import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'dart:convert' show base64Encode;
import 'dart:io';

/// Cloudinary service providing signed uploads via Supabase Edge Function
/// `cloudinary-signature` and simple URL helpers.
///
/// Env keys expected (loaded in main.dart using flutter_dotenv):
/// - CLOUDINARY_CLOUD_NAME
/// - CLOUDINARY_UPLOAD_PRESET (unsigned preset name used in your account)
class CloudinaryService {
  // Lazy singleton to avoid repeated environment parsing and Dio/Supabase client
  // construction. Use `CloudinaryService.instance` when you are sure env vars
  // exist (this will throw if they don't). Use `CloudinaryService.instanceOrNull`
  // when you want a safe, non-throwing attempt that returns null when Cloudinary
  // is not configured.
  static CloudinaryService? _instance;

  /// Returns a singleton instance, creating it from env if necessary.
  /// Throws if required environment variables are missing.
  static CloudinaryService get instance => _instance ??= CloudinaryService.fromEnv();

  /// Attempts to return a singleton instance created from env. If env is not
  /// configured or creation fails, returns null instead of throwing.
  static CloudinaryService? get instanceOrNull {
    if (_instance != null) return _instance;
    try {
      _instance = CloudinaryService.fromEnv();
      return _instance;
    } catch (_) {
      return null;
    }
  }

  /// Manually override the singleton (useful for tests or custom wiring).
  static void setInstance(CloudinaryService? svc) => _instance = svc;
  CloudinaryService({
    required String cloudName,
    required String uploadPreset,
    SupabaseClient? supabase,
  })  : _cloudName = cloudName,
        _uploadPreset = uploadPreset,
  _supabase = supabase ?? Supabase.instance.client,
  _dio = dio.Dio();

  /// Create from environment variables.
  factory CloudinaryService.fromEnv({SupabaseClient? supabase}) {
    final cloud = dotenv.maybeGet('CLOUDINARY_CLOUD_NAME') ?? '';
    final preset = dotenv.maybeGet('CLOUDINARY_UPLOAD_PRESET') ?? '';
    if (cloud.isEmpty) {
      throw StateError('Missing CLOUDINARY_CLOUD_NAME in .env');
    }
    // upload preset is optional for signed upload flows; allow empty but keep value if present.
    return CloudinaryService(
      cloudName: cloud,
      uploadPreset: preset,
      supabase: supabase,
    );
  }

  final String _cloudName;
  final String _uploadPreset;
  final SupabaseClient _supabase;
  final dio.Dio _dio;

  String get cloudName => _cloudName;
  String get uploadPreset => _uploadPreset;

  Future<_SignatureBundle> _getSignature({
    String resourceType = 'image',
    String? folder,
    String? publicId,
    Map<String, String>? context,
  }) async {
    // Cloudinary requires a Unix timestamp (seconds) for signed upload
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();

    // Build the exact params that will also be sent to Cloudinary upload API
    // Do NOT include resource_type, file, or api_key in the signature payload.
    final paramsToSign = <String, dynamic>{
      'timestamp': timestamp,
  if (_uploadPreset.isNotEmpty) 'upload_preset': _uploadPreset,
      if (folder != null && folder.isNotEmpty) 'folder': folder,
      if (publicId != null && publicId.isNotEmpty) 'public_id': publicId,
      if (context != null && context.isNotEmpty)
        'context': context.entries.map((e) => '${e.key}=${e.value}').join('|'),
    };

    final res = await _supabase.functions.invoke(
      'cloudinary-signature',
      body: paramsToSign,
    );

    final data = res.data;
    if (data is! Map) {
      throw StateError('Invalid signature response: $data');
    }
    final sig = data['signature'] as String?;
    final key = data['apiKey'] as String? ?? data['api_key'] as String?;
    if (sig == null || key == null) {
      throw StateError('Signature payload missing fields: $data');
    }
    return _SignatureBundle(signature: sig, timestamp: timestamp, apiKey: key);
  }

  /// Upload an image from a local file path.
  /// Returns the secure URL of the uploaded asset.
  Future<String> uploadImageFromPath(
    String path, {
    String? folder,
    String? publicId,
    Map<String, String>? context,
    void Function(double progress)? onProgress,
  }) async {
    // Safety check before upload
    if (kIsWeb) {
      // Path-based upload is uncommon on web; if used, we cannot read the path. Expect callers to use bytes API on web.
      // For safety, block and hint callers to use bytes flow so we can moderate.
      throw UnsafeImageException(reason: '웹에서는 bytes 기반 업로드 API를 사용하세요');
    } else {
      final safe = await _isImageSafe(await File(path).readAsBytes());
      if (!safe.allowed) {
        throw UnsafeImageException(reason: safe.reason, labels: safe.matchedLabels);
      }
    }
    final sig = await _getSignature(
      resourceType: 'image',
      folder: folder,
      publicId: publicId,
      context: context,
    );

    final url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';
    final form = dio.FormData.fromMap({
      'file': await dio.MultipartFile.fromFile(path),
      'api_key': sig.apiKey,
  'timestamp': sig.timestamp.toString(),
      'signature': sig.signature,
      // include preset if your signature generation expects it
  if (_uploadPreset.isNotEmpty) 'upload_preset': _uploadPreset,
      if (folder != null && folder.isNotEmpty) 'folder': folder,
      if (publicId != null && publicId.isNotEmpty) 'public_id': publicId,
      if (context != null && context.isNotEmpty)
        'context': context.entries.map((e) => '${e.key}=${e.value}').join('|'),
    });

  final res = await _dio.post(
      url,
      data: form,
      onSendProgress: (sent, total) {
        if (onProgress != null && total > 0) onProgress(sent / total);
      },
    );
    final data = res.data;
    if (data is Map && data['secure_url'] is String) {
      return data['secure_url'] as String;
    }
    throw StateError('Unexpected Cloudinary response: ${res.data}');
  }

  /// Upload an image from raw bytes.
  Future<String> uploadImageFromBytes(
    Uint8List bytes, {
    required String fileName,
    String? folder,
    String? publicId,
    Map<String, String>? context,
    void Function(double progress)? onProgress,
  }) async {
    // Safety check before upload
    if (kIsWeb) {
      final verdict = await _moderateOnWeb(bytes, fileName: fileName);
      if (!verdict.allowed) {
        throw UnsafeImageException(reason: verdict.reason, labels: verdict.matchedLabels);
      }
    } else {
      final safe = await _isImageSafe(bytes);
      if (!safe.allowed) {
        throw UnsafeImageException(reason: safe.reason, labels: safe.matchedLabels);
      }
    }
    final sig = await _getSignature(
      resourceType: 'image',
      folder: folder,
      publicId: publicId,
      context: context,
    );

    final url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';
    final form = dio.FormData.fromMap({
      'file': dio.MultipartFile.fromBytes(bytes, filename: fileName),
      'api_key': sig.apiKey,
  'timestamp': sig.timestamp.toString(),
      'signature': sig.signature,
  if (_uploadPreset.isNotEmpty) 'upload_preset': _uploadPreset,
      if (folder != null && folder.isNotEmpty) 'folder': folder,
      if (publicId != null && publicId.isNotEmpty) 'public_id': publicId,
      if (context != null && context.isNotEmpty)
        'context': context.entries.map((e) => '${e.key}=${e.value}').join('|'),
    });

  final res = await _dio.post(
      url,
      data: form,
      onSendProgress: (sent, total) {
        if (onProgress != null && total > 0) onProgress(sent / total);
      },
    );
    final data = res.data;
    if (data is Map && data['secure_url'] is String) {
      return data['secure_url'] as String;
    }
    throw StateError('Unexpected Cloudinary response: ${res.data}');
  }

  // --- Content safety (on-device, best-effort via ML Kit image labeling) ---
  static const double _blockConfidence = 0.65; // 65%+
  static const List<String> _blockKeywords = [
    // adult/sexual
    'explicit', 'nudity', 'nude', 'sex', 'sexual', 'porn', 'underwear', 'lingerie',
    // violence/blood/weapons
    'violence', 'violent', 'blood', 'bloody', 'gore', 'weapon', 'gun', 'rifle', 'pistol', 'knife', 'sword',
    // illegal/harmful substances
    'drugs', 'drug', 'marijuana', 'cannabis', 'cocaine', 'heroin', 'meth', 'alcohol', 'beer', 'wine', 'liquor', 'tobacco', 'cigarette', 'smoking',
  ];

  Future<_SafetyVerdict> _isImageSafe(Uint8List bytes) async {
    try {
      // Only supported on Android/iOS; skip on other platforms.
      if (!(defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
        return const _SafetyVerdict(allowed: true);
      }

      // Write to a temp file for the plugin API
      final tmpDir = await Directory.systemTemp.createTemp('mlv_');
      final f = File('${tmpDir.path}/check.jpg');
      await f.writeAsBytes(bytes, flush: true);

  final input = InputImage.fromFilePath(f.path);
  final options = ImageLabelerOptions(confidenceThreshold: 0.5);
  final labeler = ImageLabeler(options: options);
  final labels = await labeler.processImage(input);
  await labeler.close();

      final matched = <String>[];
      for (final l in labels) {
  final text = (l.label).toLowerCase();
  final conf = l.confidence;
        if (conf < _blockConfidence) continue;
        for (final kw in _blockKeywords) {
          if (text.contains(kw)) {
            matched.add('${l.label} (${(conf * 100).toStringAsFixed(0)}%)');
            break;
          }
        }
      }

      try {
        await f.parent.delete(recursive: true);
      } catch (_) {/* ignore */}

      if (matched.isNotEmpty) {
        return _SafetyVerdict(
          allowed: false,
          reason: '안전하지 않은 이미지(성인/폭력/유해 요소)로 판단됨',
          matchedLabels: matched,
        );
      }
      return const _SafetyVerdict(allowed: true);
    } catch (_) {
      // On failure of safety check, default to allow to avoid false blocks; adjust if policy requires fail-closed.
      return const _SafetyVerdict(allowed: true);
    }
  }

  /// Web-only moderation via Supabase Edge Function.
  /// Expects the function to return: { allowed: bool, reason?: string, labels?: string[] }
  Future<_SafetyVerdict> _moderateOnWeb(Uint8List bytes, {required String fileName}) async {
    try {
      if (!kIsWeb) return const _SafetyVerdict(allowed: true);
      final b64 = base64Encode(bytes);
      final overrideUrl = dotenv.maybeGet('IMAGE_SAFETY_WEB_URL')?.trim();
      Map<String, dynamic>? data;
      if (overrideUrl != null && overrideUrl.isNotEmpty) {
        final resp = await _dio.post(
          overrideUrl,
          data: {
            'fileName': fileName,
            'contentType': _inferContentType(fileName) ?? 'application/octet-stream',
            'dataBase64': b64,
          },
          options: dio.Options(
            headers: {
              'content-type': 'application/json',
            },
          ),
        );
        data = (resp.data is Map) ? Map<String, dynamic>.from(resp.data) : null;
      } else {
        final res = await _supabase.functions.invoke(
          'image-safety-web',
          body: {
            'fileName': fileName,
            'contentType': _inferContentType(fileName) ?? 'application/octet-stream',
            'dataBase64': b64,
          },
        );
        data = (res.data is Map) ? Map<String, dynamic>.from(res.data) : null;
      }

      if (data != null) {
        final allowed = (data['allowed'] == true);
        final reason = (data['reason'] as String?) ?? (allowed ? null : '검수 실패');
        final labels = (data['labels'] is List)
            ? List<String>.from(data['labels'] as List)
            : const <String>[];
        return _SafetyVerdict(allowed: allowed, reason: reason, matchedLabels: labels);
      }
      return const _SafetyVerdict(allowed: true);
    } catch (_) {
      // Fail-open by default to avoid blocking web in case of transient errors.
      return const _SafetyVerdict(allowed: true);
    }
  }

  String? _inferContentType(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.jpg') || n.endsWith('.jpeg')) return 'image/jpeg';
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    if (n.endsWith('.gif')) return 'image/gif';
    return null;
  }

  /// Build a transformed image URL from a public ID.
  /// Example: service.imageUrl('folder/my_img', width: 300, height: 300, crop: 'fill')
  String imageUrl(
    String publicId, {
    int? width,
    int? height,
    String? crop,
    String? gravity,
  bool autoFormat = true,
  bool autoQuality = true,
  }) {
    final base = 'https://res.cloudinary.com/$_cloudName/image/upload';
    final parts = <String>[];
    if (autoFormat) parts.add('f_auto');
    if (autoQuality) parts.add('q_auto');
    if (crop != null && crop.isNotEmpty) parts.add('c_$crop');
    if (width != null) parts.add('w_$width');
    if (height != null) parts.add('h_$height');
    // If crop asks auto square and gravity not provided, default to g_auto
    final g = gravity ?? ((crop == 'auto') ? 'auto' : null);
    if (g != null && g.isNotEmpty) parts.add('g_$g');
    final transform = parts.isEmpty ? '' : parts.join(',');
    final prefix = transform.isEmpty ? base : '$base/$transform';
    return '$prefix/$publicId';
  }

  /// Given a Cloudinary secure URL, return a new URL with optional transformations
  /// injected (e.g., f_auto, q_auto, c_fill, w/h, g_auto).
  /// If the URL does not match the expected Cloudinary upload pattern, returns it unchanged.
  String transformedUrlFromSecureUrl(
    String secureUrl, {
    int? width,
    int? height,
    String? crop,
    String? gravity,
    bool autoFormat = true,
    bool autoQuality = true,
  }) {
    try {
      final uri = Uri.parse(secureUrl);
      // Expecting path like: /<cloud>/image/upload/...[version]/<publicId>
      // We will inject our transformation segment right after 'upload'.
      final segments = List<String>.from(uri.pathSegments);
      final uploadIndex = segments.indexOf('upload');
      if (uri.host != 'res.cloudinary.com' || uploadIndex == -1) {
        return secureUrl; // Not a Cloudinary delivery URL.
      }

      final parts = <String>[];
      if (autoFormat) parts.add('f_auto');
      if (autoQuality) parts.add('q_auto');
      if (crop != null && crop.isNotEmpty) parts.add('c_$crop');
      if (width != null) parts.add('w_$width');
      if (height != null) parts.add('h_$height');
      final g = gravity ?? ((crop == 'auto') ? 'auto' : null);
      if (g != null && g.isNotEmpty) parts.add('g_$g');

      final transform = parts.isEmpty ? null : parts.join(',');
      if (transform == null) return secureUrl; // no-op

      // Insert transformation just after 'upload'
      final newSegments = <String>[
        ...segments.sublist(0, uploadIndex + 1),
        transform,
        ...segments.sublist(uploadIndex + 1),
      ];
      final newUri = uri.replace(pathSegments: newSegments);
      return newUri.toString();
    } catch (_) {
      return secureUrl;
    }
  }

  /// Download image bytes via Cloudinary delivery URL.
  ///
  /// Note: Prefer using the URL directly with Image.network / CachedNetworkImage
  /// for streaming/caching. This helper is for cases needing raw bytes in-app.
  Future<Uint8List> downloadImageBytes(
    String publicId, {
    int? width,
    int? height,
    String? crop,
  }) async {
    final url = imageUrl(publicId, width: width, height: height, crop: crop);
    final res = await _dio.get<List<int>>(
      url,
      options: dio.Options(responseType: dio.ResponseType.bytes),
    );
    final data = res.data;
    if (data == null) {
      throw StateError('Image download returned empty body for $url');
    }
    return Uint8List.fromList(data);
  }
}

/// Data returned by edge function for signed upload.
@immutable
class _SignatureBundle {
  const _SignatureBundle({
    required this.signature,
    required this.timestamp,
    required this.apiKey,
  });
  final String signature;
  final int timestamp;
  final String apiKey;
}

@immutable
class _SafetyVerdict {
  const _SafetyVerdict({required this.allowed, this.reason, this.matchedLabels = const []});
  final bool allowed;
  final String? reason;
  final List<String> matchedLabels;
}

class UnsafeImageException implements Exception {
  UnsafeImageException({this.reason, this.labels = const []});
  final String? reason;
  final List<String> labels;
  @override
  String toString() => 'UnsafeImageException(${reason ?? 'blocked'}, labels=$labels)';
}

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'dart:convert' show base64Encode;
import 'dart:io';
import 'dart:math' show min, max;

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
  static CloudinaryService get instance =>
      _instance ??= CloudinaryService.fromEnv();

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
  }) : _cloudName = cloudName,
       _uploadPreset = uploadPreset,
       _supabase = supabase ?? Supabase.instance.client,
       _dio = dio.Dio()..options = dio.BaseOptions(
         connectTimeout: const Duration(seconds: 30),
         receiveTimeout: const Duration(minutes: 3),
         sendTimeout: const Duration(minutes: 3),
       );

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
        throw UnsafeImageException(
          reason: safe.reason,
          labels: safe.matchedLabels,
        );
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
      // 이미지 최적화 및 리사이징 설정 (최소 용량 우선)
      'quality': 'auto:eco',   // 최소 용량 우선 품질 최적화 (eco 모드)
      'fetch_format': 'auto',  // 브라우저에 맞는 최적 포맷 자동 선택 (WebP, AVIF 등)
      'crop': 'limit',         // 원본 비율 유지하면서 크기 제한
      'width': 800,            // 최대 너비 800px (모바일 앱에 충분)
      'height': 800,           // 최대 높이 800px (모바일 앱에 충분)
      'dpr': '1.0',            // 픽셀 비율 1.0 고정 (용량 절약)
      'flags': 'progressive', // 프로그레시브 JPEG 활성화 (빠른 로딩)
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
    int maxRetries = 2,
  }) async {
    // Safety check before upload
    if (kIsWeb) {
      final verdict = await _moderateOnWeb(bytes, fileName: fileName);
      if (!verdict.allowed) {
        throw UnsafeImageException(
          reason: verdict.reason,
          labels: verdict.matchedLabels,
        );
      }
    } else {
      final safe = await _isImageSafe(bytes);
      if (!safe.allowed) {
        throw UnsafeImageException(
          reason: safe.reason,
          labels: safe.matchedLabels,
        );
      }
    }

    Exception? lastError;
    
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        if (kDebugMode) {
          print('[CloudinaryService] Uploading $fileName (attempt ${attempt + 1}/${maxRetries + 1})');
        }
        
        final sig = await _getSignature(
          resourceType: 'image',
          folder: folder,
          publicId: publicId,
          context: context,
        );

        if (kDebugMode) {
          print('[CloudinaryService] Got signature for $fileName');
        }

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
          // Use intelligent resizing - analyze dimensions and apply optimal configuration
          ...(await _buildIntelligentResizeParams(bytes, ImageResizeConfig.post))
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
          final secureUrl = data['secure_url'] as String;
          if (kDebugMode) {
            print('[CloudinaryService] Successfully uploaded $fileName: $secureUrl');
          }
          return secureUrl;
        }
        throw StateError('Unexpected Cloudinary response: ${res.data}');
        
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        
        if (kDebugMode) {
          print('[CloudinaryService] Upload failed for $fileName (attempt ${attempt + 1}): $e');
        }
        
        if (attempt < maxRetries) {
          // 재시도 전에 잠시 대기 (exponential backoff)
          final delay = Duration(seconds: (attempt + 1) * 2);
          if (kDebugMode) {
            print('[CloudinaryService] Retrying in ${delay.inSeconds} seconds...');
          }
          await Future.delayed(delay);
          continue;
        }
      }
    }
    
    // 모든 재시도 실패
    if (kDebugMode) {
      print('[CloudinaryService] All retries failed for $fileName');
    }
    throw lastError ?? Exception('Upload failed after $maxRetries retries');
  }

  /// Analyze image dimensions and properties for optimal upload configuration
  Future<ImageDimensions> analyzeImage(Uint8List bytes) async {
    try {
      final sizeResult = ImageSizeGetter.getSizeResult(MemoryInput(bytes));
      
      // Access the Size object from the result
      final size = sizeResult.size;
      
      // Handle invalid dimensions
      if (size.width <= 0 || size.height <= 0) {
        throw Exception('Invalid image dimensions');
      }
      
      final width = size.width;
      final height = size.height;
      final aspectRatio = width / height;
      
      return ImageDimensions(
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        isPortrait: height > width,
        isLandscape: width > height,
        isSquare: (width - height).abs() <= 10, // Allow 10px tolerance
      );
    } catch (e) {
      if (kDebugMode) {
        print('[CloudinaryService] Failed to analyze image dimensions: $e');
      }
      // Return reasonable defaults if analysis fails
      return const ImageDimensions(
        width: 800,
        height: 800,
        aspectRatio: 1.0,
        isPortrait: false,
        isLandscape: false,
        isSquare: true,
      );
    }
  }

  /// Upload an image with intelligent resizing based on use case
  /// This method analyzes the image dimensions and applies optimal resizing
  Future<String> uploadImageWithConfig(
    Uint8List bytes, {
    required String fileName,
    required ImageResizeConfig config,
    String? folder,
    String? publicId,
    Map<String, String>? context,
    void Function(double progress)? onProgress,
    int maxRetries = 2,
  }) async {
    // Safety check before upload
    if (kIsWeb) {
      final verdict = await _moderateOnWeb(bytes, fileName: fileName);
      if (!verdict.allowed) {
        throw UnsafeImageException(
          reason: verdict.reason,
          labels: verdict.matchedLabels,
        );
      }
    } else {
      final safe = await _isImageSafe(bytes);
      if (!safe.allowed) {
        throw UnsafeImageException(
          reason: safe.reason,
          labels: safe.matchedLabels,
        );
      }
    }

    // Analyze image dimensions
    final dimensions = await analyzeImage(bytes);
    final optimal = dimensions.getOptimalDimensions(config);

    if (kDebugMode) {
      print('[CloudinaryService] Image analysis for $fileName:');
      print('  Original: ${dimensions.width}x${dimensions.height}');
      print('  Optimal: ${optimal.width}x${optimal.height}');
      print('  Aspect ratio: ${dimensions.aspectRatio.toStringAsFixed(2)}');
      print('  Type: ${dimensions.isSquare ? 'Square' : dimensions.isPortrait ? 'Portrait' : 'Landscape'}');
    }

    Exception? lastError;
    
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        if (kDebugMode) {
          print('[CloudinaryService] Uploading $fileName (attempt ${attempt + 1}/${maxRetries + 1})');
        }
        
        final sig = await _getSignature(
          resourceType: 'image',
          folder: folder,
          publicId: publicId,
          context: context,
        );

        if (kDebugMode) {
          print('[CloudinaryService] Got signature for $fileName');
        }

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
          // Intelligent resizing configuration
          'quality': config.quality,
          'fetch_format': 'auto',
          'crop': config.cropMode,
          'width': optimal.width,
          'height': optimal.height,
          'dpr': '1.0',
          'flags': 'progressive',
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
          final secureUrl = data['secure_url'] as String;
          if (kDebugMode) {
            print('[CloudinaryService] Successfully uploaded $fileName: $secureUrl');
          }
          return secureUrl;
        }
        throw StateError('Unexpected Cloudinary response: ${res.data}');
        
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        
        if (kDebugMode) {
          print('[CloudinaryService] Upload failed for $fileName (attempt ${attempt + 1}): $e');
        }
        
        if (attempt < maxRetries) {
          // 재시도 전에 잠시 대기 (exponential backoff)
          final delay = Duration(seconds: (attempt + 1) * 2);
          if (kDebugMode) {
            print('[CloudinaryService] Retrying in ${delay.inSeconds} seconds...');
          }
          await Future.delayed(delay);
          continue;
        }
      }
    }
    
    // 모든 재시도 실패
    if (kDebugMode) {
      print('[CloudinaryService] All retries failed for $fileName');
    }
    throw lastError ?? Exception('Upload failed after $maxRetries retries');
  }

  /// Convenience method for avatar uploads
  Future<String> uploadAvatar(
    Uint8List bytes, {
    required String fileName,
    String? folder = 'avatars',
    String? publicId,
    void Function(double progress)? onProgress,
  }) async {
    return uploadImageWithConfig(
      bytes,
      fileName: fileName,
      config: ImageResizeConfig.avatar,
      folder: folder,
      publicId: publicId,
      onProgress: onProgress,
    );
  }

  /// Convenience method for post image uploads
  Future<String> uploadPostImage(
    Uint8List bytes, {
    required String fileName,
    String? folder = 'posts',
    String? publicId,
    void Function(double progress)? onProgress,
  }) async {
    return uploadImageWithConfig(
      bytes,
      fileName: fileName,
      config: ImageResizeConfig.post,
      folder: folder,
      publicId: publicId,
      onProgress: onProgress,
    );
  }

  /// Convenience method for thumbnail uploads
  Future<String> uploadThumbnail(
    Uint8List bytes, {
    required String fileName,
    String? folder = 'thumbnails',
    String? publicId,
    void Function(double progress)? onProgress,
  }) async {
    return uploadImageWithConfig(
      bytes,
      fileName: fileName,
      config: ImageResizeConfig.thumbnail,
      folder: folder,
      publicId: publicId,
      onProgress: onProgress,
    );
  }

  /// Helper method to build intelligent resize parameters for form data
  Future<Map<String, dynamic>> _buildIntelligentResizeParams(
    Uint8List bytes,
    ImageResizeConfig config,
  ) async {
    try {
      // Analyze image dimensions
      final dimensions = await analyzeImage(bytes);
      final optimal = dimensions.getOptimalDimensions(config);

      if (kDebugMode) {
        print('[CloudinaryService] Intelligent resize:');
        print('  Original: ${dimensions.width}x${dimensions.height}');
        print('  Optimal: ${optimal.width}x${optimal.height}');
        print('  Aspect ratio: ${dimensions.aspectRatio.toStringAsFixed(2)}');
        print('  Type: ${dimensions.isSquare ? 'Square' : dimensions.isPortrait ? 'Portrait' : 'Landscape'}');
      }

      return {
        'quality': config.quality,
        'fetch_format': 'auto',
        'crop': config.cropMode,
        'width': optimal.width,
        'height': optimal.height,
        'dpr': '1.0',
        'flags': 'progressive',
      };
    } catch (e) {
      if (kDebugMode) {
        print('[CloudinaryService] Failed to analyze image for intelligent resize, using defaults: $e');
      }
      // Fallback to reasonable defaults if analysis fails
      return {
        'quality': 'auto:eco',
        'fetch_format': 'auto',
        'crop': 'limit',
        'width': 1200,
        'height': 1200,
        'dpr': '1.0',
        'flags': 'progressive',
      };
    }
  }

  // --- Content safety (on-device, best-effort via ML Kit image labeling) ---
  static const double _blockConfidence = 0.65; // 65%+
  static const List<String> _blockKeywords = [
    // adult/sexual
    'explicit',
    'nudity',
    'nude',
    'sex',
    'sexual',
    'porn',
    'underwear',
    'lingerie',
    // violence/blood/weapons
    'violence',
    'violent',
    'blood',
    'bloody',
    'gore',
    'weapon',
    'gun',
    'rifle',
    'pistol',
    'knife',
    'sword',
    // illegal/harmful substances
    'drugs',
    'drug',
    'marijuana',
    'cannabis',
    'cocaine',
    'heroin',
    'meth',
    'alcohol',
    'beer',
    'wine',
    'liquor',
    'tobacco',
    'cigarette',
    'smoking',
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
      } catch (_) {
        /* ignore */
      }

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
  Future<_SafetyVerdict> _moderateOnWeb(
    Uint8List bytes, {
    required String fileName,
  }) async {
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
            'contentType':
                _inferContentType(fileName) ?? 'application/octet-stream',
            'dataBase64': b64,
          },
          options: dio.Options(headers: {'content-type': 'application/json'}),
        );
        data = (resp.data is Map) ? Map<String, dynamic>.from(resp.data) : null;
      } else {
        final res = await _supabase.functions.invoke(
          'image-safety-web',
          body: {
            'fileName': fileName,
            'contentType':
                _inferContentType(fileName) ?? 'application/octet-stream',
            'dataBase64': b64,
          },
        );
        data = (res.data is Map) ? Map<String, dynamic>.from(res.data) : null;
      }

      if (data != null) {
        final allowed = (data['allowed'] == true);
        final reason =
            (data['reason'] as String?) ?? (allowed ? null : '검수 실패');
        final labels = (data['labels'] is List)
            ? List<String>.from(data['labels'] as List)
            : const <String>[];
        return _SafetyVerdict(
          allowed: allowed,
          reason: reason,
          matchedLabels: labels,
        );
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
  const _SafetyVerdict({
    required this.allowed,
    this.reason,
    this.matchedLabels = const [],
  });
  final bool allowed;
  final String? reason;
  final List<String> matchedLabels;
}

class UnsafeImageException implements Exception {
  UnsafeImageException({this.reason, this.labels = const []});
  final String? reason;
  final List<String> labels;
  @override
  String toString() =>
      'UnsafeImageException(${reason ?? 'blocked'}, labels=$labels)';
}

/// Configuration for intelligent image resizing based on use case
@immutable
class ImageResizeConfig {
  const ImageResizeConfig({
    required this.maxDimension,
    required this.quality,
    this.targetAspectRatio,
    this.preserveAspectRatio = true,
    this.cropMode = 'limit',
    this.minDimension,
  });

  /// Maximum width or height in pixels
  final int maxDimension;
  
  /// Minimum width or height in pixels (optional)
  final int? minDimension;
  
  /// Quality setting ('auto:eco', 'auto:good', 'auto:best', or specific number)
  final String quality;
  
  /// Target aspect ratio (width/height) - if null, preserves original
  final double? targetAspectRatio;
  
  /// Whether to preserve the original aspect ratio
  final bool preserveAspectRatio;
  
  /// Cloudinary crop mode ('limit', 'fill', 'fit', 'crop', 'scale')
  final String cropMode;

  /// Profile/avatar images - small, square, high quality
  static const avatar = ImageResizeConfig(
    maxDimension: 400,
    minDimension: 100,
    quality: 'auto:good',
    targetAspectRatio: 1.0, // Square
    cropMode: 'fill',
  );

  /// Post images - medium size, preserve aspect ratio, balanced quality
  static const post = ImageResizeConfig(
    maxDimension: 1200,
    minDimension: 300,
    quality: 'auto:eco',
    preserveAspectRatio: true,
    cropMode: 'limit',
  );

  /// Thumbnail images - small, fast loading
  static const thumbnail = ImageResizeConfig(
    maxDimension: 300,
    minDimension: 150,
    quality: 'auto:eco',
    cropMode: 'fit',
  );

  /// High quality images for detailed viewing
  static const highQuality = ImageResizeConfig(
    maxDimension: 2048,
    minDimension: 800,
    quality: 'auto:best',
    preserveAspectRatio: true,
    cropMode: 'limit',
  );
}

/// Result of image dimension analysis
@immutable
class ImageDimensions {
  const ImageDimensions({
    required this.width,
    required this.height,
    required this.aspectRatio,
    required this.isPortrait,
    required this.isLandscape,
    required this.isSquare,
  });

  final int width;
  final int height;
  final double aspectRatio;
  final bool isPortrait;
  final bool isLandscape;
  final bool isSquare;

  /// Get optimal dimensions for the given config
  ({int width, int height}) getOptimalDimensions(ImageResizeConfig config) {
    if (config.targetAspectRatio != null) {
      // Force specific aspect ratio
      final targetRatio = config.targetAspectRatio!;
      if (targetRatio == 1.0) {
        // Square
        final size = min(config.maxDimension, max(width, height));
        return (width: size, height: size);
      } else {
        // Other ratios
        int newWidth, newHeight;
        if (targetRatio > aspectRatio) {
          // Target is wider
          newWidth = config.maxDimension;
          newHeight = (config.maxDimension / targetRatio).round();
        } else {
          // Target is taller
          newHeight = config.maxDimension;
          newWidth = (config.maxDimension * targetRatio).round();
        }
        return (width: newWidth, height: newHeight);
      }
    }

    // Preserve aspect ratio, constrain by max dimension
    final scale = config.maxDimension / max(width, height);
    if (scale >= 1.0) {
      // Image is already smaller than max dimension
      return (width: width, height: height);
    }

    final newWidth = (width * scale).round();
    final newHeight = (height * scale).round();

    // Apply minimum dimension constraint if specified
    if (config.minDimension != null) {
      final minScale = config.minDimension! / min(newWidth, newHeight);
      if (minScale > 1.0) {
        return (
          width: (newWidth * minScale).round(),
          height: (newHeight * minScale).round(),
        );
      }
    }

    return (width: newWidth, height: newHeight);
  }
}

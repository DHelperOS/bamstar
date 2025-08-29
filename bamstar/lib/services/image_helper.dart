import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bamstar/services/cloudinary.dart';
import 'package:flutter/foundation.dart';

/// Helper for regular (post) images. Tries to inject Cloudinary transformations
/// when the URL is a Cloudinary delivery URL. Falls back to original URL or
/// bundled asset when appropriate.
ImageProvider imageProviderFromUrl(
  String? url, {
  int? width,
  int? height,
  String crop = 'fill',
  String gravity = 'auto',
}) {
  if (url == null || url.isEmpty) {
    return const AssetImage('assets/images/placeholder/image_placeholder.png');
  }

  if (url.startsWith('assets/')) return AssetImage(url);

  if (url.startsWith('http://') || url.startsWith('https://')) {
    try {
      final cloud = CloudinaryService.instanceOrNull;
      if (cloud != null) {
        final transformed = cloud.transformedUrlFromSecureUrl(
          url,
          width: width,
          height: height,
          crop: crop,
          gravity: gravity,
          autoFormat: true,
          autoQuality: true,
        );
        return CachedNetworkImageProvider(transformed);
      }
    } catch (_) {
      // ignore and fall back
    }
    return CachedNetworkImageProvider(url);
  }

  return CachedNetworkImageProvider(url);
}

/// A convenience widget that uses the helper and shows a placeholder while
/// loading and an error widget on failure. It optimizes for Cloudinary
/// transformations when available.
class CloudinaryImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CloudinaryImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return placeholder ?? Container(color: Colors.grey[300], width: width, height: height);
    }

    final cloud = CloudinaryService.instanceOrNull;
    final effectiveUrl = (cloud != null)
        ? cloud.transformedUrlFromSecureUrl(url!, width: width?.toInt(), height: height?.toInt())
        : url!;

    return CachedNetworkImage(
      imageUrl: effectiveUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? Container(color: Colors.grey[300], width: width, height: height),
      errorWidget: (context, url, error) => errorWidget ?? _ErrorRetry(width: width, height: height, imageUrl: effectiveUrl),
    );
  }
}

class _ErrorRetry extends StatefulWidget {
  final double? width;
  final double? height;
  final String imageUrl;
  const _ErrorRetry({this.width, this.height, required this.imageUrl});

  @override
  State<_ErrorRetry> createState() => _ErrorRetryState();
}

class _ErrorRetryState extends State<_ErrorRetry> {
  int _attempt = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.broken_image, size: 36, color: Colors.grey),
            const SizedBox(height: 8),
            Text('이미지 로드 실패', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() => _attempt++);
              },
              child: const Text('다시 시도'),
            ),
            // Invisible image to trigger retry when _attempt changes
            SizedBox(
              width: 0,
              height: 0,
              child: _attempt == 0 ? null : Image.network(widget.imageUrl),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to upload images with intelligent resizing
/// Automatically chooses the best configuration based on use case
Future<String> uploadImageIntelligently(
  Uint8List bytes, {
  required String fileName,
  required ImageUploadType type,
  String? customFolder,
  String? publicId,
  void Function(double progress)? onProgress,
}) async {
  final cloudinary = CloudinaryService.instance;
  
  switch (type) {
    case ImageUploadType.avatar:
      return cloudinary.uploadAvatar(
        bytes,
        fileName: fileName,
        folder: customFolder ?? 'avatars',
        publicId: publicId,
        onProgress: onProgress,
      );
    case ImageUploadType.post:
      return cloudinary.uploadPostImage(
        bytes,
        fileName: fileName,
        folder: customFolder ?? 'posts',
        publicId: publicId,
        onProgress: onProgress,
      );
    case ImageUploadType.thumbnail:
      return cloudinary.uploadThumbnail(
        bytes,
        fileName: fileName,
        folder: customFolder ?? 'thumbnails',
        publicId: publicId,
        onProgress: onProgress,
      );
    case ImageUploadType.highQuality:
      return cloudinary.uploadImageWithConfig(
        bytes,
        fileName: fileName,
        config: ImageResizeConfig.highQuality,
        folder: customFolder ?? 'high-quality',
        publicId: publicId,
        onProgress: onProgress,
      );
  }
}

/// Types of image uploads with different optimization strategies
enum ImageUploadType {
  /// Profile/avatar images - square, optimized for small display
  avatar,
  
  /// Regular post images - preserve aspect ratio, balanced quality
  post,
  
  /// Thumbnail images - small, fast loading
  thumbnail,
  
  /// High quality images for detailed viewing
  highQuality,
}

/// Get recommended upload type based on image characteristics
Future<ImageUploadType> getRecommendedUploadType(
  Uint8List bytes, {
  bool isProfileImage = false,
  bool isThumbnail = false,
  bool needsHighQuality = false,
}) async {
  if (isProfileImage) return ImageUploadType.avatar;
  if (isThumbnail) return ImageUploadType.thumbnail;
  if (needsHighQuality) return ImageUploadType.highQuality;
  
  try {
    final cloudinary = CloudinaryService.instanceOrNull;
    if (cloudinary != null) {
      final dimensions = await cloudinary.analyzeImage(bytes);
      
      // Large images benefit from high quality
      if (dimensions.width > 1920 || dimensions.height > 1920) {
        return ImageUploadType.highQuality;
      }
      
      // Small images can be thumbnails
      if (dimensions.width < 300 && dimensions.height < 300) {
        return ImageUploadType.thumbnail;
      }
      
      // Square images might be avatars
      if (dimensions.isSquare && dimensions.width <= 800) {
        return ImageUploadType.avatar;
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('[ImageHelper] Failed to analyze image for type recommendation: $e');
    }
  }
  
  // Default to post type
  return ImageUploadType.post;
}

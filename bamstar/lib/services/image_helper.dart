import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bamstar/services/cloudinary.dart';

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


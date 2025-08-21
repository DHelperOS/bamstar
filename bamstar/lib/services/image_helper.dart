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

    // Use CachedNetworkImage for built-in placeholder/error behavior but prefer
    // Cloudinary-transformed URL where possible.
    try {
      final provider = imageProviderFromUrl(url, width: width?.toInt(), height: height?.toInt());
      return Image(image: provider, width: width, height: height, fit: fit);
    } catch (_) {
      return errorWidget ?? Container(color: Colors.grey[200], width: width, height: height);
    }
  }
}


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

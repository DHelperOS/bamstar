import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bamstar/services/cloudinary.dart';

/// Small helper to normalize avatar/profile image sources.
/// If [url] is a Cloudinary delivery URL, attempt to inject transformations
/// (width/height/crop) via [CloudinaryService.transformedUrlFromSecureUrl].
/// Falls back to the original URL on any error or when Cloudinary is not
/// configured. If [url] is an asset path, returns AssetImage.
ImageProvider avatarImageProviderFromUrl(
  String? url, {
  int width = 100,
  int height = 100,
  String crop = 'fill',
  String gravity = 'auto',
}) {
  if (url == null || url.isEmpty) {
    // Fallback to a bundled avatar asset — keep this lightweight.
    return const AssetImage('assets/images/avatar/avatar-1.webp');
  }

  if (url.startsWith('assets/')) return AssetImage(url);

  // For network URLs, try to use Cloudinary transform when possible.
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
      // ignore and fall back to original URL
    }
    return CachedNetworkImageProvider(url);
  }

  // Unknown format, use network provider as last resort.
  return CachedNetworkImageProvider(url);
}

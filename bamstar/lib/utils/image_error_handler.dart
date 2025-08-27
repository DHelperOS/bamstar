import 'package:flutter/material.dart';

/// Utility class for handling image loading errors gracefully
class ImageErrorHandler {
  
  /// Creates an ImageProvider with error handling and fallback
  static ImageProvider createSafeImageProvider(
    String? imageUrl, {
    ImageProvider? fallbackImage,
    String? fallbackAsset,
  }) {
    // If no URL provided, use fallback immediately
    if (imageUrl == null || imageUrl.isEmpty) {
      return _getFallbackImage(fallbackImage, fallbackAsset);
    }
    
    // Return NetworkImage with error handling
    return NetworkImage(imageUrl);
  }
  
  /// Widget that handles image loading errors gracefully
  static Widget buildSafeImage({
    required String? imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    String? fallbackAsset,
    Widget? errorWidget,
    Widget? loadingWidget,
  }) {
    // Default error widget
    final defaultErrorWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey[600],
        size: width * 0.3,
      ),
    );

    // Default loading widget
    final defaultLoadingWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );

    // If no URL provided, show fallback immediately
    if (imageUrl == null || imageUrl.isEmpty) {
      if (fallbackAsset != null) {
        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: Image.asset(
            fallbackAsset,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Asset image failed to load: $fallbackAsset');
              return errorWidget ?? defaultErrorWidget;
            },
          ),
        );
      }
      return errorWidget ?? defaultErrorWidget;
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return loadingWidget ?? defaultLoadingWidget;
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Network image failed to load: $imageUrl - Error: $error');
          
          // Try fallback asset if provided
          if (fallbackAsset != null) {
            return Image.asset(
              fallbackAsset,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, assetError, assetStackTrace) {
                debugPrint('Fallback asset also failed: $fallbackAsset');
                return errorWidget ?? defaultErrorWidget;
              },
            );
          }
          
          return errorWidget ?? defaultErrorWidget;
        },
      ),
    );
  }
  
  /// Get fallback image provider
  static ImageProvider _getFallbackImage(
    ImageProvider? fallbackImage,
    String? fallbackAsset,
  ) {
    if (fallbackImage != null) {
      return fallbackImage;
    }
    if (fallbackAsset != null) {
      return AssetImage(fallbackAsset);
    }
    // Return a transparent image as ultimate fallback
    return const AssetImage('assets/images/placeholder.png'); // Add this asset
  }
}

/// Extension to add safe image methods to String
extension SafeImageUrl on String? {
  
  /// Convert string URL to safe ImageProvider
  ImageProvider toSafeImageProvider({
    ImageProvider? fallbackImage,
    String? fallbackAsset,
  }) {
    return ImageErrorHandler.createSafeImageProvider(
      this,
      fallbackImage: fallbackImage,
      fallbackAsset: fallbackAsset,
    );
  }
  
  /// Build safe image widget from URL
  Widget toSafeImage({
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    String? fallbackAsset,
    Widget? errorWidget,
    Widget? loadingWidget,
  }) {
    return ImageErrorHandler.buildSafeImage(
      imageUrl: this,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      fallbackAsset: fallbackAsset,
      errorWidget: errorWidget,
      loadingWidget: loadingWidget,
    );
  }
}
// Centralized constants for community UI sizing
class CommunitySizes {
  // Base avatar size used throughout community screens (logical pixels).
  // Increase this to make community avatars larger globally.
  static const double avatarBase = 30.0;
  // Scale factor applied only to AvatarStack rendered avatars.
  // Set to 0.85 to render stack avatars 15% smaller than the base size.
  static const double avatarStackScale = 0.85;
  // Image layout constants used by post and comment galleries
  // Single image max height (preserve aspect up to this height)
  static const double imageSingleMaxHeight = 180.0;
  // Square thumbnail size for multi-image grids
  static const double imageThumbSize =
      140.0; // Updated per request (match larger comment/feed thumbnails)
  // Spacing between thumbnails
  static const double imageThumbSpacing = 4.0;
}

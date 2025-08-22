import 'package:flutter/material.dart';
import 'package:avatar_stack/animated_avatar_stack.dart';
import 'package:bamstar/scenes/community/community_constants.dart';
import 'package:bamstar/services/avatar_helper.dart';

/// Adapter that preserves the old local API (`avatarUrls`, `size`, `maxDisplay`)
/// while delegating rendering to the external `avatar_stack` package.
class AvatarStack extends StatelessWidget {
  final List<String> avatarUrls;
  final double size;
  final double? avatarSize; // explicit per-avatar size override
  final double overlapFactor; // how much avatars overlap (0..1)
  final int maxDisplay;
  const AvatarStack({
    super.key,
    required this.avatarUrls,
    this.size = CommunitySizes.avatarBase,
    this.avatarSize,
    this.overlapFactor = 0.6,
    this.maxDisplay = 3,
  });

  @override
  Widget build(BuildContext context) {
    // Deduplicate while preserving order to avoid duplicate keys inside AnimatedAvatarStack.
    final seen = <String>{};
    final toShow = <String>[];
    for (final u in avatarUrls) {
      final trimmed = u.trim();
      if (trimmed.isEmpty) continue;
      if (seen.add(trimmed)) {
        toShow.add(trimmed);
      }
      if (toShow.length >= maxDisplay) break;
    }
    // Determine actual per-avatar size: prefer explicit avatarSize, fallback to legacy size.
    final perAvatar = avatarSize ?? size;
    // Apply centralized stack-scale so AvatarStack renders slightly smaller than
    // the base avatar when desired (e.g. 15% reduction).
    final renderSize = perAvatar * CommunitySizes.avatarStackScale;

    if (toShow.isEmpty) return SizedBox(height: renderSize, width: renderSize);

    // The package accepts ImageProvider items (NetworkImage works).
    final avatars = toShow
        .map<ImageProvider>(
          (u) => avatarImageProviderFromUrl(
            u,
            width: renderSize.toInt(),
            height: renderSize.toInt(),
          ),
        )
        .toList();

    // Calculate a finite width to avoid LayoutBuilder receiving infinite constraints
    // (the package expects a bounded width to compute stacking). This mirrors the
    // previous local implementation's width calculation but uses renderSize.
    final width =
        renderSize + (avatars.length - 1) * (renderSize * overlapFactor);

    return SizedBox(
      height: renderSize,
      width: width,
      child: AnimatedAvatarStack(
        height: renderSize,
        avatars: avatars,
        // keep defaults for alignment/coverage; could expose more props if needed
      ),
    );
  }
}

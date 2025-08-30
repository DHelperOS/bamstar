import 'package:flutter/material.dart';
import '../models/match_profile.dart';
import 'package:bamstar/theme/app_text_styles.dart';
import 'package:solar_icons/solar_icons.dart';

/// Match card widget for flutter_card_swiper
class MatchCard extends StatelessWidget {
  final MatchProfile profile;
  final VoidCallback? onTap;

  const MatchCard({
    super.key,
    required this.profile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 32;
    final cardHeight = cardWidth * 1.4;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile image area
              Expanded(
                flex: 3,
                child: Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Icon(
                      profile.type == ProfileType.place
                          ? SolarIconsOutline.shop
                          : SolarIconsOutline.user,
                      size: 64,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              // Info section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and match score
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.name,
                                  style: AppTextStyles.sectionTitle(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile.subtitle,
                                  style: AppTextStyles.secondaryText(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Match score badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getScoreGradient(profile.matchScore, colorScheme),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  SolarIconsBold.star,
                                  size: 16,
                                  color: colorScheme.surface,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${profile.matchScore}%',
                                  style: AppTextStyles.captionText(context).copyWith(
                                    color: colorScheme.surface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Location and distance
                      Row(
                        children: [
                          Icon(
                            SolarIconsOutline.mapPoint,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profile.location,
                            style: AppTextStyles.captionText(context),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colorScheme.onSurfaceVariant,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            profile.formattedDistance,
                            style: AppTextStyles.captionText(context).copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Pay info
                      Row(
                        children: [
                          Icon(
                            SolarIconsOutline.wallet,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              profile.payInfo,
                              style: AppTextStyles.captionText(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Tags
                      SizedBox(
                        height: 28,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: profile.tags.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 6),
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colorScheme.outline.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                profile.tags[index],
                                style: AppTextStyles.captionText(context).copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getScoreGradient(int score, ColorScheme colorScheme) {
    if (score >= 90) {
      return [
        colorScheme.primary,
        colorScheme.primary.withValues(alpha: 0.8),
      ];
    } else if (score >= 70) {
      return [
        colorScheme.tertiary,
        colorScheme.tertiary.withValues(alpha: 0.8),
      ];
    } else {
      return [
        colorScheme.secondary,
        colorScheme.secondary.withValues(alpha: 0.8),
      ];
    }
  }
}
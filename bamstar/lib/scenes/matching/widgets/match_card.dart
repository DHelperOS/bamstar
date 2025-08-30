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
        child: Stack(
          children: [
            ClipRRect(
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
                      // Name and profile badges
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side - Name and subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      profile.name,
                                      style: AppTextStyles.sectionTitle(context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 4),
                                    // Gender icon based on actual gender data
                                    if (profile.gender != null)
                                      Icon(
                                        profile.gender == 'MALE' 
                                          ? SolarIconsOutline.men 
                                          : SolarIconsOutline.women,
                                        size: 16,
                                        color: profile.gender == 'MALE'
                                          ? const Color(0xFF2196F3) // Blue for male
                                          : const Color(0xFFF44336), // Red for female
                                      ),
                                  ],
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
                          // Right side - Profile info badges
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Wrap(
                                alignment: WrapAlignment.end,
                                spacing: 4,
                                runSpacing: 4,
                                children: _getProfileBadges(profile, colorScheme).map((badge) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: colorScheme.primary,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (badge['icon'] != null) ...[
                                          Icon(
                                            badge['icon'],
                                            size: 12,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        Text(
                                          badge['text'],
                                          style: AppTextStyles.captionText(context).copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
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
                      // Tags with scroll (no swipe interference)
                      SizedBox(
                        height: 28,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            // Prevent scroll events from bubbling up to parent swiper
                            return true;
                          },
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const ClampingScrollPhysics(), // Enable horizontal scroll
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Match score badge positioned at top-right of image (아이콘 제거)
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '매칭률: ${profile.matchScore}%',
              style: AppTextStyles.captionText(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ),

        // Hearts and Favorites count (좋아요/즐겨찾기 갯수)
        Positioned(
          top: 16,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (profile.heartsCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B9D).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        SolarIconsOutline.heart,
                        size: 10,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${profile.heartsCount}',
                        style: AppTextStyles.captionText(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              if (profile.heartsCount > 0 && profile.favoritesCount > 0)
                const SizedBox(height: 4),
              if (profile.favoritesCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD93D).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        SolarIconsOutline.star,
                        size: 10,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${profile.favoritesCount}',
                        style: AppTextStyles.captionText(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
      ),
    );
  }

  /// Generate profile info badges based on available data
  List<Map<String, dynamic>> _getProfileBadges(MatchProfile profile, ColorScheme colorScheme) {
    List<Map<String, dynamic>> badges = [];
    
    // Age badge - Extract age from tags or use default
    String ageText = '25세'; // Default
    for (String tag in profile.tags) {
      if (tag.contains('세') || tag.contains('20대') || tag.contains('30대')) {
        if (tag.contains('20대')) {
          ageText = '20대';
        } else if (tag.contains('30대')) {
          ageText = '30대';
        } else if (tag.contains('세')) {
          ageText = tag;
        }
        break;
      }
    }
    badges.add({
      'text': ageText,
      'icon': SolarIconsOutline.calendar,
    });
    
    // Experience/Career badge (필수 - 기존 subtitle 활용)
    badges.add({
      'text': profile.subtitle.isNotEmpty ? profile.subtitle : '신입',
      'icon': SolarIconsOutline.bagSmile,
    });
    
    return badges;
  }

}
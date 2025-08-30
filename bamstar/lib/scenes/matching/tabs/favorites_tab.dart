import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bamstar/theme/app_text_styles.dart';
import 'package:solar_icons/solar_icons.dart';
import '../models/match_profile.dart';
import 'package:bamstar/utils/toast_helper.dart';

/// Favorites Tab - Manage saved/bookmarked profiles
class FavoritesTab extends ConsumerStatefulWidget {
  final bool isMemberView;
  final Function(int) onFavoritesCountChanged;
  
  const FavoritesTab({
    super.key,
    required this.isMemberView,
    required this.onFavoritesCountChanged,
  });

  @override
  ConsumerState<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends ConsumerState<FavoritesTab> 
    with AutomaticKeepAliveClientMixin {
  final List<MatchProfile> _favorites = [];
  bool _isLoading = true;
  String _sortBy = 'date'; // date, score, distance
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    // TODO: Load favorites from Supabase
    setState(() {
      _favorites.clear();
      _favorites.addAll(_generateMockFavorites());
      _isLoading = false;
    });
    
    widget.onFavoritesCountChanged(_favorites.length);
  }

  List<MatchProfile> _generateMockFavorites() {
    if (widget.isMemberView) {
      return [
        MatchProfile(
          id: '1',
          name: '테라로사',
          subtitle: '강릉본점',
          imageUrl: null,
          matchScore: 98,
          location: '강릉시 구정면',
          distance: 180.5,
          payInfo: '시급 18,000원',
          schedule: '평일 오전',
          tags: ['로스터리카페', '커피교육', '기숙사제공', '정규직전환'],
          type: ProfileType.place,
          isPremium: true,
        ),
        MatchProfile(
          id: '2',
          name: '% 아라비카',
          subtitle: '한남점',
          imageUrl: null,
          matchScore: 94,
          location: '용산구 한남동',
          distance: 4.8,
          payInfo: '시급 16,000원',
          schedule: '시간협의',
          tags: ['프리미엄카페', '바리스타교육', '영어필수'],
          type: ProfileType.place,
        ),
        MatchProfile(
          id: '3',
          name: '프릳츠커피',
          subtitle: '도산점',
          imageUrl: null,
          matchScore: 91,
          location: '강남구 신사동',
          distance: 2.1,
          payInfo: '시급 15,000원',
          schedule: '평일/주말',
          tags: ['스페셜티커피', '로스팅교육', '직원할인'],
          type: ProfileType.place,
        ),
        MatchProfile(
          id: '4',
          name: '센터커피',
          subtitle: '성수점',
          imageUrl: null,
          matchScore: 89,
          location: '성동구 성수동',
          distance: 3.5,
          payInfo: '시급 14,500원',
          schedule: '평일 오후',
          tags: ['로스터리', '라떼아트교육', '팀워크좋음'],
          type: ProfileType.place,
        ),
        MatchProfile(
          id: '5',
          name: '하이브로우',
          subtitle: '이태원점',
          imageUrl: null,
          matchScore: 87,
          location: '용산구 이태원동',
          distance: 5.2,
          payInfo: '시급 14,000원',
          schedule: '주말근무',
          tags: ['브런치카페', '팁문화', '외국인많음'],
          type: ProfileType.place,
        ),
        MatchProfile(
          id: '6',
          name: '커피리브레',
          subtitle: '연남점',
          imageUrl: null,
          matchScore: 85,
          location: '마포구 연남동',
          distance: 6.8,
          payInfo: '시급 13,500원',
          schedule: '시간협의',
          tags: ['동네카페', '친절한사장님', '자유로운분위기'],
          type: ProfileType.place,
        ),
      ];
    } else {
      return [
        MatchProfile(
          id: '1',
          name: '윤서준',
          subtitle: 'Q-Grader, 바리스타 8년차',
          imageUrl: null,
          matchScore: 99,
          location: '강남구 거주',
          distance: 0.3,
          payInfo: '희망시급 20,000원',
          schedule: '평일 오전',
          tags: ['Q-Grader', 'SCA마스터', '로스팅전문', '매니저10년'],
          type: ProfileType.member,
          isPremium: true,
        ),
        MatchProfile(
          id: '2',
          name: '한지민',
          subtitle: '바리스타 5년차',
          imageUrl: null,
          matchScore: 95,
          location: '서초구 거주',
          distance: 1.5,
          payInfo: '희망시급 16,000원',
          schedule: '평일가능',
          tags: ['라떼아트전문', '대회수상', '영어/일어가능'],
          type: ProfileType.member,
        ),
        MatchProfile(
          id: '3',
          name: '조민호',
          subtitle: '카페 매니저 7년차',
          imageUrl: null,
          matchScore: 92,
          location: '송파구 거주',
          distance: 3.2,
          payInfo: '희망시급 18,000원',
          schedule: '풀타임가능',
          tags: ['매니저경험', '매출관리', '직원교육', '창업경험'],
          type: ProfileType.member,
        ),
        MatchProfile(
          id: '4',
          name: '김예린',
          subtitle: '바리스타 3년차',
          imageUrl: null,
          matchScore: 88,
          location: '강동구 거주',
          distance: 4.5,
          payInfo: '희망시급 14,500원',
          schedule: '평일 오후',
          tags: ['디저트제조', '친절', '책임감강함'],
          type: ProfileType.member,
        ),
        MatchProfile(
          id: '5',
          name: '이도현',
          subtitle: '바리스타 4년차',
          imageUrl: null,
          matchScore: 86,
          location: '성동구 거주',
          distance: 2.8,
          payInfo: '희망시급 15,000원',
          schedule: '주말가능',
          tags: ['로스팅가능', '장비관리', '성실'],
          type: ProfileType.member,
        ),
        MatchProfile(
          id: '6',
          name: '박소연',
          subtitle: '카페 경력 2년',
          imageUrl: null,
          matchScore: 83,
          location: '마포구 거주',
          distance: 5.5,
          payInfo: '희망시급 13,500원',
          schedule: '시간협의',
          tags: ['브런치조리', '베이킹', '친절'],
          type: ProfileType.member,
        ),
      ];
    }
  }

  void _sortFavorites(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      switch (sortBy) {
        case 'score':
          _favorites.sort((a, b) => b.matchScore.compareTo(a.matchScore));
          break;
        case 'distance':
          _favorites.sort((a, b) => a.distance.compareTo(b.distance));
          break;
        case 'date':
        default:
          // Keep original order (most recent first)
          break;
      }
    });
  }

  void _removeFavorite(MatchProfile profile) {
    setState(() {
      _favorites.remove(profile);
    });
    widget.onFavoritesCountChanged(_favorites.length);
    ToastHelper.info(context, '즐겨찾기에서 제거했습니다');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Column(
      children: [
        // Header with sort options
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                SolarIconsBold.bookmark,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '즐겨찾기',
                style: AppTextStyles.sectionTitle(context),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_favorites.length}개',
                  style: AppTextStyles.captionText(context).copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              // Sort dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  icon: Icon(
                    SolarIconsOutline.sort,
                    size: 16,
                    color: colorScheme.onSurface,
                  ),
                  style: AppTextStyles.captionText(context),
                  items: [
                    DropdownMenuItem(
                      value: 'date',
                      child: Text('최신순', style: AppTextStyles.captionText(context)),
                    ),
                    DropdownMenuItem(
                      value: 'score',
                      child: Text('매칭순', style: AppTextStyles.captionText(context)),
                    ),
                    DropdownMenuItem(
                      value: 'distance',
                      child: Text('거리순', style: AppTextStyles.captionText(context)),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _sortFavorites(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Favorites list
        Expanded(
          child: _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        SolarIconsOutline.bookmarkOpened,
                        size: 64,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '아직 즐겨찾기가 없습니다',
                        style: AppTextStyles.primaryText(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '마음에 드는 프로필을 저장해보세요',
                        style: AppTextStyles.secondaryText(context),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to recommendation tab
                          DefaultTabController.of(context).animateTo(0);
                        },
                        icon: Icon(
                          SolarIconsOutline.stars,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        label: Text(
                          '프로필 둘러보기',
                          style: AppTextStyles.buttonText(context).copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final profile = _favorites[index];
                      return _FavoriteCard(
                        profile: profile,
                        onRemove: () => _removeFavorite(profile),
                        onLike: () {
                          ToastHelper.success(
                            context,
                            '${profile.name}에게 좋아요를 보냈습니다',
                          );
                        },
                        onTap: () {
                          // TODO: Navigate to profile detail
                          _showProfileDetail(profile);
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _showProfileDetail(MatchProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProfileDetailSheet(
        profile: profile,
        onLike: () {
          Navigator.pop(context);
          ToastHelper.success(
            context,
            '${profile.name}에게 좋아요를 보냈습니다',
          );
        },
        onRemove: () {
          Navigator.pop(context);
          _removeFavorite(profile);
        },
      ),
    );
  }
}

// Favorite card widget
class _FavoriteCard extends StatelessWidget {
  final MatchProfile profile;
  final VoidCallback onRemove;
  final VoidCallback onLike;
  final VoidCallback onTap;

  const _FavoriteCard({
    required this.profile,
    required this.onRemove,
    required this.onLike,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: profile.isPremium
                ? Colors.amber.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.1),
            width: profile.isPremium ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image section
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: profile.isPremium
                      ? [Colors.amber.shade100, Colors.orange.shade100]
                      : [
                          colorScheme.primaryContainer,
                          colorScheme.secondaryContainer,
                        ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      profile.type == ProfileType.place
                          ? SolarIconsBold.shop
                          : SolarIconsBold.user,
                      size: 48,
                      color: profile.isPremium
                          ? Colors.amber.shade700
                          : colorScheme.onPrimaryContainer,
                    ),
                  ),
                  // Premium badge
                  if (profile.isPremium)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              SolarIconsBold.crown,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Match score
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profile.scoreEmoji,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.matchScore}%',
                            style: AppTextStyles.captionText(context).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: AppTextStyles.cardTitle(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.subtitle,
                              style: AppTextStyles.secondaryText(context),
                            ),
                          ],
                        ),
                      ),
                      // Distance badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getDistanceColor(profile.distance).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              SolarIconsOutline.mapPoint,
                              size: 12,
                              color: _getDistanceColor(profile.distance),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              profile.formattedDistance,
                              style: AppTextStyles.captionText(context).copyWith(
                                color: _getDistanceColor(profile.distance),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: profile.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.chipLabel(context).copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onRemove,
                          icon: Icon(
                            SolarIconsOutline.bookmarkOpened,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          label: Text(
                            '제거',
                            style: AppTextStyles.buttonText(context).copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onLike,
                          icon: const Icon(
                            SolarIconsBold.heart,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            '좋아요',
                            style: AppTextStyles.buttonText(context).copyWith(
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDistanceColor(double distance) {
    if (distance < 1.0) return Colors.green;
    if (distance < 3.0) return Colors.blue;
    if (distance < 5.0) return Colors.orange;
    return Colors.red;
  }
}

// Profile detail bottom sheet
class _ProfileDetailSheet extends StatelessWidget {
  final MatchProfile profile;
  final VoidCallback onLike;
  final VoidCallback onRemove;

  const _ProfileDetailSheet({
    required this.profile,
    required this.onLike,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Profile header
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: profile.isPremium
                                  ? [Colors.amber.shade200, Colors.orange.shade200]
                                  : [
                                      colorScheme.primaryContainer,
                                      colorScheme.secondaryContainer,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Icon(
                              profile.type == ProfileType.place
                                  ? SolarIconsBold.shop
                                  : SolarIconsBold.user,
                              size: 40,
                              color: profile.isPremium
                                  ? Colors.amber.shade700
                                  : colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: AppTextStyles.pageTitle(context),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.subtitle,
                                style: AppTextStyles.secondaryText(context),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getScoreColor(profile.matchScore).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          profile.scoreEmoji,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${profile.matchScore}%',
                                          style: AppTextStyles.captionText(context).copyWith(
                                            color: _getScoreColor(profile.matchScore),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (profile.isPremium) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            SolarIconsBold.crown,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'PREMIUM',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Info sections
                    _InfoSection(
                      icon: SolarIconsOutline.mapPoint,
                      title: '위치',
                      content: '${profile.location} (${profile.formattedDistance})',
                    ),
                    _InfoSection(
                      icon: SolarIconsOutline.wallet,
                      title: '급여',
                      content: profile.payInfo,
                    ),
                    _InfoSection(
                      icon: SolarIconsOutline.calendar,
                      title: '근무시간',
                      content: profile.schedule,
                    ),
                    // Tags
                    const SizedBox(height: 16),
                    Text(
                      '특징',
                      style: AppTextStyles.formLabel(context),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            tag,
                            style: AppTextStyles.chipLabel(context).copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              // Action buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRemove,
                        icon: Icon(
                          SolarIconsOutline.bookmarkOpened,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        label: Text(
                          '즐겨찾기 제거',
                          style: AppTextStyles.buttonText(context).copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          side: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onLike,
                        icon: const Icon(
                          SolarIconsBold.heart,
                          color: Colors.white,
                        ),
                        label: Text(
                          '좋아요 보내기',
                          style: AppTextStyles.buttonText(context).copyWith(
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.red;
    if (score >= 80) return Colors.orange;
    if (score >= 70) return Colors.blue;
    return Colors.grey;
  }
}

// Info section widget
class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.captionText(context),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: AppTextStyles.primaryText(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
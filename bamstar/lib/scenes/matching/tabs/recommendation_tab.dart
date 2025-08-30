import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:bamstar/theme/app_text_styles.dart';
import 'package:solar_icons/solar_icons.dart';
import '../widgets/match_card.dart';
import '../models/match_profile.dart';
import 'package:bamstar/utils/toast_helper.dart';

/// Recommendation Tab - AI-powered matching with swipe cards
class RecommendationTab extends ConsumerStatefulWidget {
  final bool isMemberView;
  
  const RecommendationTab({
    super.key,
    required this.isMemberView,
  });

  @override
  ConsumerState<RecommendationTab> createState() => _RecommendationTabState();
}

class _RecommendationTabState extends ConsumerState<RecommendationTab> 
    with AutomaticKeepAliveClientMixin {
  final List<MatchProfile> _profiles = [];
  bool _isLoading = true;
  final CardSwiperController _swiperController = CardSwiperController();
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    // TODO: Load profiles from Supabase based on user type
    // For now, using mock data
    setState(() {
      _profiles.addAll(_generateMockProfiles());
      _isLoading = false;
    });
  }

  List<MatchProfile> _generateMockProfiles() {
    if (widget.isMemberView) {
      // Member sees Place profiles
      return [
        MatchProfile(
          id: '1',
          name: '카페 델라루나',
          subtitle: '강남점',
          imageUrl: null,
          matchScore: 92,
          location: '강남구 역삼동',
          distance: 2.3,
          payInfo: '시급 13,000-15,000원',
          schedule: '평일/주말 협의가능',
          tags: ['라떼아트교육', '식사제공', '교통비지원', '친절한사장님'],
          type: ProfileType.place,
        ),
        MatchProfile(
          id: '2',
          name: '스타벅스',
          subtitle: '역삼점',
          imageUrl: null,
          matchScore: 87,
          location: '강남구 역삼동',
          distance: 0.8,
          payInfo: '시급 12,000원',
          schedule: '주 5일 근무',
          tags: ['대기업', '복지우수', '정규직전환'],
          type: ProfileType.place,
        ),
        MatchProfile(
          id: '3',
          name: '투썸플레이스',
          subtitle: '삼성점',
          imageUrl: null,
          matchScore: 85,
          location: '강남구 삼성동',
          distance: 1.5,
          payInfo: '시급 13,000원',
          schedule: '시간협의',
          tags: ['바리스타교육', '유니폼제공'],
          type: ProfileType.place,
        ),
        MatchProfile(
          id: '4',
          name: '블루보틀',
          subtitle: '성수점',
          imageUrl: null,
          matchScore: 90,
          location: '성동구 성수동',
          distance: 3.2,
          payInfo: '시급 14,000원',
          schedule: '주말 필수',
          tags: ['스페셜티커피', '교육지원', '성과급'],
          type: ProfileType.place,
        ),
        MatchProfile(
          id: '5',
          name: '폴바셋',
          subtitle: '강남대로점',
          imageUrl: null,
          matchScore: 88,
          location: '강남구 역삼동',
          distance: 1.1,
          payInfo: '시급 13,500원',
          schedule: '평일 오전',
          tags: ['브런치제공', '직원할인', '교육체계우수'],
          type: ProfileType.place,
        ),
      ];
    } else {
      // Place sees Member profiles
      return [
        MatchProfile(
          id: '1',
          name: '김민수',
          subtitle: '바리스타 3년차',
          imageUrl: null,
          matchScore: 94,
          location: '강남구 거주',
          distance: 2.0,
          payInfo: '희망시급 15,000원',
          schedule: '평일 오전 가능',
          tags: ['라떼아트', '로스팅자격증', '친절', '성실'],
          type: ProfileType.member,
        ),
        MatchProfile(
          id: '2',
          name: '이서연',
          subtitle: '카페 경력 2년',
          imageUrl: null,
          matchScore: 89,
          location: '서초구 거주',
          distance: 3.5,
          payInfo: '희망시급 14,000원',
          schedule: '주말 가능',
          tags: ['영어가능', '손님응대우수', '팀워크'],
          type: ProfileType.member,
        ),
        MatchProfile(
          id: '3',
          name: '박준영',
          subtitle: '신입 열정',
          imageUrl: null,
          matchScore: 82,
          location: '송파구 거주',
          distance: 5.2,
          payInfo: '희망시급 12,000원',
          schedule: '풀타임 가능',
          tags: ['열정적', '빠른습득', '장기근무가능'],
          type: ProfileType.member,
        ),
        MatchProfile(
          id: '4',
          name: '최지우',
          subtitle: '스페셜티 전문',
          imageUrl: null,
          matchScore: 91,
          location: '강남구 거주',
          distance: 1.5,
          payInfo: '희망시급 16,000원',
          schedule: '오후 가능',
          tags: ['SCA자격증', '핸드드립', '커피지식'],
          type: ProfileType.member,
        ),
        MatchProfile(
          id: '5',
          name: '정하늘',
          subtitle: '서비스 경력 5년',
          imageUrl: null,
          matchScore: 86,
          location: '성동구 거주',
          distance: 4.0,
          payInfo: '희망시급 15,000원',
          schedule: '주 4일 희망',
          tags: ['매니저경험', '교육가능', '리더십'],
          type: ProfileType.member,
        ),
      ];
    }
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (previousIndex >= _profiles.length) return false;
    
    final profile = _profiles[previousIndex];
    HapticFeedback.lightImpact();
    
    String message = '';
    
    switch (direction) {
      case CardSwiperDirection.right:
        message = '${profile.name}에게 좋아요를 보냈습니다 ❤️';
        _sendLike(profile);
        break;
      case CardSwiperDirection.left:
        message = '다음 기회에 만나요';
        _passProfile(profile);
        break;
      case CardSwiperDirection.top:
        message = '즐겨찾기에 추가했습니다 ⭐';
        _addToFavorites(profile);
        break;
      case CardSwiperDirection.bottom:
        // Undo functionality
        return true;
      case CardSwiperDirection.none:
        // No swipe
        return false;
    }
    
    ToastHelper.info(context, message);
    
    // Load more profiles when running low
    if (currentIndex != null && currentIndex >= _profiles.length - 2) {
      _loadProfiles();
    }
    
    return true;
  }

  Future<void> _sendLike(MatchProfile profile) async {
    // TODO: Implement sending like via Supabase
  }

  Future<void> _passProfile(MatchProfile profile) async {
    // TODO: Record pass action
  }

  Future<void> _addToFavorites(MatchProfile profile) async {
    // TODO: Add to favorites via Supabase
  }

  void _showProfileDetail(MatchProfile profile) {
    // TODO: Navigate to detailed profile view
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileDetailModal(profile: profile),
    );
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
    
    if (_profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              SolarIconsOutline.document,
              size: 80,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '현재 추천할 프로필이 없습니다',
              style: AppTextStyles.primaryText(context),
            ),
            const SizedBox(height: 8),
            Text(
              '잠시 후 다시 확인해주세요',
              style: AppTextStyles.secondaryText(context),
            ),
          ],
        ),
      );
    }
    
    return Stack(
      children: [
        // Background
        Container(
          color: colorScheme.surface,
        ),
        
        // Main content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Daily limit indicator (for free users)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        SolarIconsOutline.fire,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '오늘의 매칭: 15/20',
                        style: AppTextStyles.captionText(context).copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Swipe card stack using flutter_card_swiper
                Expanded(
                  child: CardSwiper(
                    controller: _swiperController,
                    cardBuilder: (context, index, percentThresholdX, percentThresholdY) => MatchCard(
                      profile: _profiles[index],
                      onTap: () => _showProfileDetail(_profiles[index]),
                    ),
                    onSwipe: _onSwipe,
                    padding: const EdgeInsets.all(0),
                    numberOfCardsDisplayed: 3,
                    backCardOffset: const Offset(0, 30),
                    cardsCount: _profiles.length,
                    isLoop: false,
                    allowedSwipeDirection: const AllowedSwipeDirection.all(),
                    scale: 0.9,
                  ),
                ),
                
                // Action buttons - Clean minimal design
                Padding(
                  padding: const EdgeInsets.only(bottom: 32, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cancel button
                      _MinimalActionButton(
                        icon: SolarIconsOutline.closeCircle,
                        onTap: () {
                          _swiperController.swipe(CardSwiperDirection.left);
                        },
                      ),
                      const SizedBox(width: 56),
                      // Heart button (Primary)
                      _MinimalActionButton(
                        icon: SolarIconsOutline.heart,
                        isPrimary: true,
                        onTap: () {
                          _swiperController.swipe(CardSwiperDirection.right);
                        },
                      ),
                      const SizedBox(width: 56),
                      // Bookmark button
                      _MinimalActionButton(
                        icon: SolarIconsOutline.bookmark,
                        onTap: () {
                          _swiperController.swipe(CardSwiperDirection.top);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Minimal action button widget - Clean and modern
class _MinimalActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _MinimalActionButton({
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // 통일된 크기 - 심플함 극대화
    const dimension = 56.0;
    const iconSize = 24.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          // 배경 완전 투명 - 극도의 미니멀리즘
          color: Colors.transparent,
          shape: BoxShape.circle,
          // 매우 얇은 테두리만
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.15),
            width: 1.0,
          ),
        ),
        child: Icon(
          icon,
          size: iconSize,
          // Primary 버튼만 색상, 나머지는 회색
          color: isPrimary
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

// Profile detail modal
class ProfileDetailModal extends StatelessWidget {
  final MatchProfile profile;

  const ProfileDetailModal({
    super.key,
    required this.profile,
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
                    Text(
                      profile.name,
                      style: AppTextStyles.pageTitle(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.subtitle,
                      style: AppTextStyles.secondaryText(context),
                    ),
                    // TODO: Add more detailed profile information
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:bamstar/theme/app_text_styles.dart';
import 'package:solar_icons/solar_icons.dart';
import '../widgets/match_card.dart';
import '../models/match_profile.dart';
import '../../../services/matching_service.dart';
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
    try {
      setState(() {
        _isLoading = true;
      });
      
      final profiles = await MatchingService.getMatchingProfiles(
        isMemberView: widget.isMemberView,
        limit: 20,
      );
      
      setState(() {
        if (profiles.isNotEmpty) {
          _profiles.clear();
          _profiles.addAll(profiles);
        } else {
          _profiles.addAll(_generateMockProfiles());
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _profiles.addAll(_generateMockProfiles());
        _isLoading = false;
      });
      
      if (mounted) {
        ToastHelper.error(context, '데이터 로딩 중 오류가 발생했습니다');
      }
    }
  }

  List<MatchProfile> _generateMockProfiles() {
    if (widget.isMemberView) {
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
      ];
    } else {
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
    
    switch (direction) {
      case CardSwiperDirection.right:
        _sendLike(profile);
        break;
      case CardSwiperDirection.left:
        _passProfile(profile);
        break;
      case CardSwiperDirection.top:
        _addToFavorites(profile);
        break;
      case CardSwiperDirection.bottom:
        return true;
      case CardSwiperDirection.none:
        return false;
    }
    
    if (currentIndex != null && currentIndex >= _profiles.length - 2) {
      _loadProfiles();
    }
    
    return true;
  }

  Future<void> _sendLike(MatchProfile profile) async {
    try {
      final success = await MatchingService.sendHeart(profile.id, widget.isMemberView);
      if (success && mounted) {
        ToastHelper.success(context, '${profile.name}에게 좋아요를 보냈습니다 ❤️');
      } else if (mounted) {
        ToastHelper.error(context, '좋아요 전송에 실패했습니다');
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.error(context, '좋아요 전송 중 오류가 발생했습니다');
      }
    }
  }

  Future<void> _passProfile(MatchProfile profile) async {
    try {
      await MatchingService.recordPassAction(profile.id, widget.isMemberView);
    } catch (e) {
      // Silent fail for pass action
    }
  }

  Future<void> _addToFavorites(MatchProfile profile) async {
    try {
      final success = await MatchingService.addToFavorites(profile.id, widget.isMemberView);
      if (success && mounted) {
        ToastHelper.success(context, '${profile.name}을(를) 즐겨찾기에 추가했습니다 ⭐');
      } else if (mounted) {
        ToastHelper.error(context, '즐겨찾기 추가에 실패했습니다');
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.error(context, '즐겨찾기 추가 중 오류가 발생했습니다');
      }
    }
  }

  void _showProfileDetail(MatchProfile profile) {
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
        Container(
          color: colorScheme.surface,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
                Expanded(
                  child: CardSwiper(
                    controller: _swiperController,
                    cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                      return Stack(
                        children: [
                          MatchCard(
                            profile: _profiles[index],
                            onTap: () => _showProfileDetail(_profiles[index]),
                          ),
                          _SwipeActionOverlay(
                            percentThresholdX: percentThresholdX.toDouble(),
                            percentThresholdY: percentThresholdY.toDouble(),
                          ),
                        ],
                      );
                    },
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MinimalActionButton(
                        icon: SolarIconsOutline.closeCircle,
                        buttonType: ButtonType.cancel,
                        onTap: () {
                          _swiperController.swipe(CardSwiperDirection.left);
                        },
                      ),
                      const SizedBox(width: 56),
                      _MinimalActionButton(
                        icon: SolarIconsOutline.heart,
                        buttonType: ButtonType.heart,
                        onTap: () {
                          _swiperController.swipe(CardSwiperDirection.right);
                        },
                      ),
                      const SizedBox(width: 56),
                      _MinimalActionButton(
                        icon: SolarIconsOutline.bookmark,
                        buttonType: ButtonType.bookmark,
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

enum ButtonType { cancel, heart, bookmark }

class _MinimalActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ButtonType buttonType;

  const _MinimalActionButton({
    required this.icon,
    required this.onTap,
    required this.buttonType,
  });

  @override
  Widget build(BuildContext context) {
    const dimension = 56.0;
    const iconSize = 24.0;
    
    Color iconColor;
    
    switch (buttonType) {
      case ButtonType.cancel:
        iconColor = const Color(0xFFFF9999);
        break;
      case ButtonType.heart:
        iconColor = const Color(0xFFFFB3D9);
        break;
      case ButtonType.bookmark:
        iconColor = const Color(0xFFFFD966);
        break;
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}

class _SwipeActionOverlay extends StatelessWidget {
  final double percentThresholdX;
  final double percentThresholdY;

  const _SwipeActionOverlay({
    required this.percentThresholdX,
    required this.percentThresholdY,
  });

  @override
  Widget build(BuildContext context) {
    SwipeAction? activeAction;
    double intensity = 0.0;
    
    if (percentThresholdX.abs() > percentThresholdY.abs()) {
      if (percentThresholdX > 0.1) {
        activeAction = SwipeAction.like;
        intensity = (percentThresholdX - 0.1) / 0.4;
      } else if (percentThresholdX < -0.1) {
        activeAction = SwipeAction.pass;
        intensity = (percentThresholdX.abs() - 0.1) / 0.4;
      }
    } else {
      if (percentThresholdY < -0.1) {
        activeAction = SwipeAction.bookmark;
        intensity = (percentThresholdY.abs() - 0.1) / 0.4;
      }
    }
    
    intensity = intensity.clamp(0.0, 1.0);
    
    if (activeAction == null || intensity == 0.0) {
      return const SizedBox.shrink();
    }
    
    final action = activeAction;
    
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 150),
        tween: Tween(begin: 0.0, end: intensity),
        builder: (context, animatedIntensity, child) {
          final scale = 0.6 + (animatedIntensity * 0.4);
          final opacity = (animatedIntensity * 0.8).clamp(0.0, 0.8);
          
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getActionColor(action).withValues(alpha: opacity * 0.15),
                border: Border.all(
                  color: _getActionColor(action).withValues(alpha: opacity * 0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getActionColor(action).withValues(alpha: opacity * 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _getActionIcon(action),
                size: 32 + (animatedIntensity * 12),
                color: _getActionColor(action).withValues(alpha: opacity * 0.9),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Color _getActionColor(SwipeAction action) {
    switch (action) {
      case SwipeAction.like:
        return const Color(0xFFFF6B9D);
      case SwipeAction.pass:
        return const Color(0xFFFF8A8A);
      case SwipeAction.bookmark:
        return const Color(0xFFFFD93D);
    }
  }
  
  IconData _getActionIcon(SwipeAction action) {
    switch (action) {
      case SwipeAction.like:
        return SolarIconsOutline.heart;
      case SwipeAction.pass:
        return SolarIconsOutline.closeCircle;
      case SwipeAction.bookmark:
        return SolarIconsOutline.star;
    }
  }
}

enum SwipeAction { like, pass, bookmark }

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
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
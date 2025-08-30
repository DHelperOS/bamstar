import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bamstar/theme/app_text_styles.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:bamstar/providers/user/role_providers.dart';
import 'package:bamstar/utils/toast_helper.dart';

// Import tab pages
import 'tabs/recommendation_tab.dart';
import 'tabs/search_tab.dart';
import 'tabs/map_tab.dart';
import 'tabs/hearts_tab.dart';
import 'tabs/favorites_tab.dart';

/// Main Matching Page with 5 tabs
/// Member sees Place profiles only
/// Place sees Member profiles only
class MatchingPage extends ConsumerStatefulWidget {
  const MatchingPage({super.key});

  @override
  ConsumerState<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends ConsumerState<MatchingPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  
  // Track unread counts for badges
  int _unreadHearts = 3; // Example: 3 new likes received
  int _favoritesCount = 12; // Example: 12 saved profiles

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadUnreadCounts();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  Future<void> _loadUnreadCounts() async {
    // TODO: Load actual counts from Supabase
    // This will be implemented with the backend integration
  }

  /// Determine user type for filtering
  bool get isUserMember {
    final roleId = ref.watch(currentUserRoleIdProvider);
    // Role IDs: 2=STAR, 6=MEMBER are considered members
    return roleId == 2 || roleId == 6;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          '매칭',
          style: AppTextStyles.appBarTitle(context),
        ),
        actions: [
          // 매칭 가중치 설정 버튼
          IconButton(
            icon: Icon(
              SolarIconsOutline.tuning,
              color: colorScheme.onSurface,
            ),
            onPressed: () {
              // TODO: Navigate to matching weight settings
              ToastHelper.info(context, '매칭 가중치 설정');
            },
          ),
          // 알림 버튼
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  SolarIconsOutline.bell,
                  color: colorScheme.onSurface,
                ),
                onPressed: () {
                  // TODO: Navigate to notifications
                  ToastHelper.info(context, '알림');
                },
              ),
              // 알림 배지 (새 알림이 있을 때 보임)
              if (_unreadHearts > 0 || _favoritesCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorScheme.primaryContainer,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                labelStyle: AppTextStyles.primaryText(context).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: AppTextStyles.primaryText(context).copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                Tab(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _currentIndex == 0 
                          ? SolarIconsBold.stars 
                          : SolarIconsOutline.stars,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      const Text('추천'),
                    ],
                  ),
                ),
                Tab(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _currentIndex == 1 
                          ? SolarIconsBold.magnifier 
                          : SolarIconsOutline.magnifier,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      const Text('탐색'),
                    ],
                  ),
                ),
                Tab(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _currentIndex == 2 
                          ? SolarIconsBold.mapPoint 
                          : SolarIconsOutline.mapPoint,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      const Text('지도'),
                    ],
                  ),
                ),
                Tab(
                  height: 40,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _currentIndex == 3 
                          ? SolarIconsBold.heart 
                          : SolarIconsOutline.heart,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      const Text('하트'),
                    ],
                  ),
                ),
                Tab(
                  height: 40,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _currentIndex == 4 
                          ? SolarIconsBold.bookmark 
                          : SolarIconsOutline.bookmark,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      const Text('즐겨찾기'),
                    ],
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe to allow card swiping
        children: [
          RecommendationTab(isMemberView: isUserMember),
          SearchTab(isMemberView: isUserMember),
          MapTab(isMemberView: isUserMember),
          HeartsTab(
            isMemberView: isUserMember,
            onUnreadCountChanged: (count) {
              setState(() {
                _unreadHearts = count;
              });
            },
          ),
          FavoritesTab(
            isMemberView: isUserMember,
            onFavoritesCountChanged: (count) {
              setState(() {
                _favoritesCount = count;
              });
            },
          ),
        ],
      ),
    );
  }
}
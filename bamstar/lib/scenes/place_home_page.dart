import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bamstar/theme/app_text_styles.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:badges/badges.dart' as badges;
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:bamstar/theme/typography.dart';
import 'package:bamstar/services/user_service.dart';
import 'package:bamstar/scenes/user_settings_page.dart';
import 'package:bamstar/scenes/place_settings_page.dart';
import 'package:bamstar/scenes/community/community_home_page.dart';
import 'package:bamstar/providers/user/role_providers.dart';
import '../utils/toast_helper.dart';
import 'package:bamstar/scenes/matching/matching_page.dart';

// Main widget (UI only; no navigation routes)
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // Listen to UserService changes
    UserService.instance.addListener(_onUserChanged);
  }
  
  @override
  void dispose() {
    UserService.instance.removeListener(_onUserChanged);
    super.dispose();
  }
  
  void _onUserChanged() {
    // Rebuild when user data changes
    // Use addPostFrameCallback to avoid setState during build
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  Widget _getSettingsPage() {
    final user = UserService.instance.user;
    final roleId = user?.data['role_id'] as int?;
    
    // Debug logging
    print('[PlaceHomePage] Current user role_id: $roleId');
    print('[PlaceHomePage] User data: ${user?.data}');
    
    // Handle null case
    if (roleId == null) {
      print('[PlaceHomePage] role_id is null, defaulting to UserSettingsPage');
      return UserSettingsPage();
    }
    
    // Route based on role_id
    // DB: 1=GUEST, 2=STAR, 3=PLACE, 4=ADMIN, 6=MEMBER
    switch (roleId) {
      case 1: // GUEST -> UserSettingsPage
        print('[PlaceHomePage] Routing to UserSettingsPage for role_id: 1 (GUEST)');
        return UserSettingsPage();
      case 2: // STAR -> UserSettingsPage  
        print('[PlaceHomePage] Routing to UserSettingsPage for role_id: 2 (STAR)');
        return UserSettingsPage();
      case 3: // PLACE -> PlaceSettingsPage
        print('[PlaceHomePage] Routing to PlaceSettingsPage for role_id: 3');
        return PlaceSettingsPage();
      case 4: // ADMIN -> UserSettingsPage
        print('[PlaceHomePage] Routing to UserSettingsPage for role_id: 4 (ADMIN)');
        return UserSettingsPage();
      case 6: // MEMBER -> UserSettingsPage
        print('[PlaceHomePage] Routing to UserSettingsPage for role_id: 6 (MEMBER)');
        return UserSettingsPage();
      default: // Default to user settings
        print('[PlaceHomePage] Routing to UserSettingsPage for unknown role_id: $roleId');
        return UserSettingsPage();
    }
  }

  String _getSettingsText() {
    final roleId = ref.watch(currentUserRoleIdProvider);
    switch (roleId) {
      case 2: // STAR
        return '프로필';
      case 3: // PLACE
        return '나의 플레이스';
      default:
        return '설정';
    }
  }

  IconData _getSettingsIcon(bool isActive) {
    final roleId = ref.watch(currentUserRoleIdProvider);
    switch (roleId) {
      case 2: // STAR
        return isActive ? SolarIconsBold.user : SolarIconsOutline.user;
      case 3: // PLACE
        return isActive ? SolarIconsBold.shop : SolarIconsOutline.shop;
      default:
        return isActive ? SolarIconsBold.settings : SolarIconsOutline.settings;
    }
  }

  List<Widget> get _tabs => [
    HomeScreen(), // Place (Home)
    const MatchingPage(),
    // Community tab is embedded so the bottom bar persists
    CommunityHomePage(),
    _ChatTab(),
    _getSettingsPage(), // Settings - role-based routing (dynamically evaluated)
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.white,
      body: _tabs[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: SalomonBottomBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          selectedItemColor: cs.primary,
          unselectedItemColor: cs.onSurfaceVariant,
          items: [
            SalomonBottomBarItem(
              icon: Icon(SolarIconsOutline.home),
              activeIcon: Icon(SolarIconsBold.home),
              title: Text('플레이스'),
            ),
            SalomonBottomBarItem(
              icon: Icon(SolarIconsOutline.hearts),
              activeIcon: Icon(SolarIconsBold.hearts),
              title: Text('매칭'),
            ),
            SalomonBottomBarItem(
              icon: Icon(SolarIconsOutline.usersGroupTwoRounded),
              activeIcon: Icon(SolarIconsBold.usersGroupTwoRounded),
              title: Text('커뮤니티'),
            ),
            SalomonBottomBarItem(
              icon: Icon(SolarIconsOutline.chatRound),
              activeIcon: Icon(SolarIconsBold.chatRound),
              title: Text('채팅'),
            ),
            SalomonBottomBarItem(
              icon: Icon(_getSettingsIcon(false)),
              activeIcon: Icon(_getSettingsIcon(true)),
              title: Text(_getSettingsText()),
            ),
          ],
        ),
      ),
    );
  }
}

// Removed embedded Community tab; now uses GoRouter '/community'

class _ChatTab extends StatelessWidget {
  const _ChatTab();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text('채팅')),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Disabled demo seeding to avoid overwriting real user data during development.
        // await UserService.instance.seedDemoUser();
        await UserService.instance.loadCurrentUser();
        // simple loading state: hide skeleton after load
        setState(() => _isLoading = false);
      } catch (_) {
        // ignore errors (e.g., no auth session)
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text('플레이스', style: AppTextStyles.appBarTitle(context)),
        ),
        actions: [
          IconButton(
            icon: Icon(SolarIconsOutline.hearts, color: cs.onSurface),
            tooltip: '매칭',
            onPressed: () {
              ToastHelper.info(context, '매칭을 실행합니다.');
            },
          ),
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: -4, end: -6),
            badgeContent: const Text(
              '3',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: IconButton(
              icon: Icon(SolarIconsOutline.bell, color: cs.onSurface),
              tooltip: '알림',
              onPressed: () {
                ToastHelper.info(context, '알림을 확인합니다.');
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // remove top padding so banner is flush under AppBar
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Skeletonizer(
          enabled: _isLoading,
          // animate the switch between skeleton and real content
          enableSwitchAnimation: true,
          switchAnimationConfig: SwitchAnimationConfig(
            duration: const Duration(milliseconds: 300),
          ),
          effect: ShimmerEffect(
            // use app primary color with subtle opacities so shimmer matches brand
            baseColor: (Theme.of(context).brightness == Brightness.dark
                ? cs.primary.withValues(alpha: 0.08)
                : cs.primary.withValues(alpha: 0.12)),
            highlightColor: (Theme.of(context).brightness == Brightness.dark
                ? cs.primary.withValues(alpha: 0.18)
                : cs.primary.withValues(alpha: 0.24)),
            duration: const Duration(milliseconds: 900),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner carousel inserted at the top of the home screen
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: _isLoading
                      ? _BannerSkeleton(height: 80)
                      : _FullWidthBannerCarousel(
                          banners: const [
                            'assets/images/banner/banner_01.png',
                            'assets/images/banner/banner_02.png',
                            'assets/images/banner/banner_03.png',
                            'assets/images/banner/banner_04.png',
                            'assets/images/banner/banner_05.png',
                          ],
                          height: 80,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: _SectionHeader(title: 'Continue Learning'),
              ),
              SizedBox(height: 12),
              _isLoading ? _ListSkeleton() : _ContinueLearningList(),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: _SectionHeader(title: 'Popular Mentors'),
              ),
              SizedBox(height: 12),
              _isLoading ? _ListSkeleton() : _PopularMentorsList(),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: _SectionHeader(title: 'Popular Course 🔥'),
              ),
              SizedBox(height: 12),
              _isLoading ? _ListSkeleton() : _PopularCourseList(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// A simple full-width banner carousel implemented with PageView.
class _FullWidthBannerCarousel extends StatefulWidget {
  final List<String> banners;
  final double height;

  const _FullWidthBannerCarousel({
    Key? key,
    required this.banners,
    required this.height,
  }) : super(key: key);

  @override
  State<_FullWidthBannerCarousel> createState() =>
      _FullWidthBannerCarouselState();
}

class _FullWidthBannerCarouselState extends State<_FullWidthBannerCarousel> {
  late final PageController _controller = PageController(viewportFraction: 1);
  int _currentPage = 0;
  Timer? _autoTimer;

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // start auto-scroll
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.banners.length,
              itemBuilder: (context, index) {
                final path = widget.banners[index];
                return Image.asset(
                  path,
                  width: double.infinity,
                  height: widget.height,
                  fit: BoxFit.fill,
                );
              },
            ),
            Positioned(
              right: 12,
              bottom: 8,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: widget.banners.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 2.0,
                    activeDotColor: cs.primary,
                    dotColor: Color.fromRGBO(255, 255, 255, 0.6),
                    paintStyle: PaintingStyle.fill,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple banner skeleton placeholder
class _BannerSkeleton extends StatelessWidget {
  final double height;
  const _BannerSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: height,
        color: cs.surfaceContainerHighest,
        child: Center(
          child: Icon(Icons.image, color: cs.onSurfaceVariant, size: 32),
        ),
      ),
    );
  }
}

// Simple list skeleton for horizontal lists
class _ListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return Container(
            width: 300,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: context.titleMedium),
        TextButton(
          onPressed: () {}, // UI only
          child: Text(
            'See All',
            style: context.bodyMedium.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContinueLearningList extends StatelessWidget {
  const _ContinueLearningList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = [
      {
        'image': 'https://picsum.photos/id/1043/100/80',
        'title': 'Web Development Bootcamp: Build and Deploy Your Own Website',
        'progress': 0.75,
        'completed': '75% completed',
      },
      {
        'image': 'https://picsum.photos/id/1047/100/80',
        'title': 'Mobile App UI/UX Design Fundamentals with Figma',
        'progress': 0.5,
        'completed': '50% completed',
      },
      {
        'image': 'https://picsum.photos/id/1048/100/80',
        'title': 'Introduction to Data Science with Python',
        'progress': 0.2,
        'completed': '20% completed',
      },
    ];
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final it = items[index];
          return Container(
            width: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Skeleton.replace(
                        width: 100,
                        height: 80,
                        child: Image.network(
                          it['image'] as String,
                          height: 80,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            it['title'] as String,
                            style: context.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: it['progress'] as double,
                            backgroundColor: cs.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(cs.primary),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            it['completed'] as String,
                            style: context.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PopularMentorsList extends StatelessWidget {
  const _PopularMentorsList();

  @override
  Widget build(BuildContext context) {
    final mentors = const [
      {'name': 'Destiny', 'image': 'https://picsum.photos/id/1027/200/200'},
      {'name': 'Kayley', 'image': 'https://picsum.photos/id/1025/200/200'},
      {'name': 'Kirstin', 'image': 'https://picsum.photos/id/1011/200/200'},
      {'name': 'Ramon', 'image': 'https://picsum.photos/id/1005/200/200'},
      {'name': 'Gustave', 'image': 'https://picsum.photos/id/1009/200/200'},
      {'name': 'Alice', 'image': 'https://picsum.photos/id/1004/200/200'},
    ];
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: mentors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final m = mentors[index];
          return Column(
            children: [
              ClipOval(
                child: Skeleton.replace(
                  width: 80,
                  height: 80,
                  child: Image.network(
                    m['image']!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                m['name']!,
                style: context.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PopularCourseList extends StatelessWidget {
  const _PopularCourseList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final courses = [
      {
        'category': 'Design',
        'title': 'Expert Wireframing for Mobile Design',
        'image': 'https://picsum.photos/id/600/200/150',
        'rating': 4.5,
        'reviews': 1239,
        'price': '\$499',
        'oldPrice': '\$699',
        'tag': 'New Course',
      },
      {
        'category': 'Language',
        'title': 'TOEFL Preparation Course: Boost Your E…',
        'image': 'https://picsum.photos/id/603/200/150',
        'rating': 4.2,
        'reviews': 886,
        'price': '\$399',
        'oldPrice': '\$499',
      },
      {
        'category': 'Programming',
        'title': 'Advanced React.js for Modern Web Apps',
        'image': 'https://picsum.photos/id/602/200/150',
        'rating': 4.8,
        'reviews': 1500,
        'price': '\$599',
        'oldPrice': '\$799',
        'tag': 'Best Seller',
      },
    ];

    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final c = courses[index];
          bool isFav = false;
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                width: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Skeleton.replace(
                              width: double.infinity,
                              height: 120,
                              child: Image.network(
                                c['image'] as String,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Material(
                                color: Colors.white.withValues(alpha: 0.85),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () => setState(() => isFav = !isFav),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      isFav
                                          ? SolarIconsBold.heart
                                          : SolarIconsOutline.heart,
                                      color: isFav ? Colors.red : Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (c['tag'] != null)
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    c['tag'] as String,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: cs.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['category'] as String,
                              style: textTheme.bodySmall?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c['title'] as String,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  SolarIconsBold.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${c['rating']} (${c['reviews']} reviews)',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  c['price'] as String,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cs.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (c['oldPrice'] != null)
                                  Text(
                                    c['oldPrice'] as String,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[500],
                                      decoration: TextDecoration.lineThrough,
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
            },
          );
        },
      ),
    );
  }
}

// Profile Screen (UI only)
// Removed custom profile UI. Profile tab now shows UserSettingsPage.

class NavbarWishlist extends StatefulWidget {
  const NavbarWishlist({super.key});

  @override
  State<NavbarWishlist> createState() => _NavbarWishlistState();
}

class _NavbarWishlistState extends State<NavbarWishlist> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex =
      1; // "Science" is selected by default as per image

  final List<Map<String, dynamic>> _categoryChipsWithIcons = [
    {'name': 'Programming', 'icon': Icons.laptop_mac}, // Placeholder icon
    {'name': 'Science', 'icon': Icons.public}, // Placeholder icon
    {'name': 'Design', 'icon': Icons.palette}, // Placeholder icon
    {'name': 'Business', 'icon': Icons.business_center}, // Placeholder icon
    {'name': 'Art', 'icon': Icons.brush}, // Placeholder icon
  ];

  // Modified wishlistCourses to include an isFavorited status for each item
  final List<Map<String, dynamic>> _wishlistCourses = [
    {
      'image': 'https://picsum.photos/id/600/100/80',
      'category': 'Graphic Design',
      'title': 'Expert Wireframing for Mobile Design',
      'rating': 4.9,
      'reviews': 12990,
      'author': 'Jerremy Mamika',
      'price': '\$48',
      'isFavorited': true, // All items start as favorited as per screenshot
    },
    {
      'image': 'https://picsum.photos/id/338/100/80',
      'category': 'Science',
      'title': 'The Complete Solar Energy Course',
      'rating': 4.9,
      'reviews': 12990,
      'author': 'Jerremy Mamika',
      'price': '\$125',
      'isFavorited': true,
    },
    {
      'image': 'https://picsum.photos/id/1015/100/80',
      'category': 'Coding',
      'title': 'How to convert design to React js Brssic',
      'rating': 4.9,
      'reviews': 12990,
      'author': 'Jerremy Mamika',
      'price': '\$34',
      'isFavorited': true,
    },

    {
      'image': 'https://picsum.photos/id/116/100/80',
      'category': 'Coding',
      'title': 'How to convert design to React js Brssic',
      'rating': 4.9,
      'reviews': 12990,
      'author': 'Jerremy Mamika',
      'price': '\$34',
      'isFavorited': true,
    },
    {
      'image': 'https://picsum.photos/id/1043/100/80',
      'category': 'Photography',
      'title': 'Mastering Street Photography',
      'rating': 4.8,
      'reviews': 9870,
      'author': 'Sarah Doe',
      'price': '\$75',
      'isFavorited': true,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {}, // no navigation
          iconSize: 20,
        ),
        title: const Text('My Wishlist'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Something',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Icon(
                        Icons.search,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          // Perform search clear logic
                        },
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white, // White background for the input
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                  ),
                  onChanged: (value) {
                    // Perform search as user types
                  },
                ),
                const SizedBox(height: 16),

                // Category Chips
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categoryChipsWithIcons.length,
                    itemBuilder: (context, index) {
                      final chipData = _categoryChipsWithIcons[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: _CategoryChipWithIcon(
                          name: chipData['name']!,
                          icon: chipData['icon']!,
                          isSelected: index == _selectedCategoryIndex,
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Wishlist Course List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              itemCount: _wishlistCourses.length,
              itemBuilder: (context, index) {
                final course = _wishlistCourses[index];
                return _buildWishlistCourseCard(
                  context,
                  course,
                  primaryColor,
                  textTheme,
                  index, // Pass index to uniquely identify the card
                );
              },
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 16), // Spacing between cards
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistCourseCard(
    BuildContext context,
    Map<String, dynamic> course,
    Color primaryColor,
    TextTheme textTheme,
    int index,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {},
        hoverColor: primaryColor.withValues(
          alpha: 0.05,
        ), // subtle hover on web/desktop
        splashColor: primaryColor.withValues(
          alpha: 0.2,
        ), // splash effect on tap
        child: Container(
          height: 120,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              // Left Image
              SizedBox(
                width: 120,
                height: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    bottomLeft: Radius.circular(16.0),
                  ),
                  child: Skeleton.replace(
                    width: 120,
                    height: 120,
                    child: Image.network(course['image']!, fit: BoxFit.cover),
                  ),
                ),
              ),
              // Right Text Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 8,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + Heart Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              course['category']!,
                              style: textTheme.bodySmall?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _wishlistCourses[index]['isFavorited'] =
                                    !_wishlistCourses[index]['isFavorited'];
                              });
                            },
                            child: Icon(
                              _wishlistCourses[index]['isFavorited']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _wishlistCourses[index]['isFavorited']
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      // Title
                      Text(
                        course['title']!,
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Rating and Reviews
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${course['rating']} • (${course['reviews']})',
                            style: textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      // Author and Price
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course['author']!,
                              style: textTheme.bodySmall?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            course['price']!,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ],
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
}

// Reusing and adapting the CategoryChip for icons
class _CategoryChipWithIcon extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChipWithIcon({
    required this.name,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    final ButtonStyle style = Theme.of(context).outlinedButtonTheme.style!
        .copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (isSelected) {
              return primaryColor;
            }
            return Colors.white; // White background for unselected
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (isSelected) {
              return Colors.white;
            }
            return Colors.black; // Black text for unselected
          }),
          side: WidgetStateProperty.resolveWith<BorderSide>((
            Set<WidgetState> states,
          ) {
            if (isSelected) {
              return BorderSide(color: primaryColor, width: 1.5);
            }
            return BorderSide(
              color: Colors.grey[300]!,
              width: 1.5,
            ); // Light grey border for unselected
          }),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          ),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          ),
        );

    return OutlinedButton(
      onPressed: onTap,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.black, size: 18),
          const SizedBox(width: 8),
          Text(
            name,
            style: textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class NavbarMyCourse extends StatefulWidget {
  const NavbarMyCourse({super.key});

  @override
  State<NavbarMyCourse> createState() => _NavbarMyCourseState();
}

class _NavbarMyCourseState extends State<NavbarMyCourse> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex =
      1; // "Science" is selected by default as per image

  final List<Map<String, dynamic>> _categoryChipsWithIcons = [
    {'name': 'Programming', 'icon': Icons.laptop_mac}, // Placeholder icon
    {'name': 'Science', 'icon': Icons.public}, // Placeholder icon
    {'name': 'Design', 'icon': Icons.palette}, // Placeholder icon
    {'name': 'Business', 'icon': Icons.business_center}, // Placeholder icon
    {'name': 'Art', 'icon': Icons.brush}, // Placeholder icon
  ];

  final List<Map<String, dynamic>> _myCourses = [
    {
      'image': 'https://picsum.photos/id/1045/100/80',
      'title': 'Complete 3D Animation Using Blender',
      'author': 'Jane Cooper',
      'members': 420,
      'num_courses': 43,
      'status': 'not_started', // or 'completed', 'in_progress'
      'progress': 0.0,
    },
    {
      'image': 'https://picsum.photos/id/237/100/80',
      'title': 'Fitness Training : Basic Workouts & Body Building',
      'author': 'Esther Howard',
      'members': 100,
      'num_courses': 16,
      'status': 'completed',
      'progress': 1.0, // 100%
    },
    {
      'image': 'https://picsum.photos/id/1014/100/80',
      'title': 'Advance Trading : Forex Trading/Stock Trading',
      'author': 'Courtney Henry',
      'members': 221,
      'num_courses': 12,
      'status': 'in_progress',
      'progress': 0.52, // 52%
    },
    {
      'image': 'https://picsum.photos/id/100/100/80',
      'title': 'Introduction to Digital Photography',
      'author': 'Emily White',
      'members': 350,
      'num_courses': 25,
      'status': 'in_progress',
      'progress': 0.70, // 70%
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () {}, // no navigation
        ),
        title: const Text('My Course'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Something',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Icon(Icons.search, color: Colors.grey[600]),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                        onPressed: () {
                          _searchController.clear();
                          // Perform search clear logic
                        },
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white, // White background for the input
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                  ),
                  onChanged: (value) {
                    // Perform search as user types
                  },
                ),
                const SizedBox(height: 16),

                // Category Chips
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categoryChipsWithIcons.length,
                    itemBuilder: (context, index) {
                      final chipData = _categoryChipsWithIcons[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: _CategoryChipWithIcon(
                          name: chipData['name']!,
                          icon: chipData['icon']!,
                          isSelected: index == _selectedCategoryIndex,
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // My Course List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              itemCount: _myCourses.length,
              itemBuilder: (context, index) {
                final course = _myCourses[index];
                return _buildMyCourseCard(
                  context,
                  course,
                  primaryColor,
                  textTheme,
                );
              },
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 16), // Spacing between cards
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyCourseCard(
    BuildContext context,
    Map<String, dynamic> course,
    Color primaryColor,
    TextTheme textTheme,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              width: 0.5,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16.0),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          course['image']!,
                          height: 64,
                          width: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course['title']!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              course['author']!,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.people_alt,
                                  color: Colors.grey[600],
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                // Wrap with Flexible or Expanded to prevent overflow
                                Flexible(
                                  child: Text(
                                    '${course['members']} Members',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.grey[600],
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                // Wrap with Flexible or Expanded to prevent overflow
                                Flexible(
                                  child: Text(
                                    '${course['num_courses']} Courses',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (course['status'] == 'not_started')
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {
                                    // Handle start course button tap
                                    debugPrint(
                                      'Start course tapped: ${course['title']}',
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Start Course',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            else if (course['status'] == 'completed')
                              Row(
                                children: [
                                  Text(
                                    'Complete',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Explicitly constrain width if overflow still occurs, or ensure enough space
                                  Text(
                                    '${(course['progress'] * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    // Removed softWrap: false and overflow: TextOverflow.visible, let Expanded handle it
                                  ),
                                ],
                              ),
                            if (course['status'] == 'in_progress')
                              Row(
                                children: [
                                  Text(
                                    'Course is in progress',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${(course['progress'] * 100).toInt()}%',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                    // Removed softWrap: false and overflow: TextOverflow.visible
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Progress Indicator (replacing the slider)
                  if (course['status'] == 'in_progress' ||
                      course['status'] == 'completed')
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: LinearProgressIndicator(
                        value: course['progress'],
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        minHeight: 6.0,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

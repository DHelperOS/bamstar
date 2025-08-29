import 'package:flutter/material.dart';
import 'package:bamstar/theme/app_text_styles.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
// Typography import removed as it's not used in current implementation
import 'package:bamstar/scenes/member_profile/basic_info_sheet_flow.dart';
import 'package:bamstar/scenes/region_preference_sheet.dart';
import 'package:bamstar/services/user_service.dart';
import 'package:bamstar/scenes/member_profile/edit_profile_modal.dart';
import 'package:bamstar/scenes/device_settings_page.dart';
import 'package:bamstar/scenes/member_profile/matching_preferences_page.dart';
import 'package:bamstar/scenes/member_profile/services/basic_info_service.dart';
import 'package:bamstar/scenes/member_profile/services/member_preferences_service.dart';
import 'package:bamstar/scenes/member_profile/services/region_preference_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'member_profile/services/basic_info_service.dart';
import 'member_profile/services/member_preferences_service.dart';
import 'member_profile/services/region_preference_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/toast_helper.dart';
import '../providers/user/role_providers.dart';

// Enhanced user settings page with modern card design and tab navigation
// - Clean white background with card-based layout
// - Tab navigation: 프로필, 지원 현황, 내가 쓴글, 차단 목록
// - Responsive design for mobile and web
// - Maintains all existing functionality
class UserSettingsPage extends ConsumerStatefulWidget {
  const UserSettingsPage({super.key});

  @override
  ConsumerState<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends ConsumerState<UserSettingsPage>
    with SingleTickerProviderStateMixin {
  ImageProvider? _profileImage;
  late TabController _tabController;

  // Profile completion status
  bool _isBasicInfoComplete = false;
  bool _isMatchingComplete = false;
  bool _isRegionComplete = false;
  bool _hasBasicInfoData = false;
  bool _hasMatchingData = false;
  bool _hasRegionData = false;
  bool _isAdultVerified = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProfileImage();
    _loadProfileCompletionStatus();
    UserService.instance.addListener(_onUserChanged);
    UserService.instance.loadCurrentUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    UserService.instance.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() {
    if (!mounted) return;
    setState(() {});
    _loadProfileImage();
    _loadProfileCompletionStatus();
  }

  Future<void> _loadProfileImage() async {
    final img = await UserService.instance.getProfileImageProvider();
    if (!mounted) return;
    setState(() => _profileImage = img);
  }

  Future<void> _loadProfileCompletionStatus() async {
    if (!mounted) return;

    try {
      // Use role provider to check adult verification status
      final isAdult = ref.read(currentUserIsAdultProvider);
      
      // Check basic info completion
      final basicInfo = await BasicInfoService.instance.loadBasicInfo();
      bool basicComplete = false;
      bool hasBasicData = basicInfo != null;

      if (basicInfo != null) {
        // Check if essential basic info fields are filled
        basicComplete =
            (basicInfo.realName?.isNotEmpty ?? false) &&
            basicInfo.age != null &&
            (basicInfo.gender?.isNotEmpty ?? false) &&
            (basicInfo.contactPhone?.isNotEmpty ?? false);
      }

      // Check matching preferences completion
      final matchingData = await MemberPreferencesService.instance
          .loadMatchingPreferences();
      bool matchingComplete = false;
      bool hasMatchingData = matchingData != null;

      if (matchingData != null) {
        // Check if essential matching fields are filled
        matchingComplete =
            matchingData.selectedIndustryIds.isNotEmpty ||
            matchingData.selectedJobIds.isNotEmpty ||
            matchingData.selectedStyleIds.isNotEmpty;
      }

      // Check region preferences completion
      final regionData = await RegionPreferenceService.instance
          .loadPreferredAreaGroups();
      bool regionComplete = regionData.isNotEmpty;
      bool hasRegionData = regionData.isNotEmpty;

      if (!mounted) return;
      setState(() {
        _isBasicInfoComplete = basicComplete;
        _isMatchingComplete = matchingComplete;
        _isRegionComplete = regionComplete;
        _hasBasicInfoData = hasBasicData;
        _hasMatchingData = hasMatchingData;
        _hasRegionData = hasRegionData;
        _isAdultVerified = isAdult;
      });
    } catch (e) {
      debugPrint('Error loading profile completion status: $e');
      if (!mounted) return;
      setState(() {
        _isBasicInfoComplete = false;
        _isMatchingComplete = false;
        _isRegionComplete = false;
        _hasBasicInfoData = false;
        _hasMatchingData = false;
        _hasRegionData = false;
        _isAdultVerified = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Removed unused colorScheme variable
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final maxWidth = isTablet ? 800.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Clean white background
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: Text(
          '프로필',
          style: TextStyle(
            color: const Color(0xFF1C252E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: Icon(
              SolarIconsBold.power,
              color: Theme.of(context).colorScheme.error,
            ),
            tooltip: '로그아웃',
          ),
          const SizedBox(width: 4), // Add spacing between buttons
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DeviceSettingsPage()),
            ),
            icon: Icon(
              SolarIconsOutline.settings,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: '설정',
          ),
          const SizedBox(width: 8), // Add margin from right edge
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            children: [
              // Combined Profile Header and Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Profile section
                    _buildProfileHeader(context),
                    // Divider line (subtle)
                    Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    // Tab bar section
                    _buildTabBar(context),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(context),
                    _buildSupportStatusTab(context),
                    _buildMyPostsTab(context),
                    _buildBlockedListTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Profile Avatar with subtle styling
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: _profileImage,
                    child: _profileImage == null
                        ? Icon(
                            SolarIconsBold.userCircle,
                            size: 44,
                            color: const Color(0xFFDDE2E8),
                          )
                        : null,
                  ),
                ),
              ),
              // Status indicator
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10B981),
                    border: Border.all(
                      color: const Color(0xFFF8F9FA),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Role tag with better styling
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getRoleIcon(),
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getRoleName(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Adult verification badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _isAdultVerified 
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                            : Theme.of(context).colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isAdultVerified
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                              : Theme.of(context).colorScheme.error.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isAdultVerified 
                                ? SolarIconsBold.checkCircle
                                : SolarIconsBold.closeCircle,
                            size: 12,
                            color: _isAdultVerified
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '성인 인증',
                            style: TextStyle(
                              color: _isAdultVerified
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Name
                Text(
                  UserService.instance.displayName,
                  style: const TextStyle(
                    color: Color(0xFF1C252E),
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                // Email with better styling
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        SolarIconsOutline.letter,
                        size: 13,
                        color: const Color(0xFF637381),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          UserService.instance.user?.email ?? '이메일 없음',
                          style: const TextStyle(
                            color: Color(0xFF637381),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Edit button with better integration
          Container(
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => showEditProfileModal(
                  context,
                  _profileImage,
                  onImagePicked: (img) {
                    if (!mounted) return;
                    setState(() => _profileImage = img);
                  },
                ),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    SolarIconsBold.pen,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: const Color(0xFF919EAB),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(SolarIconsBold.user, size: 16),
                SizedBox(width: 4),
                Text('프로필'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(SolarIconsBold.documentText, size: 16),
                SizedBox(width: 4),
                Text('지원'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(SolarIconsBold.penNewSquare, size: 16),
                SizedBox(width: 4),
                Text('내글'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(SolarIconsBold.userBlock, size: 16),
                SizedBox(width: 4),
                Text('차단'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    return SingleChildScrollView(
      primary: true,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('내 정보', style: AppTextStyles.sectionTitle(context)),
          const SizedBox(height: 16),

          // 기본 정보 카드
          _buildTooltipWrapper(
            tooltipMessage: _getTooltipMessage(
              '프로필',
              _isBasicInfoComplete,
              _hasBasicInfoData,
            ),
            showTooltip: !_isBasicInfoComplete,
            child: _buildInfoCard(
              context,
              icon: SolarIconsOutline.user,
              title: '프로필 시작하기',
              subtitle: '플레이스와 연결을 위해 꼭 필요한 정보예요.',
              trailing: _buildStatusIcon(
                _isBasicInfoComplete,
                _hasBasicInfoData,
              ),
              onTap: () => Navigator.of(
                context,
                rootNavigator: true,
              ).push(basicInfoSheetRoute()),
            ),
          ),

          const SizedBox(height: 12),

          // 상세 정보 카드
          _buildTooltipWrapper(
            tooltipMessage: _getTooltipMessage(
              '매칭 조건 설정',
              _isMatchingComplete,
              _hasMatchingData,
            ),
            showTooltip: !_isMatchingComplete,
            child: _buildInfoCard(
              context,
              icon: SolarIconsOutline.menuDots,
              title: '매칭 조건 설정하기',
              subtitle: '자세히 설정할수록, 빨리 매칭될 수 있어요.',
              trailing: _buildStatusIcon(_isMatchingComplete, _hasMatchingData),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MatchingPreferencesPage(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 선호 지역 카드
          _buildTooltipWrapper(
            tooltipMessage: _getTooltipMessage(
              '선호 지역 설정',
              _isRegionComplete,
              _hasRegionData,
            ),
            showTooltip: !_isRegionComplete,
            child: _buildInfoCard(
              context,
              icon: SolarIconsOutline.mapPoint,
              title: '어디에서 빛나고 싶으신가요?',
              subtitle: '선호 지역을 중심으로 추천해 드려요.',
              trailing: _buildStatusIcon(_isRegionComplete, _hasRegionData),
              onTap: () async {
                final res = await Navigator.of(
                  context,
                  rootNavigator: true,
                ).push(preferredRegionSheetRoute());
                if (!context.mounted) return;
                if (res is List) {
                  ToastHelper.success(context, '선호 지역이 업데이트되었습니다.');
                  _loadProfileCompletionStatus(); // Refresh status after update
                }
              },
            ),
          ),

          const SizedBox(height: 12),

          // 성인 인증 카드
          _buildTooltipWrapper(
            tooltipMessage: _isAdultVerified
                ? '성인 인증이 완료되었습니다'
                : '아직 성인 인증이 완료되지 않았어요',
            showTooltip: !_isAdultVerified,
            child: _buildInfoCard(
              context,
              icon: SolarIconsOutline.shield,
              title: '성인 인증하기',
              subtitle: '앱을 이용하려면 성인 인증이 필요해요.',
              trailing: _buildStatusIcon(_isAdultVerified, _isAdultVerified),
              onTap: () => _handleAdultVerification(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportStatusTab(BuildContext context) {
    return SingleChildScrollView(
      primary: true,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('지원 현황', style: AppTextStyles.sectionTitle(context)),
          const SizedBox(height: 16),

          _buildInfoCard(
            context,
            icon: SolarIconsOutline.documentText,
            title: '지원한 공고',
            subtitle: '총 0개의 공고에 지원하였습니다',
            trailing: const Icon(
              SolarIconsOutline.arrowRight,
              color: Color(0xFF919EAB),
            ),
            onTap: () => _showToast(context, '지원한 공고'),
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            context,
            icon: SolarIconsOutline.eye,
            title: '조회한 공고',
            subtitle: '최근 조회한 공고를 확인하세요',
            trailing: const Icon(
              SolarIconsOutline.arrowRight,
              color: Color(0xFF919EAB),
            ),
            onTap: () => _showToast(context, '조회한 공고'),
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            context,
            icon: SolarIconsOutline.heart,
            title: '관심 공고',
            subtitle: '관심있는 공고를 저장하고 관리하세요',
            trailing: const Icon(
              SolarIconsOutline.arrowRight,
              color: Color(0xFF919EAB),
            ),
            onTap: () => _showToast(context, '관심 공고'),
          ),
        ],
      ),
    );
  }

  Widget _buildMyPostsTab(BuildContext context) {
    return SingleChildScrollView(
      primary: true,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('내가 쓴 글', style: AppTextStyles.sectionTitle(context)),
          const SizedBox(height: 16),

          _buildInfoCard(
            context,
            icon: SolarIconsOutline.documentText,
            title: '작성한 게시글',
            subtitle: '커뮤니티에 작성한 게시글을 확인하세요',
            trailing: const Icon(
              SolarIconsOutline.arrowRight,
              color: Color(0xFF919EAB),
            ),
            onTap: () => _showToast(context, '작성한 게시글'),
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            context,
            icon: SolarIconsOutline.chatRoundDots,
            title: '작성한 댓글',
            subtitle: '다른 게시글에 작성한 댓글을 확인하세요',
            trailing: const Icon(
              SolarIconsOutline.arrowRight,
              color: Color(0xFF919EAB),
            ),
            onTap: () => _showToast(context, '작성한 댓글'),
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            context,
            icon: SolarIconsOutline.heart,
            title: '좋아요한 게시글',
            subtitle: '좋아요를 누른 게시글을 확인하세요',
            trailing: const Icon(
              SolarIconsOutline.arrowRight,
              color: Color(0xFF919EAB),
            ),
            onTap: () => _showToast(context, '좋아요한 게시글'),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedListTab(BuildContext context) {
    return SingleChildScrollView(
      primary: true,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('차단 목록', style: AppTextStyles.sectionTitle(context)),
          const SizedBox(height: 16),

          _buildInfoCard(
            context,
            icon: SolarIconsOutline.forbiddenCircle,
            title: '차단한 사용자',
            subtitle: '차단한 사용자 목록을 관리하세요',
            trailing: const Icon(
              SolarIconsOutline.arrowRight,
              color: Color(0xFF919EAB),
            ),
            onTap: () => _showToast(context, '차단한 사용자'),
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            context,
            icon: SolarIconsOutline.shieldMinus,
            title: '신고한 게시글',
            subtitle: '신고한 게시글의 처리 현황을 확인하세요',
            trailing: const Icon(
              SolarIconsOutline.arrowRight,
              color: Color(0xFF919EAB),
            ),
            onTap: () => _showToast(context, '신고한 게시글'),
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            context,
            icon: SolarIconsOutline.settings,
            title: '프라이버시 설정',
            subtitle: '계정 보안 및 프라이버시 설정을 관리하세요',
            trailing: const Icon(
              SolarIconsOutline.arrowRight,
              color: Color(0xFF919EAB),
            ),
            onTap: () => _showToast(context, '프라이버시 설정'),
          ),
        ],
      ),
    );
  }

  // Helper methods for role display using Riverpod providers
  String _getRoleName() {
    // Use the Korean name from the roles table
    final roleKorName = ref.watch(currentUserRoleKorNameProvider);
    return roleKorName;
  }

  IconData _getRoleIcon() {
    final roleId = ref.watch(currentUserRoleIdProvider);
    switch (roleId) {
      case 1:
        return SolarIconsBold.shield;
      case 2:
        return SolarIconsBold.crown;
      case 3:
        return SolarIconsBold.userHands;
      default:
        return SolarIconsBold.userHands;
    }
  }

  Color _getRoleColor(BuildContext context) {
    final roleId = ref.watch(currentUserRoleIdProvider);
    switch (roleId) {
      case 1:
        return const Color(0xFFDC2626); // Admin - Red
      case 2:
        return Theme.of(context).colorScheme.primary; // Product Owner - Primary
      case 3:
        return Theme.of(context).colorScheme.secondary; // Member - Secondary
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0x0F919EAB), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: const Color(0xFF637381)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF1C252E),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF919EAB),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(bool isComplete, bool hasData) {
    if (isComplete) {
      return const Icon(
        SolarIconsBold.checkCircle,
        color: Color(0xFF22C55E), // Green color for complete
        size: 20,
      );
    } else if (hasData) {
      return const Icon(
        SolarIconsOutline.dangerTriangle,
        color: Color(0xFFF59E0B), // Yellow/amber color for in progress
        size: 20,
      );
    } else {
      return const Icon(
        SolarIconsOutline.dangerTriangle,
        color: Color(0xFFEF4444), // Red color for not started
        size: 20,
      );
    }
  }

  String _getTooltipMessage(String section, bool isComplete, bool hasData) {
    if (isComplete) {
      return '$section이 완료되었습니다';
    } else if (hasData) {
      return '아직 $section이 완료되지 않았어요';
    } else {
      return '아직 $section이 완료되지 않았어요';
    }
  }

  Widget _buildTooltipWrapper({
    required Widget child,
    required String tooltipMessage,
    required bool showTooltip,
  }) {
    if (!showTooltip) {
      return child;
    }

    return JustTheTooltip(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          tooltipMessage,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      backgroundColor: const Color(0xFF1F2937),
      borderRadius: BorderRadius.circular(8),
      preferredDirection: AxisDirection.up,
      tailLength: 8,
      tailBaseWidth: 16,
      showDuration: const Duration(seconds: 5),
      waitDuration: const Duration(milliseconds: 500),
      child: child,
    );
  }

  void _showToast(BuildContext context, String message) {
    ToastHelper.info(context, message);
  }

  Future<void> _handleAdultVerification(BuildContext context) async {
    if (_isAdultVerified) {
      _showToast(context, '이미 성인 인증이 완료되었습니다');
      return;
    }

    // TODO: Implement actual adult verification flow
    _showToast(context, '성인 인증 기능을 준비 중입니다');
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      SolarIconsBold.power,
                      color: colorScheme.error,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    '로그아웃',
                    style: AppTextStyles.sectionTitle(context).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Content
                  Text(
                    '정말 로그아웃하시겠습니까?\n다시 로그인해야 서비스를 이용할 수 있어요',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.secondaryText(context).copyWith(
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Buttons
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.onSurface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              '취소',
                              style: AppTextStyles.buttonText(context).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Confirm button
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.error.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.onError,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              '로그아웃',
                              style: AppTextStyles.buttonText(context).copyWith(
                                color: colorScheme.onError,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;

    try {
      // Sign out from Supabase - this will trigger the auth state listener
      // in UserService which will automatically clear the user data
      await Supabase.instance.client.auth.signOut();

      if (!context.mounted) return;

      // Show success message
      ToastHelper.success(context, '로그아웃되었습니다');

      // Navigate to login page using GoRouter
      context.go('/login');
    } catch (error) {
      debugPrint('Logout error: $error');

      if (!context.mounted) return;

      // Show error message
      ToastHelper.error(context, '로그아웃 중 오류가 발생했습니다');
    }
  }
}

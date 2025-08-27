import 'package:flutter/material.dart';
import 'package:bamstar/theme/app_text_styles.dart';
import 'package:solar_icons/solar_icons.dart';
// Typography import removed as it's not used in current implementation
import 'package:bamstar/scenes/edit_info_page.dart';
import 'package:bamstar/scenes/basic_info_sheet_flow.dart';
import 'package:bamstar/scenes/region_preference_sheet.dart';
import 'package:bamstar/services/user_service.dart';
import 'package:bamstar/scenes/edit_profile_modal.dart';
import 'package:bamstar/scenes/device_settings_page.dart';
import 'package:bamstar/scenes/matching_preferences_page.dart';

// Enhanced user settings page with modern card design and tab navigation
// - Clean white background with card-based layout
// - Tab navigation: 프로필, 지원 현황, 내가 쓴글, 차단 목록
// - Responsive design for mobile and web
// - Maintains all existing functionality
class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage>
    with SingleTickerProviderStateMixin {
  ImageProvider? _profileImage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProfileImage();
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
  }

  Future<void> _loadProfileImage() async {
    final img = await UserService.instance.getProfileImageProvider();
    if (!mounted) return;
    setState(() => _profileImage = img);
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
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DeviceSettingsPage()),
            ),
            icon: Icon(
              SolarIconsOutline.settings,
              color: const Color(0xFF1C252E),
            ),
            tooltip: '설정',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            children: [
              // Enhanced Profile Header Card
              _buildProfileHeader(context),

              // Tab Bar
              _buildTabBar(context),

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
      margin: const EdgeInsets.all(20.0),
      // Slightly reduced padding so text lines sit closer together vertically
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0x0F919EAB), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Avatar (reduced to ~80%)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x26919EAB), width: 2),
                ),
                child: CircleAvatar(
                  radius: 32, // reduced from 40 -> ~80%
                  backgroundColor: const Color(0xFFF4F6F8),
                  backgroundImage: _profileImage,
                ),
              ),
              const SizedBox(width: 16),

              // Profile Info with edit icon placed to the right of the name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Display name with pen icon immediately to its right
                        Flexible(
                          fit: FlexFit.loose,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  UserService.instance.displayName,
                                  style: const TextStyle(
                                    color: Color(0xFF1C252E),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 2),
                              IconButton(
                                onPressed: () => showEditProfileModal(
                                  context,
                                  _profileImage,
                                  onImagePicked: (img) {
                                    if (!mounted) return;
                                    setState(() => _profileImage = img);
                                  },
                                ),
                                icon: Icon(
                                  SolarIconsOutline.pen,
                                  size: 18,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                                tooltip: '프로필 편집',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Reduce vertical gap between name and email to bring them closer
                    const SizedBox(height: 4),
                    Text(
                      UserService.instance.user?.email ?? '이메일 없음',
                      style: const TextStyle(
                        color: Color(0xFF919EAB),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x0F919EAB), width: 1),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: const Color(0xFFFFFFFF),
        unselectedLabelColor: const Color(0xFF919EAB),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '프로필'),
          Tab(text: '지원 현황'),
          Tab(text: '내가 쓴글'),
          Tab(text: '차단 목록'),
        ],
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('내 정보', style: AppTextStyles.sectionTitle(context)),
          const SizedBox(height: 16),

          // 기본 정보 카드
          _buildInfoCard(
            context,
            icon: SolarIconsOutline.user,
            title: '프로필 시작하기',
            subtitle: '플레이스와 연결을 위해 꼭 필요한 정보예요.',
            trailing: const Icon(
              SolarIconsOutline.dangerTriangle,
              color: Colors.amber,
            ),
            onTap: () => Navigator.of(
              context,
              rootNavigator: true,
            ).push(basicInfoSheetRoute()),
          ),

          const SizedBox(height: 12),

          // 상세 정보 카드
          _buildInfoCard(
            context,
            icon: SolarIconsOutline.menuDots,
            title: '매칭 조건 설정하기',
            subtitle: '자세히 설정할수록, 빨리 매칭될 수 있어요.',
            trailing: Icon(
              SolarIconsOutline.dangerTriangle,
              color: Theme.of(context).colorScheme.error,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MatchingPreferencesPage(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 선호 지역 카드
          _buildInfoCard(
            context,
            icon: SolarIconsOutline.mapPoint,
            title: '어디에서 빛나고 싶으신가요?',
            subtitle: '선호 지역을 중심으로 추천해 드려요.',
            trailing: const Icon(
              SolarIconsOutline.arrowRight,
              color: Color(0xFF919EAB),
            ),
            onTap: () async {
              final res = await Navigator.of(
                context,
                rootNavigator: true,
              ).push(preferredRegionSheetRoute());
              if (!context.mounted) return;
              if (res is List) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('선호 지역이 업데이트되었습니다.')),
                );
              }
            },
          ),

          const SizedBox(height: 24),

          Text('기타', style: AppTextStyles.sectionTitle(context)),
          const SizedBox(height: 16),

          _buildInfoCard(
            context,
            icon: SolarIconsOutline.questionCircle,
            title: '자주 묻는 질문',
            trailing: const Icon(
              SolarIconsOutline.arrowRight,
              color: Color(0xFF919EAB),
            ),
            onTap: () => _showToast(context, '자주 묻는 질문'),
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            context,
            icon: SolarIconsOutline.chatRoundCall,
            title: '도움말 및 지원',
            trailing: const Icon(
              SolarIconsOutline.arrowRight,
              color: Color(0xFF919EAB),
            ),
            onTap: () => _showToast(context, '도움말 및 지원'),
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            context,
            icon: SolarIconsOutline.logout,
            title: '로그아웃',
            onTap: () => _showToast(context, '로그아웃'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportStatusTab(BuildContext context) {
    return SingleChildScrollView(
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

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

import 'package:flutter/material.dart';
import 'package:bamstar/theme/app_text_styles.dart';
import 'package:solar_icons/solar_icons.dart';
// modal implementation moved to separate file
import 'package:bamstar/theme/typography.dart';
import 'package:bamstar/scenes/edit_info_page.dart';
import 'package:bamstar/scenes/basic_info_sheet_flow.dart';
import 'package:bamstar/scenes/region_preference_sheet.dart';
import 'package:bamstar/services/user_service.dart';
import 'package:bamstar/scenes/edit_profile_modal.dart';
import 'package:bamstar/scenes/device_settings_page.dart';

// Settings page adapted from the reference profile_screen template
// - Uses Material 3
// - Uses solar_icons per project standard
// - No nested bottom navigation (MainScreen owns navigation)
class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  // moved device-specific settings to DeviceSettingsPage
  ImageProvider? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    UserService.instance.addListener(_onUserChanged);
    // Ensure we have the latest user row
    UserService.instance.loadCurrentUser();
  }

  @override
  void dispose() {
    UserService.instance.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() {
    // Refresh UI and profile image when the user row updates
    if (!mounted) return;
    setState(() {});
    _loadProfileImage();
  }

  // displayName logic moved to UserService (UserService.instance.displayName)

  Future<void> _loadProfileImage() async {
    final img = await UserService.instance.getProfileImageProvider();
    if (!mounted) return;
    setState(() => _profileImage = img);
  }

  // Local avatar selection delegated to UserService.pickRandomLocalAvatar

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white, // 유지: 사용자 요구(흰색 배경)
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white, // 유지: 사용자 요구
        title: Text('프로필', style: AppTextStyles.appBarTitle(context)),
        actions: [
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
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header with inline edit label
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _profileImage,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          UserService.instance.displayName,
                          style: context.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          UserService.instance.user?.email ?? '이메일 없음',
                          style: context.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => showEditProfileModal(
                      context,
                      _profileImage,
                      onImagePicked: (img) {
                        if (!mounted) return;
                        setState(() => _profileImage = img);
                      },
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      visualDensity: VisualDensity.compact,
                      minimumSize: const Size(0, 36),
                      shape: const StadiumBorder(),
                      side: BorderSide(color: cs.primary, width: 1),
                      foregroundColor: cs.primary,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, size: 16, color: cs.primary),
                        const SizedBox(width: 8),
                        Text(
                          '수정하기',
                          style: context.bodyMedium.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- 내 정보 섹션: 간단한 카드 2개 (기본 정보, 상세 정보)
              Text('내 정보', style: AppTextStyles.sectionTitle(context)),
              const SizedBox(height: 12),

              // 기본 정보 (심플 카드) - 필드 삭제 요청으로 항목 제거, 편집은 빈 필드로 이동
              Card(
                elevation: 1,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: cs.outline.withAlpha(28), width: 1),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).push(basicInfoSheetRoute()),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(SolarIconsOutline.settings, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('기본 정보', style: context.titleMedium),
                              const SizedBox(height: 6),
                              Text(
                                '나의 간단한 기본 정보를 넣어주세요.',
                                style: context.bodySmall.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          SolarIconsOutline.dangerTriangle,
                          size: 18,
                          color: Colors.amber.shade700,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 상세 정보 (매칭을 위한 보다 정확한 정보) - 필드 삭제 요청으로 항목 제거
              Card(
                elevation: 1,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: cs.outline.withAlpha(28), width: 1),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditInfoPage(title: '상세 정보', fields: {}),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(SolarIconsOutline.menuDots, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('상세 정보', style: context.titleMedium),
                              const SizedBox(height: 6),
                              Text(
                                'AI 매칭에 필요한 상세한 정보를 넣어주세요',
                                style: context.bodySmall.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          SolarIconsOutline.dangerTriangle,
                          size: 18,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 선호 지역: 상세 정보 카드와 동일한 디자인, 아이콘은 지도/지구 모양
              Card(
                elevation: 1,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: cs.outline.withAlpha(28), width: 1),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
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
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(SolarIconsOutline.map, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('선호 지역', style: context.titleMedium),
                              const SizedBox(height: 6),
                              Text(
                                '매칭에 반영할 선호 지역을 설정하세요',
                                style: context.bodySmall.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          SolarIconsOutline.arrowRight,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text('기타', style: AppTextStyles.sectionTitle(context)),
              const SizedBox(height: 16),
              _tile(
                context,
                icon: Icon(SolarIconsOutline.questionCircle),
                title: '자주 묻는 질문',
                trailing: Icon(SolarIconsOutline.arrowRight, size: 18),
                onTap: () => _toast(context, '자주 묻는 질문'),
              ),
              const SizedBox(height: 8),
              _tile(
                context,
                icon: Icon(SolarIconsOutline.chatRoundCall),
                title: '도움말 및 지원',
                trailing: Icon(SolarIconsOutline.arrowRight, size: 18),
                onTap: () => _toast(context, '도움말 및 지원'),
              ),
              const SizedBox(height: 8),
              _tile(
                context,
                icon: Icon(SolarIconsOutline.logout),
                title: '로그아웃',
                onTap: () => _toast(context, '로그아웃'),
              ),

              SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
              Center(
                child: Text('2021 SkillUp • 버전 1.0', style: context.bodySmall),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable tile aligned to Material 3 ListTile patterns
  Widget _tile(
    BuildContext context, {
    required Widget icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: IconTheme.merge(
              data: const IconThemeData(size: 20),
              child: icon,
            ),
          ),
        ),
        title: Text(
          title,
          style: context.lead.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        trailing: trailing,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // modal trailing helper moved to edit_profile_modal.dart
}

// ...infoRow removed per user request (fields deleted)

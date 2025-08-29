import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../providers/auth/auth_providers.dart';
import '../providers/user/role_providers.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:solar_icons/solar_icons.dart';
// auth_fields removed from this screen
import '../widgets/primary_text_button.dart';
import '../widgets/social_auth_button.dart';
import '../widgets/auth_fields.dart';
import '../theme/app_color_scheme_extension.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive_utils.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  late final AnimationController _logoController;
  late final Animation<double> _logoRotateAnim;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    final curved = CurvedAnimation(
      parent: _logoController,
      // gentle oscillation
      curve: Curves.easeInOutSine,
    );

    // small, cute rotation animation (radians)
    _logoRotateAnim = Tween<double>(begin: -0.12, end: 0.12).animate(curved);
    
    // Listen for focus changes to update UI
    _phoneFocusNode.addListener(() {
      setState(() {}); // Update UI when focus changes
    });
  }


  @override
  void dispose() {
    _logoController.dispose();
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _hideKeyboard() {
    // Multiple methods to ensure keyboard is hidden
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  /// Navigate after login based on role and terms agreement status
  Future<void> _navigateAfterLogin() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        context.go('/login');
        return;
      }

      // Check user role - invalidate provider first to get fresh data
      ref.invalidate(currentUserRoleProvider);
      
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('role_id')
          .eq('id', user.id)
          .single();

      final roleId = userResponse['role_id'] as int?;

      // If GUEST (role_id == 1), go to roles selection
      if (roleId == null || roleId == 1) {
        context.go('/roles');
        return;
      }

      // Role is set, check mandatory terms agreement
      final mandatoryTerms = await Supabase.instance.client
          .from('terms')
          .select('id')
          .eq('type', 'mandatory')
          .eq('is_active', true);

      if (mandatoryTerms.isEmpty) {
        // No mandatory terms, go to home
        context.go('/home');
        return;
      }

      // Check if user agreed to all mandatory terms
      final agreedTerms = await Supabase.instance.client
          .from('user_term_agreements')
          .select('term_id')
          .eq('user_id', user.id)
          .eq('is_agreed', true);

      final mandatoryTermIds = mandatoryTerms.map((term) => term['id']).toSet();
      final agreedTermIds = agreedTerms.map((agreement) => agreement['term_id']).toSet();

      final allMandatoryAgreed = mandatoryTermIds.every((termId) => agreedTermIds.contains(termId));

      if (allMandatoryAgreed) {
        // All mandatory terms agreed, go to home
        context.go('/home');
      } else {
        // Terms not agreed, go to terms page
        context.go('/terms');
      }
    } catch (e) {
      debugPrint('[DEBUG] Error in _navigateAfterLogin: $e');
      // Default to roles page on error
      context.go('/roles');
    }
  }


  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes: show errors and navigate on successful sign-in
    ref.listen<AsyncValue<AuthState>>(authProvider, (previous, next) {
      next.whenOrNull(
        error: (e, _) {
          final msg = e.toString();
          if (mounted) {
            DelightToastBar(
              builder: (ctx) => Material(
                color: Colors.transparent,
                child: _ToastContent(
                  title: '로그인 오류',
                  message: msg,
                  icon: Icon(
                    SolarIconsOutline.dangerTriangle,
                    color: Colors.white,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
              autoDismiss: true,
            ).show(context);
          }
        },
        data: (authState) {
          // If we transitioned from no-session -> session, navigate based on role and terms
          final prevSession = previous?.maybeWhen(
            data: (v) => v.session,
            orElse: () => null,
          );
          if (authState.session != null && prevSession == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _navigateAfterLogin();
            });
          }
        },
      );
    });
    final asyncAuth = ref.watch(authProvider);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          // Simple approach: only hide if not focused on text field
          final currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
            // Check if any text field has focus before hiding
            final focusedWidget = currentFocus.focusedChild;
            if (focusedWidget != null) {
              // Don't hide keyboard if a text field is focused
              return;
            }
          }
          _hideKeyboard();
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // Dismiss keyboard when tapping outside of text fields
            _hideKeyboard();
          },
          child: SafeArea(
            child: _buildResponsiveLayout(context, asyncAuth, theme, primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(
    BuildContext context,
    AsyncValue<AuthState> asyncAuth,
    ThemeData theme,
    Color primaryColor,
  ) {
    if (ResponsiveUtils.isDesktop(context)) {
      return _buildDesktopLayout(context, asyncAuth, theme, primaryColor);
    } else {
      return _buildMobileTabletLayout(context, asyncAuth, theme, primaryColor);
    }
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    AsyncValue<AuthState> asyncAuth,
    ThemeData theme,
    Color primaryColor,
  ) {
    return Stack(
      children: [
        _buildBackground(context),
        Row(
          children: [
            // Left side - Branding/illustration area
            Expanded(
              flex: ResponsiveUtils.isWideDesktop(context) ? 3 : 2,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _hideKeyboard(),
                child: Container(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Enhanced branding section for desktop
                    Text(
                      'BamStar',
                      style: AppTextStyles.pageTitle(context).copyWith(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '당신만의 특별한 순간을 만들어가세요.\n가장 빛나는 밤, 가장 빛나는 당신이 되어보세요.',
                      style: AppTextStyles.secondaryText(context).copyWith(
                        fontSize: 18,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Feature highlights for desktop
                    _buildFeatureList(context),
                    ],
                  ),
                ),
              ),
            ),
            // Right side - Login form
            Expanded(
              flex: ResponsiveUtils.isWideDesktop(context) ? 2 : 3,
              child: Container(
                padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
                child: Center(
                  child: _buildLoginCard(context, theme, primaryColor),
                ),
              ),
            ),
          ],
        ),
        if (asyncAuth.isLoading) _buildLoadingOverlay(context),
      ],
    );
  }

  Widget _buildMobileTabletLayout(
    BuildContext context,
    AsyncValue<AuthState> asyncAuth,
    ThemeData theme,
    Color primaryColor,
  ) {
    return Stack(
      children: [
        _buildBackground(context),
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _hideKeyboard(),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                left: ResponsiveUtils.getHorizontalPadding(context),
                right: ResponsiveUtils.getHorizontalPadding(context),
                top: ResponsiveUtils.isMobile(context) ? 32 : 48,
                bottom: MediaQuery.of(context).viewInsets.bottom + 
                        (ResponsiveUtils.isMobile(context) ? 32 : 48) +
                        (_phoneFocusNode.hasFocus ? 150 : 0), // Extra space when phone field focused
              ),
              child: _buildLoginCard(context, theme, primaryColor),
            ),
          ),
        ),
        if (asyncAuth.isLoading) _buildLoadingOverlay(context),
      ],
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Stack(
      children: [
        // Enhanced gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: ResponsiveUtils.isDesktop(context)
                  ? [
                      const Color(0xFFF6F7FB),
                      const Color(0xFFF0EEFF),
                      const Color(0xFFEEF2FF),
                    ]
                  : [const Color(0xFFF6F7FB), const Color(0xFFF0EEFF)],
            ),
          ),
        ),
        // Texture overlay
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.06,
              child: Transform.rotate(
                angle: -0.18,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFDCE7FF).withValues(alpha: 0.02),
                        Colors.transparent,
                        Color(0xFFF6F0FF).withValues(alpha: 0.02),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context, ThemeData theme, Color primaryColor) {
    final cardMaxWidth = ResponsiveUtils.getCardMaxWidth(context);
    final logoSize = ResponsiveUtils.getLogoSize(context);
    final verticalSpacing = ResponsiveUtils.getVerticalSpacing(context);
    
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: cardMaxWidth),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.isMobile(context) ? 24 : 32,
          vertical: ResponsiveUtils.isMobile(context) ? 32 : 48,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: ResponsiveUtils.isDesktop(context) ? 0.92 : 0.86,
          ),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.isMobile(context) ? 16 : 20,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: ResponsiveUtils.isDesktop(context) ? 0.06 : 0.04,
              ),
              blurRadius: ResponsiveUtils.isDesktop(context) ? 32 : 20,
              offset: Offset(0, ResponsiveUtils.isDesktop(context) ? 8 : 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildLogo(context, theme, logoSize),
            SizedBox(height: verticalSpacing),
            _buildTitleSection(context),
            SizedBox(height: verticalSpacing),
            _buildSocialButtons(context),
            SizedBox(height: verticalSpacing),
            _buildDivider(context),
            SizedBox(height: verticalSpacing * 0.75),
            _buildPhoneSection(context, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context, ThemeData theme, double size) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: ResponsiveUtils.isDesktop(context) ? 24.0 : 20.0,
          sigmaY: ResponsiveUtils.isDesktop(context) ? 24.0 : 20.0,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.04),
                const Color.fromARGB(255, 209, 163, 218).withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                final rotate = _logoRotateAnim.value;
                return Transform.rotate(
                  angle: rotate,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/icon/app_icon.png',
                width: size * 0.475,
                height: size * 0.475,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      children: [
        Text(
          '가장 빛나는 밤, 가장 빛나는 나.',
          textAlign: TextAlign.center,
          style: ResponsiveUtils.getResponsiveTextStyle(
            context,
            AppTextStyles.sectionTitle(context).copyWith(
              fontWeight: FontWeight.w800,
            ),
            tabletScale: 1.1,
            desktopScale: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '소셜 로그인으로 간편하게 시작하세요.',
          textAlign: TextAlign.center,
          style: ResponsiveUtils.getResponsiveTextStyle(
            context,
            AppTextStyles.secondaryText(context),
            tabletScale: 1.05,
            desktopScale: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons(BuildContext context) {
    final auth = ref.read(authProvider.notifier);
    final isTabletOrDesktop = !ResponsiveUtils.isMobile(context);
    
    if (isTabletOrDesktop && ResponsiveUtils.isDesktop(context)) {
      // Two-column layout for desktop
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SocialAuthButton.kakao(
                  onPressed: () => auth.signInWithKakao(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SocialAuthButton(
                  type: ButtonType.google,
                  onPressed: () => auth.signInWithGoogle(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SocialAuthButton.apple(
            onPressed: () => auth.signInWithApple(),
          ),
        ],
      );
    } else {
      // Single column layout for mobile and tablet
      return Column(
        children: [
          SocialAuthButton.kakao(
            onPressed: () => auth.signInWithKakao(),
          ),
          const SizedBox(height: 12),
          SocialAuthButton(
            type: ButtonType.google,
            onPressed: () => auth.signInWithGoogle(),
          ),
          const SizedBox(height: 12),
          SocialAuthButton.apple(
            onPressed: () => auth.signInWithApple(),
          ),
        ],
      );
    }
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outline,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            'OR',
            style: AppTextStyles.helperText(context).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outline,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneSection(BuildContext context, Color primaryColor) {
    // Add extra padding when keyboard is visible to push button up
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final additionalPadding = keyboardHeight > 0 ? 200.0 : 0.0;
    
    return Column(
      children: [
        Text(
          '소셜 계정 대신, 휴대폰 번호로 시작해보세요!',
          textAlign: TextAlign.center,
          style: ResponsiveUtils.getResponsiveTextStyle(
            context,
            AppTextStyles.secondaryText(context),
            tabletScale: 1.05,
            desktopScale: 1.1,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: _phoneFocusNode.hasFocus
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.15),
                      blurRadius: 15.0,
                      spreadRadius: 5.0,
                      offset: const Offset(0, 0),
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
              PhoneNumberTextInputFormatter(),
            ],
            style: AppTextStyles.inputText(context),
            decoration: InputDecoration(
              labelText: '휴대폰 번호를 입력해주세요',
              hintText: '휴대폰 번호를 입력해주세요',
              prefixIcon: Icon(
                SolarIconsBold.phoneCallingRounded,
                color: primaryColor,
              ),
              contentPadding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: primaryColor, width: 2.0),
              ),
              labelStyle: AppTextStyles.inputLabel(context).copyWith(
                color: _phoneFocusNode.hasFocus 
                    ? primaryColor 
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryTextButton(
          text: '휴대폰 번호 로그인',
          onPressed: () {
            final digitsOnly = _phoneController.text.replaceAll(
              RegExp(r'\D'),
              '',
            );
            if (digitsOnly.length < 10 || digitsOnly.length > 11) {
              DelightToastBar(
                builder: (ctx) => Material(
                  color: Colors.transparent,
                  child: _ToastContent(
                    title: '입력 오류',
                    message: '전화 번호는 숫자 10~11자리여야 합니다.',
                    icon: Icon(
                      SolarIconsBold.phoneCallingRounded,
                      color: Colors.white,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.warning,
                  ),
                ),
                autoDismiss: true,
              ).show(context);
              return;
            }
            // TODO: 실제 인증 로직 연결
          },
        ),
        // Add dynamic spacing when keyboard is visible
        SizedBox(height: additionalPadding),
      ],
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    final features = [
      {
        'icon': SolarIconsBold.star,
        'title': 'AI 맞춤 추천',
        'description': '당신에게 완벽한 플레이스를 찾아드립니다',
      },
      {
        'icon': SolarIconsBold.usersGroupTwoRounded,
        'title': '커뮤니티',
        'description': '같은 관심사를 가진 사람들과 소통하세요',
      },
      {
        'icon': SolarIconsBold.shield,
        'title': '안전한 환경',
        'description': '검증된 플레이스에서 안심하고 즐기세요',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: AppTextStyles.subtitle(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['description'] as String,
                      style: AppTextStyles.captionText(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.12),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

// Simple toast content widget used by DelightToastBar
class _ToastContent extends StatelessWidget {
  // ignore: use_super_parameters
  const _ToastContent({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    this.backgroundColor = Colors.black87,
  }) : super(key: key);

  final String title;
  final String message;
  final Widget icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.26), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.24),
              shape: BoxShape.circle,
            ),
            child: icon,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.buttonText(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: AppTextStyles.captionText(context).copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

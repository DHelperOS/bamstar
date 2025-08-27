import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_providers.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:solar_icons/solar_icons.dart';
// auth_fields removed from this screen
import '../widgets/primary_text_button.dart';
import '../widgets/social_auth_button.dart';
import '../widgets/auth_fields.dart';
import '../theme/app_color_scheme_extension.dart';
import '../theme/typography.dart';
import '../theme/app_text_styles.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();

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
  }

  @override
  void dispose() {
    _logoController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes: show errors and navigate on successful sign-in
    ref.listen<AsyncValue<AuthState>>(authControllerProvider, (previous, next) {
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
          // If we transitioned from no-session -> session, navigate to roles selection
          final prevSession = previous?.maybeWhen(
            data: (v) => v.session,
            orElse: () => null,
          );
          if (authState.session != null && prevSession == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.go('/roles');
            });
          }
        },
      );
    });
    final asyncAuth = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          // subtle background gradient so glass effect has something to blur
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF6F7FB), Color(0xFFF0EEFF)],
              ),
            ),
          ),
          // subtle diagonal overlay to provide texture/pattern for the blur
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
                          // faint tinted bands to make blur more noticeable
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
          Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 74),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 68,
                  ),
                  decoration: BoxDecoration(
                    // make the card more translucent so backdrop blur is more visible
                    color: Colors.white.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top logo circle with glassmorphism effect; animate only the inner image
                      ClipOval(
                        child: BackdropFilter(
                          // increase blur to make frosted effect stronger
                          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              // subtle frosted glass look
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                // reduce inner opacity so the blurred backdrop shows
                                colors: [
                                  theme.colorScheme.primary.withValues(
                                    alpha: 0.04,
                                  ),
                                  const Color.fromARGB(
                                    255,
                                    209,
                                    163,
                                    218,
                                  ).withValues(alpha: 0.5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(40),
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
                                  width: 38,
                                  height: 38,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title & subtitle
                      Text(
                        '가장 빛나는 밤, 가장 빛나는 나.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.sectionTitle(context).copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '소셜 로그인으로 간편하게 시작하세요.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.secondaryText(context),
                      ),
                      const SizedBox(height: 24),

                      // Social buttons
                      Consumer(
                        builder: (context, ref, _) {
                          final auth = ref.read(
                            authControllerProvider.notifier,
                          );
                          return Column(
                            children: [
                              SocialAuthButton.kakao(
                                onPressed: () {
                                  auth.signInWithKakao();
                                },
                              ),
                              const SizedBox(height: 12),
                              SocialAuthButton(
                                type: ButtonType.google,
                                onPressed: () {
                                  auth.signInWithGoogle();
                                },
                              ),
                              const SizedBox(height: 12),
                              SocialAuthButton.apple(
                                onPressed: () {
                                  auth.signInWithApple();
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 24),

                      // OR separator
                      Row(
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
                      ),
                      const SizedBox(height: 16),

                      const SizedBox(height: 12),

                      // helper title above phone input (same style as subtitle)
                      Text(
                        '소셜 계정 대신, 휴대폰 번호로 시작해보세요!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.secondaryText(context),
                      ),
                      const SizedBox(height: 20),

                      // Phone input for sign-up
                      AuthTextfields().buildTextField(
                        controller: _phoneController,
                        labelText: '휴대폰 번호를 입력해주세요',
                        hintText: '휴대폰 번호를 입력해주세요',
                        focusColor: primaryColor,
                        context: context,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                          PhoneNumberTextInputFormatter(),
                        ],
                        prefixIcon: Icon(
                          // use solar_icons package icon per project policy
                          // mapped from `.solar--phone-calling-rounded-bold-duotone`
                          SolarIconsBold.phoneCallingRounded,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      const SizedBox(height: 8),

                      // Login button with simple phone validation
                      PrimaryTextButton(
                        text: '휴대폰 번호 로그인',
                        onPressed: () {
                          final digitsOnly = _phoneController.text.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );
                          if (digitsOnly.length < 10 ||
                              digitsOnly.length > 11) {
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
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (asyncAuth.isLoading)
            Positioned.fill(
              child: Container(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.12),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
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

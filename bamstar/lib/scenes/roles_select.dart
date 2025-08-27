// Bamstar - Role Selection Screen
// References: dev/templates/ai-reference/study_platform_ui_kit (layout spacing, card patterns)
// Material 3 적용: 사용됨, Used icons: solar_icons

import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animated_emoji/animated_emoji.dart';
import 'package:bamstar/widgets/bs_alert_dialog.dart';
import 'package:bamstar/scenes/match_profiles.dart';
import '../theme/typography.dart';
import '../theme/app_text_styles.dart';
import '../utils/toast_helper.dart';
import 'package:go_router/go_router.dart';
// animations package no longer needed after local pop-forward effect

typedef RoleSelectCallback = void Function(String role);

class RoleSelectPage extends StatefulWidget {
  const RoleSelectPage({super.key, this.onSelected});

  final RoleSelectCallback? onSelected;

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage>
    with TickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<Offset> _slideLeft;
  late final Animation<Offset> _slideRight;

  bool _hoverStar = false;
  bool _hoverPlace = false;
  int? _selectedIndex; // 0: Star, 1: Place
  // saving state for role update
  bool _isSaving = false;
  int? _savingIndex; // which card is currently being saved
  int? _savedIndex; // recently saved card index (for success UI)
  bool _isDialogOpen = false;
  String? _lastSavedRole;

  // Use app homepage theme via ColorScheme instead of hard-coded palette

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideLeft = Tween<Offset>(begin: const Offset(-0.2, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ac,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
          ),
        );
    _slideRight = Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ac,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    // Kick animation on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _ac.forward());
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the app's ColorScheme so this page follows the homepage theme
    final cs = Theme.of(context).colorScheme;
    // prefer surface for background following Material 3 guidance
    final bg = cs.surface;
    final surfaceColor = cs.surface;
    final starAccent = cs.primary; // primary as accent for star
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurfaceVariant;
    // cherry blossom / pale pink for the second card accent
    final cherryPink = const Color(0xFFFFB7C9);

    Widget buildCard({
      required bool isStar,
      required bool hovered,
      required ValueChanged<bool> onHover,
      required VoidCallback onTap,
    }) {
      // Local forward-pop effect: scale + slight lift with stronger shadow. No fullscreen route push.
      return MouseRegion(
        onEnter: (_) => onHover(true),
        onExit: (_) => onHover(false),
        child: GestureDetector(
          onTap: () {
            // tapping the card selects it visually only; actual role update happens when
            // the "시작 하기" badge/button is pressed.
            setState(() => _selectedIndex = isStar ? 0 : 1);
          },
          child: LayoutBuilder(
            builder: (context, c) {
              final cardWidth = c.maxWidth.isFinite ? c.maxWidth : 260.0;
              final cardHeight = c.maxHeight.isFinite ? c.maxHeight : 320.0;
              final isSelected = _selectedIndex == (isStar ? 0 : 1);
              final othersDim = _selectedIndex != null && !isSelected;
              // content strings
              final header = isStar
                  ? '나의 가치를 증명할,\n새로운 무대를 찾고 있어요.'
                  : '우리의 무대를 빛내줄,\n최고의 스타를 찾고 있어요.';
              final body = isStar
                  ? '최고의 플레이스를 직접 선택하고,\n안전한 커뮤니티에서 다른 스타들과 함께 성장하세요.\n당신이 바로 이 밤의 주인공입니다.'
                  : 'AI의 지능적인 추천으로 최고의 인재를 발견하고,\n당신의 플레이스가 가진 진짜 매력을\n수많은 스타들에게 직접 어필하세요.';

              return Center(
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  offset: isSelected ? const Offset(0, -0.04) : Offset.zero,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutBack,
                    scale: isSelected
                        ? 1.04
                        : (othersDim ? 0.92 : (hovered ? 1.03 : 1.0)),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 220),
                      opacity: othersDim ? 0.6 : 1.0,
                      child: Container(
                        width: cardWidth,
                        height: cardHeight,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(
                                (((isSelected
                                            ? 0.22
                                            : (hovered ? 0.12 : 0.08))) *
                                        255)
                                    .round(),
                              ),
                              blurRadius: isSelected ? 34 : (hovered ? 24 : 12),
                              offset: const Offset(0, 12),
                            ),
                          ],
                          border: Border.all(
                            color: isSelected
                                ? (isStar ? starAccent : cherryPink)
                                : Colors.transparent,
                            width: isSelected ? 2.0 : 0.0,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // subtle tiled pattern using faint icons
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.06,
                                child: const _PatternBackground(),
                              ),
                            ),
                            // top-right decorative blob
                            Positioned(
                              right: -40,
                              top: -40,
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      isStar
                                          ? starAccent.withAlpha(
                                              (0.95 * 255).round(),
                                            )
                                          : cherryPink.withAlpha(
                                              (0.95 * 255).round(),
                                            ),
                                      (isStar ? starAccent : cherryPink)
                                          .withAlpha((0.6 * 255).round()),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            // top-left small label (스타 / 플레이스)
                            Positioned(
                              left: 14,
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isStar ? starAccent : cherryPink,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  isStar ? '스타' : '플레이스',
                                  style: AppTextStyles.chipLabel(context).copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            // main content (made flexible to avoid overflow on small card heights)
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // add a bit more top spacing so emoji/header/body sit lower in the card
                                    const SizedBox(height: 10),
                                    // top illustration (role image)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: isStar
                                            ? AnimatedEmoji(
                                                AnimatedEmojis.dancerWoman,
                                                size: 28,
                                              )
                                            : AnimatedEmoji(
                                                AnimatedEmojis.rocket,
                                                size: 28,
                                              ),
                                      ),
                                    ),
                                    // header + description
                                    Text(
                                      header,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.cardTitle(context).copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Make description area flexible, scrollable and show a scrollbar so text isn't clipped
                                    Expanded(
                                      child: RawScrollbar(
                                        thumbVisibility: true,
                                        radius: const Radius.circular(8),
                                        thickness: 6,
                                        child: SingleChildScrollView(
                                          primary: false,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Text(
                                            body,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: textSecondary,
                                              height: 1.36,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // selection badge at card bottom (now doubles as action)
                                    GestureDetector(
                                      onTap: () {
                                        if (isSelected) {
                                          // when already selected, pressing badge performs the action
                                          onTap();
                                        } else {
                                          setState(
                                            () =>
                                                _selectedIndex = isStar ? 0 : 1,
                                          );
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 220,
                                        ),
                                        curve: Curves.easeInOut,
                                        width: 110,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? (isStar
                                                    ? starAccent
                                                    : cherryPink)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.transparent
                                                : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.12),
                                            width: 1.2,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.12,
                                                        ),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Center(
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 260,
                                            ),
                                            switchInCurve: Curves.easeOutBack,
                                            child: (() {
                                              // saving indicator
                                              if (_isSaving &&
                                                  _savingIndex ==
                                                      (isStar ? 0 : 1)) {
                                                return Row(
                                                  key: const ValueKey('saving'),
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(
                                                              isStar
                                                                  ? Colors.white
                                                                  : Colors
                                                                        .white,
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      '저장 중',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }

                                              // saved success state
                                              if (_savedIndex != null &&
                                                  _savedIndex ==
                                                      (isStar ? 0 : 1)) {
                                                return Row(
                                                  key: const ValueKey('done'),
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      SolarIconsOutline
                                                          .checkCircle,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      '완료',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }

                                              // default: selected/not-selected
                                              return Row(
                                                key: ValueKey(
                                                  isSelected
                                                      ? 'start'
                                                      : 'select',
                                                ),
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    SolarIconsOutline
                                                        .checkCircle,
                                                    size: 16,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : (isStar
                                                              ? starAccent
                                                              : cherryPink),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    isSelected ? '시작 하기' : '선택',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: isSelected
                                                          ? Colors.white
                                                          : textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            })(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth >= 680;
            final spacing = isWide ? 24.0 : 16.0;

            // card width when wide: leave some outer padding and center the pair
            final cardWidth = isWide
                ? ((c.maxWidth - spacing * 3) / 2).clamp(160.0, 220.0)
                : c.maxWidth;

            final leftCard = SlideTransition(
              position: _slideLeft,
              child: buildCard(
                isStar: true,
                hovered: _hoverStar,
                onHover: (v) => setState(() => _hoverStar = v),
                onTap: () => _select('STAR'),
              ),
            );
            final rightCard = SlideTransition(
              position: _slideRight,
              child: buildCard(
                isStar: false,
                hovered: _hoverPlace,
                onHover: (v) => setState(() => _hoverPlace = v),
                onTap: () => _select('PLACE'),
              ),
            );

            final content = isWide
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: cardWidth, child: leftCard),
                      SizedBox(width: spacing),
                      SizedBox(width: cardWidth, child: rightCard),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: () {
                      final verticalAvail = c.maxHeight - spacing * 2;
                      final each = ((verticalAvail - spacing) / 2).clamp(
                        180.0,
                        260.0,
                      );
                      return [
                        SizedBox(height: each, child: leftCard),
                        SizedBox(height: spacing),
                        SizedBox(height: each, child: rightCard),
                      ];
                    }(),
                  );

            return Center(
              child: Padding(
                padding: EdgeInsets.all(spacing),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // lifted header — translate upward by ~100px to match visual request
                    Transform.translate(
                      offset: const Offset(0, -50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedEmoji(AnimatedEmojis.sparkles, size: 28),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              '역할을 선택하여 밤스타를 시작하세요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedEmoji(AnimatedEmojis.sparkles, size: 28),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing),
                    content,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _select(String role) async {
    // Try to persist the selected role to Supabase (public.users.role_id).
    // Assumption: `role` is an allowed value for users.role_id in the DB (e.g. 'STAR' or 'PLACE').
    // Capture Messenger and Navigator before awaiting to avoid using BuildContext
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ToastHelper.warning(context, '로그인이 필요합니다.');
        return;
      }

      // Start saving UI
      setState(() {
        _isSaving = true;
        _savingIndex = (role == 'STAR') ? 0 : 1;
        _savedIndex = null;
      });

      // If the role matches the last saved role, skip DB call and reuse success flow
      if (_lastSavedRole != null && _lastSavedRole == role) {
        final int idx = (role == 'STAR') ? 0 : 1;
        setState(() {
          _isSaving = false;
          _savingIndex = null;
          _savedIndex = idx;
        });

        // brief pause to show saved state then show dialog (reuse existing dialog flow)
        await Future.delayed(const Duration(milliseconds: 600));

        if (!mounted) return;
        if (!_isDialogOpen) {
          _isDialogOpen = true;
          try {
            final bool? confirmed = await showBsAlert<bool>(
              context,
              header: role == 'STAR'
                  ? '프로필 완성하고, 주인공 되기.'
                  : '프로필 완성하고, 스타 섭외하기.',
              body: role == 'STAR'
                  ? '프로필을 완성하면, AI가 회원님에게 꼭 맞는 플레이스를 추천하고, 플레이스로부터 먼저 연결 제안을 받을 확률이 크게 올라가요.'
                  : '상세 프로필은 AI 추천과 검색 결과에 모두 반영되어, 더 많은 스타들에게 당신의 플레이스가 노출될 기회를 만듭니다.',
              primaryText: role == 'STAR' ? '내 매력 어필하기' : '정확도 올리기',
              secondaryText: '나중에..',
              icon: SolarIconsOutline.checkCircle,
              barrierDismissible: true,
            );

            if (confirmed == true) {
              // After role confirmation, send to home per requirement
              if (mounted) context.go('/home');
            }
          } finally {
            _isDialogOpen = false;
          }
        }

        // propagate selection result and close if possible (same as normal flow)
        if (widget.onSelected != null) {
          widget.onSelected!(role);
        }
        if (mounted && navigator.canPop()) {
          navigator.pop(role);
        } else if (mounted) {
          // If cannot pop (e.g., entry route), go to home to continue
          context.go('/home');
        }

        // clear saved UI state after a short moment
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) {
          setState(() {
            _savedIndex = null;
          });
        }

        return;
      }

      // Map role string to DB numeric ID
      final int roleId = (role == 'STAR') ? 2 : 3; // STAR=2, PLACE=3

      // Perform update; wrap in try/catch to avoid throwing into UI.
      await Supabase.instance.client
          .from('users')
          .update({'role_id': roleId})
          .eq('id', user.id);

      if (!mounted) return;

      // success
      setState(() {
        _isSaving = false;
        _savedIndex = _savingIndex;
        _savingIndex = null;
      });

      // remember last saved role to avoid redundant DB updates
      _lastSavedRole = role;

      // Optional: ambient feedback removed per request

      // show success state briefly before continuing
      await Future.delayed(const Duration(milliseconds: 900));

      // Show reusable Material 3 alert dialog (blocks until dismissed)
      if (!mounted) return;
      if (!_isDialogOpen) {
        _isDialogOpen = true;
        try {
          final bool? confirmed = await showBsAlert<bool>(
            context,
            header: role == 'STAR' ? '프로필 완성하고, 주인공 되기.' : '프로필 완성하고, 스타 섭외하기.',
            body: role == 'STAR'
                ? '프로필을 완성하면, AI가 회원님에게 꼭 맞는 플레이스를 추천하고, 플레이스로부터 먼저 연결 제안을 받을 확률이 크게 올라가요.'
                : '상세 프로필은 AI 추천과 검색 결과에 모두 반영되어, 더 많은 스타들에게 당신의 플레이스가 노출될 기회를 만듭니다.',
            primaryText: role == 'STAR' ? '내 매력 어필하기' : '정확도 올리기',
            secondaryText: '나중에..',
            icon: SolarIconsOutline.checkCircle,
            barrierDismissible: true,
          );

          // If user tapped the primary action, give immediate feedback (navigation handled elsewhere)
          if (confirmed == true) {
            if (role == 'STAR') {
              await navigator.push(
                MaterialPageRoute(builder: (_) => const MatchProfilesPage()),
              );
            } else {
              ToastHelper.info(context, '자세한 정보로 정확도를 올려보세요.');
            }
          }
        } finally {
          _isDialogOpen = false;
        }
      }
    } catch (e) {
      // Log and show minimal feedback
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _savingIndex = null;
      });
      ToastHelper.error(context, '역할 저장에 실패했습니다.');
      return;
    }

    if (widget.onSelected != null) {
      widget.onSelected!(role);
    }

    // Fallback: simple navigation pop with result if possible
    if (mounted && navigator.canPop()) {
      navigator.pop(role);
    }

    // clear saved UI state after a short moment (if still mounted)
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _savedIndex = null;
      });
    }
  }
}

// _RoleCard was removed; use _SimpleRoleCard + OpenContainer for the interactive experience.

// Helper to determine icon type from the provided widget (best-effort)
bool isStarIcon(Widget w) {
  return w is Icon && w.icon == SolarIconsOutline.star;
}

// A slim card used by OpenContainer closedBuilder
// Pattern background: faint tiled icons to mimic the sample's textured backdrop
class _PatternBackground extends StatelessWidget {
  const _PatternBackground();

  @override
  Widget build(BuildContext context) {
    // Use a wrap of small icons spaced out to create a light pattern
    return LayoutBuilder(
      builder: (context, c) {
        final cols = (c.maxWidth / 80).ceil();
        final rows = (c.maxHeight / 80).ceil();
        final count = (cols * rows).clamp(0, 80);
        return Center(
          child: Wrap(
            spacing: 18,
            runSpacing: 18,
            children: List.generate(count, (i) {
              return Opacity(
                opacity: 0.9,
                child: Icon(
                  SolarIconsOutline.star,
                  size: 34,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha((0.04 * 255).round()),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// Page shown when card opens — playful pop-out with a single CTA
// Non-fullscreen popout used by OpenContainer.openBuilder to give the forward pop effect
// (Removed _RolePopout since we use local scale/slide pop-forward effect)

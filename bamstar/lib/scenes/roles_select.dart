// Bamstar - Role Selection Screen
// References: dev/templates/ai-reference/study_platform_ui_kit (layout spacing, card patterns)
// Material 3 적용: 사용됨, Used icons: solar_icons

import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animated_emoji/animated_emoji.dart';

import '../theme/app_text_styles.dart';
import '../utils/toast_helper.dart';
import 'package:go_router/go_router.dart';

typedef RoleSelectCallback = void Function(String role);

class RoleSelectPage extends StatefulWidget {
  const RoleSelectPage({super.key, this.onSelected});

  final RoleSelectCallback? onSelected;

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage>
    with TickerProviderStateMixin {
  
  // Multi-controller setup for better animation coordination
  late final AnimationController _pageController;
  late final AnimationController _cardsController;
  late final AnimationController _headerController;
  
  // Page-level animations
  late final Animation<double> _pageOpacity;
  late final Animation<double> _pageScale;
  
  // Header animations
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _headerOpacity;
  
  // Card animations
  late final Animation<Offset> _leftCardSlide;
  late final Animation<Offset> _rightCardSlide;
  late final Animation<double> _cardsOpacity;
  
  bool _hoverStar = false;
  bool _hoverPlace = false;
  int? _selectedIndex; // 0: Star, 1: Place
  bool _isSaving = false;
  int? _savingIndex;
  int? _savedIndex;
  String? _lastSavedRole;
  


  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startEntranceAnimation();
  }

  void _initAnimations() {
    // Page controller for overall entrance
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    // Header controller for title entrance
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Cards controller for card entrance
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    // Page-level fade and subtle scale
    _pageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: Curves.easeOut,
      ),
    );
    
    _pageScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Header animations - slide down with fade
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: Curves.easeOutBack,
      ),
    );
    
    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    
    // Card animations - staggered entrance from sides
    _leftCardSlide = Tween<Offset>(
      begin: const Offset(-0.15, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cardsController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    
    _rightCardSlide = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cardsController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    
    _cardsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardsController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    

  }

  Future<void> _startEntranceAnimation() async {
    // Start page animation immediately (no frame delay)
    _pageController.forward();
    
    // Stagger the other animations for a polished entrance
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) _headerController.forward();
    
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) _cardsController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headerController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = cs.surface;
    final surfaceColor = cs.surface;
    final starAccent = cs.primary;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurfaceVariant;
    final cherryPink = const Color(0xFFFFB7C9);

    return Scaffold(
      backgroundColor: bg,
      body: AnimatedBuilder(
        animation: Listenable.merge([_pageController, _headerController, _cardsController]),
        builder: (context, child) {
          return Opacity(
            opacity: _pageOpacity.value,
            child: Transform.scale(
              scale: _pageScale.value,
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final isWide = c.maxWidth >= 680;
                    final spacing = isWide ? 24.0 : 16.0;
                    final cardWidth = isWide
                        ? ((c.maxWidth - spacing * 3) / 2).clamp(160.0, 220.0)
                        : c.maxWidth;

                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(spacing),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Enhanced header with smooth entrance
                            Transform.translate(
                              offset: const Offset(0, -50),
                              child: SlideTransition(
                                position: _headerSlide,
                                child: FadeTransition(
                                  opacity: _headerOpacity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedEmoji(AnimatedEmojis.sparkles, size: 28),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          '역할을 선택하여 밤스타를 시작하세요.',
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.pageTitle(context).copyWith(
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
                              ),
                            ),
                            SizedBox(height: spacing),
                            
                            // Enhanced cards with smooth entrance
                            FadeTransition(
                              opacity: _cardsOpacity,
                              child: isWide
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: cardWidth,
                                          child: SlideTransition(
                                            position: _leftCardSlide,
                                            child: _buildEnhancedCard(
                                              isStar: true,
                                              hovered: _hoverStar,
                                              onHover: (v) => setState(() => _hoverStar = v),
                                              onTap: () => _select('STAR'),
                                              surfaceColor: surfaceColor,
                                              starAccent: starAccent,
                                              cherryPink: cherryPink,
                                              textPrimary: textPrimary,
                                              textSecondary: textSecondary,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: spacing),
                                        SizedBox(
                                          width: cardWidth,
                                          child: SlideTransition(
                                            position: _rightCardSlide,
                                            child: _buildEnhancedCard(
                                              isStar: false,
                                              hovered: _hoverPlace,
                                              onHover: (v) => setState(() => _hoverPlace = v),
                                              onTap: () => _select('PLACE'),
                                              surfaceColor: surfaceColor,
                                              starAccent: starAccent,
                                              cherryPink: cherryPink,
                                              textPrimary: textPrimary,
                                              textSecondary: textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: () {
                                        final verticalAvail = c.maxHeight - spacing * 2;
                                        final each = ((verticalAvail - spacing) / 2).clamp(180.0, 260.0);
                                        return [
                                          SizedBox(
                                            height: each,
                                            child: SlideTransition(
                                              position: _leftCardSlide,
                                              child: _buildEnhancedCard(
                                                isStar: true,
                                                hovered: _hoverStar,
                                                onHover: (v) => setState(() => _hoverStar = v),
                                                onTap: () => _select('STAR'),
                                                surfaceColor: surfaceColor,
                                                starAccent: starAccent,
                                                cherryPink: cherryPink,
                                                textPrimary: textPrimary,
                                                textSecondary: textSecondary,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: spacing),
                                          SizedBox(
                                            height: each,
                                            child: SlideTransition(
                                              position: _rightCardSlide,
                                              child: _buildEnhancedCard(
                                                isStar: false,
                                                hovered: _hoverPlace,
                                                onHover: (v) => setState(() => _hoverPlace = v),
                                                onTap: () => _select('PLACE'),
                                                surfaceColor: surfaceColor,
                                                starAccent: starAccent,
                                                cherryPink: cherryPink,
                                                textPrimary: textPrimary,
                                                textSecondary: textSecondary,
                                              ),
                                            ),
                                          ),
                                        ];
                                      }(),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedCard({
    required bool isStar,
    required bool hovered,
    required ValueChanged<bool> onHover,
    required VoidCallback onTap,
    required Color surfaceColor,
    required Color starAccent,
    required Color cherryPink,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedIndex = isStar ? 0 : 1);
        },
        child: LayoutBuilder(
          builder: (context, c) {
            final cardWidth = c.maxWidth.isFinite ? c.maxWidth : 260.0;
            final cardHeight = c.maxHeight.isFinite ? c.maxHeight : 320.0;
            final isSelected = _selectedIndex == (isStar ? 0 : 1);
            final othersDim = _selectedIndex != null && !isSelected;

            final header = isStar
                ? '나의 가치를 증명할,\n새로운 무대를 찾고 있어요.'
                : '우리의 무대를 빛내줄,\n최고의 스타를 찾고 있어요.';
            final body = isStar
                ? '최고의 플레이스를 직접 선택하고,\n안전한 커뮤니티에서 다른 스타들과 함께 성장하세요.\n당신이 바로 이 밤의 주인공입니다.'
                : 'AI의 지능적인 추천으로 최고의 인재를 발견하고,\n당신의 플레이스가 가진 진짜 매력을\n수많은 스타들에게 직접 어필하세요.';

            return Center(
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                offset: isSelected ? const Offset(0, -0.03) : Offset.zero,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  scale: isSelected
                      ? 1.03
                      : (othersDim ? 0.94 : (hovered ? 1.02 : 1.0)),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: othersDim ? 0.65 : 1.0,
                    child: Container(
                      width: cardWidth,
                      height: cardHeight,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isSelected ? 0.2 : (hovered ? 0.1 : 0.06),
                            ),
                            blurRadius: isSelected ? 30 : (hovered ? 20 : 10),
                            offset: Offset(0, isSelected ? 10 : (hovered ? 8 : 6)),
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
                          // Pattern background
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.04,
                              child: const _PatternBackground(),
                            ),
                          ),
                          
                          // Decorative blob with enhanced gradient
                          Positioned(
                            right: -40,
                            top: -40,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    (isStar ? starAccent : cherryPink)
                                        .withValues(alpha: 0.9),
                                    (isStar ? starAccent : cherryPink)
                                        .withValues(alpha: 0.5),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          
                          // Enhanced role label
                          Positioned(
                            left: 14,
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: isStar ? starAccent : cherryPink,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                isStar ? '스타' : '플레이스',
                                style: AppTextStyles.chipLabel(context).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          
                          // Main content
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
                                  const SizedBox(height: 10),
                                  
                                  // Enhanced emoji with subtle animation
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: AnimatedScale(
                                        duration: const Duration(milliseconds: 200),
                                        scale: hovered ? 1.1 : 1.0,
                                        child: isStar
                                            ? AnimatedEmoji(
                                                AnimatedEmojis.dancerWoman,
                                                size: 30,
                                              )
                                            : AnimatedEmoji(
                                                AnimatedEmojis.rocket,
                                                size: 30,
                                              ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Header text
                                  Text(
                                    header,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.cardTitle(context).copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: textPrimary,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Description
                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics: const ClampingScrollPhysics(),
                                      child: Text(
                                        body,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.secondaryText(context).copyWith(
                                          fontSize: 14.0,
                                          height: 1.4,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  
                                  // Enhanced action button
                                  _buildActionButton(
                                    isSelected: isSelected,
                                    isStar: isStar,
                                    starAccent: starAccent,
                                    cherryPink: cherryPink,
                                    textSecondary: textSecondary,
                                    onTap: onTap,
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

  Widget _buildActionButton({
    required bool isSelected,
    required bool isStar,
    required Color starAccent,
    required Color cherryPink,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          onTap();
        } else {
          setState(() => _selectedIndex = isStar ? 0 : 1);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 115,
        height: 38,
        decoration: BoxDecoration(
          color: isSelected
              ? (isStar ? starAccent : cherryPink)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutBack,
            child: _buildButtonContent(isSelected, isStar, textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(bool isSelected, bool isStar, Color textSecondary) {
    if (_isSaving && _savingIndex == (isStar ? 0 : 1)) {
      return Row(
        key: const ValueKey('saving'),
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '저장 중',
            style: AppTextStyles.buttonText(context).copyWith(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    if (_savedIndex != null && _savedIndex == (isStar ? 0 : 1)) {
      return Row(
        key: const ValueKey('done'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            SolarIconsOutline.checkCircle,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            '완료',
            style: AppTextStyles.buttonText(context).copyWith(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    return Row(
      key: ValueKey(isSelected ? 'start' : 'select'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          SolarIconsOutline.checkCircle,
          size: 16,
          color: isSelected ? Colors.white : textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          isSelected ? '시작 하기' : '선택',
          style: AppTextStyles.buttonText(context).copyWith(
            fontSize: 12,
            color: isSelected ? Colors.white : textSecondary,
          ),
        ),
      ],
    );
  }

  Future<void> _select(String role) async {
    final navigator = Navigator.of(context);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ToastHelper.warning(context, '로그인이 필요합니다.');
        return;
      }

      setState(() {
        _isSaving = true;
        _savingIndex = (role == 'STAR') ? 0 : 1;
        _savedIndex = null;
      });

      if (_lastSavedRole != null && _lastSavedRole == role) {
        final int idx = (role == 'STAR') ? 0 : 1;
        setState(() {
          _isSaving = false;
          _savingIndex = null;
          _savedIndex = idx;
        });

        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        context.go('/terms');

        if (widget.onSelected != null) {
          widget.onSelected!(role);
        }
        if (mounted && navigator.canPop()) {
          navigator.pop(role);
        } else if (mounted) {
          context.go('/home');
        }

        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          setState(() => _savedIndex = null);
        }
        return;
      }

      // STAR = member (role_id: 3), PLACE = product_owner (role_id: 2)
      final int roleId = (role == 'STAR') ? 3 : 2;

      await Supabase.instance.client
          .from('users')
          .update({'role_id': roleId})
          .eq('id', user.id);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _savedIndex = _savingIndex;
        _savingIndex = null;
      });

      _lastSavedRole = role;

      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      context.go('/terms');
    } catch (e) {
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

    if (mounted && navigator.canPop()) {
      navigator.pop(role);
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _savedIndex = null);
    }
  }
}

class _PatternBackground extends StatelessWidget {
  const _PatternBackground();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = (c.maxWidth / 80).ceil();
        final rows = (c.maxHeight / 80).ceil();
        final count = (cols * rows).clamp(0, 60);
        return Center(
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: List.generate(count, (i) {
              return Opacity(
                opacity: 0.8,
                child: Icon(
                  SolarIconsOutline.star,
                  size: 32,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.03),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
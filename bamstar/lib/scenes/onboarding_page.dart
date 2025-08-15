import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:solar_icons/solar_icons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _titleController;
  late final AnimationController _descController;
  late final Animation<Offset> _titleOffset;
  late final Animation<Offset> _descOffset;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _descOpacity;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/onboard/onboard_one.webp',
      'title': '가장 빛나는 밤,\n가장 빛나는 나.',
      'description':
          '당신의 가치를 모르는 곳은 이제 그만.\n최고의 플레이스를 직접 고를 시간이에요.',
    },
    {
      'image': 'assets/images/onboard/onboard_two.webp',
      'title': 'AI가 찾아주는,\n나를 알아주는 단 하나의 플레이스.',
      'description': '\'탐색\'에서 자유롭게 보물을 찾거나,\n\'추천\'을 통해 AI가 엄선한 최고의 기회를 제안받으세요.',
    },
    {
      'image': 'assets/images/onboard/onboard_three.webp',
      'title': '혼자가 아니야,\n우리는 서로의 별이니까.',
      'description': '플레이스는 절대 들어올 수 없는 우리만의 공간에서,\n솔직한 정보와 따뜻한 위로를 나누세요.',
    },
  ];

  @override
  void initState() {
    super.initState();

    _titleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _descController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));

    _titleOffset = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));
    _descOffset = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _descController, curve: Curves.easeOut));

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeIn));
    _descOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _descController, curve: Curves.easeIn));

    _pageController.addListener(() {
      final next = _pageController.page?.round() ?? 0;
      if (_currentPage != next) {
        setState(() => _currentPage = next);
        _playEntryAnimations();
      }
    });

    // Play initial animations after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _playEntryAnimations());
  }

  void _playEntryAnimations() {
    try {
      _titleController.forward(from: 0.0);
      // stagger description slightly
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _descController.forward(from: 0.0);
      });
    } catch (_) {}
  }

  @override
  void dispose() {
  _pageController.dispose();
  _titleController.dispose();
  _descController.dispose();
  super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);

    return Scaffold(
      // Use theme's scaffold background so Material3 theme is applied consistently
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v < -150) {
            // swipe left -> next
            final next = (_currentPage + 1).clamp(0, _pages.length - 1);
            if (next != _currentPage) {
              _pageController.animateToPage(next, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
            }
          } else if (v > 150) {
            // swipe right -> previous
            final prev = (_currentPage - 1).clamp(0, _pages.length - 1);
            if (prev != _currentPage) {
              _pageController.animateToPage(prev, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
            }
          }
        },
        child: Stack(
        children: [
          Column(
          children: [
          Expanded(
            flex: 3,
            child: PageView(
              controller: _pageController,
              children: List.generate(
                _pages.length,
                (i) => _OnboardingPage(
                  imagePath: _pages[i]['image']!,
                  title: _pages[i]['title']!,
                  description: _pages[i]['description']!,
                  pageController: _pageController,
                  index: i,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // indicators (left) and Skip (right) - place Skip near content for a more natural feel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        _pages.length,
                        (index) => buildDot(index, context),
                      ),
                    ),
                    // Inline skip button next to indicators
                    Material(
                      color: theme.colorScheme.primary.withOpacity(0.06),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.12))),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          final last = _pages.length - 1;
                          _pageController.animateToPage(last, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(SolarIconsBold.mapArrowRight, size: 14, color: theme.colorScheme.primary),
                              const SizedBox(width: 6),
                              Text('건너뛰기', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title - allow padding to control available width
                SlideTransition(
                  position: _titleOffset,
                  child: FadeTransition(
                    opacity: _titleOpacity,
                    child: Text(
                      _pages[_currentPage]['title']!,
                      textAlign: TextAlign.start,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.1,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Description - allow padding to control available width
                SlideTransition(
                  position: _descOffset,
                  child: FadeTransition(
                    opacity: _descOpacity,
                    child: Text(
                      _pages[_currentPage]['description']!,
                      textAlign: TextAlign.start,
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700], height: 1.4, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Button aligned to same width as text content
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
                      final isLast = _currentPage == _pages.length - 1;
                      if (!isLast) {
                        _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                    child: Text(
                      _currentPage == _pages.length - 1 ? '밤스타 가입하기' : '더 알아보기',
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          ],
          ),

          

        ],
        ),
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    final theme = Theme.of(context);
    final bool active = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 6),
      height: active ? 6 : 6,
      width: active ? 14 : 6,
      decoration: BoxDecoration(
  color: active ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final PageController pageController;
  final int index;

  const _OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.pageController,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder listens to the pageController to compute a transform
    return Column(
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: pageController,
            builder: (context, child) {
              double page = 0.0;
              if (pageController.hasClients) {
                page = pageController.page ?? pageController.initialPage.toDouble();
              } else {
                page = pageController.initialPage.toDouble();
              }

              final double delta = (index - page);
              final double absDelta = delta.abs().clamp(0.0, 1.0);

              // progress how close to center (0..1)
              final double t = (1.0 - absDelta).clamp(0.0, 1.0);
              final double ease = Curves.easeOut.transform(t);
              final double elastic = Curves.elasticOut.transform(t);

              // Dramatic scale but capped: start small (0.5) and grow toward 1.0
              final double scale = (0.5 + 0.5 * elastic).clamp(0.5, 1.0);

              // Stronger rotation for drama
              final double rotation = delta * 0.6 * (1.0 - absDelta);

              // Bigger flying-in from above + bounce when centering
              const double baseShift = 28.0;
              final double flyIn = (1.0 - t) * -160.0; // start much higher
              final double bounce = math.sin(t * math.pi) * 28.0 * ease; // pronounced bounce
              final double translateY = flyIn + baseShift - bounce;

              // Increased horizontal parallax
              final double translateX = delta * 60.0 * (1.0 - absDelta);

              // Fade in quickly
              final double opacity = (0.0 + 1.0 * ease).clamp(0.0, 1.0);

              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(translateX, translateY),
                  child: Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.center,
                      child: child,
                    ),
                  ),
                ),
              );
            },
            child: _buildImage(context),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    if (imagePath.startsWith('http')) {
      return Center(
          child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.62,
          child: Image.network(imagePath, fit: BoxFit.contain, width: double.infinity),
        ),
      );
    }
    return Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.62,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
        // Log the error for debugging when running locally
        debugPrint('Failed to load onboard image: $imagePath -> $error');
        final theme = Theme.of(context);
        return Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text('이미지 로드 실패', style: theme.textTheme.bodySmall),
            ],
          ),
        );
          },
        ),
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'dart:math' as math;

// Reusable pull-to-refresh indicator widget.
// Usage: AppPullRefreshIndicator(progress: 0.0..1.0, spinning: bool)
class AppPullRefreshIndicator extends StatefulWidget {
  final double progress; // 0.0 .. ~1.5
  final bool spinning;
  const AppPullRefreshIndicator({required this.progress, required this.spinning, super.key});

  @override
  State<AppPullRefreshIndicator> createState() => _AppPullRefreshIndicatorState();
}

class _AppPullRefreshIndicatorState extends State<AppPullRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _maybeAnimate();
  }

  @override
  void didUpdateWidget(covariant AppPullRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeAnimate();
  }

  void _maybeAnimate() {
    if (widget.spinning) {
      if (!_ctrl.isAnimating) _ctrl.repeat();
    } else {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double size = 34;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value; // 0..1
        final angle = widget.spinning
            ? t * 2 * math.pi
            : (widget.progress.clamp(0.0, 1.0) * 2 * math.pi * 0.7);

        // Sparkle animation params
        double sparkle(double phase) => 0.5 + 0.5 * math.sin(2 * math.pi * (t + phase));
        final s1 = sparkle(0.0);
        final s2 = sparkle(0.33);
        final s3 = sparkle(0.66);

        return Opacity(
          opacity: (widget.spinning || widget.progress > 0.05) ? 1 : 0,
          child: SizedBox(
            width: 80,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // sparkles (3 small pulsing dots)
                Transform.translate(
                  offset: const Offset(-18, -10),
                  child: _SparkleDot(
                    scale: 0.6 + 0.4 * s1,
                    color: cs.primary.withValues(alpha: 64),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(22, -6),
                  child: _SparkleDot(
                    scale: 0.5 + 0.5 * s2,
                    color: cs.primary.withValues(alpha: 56),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, 16),
                  child: _SparkleDot(
                    scale: 0.4 + 0.6 * s3,
                    color: cs.primary.withValues(alpha: 48),
                  ),
                ),
                // app icon
                Transform.rotate(
                  angle: widget.spinning ? angle : 0.0,
                  child: Opacity(
                    opacity: widget.spinning
                        ? 1.0
                        : (0.35 + (widget.progress.clamp(0.0, 1.0) * 0.65)).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: widget.spinning
                          ? 1.0
                          : (0.7 + widget.progress.clamp(0.0, 1.0) * 0.45).clamp(0.0, 2.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/icon/app_icon.png',
                              width: size,
                              height: size,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SparkleDot extends StatelessWidget {
  final double scale;
  final Color color;
  const _SparkleDot({required this.scale, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            // Using fromRGBO for opacity to avoid type issues with withValues
            BoxShadow(
              color: Color.fromRGBO(
                (color.r * 255.0).round().clamp(0, 255),
                (color.g * 255.0).round().clamp(0, 255),
                (color.b * 255.0).round().clamp(0, 255),
                0.7,
              ),
              blurRadius: 4,
              spreadRadius: 0.5,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../models/match_profile.dart';
import 'package:bamstar/theme/app_text_styles.dart';
import 'package:solar_icons/solar_icons.dart';

/// Swipeable card widget for match profiles
class SwipeCard extends StatefulWidget {
  final MatchProfile profile;
  final Function(SwipeDirection direction, MatchProfile profile) onSwipe;
  final VoidCallback onTap;
  final double scale;
  final double translateY;
  final bool isTop;

  const SwipeCard({
    super.key,
    required this.profile,
    required this.onSwipe,
    required this.onTap,
    this.scale = 1.0,
    this.translateY = 0.0,
    this.isTop = false,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _animation;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  
  Alignment _dragAlignment = Alignment.center;
  bool _isDragging = false;
  double _rotationAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = AlignmentTween(
      begin: Alignment.center,
      end: Alignment.center,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _runCardAnimation(Offset pixelsPerSecond, Size size) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );

    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);
    _controller.animateWith(simulation);
    
    // Reset rotation
    _rotationAnimation = Tween<double>(
      begin: _rotationAngle,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
    _rotationController.forward(from: 0);
  }

  void _runSwipeAnimation(SwipeDirection direction) {
    late Alignment endAlignment;
    
    switch (direction) {
      case SwipeDirection.left:
        endAlignment = Alignment(-2.5, 0);
        break;
      case SwipeDirection.right:
        endAlignment = Alignment(2.5, 0);
        break;
      case SwipeDirection.up:
        endAlignment = Alignment(0, -2.5);
        break;
      case SwipeDirection.down:
        endAlignment = Alignment(0, 2.5);
        break;
    }

    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: endAlignment,
      ),
    );

    _controller.duration = const Duration(milliseconds: 400);
    _controller.forward(from: 0).then((_) {
      widget.onSwipe(direction, widget.profile);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (!widget.isTop) {
      return Transform.scale(
        scale: widget.scale,
        child: Transform.translate(
          offset: Offset(0, widget.translateY),
          child: IgnorePointer(
            child: _buildCard(context, opacity: 0.9),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      onPanDown: (_) {
        setState(() {
          _isDragging = true;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _dragAlignment += Alignment(
            details.delta.dx / (size.width / 2),
            details.delta.dy / (size.height / 2),
          );
          // Add rotation based on horizontal drag
          _rotationAngle = _dragAlignment.x * 0.3;
        });
      },
      onPanEnd: (details) {
        setState(() {
          _isDragging = false;
        });

        final threshold = 100;
        final distance = _dragAlignment.x.abs() * size.width / 2;
        final velocity = details.velocity.pixelsPerSecond;
        
        // Determine swipe direction
        if (velocity.dx.abs() > threshold || distance > size.width * 0.25) {
          if (_dragAlignment.x > 0) {
            _runSwipeAnimation(SwipeDirection.right);
            return;
          } else if (_dragAlignment.x < 0) {
            _runSwipeAnimation(SwipeDirection.left);
            return;
          }
        }
        
        if (velocity.dy < -threshold) {
          _runSwipeAnimation(SwipeDirection.up);
          return;
        } else if (velocity.dy > threshold) {
          // Down swipe (undo) - just spring back
        }

        // Spring back to center
        _runCardAnimation(velocity, size);
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _rotationController]),
        builder: (context, child) {
          final alignment = _isDragging ? _dragAlignment : _animation.value;
          final rotation = _isDragging ? _rotationAngle : _rotationAnimation.value;
          
          return Align(
            alignment: alignment,
            child: Transform.rotate(
              angle: rotation * 0.1,
              child: _buildCard(
                context,
                opacity: 1.0,
                showOverlay: _isDragging,
                overlayAlignment: alignment,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    double opacity = 1.0,
    bool showOverlay = false,
    Alignment overlayAlignment = Alignment.center,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 32;
    final cardHeight = cardWidth * 1.4;

    return Opacity(
      opacity: opacity,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main card content
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile image area
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          widget.profile.type == ProfileType.place
                              ? SolarIconsOutline.shop
                              : SolarIconsOutline.user,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  // Info section
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name only (match score moved to top)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.profile.name,
                                style: AppTextStyles.sectionTitle(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.profile.subtitle,
                                style: AppTextStyles.secondaryText(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Location and distance
                          Row(
                            children: [
                              Icon(
                                SolarIconsOutline.mapPoint,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.profile.location,
                                style: AppTextStyles.captionText(context),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.profile.formattedDistance,
                                style: AppTextStyles.captionText(context).copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Pay info
                          Row(
                            children: [
                              Icon(
                                SolarIconsOutline.wallet,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.profile.payInfo,
                                  style: AppTextStyles.captionText(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Tags
                          SizedBox(
                            height: 28,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.profile.tags.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 6),
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: colorScheme.outline.withValues(alpha: 0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    widget.profile.tags[index],
                                    style: AppTextStyles.captionText(context).copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Swipe overlay indicators
            if (showOverlay) ...[
              // Like overlay (right swipe)
              if (overlayAlignment.x > 0.3)
                Positioned(
                  top: 50,
                  left: 20,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            SolarIconsOutline.heart,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '좋아요',
                            style: AppTextStyles.primaryText(context).copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Pass overlay (left swipe)
              if (overlayAlignment.x < -0.3)
                Positioned(
                  top: 50,
                  right: 20,
                  child: Transform.rotate(
                    angle: 0.5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            SolarIconsOutline.closeCircle,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '넘기기',
                            style: AppTextStyles.primaryText(context).copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Favorite overlay (up swipe)
              if (overlayAlignment.y < -0.3)
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            SolarIconsOutline.bookmark,
                            size: 20,
                            color: colorScheme.tertiary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '저장',
                            style: AppTextStyles.primaryText(context).copyWith(
                              color: colorScheme.tertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
            
            // Match score badge positioned at top-right of image
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7), // Higher opacity for better visibility
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      SolarIconsOutline.star,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.profile.matchScore}%',
                      style: AppTextStyles.captionText(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
import 'package:flutter/material.dart';
import 'report_dialog.dart';
import '../../../services/community/community_repository.dart';
import '../../../utils/global_toast.dart';
import '../../../theme/app_color_scheme_extension.dart';
import 'package:solar_icons/solar_icons.dart';

/// PostActionsMenu - MenuDots 버튼을 누르면 나타나는 팝업 메뉴
/// 신고하기, 차단하기, 삭제하기 옵션을 제공합니다.
class PostActionsMenu extends StatefulWidget {
  final int postId; // 신고할 게시물 ID
  final String? reportedUserId; // 신고 대상 사용자 ID (익명의 경우 null)
  final Function(ReportReason reason)? onReport; // 신고 완료 후 콜백
  final VoidCallback? onBlock;
  final VoidCallback? onDelete;
  final bool showDelete; // 작성자에게만 표시

  const PostActionsMenu({
    super.key,
    required this.postId,
    this.reportedUserId,
    this.onReport,
    this.onBlock,
    this.onDelete,
    this.showDelete = false,
  });

  @override
  State<PostActionsMenu> createState() => _PostActionsMenuState();
}

class _PostActionsMenuState extends State<PostActionsMenu>
    with SingleTickerProviderStateMixin {
  final GlobalKey _menuKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _hideMenu();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _hideMenu();
    } else {
      _showMenu();
    }
  }

  void _showMenu() {
    if (_overlayEntry != null) return;

    final RenderBox? buttonBox =
        _menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;

    final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final Size buttonSize = buttonBox.size;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size screenSize = mediaQuery.size;

    // 팝업 크기 계산
    const double popupWidth = 140.0;
    const double popupItemHeight = 48.0;
    final int itemCount = [
      if (widget.onReport != null) 1,
      if (widget.onBlock != null) 1,
      if (widget.onDelete != null && widget.showDelete) 1,
    ].fold<int>(0, (a, b) => a + b);
    final double popupHeight = itemCount * popupItemHeight + 16.0; // 8px padding top/bottom

    // 위치 계산 - 화면 경계 고려
    double left = buttonPosition.dx + buttonSize.width - popupWidth;
    double top = buttonPosition.dy + buttonSize.height + 4.0;

    // 오른쪽 경계 체크
    if (left < 16.0) {
      left = 16.0;
    } else if (left + popupWidth > screenSize.width - 16.0) {
      left = screenSize.width - popupWidth - 16.0;
    }

    // 아래쪽 경계 체크 - 팝업이 화면 아래로 나가면 버튼 위쪽에 표시
    if (top + popupHeight > screenSize.height - mediaQuery.padding.bottom - 16.0) {
      top = buttonPosition.dy - popupHeight - 4.0;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: _hideMenu,
          behavior: HitTestBehavior.translucent,
          child: SizedBox.expand(
            child: Stack(
              children: [
                Positioned(
                  left: left,
                  top: top,
                  child: _buildPopupMenu(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  void _hideMenu() {
    if (_overlayEntry != null) {
      _animationController.reverse().then((_) {
        if (mounted) {
          _overlayEntry?.remove();
          _overlayEntry = null;
        }
      });
    }
  }

  Widget _buildPopupMenu() {
    final theme = Theme.of(context);
    
    final menuItems = <Widget>[];
    
    if (widget.onReport != null) {
      menuItems.add(_buildMenuItem(
        icon: SolarIconsOutline.flag,
        label: '신고하기',
        onTap: () {
          _hideMenu();
          _showReportDialog();
        },
        isDestructive: false,
      ));
    }
    
    if (widget.onBlock != null) {
      menuItems.add(_buildMenuItem(
        icon: SolarIconsOutline.dangerCircle,
        label: '차단하기',
        onTap: () {
          _hideMenu();
          _handleBlockUser();
        },
        isDestructive: false,
      ));
    }
    
    if (widget.onDelete != null && widget.showDelete) {
      menuItems.add(_buildMenuItem(
        icon: SolarIconsOutline.trashBinMinimalistic,
        label: '삭제하기',
        onTap: () {
          _hideMenu();
          widget.onDelete?.call();
        },
        isDestructive: true,
      ));
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: 140.0,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.12),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.15),
                    blurRadius: 16.0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: menuItems,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDestructive,
  }) {
    final theme = Theme.of(context);
    
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          height: 48.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20.0,
                color: isDestructive 
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Pretendard',
                    color: isDestructive 
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Semantics(
      label: '게시물 메뉴 열기',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: _menuKey,
          onTap: _toggleMenu,
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Icon(
              SolarIconsOutline.menuDots,
              size: 20.0,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  void _showReportDialog() {
    showReportDialog(
      context: context,
      onReport: (reason) async {
        try {
          // 실제 신고 처리 로직
          final repository = CommunityRepository.instance;
          await repository.reportPost(
            postId: widget.postId,
            reportReason: reason.name, // enum name을 문자열로 변환
            reportDetails: null,
          );
          
          // 성공 후 사용자 정의 콜백 호출 (있는 경우)
          widget.onReport?.call(reason);
          
        } catch (e) {
          // 에러를 다시 throw하여 ReportDialog에서 로딩 해제
          rethrow;
        }
      },
    );
  }

  void _handleBlockUser() async {
    if (widget.reportedUserId == null) return; // 익명 사용자는 차단 불가
    
    try {
      final repository = CommunityRepository.instance;
      await repository.blockUser(
        blockedUserId: widget.reportedUserId!,
        reason: 'manual_block',
      );
      
      // 성공 토스트 표시
      if (mounted) {
        showGlobalToast(
          title: '차단 완료',
          message: '사용자를 차단했습니다.',
          backgroundColor: Theme.of(context).colorScheme.warning,
        );
      }
      
      // 성공 후 사용자 정의 콜백 호출
      widget.onBlock?.call();
      
    } catch (e) {
      if (mounted) {
        showGlobalToast(
          title: '차단 실패',
          message: '차단에 실패했습니다.',
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
      print('Failed to block user: $e');
    }
  }
}
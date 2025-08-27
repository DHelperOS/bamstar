import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive_utils.dart';

// Enhanced social auth button with responsive design capabilities
enum ButtonType { apple, google, facebook, kakao }

class ResponsiveSocialAuthButton extends StatelessWidget {
  final ButtonType type;
  final VoidCallback onPressed;
  final String? customText;
  final bool isCompact; // For two-column layout

  const ResponsiveSocialAuthButton({
    super.key,
    required this.type,
    required this.onPressed,
    this.customText,
    this.isCompact = false,
  });

  factory ResponsiveSocialAuthButton.apple({
    Key? key, 
    required VoidCallback onPressed,
    bool isCompact = false,
  }) => ResponsiveSocialAuthButton(
    key: key, 
    type: ButtonType.apple, 
    onPressed: onPressed,
    isCompact: isCompact,
  );

  factory ResponsiveSocialAuthButton.google({
    Key? key,
    required VoidCallback onPressed,
    bool isCompact = false,
  }) => ResponsiveSocialAuthButton(
    key: key, 
    type: ButtonType.google, 
    onPressed: onPressed,
    isCompact: isCompact,
  );

  factory ResponsiveSocialAuthButton.facebook({
    Key? key,
    required VoidCallback onPressed,
    bool isCompact = false,
  }) => ResponsiveSocialAuthButton(
    key: key,
    type: ButtonType.facebook,
    onPressed: onPressed,
    isCompact: isCompact,
  );

  factory ResponsiveSocialAuthButton.kakao({
    Key? key, 
    required VoidCallback onPressed,
    bool isCompact = false,
  }) => ResponsiveSocialAuthButton(
    key: key, 
    type: ButtonType.kakao, 
    onPressed: onPressed,
    isCompact: isCompact,
  );

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final minHeight = isMobile ? 56.0 : 60.0;
    final horizontalPadding = isMobile ? 16.0 : 20.0;
    final borderRadius = isMobile ? 12.0 : 14.0;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(minHeight),
          backgroundColor: _getButtonColor(),
          foregroundColor: _getTextColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          side: type == ButtonType.google
              ? BorderSide(
                  color: Theme.of(context).colorScheme.outline, 
                  width: 1,
                )
              : BorderSide.none,
          elevation: ResponsiveUtils.isDesktop(context) ? 1 : 0,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        ),
        child: _buildButtonContent(context),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final iconSize = isMobile ? 24.0 : 26.0;
    final iconContainerSize = isMobile ? 36.0 : 40.0;
    
    if (isCompact) {
      // Compact layout - icon only or minimal text
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconContainer(iconSize, iconContainerSize),
          if (!ResponsiveUtils.isMobile(context)) ...[
            const SizedBox(width: 8),
            Text(
              _getCompactText(),
              style: AppTextStyles.buttonText(context).copyWith(
                fontWeight: FontWeight.w500,
                color: _getTextColor(),
                fontSize: 14,
              ),
            ),
          ],
        ],
      );
    } else {
      // Standard layout
      return Stack(
        alignment: Alignment.center,
        children: [
          // Left icon
          Positioned(
            left: 12, 
            child: _buildIconContainer(iconSize, iconContainerSize),
          ),
          // Centered text
          Center(
            child: Text(
              customText ?? _getDefaultButtonText(),
              style: ResponsiveUtils.getResponsiveTextStyle(
                context,
                AppTextStyles.buttonText(context).copyWith(
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(),
                ),
                tabletScale: 1.05,
                desktopScale: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }
  }

  Color _getButtonColor() {
    switch (type) {
      case ButtonType.apple:
        return Colors.black;
      case ButtonType.google:
        return Colors.white;
      case ButtonType.facebook:
        return const Color(0xFF1877F2);
      case ButtonType.kakao:
        return const Color(0xFFFFE812);
    }
  }

  Color _getTextColor() {
    switch (type) {
      case ButtonType.apple:
      case ButtonType.facebook:
        return Colors.white;
      case ButtonType.google:
      case ButtonType.kakao:
        return Colors.black87;
    }
  }

  Widget _buildIconContainer(double iconSize, double containerSize) {
    return Container(
      width: containerSize,
      height: containerSize,
      alignment: Alignment.center,
      child: _buildIcon(iconSize),
    );
  }

  Widget _buildIcon(double iconSize) {
    switch (type) {
      case ButtonType.apple:
        return Image.asset(
          'assets/images/icon/apple.png',
          height: iconSize,
          width: iconSize,
          fit: BoxFit.contain,
          color: Colors.white,
          colorBlendMode: BlendMode.srcIn,
        );
      case ButtonType.google:
        return Image.asset(
          'assets/images/icon/google.png',
          height: iconSize,
          width: iconSize,
          fit: BoxFit.contain,
        );
      case ButtonType.facebook:
        return SizedBox(
          width: iconSize, 
          height: iconSize,
        );
      case ButtonType.kakao:
        return Image.asset(
          'assets/images/icon/kakaotalk.png',
          height: iconSize,
          width: iconSize,
          fit: BoxFit.contain,
        );
    }
  }

  String _getDefaultButtonText() {
    switch (type) {
      case ButtonType.apple:
        return '애플 로그인';
      case ButtonType.google:
        return '구글 로그인';
      case ButtonType.facebook:
        return 'Facebook으로 계속하기';
      case ButtonType.kakao:
        return '카카오톡 로그인';
    }
  }

  String _getCompactText() {
    switch (type) {
      case ButtonType.apple:
        return 'Apple';
      case ButtonType.google:
        return 'Google';
      case ButtonType.facebook:
        return 'Facebook';
      case ButtonType.kakao:
        return 'KakaoTalk';
    }
  }
}
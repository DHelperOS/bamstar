/*
A comprehensive social authentication button widget that supports multiple providers(Apple, Google, Facebook) with brand-specific styling.

Common use cases:
1. Social login/signup flows
2. Account linking interfaces
3. Social sharing features
4. OAuth authentication implementations
*/

import 'package:flutter/material.dart';

// Enum defining the types of buttons supported
enum ButtonType { apple, google, facebook, kakao }

class SocialAuthButton extends StatelessWidget {
  final ButtonType type;
  final VoidCallback onPressed;
  final String? customText; // Optional text override

  const SocialAuthButton({
    super.key,
    required this.type,
    required this.onPressed,
    this.customText,
  });

  factory SocialAuthButton.apple({Key? key, required VoidCallback onPressed}) =>
      SocialAuthButton(key: key, type: ButtonType.apple, onPressed: onPressed);

  factory SocialAuthButton.google({
    Key? key,
    required VoidCallback onPressed,
  }) =>
      SocialAuthButton(key: key, type: ButtonType.google, onPressed: onPressed);

  factory SocialAuthButton.facebook({
    Key? key,
    required VoidCallback onPressed,
  }) => SocialAuthButton(
    key: key,
    type: ButtonType.facebook,
    onPressed: onPressed,
  );

  factory SocialAuthButton.kakao({Key? key, required VoidCallback onPressed}) =>
      SocialAuthButton(key: key, type: ButtonType.kakao, onPressed: onPressed);

  @override
  Widget build(BuildContext context) {
    // Fixed height, left-aligned icon and centered label to match the design spec
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(
            56,
          ), // consistent large tappable area
          backgroundColor: _getButtonColor(),
          foregroundColor: _getTextColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: type == ButtonType.google
              ? BorderSide(color: Colors.grey.shade300, width: 1)
              : BorderSide.none,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left icon
            Positioned(left: 12, child: _buildIconContainer()),

            // Centered text
            Center(
              child: Text(
                customText ?? _getDefaultButtonText(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: _getTextColor(),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Only relevant for social buttons
  // Provider name helper removed — replaced by localized _getDefaultButtonText().

  Color _getButtonColor() {
    switch (type) {
      case ButtonType.apple:
        return Colors.black;
      case ButtonType.google:
        // Using white for Google button background as is common
        return Colors.white;
      case ButtonType.facebook:
        return const Color(0xFF1877F2); // Facebook blue
      case ButtonType.kakao:
        // Kakao signature yellow
        return const Color(0xFFFFE812);
    }
  }

  Color _getTextColor() {
    switch (type) {
      case ButtonType.apple:
        return Colors.white;
      case ButtonType.facebook:
        return Colors.white;
      case ButtonType.google:
        return Colors.black87;
      case ButtonType.kakao:
        return Colors.black87;
    }
  }

  // Returns the icon widget or an empty box
  Widget _buildIconContainer() {
    const double iconSize = 24.0;
    // Small fixed-size icon area to the left of the text
    switch (type) {
      case ButtonType.apple:
        return Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/icon/apple.png',
            height: iconSize,
            width: iconSize,
            fit: BoxFit.contain,
            color: type == ButtonType.apple ? Colors.white : null,
            colorBlendMode: BlendMode.srcIn,
          ),
        );
      case ButtonType.google:
        return Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/icon/google.png',
            height: iconSize,
            width: iconSize,
            fit: BoxFit.contain,
          ),
        );
      case ButtonType.facebook:
        return const SizedBox(width: 36, height: 36); // no icon asset bundled
      case ButtonType.kakao:
        return Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/icon/kakaotalk.png',
            height: iconSize,
            width: iconSize,
            fit: BoxFit.contain,
          ),
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
}

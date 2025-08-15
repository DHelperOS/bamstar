/*
A comprehensive social authentication button widget that supports multiple providers(Apple, Google, Facebook) with brand-specific styling.

Common use cases:
1. Social login/signup flows
2. Account linking interfaces
3. Social sharing features
4. OAuth authentication implementations
*/

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Enum defining the types of buttons supported
enum ButtonType { apple, google, facebook }

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: double.infinity,

          child: FilledButton(
            onPressed: onPressed,

            style: FilledButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300, width: 1),

              /// The button should be rounded. Don't change the borderRadius.
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(60),
              ),
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              backgroundColor: _getButtonColor(),
              foregroundColor: _getTextColor(),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(left: 0, child: _getIcon(24.0)),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    // Use custom text first, then provider name, then default
                    customText ?? 'Continue with ${_getProviderName()}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Only relevant for social buttons
  String _getProviderName() {
    switch (type) {
      case ButtonType.apple:
        return 'Apple';
      case ButtonType.google:
        return 'Google';
      case ButtonType.facebook:
        return 'Facebook';
    }
  }

  Color _getButtonColor() {
    switch (type) {
      case ButtonType.apple:
        return Colors.white;
      case ButtonType.google:
        // Using white for Google button background as is common
        return Colors.white;
      case ButtonType.facebook:
        return Colors.white; // Facebook blue
    }
  }

  Color _getTextColor() {
    switch (type) {
      case ButtonType.apple:
      case ButtonType.facebook:
      case ButtonType.google:
        return Colors.black87;
    }
  }

  // Returns the icon widget or an empty box
  Widget _getIcon(double size) {
    switch (type) {
      case ButtonType.apple:
        // Using FontAwesome for consistency, but could use Icons.apple
        return FaIcon(
          FontAwesomeIcons.apple,
          size: size,
          color: _getTextColor(),
        );
      case ButtonType.google:
        return Image.network(
          'https://img.icons8.com/?size=100&id=17949&format=png',
          height: size,
          width: size,
        );
      case ButtonType.facebook:
        // Using FontAwesome's Facebook icon
        return FaIcon(
          FontAwesomeIcons.facebookF,
          size: size,
          color: Colors.blue,
        ); // Use F logo
    }
  }
}

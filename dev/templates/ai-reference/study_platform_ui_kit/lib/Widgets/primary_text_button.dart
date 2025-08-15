/*
A versatile primary button widget that spans the full width of its container with customizable text and state handling.
Common use cases:
1. Form submission buttons
2. Primary action buttons in workflows
3. Confirmation dialogs
4. Call-to-action buttons in key user flows
*/

import 'package:flutter/material.dart';

class PrimaryTextButton extends StatelessWidget {
  final Function()? onPressed;
  final String text;
  const PrimaryTextButton({
    super.key,
    this.text = "Submit",
    this.onPressed = _defaultOnPressed,
  });
  static void _defaultOnPressed() {}

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          /// The button should be rounded. Don't change the borderRadius.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

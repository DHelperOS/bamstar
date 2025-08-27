import 'package:flutter/material.dart';

class PrimaryTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryTextButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

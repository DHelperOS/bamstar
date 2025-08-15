import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Reusable widget for a menu item with a leading widget (icon or custom icon container) and text
class MenuItemTile extends StatelessWidget {
  final Widget leadingWidget; // Changed from IconData icon to Widget leadingWidget
  final String text;
  final Widget? trailing; // Optional trailing widget, e.g., a Switch or arrow
  final VoidCallback? onTap;
  final bool isGreyedOut; // For disabled appearance
  final Color? textColor; // Optional custom text color
  final double? fontSize; // Optional custom font size

  const MenuItemTile({
    Key? key,
    required this.leadingWidget, // Updated parameter name
    required this.text,
    this.trailing,
    this.onTap,
    this.isGreyedOut = false,
    this.textColor,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0), // Slightly reduced vertical padding for tighter list as in image
        child: Row(
          children: [
            leadingWidget, // Use the provided leading widget
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: fontSize ?? 16,
                  color: textColor ?? (isGreyedOut ? Colors.grey[400] : Colors.black),
                  fontWeight: FontWeight.w500, // Semi-bold for menu items
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

// Helper widget to create the circular icon with pink background
class CircularIconBackground extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double radius;
  final double iconSize;

  const CircularIconBackground({
    Key? key,
    required this.icon,
    required this.backgroundColor,
    this.iconColor = Colors.white,
    this.radius = 24, // Default radius for consistency
    this.iconSize = 24, // Default icon size
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/components/menu_item_tile.dart';
import 'package:socialPixel/screens/follow_someone_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkThemeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.black, // Explicitly black as per UIKit
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700, // Bold as per existing app bars
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: false, // Align title to the left
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MenuItemTile(
              leadingWidget: const Icon(
                Icons.person_add_alt_1_outlined,
                size: 24,
                color: Colors.black,
              ),
              text: 'Follow and Invite Friends',
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => FollowSomeoneScreen(),
                  ),
                );
              },
            ),
            MenuItemTile(
              leadingWidget: const Icon(
                Icons.notifications_none_outlined,
                size: 24,
                color: Colors.black,
              ),
              text: 'Notifications',
              onTap: () {},
            ),
            MenuItemTile(
              leadingWidget: const Icon(
                Icons.lock_outline,
                size: 24,
                color: Colors.black,
              ),
              text: 'Privacy',
              onTap: () {},
            ),
            MenuItemTile(
              leadingWidget: const Icon(
                Icons.verified_user_outlined,
                size: 24,
                color: Colors.black,
              ),
              text: 'Security',
              onTap: () {},
            ),
            MenuItemTile(
              leadingWidget: const Icon(
                Icons.insights_outlined,
                size: 24,
                color: Colors.black,
              ),
              text: 'Ads',
              onTap: () {},
            ),
            MenuItemTile(
              leadingWidget: const Icon(
                Icons.person_outline,
                size: 24,
                color: Colors.black,
              ),
              text: 'Account',
              onTap: () {},
            ),
            MenuItemTile(
              leadingWidget: const Icon(
                Icons.info_outline,
                size: 24,
                color: Colors.black,
              ),
              text: 'Help',
              onTap: () {},
            ),
            MenuItemTile(
              leadingWidget: const Icon(
                Icons.warning_amber_outlined,
                size: 24,
                color: Colors.black,
              ),
              text: 'About',
              onTap: () {},
            ),
            MenuItemTile(
              leadingWidget: const Icon(
                Icons.remove_red_eye_outlined,
                size: 24,
                color: Colors.black,
              ),
              text: 'Dark Theme',
              trailing: Switch(
                value: _isDarkThemeEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isDarkThemeEnabled = value;
                  });
                },
                activeTrackColor:
                    primaryColor, // Set activeTrackColor to primaryColor
                activeColor: Colors.white, // Set activeColor to white
              ),
              onTap: () {
                setState(() {
                  _isDarkThemeEnabled = !_isDarkThemeEnabled;
                });
              },
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero, // Remove default padding
                alignment: Alignment.centerLeft, // Align text to left
                foregroundColor: primaryColor, // Blue color as per image
              ),
              child: Text(
                'Add or Switch Account',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500, // Semi-bold for menu items
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                foregroundColor: primaryColor,
              ),
              child: Text(
                'Logout john_doe',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                foregroundColor: primaryColor,
              ),
              child: Text(
                'Logout All Accounts',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20), // Padding at bottom
          ],
        ),
      ),
    );
  }
}

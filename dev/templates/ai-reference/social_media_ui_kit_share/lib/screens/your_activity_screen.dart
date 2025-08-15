import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/components/menu_item_tile.dart';
import 'package:socialPixel/screens/explore_saved_screen.dart'; // Import the reusable MenuItemTile

class YourActivityScreen extends StatelessWidget {
  const YourActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Defined explicitly as per the image's pink circles, this is buttonPink from main.dart

    const Color arrowColor =
        Colors.grey; // The arrows in the image are grey, not pink.
    final Color primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Back arrow icon
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.black, // Set icon color to black explicitly
        ),
        title: Text(
          'Your Activity',
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
              leadingWidget: CircularIconBackground(
                icon: Icons.timer_outlined, // Time Spent icon
                backgroundColor: primaryColor,
              ),
              text: 'Time Spent',
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: arrowColor,
              ),
              onTap: () {},
            ),
            const SizedBox(height: 8), // Spacing between items
            MenuItemTile(
              leadingWidget: CircularIconBackground(
                icon: Icons.image_outlined, // Photos and Videos icon
                backgroundColor: primaryColor,
              ),
              text: 'Photos and Videos',
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: arrowColor,
              ),
              onTap: () {},
            ),
            const SizedBox(height: 8),
            MenuItemTile(
              leadingWidget: CircularIconBackground(
                icon: Icons.sync_alt, // Interactions icon (two-way arrow)
                backgroundColor: primaryColor,
              ),
              text: 'Interactions',
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: arrowColor,
              ),
              onTap: () {},
            ),
            const SizedBox(height: 8),
            MenuItemTile(
              leadingWidget: CircularIconBackground(
                icon: Icons.calendar_today_outlined, // Account History icon
                backgroundColor: primaryColor,
              ),
              text: 'Account History',
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: arrowColor,
              ),
              onTap: () {},
            ),
            const SizedBox(height: 8),
            MenuItemTile(
              leadingWidget: CircularIconBackground(
                icon: Icons.search, // Recent Search icon
                backgroundColor: primaryColor,
              ),
              text: 'Recent Search',
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: arrowColor,
              ),
              onTap: () {},
            ),
            const SizedBox(height: 8),
            MenuItemTile(
              leadingWidget: CircularIconBackground(
                icon:
                    Icons
                        .link, // Link You've Visited icon (using generic link icon)
                backgroundColor: primaryColor,
              ),
              text: 'Link You\'ve Visited',
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: arrowColor,
              ),
              onTap: () {},
            ),
            const SizedBox(height: 8),
            MenuItemTile(
              leadingWidget: CircularIconBackground(
                icon: Icons.archive_outlined, // Archived icon
                backgroundColor: primaryColor,
              ),
              text: 'Archived',
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: arrowColor,
              ),
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ExploreSavedScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            MenuItemTile(
              leadingWidget: CircularIconBackground(
                icon: Icons.delete_outline, // Recently Deleted icon
                backgroundColor: primaryColor,
              ),
              text: 'Recently Deleted',
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: arrowColor,
              ),
              onTap: () {},
            ),
            const SizedBox(height: 8),
            MenuItemTile(
              leadingWidget: CircularIconBackground(
                icon: Icons.download_outlined, // Download Your Information icon
                backgroundColor: primaryColor,
              ),
              text: 'Download Your Information',
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: arrowColor,
              ),
              onTap: () {},
            ),
            const SizedBox(height: 20), // Padding at bottom
          ],
        ),
      ),
    );
  }
}

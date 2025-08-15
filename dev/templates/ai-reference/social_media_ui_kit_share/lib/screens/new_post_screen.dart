import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/components/menu_item_tile.dart'; // Import the new MenuItemTile

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  bool _facebookShare = true;
  bool _twitterShare = false;
  bool _tumblrShare = false;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        title: Text(
          'New Post',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.send_outlined,
              color: primaryColor,
            ), // Paper plane icon, primary color
            onPressed: () {
              // Handle send post action
            },
          ),
        ],
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(
                    'https://picsum.photos/100/100?random=1',
                  ), // Current user avatar
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6F7), // Light grey background
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Write a caption...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.zero, // Remove default content padding
                        isDense: true, // Make text field more compact
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      maxLines: null, // Allows multiline input
                      minLines: 3, // Minimum lines for the text field
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://picsum.photos/100/100?random=19', // Placeholder for post image
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, color: Colors.grey[600]),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 8),
            MenuItemTile(
              leadingWidget: Icon(
                Icons.person_add_alt_1_outlined,
              ), // Person icon for Tag People
              text: 'Tag People',
              onTap: () {
                // Handle tag people
              },
            ),
            Divider(color: Colors.grey[200], height: 1),
            MenuItemTile(
              leadingWidget: Icon(
                Icons.location_on_outlined,
              ), // Location icon for Add Location
              text: 'Add Location',
              onTap: () {
                // Handle add location
              },
            ),
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 24),

            Text(
              'Also post to',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            MenuItemTile(
              leadingWidget: Icon(
                Icons.facebook,
              ), // Using generic icon, can be replaced by actual Facebook icon
              text: 'Facebook',
              isGreyedOut: !_facebookShare, // Grey out if switch is off
              trailing: Switch(
                value: _facebookShare,
                onChanged: (bool value) {
                  setState(() {
                    _facebookShare = value;
                  });
                },
                activeTrackColor: primaryColor,
                activeColor: Colors.white,
              ),
            ),
            Divider(color: Colors.grey[200], height: 1),
            MenuItemTile(
              leadingWidget: Icon(
                Icons.alternate_email,
              ), // Using generic icon for Twitter
              text: 'Twitter',
              isGreyedOut: !_twitterShare,
              trailing: Switch(
                value: _twitterShare,
                onChanged: (bool value) {
                  setState(() {
                    _twitterShare = value;
                  });
                },
                activeTrackColor: primaryColor,
                activeColor: Colors.white,
              ),
            ),
            Divider(color: Colors.grey[200], height: 1),
            MenuItemTile(
              leadingWidget: Icon(Icons.share), // Using generic icon for Tumblr
              text: 'Tumblr',
              isGreyedOut: !_tumblrShare,
              trailing: Switch(
                value: _tumblrShare,
                onChanged: (bool value) {
                  setState(() {
                    _tumblrShare = value;
                  });
                },
                activeTrackColor: primaryColor,
                activeColor: Colors.white,
              ),
            ),
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 24),

            MenuItemTile(
              leadingWidget: Icon(Icons.settings_outlined), // Settings icon
              text: 'Advanced Settings',
              onTap: () {
                // Handle advanced settings
              },
            ),
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 20), // Padding at bottom
          ],
        ),
      ),
    );
  }
}

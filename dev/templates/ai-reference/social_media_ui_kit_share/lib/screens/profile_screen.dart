import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // Import dart:io for File class

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> tabs = ['Feeds', 'Shorts', 'Tag'];

  // Placeholder for profile image file
  // This would typically be a File object from image_picker, or null/default
  String? _profileImageUrl = 'https://picsum.photos/200/200?random=41';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Function to show the image selection dialog
  void _showImagePickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(
                  'Capture from Camera',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(bc); // Close the bottom sheet
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(
                  'Pick from Gallery',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(bc); // Close the bottom sheet
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10), // Add some space at the bottom
            ],
          ),
        );
      },
    );
  }

  // Function to pick image using image_picker
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _profileImageUrl =
              image
                  .path; // Update image URL with local path (or upload and use URL)
        });
        // In a real app, you'd upload this image to a server and update the profile with the returned URL.
      } else {}
    } catch (e) {
      // Handle permission issues or other errors
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    // Dummy data for highlights
    final List<Map<String, dynamic>> highlights = [
      {
        'name': 'Hangout',
        'imageUrl': 'https://picsum.photos/100/100?random=27',
      },
      {
        'name': 'New Year',
        'imageUrl': 'https://picsum.photos/100/100?random=28',
      },
      {
        'name': 'Friends',
        'imageUrl': 'https://picsum.photos/100/100?random=29',
      },
      {'name': 'Beach', 'imageUrl': 'https://picsum.photos/100/100?random=30'},
      {'name': 'Work', 'imageUrl': 'https://picsum.photos/100/100?random=31'},
    ];

    // Dummy data for content grid
    final List<String> contentImages = [
      'https://picsum.photos/200/200?random=32',
      'https://picsum.photos/200/200?random=33',
      'https://picsum.photos/200/200?random=34',
      'https://picsum.photos/200/200?random=35',
      'https://picsum.photos/200/200?random=36',
      'https://picsum.photos/200/200?random=37',
      'https://picsum.photos/200/200?random=38',
      'https://picsum.photos/200/200?random=39',
      'https://picsum.photos/200/200?random=40',
    ];

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'julia_adaline',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700, // Bold for username
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: Colors.black,
            ), // Three dots menu icon
            onPressed: () {
              // Handle menu action
            },
          ),
        ],
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        // Changed to single scroll view for entire body
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Avatar and Edit Icon
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60, // Larger avatar
                        backgroundImage:
                            _profileImageUrl!.startsWith('http')
                                ? NetworkImage(_profileImageUrl!)
                                    as ImageProvider
                                : FileImage(
                                  File(_profileImageUrl!),
                                ), // Use FileImage for local paths
                        backgroundColor: Colors.grey[300],
                      ),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          // Wrapped with GestureDetector
                          onTap:
                              () => _showImagePickerDialog(
                                context,
                              ), // Call dialog on tap
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  primaryColor, // Use primary color for edit icon background
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ), // White border
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.edit, // Edit icon
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Julia Adaline',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Photographer',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'www.yourdomain.com',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('267', 'Posts'),
                      _buildStatColumn('24,278', 'Followers'),
                      _buildStatColumn('237', 'Following'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Handle follow
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const FaIcon(
                            FontAwesomeIcons.userPlus,
                            size: 18,
                          ),
                          label: Text(
                            'Follow',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Handle message
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const FaIcon(
                            FontAwesomeIcons.commentDots,
                            size: 18,
                          ),
                          label: Text(
                            'Message',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Highlights/Stories Section
                  SizedBox(
                    height: 90, // Height for circular images and text
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: highlights.length,
                      itemBuilder: (context, index) {
                        final highlight = highlights[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30, // Size of highlight circle
                                backgroundImage: NetworkImage(
                                  highlight['imageUrl'],
                                ),
                                backgroundColor: Colors.grey[300],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                highlight['name'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Tab Navigation
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: primaryColor,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                indicatorPadding: EdgeInsets.zero,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey[600],
                indicatorSize: TabBarIndicatorSize.label,
                overlayColor: WidgetStateProperty.resolveWith<Color?>((
                  Set<WidgetState> states,
                ) {
                  if (states.contains(WidgetState.pressed)) {
                    return primaryColor.withValues(alpha: 0.1); // Ripple color
                  }
                  return null; // Defer to the widget's default.
                }),
                tabs:
                    List.generate(tabs.length, (index) {
                      final t = tabs[index];
                      return Tab(
                        icon: Icon(_getTabIcon(t), size: 20),
                        child: Text(
                          t,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            // Content Grid based on Tabs
            SizedBox(
              // Give a constrained height to TabBarView when inside SingleChildScrollView
              height:
                  400, // Adjust this height as needed, or make it dynamic based on content
              child: TabBarView(
                controller: _tabController,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable TabBarView's own scrolling
                children:
                    tabs.map((tab) {
                      // For simplicity, all tabs show the same image grid
                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1.0,
                            ),
                        itemCount: contentImages.length,
                        itemBuilder: (context, index) {
                          return ImageGridItem(imageUrl: contentImages[index]);
                        },
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build stat columns
  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Helper to get tab icons
  IconData _getTabIcon(String tabName) {
    switch (tabName) {
      case 'Feeds':
        return Icons
            .grid_on_outlined; // Or FaIcon(FontAwesomeIcons.gripfire) if available
      case 'Shorts':
        return Icons.play_arrow; // Or FaIcon(FontAwesomeIcons.play)
      case 'Tag':
        return Icons.bookmark_border; // Or FaIcon(FontAwesomeIcons.bookmark)
      default:
        return Icons.help_outline;
    }
  }
}

// Reusing CustomChip from UIKit
class CustomChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final double height;
  final Color selectedColor;
  final Color selectedTextColor;
  final Color unselectedColor;
  final Color unselectedTextColor;

  const CustomChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    required this.height,
    required this.selectedColor,
    required this.selectedTextColor,
    required this.unselectedColor,
    required this.unselectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      splashColor:
          isSelected
              ? selectedTextColor.withValues(alpha: 0.3)
              : unselectedTextColor.withValues(alpha: 0.3),
      highlightColor:
          isSelected
              ? selectedTextColor.withValues(alpha: 0.1)
              : unselectedTextColor.withValues(alpha: 0.1),

      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              // Using PlusJakartaSans
              color: isSelected ? selectedTextColor : unselectedTextColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

// Reusable widget for image grid item (for Posts)
class ImageGridItem extends StatelessWidget {
  final String imageUrl;

  const ImageGridItem({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8), // Rounded corners
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle image tap
          },
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder:
                (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, color: Colors.grey[600]),
                ),
          ),
        ),
      ),
    );
  }
}

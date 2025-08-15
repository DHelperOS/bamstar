import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialPixel/components/custom_appbar.dart';
import 'package:socialPixel/components/search_field.dart';
import 'package:socialPixel/screens/add_story_screen.dart';
import 'package:socialPixel/screens/comment_section_screen.dart';
import 'package:socialPixel/screens/new_post_gallery_screen.dart';

import 'package:socialPixel/screens/story_viewer_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late PageController _pageController; // PageController for PageView

  // List of screens for each tab
  final List<Widget> _screens = [
    const FeedScreen(),
    const NavSearchScreen(), // Use the existing NavSearchScreen
    const NewPostGalleryScreen(), // Assuming this is the screen for the '+' button
    const NavShortsScreen(), // Use the existing NavShortsScreen
    const NavProfileScreen(), // Use the existing NavProfileScreen
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    // Determine nav bar background and inactive color based on screen
    final bool isShortsScreen = _selectedIndex == 3;
    final Color navBarColor = isShortsScreen ? Colors.black : Colors.white;
    final Color inactiveIconColor =
        isShortsScreen ? Colors.white : Colors.grey[700]!;

    return Scaffold(
      backgroundColor: isShortsScreen ? Colors.black : Colors.white,
      appBar:
          _selectedIndex == 0
              ? const CustomAppbar2()
              : null, // Only show AppBar for FeedScreen
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: navBarColor,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(
                0,
                Icons.home,
                'Home',
                primaryColor,
                inactiveIconColor,
              ),
              _buildNavItem(
                1,
                Icons.search,
                'Search',
                primaryColor,
                inactiveIconColor,
              ),
              _buildPlusButton(primaryColor),
              _buildNavItem(
                3,
                Icons.play_circle_outline,
                'Shorts',
                primaryColor,
                inactiveIconColor,
              ),
              _buildNavItem(
                4,
                Icons.person_outline,
                'Profile',
                primaryColor,
                inactiveIconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color activeColor,
    Color inactiveColor,
  ) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(index),
          borderRadius: BorderRadius.circular(20), // Circular border radius
          splashColor: activeColor.withValues(
            alpha: 0.2,
          ), // Custom splash color
          highlightColor: activeColor.withValues(
            alpha: 0.1,
          ), // Custom highlight color
          hoverColor: activeColor.withValues(alpha: 0.08), // Custom hover color
          radius: 50, // Splash radius for circular effect
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? activeColor : inactiveColor,
                  size: 24,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlusButton(Color primaryColor) {
    final bool isSelected = _selectedIndex == 2;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onItemTapped(2),
            borderRadius: BorderRadius.circular(22), // Circular border radius
            splashColor: Colors.white.withValues(
              alpha: 0.3,
            ), // White splash on colored background
            highlightColor: Colors.white.withValues(
              alpha: 0.2,
            ), // White highlight
            hoverColor: Colors.white.withValues(
              alpha: 0.1,
            ), // White hover effect
            radius: 50, // Splash radius matching button size
            child: Container(
              width: 44,
              height: 64,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? primaryColor.withValues(alpha: 0.8)
                        : primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }

  // Simplified _onItemTapped method
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

// Updated FeedScreen - Remove navigation logic and app bar
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    // Dummy data for stories
    final List<Map<String, dynamic>> stories = [
      {
        'imageUrl': 'https://picsum.photos/100/100?random=1',
        'username': 'You',
        'isYou': true,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=2',
        'username': 'Julia',
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=3',
        'username': 'Andrew',
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=4',
        'username': 'Jenny',
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=5',
        'username': 'Robert',
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=6',
        'username': 'Alice',
      },
    ];

    // Dummy data for feed posts
    final List<Map<String, dynamic>> posts = [
      {
        'userImageUrl': 'https://picsum.photos/100/100?random=7',
        'username': 'anny_wilson',
        'profession': 'Marketing Coordinator',
        'postImageUrl': 'https://picsum.photos/400/400?random=8',
        'likes': 44389,
        'comments': 26376,
        'postDescription':
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
      },
      {
        'userImageUrl': 'https://picsum.photos/100/100?random=9',
        'username': 'hime_tanuki',
        'profession': 'Web Designer',
        'postImageUrl': 'https://picsum.photos/400/400?random=10',
        'likes': 12345,
        'comments': 5678,
        'postDescription': 'Beautiful day outside! Enjoying the moment.',
      },
      {
        'userImageUrl': 'https://picsum.photos/100/100?random=11',
        'username': 'john_doe',
        'profession': 'Software Engineer',
        'postImageUrl': 'https://picsum.photos/400/400?random=12',
        'likes': 7890,
        'comments': 1234,
        'postDescription': 'Coding away! Building new things.',
      },
    ];

    return Column(
      children: [
        // Stories Section
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return _StoryAvatar(
                imageUrl: story['imageUrl'],
                username: story['username'],
                isYou: story['isYou'] ?? false,
              );
            },
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF4F6F7)),
        // Feed Posts
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _FeedPostCard(
                userImageUrl: post['userImageUrl'],
                username: post['username'],
                profession: post['profession'],
                postImageUrl: post['postImageUrl'],
                initialLikes: post['likes'],
                initialComments: post['comments'],
                postDescription: post['postDescription'],
              );
            },
          ),
        ),
      ],
    );
  }
}

// Search Screen
class NavSearchScreen extends StatefulWidget {
  const NavSearchScreen({super.key});

  @override
  State<NavSearchScreen> createState() => _NavSearchScreenState();
}

class _NavSearchScreenState extends State<NavSearchScreen> {
  int _selectedFilterIndex = 0; // 'Trending' selected by default

  final List<String> _filterChips = [
    'Trending',
    'Discover',
    'Posts',
    'Shorts',
    'Accounts',
    'Sounds',
    'Locations',
  ];

  void _onFilterChipTapped(int index) {
    setState(() {
      _selectedFilterIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    // Dummy data for image grid
    final List<Map<String, dynamic>> gridItems = [
      {'imageUrl': 'https://picsum.photos/200/300?random=1', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=2', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=3', 'isVideo': true},
      {'imageUrl': 'https://picsum.photos/200/300?random=4', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=5', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=6', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=7', 'isVideo': true},
      {'imageUrl': 'https://picsum.photos/200/300?random=8', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=9', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=10', 'isVideo': true},
      {'imageUrl': 'https://picsum.photos/200/300?random=11', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=12', 'isVideo': false},
    ];

    return Scaffold(
      appBar: AppBar(
        // Empty app bar as per image for a full-bleed search screen
        toolbarHeight: 0, // No height for the toolbar
        elevation: 0,
        backgroundColor: Colors.transparent, // Fully transparent
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchTextField3(controller: TextEditingController()),
          ),
          // Filter Chips
          SizedBox(
            height: 40, // Height for the chips
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _filterChips.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: CustomChip(
                    label: _filterChips[index],
                    isSelected: _selectedFilterIndex == index,
                    onTap: () => _onFilterChipTapped(index),
                    selectedColor:
                        primaryColor, // Use primaryColor for selected chip
                    selectedTextColor: Colors.white,
                    unselectedColor: Colors.white,
                    unselectedTextColor: Colors.black,
                    borderColor:
                        Colors.grey[300]!, // Light grey border for unselected
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16), // Space between chips and grid
          // Image Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero, // Removed padding
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio:
                    0.75, // Further reduced aspect ratio to make images even taller
              ),
              itemCount: gridItems.length,
              itemBuilder: (context, index) {
                final item = gridItems[index];
                return _SearchGridItem(
                  imageUrl: item['imageUrl'],
                  isVideo: item['isVideo'],
                );
              },
            ),
          ),
        ],
      ),
      // Removed floatingActionButton and floatingActionButtonLocation
    );
  }
}

// Reusing CustomSearchTextField from earlier tasks
class CustomSearchTextField extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;

  const CustomSearchTextField({
    super.key,
    this.hintText = 'Search',
    this.onTap,
    this.readOnly = false,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF4F6F7,
        ), // Lighter grey background as per UIKit template
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.plusJakartaSans(
            color: Colors.grey,
            fontSize: 16,
          ),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// Reusing CustomChip from NavProfileScreen or other UIKit components
class CustomChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final double height;
  final Color selectedColor;
  final Color selectedTextColor;
  final Color unselectedColor;
  final Color unselectedTextColor;
  final Color borderColor; // Added for outlined look when unselected

  const CustomChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.height = 36.0, // Default height as seen in image
    required this.selectedColor,
    required this.selectedTextColor,
    required this.unselectedColor,
    required this.unselectedTextColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color:
                isSelected
                    ? Colors.transparent
                    : borderColor, // Transparent border when selected
            width: 1.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
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

// Adapted ImageGridItem to include video play icon
class _SearchGridItem extends StatelessWidget {
  final String imageUrl;
  final bool isVideo;

  const _SearchGridItem({required this.imageUrl, this.isVideo = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle tap (e.g., open full screen or detail view)
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
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
              if (isVideo)
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(80), // ~0.3 opacity
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Charts Screen
class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Sample chart container
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 60, color: Colors.grey[500]),
                const SizedBox(height: 16),
                Text(
                  'Analytics Chart',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Stats cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '1.2K',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        'Followers',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '856',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        'Following',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Profile Screen
class NavProfileScreen extends StatefulWidget {
  const NavProfileScreen({super.key});

  @override
  State<NavProfileScreen> createState() => _NavProfileScreenState();
}

class _NavProfileScreenState extends State<NavProfileScreen>
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {},
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
            icon: const Icon(
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
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
          ),
        ),
      ),
    );
  }
}

// Keep your existing helper widgets (_StoryAvatar and _FeedPostCard) exactly as they are
// ... (include all your existing _StoryAvatar and _FeedPostCard code here)

// Helper widget for a single story avatar
class _StoryAvatar extends StatefulWidget {
  final String imageUrl;
  final String username;
  final bool isYou;

  const _StoryAvatar({
    required this.imageUrl,
    required this.username,
    this.isYou = false,
  });

  @override
  State<_StoryAvatar> createState() => _StoryAvatarState();
}

class _StoryAvatarState extends State<_StoryAvatar> {
  bool showBorder = true;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () {
                setState(() {
                  showBorder = !showBorder;
                });
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => StoryViewerScreen(),
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          (widget.isYou || !showBorder)
                              ? null
                              : Border.all(color: primaryColor, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundImage: NetworkImage(widget.imageUrl),
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  if (widget.isYou)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Material(
                        color: Colors.transparent, // To keep shape-only styling
                        shape: const CircleBorder(),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: InkWell(
                            customBorder:
                                const CircleBorder(), // Ensures ripple matches shape
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => AddStoryScreen(),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(
                                4,
                              ), // Adjust for better touch area
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.username,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for a single feed post card
class _FeedPostCard extends StatefulWidget {
  final String userImageUrl;
  final String username;
  final String profession;
  final String postImageUrl;
  final int initialLikes;
  final int initialComments;
  final String postDescription;

  const _FeedPostCard({
    required this.userImageUrl,
    required this.username,
    required this.profession,
    required this.postImageUrl,
    required this.initialLikes,
    required this.initialComments,
    required this.postDescription,
  });

  @override
  State<_FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<_FeedPostCard> {
  int _likes = 0;
  bool _isLiked = false;
  bool _isBookmarked = false;
  final int _currentPage = 0; // Placeholder for carousel

  @override
  void initState() {
    super.initState();
    _likes = widget.initialLikes;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likes += _isLiked ? 1 : -1;
    });
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  Widget _buildPageIndicator(
    int index,
    int currentPage,
    Color activeColor,
    Color inactiveColor,
  ) {
    return Container(
      width: 8.0,
      height: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == currentPage ? activeColor : inactiveColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    const Color heartRed = Color(0xFFFF5270);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16, right: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(widget.userImageUrl),
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.username,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        widget.profession,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.black),
                  onPressed: () {
                    // handle more options
                  },
                ),
              ],
            ),
          ),

          // Post Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              widget.postImageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 350,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 350,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
            ),
          ),

          const SizedBox(height: 12),

          // Page Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return _buildPageIndicator(
                index,
                _currentPage,
                primaryColor,
                Colors.grey[300]!,
              );
            }),
          ),

          const SizedBox(height: 16),

          // Actions Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Like
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: _toggleLike,
                    child: Row(
                      children: [
                        Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? heartRed : Colors.grey[700],
                          size: 24,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$_likes',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // Comment
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => CommentSectionScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.grey[700],
                          size: 24,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.initialComments}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Share
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.send_outlined,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // Bookmark
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: _toggleBookmark,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: _isBookmarked ? primaryColor : Colors.grey[700],
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Post Description
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                    text: widget.username,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: ' ${widget.postDescription}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavShortsScreen extends StatefulWidget {
  const NavShortsScreen({super.key});

  @override
  State<NavShortsScreen> createState() => _NavShortsScreenState();
}

class _NavShortsScreenState extends State<NavShortsScreen> {
  bool _isLiked = false;
  int _likesCount = 12267;
  bool _isPlayingVideo = true; // State for the central play/pause button

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _likesCount--;
      } else {
        _likesCount++;
      }
      _isLiked = !_isLiked;
    });
  }

  void _toggleVideoPlayback() {
    setState(() {
      _isPlayingVideo = !_isPlayingVideo;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color heartRed = Color(
      0xFFFF5270,
    ); // Keeping this specific red for heart icon as per image/common UX

    return Scaffold(
      extendBodyBehindAppBar:
          true, // Allow body to go behind app bar for full-screen video
      extendBody: true, // Extend body to go behind bottom nav bar
      backgroundColor: Colors.black, // Dark background for video screen
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Shorts',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
        leadingWidth: 100, // Give enough space for 'Shorts' text
        actions: [
          IconButton(
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          // Full-screen video placeholder
          Positioned.fill(
            child: Image.network(
              'https://picsum.photos/800/1200?random=1', // Placeholder for video
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.videocam_off,
                        color: Colors.grey,
                        size: 100,
                      ),
                    ),
                  ),
            ),
          ),
          // Centered Play/Pause button
          Positioned(
            left: 50,
            right: 50,
            top: 135,
            bottom: 50,
            child: GestureDetector(
              onTap: _toggleVideoPlayback,
              child: Icon(
                _isPlayingVideo ? Icons.pause : Icons.play_circle_fill,
                size: 80,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),

          // Engagement Metrics (Right Side)
          Positioned(
            bottom: 38, // Above bottom navigation bar
            right: 16,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: Column(
                    children: [
                      Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? heartRed : Colors.white,
                        size: 32,
                      ),
                      Text(
                        _likesCount.toString(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    IconButton(
                      // Converted to IconButton
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () {},
                    ),
                    Text(
                      '9.287', // Dummy comment count
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                IconButton(
                  // Converted to IconButton
                  icon: const Icon(
                    Icons.send_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                IconButton(
                  // Converted to IconButton
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // User Info and Audio Attribution (Bottom Left)
          Positioned(
            bottom: 38, // Above bottom navigation bar
            left: 16,
            right: 120, // Give space for right-side icons
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FollowListItem(
                  imageUrl: 'https://picsum.photos/100/100?random=2',
                  name: 'jenny_wirosa',
                  profession: 'Videographer',
                  initialFollowing: false,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Favorite Girl by Justin Bieber',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reusing FollowListItem from lib/screens/follow_someone_screen.dart and search_results_screen.dart
class FollowListItem extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String profession; // Using profession for the smaller text
  final bool initialFollowing;

  const FollowListItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.profession,
    this.initialFollowing = false,
  });

  @override
  State<FollowListItem> createState() => _FollowListItemState();
}

class _FollowListItemState extends State<FollowListItem> {
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialFollowing;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20, // Slightly smaller for this context
            backgroundImage: NetworkImage(widget.imageUrl),
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600, // Semi-bold for names
                    fontSize: 16,
                    color: Colors.white, // White text on dark background
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.profession,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.white70, // Lighter text
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _isFollowing
              ? OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isFollowing = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white, // White text on outline
                  side: BorderSide(color: primaryColor), // Primary color border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  minimumSize: const Size(80, 36), // Fixed size for consistency
                ),
                child: Text(
                  'Following',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
              : ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isFollowing = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, // Use primaryColor
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 8,
                  ),
                  minimumSize: const Size(80, 36), // Fixed size for consistency
                ),
                child: Text(
                  'Follow',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/components/center_button_navbar.dart';
import 'package:socialPixel/components/search_field.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedIndex = 1; // Highlight 'Search' in bottom nav
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

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
      bottomNavigationBar: CenterButtonNavbar(),
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

// Reusing CustomChip from ProfileScreen or other UIKit components
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

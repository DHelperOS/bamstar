import 'package:canwa/Screens/course_detail_screen.dart';
import 'package:flutter/material.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex =
      1; // "Science" is selected by default as per image

  final List<Map<String, dynamic>> _categoryChipsWithIcons = [
    {'name': 'Programming', 'icon': Icons.laptop_mac}, // Placeholder icon
    {'name': 'Science', 'icon': Icons.public}, // Placeholder icon
    {'name': 'Design', 'icon': Icons.palette}, // Placeholder icon
    {'name': 'Business', 'icon': Icons.business_center}, // Placeholder icon
    {'name': 'Art', 'icon': Icons.brush}, // Placeholder icon
  ];

  // Modified wishlistCourses to include an isFavorited status for each item
  final List<Map<String, dynamic>> _wishlistCourses = [
    {
      'image': 'https://picsum.photos/id/600/100/80',
      'category': 'Graphic Design',
      'title': 'Expert Wireframing for Mobile Design',
      'rating': 4.9,
      'reviews': 12990,
      'author': 'Jerremy Mamika',
      'price': '\$48',
      'isFavorited': true, // All items start as favorited as per screenshot
    },
    {
      'image': 'https://picsum.photos/id/338/100/80',
      'category': 'Science',
      'title': 'The Complete Solar Energy Course',
      'rating': 4.9,
      'reviews': 12990,
      'author': 'Jerremy Mamika',
      'price': '\$125',
      'isFavorited': true,
    },
    {
      'image': 'https://picsum.photos/id/1015/100/80',
      'category': 'Coding',
      'title': 'How to convert design to React js Brssic',
      'rating': 4.9,
      'reviews': 12990,
      'author': 'Jerremy Mamika',
      'price': '\$34',
      'isFavorited': true,
    },

    {
      'image': 'https://picsum.photos/id/116/100/80',
      'category': 'Coding',
      'title': 'How to convert design to React js Brssic',
      'rating': 4.9,
      'reviews': 12990,
      'author': 'Jerremy Mamika',
      'price': '\$34',
      'isFavorited': true,
    },
    {
      'image': 'https://picsum.photos/id/1043/100/80',
      'category': 'Photography',
      'title': 'Mastering Street Photography',
      'rating': 4.8,
      'reviews': 9870,
      'author': 'Sarah Doe',
      'price': '\$75',
      'isFavorited': true,
    },
  ];

  int _selectedIndex =
      1; // 0 for Home, 1 for Wishlist, 2 for My Course, 3 for Profile

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // In a real app, you would navigate to different screens here.
    // For now, it just highlights the selected tab.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: primaryColor,
          ), // Black icon, transparent background
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 20,
        ),
        title: Text(
          'My Wishlist',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: primaryColor,
              size: 20,
            ), // Black icon, transparent background
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Something',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Icon(Icons.search, color: Colors.grey[600]),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                        onPressed: () {
                          _searchController.clear();
                          // Perform search clear logic
                        },
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white, // White background for the input
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                  ),
                  onChanged: (value) {
                    // Perform search as user types
                  },
                ),
                const SizedBox(height: 16),

                // Category Chips
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categoryChipsWithIcons.length,
                    itemBuilder: (context, index) {
                      final chipData = _categoryChipsWithIcons[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: _CategoryChipWithIcon(
                          name: chipData['name']!,
                          icon: chipData['icon']!,
                          isSelected: index == _selectedCategoryIndex,
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Wishlist Course List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              itemCount: _wishlistCourses.length,
              itemBuilder: (context, index) {
                final course = _wishlistCourses[index];
                return _buildWishlistCourseCard(
                  context,
                  course,
                  primaryColor,
                  textTheme,
                  index, // Pass index to uniquely identify the card
                );
              },
              separatorBuilder:
                  (context, index) =>
                      const SizedBox(height: 16), // Spacing between cards
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 0 ? Icons.home_filled : Icons.home_outlined,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 1 ? Icons.bookmark : Icons.bookmark_border,
            ),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 2
                  ? Icons.play_circle_fill
                  : Icons.play_circle_outline,
            ),
            label: 'My Course',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 3 ? Icons.person : Icons.person_outline,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures all labels are shown
        selectedLabelStyle: textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: textTheme.bodySmall,
      ),
    );
  }

  Widget _buildWishlistCourseCard(
    BuildContext context,
    Map<String, dynamic> course,
    Color primaryColor,
    TextTheme textTheme,
    int index,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(pageBuilder: (_, __, ___) => CourseDetailScreen()),
          );
        },
        hoverColor: primaryColor.withValues(
          alpha: 0.05,
        ), // subtle hover on web/desktop
        splashColor: primaryColor.withValues(
          alpha: 0.2,
        ), // splash effect on tap
        child: Container(
          height: 120,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              // Left Image
              SizedBox(
                width: 120,
                height: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    bottomLeft: Radius.circular(16.0),
                  ),
                  child: Image.network(course['image']!, fit: BoxFit.cover),
                ),
              ),
              // Right Text Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 8,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + Heart Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              course['category']!,
                              style: textTheme.bodySmall?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _wishlistCourses[index]['isFavorited'] =
                                    !_wishlistCourses[index]['isFavorited'];
                              });
                            },
                            child: Icon(
                              _wishlistCourses[index]['isFavorited']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  _wishlistCourses[index]['isFavorited']
                                      ? Colors.red
                                      : Colors.grey[600],
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      // Title
                      Text(
                        course['title']!,
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Rating and Reviews
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${course['rating']} • (${course['reviews']})',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      // Author and Price
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course['author']!,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            course['price']!,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
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

// Reusing and adapting the CategoryChip for icons
class _CategoryChipWithIcon extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChipWithIcon({
    required this.name,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    final ButtonStyle style = Theme.of(
      context,
    ).outlinedButtonTheme.style!.copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (isSelected) {
          return primaryColor;
        }
        return Colors.white; // White background for unselected
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (isSelected) {
          return Colors.white;
        }
        return Colors.black; // Black text for unselected
      }),
      side: WidgetStateProperty.resolveWith<BorderSide>((
        Set<WidgetState> states,
      ) {
        if (isSelected) {
          return BorderSide(color: primaryColor, width: 1.5);
        }
        return BorderSide(
          color: Colors.grey[300]!,
          width: 1.5,
        ); // Light grey border for unselected
      }),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      ),
    );

    return OutlinedButton(
      onPressed: onTap,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.black, size: 18),
          const SizedBox(width: 8),
          Text(
            name,
            style: textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

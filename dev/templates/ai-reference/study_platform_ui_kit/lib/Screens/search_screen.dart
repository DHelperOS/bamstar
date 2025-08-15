import 'package:canwa/Screens/course_detail_screen.dart';
import 'package:canwa/Screens/profile_mentor_screen.dart';
import 'package:canwa/Widgets/primary_text_button.dart';
import 'package:flutter/material.dart';
import 'package:canwa/Widgets/category_chip.dart'; // Reusing for consistency, though we'll make a new chip type

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _selectedCategoryIndices =
      {}; // Tracks multiple selected category chips

  final List<Map<String, dynamic>> _categoryChips = [
    {'name': 'Design', 'emoji': '📝'},
    {'name': 'Business', 'emoji': '💰'},
    {'name': 'Art', 'emoji': '🎨'},
    {'name': 'Trading', 'emoji': '📈'},
    {'name': 'Gym', 'emoji': '🏋️'},
    {'name': 'Programming', 'emoji': '💻'},
  ];

  final List<Map<String, String>> _popularMentors = [
    {'name': 'Destiny', 'image': 'https://picsum.photos/id/1027/200/200'},
    {'name': 'Kayley', 'image': 'https://picsum.photos/id/1025/200/200'},
    {'name': 'Kirstin', 'image': 'https://picsum.photos/id/1011/200/200'},
    {'name': 'Ramon', 'image': 'https://picsum.photos/id/1005/200/200'},
    {'name': 'Gustave', 'image': 'https://picsum.photos/id/1009/200/200'},
  ];

  final List<Map<String, dynamic>> _lastSeenCourses = [
    {
      'image': 'https://picsum.photos/id/1014/200/150',
      'title': 'Complete Anatomy Human Beginner',
      'rating': 4.2,
      'reviews': 886,
      'price': '\$399',
      'oldPrice': '\$499',
      'tag': null,
    },
    {
      'image': 'https://picsum.photos/id/600/200/150',
      'title': 'How to convert design to React js Brssic',
      'rating': 4.5,
      'reviews': 1239,
      'price': '\$499',
      'oldPrice': '\$699',
      'tag': 'New Course',
    },
    {
      'image': 'https://picsum.photos/id/602/200/150',
      'title': 'Advanced Python for Data Science',
      'rating': 4.7,
      'reviews': 1100,
      'price': '\$550',
      'oldPrice': '\$700',
      'tag': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 20,
        ),
        title: Text(
          'Search',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ), // Three dots icon
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Something',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
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
            const SizedBox(height: 24),

            // Categories Section
            Text(
              'Categories',
              style: textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12.0, // horizontal space between chips
              runSpacing: 12.0, // vertical space between lines of chips
              children: List.generate(_categoryChips.length, (index) {
                final chipData = _categoryChips[index];
                return _EmojiCategoryChip(
                  name: chipData['name']!,
                  emoji: chipData['emoji']!,
                  isSelected: _selectedCategoryIndices.contains(index),
                  onTap: () {
                    setState(() {
                      if (_selectedCategoryIndices.contains(index)) {
                        _selectedCategoryIndices.remove(index);
                      } else {
                        _selectedCategoryIndices.add(index);
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 32),

            // Popular Mentors Section
            _buildSectionHeader(
              context,
              'Popular Mentors',
              onSeeAllTap: () => {},
            ),
            const SizedBox(height: 16),
            _buildPopularMentorsList(context),
            const SizedBox(height: 32),

            // Last Seen Section
            _buildSectionHeader(context, 'Last Seen', onSeeAllTap: () => {}),
            const SizedBox(height: 16),
            _buildLastSeenCourseList(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAllTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        if (onSeeAllTap != null)
          TextButton(
            onPressed: onSeeAllTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'See All',
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPopularMentorsList(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 120, // Height for mentor avatars and names
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _popularMentors.length,
        itemBuilder: (context, index) {
          final mentor = _popularMentors[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              children: [
                Material(
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      // Handle the tap here
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => ProfileMentorScreen(),
                        ),
                      );
                    },
                    customBorder: const CircleBorder(),
                    child: Ink.image(
                      image: NetworkImage(mentor['image']!),
                      width: 80, // Since radius is 40
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mentor['name']!,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLastSeenCourseList(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;

    return SizedBox(
      height: 300, // Height for course cards including the button
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _lastSeenCourses.length,
        itemBuilder: (context, index) {
          final course = _lastSeenCourses[index];
          return Container(
            width: 200, // Fixed width for each card
            margin: const EdgeInsets.only(right: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16.0),
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        course['image']!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      if (course['tag'] != null)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course['tag']!,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // No category text at the top in this specific card variant
                      Text(
                        course['title']!,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${course['rating']} (${course['reviews']} reviews)',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            course['price']!,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            course['oldPrice']!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (_, __, ___) => CourseDetailScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            elevation: 0, // No shadow for this button
                          ),
                          child: Text(
                            'Enroll Now',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the bottom sheet to take full height if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return _FilterBottomSheet();
      },
    );
  }
}

class _EmojiCategoryChip extends StatelessWidget {
  final String name;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmojiCategoryChip({
    required this.name,
    required this.emoji,
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
          Text(
            emoji,
            style: const TextStyle(fontSize: 18), // Emoji size
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: textTheme.bodyLarge?.copyWith(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  @override
  __FilterBottomSheetState createState() => __FilterBottomSheetState();
}

class __FilterBottomSheetState extends State<_FilterBottomSheet> {
  final Set<int> _selectedFilterCategoryIndices = {};
  final Set<int> _selectedLessonIndices = {};
  RangeValues _currentPriceRange = const RangeValues(260, 12000);

  final List<String> _filterCategories = [
    'Design & Creative',
    'Finance',
    'Writing',
    'Engineering & Architecture',
    'Marketing',
    'Development & IT',
    'Others',
  ];

  final List<String> _lessonRanges = ['15-20 Lesson', '20-30 Lesson'];

  void _resetFilters() {
    setState(() {
      _selectedFilterCategoryIndices.clear();
      _selectedLessonIndices.clear();
      _currentPriceRange = const RangeValues(
        260,
        12000,
      ); // Reset to default values
    });
  }

  void _applyFilters() {
    // Implement filter application logic here
    Navigator.pop(context); // Close the bottom sheet
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  'Filter',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Reset Filters',
                    style: textTheme.bodyLarge?.copyWith(
                      color:
                          primaryColor, // Use primary color for Reset Filters
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'Categories',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: List.generate(_filterCategories.length, (index) {
                return CategoryChip(
                  // Using the existing CategoryChip
                  name: _filterCategories[index],
                  isSelected: _selectedFilterCategoryIndices.contains(index),
                  onTap: () {
                    setState(() {
                      if (_selectedFilterCategoryIndices.contains(index)) {
                        _selectedFilterCategoryIndices.remove(index);
                      } else {
                        _selectedFilterCategoryIndices.add(index);
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 24),

            Text(
              'Price',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            RangeSlider(
              values: _currentPriceRange,
              min: 0,
              max: 20000, // A reasonable max value, adjust as needed
              divisions: 100, // For smoother steps
              activeColor: primaryColor,
              inactiveColor: primaryColor.withValues(alpha: 0.2),
              labels: RangeLabels(
                '\$${_currentPriceRange.start.round()}',
                '\$${_currentPriceRange.end.round()}',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentPriceRange = values;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${_currentPriceRange.start.round()}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '\$${_currentPriceRange.end.round()}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Lessons',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: List.generate(_lessonRanges.length, (index) {
                return CategoryChip(
                  // Using the existing CategoryChip
                  name: _lessonRanges[index],
                  isSelected: _selectedLessonIndices.contains(index),
                  onTap: () {
                    setState(() {
                      if (_selectedLessonIndices.contains(index)) {
                        _selectedLessonIndices.remove(index);
                      } else {
                        _selectedLessonIndices.add(index);
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 40),

            PrimaryTextButton(
              text: 'Apply Filters',
              onPressed: () {
                _applyFilters();
              },
            ),
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom,
            ), // Adjust for keyboard
          ],
        ),
      ),
    );
  }
}

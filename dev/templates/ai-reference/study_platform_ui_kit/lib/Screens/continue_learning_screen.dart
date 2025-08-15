import 'package:canwa/Screens/course_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:canwa/Widgets/category_chip.dart';

class ContinueLearningScreen extends StatefulWidget {
  const ContinueLearningScreen({super.key});

  @override
  State<ContinueLearningScreen> createState() => _ContinueLearningScreenState();
}

class _ContinueLearningScreenState extends State<ContinueLearningScreen> {
  final List<String> _courseCategories = [
    'All Course',
    'Education',
    'Technology',
    'Design',
    'Programming',
    'Science',
    'Art',
  ];
  int _selectedCategoryIndex = 0; // "All Course" selected by default

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor, size: 20),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Continue Learning',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black), // Filter icon
            onPressed: () {
              // Handle filter action
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
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
          ),
          const SizedBox(height: 16),

          // Category Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: _courseCategories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: CategoryChip(
                    name: _courseCategories[index],
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
          const SizedBox(height: 24),

          // Course List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: _continueLearningCourses.length,
              itemBuilder: (context, index) {
                final course = _continueLearningCourses[index];
                return _buildCourseProgressCard(
                  context,
                  course,
                  primaryColor,
                  textTheme,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseProgressCard(
    BuildContext context,
    Map<String, dynamic> course,
    Color primaryColor,
    TextTheme textTheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                width: 1,
                color: Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16.0),
              onTap: () {
                // Handle card tap
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => CourseDetailScreen(),
                  ),
                );
                // Add your navigation or action logic here
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          course['image']!,
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course['title']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                course['author']!,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: course['progress'],
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryColor,
                                ),
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(course['progress'] * 100).toInt()}% completed',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                hoverColor: Colors.black.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  // Handle more options tap
                                  print(
                                    'More options tapped for: ${course['title']}',
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.more_vert,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Sample data for courses
  final List<Map<String, dynamic>> _continueLearningCourses = [
    {
      'image': 'https://picsum.photos/id/1043/100/80',
      'title': 'Songwriting with Strings: Composing and Arranging for Guitar',
      'author': 'Daniel Lewis',
      'progress': 0.75,
    },
    {
      'image': 'https://picsum.photos/id/1047/100/80',
      'title': 'Songwriting with Strings: Composing and Arranging for Guitar',
      'author': 'James Hall',
      'progress': 0.10,
    },
    {
      'image': 'https://picsum.photos/id/1048/100/80',
      'title': 'Kitchen Confidence: Mastering Basic Cooking Techniques',
      'author': 'David Elson & Iva Carolina',
      'progress': 0.00,
    },
    {
      'image': 'https://picsum.photos/id/100/100/80',
      'title': 'Essential Spanish Grammar: Mastering the Fundamental Rules',
      'author': 'Stephanie Nicol',
      'progress': 0.90,
    },
    {
      'image': 'https://picsum.photos/id/200/100/80',
      'title': 'Introduction to Digital Photography: Capture Stunning Images',
      'author': 'Emily White',
      'progress': 0.60,
    },
  ];
}

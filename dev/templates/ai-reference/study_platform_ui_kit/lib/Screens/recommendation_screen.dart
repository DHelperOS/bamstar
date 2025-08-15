import 'package:canwa/Screens/course_detail_screen.dart';
import 'package:flutter/material.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  // Sample data for courses
  final List<Map<String, dynamic>> _recommendationCourses = [
    {
      'image': 'https://picsum.photos/id/1015/400/250',
      'category': 'Science',
      'title': 'Become a Great Scientist in physics',
      'author': 'Jerremy Mamika',
      'price': '\$57',
      'is_favorite': false,
    },
    {
      'image': 'https://picsum.photos/id/400/400/250',
      'category': 'Coding',
      'title': 'Convert to React js for Beginner',
      'author': 'Joel Tromp',
      'price': '\$132',
      'is_favorite': false,
    },
    {
      'image': 'https://picsum.photos/id/600/400/250',
      'category': 'Graphic Design',
      'title': 'Expert Wireframing for Mobile Design',
      'author': 'Jerremy Mamika',
      'price': '\$48',
      'is_favorite': false,
    },
    {
      'image': 'https://picsum.photos/id/338/400/250',
      'category': 'Marketing',
      'title': 'Digital Marketing Masterclass: From Zero to Hero',
      'author': 'Sarah Johnson',
      'price': '\$99',
      'is_favorite': false,
    },
  ];

  void _toggleFavorite(int index) {
    setState(() {
      _recommendationCourses[index]['is_favorite'] =
          !_recommendationCourses[index]['is_favorite'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 20,
        ),
        scrolledUnderElevation: 0,
        title: Text(
          'Recommendation',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: primaryColor), // Filter icon
            onPressed: () {
              // Handle filter action
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        itemCount: _recommendationCourses.length,
        itemBuilder: (context, index) {
          final course = _recommendationCourses[index];
          return _buildRecommendationCourseCard(
            context,
            course,
            primaryColor,
            textTheme,
            index, // Pass index to the card builder
          );
        },
      ),
    );
  }

  Widget _buildRecommendationCourseCard(
    BuildContext context,
    Map<String, dynamic> course,
    Color primaryColor,
    TextTheme textTheme,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            // Handle card tap - navigate to course details
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => CourseDetailScreen(),
              ),
            );
            // Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetailScreen(course: course)));
          },
          hoverColor: primaryColor.withValues(
            alpha: 0.05,
          ), // Subtle hover effect
          splashColor: primaryColor.withValues(
            alpha: 0.1,
          ), // Splash effect on tap
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
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            course['is_favorite']
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                course['is_favorite']
                                    ? Colors.red
                                    : Colors.black,
                            size: 20,
                          ),
                          onPressed: () {
                            _toggleFavorite(index);
                          },
                          splashRadius: 20,
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
                    Text(
                      course['category']!,
                      style: textTheme.bodySmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            course['author']!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          course['price']!,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

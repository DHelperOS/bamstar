import 'package:canwa/Screens/course_detail_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ProfileMentorScreen extends StatefulWidget {
  const ProfileMentorScreen({super.key});

  @override
  State<ProfileMentorScreen> createState() => _ProfileMentorScreenState();
}

class _ProfileMentorScreenState extends State<ProfileMentorScreen> {
  bool _showFullAbout = false;

  final String _shortAbout =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Eros, urna libero, nisl nullam. Cras ante ac odio dolor. Penatibus elit convallis ipsum morbi tincidunt ac diam tristique tincidunt ...';
  final String _fullAbout =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Eros, urna libero, nisl nullam. Cras ante ac odio dolor. Penatibus elit convallis ipsum morbi tincidunt ac diam tristique tincidunt. Dictum eget arcu eget nulla. Volutpat, sit sed nibh sit sit eget donec. Mattis sed turpis massa morbi. Aliquet vel aenean donec id vitae donec. Lacus, eget egestas in sed ultrices.';

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
          'Profile Mentor',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mentor Profile Header
            Row(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(
                        'https://picsum.photos/id/1027/200/200', // Placeholder profile image
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 1,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          'Mentor',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Janny Andrea',
                      style: textTheme.headlineSmall?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'UI Designer Expert',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    'Follow',
                    style: textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader(context, 'About'),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                text: _showFullAbout ? _fullAbout : _shortAbout,
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                children: [
                  if (!_showFullAbout)
                    TextSpan(
                      text: 'Read More',
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              setState(() {
                                _showFullAbout = true;
                              });
                            },
                    )
                  else
                    TextSpan(
                      text: ' Read Less',
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              setState(() {
                                _showFullAbout = false;
                              });
                            },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stat Cards Section
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Mentor',
                    '23',
                    'Course',
                    Icons.local_fire_department, // Flame icon
                    Colors.deepOrange, // Flame color
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Learning',
                    '74',
                    'Student',
                    Icons.favorite, // Heart icon
                    Colors.pink, // Heart color
                    showGraph: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Featured Class Section
            _buildSectionHeader(
              context,
              'Featured Class',
              onSeeAllTap: () => {},
            ),
            const SizedBox(height: 16),
            _buildFeaturedClassList(context),
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
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color iconColor, {
    bool showGraph = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              if (showGraph) const Spacer(),
              if (showGraph)
                // Placeholder for graph, using a simple line for visual hint
                SizedBox(
                  width: 50,
                  height: 20,
                  // This could be a CustomPainter for a real graph
                  child: CustomPaint(painter: _LearningGraphPainter(iconColor)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Add this as a class member variable (outside any method)
  final Set<int> _favoritedCourseIndices = <int>{};

  // Updated _buildFeaturedClassList method
  Widget _buildFeaturedClassList(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;

    final List<Map<String, dynamic>> courses = [
      {
        'category': 'Design',
        'title': 'Expert Wireframing for Mobile Design',
        'image': 'https://picsum.photos/id/600/200/150',
        'rating': 4.5,
        'reviews': 1239,
        'price': '\$499',
        'oldPrice': '\$699',
        'tag': 'New Course',
      },
      {
        'category': 'Language',
        'title': 'TOEFL Preparation Course: Boost Your E...',
        'image': 'https://picsum.photos/id/603/200/150',
        'rating': 4.2,
        'reviews': 886,
        'price': '\$399',
        'oldPrice': '\$499',
        'tag': null,
      },
      {
        'category': 'Programming',
        'title': 'Advanced React.js for Modern Web Apps',
        'image': 'https://picsum.photos/id/602/200/150',
        'rating': 4.8,
        'reviews': 1500,
        'price': '\$599',
        'oldPrice': '\$799',
        'tag': 'Best Seller',
      },
    ];

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          final isFavorited = _favoritedCourseIndices.contains(index);

          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16.0),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              elevation: 3,
              shadowColor: Colors.grey.withValues(alpha: 0.1),
              child: InkWell(
                borderRadius: BorderRadius.circular(16.0),
                onTap:
                    () => {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (_, __, ___) => const CourseDetailScreen(),
                        ),
                      ),
                    },
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
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
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Material(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: const CircleBorder(),
                                elevation: 2,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    setState(() {
                                      if (isFavorited) {
                                        _favoritedCourseIndices.remove(index);
                                      } else {
                                        _favoritedCourseIndices.add(index);
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Icon(
                                        isFavorited
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        key: ValueKey(isFavorited),
                                        color:
                                            isFavorited
                                                ? Colors.red
                                                : Colors.black54,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LearningGraphPainter extends CustomPainter {
  final Color lineColor;

  _LearningGraphPainter(this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final path = Path();
    // Example points for a rising graph curve, adjusted to fit the 50x20 container
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.4);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.2);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

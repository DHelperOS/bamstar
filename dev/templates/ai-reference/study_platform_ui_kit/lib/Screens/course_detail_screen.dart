import 'package:canwa/Screens/learning_screen.dart';
import 'package:canwa/Screens/profile_mentor_screen.dart';
import 'package:flutter/material.dart';
import 'package:canwa/Screens/course_reminders_screen.dart'; // Import the new reminders screen

// Course Progress Model
class CourseProgress {
  final int totalLessons;
  final int completedLessons;
  final List<bool> lessonCompletionStatus;

  CourseProgress({
    required this.totalLessons,
    required this.completedLessons,
    required this.lessonCompletionStatus,
  });

  double get progressPercentage => completedLessons / totalLessons;
  int get progressPoints => (progressPercentage * 100).round();

  // Check if milestone is achieved
  bool isMilestoneAchieved(double milestone) => progressPercentage >= milestone;
}

// Updated CourseDetailScreen with functional progress
class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  int _selectedContentIndex = 0;

  // Course progress state
  late CourseProgress _courseProgress;

  @override
  void initState() {
    super.initState();
    // Initialize with sample course data - 20 lessons, 5 completed
    _courseProgress = CourseProgress(
      totalLessons: 20,
      completedLessons: 5,
      lessonCompletionStatus: List.generate(
        20,
        (index) => index < 5,
      ), // First 5 lessons completed
    );
  }

  // Method to simulate course progress (for demo purposes)

  // Add these variables to your State class
  double scrollOffset = 0.0;
  String totalTime = "15:30";
  int currentVideoIndex = 0;
  int totalVideos = 5;
  int selectedContentIndex = 0; // This might already exist in your code

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification) {
            setState(() {
              scrollOffset = scrollNotification.metrics.pixels;
            });
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            // App Bar with Background Image
            SliverAppBar(
              scrolledUnderElevation: 0,
              expandedHeight: MediaQuery.of(context).size.height * 0.35,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.keyboard_arrow_left_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              actions: _buildActionWidgets(),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildFlexibleSpaceBackground(
                  primaryColor,
                  textTheme,
                ),
              ),
            ),

            // Content Section
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    // Course Info Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'English Beginner Level',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Learn essential English skills, including grammar, vocabulary, and practical conversation basics.',
                            style: textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[700],
                              height: 1.6,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Custom Tab Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: [
                          _CourseDetailChip(
                            label: 'Overview',
                            isSelected: _selectedContentIndex == 0,
                            onTap:
                                () => setState(() => _selectedContentIndex = 0),
                          ),
                          const SizedBox(width: 12),
                          _CourseDetailChip(
                            label: 'Course',
                            isSelected: _selectedContentIndex == 1,
                            onTap:
                                () => setState(() => _selectedContentIndex = 1),
                          ),
                          const SizedBox(width: 12),
                          _CourseDetailChip(
                            label: 'Achievements',
                            isSelected: _selectedContentIndex == 2,
                            onTap:
                                () => setState(() => _selectedContentIndex = 2),
                          ),
                          const SizedBox(width: 12),
                          _CourseDetailChip(
                            label: 'Resources',
                            isSelected: _selectedContentIndex == 3,
                            onTap:
                                () => setState(() => _selectedContentIndex = 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Content based on selected tab
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildContentBasedOnTab(
                            context,
                            primaryColor,
                            textTheme,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionWidgets() {
    final isCollapsed = scrollOffset > _getCollapseThreshold();

    if (isCollapsed) {
      // Show minimized preview image when collapsed
      return [
        GestureDetector(
          onTap: () {
            _expandPreview();
          },
          child: Row(
            children: [
              Text(
                'English Beginner Level',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(width: 100), // Space between text and image
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                width: 80,
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://picsum.photos/id/1062/600/400',
                        fit: BoxFit.cover,
                      ),
                      // Optional: Add a subtle border
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ];
    } else {
      // Show more options button when expanded
      return [
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CourseRemindersScreen(),
                ),
              );
            },
          ),
        ),
      ];
    }
  }

  Widget _buildFlexibleSpaceBackground(
    Color primaryColor,
    TextTheme textTheme,
  ) {
    final isCollapsed = scrollOffset > _getCollapseThreshold();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isCollapsed ? 0.0 : 1.0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.network(
            'https://picsum.photos/id/1062/600/400',
            fit: BoxFit.cover,
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),

          // Preview Info at Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Preview',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        totalTime,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(totalVideos, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  index == currentVideoIndex
                                      ? primaryColor
                                      : Colors.white.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                      Text(
                        '${currentVideoIndex + 1} of $totalVideos',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
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
    );
  }

  double _getCollapseThreshold() {
    final expandedHeight = MediaQuery.of(context).size.height * 0.65;
    return expandedHeight * 0.7; // Collapse when 70% scrolled
  }

  void _expandPreview() {
    // Scroll back to top to expand the preview
    // You'll need to add a ScrollController to implement this
    // scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Widget _buildContentBasedOnTab(
    BuildContext context,
    Color primaryColor,
    TextTheme textTheme,
  ) {
    switch (_selectedContentIndex) {
      case 0: // Overview tab
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Functional Course Progress Section
            Text(
              'Course Progress',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _FunctionalCourseProgressBar(
              courseProgress: _courseProgress,
              primaryColor: primaryColor,
              textTheme: textTheme,
            ),

            // Demo button to simulate progress
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => LearningScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.play_lesson),
                label: Text(
                  _courseProgress.completedLessons <
                          _courseProgress.totalLessons
                      ? 'Start New Lesson'
                      : 'Course Completed!',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Course Overview Section
            Text(
              'Course Overview',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Master essential English skills through engaging lessons on grammar, vocabulary, and everyday conversations. Build confidence with interactive exercises, listening practice, and speaking drills tailored for beginners.',
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Mentors Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mentors',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'See All',
                    style: textTheme.bodyLarge?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMentorsList(context, textTheme),
          ],
        );
      case 1: // Course tab
        return _buildCourseList(context, primaryColor, textTheme);
      case 2: // Achievements tab
        return _buildAchievements(context, primaryColor, textTheme);
      case 3: // Resources tab
        return _buildResources(context, textTheme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCourseList(
    BuildContext context,
    Color primaryColor,
    TextTheme textTheme,
  ) {
    // This data is adjusted to match the image content for "Week 1: Foundations"
    // and includes placeholder images where appropriate.
    final List<Map<String, dynamic>> lessons = [
      {
        'title': 'Building Strong Foundations',
        'date': 'Monday, 3 Feb 2025',
        'image': 'https://picsum.photos/id/1004/100/80',
        'type': 'completed',
        'description':
            'Learn basic grammar, vocabulary, and pronunciation for daily use.',
        'progress_percentage': null,
        'bullet_points': [],
      },
      {
        'title': 'Skill Expansion',
        'date': 'Monday, 3 Feb 2025',
        'image': 'https://picsum.photos/id/1011/100/80',
        'type': 'in_progress',
        'description':
            'Improve speaking, listening, and vocabulary for everyday conversations.',
        'progress_percentage': 0.30,
        'bullet_points': [
          'Learn how to ask and answer questions.',
          'Improve listening comprehension with real-life dialogues.',
          'Expand vocabulary for daily conversations.',
        ],
      },
      {
        'title': 'Real-World Mastery',
        'date': 'Monday, 3 Feb 2025',
        'image': 'https://picsum.photos/id/1005/100/80',
        'type': 'locked',
        'description': 'Focus on workplace, travel, and social fluency.',
        'progress_percentage': 0.0,
        'bullet_points': [],
      },
      // You can add more lessons here to match the 20 total lessons if needed for progress
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Week 1: Foundations',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Introduction to English Basics',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100], // Light grey background
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.calendar_month, color: Colors.black),
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            final bool isCompleted = lesson['type'] == 'completed';
            final bool isInProgress = lesson['type'] == 'in_progress';
            final bool isLocked = lesson['type'] == 'locked';

            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12.0),
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
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              lesson['image']!,
                              height: 80, // Reduced height
                              width: 80, // Reduced width
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lesson['date']!,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lesson['title']!,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lesson['description']!,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (isCompleted)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          if (isInProgress)
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: CircularProgressIndicator(
                                      value: lesson['progress_percentage'],
                                      strokeWidth: 4,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        primaryColor,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${(lesson['progress_percentage'] * 100).toInt()}%',
                                    style: textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (isLocked)
                            SizedBox(
                              width: 48, // Occupy similar space for consistency
                              height: 48,
                              child: Center(
                                child: Text(
                                  '0%', // Showing 0% for locked as per image
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (isInProgress &&
                          lesson['bullet_points'] != null &&
                          lesson['bullet_points'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                lesson['bullet_points'].asMap().entries.map<
                                  Widget
                                >((entry) {
                                  int idx = entry.key;
                                  String point = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(
                                            top: 6,
                                            right: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                idx == 0
                                                    ? primaryColor
                                                    : Colors
                                                        .grey[400], // Green for first, grey for others
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            point,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: Colors.grey[700],
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAchievements(
    BuildContext context,
    Color primaryColor,
    TextTheme textTheme,
  ) {
    final achievements = [
      {
        'title': 'First Steps',
        'description': 'Complete your first lesson',
        'achieved': _courseProgress.completedLessons >= 1,
      },
      {
        'title': 'Getting Started',
        'description': 'Complete 5 lessons',
        'achieved': _courseProgress.completedLessons >= 5,
      },
      {
        'title': 'Quarter Way',
        'description': 'Complete 25% of the course',
        'achieved': _courseProgress.progressPercentage >= 0.25,
      },
      {
        'title': 'Halfway Hero',
        'description': 'Complete 50% of the course',
        'achieved': _courseProgress.progressPercentage >= 0.50,
      },
      {
        'title': 'Almost There',
        'description': 'Complete 75% of the course',
        'achieved': _courseProgress.progressPercentage >= 0.75,
      },
      {
        'title': 'Course Master',
        'description': 'Complete the entire course',
        'achieved': _courseProgress.progressPercentage >= 1.0,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Achievements',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        ...achievements.map(
          (achievement) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    achievement['achieved'] as bool
                        ? primaryColor.withValues(alpha: 0.3)
                        : Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  achievement['achieved'] as bool
                      ? Icons.emoji_events
                      : Icons.emoji_events_outlined,
                  color:
                      achievement['achieved'] as bool
                          ? primaryColor
                          : Colors.grey[400],
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement['title'] as String,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              achievement['achieved'] as bool
                                  ? Colors.black
                                  : Colors.grey[600],
                        ),
                      ),
                      Text(
                        achievement['description'] as String,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (achievement['achieved'] as bool)
                  Icon(Icons.check_circle, color: primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResources(BuildContext context, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Resources',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Access supplementary materials, downloadable PDFs, links to external tools, and other helpful resources for this course.',
          style: textTheme.bodyLarge?.copyWith(
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMentorsList(BuildContext context, TextTheme textTheme) {
    final List<Map<String, String>> mentors = [
      {'name': 'Ximia Ed', 'image': 'https://picsum.photos/id/1004/200/200'},
      {'name': 'Lee Youna', 'image': 'https://picsum.photos/id/1011/200/200'},
      {'name': 'Joshua K', 'image': 'https://picsum.photos/id/1005/200/200'},
      {'name': 'Jesselyn', 'image': 'https://picsum.photos/id/1009/200/200'},
      {'name': 'Kevin', 'image': 'https://picsum.photos/id/1027/200/200'},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mentors.length,
        itemBuilder: (context, index) {
          final mentor = mentors[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              children: [
                Material(
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => ProfileMentorScreen(),
                        ),
                      );
                    },
                    customBorder: const CircleBorder(),
                    child: Ink.image(
                      image: NetworkImage(mentor['image']!),
                      width: 72, // Diameter = 2 * radius (36 * 2)
                      height: 72,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Enhanced Course Progress Bar Widget with Milestones
class _FunctionalCourseProgressBar extends StatelessWidget {
  final CourseProgress courseProgress;
  final Color primaryColor;
  final TextTheme textTheme;

  const _FunctionalCourseProgressBar({
    required this.courseProgress,
    required this.primaryColor,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with progress info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Course Progress',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${courseProgress.progressPoints}%',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${courseProgress.completedLessons} of ${courseProgress.totalLessons} lessons completed',
            style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          // Enhanced Progress bar with milestones
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: 120,
                child: Stack(
                  children: [
                    // Milestone labels at the top
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMilestoneLabel('0%', 0.0),
                          _buildMilestoneLabel('25%', 0.25),
                          _buildMilestoneLabel('50%', 0.5),
                          _buildMilestoneLabel('75%', 0.75),
                          _buildMilestoneLabel('100%', 1.0),
                        ],
                      ),
                    ),

                    // Base progress bar track
                    Positioned(
                      top: 45,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),

                    // Filled progress bar with gradient
                    Positioned(
                      top: 45,
                      left: 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeInOut,
                        height: 12,
                        width:
                            constraints.maxWidth *
                            courseProgress.progressPercentage,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withOpacity(0.8),
                              primaryColor,
                              primaryColor.withOpacity(0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Milestone markers
                    ..._buildMilestoneMarkers(constraints.maxWidth),

                    // Current progress indicator
                    if (courseProgress.progressPercentage > 0)
                      Positioned(
                        top: 40,
                        left:
                            (constraints.maxWidth *
                                courseProgress.progressPercentage) -
                            11,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeInOut,
                          child: Column(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.play_arrow,
                                  color: primaryColor,
                                  size: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Achievement badges for completed milestones
                  ],
                ),
              );
            },
          ),

          // Enhanced motivational message with better styling
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.05),
                  primaryColor.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getMotivationIcon(),
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getMotivationTitle(),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getMotivationMessage(),
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneLabel(String label, double milestone) {
    final isAchieved = courseProgress.progressPercentage >= milestone;
    return Text(
      label,
      style: textTheme.bodySmall?.copyWith(
        color: isAchieved ? primaryColor : Colors.grey[500],
        fontWeight: isAchieved ? FontWeight.bold : FontWeight.normal,
        fontSize: 14,
      ),
    );
  }

  List<Widget> _buildMilestoneMarkers(double maxWidth) {
    final milestones = [0.0, 0.25, 0.5, 0.75, 1.0];
    return milestones.map((milestone) {
      final isAchieved = courseProgress.progressPercentage >= milestone;
      final left = (maxWidth * milestone) - 3;

      return Positioned(
        top: 42,
        left: left.clamp(0.0, maxWidth - 6),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 800 + (milestone * 400).round()),
          curve: Curves.easeInOut,
          width: 6,
          height: 18,
          decoration: BoxDecoration(
            color: isAchieved ? primaryColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(3),
            boxShadow:
                isAchieved
                    ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ]
                    : null,
          ),
        ),
      );
    }).toList();
  }

  IconData _getMotivationIcon() {
    if (courseProgress.progressPercentage >= 1.0) return Icons.celebration;
    if (courseProgress.progressPercentage >= 0.75) return Icons.star;
    if (courseProgress.progressPercentage >= 0.5) return Icons.trending_up;
    if (courseProgress.progressPercentage >= 0.25) {
      return Icons.lightbulb_outline;
    }
    return Icons.play_circle_outline;
  }

  String _getMotivationTitle() {
    if (courseProgress.progressPercentage >= 1.0) return 'Course Completed! 🎉';
    if (courseProgress.progressPercentage >= 0.75) return 'Almost There! 🌟';
    if (courseProgress.progressPercentage >= 0.5) return 'Halfway Champion! 📈';
    if (courseProgress.progressPercentage >= 0.25) return 'Great Start! 💡';
    return 'Welcome Aboard! ▶️';
  }

  String _getMotivationMessage() {
    if (courseProgress.progressPercentage >= 1.0) {
      return 'Amazing! You\'ve mastered the entire course. Ready for your next challenge?';
    } else if (courseProgress.progressPercentage >= 0.75) {
      return 'Outstanding progress! Just a few more lessons to complete your journey.';
    } else if (courseProgress.progressPercentage >= 0.5) {
      return 'Excellent work! You\'re building great momentum. Keep it up!';
    } else if (courseProgress.progressPercentage >= 0.25) {
      return 'You\'re making fantastic progress! Every lesson brings you closer to fluency.';
    } else {
      return 'Your learning adventure begins now! Take it one lesson at a time.';
    }
  }
}

// Course Detail Chip Widget (unchanged)
class _CourseDetailChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CourseDetailChip({
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyLarge?.copyWith(
            fontSize: 14,
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

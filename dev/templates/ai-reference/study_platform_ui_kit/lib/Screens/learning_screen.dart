import 'package:canwa/Screens/profile_mentor_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  // Assuming video progress and total duration for display
  final double _videoProgress = 0.6; // 60% progress
  final String _currentTime = '06:04';
  final String _totalTime = '10:12';
  final int _currentVideoIndex = 0; // For pagination dots
  final int _totalVideos = 3; // For pagination dots

  bool _isPlayingVideo = false; // State for play/pause button
  bool _showFullDescription = false; // State for "Read More" functionality
  int _currentPlayingLessonIndex = 1; // Index 1 for "Tools" as per image

  final String _shortDescription =
      'In this section you will learn what tools will be used in designing...';
  final String _fullDescription =
      'In this section you will learn what tools will be used in designing the user interface and user experience of mobile applications. This includes a deep dive into industry-standard software, collaborative platforms, and best practices for creating wireframes, prototypes, and final designs. We will cover tools for brainstorming, low-fidelity and high-fidelity mockups, and user testing. Understanding these tools is crucial for any aspiring UI/UX designer to efficiently bring their ideas to life and create intuitive and engaging mobile experiences. We will explore how to set up your design environment, manage design assets, and work effectively within design teams using various popular tools.';

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
          'Learning',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Player Section
            Container(
              height: 220, // Height for the video player area
              width: double.infinity,
              color: Colors.black, // Placeholder for video player background
              child: Stack(
                children: [
                  Image.network(
                    'https://picsum.photos/id/1043/800/450', // Placeholder video thumbnail
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  // Play/Pause Button
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isPlayingVideo ? Icons.pause : Icons.play_arrow,
                            color: primaryColor,
                            size: 36,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPlayingVideo = !_isPlayingVideo;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  // Bottom controls overlay
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
                                _currentTime,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _totalTime,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: _videoProgress,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryColor,
                            ),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: List.generate(_totalVideos, (index) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color:
                                          index == _currentVideoIndex
                                              ? primaryColor
                                              : Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                }),
                              ),
                              IconButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () {},
                                icon: Icon(
                                  Icons.fullscreen,
                                  color: Colors.white,
                                  size: 24,
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
            const SizedBox(height: 24),

            // Course Content Overview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Part 2 - Expert Wireframing for Mobile Design',
                    style: textTheme.bodyMedium?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tools',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      text:
                          _showFullDescription
                              ? _fullDescription
                              : _shortDescription,
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      children: [
                        if (!_showFullDescription)
                          TextSpan(
                            text: 'Read More',
                            style: textTheme.bodyLarge?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      _showFullDescription = true;
                                    });
                                  },
                          )
                        else
                          TextSpan(
                            text:
                                ' Read Less', // Added space for visual separation
                            style: textTheme.bodyLarge?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      _showFullDescription = false;
                                    });
                                  },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mentor Info Section (Reused from CourseDetailScreen)
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                          'https://picsum.photos/id/1005/200/200',
                        ), // Placeholder mentor image
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Janny Andrea',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Best Mentor OnLearning',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (_, __, ___) => const ProfileMentorScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(
                            color: primaryColor,
                          ), // Primary color border
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          'View Profile',
                          style: textTheme.bodyMedium?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Lessons List
                  Text(
                    'Section 1 - Preparation',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLessonItem(
                    context,
                    1,
                    'Introduction',
                    'Video - 3 Min',
                    true,
                    primaryColor: primaryColor,
                    textTheme: textTheme,
                    onTap: () {
                      setState(() {
                        _currentPlayingLessonIndex =
                            0; // Assuming 0-indexed for internal logic
                      });
                    },
                    isCurrent: _currentPlayingLessonIndex == 0,
                  ),
                  _buildLessonItem(
                    context,
                    2,
                    'Tools',
                    'Video - 3 Min',
                    false, // Not completed yet
                    primaryColor: primaryColor,
                    textTheme: textTheme,
                    onTap: () {
                      setState(() {
                        _currentPlayingLessonIndex = 1;
                      });
                    },
                    isCurrent: _currentPlayingLessonIndex == 1,
                  ),
                  _buildLessonItem(
                    context,
                    3,
                    'Resources',
                    'Video - 5 Min',
                    false,
                    primaryColor: primaryColor,
                    textTheme: textTheme,
                    onTap: () {
                      setState(() {
                        _currentPlayingLessonIndex = 2;
                      });
                    },
                    isCurrent: _currentPlayingLessonIndex == 2,
                  ),
                  // Add more sections/lessons as needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonItem(
    BuildContext context,
    int number,
    String title,
    String duration,
    bool isCompleted, {
    bool isCurrent = false,
    required Color primaryColor,
    required TextTheme textTheme,
    required VoidCallback onTap, // Added onTap
  }) {
    return GestureDetector(
      // Make the entire item tappable
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isCurrent ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border:
              isCurrent
                  ? null
                  : Border.all(
                    color: Colors.grey[200]!,
                    width: 1.5,
                  ), // Subtle border for unselected
          boxShadow:
              isCurrent
                  ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.2),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCurrent ? Colors.white : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCurrent ? primaryColor : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    duration,
                    style: textTheme.bodySmall?.copyWith(
                      color:
                          isCurrent
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              Icon(
                Icons.check_circle,
                color: isCurrent ? Colors.white : Colors.green,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:canwa/Screens/course_detail_screen.dart';
import 'package:canwa/Screens/edit_profile_screen.dart';
import 'package:canwa/Screens/faq_screen.dart';
import 'package:canwa/Screens/help_and_support_screen.dart';
import 'package:canwa/Screens/language_screen.dart';
import 'package:canwa/Screens/login_screen.dart';
import 'package:canwa/Screens/profile_mentor_screen.dart';
import 'package:canwa/Widgets/appbar.dart';
import 'package:flutter/material.dart';

// Main widget that handles navigation between screens
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const NavbarWishlist(),
    const NavbarMyCourse(),
    const NavbarProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: _screens[_selectedIndex],
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
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: textTheme.bodySmall,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Continue Learning Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildSectionHeader(
                context,
                'Continue Learning',
                onSeeAllTap: () => {},
              ),
            ),
            const SizedBox(height: 16),
            _buildContinueLearningList(context),
            const SizedBox(height: 32),

            // Popular Mentors Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildSectionHeader(
                context,
                'Popular Mentors',
                onSeeAllTap: () => {},
              ),
            ),
            const SizedBox(height: 16),
            _buildPopularMentorsList(context),
            const SizedBox(height: 32),

            // Popular Course Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildSectionHeader(
                context,
                'Popular Course 🔥',
                onSeeAllTap: () => {},
              ),
            ),
            const SizedBox(height: 16),
            _buildPopularCourseList(context),
            const SizedBox(height: 20), // Padding for bottom nav bar
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
    final primaryColor = Theme.of(context).primaryColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
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
              style: TextStyle(
                fontSize: 16,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContinueLearningList(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;

    final List<Map<String, dynamic>> continueCourses = [
      {
        'image': 'https://picsum.photos/id/1043/100/80',
        'title': 'Web Development Bootcamp: Build and Deploy Your Own Website',
        'progress': 0.75,
        'completed_text': '75% completed',
      },
      {
        'image': 'https://picsum.photos/id/1047/100/80',
        'title': 'Mobile App UI/UX Design Fundamentals with Figma',
        'progress': 0.50,
        'completed_text': '50% completed',
      },
      {
        'image': 'https://picsum.photos/id/1048/100/80',
        'title': 'Introduction to Data Science with Python',
        'progress': 0.20,
        'completed_text': '20% completed',
      },
    ];

    return SizedBox(
      height: 120, // Height for the continue learning cards
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: continueCourses.length,
        itemBuilder: (context, index) {
          final course = continueCourses[index];
          return Container(
            width: 300, // Fixed width for each card
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const CourseDetailScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          course['image']!,
                          height: 80,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              course['title']!,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: course['progress'],
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(primaryColor),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              course['completed_text']!,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
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
          );
        },
      ),
    );
  }

  Widget _buildPopularMentorsList(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final List<Map<String, String>> mentors = [
      {'name': 'Destiny', 'image': 'https://picsum.photos/id/1027/200/200'},
      {'name': 'Kayley', 'image': 'https://picsum.photos/id/1025/200/200'},
      {'name': 'Kirstin', 'image': 'https://picsum.photos/id/1011/200/200'},
      {'name': 'Ramon', 'image': 'https://picsum.photos/id/1005/200/200'},
      {'name': 'Gustave', 'image': 'https://picsum.photos/id/1009/200/200'},
      {'name': 'Alice', 'image': 'https://picsum.photos/id/1004/200/200'},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                  child: Ink.image(
                    image: NetworkImage(mentor['image']!),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    child: InkWell(
                      onTap: () {
                        // Handle tap here
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => ProfileMentorScreen(),
                          ),
                        );
                      },
                      customBorder: const CircleBorder(),
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

  Widget _buildPopularCourseList(BuildContext context) {
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
        'isFavorite': false, // Added favorite state
      },
      {
        'category': 'Language',
        'title':
            'TOEFL Preparation Course: Boost Your E...', // Truncated as per image
        'image': 'https://picsum.photos/id/603/200/150',
        'rating': 4.2,
        'reviews': 886,
        'price': '\$399',
        'oldPrice': '\$499',
        'tag': null,
        'isFavorite': false,
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
        'isFavorite': false,
      },
    ];

    return SizedBox(
      height: 280, // Height for course cards
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.0),
                onTap: () {
                  // Handle course card tap
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => CourseDetailScreen(),
                    ),
                  );
                  // You can navigate to course detail page here
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetailPage(course: course)));
                },
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
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                return Material(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      setState(() {
                                        course['isFavorite'] =
                                            !course['isFavorite'];
                                      });
                                      // You can also call a callback here to update parent state
                                      print(
                                        'Favorite toggled for: ${course['title']}',
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        course['isFavorite']
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color:
                                            course['isFavorite']
                                                ? Colors.red
                                                : Colors.black,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                );
                              },
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
                            course['category']!, // Added category text
                            style: textTheme.bodySmall?.copyWith(
                              color:
                                  primaryColor, // Category text in primary color
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
          );
        },
      ),
    );
  }
}

// Profile Screen
class NavbarProfileScreen extends StatefulWidget {
  const NavbarProfileScreen({super.key});

  @override
  State<NavbarProfileScreen> createState() => _NavbarProfileScreenState();
}

class _NavbarProfileScreenState extends State<NavbarProfileScreen> {
  // Assuming the primary color from the main app theme
  late Color primaryColor;
  late TextTheme textTheme;

  bool _isNotificationOn = true;
  bool _isNightModeOn = false;
  int _selectedIndex = 3; // Profile tab is selected by default

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // In a real app, you would navigate to different screens here
    // based on the selected index.
    // Example:
    // if (index == 0) {
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    // } else if (index == 1) {
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WishlistScreen()));
    // } else if (index == 2) {
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyCourseScreen()));
    // }
  }

  @override
  Widget build(BuildContext context) {
    primaryColor = Theme.of(context).primaryColor;
    textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false, // Align title to start as per image
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => EditProfileScreen(),
                  ),
                );
              },
              child: Text(
                'Edit Profile',
                style: textTheme.bodyLarge?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Row(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundImage: NetworkImage(
                    'https://picsum.photos/100/100', // Placeholder profile image
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Henry',
                      style: textTheme.headlineSmall?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'johnhenry99@gmail.com',
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // General Section
            Text(
              'General',
              style: textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileOptionItem(
              icon: Icons.translate,
              title: 'Language',
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => LanguageScreen(),
                  ),
                );
              },
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 18,
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileOptionItem(
              icon: Icons.notifications_none,
              title: 'Notification',
              onTap: () {
                setState(() {
                  _isNotificationOn = !_isNotificationOn;
                });
              },
              trailing: Switch(
                value: _isNotificationOn,
                splashRadius: 18,
                onChanged: (value) {
                  setState(() {
                    _isNotificationOn = value;
                  });
                },
                activeColor: Colors.white, // Active thumb color
                activeTrackColor: primaryColor, // Active track color
                inactiveThumbColor: Colors.grey, // Inactive thumb color
                inactiveTrackColor: Colors.grey[300], // Inactive track color
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileOptionItem(
              icon: Icons.nights_stay,
              title: 'Night Mode',
              onTap: () {
                setState(() {
                  _isNightModeOn = !_isNightModeOn;
                });
              },
              trailing: Switch(
                value: _isNightModeOn,
                onChanged: (value) {
                  setState(() {
                    _isNightModeOn = value;
                  });
                },
                activeColor: Colors.white, // Active thumb color
                activeTrackColor: primaryColor, // Active track color
                inactiveThumbColor: Colors.grey, // Inactive thumb color
                inactiveTrackColor: Colors.grey[300], // Inactive track color
              ),
            ),
            const SizedBox(height: 32),

            // Other Section
            Text(
              'Other',
              style: textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileOptionItem(
              icon: Icons.help_outline,
              title: 'FAQ',
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(pageBuilder: (_, __, ___) => FaqScreen()),
                );
              },
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 18,
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileOptionItem(
              icon: Icons.volume_up,
              title: 'Help & Support',
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => HelpAndSupportScreen(),
                  ),
                );
              },
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 18,
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileOptionItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(pageBuilder: (_, __, ___) => LoginScreen()),
                );
              },
              // No trailing icon needed for logout as per image
            ),
            const SizedBox(height: 40),

            // Version Info
            Center(
              child: Text(
                '2021 SkillUp • Ver 1.0',
                style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 20), // Space for bottom navigation bar
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final bool hasSwitch = trailing is Switch;

    final rowContent = Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );

    // Use InkWell only if there's no Switch
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child:
          hasSwitch
              ? rowContent // Don't use InkWell for Switch rows
              : Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: rowContent,
                  ),
                ),
              ),
    );
  }
}

class NavbarWishlist extends StatefulWidget {
  const NavbarWishlist({super.key});

  @override
  State<NavbarWishlist> createState() => _NavbarWishlistState();
}

class _NavbarWishlistState extends State<NavbarWishlist> {
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
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const CourseDetailScreen(),
            ),
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

class NavbarMyCourse extends StatefulWidget {
  const NavbarMyCourse({super.key});

  @override
  State<NavbarMyCourse> createState() => _NavbarMyCourseState();
}

class _NavbarMyCourseState extends State<NavbarMyCourse> {
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

  final List<Map<String, dynamic>> _myCourses = [
    {
      'image': 'https://picsum.photos/id/1045/100/80',
      'title': 'Complete 3D Animation Using Blender',
      'author': 'Jane Cooper',
      'members': 420,
      'num_courses': 43,
      'status': 'not_started', // or 'completed', 'in_progress'
      'progress': 0.0,
    },
    {
      'image': 'https://picsum.photos/id/237/100/80',
      'title': 'Fitness Training : Basic Workouts & Body Building',
      'author': 'Esther Howard',
      'members': 100,
      'num_courses': 16,
      'status': 'completed',
      'progress': 1.0, // 100%
    },
    {
      'image': 'https://picsum.photos/id/1014/100/80',
      'title': 'Advance Trading : Forex Trading/Stock Trading',
      'author': 'Courtney Henry',
      'members': 221,
      'num_courses': 12,
      'status': 'in_progress',
      'progress': 0.52, // 52%
    },
    {
      'image': 'https://picsum.photos/id/100/100/80',
      'title': 'Introduction to Digital Photography',
      'author': 'Emily White',
      'members': 350,
      'num_courses': 25,
      'status': 'in_progress',
      'progress': 0.70, // 70%
    },
  ];

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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: primaryColor,
            size: 20,
          ), // Black icon, transparent background
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        scrolledUnderElevation: 0,
        title: Text(
          'My Course',
          style: TextStyle(
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
              color: Colors.black,
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

          // My Course List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              itemCount: _myCourses.length,
              itemBuilder: (context, index) {
                final course = _myCourses[index];
                return _buildMyCourseCard(
                  context,
                  course,
                  primaryColor,
                  textTheme,
                );
              },
              separatorBuilder:
                  (context, index) =>
                      const SizedBox(height: 16), // Spacing between cards
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyCourseCard(
    BuildContext context,
    Map<String, dynamic> course,
    Color primaryColor,
    TextTheme textTheme,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              width: 0.5,
              color: Colors.grey.withValues(alpha: 0.5),
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
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          course['image']!,
                          height: 64,
                          width: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course['title']!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
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
                            Row(
                              children: [
                                Icon(
                                  Icons.people_alt,
                                  color: Colors.grey[600],
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                // Wrap with Flexible or Expanded to prevent overflow
                                Flexible(
                                  child: Text(
                                    '${course['members']} Members',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.grey[600],
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                // Wrap with Flexible or Expanded to prevent overflow
                                Flexible(
                                  child: Text(
                                    '${course['num_courses']} Courses',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (course['status'] == 'not_started')
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {
                                    // Handle start course button tap
                                    print(
                                      'Start course tapped: ${course['title']}',
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Start Course',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            else if (course['status'] == 'completed')
                              Row(
                                children: [
                                  Text(
                                    'Complete',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Explicitly constrain width if overflow still occurs, or ensure enough space
                                  Text(
                                    '${(course['progress'] * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    // Removed softWrap: false and overflow: TextOverflow.visible, let Expanded handle it
                                  ),
                                ],
                              ),
                            if (course['status'] == 'in_progress')
                              Row(
                                children: [
                                  Text(
                                    'Course is in progress',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${(course['progress'] * 100).toInt()}%',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                    // Removed softWrap: false and overflow: TextOverflow.visible
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Progress Indicator (replacing the slider)
                  if (course['status'] == 'in_progress' ||
                      course['status'] == 'completed')
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: LinearProgressIndicator(
                        value: course['progress'],
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        minHeight: 6.0,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

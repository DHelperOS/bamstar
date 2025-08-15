import 'package:canwa/Screens/edit_profile_screen.dart';
import 'package:canwa/Screens/faq_screen.dart';
import 'package:canwa/Screens/help_and_support_screen.dart';
import 'package:canwa/Screens/language_screen.dart';
import 'package:canwa/Screens/login_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

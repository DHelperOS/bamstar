import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/screens/activity_screen.dart';
import 'package:socialPixel/screens/inbox_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String welcomeText;
  final String userName;
  final String profileImageUrl;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationsPressed;
  final bool showNotificationBadge;

  const CustomAppBar({
    Key? key,
    this.welcomeText = 'Welcome Back,',
    this.userName = 'Josse Makima',
    this.profileImageUrl = 'https://picsum.photos/id/237/200/200',
    this.onSearchPressed,
    this.onNotificationsPressed,
    this.showNotificationBadge = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 80, // Adjust height as needed
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                profileImageUrl, // Placeholder profile image
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  welcomeText,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed:
                  onSearchPressed ??
                  () {
                    // Handle search
                    // print('Search pressed');
                  },
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.black,
                  ),
                  onPressed:
                      onNotificationsPressed ??
                      () {
                        // Handle notifications
                        // print('Notifications pressed');
                      },
                ),
                if (showNotificationBadge)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red, // Notification indicator color
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class CustomAppbar2 extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onCameraPressed;
  final VoidCallback? onLikesPressed;
  final VoidCallback? onChatPressed;

  const CustomAppbar2({
    Key? key,
    this.onCameraPressed,
    this.onLikesPressed,
    this.onChatPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.camera_alt_outlined,
          color: Colors.black,
          size: 28,
        ),
        onPressed:
            onCameraPressed ??
            () {
              // Handle camera tap
            },
      ),
      title: Text(
        'TokTok',
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800, // Extra-bold
          fontSize: 24,
          color: Colors.black,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.favorite_border,
            color: Colors.black,
            size: 28,
          ),
          onPressed:
              onLikesPressed ??
              () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ActivityScreen(),
                  ),
                );
              },
        ),
        IconButton(
          icon: const Icon(
            Icons.chat_bubble_outline,
            color: Colors.black,
            size: 28,
          ),
          onPressed:
              onChatPressed ??
              () {
                Navigator.of(context).push(
                  PageRouteBuilder(pageBuilder: (_, __, ___) => InboxScreen()),
                );
              },
        ),
        const SizedBox(width: 8), // Padding on the right
      ],
      centerTitle: false, // Ensure title alignment
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

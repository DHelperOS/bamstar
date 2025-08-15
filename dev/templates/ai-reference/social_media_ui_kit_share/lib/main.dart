import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:socialPixel/screens/add_story_screen.dart';
import 'package:socialPixel/screens/audio_screen.dart';
import 'package:socialPixel/screens/call_screen.dart';
import 'package:socialPixel/screens/close_friends_screen.dart';
import 'package:socialPixel/screens/comment_section_screen.dart';
import 'package:socialPixel/screens/feed_screen.dart';
import 'package:socialPixel/screens/filter_screen.dart';
import 'package:socialPixel/screens/follow_someone_screen.dart';
import 'package:socialPixel/screens/hashtag_detail_screen.dart';
import 'package:socialPixel/screens/inbox_screen.dart';
import 'package:socialPixel/screens/login_screen.dart';
import 'package:socialPixel/screens/message_requests_screen.dart';
import 'package:socialPixel/screens/new_post_gallery_screen.dart';
import 'package:socialPixel/screens/new_post_screen.dart';
import 'package:socialPixel/screens/onboarding_screen.dart';
import 'package:socialPixel/screens/profile_screen.dart';
import 'package:socialPixel/screens/qr_code_screen.dart';
import 'package:socialPixel/screens/search_results_screen.dart';
import 'package:socialPixel/screens/search_screen.dart';
import 'package:socialPixel/screens/signup_screen.dart';
import 'package:socialPixel/screens/activity_screen.dart';
import 'package:socialPixel/screens/chat_screen.dart';
import 'package:socialPixel/screens/explore_saved_screen.dart';
import 'package:socialPixel/screens/fill_your_profile_screen.dart';
import 'package:socialPixel/screens/forgot_password_screen.dart';
import 'package:socialPixel/screens/location_detail_screen.dart';

import 'package:socialPixel/screens/search_detail_screen.dart';
import 'package:socialPixel/screens/settings_screen.dart';
import 'package:socialPixel/screens/shorts_screen.dart';
import 'package:socialPixel/screens/story_viewer_screen.dart';
import 'package:pixel_preview/pixel_app/pixel_group.dart';

import 'package:pixel_preview/pixel_preview.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:socialPixel/screens/your_activity_screen.dart'; // Import the new YourActivityScreen

// Define allPixelGroups at the top-level
final List<PixelGroup> allPixelGroups = [
  // Renamed _allPixelGroups to allPixelGroups
  PixelGroup(
    title: "Authentication/Onboarding",
    children: [
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: LoginScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: SignupScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: OnboardingScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: ForgotPasswordScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: FillYourProfileScreen(),
      ),
    ],
  ),
  PixelGroup(
    title: "Core Feeds/Content",
    children: [
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: MainScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: ShortsScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: StoryViewerScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: AddStoryScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: NewPostScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: NewPostGalleryScreen(),
      ),
    ],
  ),
  PixelGroup(
    title: "Messaging/Communication",
    children: [
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: ChatScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: InboxScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: MessageRequestsScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: CallScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: AudioScreen(),
      ),
    ],
  ),
  PixelGroup(
    title: "Search/Discovery",
    children: [
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: SearchScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: SearchDetailScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: SearchResultsScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: HashtagDetailScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: LocationDetailScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: ExploreSavedScreen(),
      ),
    ],
  ),
  PixelGroup(
    title: "Profile/User Management",
    children: [
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: ProfileScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: ActivityScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: YourActivityScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: FollowSomeoneScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: CloseFriendsScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: SettingsScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: QrCodeScreen(),
      ),
    ],
  ),
  PixelGroup(
    title: "Post Interaction/Creation",
    children: [
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: CommentSectionScreen(),
      ),
      PixelPreview(
        presets: ScreenPresets(),
        enabled: true,
        child: FilterScreen(),
      ),
    ],
  ),
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  List<PixelGroup> _getGroupsForRoute() {
    if (kIsWeb) {
      final uri = Uri.base;
      final pathSegments = uri.pathSegments;

      // Check for /preview/<groupKey>
      // Example: http://localhost:port/preview/auth
      // pathSegments will be ['preview', 'auth']
      if (pathSegments.length == 2 && pathSegments[0] == 'preview') {
        final groupKey = pathSegments[1].toLowerCase();
        String? targetTitle;
        switch (groupKey) {
          case 'auth':
            targetTitle = "Authentication/Onboarding";
            break;
          case 'core':
            targetTitle = "Core Feeds/Content";
            break;
          case 'messaging':
            targetTitle = "Messaging/Communication";
            break;
          case 'search':
            targetTitle = "Search/Discovery";
            break;
          case 'profile':
            targetTitle = "Profile/User Management";
            break;
          case 'post':
            targetTitle = "Post Interaction/Creation";
            break;
        }

        if (targetTitle != null) {
          PixelGroup? selectedGroup; // Declare as nullable
          for (final group in allPixelGroups) {
            // Use allPixelGroups
            if (group.title == targetTitle) {
              selectedGroup = group;
              break;
            }
          }
          // If a valid groupKey led to a targetTitle, but the group isn't in _allPixelGroups
          // or if selectedGroup is null (not found), return an empty list.
          return selectedGroup != null ? [selectedGroup] : [];
        } else {
          // Invalid groupKey (e.g., /preview/unknownkey), show an empty PixelApp
          return [];
        }
      } else if (pathSegments.length == 1 && pathSegments[0] == 'preview') {
        // Path is just "/preview" (e.g. http://localhost:port/preview)
        // No specific group requested for preview, so show an empty PixelApp.
        return [];
      }
      // For any other web path (e.g., "/", "/some/other/path"), show all groups.
      // This ensures the root URL ("http://localhost:port/") displays all groups.
    }
    // Default: not web, or a web path not handled above (like root "/"), show all groups.
    return List.from(allPixelGroups); // Return a copy using allPixelGroups
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF7356FF); // User's chosen primary color
    final List<PixelGroup> currentGroups = _getGroupsForRoute();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Socialize',
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: ThemeData.light().brightness,
          onPrimary: Colors.white,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Changed to transparent
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: primaryColor),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: const BorderSide(color: primaryColor),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      ),

      home: PixelApp(
        iFrameMode: true,
        groups: currentGroups, // Use the dynamically determined groups
      ),
    );
  }
}

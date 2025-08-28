import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Request notification permission and return the permission status
  Future<bool> requestNotificationPermission() async {
    try {
      // For iOS, request permission using FirebaseMessaging
      if (Platform.isIOS) {
        final settings = await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        return settings.authorizationStatus == AuthorizationStatus.authorized ||
               settings.authorizationStatus == AuthorizationStatus.provisional;
      }
      
      // For Android, use permission_handler
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        return status == PermissionStatus.granted;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Get the current notification permission status
  Future<bool> isNotificationPermissionGranted() async {
    try {
      if (Platform.isIOS) {
        final settings = await _firebaseMessaging.getNotificationSettings();
        return settings.authorizationStatus == AuthorizationStatus.authorized ||
               settings.authorizationStatus == AuthorizationStatus.provisional;
      }
      
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        return status == PermissionStatus.granted;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      return false;
    }
  }

  /// Get FCM token from Firebase
  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Get or create a consistent device ID
  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    
    if (deviceId == null) {
      // Generate a new device ID and save it
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('device_id', deviceId);
    }
    
    return deviceId;
  }

  /// Save FCM token to Supabase database
  Future<bool> saveFCMTokenToDatabase(String fcmToken) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return false;
      }

      // Get consistent device ID
      final deviceId = await _getDeviceId();
      
      // Determine platform
      String platform = 'web';
      if (Platform.isAndroid) platform = 'android';
      if (Platform.isIOS) platform = 'ios';

      // First, deactivate any existing tokens for this device
      await _supabase
          .from('push_tokens')
          .update({'is_active': false})
          .eq('user_id', user.id)
          .eq('device_id', deviceId);

      // Insert or update the FCM token
      final response = await _supabase
          .from('push_tokens')
          .upsert({
            'user_id': user.id,
            'fcm_token': fcmToken,
            'device_id': deviceId,
            'platform': platform,
            'is_active': true,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'fcm_token');

      debugPrint('FCM token saved successfully: $response');
      return true;
    } catch (e) {
      debugPrint('Error saving FCM token to database: $e');
      return false;
    }
  }

  /// Handle the complete notification setup flow
  /// This is called when user agrees to push notifications
  Future<bool> setupNotifications() async {
    try {
      // Step 1: Request permission
      final permissionGranted = await requestNotificationPermission();
      if (!permissionGranted) {
        debugPrint('Notification permission denied');
        return false;
      }

      // Step 2: Get FCM token
      final fcmToken = await getFCMToken();
      if (fcmToken == null) {
        debugPrint('Failed to get FCM token');
        return false;
      }

      // Step 3: Save token to database
      final tokenSaved = await saveFCMTokenToDatabase(fcmToken);
      if (!tokenSaved) {
        debugPrint('Failed to save FCM token to database');
        return false;
      }

      // Step 4: Set up token refresh listener
      _setupTokenRefreshListener();

      debugPrint('Notification setup completed successfully');
      return true;
    } catch (e) {
      debugPrint('Error setting up notifications: $e');
      return false;
    }
  }

  /// Set up listener for FCM token refresh
  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM token refreshed: $newToken');
      await saveFCMTokenToDatabase(newToken);
    });
  }

  /// Clean up tokens for the current user (when logging out)
  Future<void> cleanupUserTokens() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase
            .from('push_tokens')
            .update({'is_active': false})
            .eq('user_id', user.id);
        debugPrint('User tokens deactivated');
      }
    } catch (e) {
      debugPrint('Error cleaning up user tokens: $e');
    }
  }

  /// Initialize notification service (call this in main.dart)
  Future<void> initialize() async {
    try {
      // Initialize Firebase Messaging
      await _firebaseMessaging.setAutoInitEnabled(true);
      
      // Set up foreground notification handling
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Received foreground message: ${message.messageId}');
        // Handle foreground notifications here
      });

      // Set up background message handling
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      debugPrint('Notification service initialized');
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  // Handle background notifications here
}
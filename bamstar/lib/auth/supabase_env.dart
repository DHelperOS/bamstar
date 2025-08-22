// Supabase & provider environment configuration via flutter_dotenv
// Make sure to provide a .env file (added to pubspec assets) with keys:
//   SUPABASE_URL=...
//   SUPABASE_ANON_KEY=...
//   KAKAO_NATIVE_APP_KEY=...
// The file is loaded at app start in main.dart.

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

// Support both SUPABASE_* and NEXT_PUBLIC_SUPABASE_* naming conventions
String get supabaseUrl =>
    dotenv.maybeGet('SUPABASE_URL') ??
    dotenv.maybeGet('NEXT_PUBLIC_SUPABASE_URL') ??
    '';
String get supabaseAnonKey =>
    dotenv.maybeGet('SUPABASE_ANON_KEY') ??
    dotenv.maybeGet('NEXT_PUBLIC_SUPABASE_ANON_KEY') ??
    '';

// Kakao native app key is used when initializing the Kakao native SDK on mobile.
// If you only use Supabase External Provider (web OAuth redirect), Kakao's
// server-side client config in Supabase may be sufficient; the native key is
// required for native SDK features or native login flows.
String get kakaoNativeAppKey => dotenv.maybeGet('KAKAO_NATIVE_APP_KEY') ?? '';

// Google OAuth client IDs (web/android/ios).
// NOTE: This project now uses Firebase configuration files for native
// client IDs. Keep these getters for backward compatibility and for web
// usage, but prefer using the platform-specific firebase files:
//  - iOS:  ios/Runner/GoogleService-Info.plist
//  - Android: android/app/google-services.json
// If the env var is empty, native client IDs will be provided by the
// Firebase config at runtime (no env change required).
String get googleWebClientId =>
    dotenv.maybeGet('NEXT_PUBLIC_GOOGLE_WEB_CLIENT_ID') ??
    dotenv.maybeGet('GOOGLE_WEB_CLIENT_ID') ??
    '';

String get googleAndroidClientId =>
    dotenv.maybeGet('GOOGLE_ANDROID_CLIENT_ID') ?? '';

String get googleIosClientId => dotenv.maybeGet('GOOGLE_IOS_CLIENT_ID') ?? '';

// OAuth redirect URI used for Supabase external provider flows.
// Priority: environment variable OAUTH_REDIRECT_URI, then web Uri.base, then
// emulator-friendly localhost values.
String get oauthRedirectUri {
  final fromEnv = dotenv.maybeGet('OAUTH_REDIRECT_URI');
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;

  if (kIsWeb) return Uri.base.replace(path: '/').toString();

  // Android emulator cannot reach host's localhost; use 10.0.2.2 for Android
  // emulator, otherwise default to localhost for simulators/dev machines.
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000/';
  }
  return 'http://localhost:3000/';
}

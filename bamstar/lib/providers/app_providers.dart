import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supabase 클라이언트 Provider
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Secure Storage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// SharedPreferences Provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// 앱 초기화 상태 Provider
final appInitializationProvider = FutureProvider<bool>((ref) async {
  try {
    // Supabase 세션 체크
    final supabase = ref.watch(supabaseProvider);
    final session = supabase.auth.currentSession;
    
    // 필요한 초기화 작업
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    
    return session != null;
  } catch (e) {
    return false;
  }
});

/// 현재 사용자 ID Provider
final currentUserIdProvider = Provider<String?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.currentUser?.id;
});

/// 앱 전역 에러 핸들러
final errorHandlerProvider = StateNotifierProvider<ErrorHandler, ErrorState>(
  (ref) => ErrorHandler(),
);

class ErrorHandler extends StateNotifier<ErrorState> {
  ErrorHandler() : super(const ErrorState());

  void setError(String message, {String? code}) {
    state = ErrorState(message: message, code: code, hasError: true);
  }

  void clearError() {
    state = const ErrorState();
  }
}

class ErrorState {
  final String? message;
  final String? code;
  final bool hasError;

  const ErrorState({
    this.message,
    this.code,
    this.hasError = false,
  });
}
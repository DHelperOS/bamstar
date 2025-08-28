import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../app_providers.dart';

/// 인증 상태 AsyncNotifier - Riverpod 3.0 권장 패턴
class AuthNotifier extends AsyncNotifier<AuthState> {
  late final Logger _log;
  late final SupabaseClient _supabase;
  
  @override
  Future<AuthState> build() async {
    _log = Logger('AuthNotifier');
    _supabase = ref.watch(supabaseProvider);
    
    // 현재 세션 확인
    final session = _supabase.auth.currentSession;
    if (session != null) {
      return AuthState(
        user: session.user,
        session: session,
        isAuthenticated: true,
      );
    }
    
    return const AuthState();
  }
  
  // Track GoogleSignIn.initialize one-time call per app run.
  static bool _googleInitialized = false;
  
  /// Google 로그인 - Native SDK 사용
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        // Web client ID from Google Cloud Console
        const webClientId = '333694384981-b76kgbjmtr06qvsmv1cd5jq3t4pv6gad.apps.googleusercontent.com';
        
        // Initialize Google Sign-In only once per app run
        if (!_googleInitialized) {
          await GoogleSignIn.instance.initialize(serverClientId: webClientId);
          _googleInitialized = true;
        }
        
        // Authenticate with Google
        final account = await GoogleSignIn.instance.authenticate();
        final auth = account.authentication;
        final idToken = auth.idToken;
        
        _log.info('Google native sign-in: idToken present=${idToken != null}');
        
        if (idToken == null) {
          throw Exception('No ID Token from Google');
        }
        
        // Exchange Google ID token with Supabase
        final authRes = await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: null,
        );
        
        final session = authRes.session;
        final user = authRes.user;
        
        if (user == null) {
          throw Exception('Supabase did not return a user after id token exchange');
        }
        
        // Post sign-in actions
        await _postSignIn(user);
        
        // Analytics tracking
        try {
          // Add analytics tracking here if needed
          _log.info('Google sign-in successful for user: ${user.id}');
        } catch (_) {}
        
        return AuthState(
          user: user,
          session: session,
          isAuthenticated: true,
        );
        
      } catch (e, stack) {
        _log.severe('Native Google sign-in failed', e, stack);
        
        // Handle specific error cases
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('cancel')) {
          throw AuthException('로그인이 취소되었습니다');
        } else if (errorMessage.contains('network')) {
          throw AuthException('네트워크 연결을 확인해주세요');
        } else {
          throw AuthException('Google 로그인 실패: ${e.toString()}');
        }
      }
    });
  }
  
  /// Apple 로그인
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        
        final idToken = credential.identityToken;
        if (idToken == null) {
          throw Exception('No ID token from Apple');
        }
        
        final response = await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.apple,
          idToken: idToken,
        );
        
        if (response.user == null) {
          throw Exception('Failed to sign in with Apple');
        }
        
        await _postSignIn(response.user!);
        
        return AuthState(
          user: response.user,
          session: response.session,
          isAuthenticated: true,
        );
      } catch (e, stack) {
        _log.severe('Apple sign in failed', e, stack);
        throw AuthException('Apple 로그인 실패: ${e.toString()}');
      }
    });
  }
  
  /// Kakao 로그인
  Future<void> signInWithKakao() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        if (kIsWeb) {
          // 웹에서는 Supabase OAuth 사용
          await _supabase.auth.signInWithOAuth(
            OAuthProvider.kakao,
            redirectTo: 'YOUR_REDIRECT_URL',
          );
          return const AuthState(); // OAuth는 리다이렉트 후 처리
        }
        
        // 모바일에서는 Kakao SDK 사용
        bool isInstalled = await kakao.isKakaoTalkInstalled();
        
        if (isInstalled) {
          try {
            await kakao.UserApi.instance.loginWithKakaoTalk();
          } catch (e) {
            // 카카오톡 로그인 실패시 웹뷰로 시도
            await kakao.UserApi.instance.loginWithKakaoAccount();
          }
        } else {
          await kakao.UserApi.instance.loginWithKakaoAccount();
        }
        
        // 액세스 토큰 가져오기
        final token = await kakao.TokenManagerProvider.instance.manager.getToken();
        final accessToken = token?.accessToken;
        
        if (accessToken == null) {
          throw Exception('No access token from Kakao');
        }
        
        final response = await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.kakao,
          idToken: accessToken,
        );
        
        if (response.user == null) {
          throw Exception('Failed to sign in with Kakao');
        }
        
        await _postSignIn(response.user!);
        
        return AuthState(
          user: response.user,
          session: response.session,
          isAuthenticated: true,
        );
      } catch (e, stack) {
        _log.severe('Kakao sign in failed', e, stack);
        throw AuthException('Kakao 로그인 실패: ${e.toString()}');
      }
    });
  }
  
  /// 로그아웃
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _supabase.auth.signOut();
      
      // Kakao 로그아웃
      try {
        await kakao.UserApi.instance.logout();
      } catch (_) {}
      
      // Google 로그아웃 - handled by Supabase
      // OAuth logout is handled by Supabase's signOut
      
      return const AuthState();
    });
  }
  
  /// 로그인 후 처리
  Future<void> _postSignIn(User user) async {
    try {
      // 디바이스 정보 저장
      final storage = ref.read(secureStorageProvider);
      await storage.write(key: 'user_id', value: user.id);
      
      // 사용자 프로필 업데이트
      await _supabase.from('users').upsert({
        'id': user.id,
        'email': user.email,
        'last_sign_in': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      _log.info('User signed in: ${user.id}');
    } catch (e) {
      _log.warning('Post sign in processing failed', e);
    }
  }
}

/// 인증 상태
class AuthState {
  final User? user;
  final Session? session;
  final bool isAuthenticated;
  
  const AuthState({
    this.user,
    this.session,
    this.isAuthenticated = false,
  });
  
  String? get userId => user?.id;
  String? get email => user?.email;
  
  AuthState copyWith({
    User? user,
    Session? session,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      session: session ?? this.session,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// 인증 예외
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => message;
}

/// 인증 Provider - AsyncNotifierProvider 사용
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// 인증 상태 스트림 Provider
final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  
  return supabase.auth.onAuthStateChange.map((event) {
    final session = event.session;
    if (session != null) {
      return AuthState(
        user: session.user,
        session: session,
        isAuthenticated: true,
      );
    }
    return const AuthState();
  });
});

/// 현재 사용자 Provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).value?.user;
});

/// 인증 여부 Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).value?.isAuthenticated ?? false;
});
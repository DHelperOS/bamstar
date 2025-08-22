import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:bamstar/auth/supabase_env.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'
    as kakao_user;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bamstar/utils/global_toast.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:bamstar/services/analytics.dart';
// material and toasts are used in UI layer; this service doesn't need them

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

class AuthState {
  final Session? session;
  final String? error;
  const AuthState({this.session, this.error});
}

class AuthController extends StateNotifier<AsyncValue<AuthState>> {
  AuthController(this.storage) : super(const AsyncValue.data(AuthState())) {
    log = Logger('AuthController');
  }

  final FlutterSecureStorage storage;
  late final Logger log;

  String _koreanAuthMessage(Object e) {
    final text = e.toString();

    // Try to extract an explicit error code from JSON-like payloads or known patterns.
    String? extractCode(String input) {
      final lower = input.toLowerCase();
      // JSON style: "error":"invalid_grant"
      final jsonMatch = RegExp(
        r'"error"\s*[:=]\s*"?([a-z_0-9]+)"?',
        caseSensitive: false,
      ).firstMatch(input);
      if (jsonMatch != null) return jsonMatch.group(1);

      // key=value style
      final kvMatch = RegExp(
        r'error=([a-z_0-9]+)',
        caseSensitive: false,
      ).firstMatch(input);
      if (kvMatch != null) return kvMatch.group(1);

      // explicit token names often appear directly
      final simpleMatch = RegExp(
        r'\b(invalid_grant|invalid_otp|account_already_exists|already_exists|user_not_found|invalid_token|expired_token|token_revoked|unauthorized|invalid_request|rate_limited|password_strength|confirmation_required)\b',
        caseSensitive: false,
      ).firstMatch(lower);
      if (simpleMatch != null) return simpleMatch.group(1);

      return null;
    }

    final code = extractCode(text);
    final Map<String, String> codeMap = {
      'invalid_grant': '로그인 정보가 올바르지 않습니다. 이메일/비밀번호를 확인해 주세요.',
      'invalid_otp': '인증 코드가 잘못되었거나 만료되었습니다. 다시 시도해 주세요.',
      'account_already_exists': '이미 등록된 계정입니다. 다른 계정으로 시도해 주세요.',
      'already_exists': '이미 등록된 계정입니다. 다른 계정으로 시도해 주세요.',
      'user_not_found': '등록된 사용자를 찾을 수 없습니다.',
      'invalid_token': '유효하지 않은 인증 토큰입니다. 다시 로그인해 주세요.',
      'expired_token': '인증 토큰이 만료되었습니다. 다시 로그인해 주세요.',
      'token_revoked': '인증 토큰이 취소되었습니다. 다시 로그인해 주세요.',
      'unauthorized': '권한이 없습니다. 로그인 상태를 확인해 주세요.',
      'invalid_request': '잘못된 요청입니다. 입력값을 확인해 주세요.',
      'rate_limited': '요청이 많습니다. 잠시 후 다시 시도해 주세요.',
      'password_strength': '비밀번호가 안전하지 않습니다. 규칙을 확인해 주세요.',
      'confirmation_required': '이메일 확인이 필요합니다. 메일함을 확인해 주세요.',
    };

    if (code != null && codeMap.containsKey(code.toLowerCase())) {
      return codeMap[code.toLowerCase()]!;
    }

    // Fallback to safer substring checks (kept minimal)
    final s = text.toLowerCase();
    // Kakao-specific common errors
    if (s.contains('notsupporterror') &&
        (s.contains('kakaotalk is installed but not connected') ||
            s.contains('not connected'))) {
      return '카카오톡에 로그인되어 있지 않습니다. 카카오톡 앱에 로그인하시거나, 카카오 계정으로 로그인해 주세요.';
    }
    if (s.contains('cancel') || s.contains('canceled by user')) {
      return '로그인이 취소되었습니다.';
    }
    if (s.contains('accessdenied') || s.contains('permission')) {
      return '권한이 거부되었습니다. 설정에서 권한을 허용해 주세요.';
    }
    if (s.contains('kakaotalk') && s.contains('not installed')) {
      return '카카오톡이 설치되어 있지 않습니다. 카카오 계정으로 로그인해 주세요.';
    }
    if (s.contains('invalid login') || s.contains('invalid credentials')) {
      return '로그인 정보가 올바르지 않습니다. 이메일/비밀번호를 확인해 주세요.';
    }
    if (s.contains('not linked') && s.contains('oauth')) {
      return '외부 계정이 연결되어 있지 않습니다. 다른 로그인 방법을 시도해 주세요.';
    }
    if (s.contains('serverclientid') || s.contains('serverclientid must')) {
      return '앱 설정이 올바르지 않습니다. Google Cloud Console의 Android OAuth 클라이언트와 .env(GOOGLE_ANDROID_CLIENT_ID, NEXT_PUBLIC_GOOGLE_WEB_CLIENT_ID)를 확인하세요.';
    }

    // Generic fallback: keep short and Korean only
    return '인증 오류가 발생했습니다. 자세한 내용은 로그를 확인하세요.';
  }

  SupabaseClient get _supabase {
    try {
      return Supabase.instance.client;
    } catch (e, st) {
      log.severe(
        'Attempted to access Supabase.instance.client before initialization: $e',
        e,
        st,
      );
      rethrow;
    }
  }

  Future<void> ensureInitialized({
    required String url,
    required String anonKey,
  }) async {
    if (!_isInitialized()) {
      try {
        await Supabase.initialize(url: url, anonKey: anonKey);
        log.info('Supabase.initialize called from ensureInitialized');
      } catch (e, st) {
        log.severe(
          'Failed to initialize Supabase in ensureInitialized: $e',
          e,
          st,
        );
        rethrow;
      }
    }
  }

  bool _isInitialized() {
    try {
      Supabase.instance.client.auth;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      // Debug: log client IDs and redirect URI to help diagnose redirect issues
      try {
        final envWeb = Uri.base.replace(path: '/').toString();
        log.info(
          'Google sign-in: webRedirect=$oauthRedirectUri envWeb=$envWeb',
        );
      } catch (_) {}
      if (kIsWeb) {
        // Web: use Supabase external provider flow
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: oauthRedirectUri,
        );
        final session = _supabase.auth.currentSession;
        if (session != null) {
          await _persistSession(session);
          state = AsyncValue.data(AuthState(session: session));
        } else {
          state = const AsyncValue.data(AuthState());
        }
      } else {
        // Mobile: native Google Sign-In -> exchange tokens with Supabase
        try {
          final webClientId = googleWebClientId;
          final androidClientId = googleAndroidClientId;
          final iosClientId = googleIosClientId;

          String? clientIdForInit;
          if (defaultTargetPlatform == TargetPlatform.iOS &&
              iosClientId.isNotEmpty) {
            clientIdForInit = iosClientId;
          } else if (defaultTargetPlatform == TargetPlatform.android &&
              androidClientId.isNotEmpty) {
            clientIdForInit = androidClientId;
          } else {
            clientIdForInit = null;
          }

          // Guard: platform client id must be set for reliable native token issuance
          if ((defaultTargetPlatform == TargetPlatform.android &&
                  (androidClientId.isEmpty)) ||
              (defaultTargetPlatform == TargetPlatform.iOS &&
                  (iosClientId.isEmpty))) {
            throw Exception(
              'Missing platform Client ID. Set GOOGLE_ANDROID_CLIENT_ID (Android) or GOOGLE_IOS_CLIENT_ID (iOS) in .env.',
            );
          }

          log.info(
            'Initializing GoogleSignIn with clientIdForInit=${clientIdForInit ?? '<none>'} serverClientId=${webClientId.isNotEmpty ? webClientId : '<none>'} androidClientId=${androidClientId.isNotEmpty ? androidClientId : '<none>'}',
          );

          // Clear any previous GoogleSignIn state to avoid reauth failures due to stale sessions
          try {
            await GoogleSignIn.instance.disconnect();
          } catch (_) {}
          try {
            await GoogleSignIn.instance.signOut();
          } catch (_) {}
          // First attempt: initialize including serverClientId if available
          await GoogleSignIn.instance.initialize(
            clientId: clientIdForInit,
            serverClientId: webClientId.isNotEmpty ? webClientId : null,
          );

          // Single attempt; on Android serverClientId (web client id) is required to obtain idToken.
          final account = await GoogleSignIn.instance.authenticate();

          // Read authentication tokens from the account
          final auth = account.authentication;
          final idToken = auth.idToken;
          // Access token is not provided by google_sign_in on Android/iOS; idToken is sufficient for Supabase.
          final String? accessToken = null;

          log.info('Google native sign-in: idToken present=${idToken != null}');

          if (idToken == null) throw Exception('No ID Token from Google');

          final authRes = await _supabase.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          );

          final session = authRes.session ?? _supabase.auth.currentSession;
          if (session != null) {
            await _persistSession(session);
            // Post sign-in: ensure profile/device rows
            await _postSignIn(session);
            // Analytics: record successful sign-in
            try {
              await AnalyticsService.logEvent(
                'login',
                params: {'method': 'google', 'user_id': session.user.id},
              );
              await AnalyticsService.setUserId(session.user.id);
            } catch (_) {}
            state = AsyncValue.data(AuthState(session: session));
            return;
          }

          // If exchange didn't return a session, surface as error
          throw Exception(
            'Supabase did not return a session after id token exchange',
          );
        } catch (e, st) {
          log.severe('Native Google sign-in failed: $e', e, st);
          final message = _koreanAuthMessage(e);
          try {
            showGlobalToast(
              title: '로그인 실패',
              message: message,
              backgroundColor: Colors.redAccent,
            );
          } catch (_) {}
          state = AsyncValue.error(e, st);
        }
      }
    } catch (e, st) {
      log.severe('Google sign-in failed: $e', e, st);
      try {
        showGlobalToast(
          title: '로그인 오류',
          message: _koreanAuthMessage(e),
          backgroundColor: Colors.redAccent,
        );
      } catch (_) {}
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      final appleRes = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final idToken = appleRes.identityToken;
      final nonce = appleRes.state; // optional
      if (idToken == null) throw Exception('Apple ID token is null');
      final authRes = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: nonce,
      );
      final session = authRes.session ?? _supabase.auth.currentSession;
      if (session != null) {
        await _persistSession(session);
        await _postSignIn(session);
        state = AsyncValue.data(AuthState(session: session));
      } else {
        state = const AsyncValue.data(AuthState());
      }
    } catch (e, st) {
      log.severe('Apple sign-in failed: $e', e, st);
      try {
        showGlobalToast(
          title: '로그인 오류',
          message: _koreanAuthMessage(e),
          backgroundColor: Colors.redAccent,
        );
      } catch (_) {}
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithKakao() async {
    state = const AsyncValue.loading();
    try {
      if (kIsWeb) {
        // On web use Supabase External Provider flow (redirect-based)
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.kakao,
          redirectTo: oauthRedirectUri,
        );
        final session = _supabase.auth.currentSession;
        if (session != null) {
          await _persistSession(session);
          state = AsyncValue.data(AuthState(session: session));
          return;
        }
        state = const AsyncValue.data(AuthState());
        return;
      }

      // Mobile native flow: use Kakao native SDK to get an access token, then
      // exchange it with Supabase. This provides native SSO via KaKaoTalk app.
      try {
        // prefer KakaoTalk SSO if available
        late kakao_user.OAuthToken token;
        final bool hasKakaoTalk = await kakao_user.isKakaoTalkInstalled();
        log.info('Kakao login: kakaoTalkInstalled=$hasKakaoTalk');
        if (hasKakaoTalk) {
          try {
            token = await kakao_user.UserApi.instance.loginWithKakaoTalk();
            log.fine('Used KakaoTalk SSO for login');
          } catch (loginErr, loginSt) {
            log.warning('KakaoTalk login failed: $loginErr', loginErr, loginSt);
            // Prefer robust code-based detection first
            if (loginErr is PlatformException &&
                loginErr.code == 'NotSupportError') {
              log.info(
                'KakaoTalk not connected. Prompting user to open KakaoTalk and login, no web fallback.',
              );
              try {
                showGlobalToast(
                  title: '카카오톡 로그인 필요',
                  message: '카카오톡 앱에서 먼저 로그인한 뒤 다시 시도해 주세요.',
                  backgroundColor: Colors.orangeAccent,
                );
              } catch (_) {}
              state = const AsyncValue.data(AuthState());
              return;
            } else {
              final msg = loginErr.toString().toLowerCase();
              if (msg.contains('notsupporterror') &&
                  msg.contains('not connected')) {
                log.info(
                  'Detected not-connected via message. Informing user to login in KakaoTalk; no web fallback.',
                );
                try {
                  showGlobalToast(
                    title: '카카오톡 로그인 필요',
                    message: '카카오톡 앱에서 먼저 로그인한 뒤 다시 시도해 주세요.',
                    backgroundColor: Colors.orangeAccent,
                  );
                } catch (_) {}
                state = const AsyncValue.data(AuthState());
                return;
              } else if (msg.contains('cancel') ||
                  msg.contains('canceled') ||
                  msg.contains('cancelled')) {
                try {
                  showGlobalToast(
                    title: '로그인 취소',
                    message: '카카오 로그인이 취소되었습니다.',
                    backgroundColor: Colors.orangeAccent,
                  );
                } catch (_) {}
                state = const AsyncValue.data(AuthState());
                return;
              } else {
                rethrow;
              }
            }
          }
        } else {
          // KakaoTalk not installed: enforce native-only policy (no web fallback)
          log.info(
            'KakaoTalk not installed. Enforcing native-only: no web login fallback.',
          );
          try {
            showGlobalToast(
              title: '카카오톡 설치 필요',
              message: '카카오톡 앱을 설치한 뒤 다시 시도해 주세요.',
              backgroundColor: Colors.orangeAccent,
            );
          } catch (_) {}
          state = const AsyncValue.data(AuthState());
          return;
        }

        final accessToken = token.accessToken;
        final expiresAt = token.expiresAt;
        String mask(String? v) {
          if (v == null || v.isEmpty) {
            return '<empty>';
          }
          if (v.length <= 12) {
            return '${v.substring(0, 3)}...${v.substring(v.length - 3)}';
          }
          return '${v.substring(0, 6)}...${v.substring(v.length - 6)}';
        }

        log.info(
          'Kakao token obtained: accessToken=${mask(accessToken)} expiresAt=$expiresAt',
        );

        // Try exchanging the Kakao token with Supabase. The supabase_flutter
        // package supports signInWithIdToken for some providers; use provider
        // 'kakao' here and pass the idToken/accessToken. If Supabase project
        // is configured to accept Kakao, this should create a session.
        try {
          final authRes = await _supabase.auth.signInWithIdToken(
            provider: OAuthProvider.kakao,
            idToken: accessToken,
          );

          log.fine(
            'Supabase signInWithIdToken (kakao) response: session=${authRes.session != null}',
          );

          final session = authRes.session ?? _supabase.auth.currentSession;
          if (session != null) {
            final user = session.user;
            log.info(
              'Kakao -> Supabase exchange succeeded: user=${user.email ?? user.id}',
            );
            await _persistSession(session);
            await _postSignIn(session);
            state = AsyncValue.data(AuthState(session: session));
            return;
          }
        } catch (exchangeErr, exchangeSt) {
          log.warning(
            'Supabase token exchange for Kakao failed: $exchangeErr',
            exchangeErr,
            exchangeSt,
          );
          // continue to fallback behavior below
        }

        // Native-only policy: do not fall back to external OAuth on mobile.
        log.warning(
          'Kakao token exchange did not yield session. Native-only policy: not falling back to web.',
        );
        try {
          showGlobalToast(
            title: '로그인 오류',
            message: '로그인에 실패했습니다. 카카오톡 앱에서 로그인 상태를 확인한 뒤 다시 시도해 주세요.',
            backgroundColor: Colors.redAccent,
          );
        } catch (_) {}
        state = const AsyncValue.data(AuthState());
        return;
      } catch (e, st) {
        log.severe('Native Kakao login or token exchange failed: $e', e, st);
        try {
          showGlobalToast(
            title: '로그인 오류',
            message: _koreanAuthMessage(e),
            backgroundColor: Colors.redAccent,
          );
        } catch (_) {}
        state = AsyncValue.error(e, st);
      }
    } catch (e, st) {
      log.severe('Kakao sign-in failed: $e', e, st);
      try {
        showGlobalToast(
          title: '로그인 오류',
          message: _koreanAuthMessage(e),
          backgroundColor: Colors.redAccent,
        );
      } catch (_) {}
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await storage.deleteAll();
      try {
        await AnalyticsService.logEvent('logout', params: {'method': 'manual'});
        await AnalyticsService.setUserId('');
      } catch (_) {}
      state = const AsyncValue.data(AuthState());
    } catch (e, st) {
      log.severe('Sign out failed: $e', e, st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _persistSession(Session session) async {
    await storage.write(key: 'sb_access_token', value: session.accessToken);
    await storage.write(key: 'sb_refresh_token', value: session.refreshToken);
  }

  // Helpers for post sign-in provisioning
  Future<String> _getOrCreateDeviceUuid() async {
    const key = 'device_uuid';
    var v = await storage.read(key: key);
    if (v == null || v.isEmpty) {
      v = const Uuid().v4();
      await storage.write(key: key, value: v);
    }
    return v;
  }

  String _deviceOs() {
    if (kIsWeb) {
      return 'Web';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.fuchsia:
        return 'Fuchsia';
    }
  }

  Future<void> _postSignIn(Session session) async {
    try {
      final user = session.user;
      final uid = user.id;

      // NOTE: Per product requirement, do NOT write nickname/email/phone
      // to the users table automatically here. The user must explicitly
      // update nickname/email via the Edit Profile flow (edit_profile_modal).
      log.fine(
        'Skipping automatic users.upsert for uid=$uid (email/phone suppressed)',
      );

      // Upsert device info for this user
      final duuid = await _getOrCreateDeviceUuid();
      final os = _deviceOs();
      final devicePayload = {
        'user_id': uid,
        'device_uuid': duuid,
        'device_os': os,
        'last_login_at': DateTime.now().toUtc().toIso8601String(),
      };
      await _supabase
          .from('devices')
          .upsert(devicePayload, onConflict: 'user_id,device_uuid');

      log.fine(
        'Post sign-in provisioning completed for user=$uid device=$duuid',
      );
      try {
        await AnalyticsService.logEvent(
          'post_sign_in',
          params: {'user_id': uid, 'device_uuid': duuid, 'device_os': os},
        );
      } catch (_) {}
    } catch (e, st) {
      log.severe('Post sign-in provisioning failed: $e', e, st);
      // Non-fatal: do not break the signed-in flow
    }
  }

  // web redirect getter is now managed from supabase_env.oauthRedirectUri
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthState>>(
      (ref) => AuthController(ref.read(secureStorageProvider)),
    );

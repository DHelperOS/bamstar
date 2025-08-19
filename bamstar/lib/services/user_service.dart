import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  final String id;
  final String nickname;
  final String email;
  final Map<String, dynamic> data; // raw row data (all columns)

  AppUser({
    required this.id,
    required this.nickname,
    required this.email,
    required this.data,
  });

  factory AppUser.fromMap(Map<String, dynamic> m) {
    return AppUser(
      id: m['id'] as String,
      nickname: (m['nickname'] as String?) ?? '',
      email: (m['email'] as String?) ?? '',
      data: Map<String, dynamic>.from(m),
    );
  }
}

class UserService extends ChangeNotifier {
  UserService._private() {
    _initAuthListener();
  }
  static final UserService instance = UserService._private();

  static const String avatarPrefKey = 'local_avatar_filename';
  static const String demoNickname = 'John Henry';
  static const String demoEmail = 'johnhenry99@gmail.com';

  AppUser? _user;
  AppUser? get user => _user;

  Future<void> loadCurrentUser() async {
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) {
        _user = null;
        notifyListeners();
        return;
      }
      final res = await client.from('users').select('*').eq('id', uid).maybeSingle();
      if (res != null) {
        final row = Map<String, dynamic>.from(res as Map);
        _user = AppUser.fromMap(row);
        notifyListeners();
      }
    } catch (_) {
      // ignore errors for now
    }
  }

  void _initAuthListener() {
    try {
      final client = Supabase.instance.client;
      client.auth.onAuthStateChange.listen((_) async {
        final uid = client.auth.currentUser?.id;
        if (uid == null) {
          _user = null;
          notifyListeners();
        } else {
          await loadCurrentUser();
        }
      });
    } catch (_) {
      // ignore: failed to attach listener
    }
  }

  /// Upsert values into users table (nickname, email).
  Future<void> upsertUser({required String nickname, required String email}) async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;
    await client.from('users').upsert({
      'id': uid,
      'nickname': nickname,
      'email': email,
    }, onConflict: 'id');

    // Fetch full row after upsert to populate all columns
    final res = await client.from('users').select('*').eq('id', uid).maybeSingle();
    if (res != null) {
      final row = Map<String, dynamic>.from(res as Map);
      _user = AppUser.fromMap(row);
    } else {
      _user = AppUser(id: uid, nickname: nickname, email: email, data: {
        'id': uid,
        'nickname': nickname,
        'email': email,
      });
    }
    notifyListeners();
  }

  /// Convenience helper to seed the current authenticated user's row with
  /// the demo nickname/email. Calls [upsertUser]. No-op if no auth user.
  Future<void> seedDemoUser() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      // If user already has nickname and email, don't overwrite
      final res = await client.from('users').select('nickname,email').eq('id', uid).maybeSingle();
      if (res != null) {
        final existingNick = (res['nickname'] as String?) ?? '';
        final existingEmail = (res['email'] as String?) ?? '';
        if (existingNick.trim().isNotEmpty && existingEmail.trim().isNotEmpty) {
          return;
        }
      }

      await upsertUser(nickname: demoNickname, email: demoEmail);
    } catch (_) {
      // ignore
    }
  }

  /// Return a pseudo-random local avatar filename from assets.
  /// Format: 'avatar-N.webp' where N is 1..25
  String pickRandomLocalAvatar() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final n = (now % 25) + 1; // 1..25 pseudo-random
    return 'avatar-$n.webp';
  }

  /// Get an ImageProvider for the current user's profile image.
  /// If users.profile_img is an http(s) URL, returns NetworkImage and clears
  /// any saved local avatar preference. Otherwise returns an AssetImage
  /// using a per-user persisted filename (or a randomly picked one).
  Future<ImageProvider> getProfileImageProvider() async {
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      final sp = await SharedPreferences.getInstance();
      final key = uid != null ? '${avatarPrefKey}_$uid' : avatarPrefKey;

      String? imgUrl;
      if (uid != null) {
        final res = await client.from('users').select('profile_img').eq('id', uid).maybeSingle();
        if (res != null) {
          final v = res['profile_img'];
          if (v is String) {
            imgUrl = v.trim();
            if (imgUrl.isEmpty) imgUrl = null;
          }
        }
      }

      if (imgUrl != null && (imgUrl.startsWith('http://') || imgUrl.startsWith('https://'))) {
        await sp.remove(key);
        return NetworkImage(imgUrl);
      }

      String saved = sp.getString(key) ?? pickRandomLocalAvatar();
      await sp.setString(key, saved);
      return AssetImage('assets/images/avatar/$saved');
    } catch (_) {
      final saved = pickRandomLocalAvatar();
      return AssetImage('assets/images/avatar/$saved');
    }
  }
}

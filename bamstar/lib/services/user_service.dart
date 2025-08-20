import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

/// Convert a stored `profile_img` value into an ImageProvider.
/// If [profileImg] is an asset path (starts with 'assets/'), returns AssetImage.
/// If it is an http(s) URL, returns NetworkImage. Otherwise returns a
/// pseudo-random local asset ImageProvider using the app's avatar pool.
ImageProvider profileImageProviderFromProfileImg(String? profileImg) {
  if (profileImg != null && profileImg.isNotEmpty) {
    if (profileImg.startsWith('assets/')) return AssetImage(profileImg);
    if (profileImg.startsWith('http://') || profileImg.startsWith('https://')) {
      return CachedNetworkImageProvider(profileImg);
    }
  }
  // Fallback: pick a random local avatar filename and return its AssetImage.
  final fname = UserService.instance.pickRandomLocalAvatar();
  return AssetImage('assets/images/avatar/$fname');
}

class UserService extends ChangeNotifier {
  UserService._private() {
    _initAuthListener();
  }
  static final UserService instance = UserService._private();

  static const String avatarPrefKey = 'local_avatar_filename';
  static const Set<String> demoNicknames = {'밤스타', 'John Henry'};
  static const String demoNicknameSeed = '밤스타';
  static const String demoEmail = 'bamstar.help@gmail.com';

  AppUser? _user;
  AppUser? get user => _user;
  String? _displayName;

  /// Public display name that UI should read. Computed from nickname or role.kor_name#index
  String get displayName {
    if (_displayName != null) return _displayName!;
    final nick = _user?.nickname.trim() ?? '';
    if (nick.isNotEmpty && !demoNicknames.contains(nick)) return nick;
    return '이름 없음';
  }

  Future<void> loadCurrentUser() async {
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) {
        _user = null;
        notifyListeners();
        return;
      }
      final res = await client
          .from('users')
          .select('*')
          .eq('id', uid)
          .maybeSingle();
      if (res != null) {
        final row = Map<String, dynamic>.from(res as Map);
        _user = AppUser.fromMap(row);
        debugPrint('[UserService] loadCurrentUser fetched row: ${row}');
        debugPrint(
          '[UserService] loadCurrentUser user.nickname=${_user?.nickname} user.email=${_user?.email}',
        );
        // compute display name after loading full row
        await _computeAndCacheDisplayName();
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
  Future<void> upsertUser({
    required String nickname,
    required String email,
  }) async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;
    await client.from('users').upsert({
      'id': uid,
      'nickname': nickname,
      'email': email,
    }, onConflict: 'id');

    // Fetch full row after upsert to populate all columns
    final res = await client
        .from('users')
        .select('*')
        .eq('id', uid)
        .maybeSingle();
    if (res != null) {
      final row = Map<String, dynamic>.from(res as Map);
      _user = AppUser.fromMap(row);
      debugPrint('[UserService] upsertUser fetched after upsert row: ${row}');
      debugPrint(
        '[UserService] upsertUser user.nickname=${_user?.nickname} user.email=${_user?.email}',
      );
    } else {
      _user = AppUser(
        id: uid,
        nickname: nickname,
        email: email,
        data: {'id': uid, 'nickname': nickname, 'email': email},
      );
      debugPrint(
        '[UserService] upsertUser created local struct nickname=${_user?.nickname} email=${_user?.email}',
      );
    }
    // compute display name after upsert
    await _computeAndCacheDisplayName();
    notifyListeners();
  }

  /// Compute display name and cache in this service.
  Future<void> _computeAndCacheDisplayName() async {
    final u = _user;
    if (u == null) {
      _displayName = '이름 없음';
      return;
    }
    final nick = (u.nickname).trim();
    // Treat demo nicknames as placeholders — prefer computed role#index when
    // nickname is empty or one of demoNicknames.
    if (nick.isNotEmpty && !demoNicknames.contains(nick)) {
      _displayName = nick;
      return;
    }

    try {
      final client = Supabase.instance.client;
      dynamic idx = u.data['index'];
      dynamic roleId = u.data['role_id'];
      if (idx == null || roleId == null) {
        final res = await client
            .from('users')
            .select('index, role_id')
            .eq('id', u.id)
            .maybeSingle();
        if (res != null) {
          idx = idx ?? res['index'];
          roleId = roleId ?? res['role_id'];
          // merge into cached row data for future
          u.data['index'] = u.data['index'] ?? res['index'];
          u.data['role_id'] = u.data['role_id'] ?? res['role_id'];
        }
      }

      String roleKor = '회원';
      if (roleId != null) {
        final r = await client
            .from('roles')
            .select('kor_name')
            .eq('id', roleId)
            .maybeSingle();
        if (r != null &&
            r['kor_name'] is String &&
            (r['kor_name'] as String).trim().isNotEmpty) {
          roleKor = r['kor_name'] as String;
        }
      }

      final idxStr = (idx != null) ? idx.toString() : '0';
      final computedName = '$roleKor#${idxStr}';
      _displayName = computedName;

      // If user's nickname is empty or a demo placeholder, persist computed
      // nickname to the users table so future loads will reflect it.
      try {
        final existingNick = (u.nickname).trim();
        if (existingNick.isEmpty || demoNicknames.contains(existingNick)) {
          await client
              .from('users')
              .update({'nickname': computedName})
              .eq('id', u.id);
          // update local cache
          u.data['nickname'] = computedName;
          _user = AppUser.fromMap(Map<String, dynamic>.from(u.data));
          debugPrint(
            '[UserService] _computeAndCacheDisplayName -> wrote nickname=${computedName} for uid=${u.id}',
          );
        }
      } catch (e) {
        debugPrint('[UserService] failed to persist computed nickname: $e');
      }
    } catch (_) {
      _displayName = '이름 없음';
    }
  }

  /// Convenience helper to seed the current authenticated user's row with
  /// the demo nickname/email. Calls [upsertUser]. No-op if no auth user.
  Future<void> seedDemoUser() async {
    // seedDemoUser disabled: do not modify DB automatically. Users must
    // explicitly update their profile via the Edit Profile modal.
    return;
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
        final res = await client
            .from('users')
            .select('profile_img')
            .eq('id', uid)
            .maybeSingle();
        if (res != null) {
          final v = res['profile_img'];
          if (v is String) {
            imgUrl = v.trim();
            if (imgUrl.isEmpty) imgUrl = null;
          }
        }
      }

      if (imgUrl != null) {
        // If DB contains a network URL, return NetworkImage.
        if (imgUrl.startsWith('http://') || imgUrl.startsWith('https://')) {
          await sp.remove(key);
          debugPrint('[UserService] returning NetworkImage from DB profile_img');
          return CachedNetworkImageProvider(imgUrl);
        }

        // If DB contains an asset path (e.g. assets/images/avatar/...), use it
        // directly as AssetImage and sync SharedPreferences to the filename.
        if (imgUrl.startsWith('assets/')) {
          try {
            final filename = imgUrl.split('/').last;
            await sp.setString(key, filename);
          } catch (_) {
            // ignore
          }
          debugPrint('[UserService] returning AssetImage from DB profile_img: $imgUrl');
          return AssetImage(imgUrl);
        }
        // Unknown format: fall through to local choice.
      }

      String saved = sp.getString(key) ?? pickRandomLocalAvatar();
      await sp.setString(key, saved);

      // Persist the chosen local asset path into users.profile_img so that
      // subsequent loads can read the same asset path from the DB.
      try {
        if (uid != null) {
          final assetPath = 'assets/images/avatar/$saved';
          await client
              .from('users')
              .update({'profile_img': assetPath})
              .eq('id', uid);
          debugPrint(
              '[UserService] persisted local profile_img asset for uid=$uid -> $assetPath');
        }
      } catch (e) {
        debugPrint('[UserService] failed to persist profile_img asset path: $e');
      }

      return AssetImage('assets/images/avatar/$saved');
    } catch (_) {
      final saved = pickRandomLocalAvatar();
      // Best-effort: persist chosen local asset to SharedPreferences and DB so
      // future loads remain consistent.
      try {
        final client = Supabase.instance.client;
        final uid = client.auth.currentUser?.id;
        final sp = await SharedPreferences.getInstance();
        final key = uid != null ? '${avatarPrefKey}_$uid' : avatarPrefKey;
        await sp.setString(key, saved);
        if (uid != null) {
          final assetPath = 'assets/images/avatar/$saved';
          await client.from('users').update({'profile_img': assetPath}).eq('id', uid);
          debugPrint('[UserService] (catch) persisted local profile_img asset for uid=$uid -> $assetPath');
        }
      } catch (e) {
        debugPrint('[UserService] (catch) failed to persist profile_img asset path: $e');
      }
      return AssetImage('assets/images/avatar/$saved');
    }
  }
}

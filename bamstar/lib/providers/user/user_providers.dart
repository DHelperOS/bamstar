import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../app_providers.dart';
import '../auth/auth_providers.dart';

/// 사용자 프로필 모델
class UserProfile {
  final String id;
  final String? email;
  final String? displayName;
  final String? profileImg;
  final String? role;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const UserProfile({
    required this.id,
    this.email,
    this.displayName,
    this.profileImg,
    this.role,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      displayName: json['display_name'],
      profileImg: json['profile_img'],
      role: json['role'],
      metadata: json['metadata'],
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : null,
      updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'profile_img': profileImg,
      'role': role,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// 사용자 프로필 Provider
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  
  final supabase = ref.watch(supabaseProvider);
  
  try {
    final response = await supabase
      .from('users')
      .select()
      .eq('id', userId)
      .single();
    
    return UserProfile.fromJson(response);
  } catch (e) {
    return null;
  }
});

/// 사용자 프로필 이미지 Provider
final userProfileImageProvider = Provider<ImageProvider?>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  final profileImg = profile?.profileImg;
  
  if (profileImg == null || profileImg.isEmpty) {
    // 기본 아바타 반환
    return const AssetImage('assets/images/avatar/avatar_01.png');
  }
  
  if (profileImg.startsWith('assets/')) {
    return AssetImage(profileImg);
  }
  
  if (profileImg.startsWith('http')) {
    return NetworkImage(profileImg);
  }
  
  return const AssetImage('assets/images/avatar/avatar_01.png');
});

/// 사용자 프로필 업데이트 Notifier
class UserProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return null;
    
    return _fetchProfile(userId);
  }
  
  Future<UserProfile?> _fetchProfile(String userId) async {
    final supabase = ref.read(supabaseProvider);
    
    try {
      final response = await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();
      
      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> updateProfile({
    String? displayName,
    String? profileImg,
    Map<String, dynamic>? metadata,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseProvider);
      
      final updates = <String, dynamic>{
        'id': userId,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (displayName != null) updates['display_name'] = displayName;
      if (profileImg != null) updates['profile_img'] = profileImg;
      if (metadata != null) updates['metadata'] = metadata;
      
      await supabase.from('users').upsert(updates);
      
      return _fetchProfile(userId);
    });
  }
  
  Future<void> updateRole(String role) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseProvider);
      
      await supabase.from('users').update({
        'role': role,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      
      return _fetchProfile(userId);
    });
  }
}

/// 사용자 프로필 업데이트 Provider
final userProfileNotifierProvider = 
  AsyncNotifierProvider<UserProfileNotifier, UserProfile?>(
    UserProfileNotifier.new,
  );

/// 사용자 역할 Provider
final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(userProfileProvider).value?.role;
});

/// 사용자 표시 이름 Provider
final userDisplayNameProvider = Provider<String>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  return profile?.displayName ?? profile?.email?.split('@').first ?? 'User';
});

/// 다른 사용자 프로필 Provider (family 사용)
final otherUserProfileProvider = 
  FutureProvider.family.autoDispose<UserProfile?, String>(
    (ref, userId) async {
      final supabase = ref.watch(supabaseProvider);
      
      try {
        final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
        
        return UserProfile.fromJson(response);
      } catch (e) {
        return null;
      }
    },
  );

/// 사용자 온라인 상태 Provider
final userOnlineStatusProvider = StreamProvider<bool>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(false);
  
  final supabase = ref.watch(supabaseProvider);
  
  // Supabase Presence 사용
  final channel = supabase.channel('online-users');
  
  // Track user's own presence
  channel.track({'user_id': userId});
  
  // Subscribe to channel
  channel.subscribe();
  
  // For now, return a simple stream
  // Real presence implementation would need more complex handling
  return Stream.value(true);
});
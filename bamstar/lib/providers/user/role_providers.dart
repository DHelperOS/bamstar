import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_providers.dart';

/// 역할 모델 (public.roles 테이블과 매핑)
class Role {
  final int id;
  final String name;         // 영문 이름 (admin, product_owner, member)
  final String korName;       // 한글 이름 (관리자, 플레이스 오너, 멤버)
  final String? description;
  final DateTime? createdAt;
  
  const Role({
    required this.id,
    required this.name,
    required this.korName,
    this.description,
    this.createdAt,
  });
  
  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      korName: json['kor_name'] ?? json['name'], // fallback to name if kor_name is null
      description: json['description'],
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'kor_name': korName,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

/// 사용자 역할 정보 모델 (users와 roles 조인 결과)
class UserRole {
  final String userId;
  final int roleId;
  final Role role;
  final bool isAdult;
  final Map<String, dynamic>? userData;
  
  const UserRole({
    required this.userId,
    required this.roleId,
    required this.role,
    required this.isAdult,
    this.userData,
  });
  
  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      userId: json['id'],
      roleId: json['role_id'] ?? 3, // default to member
      role: Role.fromJson(json['roles'] ?? {
        'id': json['role_id'] ?? 3,
        'name': 'member',
        'kor_name': '멤버',
      }),
      isAdult: json['is_adult'] ?? false,
      userData: json,
    );
  }
}

/// 모든 역할 목록 Provider
final rolesProvider = FutureProvider<List<Role>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  
  try {
    final response = await supabase
      .from('roles')
      .select()
      .order('id');
    
    return (response as List)
      .map((json) => Role.fromJson(json))
      .toList();
  } catch (e) {
    // 에러 시 기본 역할 목록 반환
    return [
      const Role(id: 1, name: 'admin', korName: '관리자'),
      const Role(id: 2, name: 'product_owner', korName: '플레이스 오너'),
      const Role(id: 3, name: 'member', korName: '멤버'),
    ];
  }
});

/// 현재 사용자의 역할 정보 Provider (조인 쿼리 사용)
final currentUserRoleProvider = FutureProvider<UserRole?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  
  final supabase = ref.watch(supabaseProvider);
  
  try {
    // users 테이블과 roles 테이블 조인
    final response = await supabase
      .from('users')
      .select('''
        *,
        roles:role_id (
          id,
          name,
          kor_name
        )
      ''')
      .eq('id', userId)
      .single();
    
    return UserRole.fromJson(response);
  } catch (e) {
    // 에러 시 users 테이블만 조회하여 기본값 설정
    try {
      final userResponse = await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();
      
      final roleId = userResponse['role_id'] ?? 3;
      final roleName = _getRoleNameById(roleId);
      final roleKorName = _getRoleKorNameById(roleId);
      
      return UserRole(
        userId: userId,
        roleId: roleId,
        role: Role(
          id: roleId,
          name: roleName,
          korName: roleKorName,
        ),
        isAdult: userResponse['is_adult'] ?? false,
        userData: userResponse,
      );
    } catch (e) {
      return null;
    }
  }
});

// Helper functions for fallback role names
String _getRoleNameById(int roleId) {
  switch (roleId) {
    case 1:
      return 'guest';
    case 2:
      return 'star';  
    case 3:
      return 'place';  
    case 4:
      return 'admin';
    case 6:
      return 'member';
    default:
      return 'star';
  }
}

String _getRoleKorNameById(int roleId) {
  // 이 함수는 폴백용입니다. 실제 한글 이름은 DB의 roles.kor_name에서 가져옵니다
  switch (roleId) {
    case 1:
      return '게스트';
    case 2:
      return '스타';  
    case 3:
      return '플레이스';  
    case 4:
      return '관리자';
    case 6:
      return '멤버';
    default:
      return '스타';
  }
}

/// 현재 사용자의 역할 ID Provider
final currentUserRoleIdProvider = Provider<int>((ref) {
  final userRole = ref.watch(currentUserRoleProvider).value;
  return userRole?.roleId ?? 3; // default to member
});

/// 현재 사용자의 역할 이름 Provider (영문)
final currentUserRoleNameProvider = Provider<String>((ref) {
  final userRole = ref.watch(currentUserRoleProvider).value;
  return userRole?.role.name ?? 'member';
});

/// 현재 사용자의 역할 한글 이름 Provider
final currentUserRoleKorNameProvider = Provider<String>((ref) {
  final userRole = ref.watch(currentUserRoleProvider).value;
  return userRole?.role.korName ?? '멤버';
});

/// 현재 사용자의 성인 인증 상태 Provider
final currentUserIsAdultProvider = Provider<bool>((ref) {
  final userRole = ref.watch(currentUserRoleProvider).value;
  return userRole?.isAdult ?? false;
});

/// 사용자 역할 업데이트 Notifier
class UserRoleNotifier extends AsyncNotifier<UserRole?> {
  @override
  Future<UserRole?> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return null;
    
    return _fetchUserRole(userId);
  }
  
  Future<UserRole?> _fetchUserRole(String userId) async {
    final supabase = ref.read(supabaseProvider);
    
    try {
      final response = await supabase
        .from('users')
        .select('''
          *,
          roles:role_id (
            id,
            name,
            kor_name,
            description,
            created_at
          )
        ''')
        .eq('id', userId)
        .single();
      
      return UserRole.fromJson(response);
    } catch (e) {
      return null;
    }
  }
  
  /// 사용자 역할 변경
  Future<void> updateRole(int roleId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseProvider);
      
      await supabase.from('users').update({
        'role_id': roleId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      
      return _fetchUserRole(userId);
    });
  }
  
  /// 성인 인증 상태 업데이트
  Future<void> updateAdultVerification(bool isAdult) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseProvider);
      
      await supabase.from('users').update({
        'is_adult': isAdult,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      
      return _fetchUserRole(userId);
    });
  }
}

/// 사용자 역할 업데이트 Provider
final userRoleNotifierProvider = 
  AsyncNotifierProvider<UserRoleNotifier, UserRole?>(
    UserRoleNotifier.new,
  );

/// 특정 사용자의 역할 정보 Provider (family 사용)
final otherUserRoleProvider = 
  FutureProvider.family.autoDispose<UserRole?, String>(
    (ref, userId) async {
      final supabase = ref.watch(supabaseProvider);
      
      try {
        final response = await supabase
          .from('users')
          .select('''
            *,
            roles:role_id (
              id,
              name,
              kor_name,
              description,
              created_at
            )
          ''')
          .eq('id', userId)
          .single();
        
        return UserRole.fromJson(response);
      } catch (e) {
        return null;
      }
    },
  );

/// 역할별 권한 체크 Helper Providers
final isAdminProvider = Provider<bool>((ref) {
  final roleId = ref.watch(currentUserRoleIdProvider);
  return roleId == 1;
});

final isProductOwnerProvider = Provider<bool>((ref) {
  final roleId = ref.watch(currentUserRoleIdProvider);
  return roleId == 2;
});

final isMemberProvider = Provider<bool>((ref) {
  final roleId = ref.watch(currentUserRoleIdProvider);
  return roleId == 3;
});

/// 역할별 접근 권한 체크 Provider
final hasAccessToPlaceSettingsProvider = Provider<bool>((ref) {
  final roleId = ref.watch(currentUserRoleIdProvider);
  return roleId == 2; // Only Product Owner
});

final hasAccessToAdminPanelProvider = Provider<bool>((ref) {
  final roleId = ref.watch(currentUserRoleIdProvider);
  return roleId == 1; // Only Admin
});
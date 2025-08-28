import 'package:supabase_flutter/supabase_flutter.dart';

/// 약관 모델 클래스
class Term {
    final String id;
    final String title;
    final String? description;
    final String content;
    final String type; // 'mandatory' | 'optional'
    final String category; // 'service', 'privacy', 'marketing', 'notification'
    final String version;
    final bool isActive;
    final int displayOrder;
    final DateTime createdAt;
    final DateTime updatedAt;
    
    Term({
      required this.id,
      required this.title,
      this.description,
      required this.content,
      required this.type,
      required this.category,
      required this.version,
      required this.isActive,
      required this.displayOrder,
      required this.createdAt,
      required this.updatedAt,
    });
    
    factory Term.fromJson(Map<String, dynamic> json) {
      return Term(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        content: json['content'],
        type: json['type'],
        category: json['category'],
        version: json['version'],
        isActive: json['is_active'],
        displayOrder: json['display_order'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );
    }
    
    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'title': title,
        'description': description,
        'content': content,
        'type': type,
        'category': category,
        'version': version,
        'is_active': isActive,
        'display_order': displayOrder,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
    }
}

/// 사용자 약관 동의 모델 클래스
class UserTermAgreement {
    final String id;
    final String userId;
    final String termId;
    final bool isAgreed;
    final DateTime? agreedAt;
    final String versionAgreed;
    final String? ipAddress;
    final String? userAgent;
    final DateTime createdAt;
    final DateTime updatedAt;
    
    UserTermAgreement({
      required this.id,
      required this.userId,
      required this.termId,
      required this.isAgreed,
      this.agreedAt,
      required this.versionAgreed,
      this.ipAddress,
      this.userAgent,
      required this.createdAt,
      required this.updatedAt,
    });
    
    factory UserTermAgreement.fromJson(Map<String, dynamic> json) {
      return UserTermAgreement(
        id: json['id'],
        userId: json['user_id'],
        termId: json['term_id'],
        isAgreed: json['is_agreed'],
        agreedAt: json['agreed_at'] != null ? DateTime.parse(json['agreed_at']) : null,
        versionAgreed: json['version_agreed'],
        ipAddress: json['ip_address'],
        userAgent: json['user_agent'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );
    }
}

class TermsService {
  static final _supabase = Supabase.instance.client;
  
  /// 활성화된 약관 목록 조회 (표시 순서대로 정렬)
  static Future<List<Term>> getActiveTerms() async {
    try {
      final response = await _supabase
          .from('terms')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);
      
      return (response as List).map((json) => Term.fromJson(json)).toList();
    } catch (e) {
      throw Exception('약관 목록을 불러오는데 실패했습니다: $e');
    }
  }
  
  /// 특정 타입의 약관 목록 조회
  static Future<List<Term>> getTermsByType(String type) async {
    try {
      final response = await _supabase
          .from('terms')
          .select()
          .eq('is_active', true)
          .eq('type', type)
          .order('display_order', ascending: true);
      
      return (response as List).map((json) => Term.fromJson(json)).toList();
    } catch (e) {
      throw Exception('약관 목록을 불러오는데 실패했습니다: $e');
    }
  }
  
  /// 필수 약관 목록 조회
  static Future<List<Term>> getMandatoryTerms() async {
    return getTermsByType('mandatory');
  }
  
  /// 선택 약관 목록 조회
  static Future<List<Term>> getOptionalTerms() async {
    return getTermsByType('optional');
  }
  
  /// 특정 약관 상세 정보 조회
  static Future<Term?> getTermById(String termId) async {
    try {
      final response = await _supabase
          .from('terms')
          .select()
          .eq('id', termId)
          .eq('is_active', true)
          .maybeSingle();
      
      if (response == null) return null;
      return Term.fromJson(response);
    } catch (e) {
      throw Exception('약관 정보를 불러오는데 실패했습니다: $e');
    }
  }
  
  /// 사용자의 약관 동의 상태 조회
  static Future<List<UserTermAgreement>> getUserAgreements(String userId) async {
    try {
      final response = await _supabase
          .from('user_term_agreements')
          .select()
          .eq('user_id', userId);
      
      return (response as List).map((json) => UserTermAgreement.fromJson(json)).toList();
    } catch (e) {
      throw Exception('동의 정보를 불러오는데 실패했습니다: $e');
    }
  }
  
  /// 사용자 약관 동의 저장/업데이트
  static Future<bool> saveUserAgreement({
    required String userId,
    required String termId,
    required bool isAgreed,
    required String version,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      final now = DateTime.now();
      
      await _supabase.from('user_term_agreements').upsert({
        'user_id': userId,
        'term_id': termId,
        'is_agreed': isAgreed,
        'agreed_at': isAgreed ? now.toIso8601String() : null,
        'version_agreed': version,
        'ip_address': ipAddress,
        'user_agent': userAgent,
        'updated_at': now.toIso8601String(),
      });
      
      return true;
    } catch (e) {
      throw Exception('동의 정보 저장에 실패했습니다: $e');
    }
  }
  
  /// 여러 약관 동의 상태 일괄 저장
  static Future<bool> saveMultipleAgreements({
    required String userId,
    required Map<String, bool> agreements, // termId -> isAgreed
    required String version,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      final now = DateTime.now();
      final batch = <Map<String, dynamic>>[];
      
      for (final entry in agreements.entries) {
        batch.add({
          'user_id': userId,
          'term_id': entry.key,
          'is_agreed': entry.value,
          'agreed_at': entry.value ? now.toIso8601String() : null,
          'version_agreed': version,
          'ip_address': ipAddress,
          'user_agent': userAgent,
          'updated_at': now.toIso8601String(),
        });
      }
      
      await _supabase.from('user_term_agreements').upsert(batch);
      return true;
    } catch (e) {
      throw Exception('동의 정보 저장에 실패했습니다: $e');
    }
  }
}
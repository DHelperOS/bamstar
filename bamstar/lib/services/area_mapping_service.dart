import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AreaMappingService {
  static final AreaMappingService _instance = AreaMappingService._internal();
  factory AreaMappingService() => _instance;
  AreaMappingService._internal();

  static AreaMappingService get instance => _instance;

  final SupabaseClient _supabase = Supabase.instance.client;

  /// 주소 문자열에서 area_group_id를 찾아 반환
  Future<int?> mapAddressToAreaGroup(String address) async {
    if (address.trim().isEmpty) return null;

    try {
      // area_keywords 테이블에서 키워드 매칭
      final response = await _supabase
          .from('area_keywords')
          .select('group_id, keyword')
          .order('keyword', ascending: false); // 긴 키워드부터 매칭

      if (response.isEmpty) return null;

      final List<Map<String, dynamic>> keywords = List<Map<String, dynamic>>.from(response);
      
      // 주소를 정규화 (공백, 특수문자 제거)
      final normalizedAddress = address
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim()
          .toLowerCase();

      // 키워드 매칭 (긴 키워드부터 우선 매칭)
      for (final keywordData in keywords) {
        final keyword = keywordData['keyword'] as String;
        final normalizedKeyword = keyword.toLowerCase();
        
        if (normalizedAddress.contains(normalizedKeyword)) {
          return keywordData['group_id'] as int;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error mapping address to area group: $e');
      return null;
    }
  }

  /// area_group_id로 지역 그룹 이름 조회
  Future<String?> getAreaGroupName(int groupId) async {
    try {
      final response = await _supabase
          .from('area_groups')
          .select('name')
          .eq('group_id', groupId)
          .maybeSingle();

      return response?['name'] as String?;
    } catch (e) {
      debugPrint('Error getting area group name: $e');
      return null;
    }
  }

  /// 사용자의 선호 지역 저장 (기존 데이터 삭제 후 새로 저장)
  Future<bool> saveMemberPreferredAreaGroups(String userId, List<int> groupIds) async {
    try {
      // 기존 선호 지역 삭제
      await _supabase
          .from('member_preferred_area_groups')
          .delete()
          .eq('member_user_id', userId);

      if (groupIds.isEmpty) return true;

      // 새 선호 지역 저장 (우선순위와 함께)
      final List<Map<String, dynamic>> insertData = groupIds
          .asMap()
          .entries
          .map((entry) => {
                'member_user_id': userId,
                'group_id': entry.value,
                'priority': entry.key + 1, // 1부터 시작
              })
          .toList();

      await _supabase
          .from('member_preferred_area_groups')
          .insert(insertData);

      return true;
    } catch (e) {
      debugPrint('Error saving member preferred area groups: $e');
      return false;
    }
  }

  /// 사용자의 현재 선호 지역 조회
  Future<List<int>> getMemberPreferredAreaGroups(String userId) async {
    try {
      final response = await _supabase
          .from('member_preferred_area_groups')
          .select('group_id')
          .eq('member_user_id', userId)
          .order('priority');

      return response
          .map<int>((item) => item['group_id'] as int)
          .toList();
    } catch (e) {
      debugPrint('Error getting member preferred area groups: $e');
      return [];
    }
  }

  /// 모든 지역 그룹 목록 조회 (카테고리별로 정렬)
  Future<List<Map<String, dynamic>>> getAllAreaGroups() async {
    try {
      final response = await _supabase
          .from('area_groups')
          .select('group_id, name, category_id')
          .order('category_id')
          .order('group_id');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting all area groups: $e');
      return [];
    }
  }
}
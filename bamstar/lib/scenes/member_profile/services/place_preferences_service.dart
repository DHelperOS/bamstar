import 'package:supabase_flutter/supabase_flutter.dart';

class PlacePreferencesData {
  final Set<String> selectedIndustryIds;
  final Set<String> selectedJobIds;
  final String? selectedPayType;
  final int? payAmount;
  final Set<String> selectedDays;
  final String? experienceLevel;
  final Set<String> selectedStyleIds;
  final Set<String> selectedPlaceFeatureIds;
  final Set<String> selectedWelfareIds;

  PlacePreferencesData({
    required this.selectedIndustryIds,
    required this.selectedJobIds,
    this.selectedPayType,
    this.payAmount,
    required this.selectedDays,
    this.experienceLevel,
    required this.selectedStyleIds,
    required this.selectedPlaceFeatureIds,
    required this.selectedWelfareIds,
  });
}

class PlacePreferencesService {
  static final PlacePreferencesService _instance = PlacePreferencesService._internal();
  factory PlacePreferencesService() => _instance;
  PlacePreferencesService._internal();

  static PlacePreferencesService get instance => _instance;

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Place의 매칭 조건 로드
  Future<PlacePreferencesData?> loadMatchingPreferences() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return null;

      // place_profiles에서 기본 정보 조회
      final placeProfile = await _supabase
          .from('place_profiles')
          .select('*')
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (placeProfile == null) return null;

      // Place 속성 링크 테이블들에서 선택된 항목들 조회
      final Future<List<dynamic>> industriesQuery = _supabase
          .from('place_industries')
          .select('industry_id')
          .eq('place_user_id', currentUser.id);

      final Future<List<dynamic>> attributesQuery = _supabase
          .from('place_attributes_link')
          .select('attribute_id')
          .eq('place_user_id', currentUser.id);

      final Future<List<dynamic>> preferencesQuery = _supabase
          .from('place_preferences_link')
          .select('preference_id')
          .eq('place_user_id', currentUser.id);

      // 모든 쿼리 실행
      final results = await Future.wait([
        industriesQuery,
        attributesQuery,
        preferencesQuery,
      ]);

      final industries = results[0] as List<dynamic>;
      final attributes = results[1] as List<dynamic>;
      final preferences = results[2] as List<dynamic>;

      // 속성 ID들을 타입별로 분류 (이 부분은 attributes 테이블 구조에 따라 조정 필요)
      final jobIds = <String>{};
      final styleIds = <String>{};
      final placeFeatureIds = <String>{};
      final welfareIds = <String>{};

      // attributes와 preferences에서 타입별로 분류
      for (final attr in attributes) {
        final attrId = attr['attribute_id'].toString();
        // 실제 구현시에는 attributes 테이블을 조회해서 type에 따라 분류해야 함
        // 여기서는 예시로 임의 분류
      }

      return PlacePreferencesData(
        selectedIndustryIds: industries.map((i) => i['industry_id'].toString()).toSet(),
        selectedJobIds: jobIds,
        selectedPayType: placeProfile['offered_pay_type'],
        payAmount: placeProfile['offered_min_pay'], // 또는 offered_max_pay
        selectedDays: Set<String>.from(placeProfile['desired_working_days'] ?? []),
        experienceLevel: placeProfile['desired_experience_level'],
        selectedStyleIds: styleIds,
        selectedPlaceFeatureIds: placeFeatureIds,
        selectedWelfareIds: welfareIds,
      );
    } catch (e) {
      print('Error loading place preferences: $e');
      return null;
    }
  }

  /// Place의 매칭 조건 저장
  Future<bool> saveMatchingPreferences(PlacePreferencesData preferences) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;

      // place_profiles 업데이트
      await _supabase
          .from('place_profiles')
          .update({
            'offered_pay_type': preferences.selectedPayType,
            'offered_min_pay': preferences.payAmount,
            'desired_working_days': preferences.selectedDays.toList(),
            'desired_experience_level': preferences.experienceLevel,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', currentUser.id);

      // TODO: 속성 링크 테이블들 업데이트
      // place_industries, place_attributes_link, place_preferences_link 테이블들에
      // 선택된 항목들을 저장하는 로직 추가 필요

      return true;
    } catch (e) {
      print('Error saving place preferences: $e');
      return false;
    }
  }
}
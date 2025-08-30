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

      print('Loading preferences for user: ${currentUser.id}');

      // place_profiles에서 기본 정보 조회
      final placeProfile = await _supabase
          .from('place_profiles')
          .select('*')
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (placeProfile == null) {
        print('No place profile found');
        return null;
      }

      // Place 속성 링크 테이블들에서 선택된 항목들 조회
      final industriesQuery = _supabase
          .from('place_industries')
          .select('attribute_id')
          .eq('place_user_id', currentUser.id);

      final attributesQuery = _supabase
          .from('place_attributes_link')
          .select('attribute_id')
          .eq('place_user_id', currentUser.id);

      // 모든 쿼리 실행
      final results = await Future.wait([
        industriesQuery,
        attributesQuery,
      ]);

      final industries = results[0] as List<dynamic>;
      final attributes = results[1] as List<dynamic>;

      print('Loaded industries: $industries');
      print('Loaded attributes: $attributes');

      // attributes에서 타입별로 분류하기 위해 attributes 테이블과 조인해서 타입 정보 가져오기
      final jobIds = <String>{};
      final styleIds = <String>{};
      final placeFeatureIds = <String>{};
      final welfareIds = <String>{};

      if (attributes.isNotEmpty) {
        final attributeIds = attributes.map((attr) => attr['attribute_id']).toList();
        final attributeDetails = await _supabase
            .from('attributes')
            .select('id, type')
            .inFilter('id', attributeIds);

        print('Attribute details: $attributeDetails');

        for (final attr in attributeDetails) {
          final attrId = attr['id'].toString();
          final attrType = attr['type'];
          
          switch (attrType) {
            case 'JOB_ROLE':
              jobIds.add(attrId);
              break;
            case 'MEMBER_STYLE':
              styleIds.add(attrId);
              break;
            case 'PLACE_FEATURE':
              placeFeatureIds.add(attrId);
              break;
            case 'WELFARE':
              welfareIds.add(attrId);
              break;
          }
        }
      }

      final preferences = PlacePreferencesData(
        selectedIndustryIds: industries.map((i) => i['attribute_id'].toString()).toSet(),
        selectedJobIds: jobIds,
        selectedPayType: placeProfile['offered_pay_type'],
        payAmount: placeProfile['offered_min_pay'],
        selectedDays: Set<String>.from(placeProfile['desired_working_days'] ?? []),
        experienceLevel: placeProfile['desired_experience_level'],
        selectedStyleIds: styleIds,
        selectedPlaceFeatureIds: placeFeatureIds,
        selectedWelfareIds: welfareIds,
      );

      print('Loaded preferences: $preferences');
      return preferences;
    } catch (e) {
      print('Error loading place preferences: $e');
      return null;
    }
  }

  /// Place의 매칭 조건 저장 (완전한 매칭 시스템 연동)
  Future<bool> saveMatchingPreferences(PlacePreferencesData preferences) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('Error: No authenticated user');
        return false;
      }

      print('=== 매칭 시스템 통합 저장 시작 ===');
      print('User ID: ${currentUser.id}');
      print('Selected industries: ${preferences.selectedIndustryIds}');
      print('Selected jobs: ${preferences.selectedJobIds}');
      print('Selected styles: ${preferences.selectedStyleIds}');
      print('Selected welfare: ${preferences.selectedWelfareIds}');

      // 1. place_profiles 업데이트 (기본 제공 조건)
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

      print('✅ place_profiles 업데이트 완료');

      // 2. place_industries 저장 (업종)
      if (preferences.selectedIndustryIds.isNotEmpty) {
        // 기존 데이터 삭제
        await _supabase
            .from('place_industries')
            .delete()
            .eq('place_user_id', currentUser.id);

        // 새 데이터 삽입
        final industryInserts = preferences.selectedIndustryIds.map((industryId) => {
          'place_user_id': currentUser.id,
          'attribute_id': int.parse(industryId),
          'is_primary': true,
        }).toList();

        await _supabase
            .from('place_industries')
            .insert(industryInserts);

        print('✅ place_industries 저장: ${industryInserts.length}개');
      }

      // 3. place_attributes_link 저장 (제공하는 복지/혜택)
      final providedAttributes = <String>{};
      providedAttributes.addAll(preferences.selectedWelfareIds);
      providedAttributes.addAll(preferences.selectedPlaceFeatureIds);

      if (providedAttributes.isNotEmpty) {
        // 기존 데이터 삭제
        await _supabase
            .from('place_attributes_link')
            .delete()
            .eq('place_user_id', currentUser.id);

        // 새 데이터 삽입
        final attributeInserts = providedAttributes.map((attributeId) => {
          'place_user_id': currentUser.id,
          'attribute_id': int.parse(attributeId),
        }).toList();

        await _supabase
            .from('place_attributes_link')
            .insert(attributeInserts);

        print('✅ place_attributes_link 저장: ${attributeInserts.length}개');
      }

      // 4. place_preferences_link 저장 (원하는 직무/스타일)
      final preferredAttributes = <String>{};
      preferredAttributes.addAll(preferences.selectedJobIds);
      preferredAttributes.addAll(preferences.selectedStyleIds);

      if (preferredAttributes.isNotEmpty) {
        // 기존 데이터 삭제
        await _supabase
            .from('place_preferences_link')
            .delete()
            .eq('place_user_id', currentUser.id);

        // 새 데이터 삽입 (preference_level 포함)
        final preferenceInserts = preferredAttributes.map((attributeId) => {
          'place_user_id': currentUser.id,
          'attribute_id': int.parse(attributeId),
          'preference_level': preferences.selectedJobIds.contains(attributeId) 
              ? 'required'  // 직무는 필수
              : 'preferred', // 스타일은 선호
        }).toList();

        await _supabase
            .from('place_preferences_link')
            .insert(preferenceInserts);

        print('✅ place_preferences_link 저장: ${preferenceInserts.length}개');
      }

      // 5. 매칭 점수 캐시 무효화 (기존 점수들을 만료시킴)
      await _supabase
          .from('matching_scores')
          .update({
            'expires_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          })
          .eq('place_user_id', currentUser.id);

      print('✅ 기존 매칭 점수 캐시 무효화 완료');

      // 6. 매칭 큐에 추가 (백그라운드 재계산)
      await _supabase
          .from('matching_queue')
          .insert({
            'user_id': currentUser.id,
            'user_type': 'place',
            'priority': 8, // 프로필 업데이트는 높은 우선순위
            'status': 'pending',
          });

      print('✅ 매칭 큐에 재계산 요청 추가');

      // 7. 매칭 가중치 저장/업데이트 (기본값)
      await _supabase
          .from('matching_weights')
          .upsert({
            'user_id': currentUser.id,
            'user_type': 'place',
            'attribute_weight': 0.20,  // 스킬 매칭
            'preference_weight': 0.20, // 직무 선호도  
            'location_weight': 0.15,   // 지역
            'pay_weight': 0.20,        // 급여
            'schedule_weight': 0.15,   // 일정
            'experience_weight': 0.10, // 경력
            'updated_at': DateTime.now().toIso8601String(),
          });

      print('✅ 매칭 가중치 설정 완료');

      print('=== 매칭 시스템 통합 저장 완료 ===');
      return true;
    } catch (e) {
      print('❌ Error saving place preferences: $e');
      return false;
    }
  }
}
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberProfile {
  final String userId;
  final String? realName;
  final String nickname;
  final DateTime? birthdate;
  final String? gender;
  final String? contactPhone;
  final List<String>? profileImageUrls;
  final Map<String, dynamic>? socialLinks;
  final String? bio;
  final String? experienceLevel;
  final String? desiredPayType;
  final int? desiredPayAmount;
  final List<String>? desiredWorkingDays;
  final DateTime? availableFrom;
  final bool? canRelocate;
  final int level;
  final int experiencePoints;
  final String title;
  final DateTime? updatedAt;

  MemberProfile({
    required this.userId,
    this.realName,
    required this.nickname,
    this.birthdate,
    this.gender,
    this.contactPhone,
    this.profileImageUrls,
    this.socialLinks,
    this.bio,
    this.experienceLevel,
    this.desiredPayType,
    this.desiredPayAmount,
    this.desiredWorkingDays,
    this.availableFrom,
    this.canRelocate,
    this.level = 1,
    this.experiencePoints = 0,
    this.title = '새로운 스타',
    this.updatedAt,
  });

  factory MemberProfile.fromMap(Map<String, dynamic> map) {
    return MemberProfile(
      userId: map['user_id'] as String,
      realName: map['real_name'] as String?,
      nickname: map['nickname'] as String,
      birthdate: map['birthdate'] != null ? DateTime.parse(map['birthdate']) : null,
      gender: map['gender'] as String?,
      contactPhone: map['contact_phone'] as String?,
      profileImageUrls: map['profile_image_urls'] != null 
          ? List<String>.from(map['profile_image_urls']) : null,
      socialLinks: map['social_links'] as Map<String, dynamic>?,
      bio: map['bio'] as String?,
      experienceLevel: map['experience_level'] as String?,
      desiredPayType: map['desired_pay_type'] as String?,
      desiredPayAmount: map['desired_pay_amount'] as int?,
      desiredWorkingDays: map['desired_working_days'] != null
          ? List<String>.from(map['desired_working_days']) : null,
      availableFrom: map['available_from'] != null 
          ? DateTime.parse(map['available_from']) : null,
      canRelocate: map['can_relocate'] as bool?,
      level: map['level'] as int? ?? 1,
      experiencePoints: map['experience_points'] as int? ?? 0,
      title: map['title'] as String? ?? '새로운 스타',
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'real_name': realName,
      'nickname': nickname,
      'birthdate': birthdate?.toIso8601String(),
      'gender': gender,
      'contact_phone': contactPhone,
      'profile_image_urls': profileImageUrls,
      'social_links': socialLinks,
      'bio': bio,
      'experience_level': experienceLevel,
      'desired_pay_type': desiredPayType,
      'desired_pay_amount': desiredPayAmount,
      'desired_working_days': desiredWorkingDays,
      'available_from': availableFrom?.toIso8601String(),
      'can_relocate': canRelocate,
      'level': level,
      'experience_points': experiencePoints,
      'title': title,
    };
  }
}

class MatchingPreferencesData {
  final Set<int> selectedIndustryIds;
  final Set<int> selectedJobIds;
  final String? selectedPayType;
  final int? payAmount;
  final Set<String> selectedDays;
  final String? experienceLevel;
  final Set<int> selectedStyleIds;
  final Set<int> selectedPlaceFeatureIds;
  final Set<int> selectedWelfareIds;

  MatchingPreferencesData({
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

class MemberPreferencesService {
  MemberPreferencesService._private();
  static final MemberPreferencesService instance = MemberPreferencesService._private();

  /// Save all matching preferences for a user
  Future<bool> saveMatchingPreferences(MatchingPreferencesData data) async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      
      if (userId == null) {
        debugPrint('[MemberPreferencesService] No authenticated user');
        return false;
      }

      // Start a transaction-like batch operation
      final batch = <Future<void>>[];

      // 1. Update or insert member profile with pay conditions and working days
      batch.add(_updateMemberProfile(userId, data));

      // 2. Update member attributes (styles/strengths) - MEMBER_STYLE type
      batch.add(_updateMemberAttributes(userId, data.selectedStyleIds));

      // 3. Update member preferences (industries, jobs, place features, welfare)
      final preferenceIds = <int>{};
      preferenceIds.addAll(data.selectedIndustryIds);
      preferenceIds.addAll(data.selectedJobIds);
      preferenceIds.addAll(data.selectedPlaceFeatureIds);
      preferenceIds.addAll(data.selectedWelfareIds);
      
      batch.add(_updateMemberPreferences(userId, preferenceIds));

      // Execute all operations
      await Future.wait(batch);

      debugPrint('[MemberPreferencesService] Successfully saved all matching preferences for user: $userId');
      return true;
    } catch (e) {
      debugPrint('[MemberPreferencesService] Error saving matching preferences: $e');
      return false;
    }
  }

  /// Update member profile with pay conditions and working days
  Future<void> _updateMemberProfile(String userId, MatchingPreferencesData data) async {
    final client = Supabase.instance.client;

    final updateData = <String, dynamic>{};
    
    if (data.selectedPayType != null) {
      // Convert UI pay type to enum value
      final payTypeEnum = _convertPayTypeToEnum(data.selectedPayType!);
      updateData['desired_pay_type'] = payTypeEnum;
    }
    
    if (data.payAmount != null) {
      updateData['desired_pay_amount'] = data.payAmount;
    }
    
    if (data.selectedDays.isNotEmpty) {
      updateData['desired_working_days'] = data.selectedDays.toList();
    }

    if (updateData.isNotEmpty) {
      // Use upsert to handle both insert and update cases
      updateData['user_id'] = userId;
      
      await client
          .from('member_profiles')
          .upsert(updateData, onConflict: 'user_id');
      
      debugPrint('[MemberPreferencesService] Updated member profile for user: $userId');
    }
  }

  /// Update member attributes (styles/strengths)
  Future<void> _updateMemberAttributes(String userId, Set<int> styleIds) async {
    final client = Supabase.instance.client;

    // Delete existing member attributes
    await client
        .from('member_attributes_link')
        .delete()
        .eq('member_user_id', userId);

    // Insert new member attributes
    if (styleIds.isNotEmpty) {
      final List<Map<String, dynamic>> insertData = styleIds.map((attributeId) => {
        'member_user_id': userId,
        'attribute_id': attributeId,
      }).toList();

      await client
          .from('member_attributes_link')
          .insert(insertData);
    }

    debugPrint('[MemberPreferencesService] Updated member attributes for user: $userId (${styleIds.length} attributes)');
  }

  /// Update member preferences (industries, jobs, place features, welfare)
  Future<void> _updateMemberPreferences(String userId, Set<int> preferenceIds) async {
    final client = Supabase.instance.client;

    // Delete existing member preferences  
    await client
        .from('member_preferences_link')
        .delete()
        .eq('member_user_id', userId);

    // Insert new member preferences
    if (preferenceIds.isNotEmpty) {
      final List<Map<String, dynamic>> insertData = preferenceIds.map((attributeId) => {
        'member_user_id': userId,
        'attribute_id': attributeId,
      }).toList();

      await client
          .from('member_preferences_link')
          .insert(insertData);
    }

    debugPrint('[MemberPreferencesService] Updated member preferences for user: $userId (${preferenceIds.length} preferences)');
  }

  /// Convert UI pay type to database enum value
  String _convertPayTypeToEnum(String uiPayType) {
    switch (uiPayType) {
      case 'TC':
        return 'TC';
      case '일급':
        return 'DAILY';
      case '월급':
        return 'MONTHLY';
      case '협의':
        return 'NEGOTIABLE';
      default:
        return 'NEGOTIABLE';
    }
  }

  /// Load existing matching preferences for a user
  Future<MatchingPreferencesData?> loadMatchingPreferences() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      
      if (userId == null) {
        debugPrint('[MemberPreferencesService] No authenticated user');
        return null;
      }

      // Load member profile data
      final profileResponse = await client
          .from('member_profiles')
          .select('desired_pay_type, desired_pay_amount, desired_working_days, experience_level')
          .eq('user_id', userId)
          .maybeSingle();

      // Load member attributes (styles)
      final attributesResponse = await client
          .from('member_attributes_link')
          .select('attribute_id')
          .eq('member_user_id', userId);

      // Load member preferences (industries, jobs, features, welfare)
      final preferencesResponse = await client
          .from('member_preferences_link')
          .select('attribute_id, attributes!inner(type)')
          .eq('member_user_id', userId);

      // Parse the data
      String? payType;
      int? payAmount;
      Set<String> workingDays = {};
      
      if (profileResponse != null) {
        payType = _convertEnumToUIPayType(profileResponse['desired_pay_type']);
        payAmount = profileResponse['desired_pay_amount'];
        if (profileResponse['desired_working_days'] != null) {
          workingDays = Set<String>.from(profileResponse['desired_working_days']);
        }
      }

      // Parse attributes (styles)
      final Set<int> styleIds = {};
      for (var item in attributesResponse) {
        styleIds.add(item['attribute_id'] as int);
      }

      // Parse preferences by type
      final Set<int> industryIds = {};
      final Set<int> jobIds = {};
      final Set<int> placeFeatureIds = {};
      final Set<int> welfareIds = {};

      for (var item in preferencesResponse) {
        final attributeId = item['attribute_id'] as int;
        final attributeType = item['attributes']['type'] as String;
        
        switch (attributeType) {
          case 'INDUSTRY':
            industryIds.add(attributeId);
            break;
          case 'JOB_ROLE':
            jobIds.add(attributeId);
            break;
          case 'PLACE_FEATURE':
            placeFeatureIds.add(attributeId);
            break;
          case 'WELFARE':
            welfareIds.add(attributeId);
            break;
        }
      }

      final String? experienceLevel = profileResponse?['experience_level'] as String?;
      
      return MatchingPreferencesData(
        selectedIndustryIds: industryIds,
        selectedJobIds: jobIds,
        selectedPayType: payType,
        payAmount: payAmount,
        selectedDays: workingDays,
        experienceLevel: experienceLevel,
        selectedStyleIds: styleIds,
        selectedPlaceFeatureIds: placeFeatureIds,
        selectedWelfareIds: welfareIds,
      );

    } catch (e) {
      debugPrint('[MemberPreferencesService] Error loading matching preferences: $e');
      return null;
    }
  }

  /// Convert database enum to UI pay type
  String? _convertEnumToUIPayType(String? enumValue) {
    if (enumValue == null) return null;
    
    switch (enumValue) {
      case 'TC':
        return 'TC';
      case 'DAILY':
        return '일급';
      case 'MONTHLY':
        return '월급';
      case 'NEGOTIABLE':
        return '협의';
      default:
        return enumValue;
    }
  }

  /// Get or create member profile for current user
  Future<MemberProfile?> getMemberProfile() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      
      if (userId == null) {
        debugPrint('[MemberPreferencesService] No authenticated user');
        return null;
      }

      final response = await client
          .from('member_profiles')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return MemberProfile.fromMap(response);
      } else {
        // Create default profile if it doesn't exist
        final userResponse = await client
            .from('users')
            .select('nickname')
            .eq('id', userId)
            .maybeSingle();

        final nickname = userResponse?['nickname'] ?? '새로운 스타';
        
        final defaultProfile = MemberProfile(
          userId: userId,
          nickname: nickname,
        );

        await client
            .from('member_profiles')
            .insert(defaultProfile.toMap());

        return defaultProfile;
      }
    } catch (e) {
      debugPrint('[MemberPreferencesService] Error getting member profile: $e');
      return null;
    }
  }
}
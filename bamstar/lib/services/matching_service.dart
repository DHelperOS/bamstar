import 'package:supabase_flutter/supabase_flutter.dart';
import '../scenes/matching/models/match_profile.dart';

/// Enhanced matching service with full role-based UI support
class MatchingService {
  static final _supabase = Supabase.instance.client;
  
  /// Get matching profiles using Edge Functions (Enhanced)
  static Future<List<MatchProfile>> getMatchingProfiles({
    required bool isMemberView,
    int limit = 20,
    int offset = 0,
    int minScore = 60,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Call match-finder Edge Function
      final response = await _supabase.functions.invoke(
        'match-finder',
        body: {
          'userId': currentUser.id,
          'userType': isMemberView ? 'member' : 'place',
          'limit': limit,
          'offset': offset,
          'minScore': minScore,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to fetch matches: ${response.data}');
      }

      final responseData = response.data as Map<String, dynamic>;
      final matches = responseData['matches'] as List<dynamic>? ?? [];

      // Process matches with enhanced profile data
      final profileFutures = matches.map<Future<MatchProfile>>((matchData) async {
        return await _convertToMatchProfile(matchData, isMemberView);
      });

      return await Future.wait(profileFutures);

    } catch (e) {
      // Fallback to direct database query if Edge Function fails
      return await _getFallbackProfiles(
        isMemberView: isMemberView,
        limit: limit,
      );
    }
  }

  /// Convert match data from Edge Function to MatchProfile (Enhanced)
  static Future<MatchProfile> _convertToMatchProfile(Map<String, dynamic> matchData, bool isMemberView) async {
    final profile = isMemberView 
        ? matchData['place'] as Map<String, dynamic>? ?? {}
        : matchData['member'] as Map<String, dynamic>? ?? {};
    
    final profileData = isMemberView 
        ? profile['place_profile'] as Map<String, dynamic>? ?? {}
        : profile['member_profile'] as Map<String, dynamic>? ?? {};

    final matchScore = (matchData['total_score'] as num?)?.round() ?? 0;
    final userId = profile['id'] ?? '';
    
    if (isMemberView) {
      // Member sees Place profiles
      final heartsCount = await _getHeartsCount(userId, 'place');
      final favoritesCount = await _getFavoritesCount(userId, 'place');
      
      return MatchProfile(
        id: userId,
        name: profileData['place_name'] ?? '알 수 없는 업체',
        subtitle: _formatIndustries(profile['place_industries']),
        imageUrl: _getFirstImageUrl(profileData['profile_image_urls']),
        matchScore: matchScore,
        location: _extractLocation(profileData['address']),
        distance: _calculateDistanceFromCoords(
          profileData['latitude'],
          profileData['longitude'],
        ),
        payInfo: _formatPayInfo(
          profileData['offered_min_pay'],
          profileData['offered_max_pay'],
        ),
        schedule: _formatSchedule(profileData),
        tags: _generatePlaceTagsFromProfile(profileData, profile),
        type: ProfileType.place,
        isVerified: profileData['is_verified'] == true,
        isPremium: profileData['is_premium'] == true,
        hasSentHeart: matchData['has_sent_heart'] == true,
        isFavorited: matchData['is_favorited'] == true,
        heartsCount: heartsCount,
        favoritesCount: favoritesCount,
        industries: _extractIndustriesList(profile['place_industries']),
      );
    } else {
      // Place sees Member profiles (주요 수정 부분)
      final heartsCount = await _getHeartsCount(userId, 'member');
      final favoritesCount = await _getFavoritesCount(userId, 'member');
      
      return MatchProfile(
        id: userId,
        name: profileData['real_name'] ?? '알 수 없는 사용자',
        subtitle: _formatMemberIndustries(profile['member_industries']), // 지원 업종으로 변경
        imageUrl: _getFirstImageUrl(profileData['profile_image_urls']),
        matchScore: matchScore,
        location: _formatMemberAreas(profile['member_areas']), // 희망지역으로 변경
        distance: _calculateDistanceFromCoords(
          profileData['latitude'],
          profileData['longitude'],
        ),
        payInfo: '희망시급 ${_formatCurrency(profileData['desired_pay_amount'] ?? 0)}원',
        schedule: _formatMemberSchedule(profileData['desired_working_days']),
        tags: _generateMemberTagsFromProfile(profileData, profile),
        type: ProfileType.member,
        isVerified: profileData['is_verified'] == true,
        isPremium: profileData['is_premium'] == true,
        hasSentHeart: matchData['has_sent_heart'] == true,
        isFavorited: matchData['is_favorited'] == true,
        gender: profileData['gender'], // 성별 정보 추가
        heartsCount: heartsCount,
        favoritesCount: favoritesCount,
        industries: _extractIndustriesList(profile['member_industries']),
        preferredAreas: _extractAreasList(profile['member_areas']),
        experienceLevel: profileData['experience_level'], // 경력 레벨 추가
      );
    }
  }

  /// Format member industries from join data
  static String _formatMemberIndustries(List<dynamic>? industries) {
    if (industries == null || industries.isEmpty) {
      return '업종 미정';
    }
    
    final industryNames = industries
        .where((industry) => 
            industry['attributes'] != null && 
            industry['attributes']['type'] == 'INDUSTRY')
        .map((industry) => industry['attributes']['name'] as String)
        .toList();
    
    if (industryNames.isEmpty) {
      return '업종 미정';
    }
    
    return industryNames.join('•');
  }

  /// Format member preferred areas (top 2 priorities)
  static String _formatMemberAreas(List<dynamic>? areas) {
    if (areas == null || areas.isEmpty) {
      return '지역 협의';
    }
    
    final areaNames = areas
        .where((area) => area['area_groups'] != null)
        .map((area) => area['area_groups']['name'] as String)
        .take(2) // Only show top 2 priorities
        .toList();
    
    if (areaNames.isEmpty) {
      return '지역 협의';
    }
    
    return areaNames.join('•');
  }

  /// Format place industries from join data
  static String _formatIndustries(List<dynamic>? industries) {
    if (industries == null || industries.isEmpty) {
      return '업종 정보 없음';
    }
    
    final industryNames = industries
        .where((industry) => 
            industry['attributes'] != null && 
            industry['attributes']['type'] == 'INDUSTRY')
        .map((industry) => industry['attributes']['name'] as String)
        .toList();
    
    if (industryNames.isEmpty) {
      return '업종 정보 없음';
    }
    
    // Primary industry first, then others
    industryNames.sort((a, b) {
      final aIsPrimary = industries.any((industry) => 
          industry['attributes']['name'] == a && 
          industry['is_primary'] == true);
      final bIsPrimary = industries.any((industry) => 
          industry['attributes']['name'] == b && 
          industry['is_primary'] == true);
      
      if (aIsPrimary && !bIsPrimary) return -1;
      if (!aIsPrimary && bIsPrimary) return 1;
      return a.compareTo(b);
    });
    
    return industryNames.join('•');
  }

  /// Extract industries list
  static List<String> _extractIndustriesList(List<dynamic>? industries) {
    if (industries == null) return [];
    
    return industries
        .where((industry) => 
            industry['attributes'] != null && 
            industry['attributes']['type'] == 'INDUSTRY')
        .map((industry) => industry['attributes']['name'] as String)
        .toList();
  }

  /// Extract member preferred areas list
  static List<String> _extractAreasList(List<dynamic>? areas) {
    if (areas == null) return [];
    
    return areas
        .where((area) => area['area_groups'] != null)
        .map((area) => area['area_groups']['name'] as String)
        .take(2) // Only top 2 priorities
        .toList();
  }

  /// Get hearts count for user
  static Future<int> _getHeartsCount(String userId, String userType) async {
    try {
      final table = userType == 'member' ? 'member_hearts' : 'place_hearts';
      final column = userType == 'member' ? 'member_user_id' : 'place_user_id';
      
      final response = await _supabase
          .from(table)
          .select('*')
          .eq(column, userId);
          
      return response.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get favorites count for user
  static Future<int> _getFavoritesCount(String userId, String userType) async {
    try {
      final table = userType == 'member' ? 'member_favorites' : 'place_favorites';
      final column = userType == 'member' ? 'member_user_id' : 'place_user_id';
      
      final response = await _supabase
          .from(table)
          .select('*')
          .eq(column, userId);
          
      return response.length;
    } catch (e) {
      return 0;
    }
  }

  /// Generate member tags from profile data
  static List<String> _generateMemberTagsFromProfile(Map<String, dynamic> profileData, Map<String, dynamic> profile) {
    List<String> tags = [];
    
    // 1. member_attributes_link에서 가져온 개인 특성/스타일 태그
    final memberAttributes = profile['member_attributes'] as List<dynamic>? ?? [];
    for (final attr in memberAttributes.take(4)) { // 최대 4개 개인 특성
      if (attr['attributes'] != null) {
        final attributeData = attr['attributes'] as Map<String, dynamic>;
        final type = attributeData['type'] as String?;
        final name = attributeData['name'] as String?;
        
        // 개인 특성/스타일 관련 태그만 추가
        if (name != null && (type == 'MEMBER_STYLE' || type == 'JOB_ROLE')) {
          tags.add(name);
        }
      }
    }
    
    // 2. member_preferences_link에서 가져온 선호 태그  
    final memberPreferences = profile['member_preferences'] as List<dynamic>? ?? [];
    for (final pref in memberPreferences.take(3)) { // 최대 3개 선호 태그
      if (pref['attributes'] != null) {
        final attributeData = pref['attributes'] as Map<String, dynamic>;
        final name = attributeData['name'] as String?;
        final type = attributeData['type'] as String?;
        
        // 선호도 관련 태그만 추가
        if (name != null && (type == 'PLACE_FEATURE' || type == 'WELFARE')) {
          tags.add(name);
        }
      }
    }
    
    // 3. 업종 태그 (기존 로직 유지) - 최대 2개
    final industries = profile['member_industries'] as List<dynamic>? ?? [];
    for (final industry in industries.take(2)) {
      if (industry['attributes'] != null && 
          industry['attributes']['type'] == 'INDUSTRY') {
        tags.add(industry['attributes']['name'] as String);
      }
    }
    
    // 태그가 너무 많으면 최대 8개로 제한
    return tags.take(8).toList();
  }

  /// Generate place tags from profile data
  static List<String> _generatePlaceTagsFromProfile(Map<String, dynamic> profileData, Map<String, dynamic> profile) {
    List<String> tags = [];
    
    // Add place industries
    final industries = profile['place_industries'] as List<dynamic>? ?? [];
    for (final industry in industries.take(3)) {
      if (industry['attributes'] != null && 
          industry['attributes']['type'] == 'INDUSTRY') {
        tags.add(industry['attributes']['name'] as String);
      }
    }
    
    // Add manager gender
    if (profileData['manager_gender'] == '여') {
      tags.add('여성사장');
    } else if (profileData['manager_gender'] == '남') {
      tags.add('남성사장');  
    }
    
    // Add experience preference
    if (profileData['desired_experience_level']?.isNotEmpty == true) {
      tags.add('${_formatExperience(profileData['desired_experience_level'])} 선호');
    }
    
    return tags;
  }

  /// Send heart to a profile
  static Future<bool> sendHeart(String targetUserId, bool isMemberView) async {
    try {
      final response = await _supabase.functions.invoke(
        'hearts-manager',
        body: {
          'action': 'send',
          'targetUserId': targetUserId,
          'userType': isMemberView ? 'member' : 'place',
        },
      );

      return response.status == 200;
    } catch (e) {
      return false;
    }
  }

  /// Add profile to favorites
  static Future<bool> addToFavorites(String targetUserId, bool isMemberView, {String? notes}) async {
    try {
      final response = await _supabase.functions.invoke(
        'favorites-manager',
        body: {
          'action': 'add',
          'targetUserId': targetUserId,
          'userType': isMemberView ? 'member' : 'place',
          'notes': notes,
        },
      );

      return response.status == 200;
    } catch (e) {
      return false;
    }
  }

  /// Record pass action (for analytics)
  static Future<void> recordPassAction(String targetUserId, bool isMemberView) async {
    try {
      // Record pass in user_interactions table
      await _supabase.from('user_interactions').insert({
        'user_id': _supabase.auth.currentUser?.id,
        'target_user_id': targetUserId,
        'interaction_type': 'pass',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silent fail for analytics
    }
  }

  /// Fallback method for direct database queries
  static Future<List<MatchProfile>> _getFallbackProfiles({
    required bool isMemberView,
    int limit = 20,
  }) async {
    if (isMemberView) {
      return await _getPlaceProfiles(limit: limit);
    } else {
      return await _getMemberProfiles(limit: limit);
    }
  }

  /// Get place profiles directly from database
  static Future<List<MatchProfile>> _getPlaceProfiles({int limit = 20}) async {
    final response = await _supabase
        .from('place_profiles')
        .select('''
          user_id,
          place_name,
          address,
          latitude,
          longitude,
          manager_gender,
          offered_min_pay,
          offered_max_pay,
          desired_experience_level,
          profile_image_urls,
          is_verified,
          is_premium,
          users!inner(email),
          place_industries(
            attribute_id,
            is_primary,
            attributes:attributes(
              name,
              type
            )
          )
        ''')
        .limit(limit);

    final profileFutures = response.map<Future<MatchProfile>>((data) async {
      final userId = data['user_id'];
      final heartsCount = await _getHeartsCount(userId, 'place');
      final favoritesCount = await _getFavoritesCount(userId, 'place');
      
      return MatchProfile(
        id: userId,
        name: data['place_name'] ?? '알 수 없는 업체',
        subtitle: _formatIndustries(data['place_industries']),
        imageUrl: _getFirstImageUrl(data['profile_image_urls']),
        matchScore: _calculateMockScore(),
        location: _extractLocation(data['address']),
        distance: _calculateMockDistance(),
        payInfo: _formatPayInfo(data['offered_min_pay'], data['offered_max_pay']),
        schedule: _formatExperience(data['desired_experience_level']),
        tags: _generatePlaceTagsSync(data),
        type: ProfileType.place,
        isVerified: data['is_verified'] == true,
        isPremium: data['is_premium'] == true,
        heartsCount: heartsCount,
        favoritesCount: favoritesCount,
        industries: _extractIndustriesList(data['place_industries']),
      );
    });

    return await Future.wait(profileFutures);
  }

  /// Get member profiles directly from database
  static Future<List<MatchProfile>> _getMemberProfiles({int limit = 20}) async {
    final response = await _supabase
        .from('member_profiles')
        .select('''
          user_id,
          real_name,
          gender,
          age,
          experience_level,
          desired_pay_amount,
          desired_working_days,
          profile_image_urls,
          is_verified,
          is_premium,
          users!inner(email)
        ''')
        .limit(limit);

    final profileFutures = response.map<Future<MatchProfile>>((data) async {
      final userId = data['user_id'];
      final heartsCount = await _getHeartsCount(userId, 'member');
      final favoritesCount = await _getFavoritesCount(userId, 'member');
      
      return MatchProfile(
        id: userId,
        name: data['real_name'] ?? '알 수 없는 사용자',
        subtitle: _formatExperience(data['experience_level']),
        imageUrl: _getFirstImageUrl(data['profile_image_urls']),
        matchScore: _calculateMockScore(),
        location: '서울', // TODO: 실제 위치 정보
        distance: _calculateMockDistance(),
        payInfo: '희망시급 ${_formatCurrency(data['desired_pay_amount'] ?? 0)}원',
        schedule: _formatMemberSchedule(data['desired_working_days']),
        tags: _generateMemberTagsSync(data),
        type: ProfileType.member,
        isVerified: data['is_verified'] == true,
        isPremium: data['is_premium'] == true,
        gender: data['gender'],
        heartsCount: heartsCount,
        favoritesCount: favoritesCount,
      );
    });

    return await Future.wait(profileFutures);
  }

  // Helper methods (unchanged from original)
  
  static String? _getFirstImageUrl(dynamic imageUrls) {
    if (imageUrls is List && imageUrls.isNotEmpty) {
      return imageUrls[0] as String?;
    }
    return null;
  }

  static String _extractLocation(String? address) {
    if (address == null || address.isEmpty) return '위치 정보 없음';
    
    final parts = address.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}';
    }
    return address.length > 20 ? '${address.substring(0, 20)}...' : address;
  }

  static double _calculateDistanceFromCoords(double? lat, double? lng) {
    // TODO: Implement real distance calculation using user's current location
    // For now return mock distance
    return _calculateMockDistance();
  }

  static String _formatPayInfo(int? minPay, int? maxPay) {
    if (minPay == null && maxPay == null) return '급여 협의';
    if (minPay != null && maxPay != null) {
      return '시급 ${_formatCurrency(minPay)}-${_formatCurrency(maxPay)}원';
    }
    if (minPay != null) return '시급 ${_formatCurrency(minPay)}원 이상';
    if (maxPay != null) return '시급 ${_formatCurrency(maxPay)}원 이하';
    return '급여 협의';
  }

  static String _formatSchedule(Map<String, dynamic> profileData) {
    return profileData['business_hours'] ?? '시간 협의';
  }

  static String _formatMemberSchedule(dynamic workingDays) {
    if (workingDays is List && workingDays.isNotEmpty) {
      return workingDays.join(', ');
    }
    return '협의 가능';
  }

  static String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  static String _formatExperience(String? experience) {
    switch (experience) {
      case 'NEWCOMER': return '신입';
      case 'JUNIOR': return '초급';
      case 'INTERMEDIATE': return '중급';
      case 'SENIOR': return '고급';
      case 'EXPERT': return '전문가';
      case 'NEWBIE': return '신입';
      default: return '경력 미상';
    }
  }

  static List<String> _generatePlaceTagsSync(Map<String, dynamic> data) {
    List<String> tags = [];
    
    final industries = data['place_industries'] as List<dynamic>?;
    if (industries != null) {
      for (final industry in industries.take(3)) {
        if (industry['attributes'] != null && 
            industry['attributes']['type'] == 'INDUSTRY') {
          tags.add(industry['attributes']['name'] as String);
        }
      }
    }
    
    if (data['manager_gender'] == '여') {
      tags.add('여성사장');
    } else if (data['manager_gender'] == '남') {
      tags.add('남성사장');  
    }
    
    if (data['desired_experience_level']?.isNotEmpty == true) {
      tags.add('${_formatExperience(data['desired_experience_level'])} 선호');
    }
    
    return tags.isEmpty ? ['신입환영', '교육지원', '복리후생'] : tags;
  }

  static List<String> _generateMemberTagsSync(Map<String, dynamic> data) {
    List<String> tags = [];
    
    if (data['experience_level']?.isNotEmpty == true) {
      tags.add(_formatExperience(data['experience_level']));
    }
    
    if (data['gender'] == 'FEMALE') {
      tags.add('여성');
    } else if (data['gender'] == 'MALE') {
      tags.add('남성');
    }
    
    if (data['age'] != null) {
      final age = data['age'] as int;
      tags.add('${age}세');
      if (age >= 20 && age < 30) {
        tags.add('20대');
      } else if (age >= 30 && age < 40) {
        tags.add('30대');
      }
    }
    
    return tags.isEmpty ? ['성실함', '책임감', '팀워크'] : tags;
  }

  static int _calculateMockScore() {
    return 80 + (DateTime.now().millisecond % 20);
  }

  static double _calculateMockDistance() {
    return (DateTime.now().millisecond % 50) / 10.0;
  }
}
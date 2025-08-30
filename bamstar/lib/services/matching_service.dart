import 'package:supabase_flutter/supabase_flutter.dart';
import '../scenes/matching/models/match_profile.dart';

/// Real-time matching service with Supabase integration
class MatchingService {
  static final _supabase = Supabase.instance.client;
  
  /// Get matching profiles using Edge Functions
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

      return matches.map<MatchProfile>((matchData) {
        return _convertToMatchProfile(matchData, isMemberView);
      }).toList();

    } catch (e) {
      // Fallback to direct database query if Edge Function fails
      return await _getFallbackProfiles(
        isMemberView: isMemberView,
        limit: limit,
      );
    }
  }

  /// Convert match data from Edge Function to MatchProfile
  static MatchProfile _convertToMatchProfile(Map<String, dynamic> matchData, bool isMemberView) {
    final profile = isMemberView 
        ? matchData['place'] as Map<String, dynamic>? ?? {}
        : matchData['member'] as Map<String, dynamic>? ?? {};
    
    final profileData = isMemberView 
        ? profile['place_profile'] as Map<String, dynamic>? ?? {}
        : profile['member_profile'] as Map<String, dynamic>? ?? {};

    final matchScore = (matchData['total_score'] as num?)?.round() ?? 0;
    
    if (isMemberView) {
      // Member sees Place profiles
      return MatchProfile(
        id: profile['id'] ?? '',
        name: profileData['place_name'] ?? '알 수 없는 업체',
        subtitle: profileData['business_type'] ?? '',
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
        tags: [], // Tags will be loaded separately
        type: ProfileType.place,
        isVerified: profileData['is_verified'] == true,
        isPremium: profileData['is_premium'] == true,
        hasSentHeart: matchData['has_sent_heart'] == true,
        isFavorited: matchData['is_favorited'] == true,
      );
    } else {
      // Place sees Member profiles
      return MatchProfile(
        id: profile['id'] ?? '',
        name: profileData['real_name'] ?? '알 수 없는 사용자',
        subtitle: _formatExperience(profileData['experience_level']),
        imageUrl: _getFirstImageUrl(profileData['profile_image_urls']),
        matchScore: matchScore,
        location: _extractMemberLocation(profileData),
        distance: _calculateDistanceFromCoords(
          profileData['latitude'],
          profileData['longitude'],
        ),
        payInfo: '희망시급 ${_formatCurrency(profileData['desired_pay_amount'] ?? 0)}원',
        schedule: _formatMemberSchedule(profileData['desired_working_days']),
        tags: [], // Tags will be loaded separately
        type: ProfileType.member,
        isVerified: profileData['is_verified'] == true,
        isPremium: profileData['is_premium'] == true,
        hasSentHeart: matchData['has_sent_heart'] == true,
        isFavorited: matchData['is_favorited'] == true,
      );
    }
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
          business_type,
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
          users!inner(email)
        ''')
        .limit(limit);

    return response.map<MatchProfile>((data) {
      return MatchProfile(
        id: data['user_id'],
        name: data['place_name'] ?? '알 수 없는 업체',
        subtitle: data['business_type'] ?? '',
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
      );
    }).toList();
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

    return response.map<MatchProfile>((data) {
      return MatchProfile(
        id: data['user_id'],
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
      );
    }).toList();
  }

  /// Get first image URL from array
  static String? _getFirstImageUrl(dynamic imageUrls) {
    if (imageUrls is List && imageUrls.isNotEmpty) {
      return imageUrls[0] as String?;
    }
    return null;
  }

  /// Extract location from address
  static String _extractLocation(String? address) {
    if (address == null || address.isEmpty) return '위치 정보 없음';
    
    final parts = address.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}';
    }
    return address.length > 20 ? '${address.substring(0, 20)}...' : address;
  }

  /// Extract member location
  static String _extractMemberLocation(Map<String, dynamic> profileData) {
    // Try to get from address or use default
    return _extractLocation(profileData['address']) != '위치 정보 없음' 
        ? _extractLocation(profileData['address'])
        : '서울';
  }

  /// Calculate distance from coordinates
  static double _calculateDistanceFromCoords(double? lat, double? lng) {
    // TODO: Implement real distance calculation using user's current location
    // For now return mock distance
    return _calculateMockDistance();
  }

  /// Format pay information
  static String _formatPayInfo(int? minPay, int? maxPay) {
    if (minPay == null && maxPay == null) return '급여 협의';
    if (minPay != null && maxPay != null) {
      return '시급 ${_formatCurrency(minPay)}-${_formatCurrency(maxPay)}원';
    }
    if (minPay != null) return '시급 ${_formatCurrency(minPay)}원 이상';
    if (maxPay != null) return '시급 ${_formatCurrency(maxPay)}원 이하';
    return '급여 협의';
  }

  /// Format schedule for place profiles
  static String _formatSchedule(Map<String, dynamic> profileData) {
    return profileData['business_hours'] ?? '시간 협의';
  }

  /// Format member schedule
  static String _formatMemberSchedule(dynamic workingDays) {
    if (workingDays is List && workingDays.isNotEmpty) {
      return workingDays.join(', ');
    }
    return '협의 가능';
  }

  /// Format currency with commas
  static String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  /// Format experience level
  static String _formatExperience(String? experience) {
    switch (experience) {
      case 'NEWCOMER': return '신입';
      case 'JUNIOR': return '초급';
      case 'INTERMEDIATE': return '중급';
      case 'SENIOR': return '고급';
      case 'EXPERT': return '전문가';
      default: return '경력 미상';
    }
  }

  /// Get place tags from database
  static Future<List<String>> _getPlaceTags(String placeUserId) async {
    try {
      // Get attributes associated with this place
      final response = await _supabase
          .from('place_attributes_link')
          .select('''
            attributes!inner(
              name,
              type
            )
          ''')
          .eq('place_user_id', placeUserId);

      final tags = <String>[];
      for (final item in response) {
        final attr = item['attributes'] as Map<String, dynamic>;
        tags.add(attr['name'] as String);
      }

      // Add some default tags if none found
      if (tags.isEmpty) {
        tags.addAll(['신입환영', '교육지원', '복리후생']);
      }

      return tags;
    } catch (e) {
      return ['신입환영', '교육지원', '복리후생'];
    }
  }

  /// Get member tags from database
  static Future<List<String>> _getMemberTags(String memberUserId) async {
    try {
      // Get attributes associated with this member
      final response = await _supabase
          .from('member_attributes_link')
          .select('''
            attributes!inner(
              name,
              type
            )
          ''')
          .eq('member_user_id', memberUserId);

      final tags = <String>[];
      for (final item in response) {
        final attr = item['attributes'] as Map<String, dynamic>;
        tags.add(attr['name'] as String);
      }

      // Add some default tags if none found
      if (tags.isEmpty) {
        tags.addAll(['성실함', '책임감', '팀워크']);
      }

      return tags;
    } catch (e) {
      return ['성실함', '책임감', '팀워크'];
    }
  }

  /// Generate tags for place profiles (sync version for fallback)
  static List<String> _generatePlaceTagsSync(Map<String, dynamic> data) {
    List<String> tags = [];
    
    if (data['business_type']?.isNotEmpty == true) {
      tags.add(data['business_type']);
    }
    
    if (data['manager_gender'] == '여') {
      tags.add('여성사장');
    } else if (data['manager_gender'] == '남') {
      tags.add('남성사장');  
    }
    
    if (data['desired_experience_level']?.isNotEmpty == true) {
      tags.add('${_formatExperience(data['desired_experience_level'])} 선호');
    }
    
    tags.addAll(['신입환영', '교육지원', '복리후생']);
    return tags;
  }

  /// Generate tags for member profiles (sync version for fallback)
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
      tags.add('$age세');
      if (age >= 20 && age < 30) {
        tags.add('20대');
      } else if (age >= 30 && age < 40) {
        tags.add('30대');
      }
    }
    
    tags.addAll(['성실함', '책임감', '팀워크']);
    return tags;
  }

  /// Calculate mock matching score (fallback)
  static int _calculateMockScore() {
    return 80 + (DateTime.now().millisecond % 20);
  }

  /// Calculate mock distance (fallback)
  static double _calculateMockDistance() {
    return (DateTime.now().millisecond % 50) / 10.0;
  }
}
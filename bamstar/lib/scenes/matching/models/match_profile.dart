/// Match Profile Model
enum ProfileType { member, place }

enum SwipeDirection { left, right, up, down }

class MatchProfile {
  final String id;
  final String name;
  final String subtitle;
  final String? imageUrl;
  final int matchScore;
  final String location;
  final double distance;
  final String payInfo;
  final String schedule;
  final List<String> tags;
  final ProfileType type;
  final DateTime? lastActive;
  final bool isVerified;
  final bool isPremium;
  final bool hasSentHeart;
  final bool isFavorited;
  final int heartsCount;
  final int favoritesCount;
  final String? gender;
  final List<String> industries;
  final List<String> preferredAreas;
  final String? experienceLevel;

  MatchProfile({
    required this.id,
    required this.name,
    required this.subtitle,
    this.imageUrl,
    required this.matchScore,
    required this.location,
    required this.distance,
    required this.payInfo,
    required this.schedule,
    required this.tags,
    required this.type,
    this.lastActive,
    this.isVerified = false,
    this.isPremium = false,
    this.hasSentHeart = false,
    this.isFavorited = false,
    this.heartsCount = 0,
    this.favoritesCount = 0,
    this.gender,
    this.industries = const [],
    this.preferredAreas = const [],
    this.experienceLevel,
  });

  /// Get score color based on match percentage
  String get scoreEmoji {
    if (matchScore >= 90) return '🔥';
    if (matchScore >= 80) return '⭐';
    if (matchScore >= 70) return '👍';
    return '👌';
  }

  /// Format distance for display
  String get formattedDistance {
    if (distance < 1.0) {
      return '${(distance * 1000).toInt()}m';
    }
    return '${distance.toStringAsFixed(1)}km';
  }

  /// Check if profile was recently active (within last hour)
  bool get isRecentlyActive {
    if (lastActive == null) return false;
    return DateTime.now().difference(lastActive!).inHours < 1;
  }

  /// Format industries from place_industries join data
  static String _formatIndustriesFromJson(List<dynamic>? industries) {
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
    
    return industryNames.join(', ');
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

  /// Format member preferred areas
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

  /// Extract member industries list
  static List<String> _extractMemberIndustriesList(List<dynamic>? industries) {
    if (industries == null) return [];
    
    return industries
        .where((industry) => 
            industry['attributes'] != null && 
            industry['attributes']['type'] == 'INDUSTRY')
        .map((industry) => industry['attributes']['name'] as String)
        .toList();
  }

  /// Extract place industries list
  static List<String> _extractPlaceIndustriesList(List<dynamic>? industries) {
    if (industries == null) return [];
    
    return industries
        .where((industry) => 
            industry['attributes'] != null && 
            industry['attributes']['type'] == 'INDUSTRY')
        .map((industry) => industry['attributes']['name'] as String)
        .toList();
  }

  /// Extract member preferred areas list
  static List<String> _extractMemberAreasList(List<dynamic>? areas) {
    if (areas == null) return [];
    
    return areas
        .where((area) => area['area_groups'] != null)
        .map((area) => area['area_groups']['name'] as String)
        .take(2) // Only top 2 priorities
        .toList();
  }

  /// Create from Supabase JSON (Enhanced)
  factory MatchProfile.fromJson(Map<String, dynamic> json, ProfileType type) {
    return MatchProfile(
      id: json['user_id'] ?? json['id'],
      name: type == ProfileType.place 
        ? json['place_name'] ?? json['name']
        : json['nickname'] ?? json['name'],
      subtitle: type == ProfileType.place
        ? _formatIndustriesFromJson(json['place_industries'])
        : _formatMemberIndustries(json['member_industries']),
      imageUrl: json['profile_image_url'],
      matchScore: (json['match_score'] ?? 0).toInt(),
      location: type == ProfileType.place
        ? json['location'] ?? json['address'] ?? ''
        : _formatMemberAreas(json['member_areas']),
      distance: (json['distance'] ?? 0.0).toDouble(),
      payInfo: type == ProfileType.place
        ? '시급 ${json['offered_min_pay']}-${json['offered_max_pay']}원'
        : '희망시급 ${json['desired_pay_amount']}원',
      schedule: json['schedule'] ?? json['desired_working_days']?.join(', ') ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      type: type,
      lastActive: json['last_active'] != null 
        ? DateTime.parse(json['last_active'])
        : null,
      isVerified: json['is_verified'] ?? false,
      isPremium: json['is_premium'] ?? false,
      gender: json['gender'],
      industries: type == ProfileType.member
        ? _extractMemberIndustriesList(json['member_industries'])
        : _extractPlaceIndustriesList(json['place_industries']),
      preferredAreas: type == ProfileType.member
        ? _extractMemberAreasList(json['member_areas'])
        : [],
      heartsCount: json['hearts_count'] ?? 0,
      favoritesCount: json['favorites_count'] ?? 0,
      experienceLevel: json['experience_level'],
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'match_score': matchScore,
      'location': location,
      'distance': distance,
      'pay_info': payInfo,
      'schedule': schedule,
      'tags': tags,
      'type': type.toString(),
      'last_active': lastActive?.toIso8601String(),
      'is_verified': isVerified,
      'is_premium': isPremium,
      'has_sent_heart': hasSentHeart,
      'is_favorited': isFavorited,
      'hearts_count': heartsCount,
      'favorites_count': favoritesCount,
      'gender': gender,
      'industries': industries,
      'preferred_areas': preferredAreas,
      'experience_level': experienceLevel,
    };
  }
}
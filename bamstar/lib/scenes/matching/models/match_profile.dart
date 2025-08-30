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

  /// Create from Supabase JSON
  factory MatchProfile.fromJson(Map<String, dynamic> json, ProfileType type) {
    return MatchProfile(
      id: json['user_id'] ?? json['id'],
      name: type == ProfileType.place 
        ? json['place_name'] ?? json['name']
        : json['nickname'] ?? json['name'],
      subtitle: type == ProfileType.place
        ? json['business_type'] ?? ''
        : '${json['experience_level'] ?? '신입'}',
      imageUrl: json['profile_image_url'],
      matchScore: (json['match_score'] ?? 0).toInt(),
      location: json['location'] ?? json['address'] ?? '',
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
    };
  }
}
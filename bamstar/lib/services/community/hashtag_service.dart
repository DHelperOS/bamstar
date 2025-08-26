import 'package:bamstar/services/community/community_repository.dart';

/// Hashtag recommendation and suggestion service
/// Provides enhanced hashtag features using AI and analytics
class HashtagService {
  static final HashtagService _instance = HashtagService._internal();
  factory HashtagService() => _instance;
  HashtagService._internal();

  static HashtagService get instance => _instance;

  final _repository = CommunityRepository.instance;

  /// Cache for hashtag suggestions to avoid repeated API calls
  final Map<String, List<String>> _suggestionCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheTtl = const Duration(minutes: 10);

  /// Get intelligent hashtag suggestions based on content
  Future<List<HashtagSuggestion>> getSmartSuggestions(String content) async {
    if (content.trim().isEmpty) return [];

    final cacheKey = content.toLowerCase().trim();
    final now = DateTime.now();

    // Check cache first
    if (_suggestionCache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null && now.difference(timestamp) < _cacheTtl) {
        return _suggestionCache[cacheKey]!
            .map((tag) => HashtagSuggestion(
                  name: tag,
                  source: SuggestionSource.cached,
                  relevanceScore: 0.8,
                ))
            .toList();
      }
    }

    try {
      // Get recommendations from multiple sources
      final List<Future<List<String>>> futures = [
        _repository.getHashtagRecommendations(content, maxRecommendations: 5),
        _repository.getCachedTrendingHashtags(limit: 3),
        _repository.getPersonalizedHashtagRecommendations(limit: 3),
      ];

      final results = await Future.wait(futures);
      final contentBased = results[0];
      final trending = results[1];
      final personalized = results[2];

      // Combine and rank suggestions
      final suggestions = <HashtagSuggestion>[];
      final seen = <String>{};

      // Add content-based suggestions (highest priority)
      for (final tag in contentBased) {
        if (seen.add(tag.toLowerCase())) {
          suggestions.add(HashtagSuggestion(
            name: tag,
            source: SuggestionSource.contentBased,
            relevanceScore: 0.9,
          ));
        }
      }

      // Add personalized suggestions
      for (final tag in personalized) {
        if (seen.add(tag.toLowerCase())) {
          suggestions.add(HashtagSuggestion(
            name: tag,
            source: SuggestionSource.personalized,
            relevanceScore: 0.7,
          ));
        }
      }

      // Add trending suggestions (lower priority)
      for (final tag in trending) {
        if (seen.add(tag.toLowerCase())) {
          suggestions.add(HashtagSuggestion(
            name: tag,
            source: SuggestionSource.trending,
            relevanceScore: 0.6,
          ));
        }
      }

      // If no suggestions were found from primary sources, use popular fallback
      if (suggestions.isEmpty) {
        try {
          final popularTags = await _repository.getPopularHashtags(limit: 5);
          for (final tag in popularTags) {
            if (seen.add(tag.name.toLowerCase())) {
              suggestions.add(HashtagSuggestion(
                name: tag.name,
                source: SuggestionSource.popularFallback,
                relevanceScore: 0.5, // Lower relevance than other sources
              ));
            }
          }
        } catch (e) {
          print('Failed to get popular fallback suggestions: $e');
          // return empty list if fallback also fails
        }
      }

      // Cache results only if they are not from the popular fallback
      if (suggestions.isNotEmpty && suggestions.first.source != SuggestionSource.popularFallback) {
          final tagNames = suggestions.map((s) => s.name).toList();
          _suggestionCache[cacheKey] = tagNames;
          _cacheTimestamps[cacheKey] = now;
      }

      return suggestions;
    } catch (e) {
      print('Failed to get smart suggestions: $e');
      return [];
    }
  }

  /// Get trending hashtags with metadata
  Future<List<TrendingHashtag>> getTrendingWithMetadata({
    int limit = 10,
    int daysBack = 7,
  }) async {
    try {
      final trending = await _repository.getTrendingHashtags(
        daysBack: daysBack,
        limit: limit,
      );

      return trending
          .map((item) => TrendingHashtag(
                name: item['name'] as String,
                usageCount: item['usage_count'] as int,
                trendScore: item['trend_score'] as double,
                category: item['category'] as String,
              ))
          .toList();
    } catch (e) {
      print('Failed to get trending with metadata: $e');
      return [];
    }
  }

  /// Search hashtags with smart matching
  Future<List<HashtagSearchResult>> searchSmart(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final results = await _repository.searchHashtagsEnhanced(
        query,
        limitCount: 15,
      );

      return results
          .map((item) => HashtagSearchResult(
                name: item['name'] as String,
                usageCount: item['usage_count'] as int,
                lastUsed: item['last_used'] as String?,
                matchType: _parseMatchType(item['match_type'] as String),
              ))
          .toList();
    } catch (e) {
      print('Failed to search hashtags: $e');
      return [];
    }
  }

  /// Get daily curated hashtags
  Future<DailyCuration?> getDailyCuration() async {
    try {
      final curation = await _repository.getDailyCuration();
      if (curation == null) return null;

      final trending = (curation['trending_hashtags'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          [];
      final aiSuggestions = (curation['ai_suggestions'] as List?)
              ?.cast<String>() ??
          [];

      return DailyCuration(
        trendingHashtags: trending
            .map((item) => TrendingHashtag(
                  name: item['hashtag_name'] as String? ?? '',
                  usageCount: item['usage_count'] as int? ?? 0,
                  trendScore: (item['trend_score'] as num?)?.toDouble() ?? 0.0,
                  category: item['category'] as String? ?? 'general',
                ))
            .toList(),
        aiSuggestions: aiSuggestions,
        createdAt: DateTime.tryParse(curation['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
    } catch (e) {
      print('Failed to get daily curation: $e');
      return null;
    }
  }

  /// Clear suggestion cache
  void clearCache() {
    _suggestionCache.clear();
    _cacheTimestamps.clear();
  }

  /// Parse match type from string
  MatchType _parseMatchType(String type) {
    switch (type.toLowerCase()) {
      case 'exact':
        return MatchType.exact;
      case 'prefix':
        return MatchType.prefix;
      case 'contains':
        return MatchType.contains;
      case 'fuzzy':
        return MatchType.fuzzy;
      default:
        return MatchType.contains;
    }
  }
}

/// Data models for hashtag suggestions and search results

class HashtagSuggestion {
  final String name;
  final SuggestionSource source;
  final double relevanceScore;

  const HashtagSuggestion({
    required this.name,
    required this.source,
    required this.relevanceScore,
  });
}

enum SuggestionSource {
  contentBased,
  trending,
  personalized,
  cached,
  popularFallback,
}

class TrendingHashtag {
  final String name;
  final int usageCount;
  final double trendScore;
  final String category;

  const TrendingHashtag({
    required this.name,
    required this.usageCount,
    required this.trendScore,
    required this.category,
  });
}

class HashtagSearchResult {
  final String name;
  final int usageCount;
  final String? lastUsed;
  final MatchType matchType;

  const HashtagSearchResult({
    required this.name,
    required this.usageCount,
    this.lastUsed,
    required this.matchType,
  });
}

enum MatchType {
  exact,
  prefix,
  contains,
  fuzzy,
}

class DailyCuration {
  final List<TrendingHashtag> trendingHashtags;
  final List<String> aiSuggestions;
  final DateTime createdAt;

  const DailyCuration({
    required this.trendingHashtags,
    required this.aiSuggestions,
    required this.createdAt,
  });
}
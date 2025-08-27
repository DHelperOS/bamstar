import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Simple in-memory cache entry for avatars with fetch timestamp.
class _AvatarsCacheEntry {
  final List<String> avatars;
  final DateTime fetchedAt;
  _AvatarsCacheEntry(this.avatars, this.fetchedAt);
}

// Cache entry for blocked users list
class _BlockedUsersCacheEntry {
  final List<String> blockedUserIds;
  final DateTime fetchedAt;
  _BlockedUsersCacheEntry(this.blockedUserIds, this.fetchedAt);
}

/// Data models
class CommunityPost {
  final int id;
  final String content;
  final bool isAnonymous;
  final String? authorId;
  final String authorName; // anonymized label when isAnonymous=true
  final String? authorAvatarUrl; // null for anonymous
  final List<String> imageUrls;
  final DateTime createdAt;
  final List<String> hashtags; // without '#'
  final List<String> recentCommenterAvatarUrls; // for avatar stack
  final int likesCount;
  final int viewCount;
  final int commentCount;
  final bool isLiked;

  const CommunityPost({
    required this.id,
    required this.content,
    required this.isAnonymous,
    required this.authorId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.imageUrls,
    required this.createdAt,
    required this.hashtags,
    required this.recentCommenterAvatarUrls,
    this.likesCount = 0,
    this.viewCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });
}

class HashtagChannel {
  final int id;
  final String name; // lower-case
  final String? description;
  final String? category;
  final int postCount;
  final int subscriberCount;
  final DateTime? lastUsedAt;

  const HashtagChannel({
    required this.id,
    required this.name,
    this.description,
    this.category,
    required this.postCount,
    required this.subscriberCount,
    required this.lastUsedAt,
  });
}

/// Sorting modes for feed requests.
enum SortMode { latest, popular, liked }

/// Repository for community data. Minimal supabase wiring + mock fallbacks.
class CommunityRepository {
  CommunityRepository._();
  static final instance = CommunityRepository._();
  final _client = Supabase.instance.client;
  // In-memory cache: postId -> avatars entry
  final Map<int, _AvatarsCacheEntry> _avatarsCache = {};
  // Default TTL for avatars cache (can be tuned at runtime)
  Duration avatarsCacheTtl = const Duration(seconds: 60);
  
  // Cache for blocked users list
  _BlockedUsersCacheEntry? _blockedUsersCache;
  // Default TTL for blocked users cache (5 minutes)
  Duration blockedUsersCacheTtl = const Duration(minutes: 5);

  /// Adjust avatars cache TTL at runtime (useful for dev vs prod).
  void setAvatarsCacheTtl(Duration ttl) {
    avatarsCacheTtl = ttl;
  }

  Future<List<HashtagChannel>> fetchSubscribedChannels({int limit = 12}) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return _mockChannels(limit);
      final res = await _client
          .from('community_subscriptions')
          .select(
            'target_hashtag_id, community_hashtags(id, name, description, category, post_count, subscriber_count, last_used_at)',
          )
          .eq('subscriber_id', uid)
          .limit(limit);
      final List data = res as List? ?? [];
      return data.map((row) {
        final tag = row['community_hashtags'];
        return HashtagChannel(
          id: tag['id'] as int,
          name: (tag['name'] as String).toLowerCase(),
          description: tag['description'] as String?,
          category: tag['category'] as String?,
          postCount: tag['post_count'] as int? ?? 0,
          subscriberCount: tag['subscriber_count'] as int? ?? 0,
          lastUsedAt: tag['last_used_at'] == null
              ? null
              : DateTime.tryParse(tag['last_used_at'] as String),
        );
      }).toList();
    } catch (_) {
      return _mockChannels(limit);
    }
  }

  Future<List<CommunityPost>> fetchFeed({
    String? filterTag,
    String? contentQuery,
    int limit = 20,
    int? offset,
    SortMode sortMode = SortMode.latest,
    Duration? window,
  }) async {
    try {
      // Get blocked users list for filtering
      final blockedUserIds = await _getBlockedUsersWithCache();
      
      // If caller requested popularity/likes sorting, do a two-phase fetch:
      // 1) fetch candidate post ids within the timeframe (window) up to
      //    offset+limit items, 2) fetch aggregated counts via RPC, sort ids
      //    by counts, then 3) fetch full post rows for the selected ids in
      //    that order. This avoids client-side sorting on paginated pages
      //    which can show misleading results.
      if (sortMode == SortMode.popular || sortMode == SortMode.liked) {
        // Prefer server-side ranking RPC if available (deployed to DB).
        final int effectiveWindowDays = window?.inDays ?? 7;
        final String metric = (sortMode == SortMode.popular)
            ? 'comments'
            : 'likes';
        try {
          final res = await _client.rpc(
            'get_top_posts_by_metric',
            params: {
              'window_days': effectiveWindowDays,
              'metric': metric,
              'limit_val': limit * 2, // Fetch more to account for blocked posts
              'offset_val': offset ?? 0,
            },
          );
          final List data = res as List? ?? [];
          if (data.isEmpty) return <CommunityPost>[];

          final posts = <CommunityPost>[];
          final ids = <int>[];
          for (final row in data) {
            if (row is! Map) continue;
            try {
              final id = (row['id'] as num).toInt();
              final authorId = row['author_id'] as String?;
              
              // Skip posts from blocked users
              if (authorId != null && blockedUserIds.contains(authorId)) {
                continue;
              }
              
              ids.add(id);
              final content = (row['content'] as String?) ?? '';
              final bool _isAnon = (row['is_anonymous'] as bool?) ?? false;
              final imageUrls =
                  (row['image_urls'] as List?)?.cast<String>() ?? const [];
              final createdAt =
                  DateTime.tryParse(row['created_at'] as String? ?? '') ??
                  DateTime.now();
              final likesCount = (row['likes_count'] as num?)?.toInt() ?? 0;
              final commentsCount =
                  (row['comments_count'] as num?)?.toInt() ?? 0;
              final viewCount = (row['view_count'] as num?)?.toInt() ?? 0;

              posts.add(
                CommunityPost(
                  id: id,
                  content: content,
                  isAnonymous: _isAnon,
                  authorId: authorId,
                  authorName: _isAnon ? '익명의 스타' : '스타 ${id % 97}',
                  // RPC does not return author avatar by default; keep null for anonymous protection
                  authorAvatarUrl: _isAnon ? null : null,
                  imageUrls: imageUrls,
                  createdAt: createdAt,
                  hashtags: _extractHashtags(content),
                  recentCommenterAvatarUrls: const [],
                  likesCount: likesCount,
                  viewCount: viewCount,
                  commentCount: commentsCount,
                ),
              );
              
              // Stop when we have enough posts
              if (posts.length >= limit) break;
            } catch (_) {
              // skip row parsing errors
            }
          }

          // Determine which posts the current user has liked
          Map<int, bool> likedMap = {};
          try {
            if (ids.isNotEmpty) {
              final liked = await getUserLikedPosts(ids);
              for (final pid in liked) likedMap[pid] = true;
            }
          } catch (_) {}

          // Batch-fetch commenter avatars for the posts we just built.
          try {
            final avatarsMap = await fetchCommenterAvatarsForPosts(
              ids,
              limitPerPost: 3,
              concurrency: 6,
            );
            return posts.map((p) {
              final avatars = avatarsMap[p.id];
              final liked = likedMap[p.id] == true;
              return CommunityPost(
                id: p.id,
                content: p.content,
                isAnonymous: p.isAnonymous,
                authorId: p.authorId,
                authorName: p.authorName,
                authorAvatarUrl: p.authorAvatarUrl,
                imageUrls: p.imageUrls,
                createdAt: p.createdAt,
                hashtags: p.hashtags,
                recentCommenterAvatarUrls:
                    (avatars != null && avatars.isNotEmpty)
                    ? avatars
                    : p.recentCommenterAvatarUrls,
                likesCount: p.likesCount,
                viewCount: p.viewCount,
                commentCount: p.commentCount,
                isLiked: liked,
              );
            }).toList();
          } catch (_) {
            return posts;
          }
        } catch (_) {
          // RPC failed or not available — fall back to previous candidate-id approach
        }

        // FALLBACK: previous client-side candidate fetch (kept for compatibility)
        // Ensure we have a window for popularity/liked modes. Default to 7 days.
        final Duration effectiveWindow = window ?? const Duration(days: 7);
        final cutoff = DateTime.now()
            .subtract(effectiveWindow)
            .toIso8601String();

        // Determine how many candidate ids we need to fetch to satisfy
        // pagination after sorting: offset+limit (if offset absent, offset=0).
        final int start = offset ?? 0;
        final int need = (start + limit) * 2; // Fetch more to account for blocked posts

        // Step 1: fetch candidate ids within the window ordered by created_at
        final List idRows = await _client
            .from('community_posts')
            .select('id, author_id')
            .gte('created_at', cutoff)
            .order('created_at', ascending: false)
            .limit(need);
            
        // Filter out blocked users' posts
        final List<int> candidateIds = [];
        for (final row in (idRows as List? ?? [])) {
          final authorId = row['author_id'] as String?;
          if (authorId == null || !blockedUserIds.contains(authorId)) {
            candidateIds.add((row['id'] as num).toInt());
          }
        }

        if (candidateIds.isEmpty) return <CommunityPost>[];

        // Step 2: obtain aggregated counts for these candidate ids
        Map<int, Map<String, int>> counts = {};
        try {
          counts = await getPostCounts(candidateIds);
        } catch (_) {
          // Fallback to client-side grouped reads (less efficient)
          final idsCsv = candidateIds.join(',');
          final commentsRes = await _client
              .from('community_comments')
              .select('post_id')
              .filter('post_id', 'in', '($idsCsv)');
          final Map<int, int> commentCounts = {};
          for (final row in (commentsRes as List? ?? [])) {
            final pid = row['post_id'] as int?;
            if (pid == null) continue;
            commentCounts[pid] = (commentCounts[pid] ?? 0) + 1;
          }

          final likesRes = await _client
              .from('community_likes')
              .select('post_id')
              .filter('post_id', 'in', '($idsCsv)');
          final Map<int, int> likeCountsMap = {};
          for (final row in (likesRes as List? ?? [])) {
            final pid = row['post_id'] as int?;
            if (pid == null) continue;
            likeCountsMap[pid] = (likeCountsMap[pid] ?? 0) + 1;
          }

          for (final id in candidateIds) {
            counts[id] = {
              'likes_count': likeCountsMap[id] ?? 0,
              'comments_count': commentCounts[id] ?? 0,
            };
          }
        }

        // Step 3: sort candidate ids by the requested metric
        candidateIds.sort((a, b) {
          final aCount = (sortMode == SortMode.popular)
              ? (counts[a]?['comments_count'] ?? 0)
              : (counts[a]?['likes_count'] ?? 0);
          final bCount = (sortMode == SortMode.popular)
              ? (counts[b]?['comments_count'] ?? 0)
              : (counts[b]?['likes_count'] ?? 0);
          return bCount.compareTo(aCount);
        });

        // Apply pagination to sorted ids
        final pagedIds = candidateIds.skip(start).take(limit).toList();
        if (pagedIds.isEmpty) return <CommunityPost>[];

        // Step 4: fetch full post rows for pagedIds and preserve order
        final idsCsvFetch = pagedIds.join(',');
        final List rows = await _client
            .from('community_posts')
            .select(
              'id, content, is_anonymous, created_at, image_urls, author_id, view_count, author_avatar_url',
            )
            .filter('id', 'in', '($idsCsvFetch)');
        final Map<int, Map> mapById = {};
        for (final r in (rows as List? ?? [])) {
          try {
            mapById[(r['id'] as num).toInt()] = Map<String, dynamic>.from(
              r as Map,
            );
          } catch (_) {}
        }

        // Build CommunityPost list preserving pagedIds order and attach counts
        final posts = <CommunityPost>[];
        for (final id in pagedIds) {
          final row = mapById[id];
          if (row == null) continue; // skip missing
          final content = (row['content'] as String?) ?? '';
          final bool _isAnon = (row['is_anonymous'] as bool?) ?? false;
          final String? _dbAvatar = (row['author_avatar_url'] as String?);
          posts.add(
            CommunityPost(
              id: id,
              content: content,
              isAnonymous: _isAnon,
              authorId: row['author_id'] as String?,
              authorName: _isAnon ? '익명의 스타' : '스타 ${id % 97}',
              authorAvatarUrl: _isAnon ? null : _dbAvatar,
              imageUrls:
                  (row['image_urls'] as List?)?.cast<String>() ?? const [],
              createdAt:
                  DateTime.tryParse(row['created_at'] as String? ?? '') ??
                  DateTime.now(),
              hashtags: _extractHashtags(content),
              recentCommenterAvatarUrls: const [],
              likesCount: counts[id]?['likes_count'] ?? 0,
              viewCount: (row['view_count'] as int?) ?? 0,
              commentCount: counts[id]?['comments_count'] ?? 0,
            ),
          );
        }

        // Determine which posts the current user has liked
        Map<int, bool> likedMap = {};
        try {
          final liked = await getUserLikedPosts(pagedIds);
          for (final pid in liked) likedMap[pid] = true;
        } catch (_) {}

        // Batch-fetch commenter avatars for the posts we just built.
        try {
          final ids = posts.map((p) => p.id).toList();
          final avatarsMap = await fetchCommenterAvatarsForPosts(
            ids,
            limitPerPost: 3,
            concurrency: 6,
          );
          return posts.map((p) {
            final avatars = avatarsMap[p.id];
            final liked = likedMap[p.id] == true;
            return CommunityPost(
              id: p.id,
              content: p.content,
              isAnonymous: p.isAnonymous,
              authorId: p.authorId,
              authorName: p.authorName,
              authorAvatarUrl: p.authorAvatarUrl,
              imageUrls: p.imageUrls,
              createdAt: p.createdAt,
              hashtags: p.hashtags,
              recentCommenterAvatarUrls: (avatars != null && avatars.isNotEmpty)
                  ? avatars
                  : p.recentCommenterAvatarUrls,
              likesCount: p.likesCount,
              viewCount: p.viewCount,
              commentCount: p.commentCount,
              isLiked: liked,
            );
          }).toList();
        } catch (_) {
          return posts;
        }
      }

      // Default/latest flow
      dynamic q = _client
          .from('community_posts')
          .select(
            'id, content, is_anonymous, created_at, image_urls, author_id, view_count',
          );
      if (filterTag != null && filterTag.trim().isNotEmpty) {
        final ft = filterTag.toLowerCase();
        // Filter by hashtag-like token in content
        q = q.ilike('content', '%#$ft%');
      } else if (contentQuery != null && contentQuery.trim().isNotEmpty) {
        final cq = contentQuery.trim();
        // Search posts by content
        q = q.ilike('content', '%$cq%');
      }
      
      // Filter out blocked users at the database level if we have any
      if (blockedUserIds.isNotEmpty) {
        q = q.not('author_id', 'in', blockedUserIds);
      }
      
      if (offset != null) {
        q = q.range(offset, offset + limit - 1);
      } else {
        q = q.limit(limit);
      }
      // Apply timeframe window when requested (e.g., last 7 days)
      if (window != null) {
        final cutoff = DateTime.now().subtract(window);
        q = q.gte('created_at', cutoff.toIso8601String());
      }

      final List data = await q.order('created_at', ascending: false);
      
      // Additional client-side filtering as safety net
      final filteredData = data.where((row) {
        final authorId = row['author_id'] as String?;
        return authorId == null || !blockedUserIds.contains(authorId);
      }).toList();
      
      // collect post ids for aggregated counts
      final postIds = filteredData.map((r) => r['id'] as int).toList();
      Map<int, int> commentCounts = {};
      Map<int, int> likeCounts = {};
      try {
        if (postIds.isNotEmpty) {
          // Prefer server-side RPC to fetch per-post counts in one call
          try {
            final rpcRes = await getPostCounts(postIds);
            for (final e in rpcRes.entries) {
              likeCounts[e.key] = e.value['likes_count'] ?? 0;
              commentCounts[e.key] = e.value['comments_count'] ?? 0;
            }
          } catch (_) {
            // Fallback: client-side grouped reads (previous behavior)
            final idsCsv = postIds.join(',');
            final commentsRes = await _client
                .from('community_comments')
                .select('post_id')
                .filter('post_id', 'in', '($idsCsv)');
            for (final row in (commentsRes as List? ?? [])) {
              final pid = row['post_id'] as int?;
              if (pid == null) continue;
              commentCounts[pid] = (commentCounts[pid] ?? 0) + 1;
            }

            final likesRes = await _client
                .from('community_likes')
                .select('post_id')
                .filter('post_id', 'in', '($idsCsv)');
            for (final row in (likesRes as List? ?? [])) {
              final pid = row['post_id'] as int?;
              if (pid == null) continue;
              likeCounts[pid] = (likeCounts[pid] ?? 0) + 1;
            }
          }
        }
      } catch (_) {
        // ignore aggregation errors and fallback to defaults
      }
      // Build posts first (with fallback avatars). Then fetch commenter avatars
      // for all posts in a batched manner and replace the placeholder lists.
      final posts = filteredData.map((row) {
        final id = row['id'] as int;
        final content = (row['content'] as String?) ?? '';
        final bool _isAnon = (row['is_anonymous'] as bool?) ?? false;
        final String? _dbAvatar = (row['author_avatar_url'] as String?);
        return CommunityPost(
          id: id,
          content: content,
          isAnonymous: _isAnon,
          authorId: row['author_id'] as String?,
          authorName: _isAnon ? '익명의 스타' : '스타 ${id % 97}',
          // Do not provide avatar URL when anonymous to avoid leaking real
          // profile images; UI will render a blurred placeholder and label.
          authorAvatarUrl: _isAnon ? null : _dbAvatar,
          imageUrls: (row['image_urls'] as List?)?.cast<String>() ?? const [],
          createdAt:
              DateTime.tryParse(row['created_at'] as String? ?? '') ??
              DateTime.now(),
          // 서버 컬럼이 없으므로 내용에서 해시태그를 파싱합니다.
          hashtags: _extractHashtags(content),
          // Start with empty commenter avatars; will be filled by
          // fetchCommenterAvatarsForPosts if any real commenters exist.
          recentCommenterAvatarUrls: const [],
          likesCount: likeCounts[id] ?? 0,
          viewCount: (row['view_count'] as int?) ?? 0,
          commentCount: commentCounts[id] ?? 0,
        );
      }).toList();

      // If sorting by popularity or likes is requested, we already fetched
      // aggregated counts above (commentCounts, likeCounts). Use those to
      // sort posts client-side while preserving pagination.
      if (sortMode == SortMode.popular) {
        posts.sort(
          (a, b) =>
              (commentCounts[b.id] ?? 0).compareTo(commentCounts[a.id] ?? 0),
        );
      } else if (sortMode == SortMode.liked) {
        posts.sort(
          (a, b) => (likeCounts[b.id] ?? 0).compareTo(likeCounts[a.id] ?? 0),
        );
      }

      // Determine which posts the current user has liked (if authenticated)
      Map<int, bool> likedMap = {};
      try {
        if (postIds.isNotEmpty) {
          final liked = await getUserLikedPosts(postIds);
          for (final pid in liked) likedMap[pid] = true;
        }
      } catch (_) {
        // ignore
      }

      // Batch-fetch commenter avatars for the posts we just built. Limit
      // concurrency to avoid hammering the RPC.
      try {
        final ids = posts.map((p) => p.id).toList();
        final avatarsMap = await fetchCommenterAvatarsForPosts(
          ids,
          limitPerPost: 3,
          concurrency: 6,
        );
        // Replace placeholders when data is available.
        return posts.map((p) {
          final avatars = avatarsMap[p.id];
          final liked = likedMap[p.id] == true;
          return CommunityPost(
            id: p.id,
            content: p.content,
            isAnonymous: p.isAnonymous,
            authorId: p.authorId,
            authorName: p.authorName,
            authorAvatarUrl: p.authorAvatarUrl,
            imageUrls: p.imageUrls,
            createdAt: p.createdAt,
            hashtags: p.hashtags,
            recentCommenterAvatarUrls: (avatars != null && avatars.isNotEmpty)
                ? avatars
                : p.recentCommenterAvatarUrls,
            likesCount: p.likesCount,
            viewCount: p.viewCount,
            commentCount: p.commentCount,
            isLiked: liked,
          );
        }).toList();
      } catch (_) {
        return posts;
      }
    } catch (_) {
      // If the server call fails, do NOT return mock posts when the caller
      // specifically requested popularity/likes sorting — returning fake
      // mock data for those modes is misleading. For those cases return an
      // empty list so the UI can show an appropriate empty state.
      if (sortMode == SortMode.popular || sortMode == SortMode.liked) {
        return <CommunityPost>[];
      }
      return _mockPosts(limit: limit);
    }
  }

  // Alternate fetch method with enhanced filtering
  Future<List<CommunityPost>> fetchCommunityPostsEnhanced({
    String? filterTag,
    String? contentQuery,
    int limit = 20,
    int? offset,
    SortMode sortMode = SortMode.latest,
    Duration? window,
  }) async {
    try {
      // If caller requested popularity/likes sorting, do a two-phase fetch:
      // 1) fetch candidate post ids within the timeframe (window) up to
      //    offset+limit items, 2) fetch aggregated counts via RPC, sort ids
      //    by counts, then 3) fetch full post rows for the selected ids in
      //    that order. This avoids client-side sorting on paginated pages
      //    which can show misleading results.
      if (sortMode == SortMode.popular || sortMode == SortMode.liked) {
        // Prefer server-side ranking RPC if available (deployed to DB).
        final int effectiveWindowDays = window?.inDays ?? 7;
        final String metric = (sortMode == SortMode.popular)
            ? 'comments'
            : 'likes';
        try {
          final res = await _client.rpc(
            'get_top_posts_by_metric',
            params: {
              'window_days': effectiveWindowDays,
              'metric': metric,
              'limit_val': limit,
              'offset_val': offset ?? 0,
            },
          );
          final List data = res as List? ?? [];
          if (data.isEmpty) return <CommunityPost>[];

          final posts = <CommunityPost>[];
          final ids = <int>[];
          for (final row in data) {
            if (row is! Map) continue;
            try {
              final id = (row['id'] as num).toInt();
              ids.add(id);
              final content = (row['content'] as String?) ?? '';
              final bool _isAnon = (row['is_anonymous'] as bool?) ?? false;
              final imageUrls =
                  (row['image_urls'] as List?)?.cast<String>() ?? const [];
              final createdAt =
                  DateTime.tryParse(row['created_at'] as String? ?? '') ??
                  DateTime.now();
              final likesCount = (row['likes_count'] as num?)?.toInt() ?? 0;
              final commentsCount =
                  (row['comments_count'] as num?)?.toInt() ?? 0;
              final viewCount = (row['view_count'] as num?)?.toInt() ?? 0;

              posts.add(
                CommunityPost(
                  id: id,
                  content: content,
                  isAnonymous: _isAnon,
                  authorId: row['author_id'] as String?,
                  authorName: _isAnon ? '익명의 스타' : '스타 ${id % 97}',
                  // RPC does not return author avatar by default; keep null for anonymous protection
                  authorAvatarUrl: _isAnon ? null : null,
                  imageUrls: imageUrls,
                  createdAt: createdAt,
                  hashtags: _extractHashtags(content),
                  recentCommenterAvatarUrls: const [],
                  likesCount: likesCount,
                  viewCount: viewCount,
                  commentCount: commentsCount,
                ),
              );
            } catch (_) {
              // skip row parsing errors
            }
          }

          // Determine which posts the current user has liked
          Map<int, bool> likedMap = {};
          try {
            if (ids.isNotEmpty) {
              final liked = await getUserLikedPosts(ids);
              for (final pid in liked) likedMap[pid] = true;
            }
          } catch (_) {}

          // Batch-fetch commenter avatars for the posts we just built.
          try {
            final avatarsMap = await fetchCommenterAvatarsForPosts(
              ids,
              limitPerPost: 3,
              concurrency: 6,
            );
            return posts.map((p) {
              final avatars = avatarsMap[p.id];
              final liked = likedMap[p.id] == true;
              return CommunityPost(
                id: p.id,
                content: p.content,
                isAnonymous: p.isAnonymous,
                authorId: p.authorId,
                authorName: p.authorName,
                authorAvatarUrl: p.authorAvatarUrl,
                imageUrls: p.imageUrls,
                createdAt: p.createdAt,
                hashtags: p.hashtags,
                recentCommenterAvatarUrls:
                    (avatars != null && avatars.isNotEmpty)
                    ? avatars
                    : p.recentCommenterAvatarUrls,
                likesCount: p.likesCount,
                viewCount: p.viewCount,
                commentCount: p.commentCount,
                isLiked: liked,
              );
            }).toList();
          } catch (_) {
            return posts;
          }
        } catch (_) {
          // RPC failed or not available — fall back to previous candidate-id approach
        }

        // FALLBACK: previous client-side candidate fetch (kept for compatibility)
        // Ensure we have a window for popularity/liked modes. Default to 7 days.
        final Duration effectiveWindow = window ?? const Duration(days: 7);
        final cutoff = DateTime.now()
            .subtract(effectiveWindow)
            .toIso8601String();

        // Determine how many candidate ids we need to fetch to satisfy
        // pagination after sorting: offset+limit (if offset absent, offset=0).
        final int start = offset ?? 0;
        final int need = start + limit;

        // Step 1: fetch candidate ids within the window ordered by created_at
        final List idRows = await _client
            .from('community_posts')
            .select('id')
            .gte('created_at', cutoff)
            .order('created_at', ascending: false)
            .limit(need);
        final List<int> candidateIds = (idRows as List? ?? [])
            .map((r) => (r['id'] as num).toInt())
            .toList();

        if (candidateIds.isEmpty) return <CommunityPost>[];

        // Step 2: obtain aggregated counts for these candidate ids
        Map<int, Map<String, int>> counts = {};
        try {
          counts = await getPostCounts(candidateIds);
        } catch (_) {
          // Fallback to client-side grouped reads (less efficient)
          final idsCsv = candidateIds.join(',');
          final commentsRes = await _client
              .from('community_comments')
              .select('post_id')
              .filter('post_id', 'in', '($idsCsv)');
          final Map<int, int> commentCounts = {};
          for (final row in (commentsRes as List? ?? [])) {
            final pid = row['post_id'] as int?;
            if (pid == null) continue;
            commentCounts[pid] = (commentCounts[pid] ?? 0) + 1;
          }

          final likesRes = await _client
              .from('community_likes')
              .select('post_id')
              .filter('post_id', 'in', '($idsCsv)');
          final Map<int, int> likeCountsMap = {};
          for (final row in (likesRes as List? ?? [])) {
            final pid = row['post_id'] as int?;
            if (pid == null) continue;
            likeCountsMap[pid] = (likeCountsMap[pid] ?? 0) + 1;
          }

          for (final id in candidateIds) {
            counts[id] = {
              'likes_count': likeCountsMap[id] ?? 0,
              'comments_count': commentCounts[id] ?? 0,
            };
          }
        }

        // Step 3: sort candidate ids by the requested metric
        candidateIds.sort((a, b) {
          final aCount = (sortMode == SortMode.popular)
              ? (counts[a]?['comments_count'] ?? 0)
              : (counts[a]?['likes_count'] ?? 0);
          final bCount = (sortMode == SortMode.popular)
              ? (counts[b]?['comments_count'] ?? 0)
              : (counts[b]?['likes_count'] ?? 0);
          return bCount.compareTo(aCount);
        });

        // Apply pagination to sorted ids
        final pagedIds = candidateIds.skip(start).take(limit).toList();
        if (pagedIds.isEmpty) return <CommunityPost>[];

        // Step 4: fetch full post rows for pagedIds and preserve order
        final idsCsvFetch = pagedIds.join(',');
        final List rows = await _client
            .from('community_posts')
            .select(
              'id, content, is_anonymous, created_at, image_urls, author_id, view_count, author_avatar_url',
            )
            .filter('id', 'in', '($idsCsvFetch)');
        final Map<int, Map> mapById = {};
        for (final r in (rows as List? ?? [])) {
          try {
            mapById[(r['id'] as num).toInt()] = Map<String, dynamic>.from(
              r as Map,
            );
          } catch (_) {}
        }

        // Build CommunityPost list preserving pagedIds order and attach counts
        final posts = <CommunityPost>[];
        for (final id in pagedIds) {
          final row = mapById[id];
          if (row == null) continue; // skip missing
          final content = (row['content'] as String?) ?? '';
          final bool _isAnon = (row['is_anonymous'] as bool?) ?? false;
          final String? _dbAvatar = (row['author_avatar_url'] as String?);
          posts.add(
            CommunityPost(
              id: id,
              content: content,
              isAnonymous: _isAnon,
              authorId: row['author_id'] as String?,
              authorName: _isAnon ? '익명의 스타' : '스타 ${id % 97}',
              authorAvatarUrl: _isAnon ? null : _dbAvatar,
              imageUrls:
                  (row['image_urls'] as List?)?.cast<String>() ?? const [],
              createdAt:
                  DateTime.tryParse(row['created_at'] as String? ?? '') ??
                  DateTime.now(),
              hashtags: _extractHashtags(content),
              recentCommenterAvatarUrls: const [],
              likesCount: counts[id]?['likes_count'] ?? 0,
              viewCount: (row['view_count'] as int?) ?? 0,
              commentCount: counts[id]?['comments_count'] ?? 0,
            ),
          );
        }

        // Determine which posts the current user has liked
        Map<int, bool> likedMap = {};
        try {
          final liked = await getUserLikedPosts(pagedIds);
          for (final pid in liked) likedMap[pid] = true;
        } catch (_) {}

        // Batch-fetch commenter avatars for the posts we just built.
        try {
          final ids = posts.map((p) => p.id).toList();
          final avatarsMap = await fetchCommenterAvatarsForPosts(
            ids,
            limitPerPost: 3,
            concurrency: 6,
          );
          return posts.map((p) {
            final avatars = avatarsMap[p.id];
            final liked = likedMap[p.id] == true;
            return CommunityPost(
              id: p.id,
              content: p.content,
              isAnonymous: p.isAnonymous,
              authorId: p.authorId,
              authorName: p.authorName,
              authorAvatarUrl: p.authorAvatarUrl,
              imageUrls: p.imageUrls,
              createdAt: p.createdAt,
              hashtags: p.hashtags,
              recentCommenterAvatarUrls: (avatars != null && avatars.isNotEmpty)
                  ? avatars
                  : p.recentCommenterAvatarUrls,
              likesCount: p.likesCount,
              viewCount: p.viewCount,
              commentCount: p.commentCount,
              isLiked: liked,
            );
          }).toList();
        } catch (_) {
          return posts;
        }
      }

      // Default/latest flow
      dynamic q = _client
          .from('community_posts')
          .select(
            'id, content, is_anonymous, created_at, image_urls, author_id, view_count',
          );
      if (filterTag != null && filterTag.trim().isNotEmpty) {
        final ft = filterTag.toLowerCase();
        // Filter by hashtag-like token in content
        q = q.ilike('content', '%#$ft%');
      } else if (contentQuery != null && contentQuery.trim().isNotEmpty) {
        final cq = contentQuery.trim();
        // Search posts by content
        q = q.ilike('content', '%$cq%');
      }
      if (offset != null) {
        q = q.range(offset, offset + limit - 1);
      } else {
        q = q.limit(limit);
      }
      // Apply timeframe window when requested (e.g., last 7 days)
      if (window != null) {
        final cutoff = DateTime.now().subtract(window);
        q = q.gte('created_at', cutoff.toIso8601String());
      }

      final List data = await q.order('created_at', ascending: false);
      // collect post ids for aggregated counts
      final postIds = data.map((r) => r['id'] as int).toList();
      Map<int, int> commentCounts = {};
      Map<int, int> likeCounts = {};
      try {
        if (postIds.isNotEmpty) {
          // Prefer server-side RPC to fetch per-post counts in one call
          try {
            final rpcRes = await getPostCounts(postIds);
            for (final e in rpcRes.entries) {
              likeCounts[e.key] = e.value['likes_count'] ?? 0;
              commentCounts[e.key] = e.value['comments_count'] ?? 0;
            }
          } catch (_) {
            // Fallback: client-side grouped reads (previous behavior)
            final idsCsv = postIds.join(',');
            final commentsRes = await _client
                .from('community_comments')
                .select('post_id')
                .filter('post_id', 'in', '($idsCsv)');
            for (final row in (commentsRes as List? ?? [])) {
              final pid = row['post_id'] as int?;
              if (pid == null) continue;
              commentCounts[pid] = (commentCounts[pid] ?? 0) + 1;
            }

            final likesRes = await _client
                .from('community_likes')
                .select('post_id')
                .filter('post_id', 'in', '($idsCsv)');
            for (final row in (likesRes as List? ?? [])) {
              final pid = row['post_id'] as int?;
              if (pid == null) continue;
              likeCounts[pid] = (likeCounts[pid] ?? 0) + 1;
            }
          }
        }
      } catch (_) {
        // ignore aggregation errors and fallback to defaults
      }
      // Build posts first (with fallback avatars). Then fetch commenter avatars
      // for all posts in a batched manner and replace the placeholder lists.
      final posts = data.map((row) {
        final id = row['id'] as int;
        final content = (row['content'] as String?) ?? '';
        final bool _isAnon = (row['is_anonymous'] as bool?) ?? false;
        final String? _dbAvatar = (row['author_avatar_url'] as String?);
        return CommunityPost(
          id: id,
          content: content,
          isAnonymous: _isAnon,
          authorId: row['author_id'] as String?,
          authorName: _isAnon ? '익명의 스타' : '스타 ${id % 97}',
          // Do not provide avatar URL when anonymous to avoid leaking real
          // profile images; UI will render a blurred placeholder and label.
          authorAvatarUrl: _isAnon ? null : _dbAvatar,
          imageUrls: (row['image_urls'] as List?)?.cast<String>() ?? const [],
          createdAt:
              DateTime.tryParse(row['created_at'] as String? ?? '') ??
              DateTime.now(),
          // 서버 컬럼이 없으므로 내용에서 해시태그를 파싱합니다.
          hashtags: _extractHashtags(content),
          // Start with empty commenter avatars; will be filled by
          // fetchCommenterAvatarsForPosts if any real commenters exist.
          recentCommenterAvatarUrls: const [],
          likesCount: likeCounts[id] ?? 0,
          viewCount: (row['view_count'] as int?) ?? 0,
          commentCount: commentCounts[id] ?? 0,
        );
      }).toList();

      // If sorting by popularity or likes is requested, we already fetched
      // aggregated counts above (commentCounts, likeCounts). Use those to
      // sort posts client-side while preserving pagination.
      if (sortMode == SortMode.popular) {
        posts.sort(
          (a, b) =>
              (commentCounts[b.id] ?? 0).compareTo(commentCounts[a.id] ?? 0),
        );
      } else if (sortMode == SortMode.liked) {
        posts.sort(
          (a, b) => (likeCounts[b.id] ?? 0).compareTo(likeCounts[a.id] ?? 0),
        );
      }

      // Determine which posts the current user has liked (if authenticated)
      Map<int, bool> likedMap = {};
      try {
        if (postIds.isNotEmpty) {
          final liked = await getUserLikedPosts(postIds);
          for (final pid in liked) likedMap[pid] = true;
        }
      } catch (_) {
        // ignore
      }

      // Batch-fetch commenter avatars for the posts we just built. Limit
      // concurrency to avoid hammering the RPC.
      try {
        final ids = posts.map((p) => p.id).toList();
        final avatarsMap = await fetchCommenterAvatarsForPosts(
          ids,
          limitPerPost: 3,
          concurrency: 6,
        );
        // Replace placeholders when data is available.
        return posts.map((p) {
          final avatars = avatarsMap[p.id];
          final liked = likedMap[p.id] == true;
          return CommunityPost(
            id: p.id,
            content: p.content,
            isAnonymous: p.isAnonymous,
            authorId: p.authorId,
            authorName: p.authorName,
            authorAvatarUrl: p.authorAvatarUrl,
            imageUrls: p.imageUrls,
            createdAt: p.createdAt,
            hashtags: p.hashtags,
            recentCommenterAvatarUrls: (avatars != null && avatars.isNotEmpty)
                ? avatars
                : p.recentCommenterAvatarUrls,
            likesCount: p.likesCount,
            viewCount: p.viewCount,
            commentCount: p.commentCount,
            isLiked: liked,
          );
        }).toList();
      } catch (_) {
        return posts;
      }
    } catch (_) {
      // If the server call fails, do NOT return mock posts when the caller
      // specifically requested popularity/likes sorting — returning fake
      // mock data for those modes is misleading. For those cases return an
      // empty list so the UI can show an appropriate empty state.
      if (sortMode == SortMode.popular || sortMode == SortMode.liked) {
        return <CommunityPost>[];
      }
      return _mockPosts(limit: limit);
    }
  }

  /// Server RPC wrapper: returns map postId -> {likes_count, comments_count}
  Future<Map<int, Map<String, int>>> getPostCounts(List<int> postIds) async {
    final out = <int, Map<String, int>>{};
    if (postIds.isEmpty) return out;
    try {
      final res = await _client.rpc(
        'get_post_counts',
        params: {'post_ids_in': postIds},
      );
      final List data = res as List? ?? [];
      for (final row in data) {
        if (row is Map && row['post_id'] != null) {
          final pid = (row['post_id'] as num).toInt();
          final lc = (row['likes_count'] as num?)?.toInt() ?? 0;
          final cc = (row['comments_count'] as num?)?.toInt() ?? 0;
          out[pid] = {'likes_count': lc, 'comments_count': cc};
        }
      }
      return out;
    } catch (_) {
      return {};
    }
  }

  /// RPC: returns list of post ids liked by current user (from provided list)
  Future<List<int>> getUserLikedPosts(List<int> postIds) async {
    if (postIds.isEmpty) return [];
    try {
      final res = await _client.rpc(
        'get_user_liked_posts',
        params: {'post_ids_in': postIds},
      );
      final List data = res as List? ?? [];
      final out = <int>[];
      for (final row in data) {
        if (row is Map && row['post_id'] != null) {
          out.add((row['post_id'] as num).toInt());
        } else if (row is num) {
          out.add(row.toInt());
        }
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  /// RPC: increment view count and return new value
  Future<int?> incrementPostView(int postId) async {
    try {
      final res = await _client.rpc(
        'increment_post_view',
        params: {'post_id_in': postId},
      );
      final List data = res as List? ?? [];
      if (data.isNotEmpty) {
        final row = data.first;
        if (row is Map && row['new_count'] != null) {
          return (row['new_count'] as num).toInt();
        } else if (row is num) {
          return row.toInt();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Toggle like for a post (optimistic update supported on client side).
  Future<bool> likePost({required int postId}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      await _client.from('community_likes').insert({
        'user_id': user.id,
        'post_id': postId,
      });
      // Invalidate caches as likes changed
      invalidateAvatarsCacheForPost(postId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unlikePost({required int postId}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      await _client
          .from('community_likes')
          .delete()
          .eq('user_id', user.id)
          .eq('post_id', postId);
      invalidateAvatarsCacheForPost(postId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Toggle like for a comment
  Future<bool> likeComment({required int commentId}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      await _client.from('community_likes').insert({
        'user_id': user.id,
        'comment_id': commentId,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unlikeComment({required int commentId}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      await _client
          .from('community_likes')
          .delete()
          .eq('user_id', user.id)
          .eq('comment_id', commentId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Return a list of comment ids that the current user has liked (from the provided list)
  Future<List<int>> getUserLikedComments(List<int> commentIds) async {
    if (commentIds.isEmpty) return [];
    final user = _client.auth.currentUser;
    if (user == null) return [];
    try {
      final idsCsv = commentIds.join(',');
      final res = await _client
          .from('community_likes')
          .select('comment_id')
          .eq('user_id', user.id)
          .filter('comment_id', 'in', '($idsCsv)');
      final List data = res as List? ?? [];
      final out = <int>[];
      for (final row in data) {
        try {
          final cid = (row['comment_id'] as num).toInt();
          out.add(cid);
        } catch (_) {}
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  /// Return like counts for a list of comment ids
  Future<Map<int, int>> getCommentLikeCounts(List<int> commentIds) async {
    final out = <int, int>{};
    if (commentIds.isEmpty) return out;
    try {
      final idsCsv = commentIds.join(',');
      final res = await _client
          .from('community_likes')
          .select('comment_id')
          .filter('comment_id', 'in', '($idsCsv)');
      final List data = res as List? ?? [];
      for (final row in data) {
        try {
          final cid = (row['comment_id'] as num).toInt();
          out[cid] = (out[cid] ?? 0) + 1;
        } catch (_) {}
      }
      // ensure all requested ids exist in map
      for (final id in commentIds) {
        out[id] = out[id] ?? 0;
      }
      return out;
    } catch (_) {
      // on error return zeros
      for (final id in commentIds) out[id] = 0;
      return out;
    }
  }

  /// Fetch commenter avatars for multiple posts with limited concurrency.
  /// Returns a map postId -> list of avatar URLs.
  Future<Map<int, List<String>>> fetchCommenterAvatarsForPosts(
    List<int> postIds, {
    int limitPerPost = 3,
    int concurrency = 6,
  }) async {
    // First try server-side batch RPC for efficiency.
    try {
      final batch = await getPostCommenterAvatarsBatch(
        postIds,
        limit: limitPerPost,
      );
      if (batch.isNotEmpty) return batch;
    } catch (_) {
      // ignore and fallback
    }

    final Map<int, List<String>> out = {};
    if (postIds.isEmpty) return out;
    // Process ids in chunks of size `concurrency` to limit parallel RPC calls.
    for (var i = 0; i < postIds.length; i += concurrency) {
      final chunk = postIds.sublist(
        i,
        (i + concurrency).clamp(0, postIds.length),
      );
      final futures = <Future<List<String>>>[];
      final idsInChunk = <int>[];
      for (final id in chunk) {
        idsInChunk.add(id);
        futures.add(getPostCommenterAvatars(id, limit: limitPerPost));
      }
      try {
        final results = await Future.wait(futures);
        for (var j = 0; j < idsInChunk.length; j++) {
          out[idsInChunk[j]] = results[j];
        }
      } catch (_) {
        // ignore chunk errors and continue with next chunk
      }
    }
    return out;
  }

  // --- Comment CRUD helpers (client-side) ---
  /// Create a comment for a post and invalidate avatar cache for that post.
  Future<bool> createComment({
    required int postId,
    required String content,
    required bool isAnonymous,
    int? parentCommentId,
    List<String>? imageUrls,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      final row = <String, dynamic>{
        'post_id': postId,
        'author_id': user.id,
        'content': content,
        'is_anonymous': isAnonymous,
      };
      if (parentCommentId != null) {
        row['parent_comment_id'] = parentCommentId;
      }
      if (imageUrls != null && imageUrls.isNotEmpty) {
        // DB 컬럼이 text[] 배열이므로 배열로 저장
        row['image_url'] = imageUrls;
      }
      await _client.from('community_comments').insert(row);
      // Invalidate cache so UI shows updated avatars
      invalidateAvatarsCacheForPost(postId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Fetch recent comments for a post (non-threaded flat list, newest first)
  Future<List<Map<String, dynamic>>> fetchCommentsForPost(
    int postId, {
    int limit = 3,
  }) async {
    try {
      final res = await _client
          .from('community_comments')
          .select(
            'id, author_id, content, image_url, is_anonymous, parent_comment_id, created_at',
          )
          .eq('post_id', postId)
          .order('created_at', ascending: false)
          .limit(limit);
      final List data = res as List? ?? [];
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Delete a comment by id and invalidate cache for its post.
  Future<bool> deleteComment({
    required int commentId,
    required int postId,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      await _client
          .from('community_comments')
          .delete()
          .eq('id', commentId)
          .eq('author_id', user.id);
      invalidateAvatarsCacheForPost(postId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Delete a post owned by the current user. Returns true on success.
  Future<bool> deletePost({required int postId}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      // Only allow deleting posts by the same author (server should also enforce)
      await _client
          .from('community_posts')
          .delete()
          .eq('id', postId)
          .eq('author_id', user.id);
      // Optionally cleanup related rows (comments, likes) is handled server-side or via DB cascade.
      // Invalidate any related caches if necessary.
      invalidateAvatarsCacheForPost(postId);
      return true;
    } catch (_) {
      return false;
    }
  }

  // --- Server batch RPC wrapper ---
  /// Prefer batch RPC if available on server. Returns map postId->avatars.
  Future<Map<int, List<String>>> getPostCommenterAvatarsBatch(
    List<int> postIds, {
    int limit = 3,
  }) async {
    final out = <int, List<String>>{};
    if (postIds.isEmpty) return out;
    try {
      // Attempt server-side batch RPC which should return rows with
      // { post_id: bigint, profile_img: text }
      final res = await _client.rpc(
        'get_post_commenter_avatars_batch',
        params: {'post_ids_in': postIds, 'limit_in': limit},
      );
      final List data = res as List? ?? [];
      for (final row in data) {
        if (row is Map && row['post_id'] != null) {
          final pid = (row['post_id'] as num).toInt();
          final url = row['profile_img'] as String?;
          if (url == null || url.isEmpty) continue;
          out.putIfAbsent(pid, () => []).add(url);
        }
      }
      return out;
    } catch (_) {
      // rpc not available or failed — caller should fallback to per-post requests
      return {};
    }
  }

  // 텍스트에서 해시태그 추출: '#tag' 형태를 찾아 '#' 제거 후 반환
  List<String> _extractHashtags(String text) {
    final exp = RegExp(r'#([가-힣a-zA-Z0-9_]+)');
    final matches = exp.allMatches(text);
    return matches.map((m) => m.group(1)!).toList();
  }

  Future<void> createPost({
    required String content,
    required bool isAnonymous,
    List<String>? imageUrls,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    
    // 1. 포스트에서 해시태그 추출
    final hashtags = _extractHashtags(content);
    
    // 2. 포스트 생성
    await _client.from('community_posts').insert({
      'author_id': user.id,
      'content': content,
      'is_anonymous': isAnonymous,
      'image_urls': imageUrls ?? [],
    });
    
    // 3. 해시태그가 있으면 자동으로 해시태그 생성 및 구독 처리
    if (hashtags.isNotEmpty) {
      await _ensureHashtagsExistAndSubscribe(hashtags, user.id);
    }
  }

  /// 해시태그가 데이터베이스에 존재하는지 확인하고 없으면 생성, 그리고 자동 구독
  Future<void> _ensureHashtagsExistAndSubscribe(List<String> hashtags, String userId) async {
    try {
      for (final hashtagName in hashtags) {
        if (hashtagName.isEmpty) continue;
        
        // 1. 해시태그가 이미 존재하는지 확인
        final existing = await _client
            .from('community_hashtags')
            .select('id')
            .eq('name', hashtagName.toLowerCase())
            .maybeSingle();
            
        int hashtagId;
        
        if (existing == null) {
          // 2. 해시태그가 없으면 새로 생성
          final newHashtag = await _client
              .from('community_hashtags')
              .insert({
                'name': hashtagName.toLowerCase(),
                'post_count': 1,
                'subscriber_count': 1,
                'last_used_at': DateTime.now().toIso8601String(),
              })
              .select('id')
              .single();
          hashtagId = newHashtag['id'] as int;
        } else {
          // 3. 해시태그가 존재하면 사용 횟수 업데이트
          hashtagId = existing['id'] as int;
          await _client
              .from('community_hashtags')
              .update({
                'post_count': 'post_count + 1',
                'last_used_at': DateTime.now().toIso8601String(),
              })
              .eq('id', hashtagId);
        }
        
        // 4. 사용자를 해시태그에 자동 구독 (이미 구독되어 있으면 무시됨)
        await subscribeToChannel(hashtagId: hashtagId);
      }
    } catch (e) {
      // 해시태그 처리 실패해도 포스트 생성은 성공한 상태이므로 로그만 남김
      debugPrint('Failed to process hashtags: $e');
    }
  }

  // Subscribe current user to a hashtag channel by id
  Future<bool> subscribeToChannel({required int hashtagId}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return false;
    try {
      // Idempotent without requiring a DB unique constraint:
      // 1) Check if subscription exists
      final existing = await _client
          .from('community_subscriptions')
          .select('target_hashtag_id')
          .eq('subscriber_id', uid)
          .eq('target_hashtag_id', hashtagId)
          .maybeSingle();
      if (existing != null) {
        // Already subscribed; treat as success
        return true;
      }
      // 2) Not found → insert
      await _client.from('community_subscriptions').insert({
        'subscriber_id': uid,
        'target_hashtag_id': hashtagId,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // Unsubscribe current user from a hashtag channel by id
  Future<bool> unsubscribeFromChannel({required int hashtagId}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return false;
    try {
      await _client
          .from('community_subscriptions')
          .delete()
          .eq('subscriber_id', uid)
          .eq('target_hashtag_id', hashtagId);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Check if current user is subscribed to a hashtag id
  Future<bool> isSubscribed({required int hashtagId}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return false;
    try {
      final res = await _client
          .from('community_subscriptions')
          .select('target_hashtag_id')
          .eq('subscriber_id', uid)
          .eq('target_hashtag_id', hashtagId)
          .maybeSingle();
      return res != null;
    } catch (_) {
      return false;
    }
  }

  // Search hashtags by query (prefix or contains)
  Future<List<HashtagChannel>> searchHashtags(String q, {int limit = 8}) async {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) return [];
    try {
      final res = await _client
          .from('community_hashtags')
          .select(
            'id, name, description, category, post_count, subscriber_count, last_used_at',
          )
          .ilike('name', '%$query%')
          .order('subscriber_count', ascending: false)
          .limit(limit);
      final List data = res as List? ?? [];
      return data
          .map(
            (tag) => HashtagChannel(
              id: tag['id'] as int,
              name: (tag['name'] as String).toLowerCase(),
              description: tag['description'] as String?,
              category: tag['category'] as String?,
              postCount: tag['post_count'] as int? ?? 0,
              subscriberCount: tag['subscriber_count'] as int? ?? 0,
              lastUsedAt: tag['last_used_at'] == null
                  ? null
                  : DateTime.tryParse(tag['last_used_at'] as String),
            ),
          )
          .toList();
    } catch (_) {
      // fallback: filter mock
      return _mockChannels(limit).where((c) => c.name.contains(query)).toList();
    }
  }

  // Fetch hashtags the current user has NOT subscribed to, optionally filtered by query.
  Future<List<HashtagChannel>> fetchUnsubscribedHashtags({
    String? query,
    int limit = 24,
  }) async {
    try {
      final uid = _client.auth.currentUser?.id;
      // If unauthenticated, just return top hashtags as a discovery list
      // (no exclusion possible without uid).
      final Set<int> subscribedIds = <int>{};
      if (uid != null) {
        try {
          final sub = await _client
              .from('community_subscriptions')
              .select('target_hashtag_id')
              .eq('subscriber_id', uid);
          final List subData = sub as List? ?? [];
          for (final row in subData) {
            final hid = row['target_hashtag_id'] as int?;
            if (hid != null) subscribedIds.add(hid);
          }
        } catch (_) {
          // ignore subscription fetch errors and proceed with empty set
        }
      }

      dynamic req = _client
          .from('community_hashtags')
          .select(
            'id, name, description, category, post_count, subscriber_count, last_used_at',
          )
          .order('subscriber_count', ascending: false)
          .limit(limit * 3); // overfetch then filter client-side

      final q = query?.trim().toLowerCase() ?? '';
      if (q.isNotEmpty) {
        req = req.ilike('name', '%$q%');
      }

      final List data = await req;
      final result = <HashtagChannel>[];
      for (final tag in data) {
        final id = tag['id'] as int;
        if (subscribedIds.contains(id)) continue;
        result.add(
          HashtagChannel(
            id: id,
            name: (tag['name'] as String).toLowerCase(),
            description: tag['description'] as String?,
            category: tag['category'] as String?,
            postCount: tag['post_count'] as int? ?? 0,
            subscriberCount: tag['subscriber_count'] as int? ?? 0,
            lastUsedAt: tag['last_used_at'] == null
                ? null
                : DateTime.tryParse(tag['last_used_at'] as String),
          ),
        );
        if (result.length >= limit) break;
      }
      return result;
    } catch (_) {
      // Fallback to mock and pretend none are subscribed.
      final base = _mockChannels(limit * 2);
      final q = query?.trim().toLowerCase() ?? '';
      final filtered = q.isEmpty
          ? base
          : base.where((c) => c.name.contains(q)).toList();
      return filtered.take(limit).toList();
    }
  }

  // Fetch hashtags regardless of subscription, optionally filtered by query.
  Future<List<HashtagChannel>> fetchAllHashtags({
    String? query,
    int limit = 24,
    bool orderByPopularity = true,
  }) async {
    try {
      dynamic req = _client
          .from('community_hashtags')
          .select(
            'id, name, description, category, post_count, subscriber_count, last_used_at',
          );
      if (orderByPopularity) {
        req = req.order('subscriber_count', ascending: false);
      }
      final q = query?.trim().toLowerCase() ?? '';
      if (q.isNotEmpty) {
        req = req.ilike('name', '%$q%');
      }
      req = req.limit(limit);
      final List data = await req;
      return data.map((tag) {
        return HashtagChannel(
          id: tag['id'] as int,
          name: (tag['name'] as String).toLowerCase(),
          description: tag['description'] as String?,
          category: tag['category'] as String?,
          postCount: tag['post_count'] as int? ?? 0,
          subscriberCount: tag['subscriber_count'] as int? ?? 0,
          lastUsedAt: tag['last_used_at'] == null
              ? null
              : DateTime.tryParse(tag['last_used_at'] as String),
        );
      }).toList();
    } catch (_) {
      final base = _mockChannels(limit * 2);
      final q = query?.trim().toLowerCase() ?? '';
      final filtered = q.isEmpty
          ? base
          : base.where((c) => c.name.contains(q)).toList();
      return filtered.take(limit).toList();
    }
  }

  /// RPC wrapper for `public.get_post_commenter_avatars(post_id_in BIGINT, limit_in INT)`
  /// Returns a list of profile image URLs for recent non-anonymous commenters.
  Future<List<String>> getPostCommenterAvatars(
    int postId, {
    int limit = 3,
  }) async {
    final now = DateTime.now();
    final cached = _avatarsCache[postId];
    if (cached != null) {
      if (now.difference(cached.fetchedAt) <= avatarsCacheTtl) {
        return cached.avatars;
      } else {
        _avatarsCache.remove(postId);
      }
    }

    try {
      // First try server-side RPC which may return recent commenter avatars.
      final res = await _client.rpc(
        'get_post_commenter_avatars',
        params: {'post_id_in': postId, 'limit_in': limit},
      );
      // Expecting a list of rows like { 'profile_img': 'https://...' }
      final List data = res as List? ?? [];
      final out = <String>[];
      for (final row in data) {
        if (row is Map && row['profile_img'] != null) {
          final v = row['profile_img'] as String;
          if (v.isNotEmpty) out.add(v);
        } else if (row is String) {
          // some RPC responses can be a plain list of strings
          if (row.isNotEmpty) out.add(row);
        }
      }
      // If RPC returned enough avatars already, cache and return.
      if (out.length >= limit) {
        _avatarsCache[postId] = _AvatarsCacheEntry(out, DateTime.now());
        return out.take(limit).toList();
      }

      // RPC didn't provide enough results or isn't complete — fall back to
      // server-side table queries combining recent likers and commenters.
      // We'll fetch recent likers and recent non-anonymous commenters,
      // merge by newest activity timestamp, deduplicate, then fetch their
      // profile images from users table.
      final List<Map<String, dynamic>> interactions = [];
      try {
        // recent likers
        final likerRes = await _client
            .from('community_likes')
            .select('user_id, created_at')
            .eq('post_id', postId)
            .order('created_at', ascending: false)
            .limit(limit);
        for (final r in (likerRes as List? ?? [])) {
          try {
            interactions.add({
              'id': r['user_id'] as String?,
              'ts': r['created_at'] as String?,
            });
          } catch (_) {}
        }
      } catch (_) {}

      try {
        // recent commenters (exclude anonymous)
        final commentRes = await _client
            .from('community_comments')
            .select('author_id, created_at, is_anonymous')
            .eq('post_id', postId)
            .eq('is_anonymous', false)
            .order('created_at', ascending: false)
            .limit(limit);
        for (final r in (commentRes as List? ?? [])) {
          try {
            interactions.add({
              'id': r['author_id'] as String?,
              'ts': r['created_at'] as String?,
            });
          } catch (_) {}
        }
      } catch (_) {}

      // Parse timestamps and sort by ts desc
      interactions.removeWhere((e) => e['id'] == null);
      interactions.sort((a, b) {
        final ats = a['ts'] as String?;
        final bts = b['ts'] as String?;
        final ad =
            DateTime.tryParse(ats ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bd =
            DateTime.tryParse(bts ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });

      // Deduplicate while preserving order
      final seen = <String>{};
      final orderedIds = <String>[];
      for (final it in interactions) {
        final id = it['id'] as String;
        if (!seen.contains(id)) {
          seen.add(id);
          orderedIds.add(id);
        }
        if (orderedIds.length >= limit) break;
      }

      if (orderedIds.isNotEmpty) {
        final idsCsv = orderedIds.map((s) => '"$s"').join(',');
        final users = await _client
            .from('users')
            .select('id, profile_img')
            .filter('id', 'in', '($idsCsv)');
        final Map<String, String> byId = {};
        for (final u in (users as List? ?? [])) {
          try {
            final id = u['id'] as String?;
            final p = (u['profile_img'] as String?)?.trim();
            if (id != null && p != null && p.isNotEmpty) byId[id] = p;
          } catch (_) {}
        }
        for (final id in orderedIds) {
          final p = byId[id];
          if (p != null && p.isNotEmpty) out.add(p);
          if (out.length >= limit) break;
        }
      }
      _avatarsCache[postId] = _AvatarsCacheEntry(out, DateTime.now());
      return out;
    } catch (_) {
      return const [];
    }
  }

  /// Invalidate cached avatars for a single post (call when comments change).
  void invalidateAvatarsCacheForPost(int postId) {
    _avatarsCache.remove(postId);
  }

  /// Clear the entire avatars cache.
  void clearAvatarsCache() {
    _avatarsCache.clear();
  }

  /// Fetch subscriber counts for a list of hashtag ids in one grouped query.
  /// Returns a map of hashtagId -> count. Falls back to the subscriber_count
  /// stored on the hashtag row when the grouped query fails.
  Future<Map<int, int>> fetchSubscriberCountsForHashtags(List<int> ids) async {
    if (ids.isEmpty) return {};
    try {
      // Use a grouped select on community_subscriptions to count per target_hashtag_id
      // Fetch matching subscription rows and count client-side.
      final idsCsv = ids.join(',');
      final res = await _client
          .from('community_subscriptions')
          .select('target_hashtag_id')
          .filter('target_hashtag_id', 'in', '($idsCsv)');
      final List data = res as List? ?? [];
      final Map<int, int> out = {};
      for (final row in data) {
        final hid = row['target_hashtag_id'] as int?;
        if (hid == null) continue;
        out[hid] = (out[hid] ?? 0) + 1;
      }
      // For any ids not returned by the grouped query, try reading subscriber_count from community_hashtags
      final missing = ids.where((i) => !out.containsKey(i)).toList();
      if (missing.isNotEmpty) {
        final missingCsv = missing.join(',');
        final tags = await _client
            .from('community_hashtags')
            .select('id, subscriber_count')
            .filter('id', 'in', '($missingCsv)');
        for (final t in (tags as List? ?? [])) {
          final id = t['id'] as int?;
          final sc = t['subscriber_count'] as int? ?? 0;
          if (id != null && !out.containsKey(id)) out[id] = sc;
        }
      }
      return out;
    } catch (_) {
      // best-effort fallback: fetch stored subscriber_count from hashtag rows
      try {
        final idsCsv = ids.join(',');
        final tags = await _client
            .from('community_hashtags')
            .select('id, subscriber_count')
            .filter('id', 'in', '($idsCsv)');
        final Map<int, int> out = {};
        for (final t in (tags as List? ?? [])) {
          final id = t['id'] as int?;
          final sc = t['subscriber_count'] as int? ?? 0;
          if (id != null) out[id] = sc;
        }
        return out;
      } catch (_) {
        return {};
      }
    }
  }

  // Upload images to Supabase Storage and return public URLs
  Future<List<String>> uploadImages({
    required List<dynamic> files, // Accept XFile or File paths
    String bucket = 'community',
  }) async {
    final uid = _client.auth.currentUser?.id ?? 'anon';
    final now = DateTime.now().millisecondsSinceEpoch;
    final List<String> urls = [];
    for (int i = 0; i < files.length; i++) {
      try {
        final file = files[i];
        final String path = 'posts/$uid/${now}_$i.jpg';
        // Handle File (dart:io), XFile (image_picker), or bytes
        if (file is List<int>) {
          await _client.storage
              .from(bucket)
              .uploadBinary(
                path,
                Uint8List.fromList(file),
                fileOptions: const FileOptions(contentType: 'image/jpeg'),
              );
        } else if (file is String) {
          // When given a path string, try to read as bytes lazily
          // Avoid importing dart:io at top-level to keep web-safe; use conditional block
          // ignore: avoid_dynamic_calls
          throw UnimplementedError('Use XFile or bytes for web-safety.');
        } else {
          // Assume XFile-like object with readAsBytes
          final bytes = await file.readAsBytes();
          await _client.storage
              .from(bucket)
              .uploadBinary(
                path,
                bytes,
                fileOptions: const FileOptions(contentType: 'image/jpeg'),
              );
        }
        final publicUrl = _client.storage.from(bucket).getPublicUrl(path);
        urls.add(publicUrl);
      } catch (_) {
        // skip failed uploads
      }
    }
    return urls;
  }

  // ---- Mocks ----
  List<HashtagChannel> _mockChannels(int n) => List.generate(n, (i) {
    return HashtagChannel(
      id: i + 1,
      name: ['강남후기', '업무노하우', '자유', '밈', '채용', '스터디'][i % 6].toLowerCase(),
      postCount: 100 + i * 3,
      subscriberCount: 50 + i * 7,
      lastUsedAt: DateTime.now().subtract(Duration(hours: i * 3)),
    );
  });

  List<CommunityPost> _mockPosts({int limit = 20}) => List.generate(limit, (i) {
    final isAnon = i % 4 == 0;
    return CommunityPost(
      id: i + 1,
      content: isAnon
          ? '익명 고민: 채용 과정에서 이런 질문 받아보신 분? #강남후기 #커리어'
          : '오늘의 팁: 단축키만 잘 써도 작업 속도 2배! #업무노하우',
      isAnonymous: isAnon,
      // For mock data avoid fabricating author IDs that trigger DB queries.
      authorId: null,
      authorName: isAnon ? '익명의 스타' : '스타 ${i + 17}',
      authorAvatarUrl: null,
      imageUrls: const [],
      createdAt: DateTime.now().subtract(Duration(minutes: i * 13)),
      hashtags: ['강남후기', '업무노하우', '자유'].sublist(0, (i % 3) + 1),
      recentCommenterAvatarUrls: const [],
    );
  });

  /// Search posts by content. Returns a list of post maps (id, content).
  Future<List<Map<String, dynamic>>> searchPostsByContent(
    String q, {
    int limit = 12,
  }) async {
    if (q.trim().isEmpty) return [];
    try {
      final res = await _client
          .from('community_posts')
          .select('id, content')
          .ilike('content', '%${q.trim()}%')
          .limit(limit)
          .order('created_at', ascending: false);
      final List data = res as List? ?? [];
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  // ============== HASHTAG SERVICE METHODS ==============

  /// Get hashtag recommendations based on content using AI RPC
  Future<List<String>> getHashtagRecommendations(
    String content, {
    int maxRecommendations = 5,
  }) async {
    try {
      final response = await _client.rpc(
        'recommend_hashtags_for_content',
        params: {
          'content_text': content,
          'max_recommendations': maxRecommendations,
        },
      );
      
      final List data = response as List? ?? [];
      return data
          .map((item) => item['hashtag_name'] as String? ?? '')
          .where((tag) => tag.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Failed to get hashtag recommendations: $e');
      return [];
    }
  }

  /// Get cached trending hashtags with fallback to RPC
  Future<List<String>> getCachedTrendingHashtags({int limit = 10}) async {
    try {
      // Try to get from trending cache first
      final cacheRes = await _client
          .from('trending_hashtags_cache')
          .select('hashtags')
          .eq('cache_key', 'current_trending')
          .gt('expires_at', DateTime.now().toIso8601String())
          .limit(1);
      
      if (cacheRes.isNotEmpty) {
        final List hashtags = cacheRes[0]['hashtags'] as List? ?? [];
        return hashtags
            .map((h) => h['hashtag_name'] as String? ?? '')
            .where((tag) => tag.isNotEmpty)
            .take(limit)
            .toList();
      }
      
      // Fallback to RPC call
      final hashtags = await _client.rpc(
        'get_trending_hashtags',
        params: {
          'limit_count': limit,
          'days_back': 7,
        },
      );
      final List hashtagList = hashtags as List? ?? [];
      
      return hashtagList
          .map((h) => h['hashtag_name'] as String? ?? '')
          .where((tag) => tag.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Failed to get cached trending hashtags: $e');
      return [];
    }
  }

  /// Get personalized hashtag recommendations based on user history
  Future<List<String>> getPersonalizedHashtagRecommendations({
    int limit = 10,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      // Get user's recent hashtags from posts
      final recentPosts = await _client
          .from('community_posts')
          .select('hashtags')
          .eq('author_id', userId)
          .gte('created_at', DateTime.now().subtract(const Duration(days: 30)).toIso8601String())
          .order('created_at', ascending: false)
          .limit(20);

      // Collect all hashtags and count frequency
      final Map<String, int> tagFrequency = {};
      for (final post in (recentPosts as List? ?? [])) {
        final hashtags = (post['hashtags'] as List?)?.cast<String>() ?? [];
        for (final tag in hashtags) {
          tagFrequency[tag] = (tagFrequency[tag] ?? 0) + 1;
        }
      }

      // Get trending hashtags related to user's interests
      final trending = await getTrendingHashtags(limit: limit * 2);
      
      // Mix user history with trending, prioritize user's frequently used tags
      final recommendations = <String>[];
      final seen = <String>{};
      
      // Add user's most used tags first
      final sortedUserTags = tagFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      for (final entry in sortedUserTags.take(limit ~/ 2)) {
        if (seen.add(entry.key)) {
          recommendations.add(entry.key);
        }
      }
      
      // Fill remaining with trending hashtags
      for (final trendingItem in trending) {
        if (recommendations.length >= limit) break;
        final tag = trendingItem['name'] as String? ?? '';
        if (tag.isNotEmpty && seen.add(tag)) {
          recommendations.add(tag);
        }
      }

      return recommendations.take(limit).toList();
    } catch (e) {
      debugPrint('Failed to get personalized recommendations: $e');
      // Fallback to basic trending
      final trending = await getCachedTrendingHashtags(limit: limit);
      return trending.take(limit).toList();
    }
  }

  /// Get trending hashtags using RPC
  Future<List<Map<String, dynamic>>> getTrendingHashtags({
    int daysBack = 7,
    int minUsageCount = 2,
    int limit = 10,
  }) async {
    try {
      final response = await _client.rpc(
        'get_trending_hashtags',
        params: {
          'limit_count': limit,
          'days_back': daysBack,
        },
      );
      
      final List data = response as List? ?? [];
      return data
          .map((item) => {
                'name': item['hashtag_name'] as String,
                'usage_count': item['post_count'] as int,
                'trend_score': (item['post_count'] as num).toDouble(),
                'category': item['category'] as String? ?? 'general',
              })
          .toList();
    } catch (e) {
      debugPrint('Failed to get trending hashtags: $e');
      return [];
    }
  }

  /// Search hashtags with enhanced matching using RPC
  Future<List<Map<String, dynamic>>> searchHashtagsEnhanced(
    String searchTerm, {
    int limitCount = 10,
  }) async {
    try {
      final response = await _client.rpc(
        'search_hashtags',
        params: {
          'search_term': searchTerm,
          'limit_count': limitCount,
        },
      );

      final List data = response as List? ?? [];
      return data
          .map((item) => {
                'name': item['hashtag_name'] as String,
                'usage_count': item['usage_count'] as int,
                'last_used': item['last_used'] as String?,
                'match_type': item['match_type'] as String,
              })
          .toList();
    } catch (e) {
      debugPrint('Failed to search hashtags: $e');
      // Fallback to basic search using existing method
      final basic = await searchHashtags(searchTerm, limit: limitCount);
      return basic
          .map((channel) => {
                'name': channel.name,
                'usage_count': channel.postCount,
                'last_used': channel.lastUsedAt?.toIso8601String(),
                'match_type': 'contains',
              })
          .toList();
    }
  }

  /// Get daily hashtag curation data
  Future<Map<String, dynamic>?> getDailyCuration({
    String? date, // YYYY-MM-DD format, defaults to today
  }) async {
    try {
      final targetDate = date ?? DateTime.now().toIso8601String().split('T')[0];
      
      final response = await _client
          .from('daily_hashtag_curation')
          .select('*')
          .eq('curation_date', targetDate)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        return response.first;
      }
      
      // If no curation exists for today, return null
      return null;
    } catch (e) {
      debugPrint('Failed to get daily curation: $e');
      return null;
    }
  }

  /// Get popular hashtags based on subscriber and post counts
  Future<List<HashtagChannel>> getPopularHashtags({int limit = 10}) async {
    try {
      final res = await _client
          .from('community_hashtags')
          .select(
              'id, name, description, category, post_count, subscriber_count, last_used_at')
          .order('subscriber_count', ascending: false)
          .order('post_count', ascending: false)
          .limit(limit);
      final List data = res as List? ?? [];
      return data
          .map(
            (tag) => HashtagChannel(
              id: tag['id'] as int,
              name: (tag['name'] as String).toLowerCase(),
              description: tag['description'] as String?,
              category: tag['category'] as String?,
              postCount: tag['post_count'] as int? ?? 0,
              subscriberCount: tag['subscriber_count'] as int? ?? 0,
              lastUsedAt: tag['last_used_at'] == null
                  ? null
                  : DateTime.tryParse(tag['last_used_at'] as String),
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Failed to get popular hashtags: $e');
      return [];
    }
  }

  /// Report a community post
  Future<void> reportPost({
    required int postId,
    required String reportReason,
    String? reportDetails,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Get post details to identify reported user
      final postResponse = await _client
          .from('community_posts')
          .select('author_id, is_anonymous')
          .eq('id', postId)
          .limit(1);

      if (postResponse.isEmpty) {
        throw Exception('Post not found');
      }

      final post = postResponse.first;
      final isAnonymous = post['is_anonymous'] as bool? ?? false;
      final reportedUserId = isAnonymous ? null : post['author_id'] as String?;

      // Insert report record
      await _client.from('community_reports').insert({
        'reporter_id': user.id,
        'reported_post_id': postId,
        'reported_user_id': reportedUserId,
        'report_reason': reportReason,
        'report_details': reportDetails,
      });

      debugPrint('Post reported successfully: post_id=$postId, reason=$reportReason');
    } catch (e) {
      debugPrint('Failed to report post: $e');
      rethrow;
    }
  }

  /// Block a user manually
  Future<void> blockUser({
    required String blockedUserId,
    String reason = 'manual_block',
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    if (user.id == blockedUserId) {
      throw Exception('Cannot block yourself');
    }

    try {
      await _client.from('user_blocks').insert({
        'blocker_id': user.id,
        'blocked_user_id': blockedUserId,
        'reason': reason,
      });

      // Clear blocked users cache since the list has changed
      _clearBlockedUsersCache();
      
      debugPrint('User blocked successfully: $blockedUserId');
    } catch (e) {
      debugPrint('Failed to block user: $e');
      rethrow;
    }
  }

  /// Unblock a user
  Future<void> unblockUser({required String blockedUserId}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _client
          .from('user_blocks')
          .delete()
          .eq('blocker_id', user.id)
          .eq('blocked_user_id', blockedUserId);

      // Clear blocked users cache since the list has changed
      _clearBlockedUsersCache();
      
      debugPrint('User unblocked successfully: $blockedUserId');
    } catch (e) {
      debugPrint('Failed to unblock user: $e');
      rethrow;
    }
  }

  /// Get list of blocked users
  Future<List<String>> getBlockedUsers() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('user_blocks')
          .select('blocked_user_id')
          .eq('blocker_id', user.id);

      return (response as List)
          .map((block) => block['blocked_user_id'] as String)
          .toList();
    } catch (e) {
      debugPrint('Failed to get blocked users: $e');
      return [];
    }
  }

  /// Get blocked users with caching for performance optimization
  /// Used internally for filtering queries
  Future<List<String>> _getBlockedUsersWithCache() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    // Check cache first
    if (_blockedUsersCache != null) {
      final cacheAge = DateTime.now().difference(_blockedUsersCache!.fetchedAt);
      if (cacheAge < blockedUsersCacheTtl) {
        return _blockedUsersCache!.blockedUserIds;
      }
    }

    try {
      // Fetch fresh data
      final response = await _client
          .from('user_blocks')
          .select('blocked_user_id')
          .eq('blocker_id', user.id);

      final blockedIds = (response as List)
          .map((block) => block['blocked_user_id'] as String)
          .toList();

      // Cache the result
      _blockedUsersCache = _BlockedUsersCacheEntry(blockedIds, DateTime.now());
      
      return blockedIds;
    } catch (e) {
      debugPrint('Failed to get blocked users for filtering: $e');
      // Return empty list on error to avoid showing blocked content
      return [];
    }
  }

  /// Clear blocked users cache - call this when blocking/unblocking users
  void _clearBlockedUsersCache() {
    _blockedUsersCache = null;
  }

  /// Check if a user is blocked
  Future<bool> isUserBlocked(String userId) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    try {
      final response = await _client
          .from('user_blocks')
          .select('id')
          .eq('blocker_id', user.id)
          .eq('blocked_user_id', userId)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      debugPrint('Failed to check if user is blocked: $e');
      return false;
    }
  }

  /// Get user's report history
  Future<List<Map<String, dynamic>>> getUserReports() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('community_reports')
          .select('*, community_posts!inner(id, content)')
          .eq('reporter_id', user.id)
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Failed to get user reports: $e');
      return [];
    }
  }
}

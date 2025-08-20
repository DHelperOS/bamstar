import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data' show Uint8List;

/// Data models
class CommunityPost {
  final int id;
  final String content;
  final bool isAnonymous;
  final String authorName; // anonymized label when isAnonymous=true
  final String? authorAvatarUrl; // null for anonymous
  final List<String> imageUrls;
  final DateTime createdAt;
  final List<String> hashtags; // without '#'
  final List<String> recentCommenterAvatarUrls; // for avatar stack

  const CommunityPost({
    required this.id,
    required this.content,
    required this.isAnonymous,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.imageUrls,
    required this.createdAt,
    required this.hashtags,
    required this.recentCommenterAvatarUrls,
  });
}

class HashtagChannel {
  final int id;
  final String name; // lower-case
  final int postCount;
  final int subscriberCount;
  final DateTime? lastUsedAt;

  const HashtagChannel({
    required this.id,
    required this.name,
    required this.postCount,
    required this.subscriberCount,
    required this.lastUsedAt,
  });
}

/// Repository for community data. Minimal supabase wiring + mock fallbacks.
class CommunityRepository {
  CommunityRepository._();
  static final instance = CommunityRepository._();
  final _client = Supabase.instance.client;

  Future<List<HashtagChannel>> fetchSubscribedChannels({int limit = 12}) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return _mockChannels(limit);
      final res = await _client
          .from('community_subscriptions')
          .select(
            'target_hashtag_id, community_hashtags(id, name, post_count, subscriber_count, last_used_at)',
          )
          .eq('subscriber_id', uid)
          .limit(limit);
      final List data = res as List? ?? [];
      return data.map((row) {
        final tag = row['community_hashtags'];
        return HashtagChannel(
          id: tag['id'] as int,
          name: (tag['name'] as String).toLowerCase(),
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
  int limit = 20,
  int? offset,
  }) async {
    try {
      dynamic q = _client
          .from('community_posts')
          .select('id, content, is_anonymous, created_at, image_urls');
      if (filterTag != null && filterTag.trim().isNotEmpty) {
        final ft = filterTag.toLowerCase();
        // DB에 hashtags 컬럼이 없으므로 내용에서 태그 텍스트를 검색합니다.
        // 예: "#tag" 포함 여부로 서버측 1차 필터링
        q = q.ilike('content', '%#$ft%');
      }
      if (offset != null) {
        q = q.range(offset, offset + limit - 1);
      } else {
        q = q.limit(limit);
      }
      final List data = await q.order('created_at', ascending: false);
      return data.map((row) {
        final id = row['id'] as int;
        final content = (row['content'] as String?) ?? '';
        return CommunityPost(
          id: id,
          content: content,
          isAnonymous: row['is_anonymous'] as bool? ?? false,
          authorName: (row['is_anonymous'] as bool? ?? false)
              ? '익명의 스타'
              : '스타 ${id % 97}',
          authorAvatarUrl: (row['is_anonymous'] as bool? ?? false)
              ? null
              : 'https://picsum.photos/seed/u$id/100/100',
          imageUrls: (row['image_urls'] as List?)?.cast<String>() ?? const [],
          createdAt:
              DateTime.tryParse(row['created_at'] as String? ?? '') ??
              DateTime.now(),
          // 서버 컬럼이 없으므로 내용에서 해시태그를 파싱합니다.
          hashtags: _extractHashtags(content),
          recentCommenterAvatarUrls: List.generate(
            3,
            (i) => 'https://picsum.photos/seed/c${id}_$i/40/40',
          ),
        );
      }).toList();
    } catch (_) {
      return _mockPosts(limit: limit);
    }
  }

  // 텍스트에서 해시태그 추출: '#tag' 형태를 찾아 '#' 제거 후 반환
  List<String> _extractHashtags(String text) {
    final exp = RegExp(r'(?:^|\s)#([^\s#]+)');
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
    await _client.from('community_posts').insert({
      'author_id': user.id,
      'content': content,
      'is_anonymous': isAnonymous,
      'image_urls': imageUrls ?? [],
    });
  }

  // Subscribe current user to a hashtag channel by id
  Future<bool> subscribeToChannel({required int hashtagId}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return false;
    try {
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
          .select('id, name, post_count, subscriber_count, last_used_at')
          .ilike('name', '%$query%')
          .order('subscriber_count', ascending: false)
          .limit(limit);
      final List data = res as List? ?? [];
      return data
          .map(
            (tag) => HashtagChannel(
              id: tag['id'] as int,
              name: (tag['name'] as String).toLowerCase(),
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
      authorName: isAnon ? '익명의 스타' : '스타 ${i + 17}',
      authorAvatarUrl: isAnon ? null : 'https://picsum.photos/seed/u$i/100/100',
      imageUrls: i % 5 == 0
          ? ['https://picsum.photos/seed/p$i/800/400']
          : const [],
      createdAt: DateTime.now().subtract(Duration(minutes: i * 13)),
      hashtags: ['강남후기', '업무노하우', '자유'].sublist(0, (i % 3) + 1),
      recentCommenterAvatarUrls: List.generate(
        (i % 3) + 1,
        (j) => 'https://picsum.photos/seed/c${i}_$j/40/40',
      ),
    );
  });
}

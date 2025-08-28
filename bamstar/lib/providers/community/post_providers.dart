import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../app_providers.dart';
import '../auth/auth_providers.dart';

/// 게시물 모델
class Post {
  final String id;
  final String? title;
  final String content;
  final String authorId;
  final String? authorName;
  final String? authorAvatarUrl;
  final List<String>? images;
  final List<String>? hashtags;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final DateTime createdAt;
  
  const Post({
    required this.id,
    this.title,
    required this.content,
    required this.authorId,
    this.authorName,
    this.authorAvatarUrl,
    this.images,
    this.hashtags,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });
  
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      authorId: json['author_id'],
      authorName: json['author_name'],
      authorAvatarUrl: json['author_avatar_url'],
      images: json['images'] != null 
        ? List<String>.from(json['images']) 
        : null,
      hashtags: json['hashtags'] != null
        ? List<String>.from(json['hashtags'])
        : null,
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// 게시물 필터
enum PostFilter { all, following, trending, myPosts }

/// 게시물 필터 Provider
final postFilterProvider = StateProvider<PostFilter>((ref) => PostFilter.all);

/// 게시물 정렬
enum PostSort { recent, popular, commented }

/// 게시물 정렬 Provider
final postSortProvider = StateProvider<PostSort>((ref) => PostSort.recent);

/// 게시물 목록 Provider (페이지네이션 지원)
final postsProvider = FutureProvider<List<Post>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final filter = ref.watch(postFilterProvider);
  final sort = ref.watch(postSortProvider);
  final currentUserId = ref.watch(currentUserIdProvider);
  
  dynamic query = supabase.from('posts').select('''
    *,
    author:users!author_id(
      id,
      display_name,
      profile_img
    ),
    likes:post_likes(user_id),
    _count:comments(count)
  ''');
  
  // 필터 적용
  switch (filter) {
    case PostFilter.following:
      if (currentUserId != null) {
        // 팔로잉하는 사용자의 게시물만
        final following = await supabase
          .from('follows')
          .select('following_id')
          .eq('follower_id', currentUserId);
        final ids = following.map((f) => f['following_id']).toList();
        query = query.inFilter('author_id', ids);
      }
      break;
    case PostFilter.myPosts:
      if (currentUserId != null) {
        query = query.eq('author_id', currentUserId);
      }
      break;
    case PostFilter.trending:
      // 트렌딩은 좋아요 수로 필터링
      query = query.gte('like_count', 10);
      break;
    case PostFilter.all:
    default:
      break;
  }
  
  // 정렬 적용
  switch (sort) {
    case PostSort.popular:
      query = query.order('like_count', ascending: false);
      break;
    case PostSort.commented:
      query = query.order('comment_count', ascending: false);
      break;
    case PostSort.recent:
    default:
      query = query.order('created_at', ascending: false);
      break;
  }
  
  query = query.limit(20);
  
  final response = await query;
  
  return response.map((json) {
    // 좋아요 여부 확인
    final likes = json['likes'] as List? ?? [];
    final isLiked = currentUserId != null && 
      likes.any((like) => like['user_id'] == currentUserId);
    
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      authorId: json['author_id'],
      authorName: json['author']?['display_name'],
      authorAvatarUrl: json['author']?['profile_img'],
      images: json['images'] != null 
        ? List<String>.from(json['images']) 
        : null,
      hashtags: json['hashtags'] != null
        ? List<String>.from(json['hashtags'])
        : null,
      likeCount: json['like_count'] ?? 0,
      commentCount: json['_count'] ?? 0,
      isLiked: isLiked,
      createdAt: DateTime.parse(json['created_at']),
    );
  }).toList();
});

/// 개별 게시물 Provider (캐싱)
final postProvider = FutureProvider.family.autoDispose<Post?, String>(
  (ref, postId) async {
    final supabase = ref.watch(supabaseProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    
    try {
      final response = await supabase
        .from('posts')
        .select('''
          *,
          author:users!author_id(
            id,
            display_name,
            profile_img
          ),
          likes:post_likes(user_id)
        ''')
        .eq('id', postId)
        .single();
      
      final likes = response['likes'] as List? ?? [];
      final isLiked = currentUserId != null && 
        likes.any((like) => like['user_id'] == currentUserId);
      
      return Post(
        id: response['id'],
        title: response['title'],
        content: response['content'],
        authorId: response['author_id'],
        authorName: response['author']?['display_name'],
        authorAvatarUrl: response['author']?['profile_img'],
        images: response['images'] != null 
          ? List<String>.from(response['images']) 
          : null,
        hashtags: response['hashtags'] != null
          ? List<String>.from(response['hashtags'])
          : null,
        likeCount: response['like_count'] ?? 0,
        commentCount: response['comment_count'] ?? 0,
        isLiked: isLiked,
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      return null;
    }
  },
);

/// 실시간 게시물 스트림 Provider
final postStreamProvider = StreamProvider<List<Post>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final filter = ref.watch(postFilterProvider);
  final currentUserId = ref.watch(currentUserIdProvider);
  
  return supabase
    .from('posts')
    .stream(primaryKey: ['id'])
    .order('created_at', ascending: false)
    .limit(20)
    .map((data) {
      return data.map((json) {
        return Post(
          id: json['id'],
          title: json['title'],
          content: json['content'],
          authorId: json['author_id'],
          likeCount: json['like_count'] ?? 0,
          commentCount: json['comment_count'] ?? 0,
          createdAt: DateTime.parse(json['created_at']),
        );
      }).toList();
    });
});

/// 게시물 생성/수정 Notifier
class PostNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // 초기 상태는 void
  }
  
  Future<void> createPost({
    required String content,
    String? title,
    List<String>? images,
    List<String>? hashtags,
  }) async {
    final supabase = ref.read(supabaseProvider);
    final userId = ref.read(currentUserIdProvider);
    
    if (userId == null) throw Exception('User not authenticated');
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabase.from('posts').insert({
        'author_id': userId,
        'title': title,
        'content': content,
        'images': images,
        'hashtags': hashtags,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // 게시물 목록 새로고침
      ref.invalidate(postsProvider);
    });
  }
  
  Future<void> updatePost({
    required String postId,
    String? content,
    String? title,
    List<String>? images,
    List<String>? hashtags,
  }) async {
    final supabase = ref.read(supabaseProvider);
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (content != null) updates['content'] = content;
      if (title != null) updates['title'] = title;
      if (images != null) updates['images'] = images;
      if (hashtags != null) updates['hashtags'] = hashtags;
      
      await supabase
        .from('posts')
        .update(updates)
        .eq('id', postId);
      
      // 해당 게시물 캐시 무효화
      ref.invalidate(postProvider(postId));
      ref.invalidate(postsProvider);
    });
  }
  
  Future<void> deletePost(String postId) async {
    final supabase = ref.read(supabaseProvider);
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabase
        .from('posts')
        .delete()
        .eq('id', postId);
      
      ref.invalidate(postsProvider);
    });
  }
  
  Future<void> toggleLike(String postId) async {
    final supabase = ref.read(supabaseProvider);
    final userId = ref.read(currentUserIdProvider);
    
    if (userId == null) return;
    
    state = await AsyncValue.guard(() async {
      // 좋아요 상태 확인
      final existing = await supabase
        .from('post_likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();
      
      if (existing != null) {
        // 좋아요 취소
        await supabase
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
      } else {
        // 좋아요 추가
        await supabase
          .from('post_likes')
          .insert({
            'post_id': postId,
            'user_id': userId,
            'created_at': DateTime.now().toIso8601String(),
          });
      }
      
      // 게시물 새로고침
      ref.invalidate(postProvider(postId));
      ref.invalidate(postsProvider);
    });
  }
}

/// 게시물 작업 Provider
final postNotifierProvider = AsyncNotifierProvider<PostNotifier, void>(
  PostNotifier.new,
);
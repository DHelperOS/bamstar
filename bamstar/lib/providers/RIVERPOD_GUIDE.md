# 🎯 BamStar Riverpod Architecture Guide

## 📋 Provider 구조

```
lib/providers/
├── app_providers.dart          # 앱 전역 상태
├── auth/
│   └── auth_providers.dart     # 인증 관련 (AsyncNotifier 패턴)
├── user/
│   └── user_providers.dart     # 사용자 프로필 상태
├── community/
│   ├── post_providers.dart     # 게시물 관련
│   ├── comment_providers.dart  # 댓글 관련
│   └── hashtag_providers.dart  # 해시태그 관련
├── chat/
│   └── chat_providers.dart     # 채팅 실시간 상태
└── ui/
    └── ui_providers.dart       # UI 상태 (네비게이션, 토글 등)
```

## 🔧 Provider Types & 사용 가이드

### 1. **AsyncNotifierProvider** (복잡한 비동기 상태)
```dart
// 인증, API 호출, 데이터베이스 작업
class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // 초기 상태 로드
    return await loadAuthState();
  }
  
  Future<void> signIn(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => authApi.signIn(email));
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
```

### 2. **StreamProvider** (실시간 데이터)
```dart
// Supabase 실시간 구독
final chatStreamProvider = StreamProvider.autoDispose<List<Message>>((ref) {
  final userId = ref.watch(authProvider).value?.userId;
  if (userId == null) return Stream.value([]);
  
  return supabase
    .from('messages')
    .stream(primaryKey: ['id'])
    .eq('room_id', roomId)
    .order('created_at');
});
```

### 3. **FutureProvider.family** (파라미터 기반 데이터)
```dart
// 게시물별 독립 캐싱
final postProvider = FutureProvider.family.autoDispose<Post, String>(
  (ref, postId) async {
    final response = await supabase
      .from('posts')
      .select()
      .eq('id', postId)
      .single();
    return Post.fromJson(response);
  },
);
```

### 4. **StateProvider** (단순 상태)
```dart
// UI 토글, 인덱스, 필터
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
final filterProvider = StateProvider<PostFilter>((ref) => PostFilter.none);
```

### 5. **Provider** (계산된 값)
```dart
// 다른 provider들을 조합
final filteredPostsProvider = Provider<List<Post>>((ref) {
  final posts = ref.watch(postsProvider).value ?? [];
  final filter = ref.watch(filterProvider);
  
  return posts.where((post) => filter.matches(post)).toList();
});
```

## 📱 Widget 패턴

### ConsumerWidget (Stateless)
```dart
class PostList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);
    
    return posts.when(
      data: (data) => ListView.builder(...),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => ErrorWidget(err),
    );
  }
}
```

### ConsumerStatefulWidget (Stateful)
```dart
class ChatScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    // Provider 초기화는 build에서!
  }
  
  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatStreamProvider);
    // ...
  }
}
```

## 🚀 Best Practices

### ✅ DO
```dart
// 1. autoDispose 사용으로 메모리 관리
final tempProvider = Provider.autoDispose<String>((ref) => 'temp');

// 2. select로 필요한 부분만 구독
final userName = ref.watch(userProvider.select((user) => user.name));

// 3. AsyncValue.guard로 에러 처리
state = await AsyncValue.guard(() => dangerousOperation());

// 4. family로 파라미터 기반 캐싱
final itemProvider = Provider.family<Item, String>((ref, id) => ...);
```

### ❌ DON'T
```dart
// 1. initState에서 Provider 초기화 금지
@override
void initState() {
  ref.read(provider).init(); // ❌ 잘못됨
}

// 2. build 메서드에서 ref.read 사용 금지
Widget build(context, ref) {
  final value = ref.read(provider); // ❌ watch 사용
}

// 3. Provider를 클래스 멤버로 선언 금지
class MyClass {
  final provider = Provider(...); // ❌ 메모리 누수
}
```

## 🔄 마이그레이션 체크리스트

### Phase 1: Core (Week 1)
- [x] Provider 폴더 구조 생성
- [ ] Auth를 AsyncNotifier로 마이그레이션
- [ ] User Service를 Provider로 변환
- [ ] 전역 상태 Provider 구성

### Phase 2: UI (Week 2)
- [ ] StatefulWidget → ConsumerStatefulWidget
- [ ] setState() → ref.watch/read
- [ ] Navigation 상태를 Provider로
- [ ] Bottom Navigation Provider 구현

### Phase 3: 실시간 기능 (Week 3)
- [ ] Supabase Stream → StreamProvider
- [ ] 채팅 실시간 구현
- [ ] 게시물 실시간 업데이트
- [ ] 알림 시스템 Provider

### Phase 4: 정리 (Week 4)
- [ ] Bloc 코드 제거
- [ ] 불필요한 의존성 정리
- [ ] Provider 테스트 작성
- [ ] 문서화 완성

## 🧪 테스트 패턴

```dart
void main() {
  test('auth state changes', () async {
    final container = ProviderContainer(
      overrides: [
        supabaseProvider.overrideWithValue(mockSupabase),
      ],
    );
    
    final auth = container.read(authProvider.notifier);
    await auth.signIn('test@example.com');
    
    expect(container.read(authProvider).value?.isAuthenticated, true);
  });
}
```

## 📚 참고 자료

- [Riverpod 공식 문서](https://riverpod.dev)
- [Migration Guide](https://riverpod.dev/docs/migration)
- [Best Practices](https://riverpod.dev/docs/essentials/do_dont)
# 신고 시스템 사용 가이드

## 개요
BamStar 앱에서 구현된 완전한 신고 시스템 사용법을 설명합니다.

## 구현 완료 사항 ✅

### 1. 데이터베이스 테이블
- `community_reports` : 신고 내역 저장
- `user_blocks` : 차단 관리 
- 자동 차단 트리거 : 신고 시 자동으로 신고대상 차단

### 2. Flutter 컴포넌트
- `PostActionsMenu` : 업데이트된 메뉴 (신고/차단 기능 통합)
- `ReportDialog` : 7가지 신고 사유 선택 다이얼로그
- `CommunityRepository` : 신고/차단 API 메서드들

### 3. 주요 기능
- **신고 처리** : 게시물 신고 + 자동 차단
- **수동 차단** : 직접 사용자 차단/차단해제
- **토스트 알림** : 성공/실패 결과 표시
- **RLS 보안** : 사용자별 데이터 접근 제한

## 사용법

### 기본 사용 (게시물에서)

```dart
import 'package:bamstar/scenes/community/widgets/post_actions_menu.dart';
import 'package:bamstar/scenes/community/widgets/report_dialog.dart';

// 게시물 위젯에서 사용
Widget _buildPostActions(CommunityPost post) {
  return PostActionsMenu(
    postId: post.id,
    reportedUserId: post.isAnonymous ? null : post.authorId,
    
    // 신고 완료 후 콜백 (선택사항)
    onReport: (ReportReason reason) {
      print('게시물 ${post.id} 신고됨: ${reason.displayName}');
      // 필요시 UI 업데이트 로직
    },
    
    // 차단 완료 후 콜백 (선택사항) 
    onBlock: () {
      print('사용자 ${post.authorId} 차단됨');
      // 필요시 UI 업데이트 (게시물 숨기기 등)
    },
    
    // 삭제 기능 (작성자에게만)
    onDelete: post.isAuthor ? () {
      _deletePost(post.id);
    } : null,
    showDelete: post.isAuthor,
  );
}
```

### 신고 사유 종류

```dart
enum ReportReason {
  inappropriate('부적절한 내용 (음란, 폭력, 혐오 표현 등)'),
  spam('스팸 또는 광고성 게시물'),
  harassment('욕설/비방/개인 공격 (명예훼손)'),
  illegal('불법 정보 (불법 도박, 마약 판매 등)'),
  privacy('개인 정보 침해 (타인의 개인 정보 유출)'),
  misinformation('허위 사실 유포 또는 가짜 뉴스'),
  other('기타');
}
```

### CommunityRepository API 메서드들

```dart
final repository = CommunityRepository.instance;

// 게시물 신고
await repository.reportPost(
  postId: 123,
  reportReason: 'inappropriate', // ReportReason.inappropriate.name
  reportDetails: '추가 상세 설명 (선택사항)',
);

// 사용자 차단
await repository.blockUser(
  blockedUserId: 'user-uuid',
  reason: 'manual_block',
);

// 사용자 차단 해제
await repository.unblockUser(
  blockedUserId: 'user-uuid',
);

// 차단된 사용자 목록 조회
final blockedUsers = await repository.getBlockedUsers();

// 사용자 차단 여부 확인
final isBlocked = await repository.isUserBlocked('user-uuid');

// 내 신고 내역 조회
final myReports = await repository.getUserReports();
```

### 프로덕션 사용 시 고려사항

#### 1. 에러 처리
```dart
PostActionsMenu(
  postId: post.id,
  reportedUserId: post.authorId,
  onReport: (reason) async {
    try {
      // 신고 처리 로직이 PostActionsMenu에서 자동 실행됨
      // 성공 시 자동으로 토스트 표시됨
      
      // 추가 로직 (예: UI 업데이트)
      setState(() {
        // 게시물을 숨기거나 상태 업데이트
      });
      
    } catch (e) {
      // 에러는 PostActionsMenu에서 ReportDialog로 전파되어
      // Dialog에서 로딩 상태 해제됨
      print('신고 처리 중 추가 오류: $e');
    }
  },
);
```

#### 2. 권한 관리
- 신고자 본인만 자신의 신고 내역 조회 가능
- 차단자 본인만 자신의 차단 목록 관리 가능
- RLS 정책으로 자동 보안 적용됨

#### 3. UI/UX 최적화
- 익명 게시물: `reportedUserId`를 null로 설정 (차단 불가)
- 자신의 게시물: 신고 메뉴 숨기기 권장
- 삭제 권한: 작성자에게만 `showDelete: true`

### 예제: CommunityHomePage에서 사용

```dart
// community_home_page.dart에서
Widget _buildPost(CommunityPost post) {
  return Card(
    child: Column(
      children: [
        // 게시물 내용
        _buildPostContent(post),
        
        // 액션 메뉴
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 자신의 게시물이 아닐 때만 신고/차단 메뉴 표시
            if (post.authorId != currentUserId)
              PostActionsMenu(
                postId: post.id,
                reportedUserId: post.isAnonymous ? null : post.authorId,
                onReport: (reason) {
                  // 신고 후 해당 게시물 숨기기
                  _hideReportedPost(post.id);
                },
                onBlock: () {
                  // 차단 후 해당 사용자의 모든 게시물 숨기기
                  _hideBlockedUserPosts(post.authorId!);
                },
              ),
            
            // 자신의 게시물일 때는 삭제 메뉴만
            if (post.authorId == currentUserId)
              PostActionsMenu(
                postId: post.id,
                reportedUserId: null,
                onDelete: () => _deletePost(post.id),
                showDelete: true,
              ),
          ],
        ),
      ],
    ),
  );
}

void _hideReportedPost(int postId) {
  setState(() {
    posts.removeWhere((post) => post.id == postId);
  });
}

void _hideBlockedUserPosts(String blockedUserId) {
  setState(() {
    posts.removeWhere((post) => post.authorId == blockedUserId);
  });
}
```

## 데이터 흐름

1. **사용자가 MenuDots 터치** → PostActionsMenu 팝업 표시
2. **'신고하기' 선택** → ReportDialog 표시  
3. **신고 사유 선택 후 '신고하기' 터치** → 데이터베이스 처리:
   - `community_reports` 테이블에 신고 기록 추가
   - 트리거 함수에 의해 `user_blocks` 테이블에 자동 차단 추가
4. **성공 토스트 표시** → 사용자 피드백
5. **onReport 콜백 실행** → 앱 UI 업데이트 (선택사항)

## 트러블슈팅

### "테이블이 존재하지 않음" 오류
- `DATABASE_SETUP_GUIDE.md` 참고하여 테이블 생성 확인

### "권한 없음" 오류  
- 사용자 인증 상태 확인: `Supabase.instance.client.auth.currentUser`

### 토스트가 표시되지 않음
- `appNavigatorKey`가 MaterialApp에 올바르게 설정되어 있는지 확인

### 자동 차단이 작동하지 않음
- 트리거 함수가 데이터베이스에 올바르게 생성되었는지 확인
- 익명 게시물(`reportedUserId`가 null)인 경우는 차단되지 않음

---

## 완성된 신고 시스템 🎉

✅ **데이터베이스 테이블**: community_reports, user_blocks  
✅ **Flutter 컴포넌트**: PostActionsMenu, ReportDialog 통합  
✅ **API 메서드**: CommunityRepository 확장  
✅ **자동 차단**: 신고 시 트리거로 자동 처리  
✅ **사용자 피드백**: delightful_toast로 결과 알림  
✅ **보안**: RLS 정책으로 데이터 접근 제한  

바로 프로덕션에서 사용할 수 있는 완전한 신고 시스템입니다!
# PostActionsMenu Widget with ReportDialog

`SolarIconsOutline.menuDots`를 누르면 나타나는 작은 툴팁 스타일의 팝업 메뉴입니다.
'신고하기' 메뉴를 선택하면 상세한 신고 사유를 선택할 수 있는 다이얼로그가 표시됩니다.

## Features

### PostActionsMenu
- **메뉴 항목**: '신고하기', '차단하기', '삭제하기' 순서
- **스타일**: 작은 tooltip 같은 팝업 디자인
- **애니메이션**: 부드러운 fade-in/out 효과
- **접근성**: 시맨틱 라벨 및 키보드 접근성 지원

### ReportDialog
- **신고 사유**: 7가지 체계적인 신고 카테고리
- **UI**: 라디오 버튼을 통한 단일 선택
- **검증**: 선택하지 않으면 신고 버튼 비활성화
- **로딩**: 신고 처리 중 로딩 상태 표시

## Usage

```dart
import 'package:bamstar/scenes/community/widgets/post_actions_menu.dart';
import 'package:bamstar/scenes/community/widgets/report_dialog.dart';

// 기본 사용 예시
PostActionsMenu(
  child: IconButton(
    icon: Icon(SolarIconsOutline.menuDots),
    onPressed: () {}, // PostActionsMenu가 자동으로 처리
  ),
  onReport: (ReportReason reason) async {
    // 신고 처리 로직
    print('신고 사유: ${reason.displayName}');
    
    try {
      // API 호출 예시
      await reportPost(postId: postId, reason: reason);
      
      // 성공 토스트 표시
      showGlobalToast(
        context: context, 
        message: '신고가 접수되었습니다.',
      );
    } catch (e) {
      // 에러 토스트 표시
      showGlobalToast(
        context: context, 
        message: '신고 접수 중 오류가 발생했습니다.',
      );
      rethrow; // ReportDialog에서 로딩 해제를 위해 다시 throw
    }
  },
  onBlock: () {
    print('차단하기');
  },
  onDelete: () {
    print('삭제하기'); 
  },
  showDelete: isAuthor, // 작성자에게만 삭제 버튼 표시
)
```

## Properties

### PostActionsMenu
- `child` (Widget): 메뉴를 트리거할 위젯 (보통 menuDots 아이콘 버튼)
- `onReport` (Function(ReportReason)): 신고하기 완료시 호출되는 콜백 (ReportDialog 통합)
- `onBlock` (VoidCallback): 차단하기 메뉴 선택시 호출되는 콜백
- `onDelete` (VoidCallback): 삭제하기 메뉴 선택시 호출되는 콜백
- `showDelete` (bool): 삭제하기 메뉴 표시 여부 (기본값: false)

### ReportReason Enum
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

## Dialog Flow

1. **메뉴 열기**: menuDots 아이콘 터치
2. **신고 선택**: '신고하기' 메뉴 항목 터치
3. **사유 선택**: ReportDialog에서 7가지 사유 중 선택
4. **신고 처리**: '신고하기' 버튼 터치 → API 호출
5. **결과 표시**: 성공/실패에 따른 토스트 표시

## Implementation Details

### Icons Used
- **신고하기**: `SolarIconsOutline.flag`
- **차단하기**: `SolarIconsOutline.dangerCircle`
- **삭제하기**: `SolarIconsOutline.trashBinMinimalistic`

### Color System
- **일반 메뉴**: onSurface 색상 사용
- **삭제 메뉴**: error 색상 사용 (destructive action)
- **Dialog**: Material 3 surface 색상 시스템

### Error Handling
- **네트워크 오류**: onReport 콜백에서 rethrow 시 Dialog 로딩 해제
- **사용자 피드백**: delightful_toast로 결과 메시지 표시
- **Validation**: 신고 사유 미선택 시 버튼 비활성화

## Integration Examples

### Community Post Widget
```dart
// 게시물 위젯에서 사용
Widget _buildPostActions(CommunityPost post) {
  return PostActionsMenu(
    onReport: (reason) => _reportPost(post.id, reason),
    onBlock: () => _blockUser(post.authorId),
    onDelete: post.isAuthor ? () => _deletePost(post.id) : null,
    showDelete: post.isAuthor,
  );
}

Future<void> _reportPost(String postId, ReportReason reason) async {
  try {
    await communityRepository.reportPost(
      postId: postId, 
      reason: reason.name,
    );
    showGlobalToast(context: context, message: '신고가 접수되었습니다.');
  } catch (e) {
    showGlobalToast(context: context, message: '신고 접수 중 오류가 발생했습니다.');
    rethrow;
  }
}
```

## Compilation Status

✅ **PostActionsMenu**: 컴파일 완료, 모든 분석 통과  
⚠️ **ReportDialog**: 컴파일 완료, deprecated warning 2개 (기능에는 영향 없음)
- RadioListTile의 groupValue, onChanged 속성이 deprecated
- 향후 RadioGroup으로 마이그레이션 권장

## Files Created

- `bamstar/lib/scenes/community/widgets/report_dialog.dart` - 신고 사유 선택 다이얼로그
- `bamstar/lib/scenes/community/widgets/post_actions_menu.dart` - 업데이트된 메뉴 (ReportDialog 통합)
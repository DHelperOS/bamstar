# Matching Conditions API Documentation

## 개요

BamStar 프로젝트의 매칭 조건 업데이트를 위한 Edge Function API입니다. 멤버(스타)가 프로필 설정을 저장할 때 호출되며, 안전하고 효율적인 서버리스 함수로 구현되었습니다.

## 🚀 API 엔드포인트

### Update Matching Conditions

**엔드포인트**: `POST /functions/v1/update-matching-conditions`  
**전체 URL**: `https://tflvicpgyycvhttctcek.supabase.co/functions/v1/update-matching-conditions`

멤버의 매칭 조건을 업데이트하고 matching_conditions JSON 객체를 자동으로 생성합니다.

## 🔐 인증

모든 요청에는 Bearer 토큰 인증이 필요합니다:

```
Authorization: Bearer [Supabase_JWT_Token]
```

- **권한**: `GUEST`, `STAR`, `PLACE` 역할의 사용자만 접근 가능
- **인증 실패**: 401 Unauthorized 반환
- **권한 없음**: 403 Forbidden 반환

## 📝 요청 (Request)

### Headers

```http
Content-Type: application/json
Authorization: Bearer [JWT_TOKEN]
```

### Request Body

모든 필드는 **선택사항(Optional)**입니다. 변경된 필드만 전송하세요.

```json
{
  "bio": "string",                              // 자기소개
  "desired_pay_type": "string",                 // 급여 형태 (TC, DAILY, MONTHLY, NEGOTIABLE)
  "desired_pay_amount": 500000,                 // 희망 급여 (정수)
  "desired_working_days": ["월", "화", "수"],    // 희망 근무일
  "experience_level": "string",                 // 경험 수준 (NEWBIE, JUNIOR, SENIOR, EXPERT)
  "selected_style_attribute_ids": [1, 2, 3],   // 스타일 속성 ID 배열
  "selected_preference_attribute_ids": [4, 5],  // 선호도 속성 ID 배열
  "selected_area_group_ids": [6, 7]            // 지역 그룹 ID 배열
}
```

### 필드 설명

| 필드 | 타입 | 설명 | 예시 값 |
|------|------|------|---------|
| `bio` | string | 자기소개 텍스트 | "안녕하세요, 열정적인 개발자입니다" |
| `desired_pay_type` | string | 급여 형태 (TC, DAILY, MONTHLY, NEGOTIABLE) | "TC" |
| `desired_pay_amount` | integer | 희망 급여 금액 | 500000 |
| `desired_working_days` | array | 희망 근무 요일 | ["월", "화", "수", "목", "금"] |
| `experience_level` | string | 경험 수준 (NEWBIE, JUNIOR, SENIOR, EXPERT) | "JUNIOR" |
| `selected_style_attribute_ids` | array | 개인 스타일 속성 ID 목록 | [1, 2, 3] |
| `selected_preference_attribute_ids` | array | 업종/직무/복지 선호도 ID 목록 | [4, 5, 6, 7, 8] |
| `selected_area_group_ids` | array | 희망 지역 그룹 ID 목록 | [9, 10] |

## 📤 응답 (Response)

### 성공 응답 (HTTP 200)

```json
{
  "success": true,
  "message": "매칭 조건이 성공적으로 업데이트되었습니다."
}
```

### 오류 응답

#### 401 Unauthorized - 인증 실패
```json
{
  "success": false,
  "error": "인증 토큰이 필요합니다."
}
```

#### 403 Forbidden - 권한 없음
```json
{
  "success": false,
  "error": "멤버 권한이 필요합니다."
}
```

#### 500 Internal Server Error - 서버 오류
```json
{
  "success": false,
  "error": "데이터 업데이트 중 오류가 발생했습니다."
}
```

## 🔄 내부 처리 로직

### 1단계: 인증 및 권한 확인
- JWT 토큰 검증
- 사용자 역할이 'GUEST', 'STAR', 'PLACE' 중 하나인지 확인

### 2단계: 데이터베이스 업데이트 (트랜잭션)
- `member_profiles` 테이블 업데이트
- `member_attributes_link` 테이블 재구성
- `member_preferences_link` 테이블 재구성  
- `member_preferred_area_groups` 테이블 재구성

### 3단계: Matching Conditions JSON 생성
4가지 카테고리로 분류된 JSON 객체 자동 생성:

```json
{
  "MUST_HAVE": [
    "페이: TC 500,000원",
    "근무일: 월, 화, 수, 목, 금",
    "경력: 주니어",
    "게임 개발",
    "모바일 앱 개발"
  ],
  "ENVIRONMENT": {
    "workplace_features": [
      "자유로운 분위기",
      "최신 장비",
      "야식 제공"
    ],
    "location_preferences": [
      "서울 강남구",
      "서울 서초구"
    ]
  },
  "PEOPLE": {
    "team_dynamics": [
      "소통을 중시하는",
      "창의적인"
    ],
    "communication_style": [
      "적극적인",
      "친근한"
    ]
  },
  "AVOID": [
    "야근이 잦은",
    "수직적 문화"
  ]
}
```

### 4단계: 최종 저장
- 생성된 matching_conditions JSON을 member_profiles 테이블에 저장
- 트랜잭션 커밋

## 💻 Flutter 사용 예시

### Service 클래스
```dart
import '../services/matching_conditions_service.dart';

// API 호출
final response = await MatchingConditionsService.instance.updateMatchingConditions(
  desiredPayType: 'TC',
  desiredPayAmount: 500000,
  desiredWorkingDays: ['월', '화', '수', '목', '금'],
  selectedStyleAttributeIds: [1, 2, 3],
  selectedPreferenceAttributeIds: [4, 5, 6, 7, 8],
  selectedAreaGroupIds: [9, 10],
);

if (response.success) {
  print('저장 성공: ${response.message}');
} else {
  print('저장 실패: ${response.error}');
}
```

### Error Handling
```dart
try {
  final response = await MatchingConditionsService.instance.updateMatchingConditions(
    // ... parameters
  );
  
  if (response.success) {
    // 성공 처리
    showSuccessMessage(response.message ?? '저장되었습니다.');
  } else {
    // API 레벨 오류 처리
    showErrorMessage(response.error ?? '알 수 없는 오류가 발생했습니다.');
  }
} catch (e) {
  // 네트워크 오류 등 예외 처리
  showErrorMessage('네트워크 오류: $e');
}
```

## 🗄️ 데이터베이스 스키마

### 주요 테이블

#### member_profiles
```sql
- user_id (UUID, Primary Key)
- bio (TEXT)
- desired_pay_type (TEXT)
- desired_pay_amount (INTEGER)
- desired_working_days (TEXT[])
- experience_level (TEXT)
- matching_conditions (JSONB) -- 자동 생성되는 매칭 조건
```

#### member_attributes_link
```sql
- member_user_id (UUID)
- attribute_id (INTEGER)
```

#### member_preferences_link
```sql
- member_user_id (UUID) 
- attribute_id (INTEGER)
```

#### member_preferred_area_groups
```sql
- member_user_id (UUID)
- area_group_id (INTEGER)
```

## 🔧 배포 및 테스트

### Edge Function 배포
```bash
# Supabase CLI 사용
supabase functions deploy update-matching-conditions --project-ref tflvicpgyycvhttctcek
```

### SQL Function 배포
```sql
-- SQL Editor에서 실행
-- sql/update_member_profile_and_conditions.sql 파일 내용
```

### 테스트 방법
1. Flutter 앱에서 매칭 설정 페이지 접속
2. 원하는 조건 설정 후 저장 버튼 클릭
3. 네트워크 탭에서 API 호출 확인
4. Supabase Dashboard에서 데이터베이스 변경사항 확인

## 📊 모니터링

### Logs 확인
```bash
# Supabase Function 로그 확인
supabase functions logs update-matching-conditions --project-ref tflvicpgyycvhttctcek
```

### 주요 메트릭스
- API 호출 성공률
- 평균 응답 시간
- 오류 발생 빈도
- 데이터베이스 트랜잭션 성공률

## 🚨 주의사항

1. **트랜잭션 안전성**: 모든 데이터베이스 작업은 트랜잭션 내에서 수행됩니다
2. **성능**: 대량의 속성 업데이트 시 성능 영향 고려 필요
3. **보안**: JWT 토큰 만료 및 권한 검증 철저히 수행
4. **에러 처리**: 클라이언트에서 적절한 오류 메시지 표시 필요

## 🔗 관련 문서

- [Supabase Edge Functions 가이드](https://supabase.com/docs/guides/functions)
- [BamStar 데이터베이스 스키마](./SUPABASE_DATABASE_REFERENCE_COMPLETE.md)
- [Flutter HTTP 서비스 가이드](./lib/services/)

---

**마지막 업데이트**: 2025-01-27  
**API 버전**: v1.0  
**상태**: 운영 준비 완료 ✅
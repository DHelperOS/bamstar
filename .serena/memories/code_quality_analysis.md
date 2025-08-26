# Code Quality & Convention Analysis

## 코드 품질 현황 (Current Code Quality)

### Flutter Analyze 결과
- **총 이슈**: 77개 (info 레벨)
- **경고**: 4개 (warning 레벨)
- **치명적 오류**: 없음

### 주요 이슈 패턴 (Issue Patterns)

#### 1. 스타일 & 컨벤션 이슈 (Style Issues)
- **deprecated_member_use**: `withOpacity()` → `withValues()` 사용 권장
- **use_super_parameters**: 생성자 파라미터 최적화
- **annotate_overrides**: 오버라이드 메서드에 `@override` 누락
- **unnecessary_brace_in_string_interps**: 문자열 보간 괄호 최적화
- **no_leading_underscores_for_local_identifiers**: 로컬 변수명 컨벤션

#### 2. 코드 구조 이슈 (Structure Issues)
- **curly_braces_in_flow_control_structures**: if문 블록 괄호 누락
- **prefer_final_fields**: final 필드 사용 권장
- **unused_field/unused_element**: 사용하지 않는 필드/메서드

#### 3. 비동기 처리 이슈 (Async Issues)
- **use_build_context_synchronously**: BuildContext 비동기 사용 경고

## 코드 컨벤션 (Code Conventions)

### 1. 네이밍 컨벤션 (Naming Conventions)
- **클래스**: PascalCase (예: `MyApp`, `CommunityHomePage`)
- **변수/메서드**: camelCase (예: `supabaseInitOk`, `initRouter`)
- **파일명**: snake_case (예: `community_home_page.dart`)
- **상수**: UPPER_SNAKE_CASE

### 2. 아키텍처 패턴 (Architecture Patterns)
- **상태 관리**: Riverpod + BlocProvider 혼합 사용
- **라우팅**: GoRouter 기반
- **폴더 구조**: 기능별 분리 (scenes/, services/, widgets/, theme/)

### 3. 테마 & 디자인 시스템 (Theme System)
- **Material 3**: `useMaterial3: true`
- **폰트**: Pretendard (한국어 최적화)
- **아이콘**: `solar_icons` (프로젝트 표준)
- **색상**: 중앙화된 ColorScheme

### 4. 주석 & 문서화 (Comments & Documentation)
- **AI 가이드라인**: pubspec.yaml 상단에 명시
- **상태 관리 정책**: main.dart 상단 주석
- **타입 힌트**: 대부분 적용됨
- **문서화**: 부분적 (개선 필요)

## 보안 & 모범 사례 (Security & Best Practices)

### 1. 환경 변수 관리
- `.env` 파일 사용 (Supabase, Cloudinary 키)
- 초기화 실패 시 에러 UI 표시
- 민감한 정보 하드코딩 방지

### 2. 인증 보안
- 소셜 로그인만 지원 (Google, Apple, Kakao)
- Supabase RLS (Row Level Security) 활용
- 세션 관리 적절

### 3. 이미지 보안
- Cloudinary 서명 기반 업로드
- ML Kit 이미지 라벨링 (콘텐츠 검증)
- 한국어 비속어 필터링

## 개선 권장사항 (Improvement Recommendations)

### 우선순위 높음 (High Priority)
1. **deprecated API 교체**: `withOpacity()` → `withValues()`
2. **비동기 BuildContext 사용 수정**
3. **테스트 수정**: 라우터 초기화 문제 해결

### 우선순위 중간 (Medium Priority)
1. **@override 어노테이션 추가**
2. **사용하지 않는 코드 정리**
3. **if문 블록 괄호 추가**

### 우선순위 낮음 (Low Priority)
1. **변수명 컨벤션 통일**
2. **코드 문서화 개선**
3. **패키지 버전 업데이트**
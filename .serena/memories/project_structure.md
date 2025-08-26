# Project Structure Analysis

## 디렉토리 구조 (Directory Structure)

### 메인 프로젝트 (Main Project)
```
bamstar/                          # Flutter 앱 메인 디렉토리
├── lib/                          # Dart 소스 코드
│   ├── main.dart                 # 앱 진입점
│   ├── scenes/                   # 화면/페이지 (UI Layer)
│   │   ├── onboarding_page.dart
│   │   ├── login_page.dart
│   │   ├── community/            # 커뮤니티 기능
│   │   └── ...
│   ├── services/                 # 비즈니스 로직 & API
│   │   ├── community/
│   │   ├── cloudinary.dart
│   │   ├── analytics.dart
│   │   └── ...
│   ├── widgets/                  # 재사용 가능한 UI 컴포넌트
│   ├── theme/                    # 디자인 시스템
│   │   ├── app_theme.dart
│   │   └── typography.dart
│   ├── auth/                     # 인증 관련
│   ├── bloc/                     # BLoC 상태 관리
│   └── utils/                    # 유틸리티 함수
├── assets/                       # 정적 리소스
│   ├── images/                   # 이미지 파일
│   └── font/                     # 폰트 파일
├── android/                      # Android 빌드 설정
├── ios/                          # iOS 빌드 설정
├── web/                          # 웹 빌드 설정
├── test/                         # 테스트 파일
└── pubspec.yaml                  # 패키지 의존성
```

### 개발 지원 디렉토리 (Development Support)
```
dev/                              # 개발 도구 & 문서
├── docs/                         # 문서
│   ├── AI_USAGE_GUIDELINES.md    # AI 사용 가이드라인
│   ├── DB_REFERENCE.md           # 데이터베이스 레퍼런스
│   └── functions.sql             # 데이터베이스 함수
├── supabase/                     # Supabase 로컬 개발
│   ├── functions/                # Edge Functions
│   ├── migrations/               # 데이터베이스 마이그레이션
│   └── scripts/                  # 설치 스크립트
├── templates/                    # UI 템플릿 참조
│   └── ai-reference/             # AI 참조용 템플릿
└── archived_ui/                  # 보관된 UI 컴포넌트
```

### MCP 서버 (MCP Server)
```
mcp/
└── supabase-mcp/                 # Supabase MCP 서버
    ├── index.js                  # MCP 서버 구현
    └── package.json              # Node.js 의존성
```

## 아키텍처 패턴 (Architecture Patterns)

### 레이어 구조 (Layered Architecture)
1. **Presentation Layer** (`scenes/`, `widgets/`)
   - 사용자 인터페이스
   - 상태 관리 (Riverpod, BLoC)
   - 라우팅 (GoRouter)

2. **Business Logic Layer** (`services/`, `bloc/`)
   - 비즈니스 로직
   - 상태 관리
   - 데이터 처리

3. **Data Layer** (`services/`)
   - API 통신 (Supabase, Cloudinary)
   - 로컬 저장소 (SharedPreferences, SecureStorage)
   - 외부 서비스 연동

### 기능별 모듈화 (Feature-based Modules)
- **인증** (`auth/`, `bloc/auth_*.dart`)
- **커뮤니티** (`scenes/community/`, `services/community/`)
- **테마** (`theme/`)
- **유틸리티** (`utils/`, `widgets/`)

## 파일 명명 규칙 (File Naming Convention)

### Dart 파일 명명
- **화면**: `*_page.dart` (예: `login_page.dart`)
- **위젯**: `*_widget.dart` 또는 기능명 (예: `primary_text_button.dart`)
- **서비스**: `*_service.dart` 또는 기능명 (예: `cloudinary.dart`)
- **BLoC**: `*_bloc.dart`, `*_event.dart`, `*_state.dart`
- **테마**: `app_theme.dart`, `typography.dart`

### 리소스 파일 명명
- **이미지**: snake_case (예: `onboard_one.webp`)
- **아이콘**: 기능별 폴더 구조
- **폰트**: 제품명-Weight 형식 (예: `Pretendard-Bold.otf`)

## 설정 파일 구조 (Configuration Structure)

### Flutter 설정
- **pubspec.yaml**: 패키지 의존성, 에셋 정의
- **analysis_options.yaml**: 정적 분석 규칙
- **devtools_options.yaml**: DevTools 설정

### 플랫폼별 설정
- **Android**: `build.gradle.kts`, `AndroidManifest.xml`
- **iOS**: `Info.plist`, `Podfile`
- **Web**: `index.html`, `manifest.json`

### 환경 설정
- **.env**: 환경 변수 (개발/운영)
- **config/**: Google Services 설정 파일

## 코드 구성 원칙 (Code Organization Principles)

### 1. 관심사 분리 (Separation of Concerns)
- UI와 비즈니스 로직 분리
- 플랫폼별 코드 분리
- 기능별 모듈 분리

### 2. 의존성 방향 (Dependency Direction)
- 상위 레이어 → 하위 레이어 의존
- 인터페이스 기반 추상화
- 순환 의존성 방지

### 3. 재사용성 (Reusability)
- 공통 위젯 모듈화
- 유틸리티 함수 분리
- 테마 시스템 중앙화

## 확장성 고려사항 (Scalability Considerations)

### 장점 (Strengths)
- ✅ 기능별 명확한 분리
- ✅ 플랫폼별 최적화
- ✅ 테마 시스템 중앙화
- ✅ 개발 도구 체계화

### 개선 영역 (Areas for Improvement)
- 📝 테스트 커버리지 확장
- 📝 문서화 개선
- 📝 CI/CD 파이프라인 구축
- 📝 모니터링 시스템 추가
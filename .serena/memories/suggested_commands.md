# Suggested Commands for BamStar Development

## Flutter 개발 명령어 (Flutter Development Commands)

### 기본 개발 명령어 (Basic Commands)
```bash
# 작업 디렉토리 이동
cd bamstar/

# 의존성 설치/업데이트
flutter pub get
flutter pub upgrade --major-versions

# 앱 실행 (개발 모드)
flutter run
flutter run --debug
flutter run --release

# 특정 플랫폼 실행
flutter run -d chrome        # 웹
flutter run -d macos         # macOS
flutter run -d ios           # iOS 시뮬레이터
flutter run -d android       # Android 에뮬레이터
```

### 코드 품질 검사 (Code Quality)
```bash
# 정적 분석 (반드시 실행)
flutter analyze

# 코드 포맷팅
dart format lib/ test/

# 패키지 의존성 검사
flutter pub outdated
flutter pub deps
```

### 테스트 명령어 (Testing Commands)
```bash
# 전체 테스트 실행
flutter test

# 특정 테스트 파일 실행
flutter test test/widget_test.dart

# 테스트 커버리지
flutter test --coverage
```

### 빌드 명령어 (Build Commands)
```bash
# Android APK 빌드
flutter build apk --release
flutter build appbundle --release  # Play Store용

# iOS 빌드
flutter build ios --release

# 웹 빌드
flutter build web --release

# macOS 빌드
flutter build macos --release
```

## 태스크 완료 후 실행 명령어 (Post-Task Commands)

### 필수 실행 순서 (Required Sequence)
1. **코드 분석**: `flutter analyze`
2. **테스트 실행**: `flutter test`
3. **포맷팅**: `dart format lib/ test/`

### 배포 전 체크리스트 (Pre-deployment Checklist)
```bash
# 1. 의존성 확인
flutter pub get

# 2. 코드 품질 검사
flutter analyze

# 3. 테스트 실행
flutter test

# 4. 빌드 테스트
flutter build apk --debug
flutter build web --debug

# 5. 아이콘 생성 (필요시)
flutter pub run flutter_launcher_icons:main
```

## 환경 설정 명령어 (Environment Setup)

### Supabase 로컬 개발 (Local Supabase Development)
```bash
# Supabase CLI 설치 (한 번만)
brew install supabase/tap/supabase

# 로컬 Supabase 시작
cd ../dev/supabase/
supabase start
supabase stop
```

### 환경 변수 설정 (Environment Variables)
```bash
# .env 파일 확인
cat .env

# 필수 환경 변수:
# SUPABASE_URL=your_supabase_url
# SUPABASE_ANON_KEY=your_anon_key
# CLOUDINARY_CLOUD_NAME=your_cloud_name
# CLOUDINARY_UPLOAD_PRESET=your_preset
```

## macOS 시스템 유틸리티 (macOS System Utilities)

### 파일 시스템 명령어 (File System Commands)
```bash
# 디렉토리 탐색
ls -la                    # 상세 파일 목록
find . -name "*.dart"     # Dart 파일 찾기
grep -r "pattern" lib/    # 코드 내 패턴 검색

# Git 명령어
git status
git add .
git commit -m "message"
git push origin main
```

### 개발 도구 명령어 (Development Tools)
```bash
# Flutter 도구
flutter doctor          # Flutter 설치 상태 확인
flutter devices         # 연결된 디바이스 목록
flutter clean          # 빌드 캐시 정리

# 패키지 관리
flutter pub cache clean  # 패키지 캐시 정리
```

## 문제 해결 명령어 (Troubleshooting Commands)

### 일반적인 문제 해결 (Common Issues)
```bash
# 빌드 문제 해결
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# iOS 문제 해결
cd ios/
pod install
cd ..

# 캐시 정리
flutter pub cache clean
rm -rf build/
```

### 디버깅 명령어 (Debugging Commands)
```bash
# 로그 확인
flutter logs

# 성능 프로파일링
flutter run --profile
```

## 권장 개발 워크플로우 (Recommended Development Workflow)

1. **시작**: `cd bamstar && flutter pub get`
2. **개발**: `flutter run --debug`
3. **코드 작성** 후: `flutter analyze`
4. **기능 완성** 후: `flutter test`
5. **커밋 전**: `dart format lib/ test/`
6. **배포 전**: 전체 체크리스트 실행
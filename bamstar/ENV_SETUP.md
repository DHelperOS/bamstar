## 개발 환경(Flutter) 설정 가이드

이 문서는 macOS에서 이 저장소(bamstar) 개발을 시작하기 위한 최소 환경 설정 및 빠른 실행 절차를 설명합니다.

### 전제 조건
- macOS (본 문서는 macOS 기준)
- Git 계정과 접근 권한(원격 저장소에 푸시 가능해야 함)

### 1) Flutter 설치
1. Flutter SDK 설치 (권장: stable 채널)
   - 공식 페이지: https://docs.flutter.dev/get-started/install
   - 설치 후 PATH에 `flutter/bin`을 추가하세요.

2. 터미널에서 확인:
```bash
flutter --version
flutter doctor
```

### 2) Android 개발 환경
1. Android Studio 설치 및 SDK Components:
   - Android SDK Platform 36 (API 36)
   - Android SDK Build-Tools 36.x
   - Android SDK Command-line Tools
   - (필요시) NDK r27

2. 환경변수 설정 예시 (~/.bash_profile 또는 ~/.bashrc):
```bash
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools"
```

3. 라이선스 동의:
```bash
sdkmanager --licenses
```

### 3) 에뮬레이터 / 디바이스
- AVD를 만들어 Android 에뮬레이터 실행 또는 USB 디바이스 연결
- 디바이스 확인:
```bash
flutter devices
```

### 4) 개발용 의존성 설치 및 초기 실행
1. 프로젝트 루트로 이동:
```bash
cd /path/to/bamstar/bamstar
```

2. 패키지 설치:
```bash
flutter pub get
```

3. 정적 분석:
```bash
flutter analyze
```

4. 앱 실행 (에뮬레이터가 실행 중이어야 함):
```bash
flutter run -d <device-id>
```

### 5) scrcpy (선택)
- 에뮬레이터/디바이스 미러링: 설치(권장 brew)
```bash
brew install scrcpy
scrcpy --serial <device-id> --max-size 800 --bit-rate 2M --show-touches
```

### 6) 에셋 추가(온보딩 이미지 등)
- 에셋 파일을 `assets/`에 넣고 `pubspec.yaml`의 `flutter/assets:` 목록에 추가 후 `flutter pub get` 실행

예:
```yaml
flutter:
  assets:
    - assets/onboard_one.png
    - assets/onboard_two.png
    - assets/onboard_three.png
```

### 7) VS Code 권장 확장
- Flutter, Dart, Android iOS Emulator, scrcpy extension (선택)

### 8) 코드 스타일·템플릿 주의
- `dev/templates/ai-reference` 하위 템플릿은 참조 전용입니다. 직접 복사/수정 시 CI에 의해 차단될 수 있으니 주의하세요.
- 아이콘은 프로젝트 표준 `solar_icons` 패키지를 사용하세요.

### 9) Git 커밋 & 푸시(예시)
```bash
git add .
git commit -m "chore: add development environment guide"
git push origin <branch-name>
```

문제가 발생하면 `flutter doctor -v`와 `flutter run -v` 출력을 첨부해 알려주세요.

---
파일 작성자: 자동 생성

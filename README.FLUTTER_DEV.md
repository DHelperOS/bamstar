# Flutter 개발 워크플로 (간단 가이드)

이 프로젝트에서 Flutter 개발을 시작할 때의 빠른 워크플로입니다.

1. 필수 도구 설치(이미 설치됨): Flutter, Android Studio, Xcode, CocoaPods, VS Code
2. 환경 변수 적용:

```bash
source ~/.bash_profile
```

3. 의존성 설치:

```bash
flutter pub get
```

4. 실행/디버깅
- VS Code: `Run and Debug`에서 `Flutter: Launch bamstar (lib/main.dart)` 선택
- 터미널: `flutter run` 또는 특정 플랫폼 `flutter run -d macos` 등

5. 에뮬레이터
- Android: Android Studio → AVD Manager에서 가상 디바이스 생성
- iOS: Simulator 앱을 열거나 Xcode → Open Developer Tool → Simulator

6. 라이선스 및 툴 확인:

```bash
flutter doctor -v
```

문제가 있으면 `flutter doctor -v` 출력 결과를 복사해서 알려 주세요.

PWA 로컬 테스트 가이드

이 프로젝트의 `web/` 폴더에는 PWA를 로컬에서 빠르게 테스트하기 위한 파일들이 포함되어 있습니다.

변경 사항 요약:
- `sw.js` : 간단한 서비스워커 (캐시: index.html, manifest.json, favicon, icons)
- `index.html` : 서비스워커 등록 스크립트 추가
- 이미 존재하는 `manifest.json` 및 `icons/` 파일을 사용합니다.

로컬에서 테스트하는 방법 (간단):

1) 간단한 HTTP 서버로 `web/` 폴더를 서빙

```bash
# macOS / Python 3 사용 예시 (web/ 디렉터리에서 실행)
cd web
python3 -m http.server 8080
```

브라우저에서 http://localhost:8080 에 접속하면, 개발자 도구의 Application → Service Workers에서 `sw.js`가 등록되었는지 확인할 수 있습니다. "Add to Home screen" / 설치 옵션은 크롬에서 주소창 우측의 설치 아이콘 또는 메뉴에서 확인합니다.

2) Flutter로 실행 테스트 (개발 브라우저에서 설치 확인)

```bash
# 전체 앱을 빌드하지 않고 chrome에서 빠르게 실행
flutter run -d chrome
```

참고 및 제약:
- Flutter의 공식 PWA 최적화(예: `flutter_service_worker.js` 생성, 더 고급 캐싱 전략)는 `flutter build web` 시 생성됩니다. 위 `sw.js`는 빠른 로컬 테스트와 설치 가능성 확인을 위한 최소 구현입니다.
- HTTPS (또는 localhost)가 아닌 환경에서는 Service Worker가 동작하지 않습니다.

원하시면 `sw.js`를 더 고급 전략(버전 관리, 자산 해시 캐싱, 업데이트 알림)으로 업그레이드하거나, CI에서 자동으로 `flutter build web`할 때 생성되는 서비스워커 방식을 채택하도록 설정해 드리겠습니다.

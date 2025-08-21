# bamstar

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


-------------------------------------------
UI & 레이아웃 (Visual Components & Layout)
-------------------------------------------
앱의 시각적 요소와 화면 구성을 담당하는 패키지들입니다.
carousel_slider: ^4.2.1       # 여러 위젯을 좌우로 넘기는 슬라이드(캐러셀)
badges: ^3.1.2                # 위젯 모서리에 알림 개수 등 작은 배지 추가
toggle_switch: ^2.3.0         # 미려한 디자인의 토글 스위치
introduction_screen: ^3.1.17  # 앱 최초 실행 시 보여주는 온보딩(소개) 페이지
flutter_sliding_box: ^1.1.5     # 화면 하단에서 올라오는 고급 슬라이딩 패널 (※간단한 경우 내장 showModalBottomSheet 우선 고려)
smooth_page_indicator: ^1.1.0 # PageView의 현재 페이지를 알려주는 인디케이터
flutter_card_swiper: ^7.0.1     # 틴더처럼 카드를 좌우로 스와이프하는 UI
flutter_staggered_grid_view: ^0.7.0 # 핀터레스트 스타일의 가변 높이 그리드
el_tooltip: ^2.0.2            # 위젯을 탭/롱클릭 시 설명 말풍선(툴팁) 표시
flutter_form_builder: ^9.2.1  # 유효성 검사를 포함한 복잡한 폼(Form)을 쉽게 구성
syncfusion_flutter_sliders: ^25.1.35 # 범위 선택 등 고급 기능이 포함된 강력한 슬라이더 바
----------------------------------------------------
애니메이션 & 시각 효과 (Animations & Visual Effects)
----------------------------------------------------
앱에 생동감과 세련미를 더하는 애니메이션 및 효과 패키지들입니다.
animations: ^2.0.11             # Flutter 팀이 제공하는 고품질의 Material 화면 전환 효과
shimmer: ^3.0.0                 # 데이터 로딩 중에 보여주는 은은하게 반짝이는 스켈레톤 UI
avatar_glow: ^3.0.1             # 프로필 사진 주변에 부드럽게 퍼지는 네온 효과
local_hero_transform: ^1.0.6    # 리스트 항목 클릭 시 상세 화면으로 자연스럽게 확대/전환되는 애니메이션
-------------------------------------------------------
사용자 인터랙션 & 피드백 (Interaction & Feedback)
-------------------------------------------------------
사용자의 행동에 반응하고 명확한 피드백을 제공하는 패키지들입니다.
in_app_review: ^2.0.8           # 앱 내에서 스토어 리뷰(평점)를 요청하는 기능
toastification: ^1.2.0          # 화면에 잠시 나타났다 사라지는 세련된 알림 메시지(토스트)
flutter_rating_bar: ^4.0.1      # 별점/하트 등으로 평점을 매기는 인터랙티브 UI
---------------------------------------
테마 & 스플래시 (Theme & Splash)
---------------------------------------
앱의 전반적인 디자인 테마와 로딩 화면을 관리합니다.
adaptive_theme: ^3.6.0          # 다크/라이트 모드 등 테마 변경 및 설정 저장 (※GetX로 직접 구현 시 불필요)
flutter_native_splash: ^2.3.10  # 앱 로딩 초기의 흰/검은 화면을 대체하는 네이티브 스플래시
-------------------------------------------------
기능 & 유틸리티 (Features & Utilities)
-------------------------------------------------
특정 기능을 구현하거나 개발을 보조하는 핵심 유틸리티 패키지들입니다.
cached_network_image: ^3.3.1  # 네트워크 이미지 캐싱 및 로딩 플레이스홀더
infinite_scroll_pagination: ^4.0.0 # 스크롤을 내리면 다음 페이지를 자동 로딩하는 무한 스크롤
hl_image_picker: ^1.2.16        # 갤러리에서 여러 사진/비디오를 선택하는 고급 이미지 피커
korean_profanity_filter: ^1.0.0 # 한글 텍스트 내 비속어 필터링
camera: ^0.10.5+9               # 기기 카메라 직접 제어 (사진/비디오 촬영)
flutter_udid: ^2.0.1            # 기기의 고유 식별자(UDID) 획득
random_avatar: ^0.0.8           # 문자열 기반 랜덤 SVG 아바타 생성
avatar_stack: ^2.0.0            # 여러 사용자 아바타를 겹쳐서 보여주는 UI
image_size_getter: ^2.1.3       # 이미지 파일/URL로부터 원본 이미지 크기 획득
image_size_getter_http_input: ^1.1.0 # image_size_getter가 네트워크 이미지를 다루도록 돕는 확장
flutter_chat_ui: ^1.6.9         # 채팅 UI를 빠르게 만들 수 있는 위젯 모음
metalink_flutter: ^1.0.1        # 텍스트 내 URL 링크의 미리보기(썸네일, 제목) 생성
kpostal: ^0.4.1                 # 대한민국 우편번호 및 주소 검색
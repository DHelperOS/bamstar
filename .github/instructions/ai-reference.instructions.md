---
applyTo: '**'
---
Provide project context and coding guidelines that AI should follow when generating code, answering questions, or reviewing changes.

AI UI-참조 지침 (필수)
----------------------
- 목적: AI가 UI 변경/생성 작업을 수행할 때 `dev/templates/ai-reference`의 두 템플릿(`social_media_ui_kit_share`, `study_platform_ui_kit`)을 반드시 참조하도록 합니다. 템플릿은 "참고 전용"이며 그대로 복사/배포하지 않습니다.
- 적용 범위: `lib/` 내부 UI 관련 변경(위젯 추가/수정), 디자인 시스템/테마 업데이트, 화면 레이아웃 생성 등 모든 UI 작업.

모바일 우선(필수): 모든 페이지 및 화면을 만들 때는 모바일 최적화를 최우선으로 합니다. 터치 친화적 레이아웃, 작은 화면에서의 성능과 가시성을 우선 고려하되, 동일한 UI는 반응형으로 구현하여 데스크톱/웹 환경에서도 자연스럽게 동작해야 합니다. (예: SafeArea, 적절한 Breakpoints, Flexible/Expanded 사용, 폰트/버튼 최소 크기 확보 등)

Material 3 강제 규칙:
- UI 컴포넌트나 테마를 생성·수정할 때는 반드시 Material 3 스타일을 사용해야 합니다 (예: ThemeData(useMaterial3: true)).
- PR 본문에 "Material 3 적용: 사용됨" 또는 유사 문구를 포함해 적용 사실을 명시해야 합니다.

- 참조 절차:
  1) 사전 검토: 작업을 시작하기 전에 두 템플릿의 `lib/` 구조와 관련 위젯을 확인해 재사용 가능성, 네이밍 규칙, 상태관리 방식(예: Provider, Riverpod 등)을 파악합니다.
  2) 구현 가이드: 템플릿의 컴포넌트 설계(재사용 가능한 위젯, 스타일/테마 정의)를 우선 참고하되, 프로젝트 규약과 충돌하는 부분은 프로젝트 규약을 따릅니다.
  3) PR 제출 요건: PR 본문에 참조한 템플릿의 경로와 차용한 패턴(한 줄)을 반드시 포함합니다. 예: `References: dev/templates/ai-reference/study_platform_ui_kit/lib/widgets/profile_card.dart`.

Checklist (PR 요건):
- `References:` 템플릿 경로 포함
- `Used components:` 템플릿에서 차용한 컴포넌트/유틸 목록
- `Modifications:` 템플릿을 변경해 사용한 경우 변경 내용 요약

Icon usage rule (추가 규칙):
- UI에 아이콘을 배치할 때는 프로젝트 표준으로 `solar_icons` 패키지를 사용해야 합니다. AI가 UI 코드를 생성하거나 수정할 때 모든 아이콘은 `solar_icons`를 사용하도록 하며, PR 본문에 `Used icons: solar_icons`를 포함해야 합니다.

패키지 사용 우선순위 (추가 규칙):
- 원칙: 외부 패키지를 사용할 때는 먼저 저장소의 `pubspec.yaml`에 이미 선언된 패키지를 우선 사용합니다. `pubspec.yaml`을 프로젝트의 패키지 소스 오브스( Source of Truth )로 간주하세요.
- 절차:
  1) 새로운 패키지를 도입해야 하는 경우, 먼저 `pubspec.yaml`에 동일하거나 대체 가능한 패키지가 이미 있는지 확인합니다.
  2) 템플릿(예: `dev/templates/ai-reference`)이나 외부 예제에서 다른 패키지를 추천할 경우, 가능하면 프로젝트에 선언된 패키지로 대체합니다. 대체가 불가능하거나 기술적 제약이 있을 때만 새 패키지를 추가합니다.
  3) 새 패키지를 `pubspec.yaml`에 추가해야 한다면 PR에 변경 사유와 함께 `pubspec.yaml`의 관련 항목을 명시하고, PR 본문에 `Added packages:` 섹션으로 추가된 패키지 이름과 버전을 기재하세요. 예: `Added packages: go_router: ^16.1.0`.
  4) 새 패키지 추가가 승인되면 로컬에서 `flutter pub get`을 실행해 종속성을 확인하고, PR 검증 단계(예: CI 또는 로컬 빌드)에서 빌드/분석이 통과하는지 확인합니다.
- 예외: 보안/라이선스 문제 또는 심각한 호환성 문제가 있는 경우, PR에 대체안(예: 다른 패키지 또는 직접 구현)을 명시하고 리뷰어와 논의하세요.

예외 및 주의사항:
- 템플릿은 `REFERENCE_ONLY.md`로 표기되어 있으므로 자동화된 복사/병합(예: CI에서 자동 적용)은 금지합니다.
- 템플릿 내 의존성이나 코드가 오래되어 문제가 있을 경우(예: deprecated 패키지, 보안 이슈) PR에 반드시 근거와 대체안을 명시해야 합니다.

간단한 명령어(로컬 확인용):
```bash
ls -R dev/templates/ai-reference
grep -R "class " dev/templates/ai-reference/*/lib || true
```

이 지침은 AI가 UI 작업을 수행할 때 참고 우선순위를 명시적으로 부여해 일관된 UI 패턴과 재사용을 촉진하기 위한 것입니다.

자동 차단 워크플로
-----------------
- 저장소에 `dev/templates/ai-reference` 하위 파일을 수정하는 PR은 자동으로 차단됩니다. 이 동작은 `.github/workflows/deny-template-changes.yml` 워크플로에 의해 수행됩니다.
- 템플릿을 업데이트해야 하는 경우, 저장소 관리자와 상의해 워크플로 예외를 적용하거나 별도의 PR 프로세스를 따르세요.
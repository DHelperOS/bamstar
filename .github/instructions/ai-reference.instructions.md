---
applyTo: '**'
---
Provide project context and coding guidelines that AI should follow when generating code, answering questions, or reviewing changes.

AI UI-참조 지침 (필수)
----------------------
- 목적: AI가 UI 변경/생성 작업을 수행할 때 `dev/templates/ai-reference`의 두 템플릿(`social_media_ui_kit_share`, `study_platform_ui_kit`)을 반드시 참조하도록 합니다. 템플릿은 "참고 전용"이며 그대로 복사/배포하지 않습니다.
- 적용 범위: `lib/` 내부 UI 관련 변경(위젯 추가/수정), 디자인 시스템/테마 업데이트, 화면 레이아웃 생성 등 모든 UI 작업.

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
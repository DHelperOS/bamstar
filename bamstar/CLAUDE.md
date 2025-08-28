# BamStar Flutter Development Guidelines

## 🎨 MANDATORY Theme & Typography System Usage

> **CRITICAL**: ALL Flutter code MUST use our centralized theme and typography system. Zero exceptions.

### **🚫 NEVER USE:**
- `Color(0x...)` - Hardcoded hex colors
- `Colors.*` - Direct Flutter color constants  
- `TextStyle(fontSize: ..., fontWeight: ...)` - Hardcoded text styles
- Direct theme access for text: `Theme.of(context).textTheme.*`

### **✅ ALWAYS USE:**

#### **Colors**
```dart
// Background Colors
Theme.of(context).colorScheme.surface
Theme.of(context).colorScheme.background

// Text Colors  
Theme.of(context).colorScheme.onSurface
Theme.of(context).colorScheme.onSurfaceVariant

// UI Element Colors
Theme.of(context).colorScheme.primary
Theme.of(context).colorScheme.secondary
Theme.of(context).colorScheme.error
Theme.of(context).colorScheme.outline
Theme.of(context).colorScheme.shadow
```

#### **Typography**
```dart
// Semantic Text Styles (MANDATORY)
AppTextStyles.pageTitle(context)      // Page headers
AppTextStyles.sectionTitle(context)   // Section headings
AppTextStyles.cardTitle(context)      // Card titles
AppTextStyles.primaryText(context)    // Main body text
AppTextStyles.secondaryText(context)  // Secondary text
AppTextStyles.captionText(context)    // Small text
AppTextStyles.buttonText(context)     // Button labels
AppTextStyles.chipLabel(context)      // Chip labels
AppTextStyles.formLabel(context)      // Form labels
AppTextStyles.errorText(context)      // Error messages
AppTextStyles.dialogTitle(context)    // Dialog titles
```

---

## 🤖 AI Code Generation Rules

### **Pre-Generation Checks**
Before generating ANY Flutter code, verify:

1. ✅ **Color Check**: No `Color(0x...)` or `Colors.*` usage
2. ✅ **Typography Check**: No hardcoded `TextStyle(...)` 
3. ✅ **Theme Check**: Uses `colorScheme.*` for colors
4. ✅ **Semantic Check**: Uses `AppTextStyles.*` for text

### **Automatic Rejections**
AI MUST reject any code containing:
- `Color(0xFFFFFFFF)` → Use `colorScheme.surface`
- `Colors.white` → Use `colorScheme.surface`  
- `Colors.black` → Use `colorScheme.onSurface`
- `TextStyle(fontSize: 14)` → Use `AppTextStyles.primaryText(context)`

---

## 📂 Project Structure Context

### **Theme Files (Reference Only)**
- `lib/theme/app_theme.dart` - Central theme configuration
- `lib/theme/app_color_scheme.dart` - Color system
- `lib/theme/app_text_styles.dart` - Typography system
- `lib/theme/typography.dart` - Base typography definitions

### **Import Requirements**
Always include these imports when using theme system:
```dart
import '../theme/app_text_styles.dart'; // For typography
// ColorScheme accessed via Theme.of(context).colorScheme
```

---

## 🎯 Common UI Patterns

### **Container Styling**
```dart
// ✅ Correct
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Theme.of(context).colorScheme.outline,
    ),
    boxShadow: [
      BoxShadow(
        color: Theme.of(context).colorScheme.shadow,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
)
```

### **Text Widget Styling**
```dart
// ✅ Correct
Text(
  'Card Title',
  style: AppTextStyles.cardTitle(context),
)

Text(
  'Body content here',  
  style: AppTextStyles.primaryText(context),
)

Text(
  'Supporting info',
  style: AppTextStyles.secondaryText(context),
)
```

### **Button Styling**
```dart
// ✅ Correct
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
  ),
  child: Text(
    'Button Text',
    style: AppTextStyles.buttonText(context),
  ),
)
```

---

## 🔍 Code Review Standards

Every Flutter code change MUST pass this checklist:

- [ ] ❌ Zero hardcoded colors (`Color(0x...)`, `Colors.*`)
- [ ] ❌ Zero hardcoded text styles (`TextStyle(...)`) 
- [ ] ✅ All colors use `Theme.of(context).colorScheme.*`
- [ ] ✅ All text uses `AppTextStyles.*`
- [ ] ✅ Semantic meaning matches usage
- [ ] ✅ Supports light/dark theme switching
- [ ] ✅ Maintains accessibility standards

**⚠️ Any code failing these checks will be automatically rejected.**

---

## 📚 Quick Reference

| Need | Use |
|------|-----|
| White background | `colorScheme.surface` |
| Black text | `colorScheme.onSurface` |
| Gray text | `colorScheme.onSurfaceVariant` |
| Red error | `colorScheme.error` |
| Primary action | `colorScheme.primary` |
| Border | `colorScheme.outline` |
| Page title | `AppTextStyles.pageTitle(context)` |
| Body text | `AppTextStyles.primaryText(context)` |
| Small text | `AppTextStyles.captionText(context)` |
| Button text | `AppTextStyles.buttonText(context)` |

---

## 🔗 개발 환경 & 도구

### **Supabase 연결**
- **연결 가이드**: `SUPABASE_CONNECTION_GUIDE.md` 참조
- **CLI 토큰**: `SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b`
- **MCP 토큰**: `MCP_AUTH_TOKEN=sb_secret_6gi2ZmG0XtspzcWuGVUkFw_OLfPWItH`
- **프로젝트 ID**: `tflvicpgyycvhttctcek`

### **빠른 명령어**
```bash
# CLI 연결 테스트
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase projects list

# 데이터베이스 쿼리 (Claude Code MCP)
mcp__supabase__execute_sql --project-id tflvicpgyycvhttctcek --query "SELECT * FROM member_profiles LIMIT 5;"
```

---

## 📢 Toast 알림 시스템

### **MANDATORY Toast System Usage**

> **CRITICAL**: ALL notification messages MUST use our centralized toast system. Zero exceptions.

### **🚫 NEVER USE:**
- `ScaffoldMessenger.of(context).showSnackBar()` - Legacy Flutter SnackBar
- `SnackBar()` widget - Inconsistent with app theme
- Direct delightful_toast calls - Use wrapper only

### **✅ ALWAYS USE:**

#### **Toast Helper Methods**
```dart
// Import required
import '../utils/toast_helper.dart';

// Success notifications (green theme)
ToastHelper.success(context, '프로필이 저장되었습니다');

// Error notifications (red theme)  
ToastHelper.error(context, '저장 중 오류가 발생했습니다');

// Warning notifications (orange theme)
ToastHelper.warning(context, '로그인이 필요합니다');

// Info notifications (blue theme)
ToastHelper.info(context, '검색을 실행합니다');
```

#### **Toast Categories**
- **Success**: Completed actions, saved data, successful operations
- **Error**: Failed operations, validation errors, system errors
- **Warning**: Missing requirements, permission issues, cautionary messages
- **Info**: General information, help text, process notifications

### **Implementation Rules**
1. ✅ Import `ToastHelper` in every file using notifications
2. ✅ Choose appropriate semantic method (success/error/warning/info)
3. ✅ Use Korean messages matching app language
4. ✅ Keep messages concise and user-friendly
5. ❌ Never mix SnackBar with ToastHelper in same file
6. ❌ Never create custom toast implementations

---

## 🗄️ Supabase Database Reference (MANDATORY)

> **CRITICAL**: ALL Supabase-related work MUST reference these comprehensive documentation files. These files contain complete, verified database schema and operational procedures.

### **📋 Required Reading Before Any Database Work**

1. **`SUPABASE_DATABASE_REFERENCE_COMPLETE.md`** - Complete schema documentation
   - 24 production tables with full schema definitions
   - 3 custom enums (gender_enum, experience_level_enum, pay_type_enum)
   - 7+ database functions and stored procedures
   - 5 edge functions (hashtag-processor, daily-hashtag-curation, etc.)
   - Row Level Security policies and triggers
   - Complete relationship mappings and foreign keys

2. **`SUPABASE_MANAGEMENT_GUIDE.md`** - Operational procedures and maintenance
   - Authenticated CLI commands with working tokens
   - Database deployment and rollback procedures  
   - Edge function management and deployment
   - Performance monitoring and health checks
   - Emergency procedures and troubleshooting
   - Daily/weekly/monthly maintenance tasks

3. **`SUPABASE_CONNECTION_GUIDE.md`** - Verified connection methods
   - Working psql connection strings (tested ✅)
   - Authenticated Supabase CLI commands
   - MCP integration setup and tokens
   - Troubleshooting for connection issues
   - Environment setup and security practices

### **🚫 Database Work Violations**

- **NEVER** guess table names, column names, or data types
- **NEVER** assume relationship structures without verification
- **NEVER** create migrations without consulting schema reference
- **NEVER** deploy edge functions without checking existing patterns
- **NEVER** modify RLS policies without understanding current rules

### **🔄 MANDATORY Documentation Updates**

> **CRITICAL**: 데이터베이스 변경사항이 있을 경우 반드시 다음 3개 파일을 즉시 갱신해야 합니다.

**데이터베이스 변경 후 필수 작업:**

1. **스키마 변경시** (테이블, 컬럼, 인덱스, enum, 함수 추가/수정/삭제)
   - ✅ `SUPABASE_DATABASE_REFERENCE_COMPLETE.md` 즉시 업데이트
   - ✅ 새로운 테이블 구조, 관계, 제약조건 반영
   - ✅ 함수 및 트리거 코드 갱신

2. **운영 절차 변경시** (CLI 명령어, 배포 절차, 모니터링 방법 변경)
   - ✅ `SUPABASE_MANAGEMENT_GUIDE.md` 즉시 업데이트
   - ✅ 새로운 관리 명령어 및 절차 반영
   - ✅ 유지보수 스크립트 갱신

3. **연결 방법 변경시** (토큰, 엔드포인트, 인증 방법 변경)
   - ✅ `SUPABASE_CONNECTION_GUIDE.md` 즉시 업데이트
   - ✅ 새로운 연결 문자열 및 토큰 반영
   - ✅ 문제해결 가이드 갱신

**변경사항 반영 규칙:**
- 🔴 **즉시 반영**: 스키마 변경은 작업 완료와 동시에 문서 업데이트
- 🟡 **검증 필요**: 변경된 내용이 실제 데이터베이스와 일치하는지 확인
- 🟢 **일관성 유지**: 세 문서 간의 정보 일치성 보장

**자동화 체크리스트:**
- [ ] ✅ 데이터베이스 변경 감지시 문서 업데이트 알림
- [ ] ✅ 스키마 변경 후 `SUPABASE_DATABASE_REFERENCE_COMPLETE.md` 갱신
- [ ] ✅ 운영 절차 변경 후 `SUPABASE_MANAGEMENT_GUIDE.md` 갱신  
- [ ] ✅ 연결 정보 변경 후 `SUPABASE_CONNECTION_GUIDE.md` 갱신
- [ ] ✅ 문서 간 일관성 검증 완료

### **✅ MANDATORY Pre-Work Checklist**

Before ANY Supabase-related task:
- [ ] ✅ Read relevant sections from `SUPABASE_DATABASE_REFERENCE_COMPLETE.md`
- [ ] ✅ Check `SUPABASE_CONNECTION_GUIDE.md` for correct connection methods
- [ ] ✅ Consult `SUPABASE_MANAGEMENT_GUIDE.md` for operational procedures
- [ ] ✅ Verify table/column names against actual schema
- [ ] ✅ Check existing edge functions before creating new ones
- [ ] ✅ Review RLS policies and triggers before modifications

### **🎯 Quick Database Reference**

#### **Key Tables**
- `users` (24 tables total) - Main user accounts with role_id foreign key
- `member_profiles` - Extended user profile with JSONB matching_conditions
- `community_posts/comments/hashtags` - Social features with threading
- `attributes` - Master attributes with type-based categorization
- `*_link` tables - Many-to-many relationships (member_attributes_link, etc.)

#### **Production Edge Functions**
- `hashtag-processor` - Hashtag extraction and processing
- `update-matching-conditions` - Member profile and matching conditions updater
- `daily-hashtag-curation` - AI-powered hashtag trend analysis
- `image-safety-web` - Image content moderation
- `cloudinary-signature` - Image upload signature generation

#### **Working Connection Commands**
```bash
# Direct psql (Primary method)
PGPASSWORD='!@Wnrsmsek1' psql -h aws-1-ap-northeast-2.pooler.supabase.com -p 6543 -d postgres -U postgres.tflvicpgyycvhttctcek

# Supabase CLI with auth
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --execute "SELECT 1;"
```

---

## 🔍 코드 품질 검증 시스템

### **MANDATORY Flutter Analyze**

> **CRITICAL**: 모든 작업 완료 후 반드시 Flutter 정적 분석을 실행하여 오류를 확인하고 수정해야 합니다.

### **🚫 완료 보고 금지 조건:**
- `flutter analyze`에서 ERROR 레벨 이슈가 발견된 경우
- 컴파일 오류나 타입 오류가 있는 경우
- 정의되지 않은 메서드나 변수 참조가 있는 경우

### **✅ 작업 완료 프로세스:**

#### **1. 작업 완료 후 필수 검증**
```bash
flutter analyze
```

#### **2. 오류 수정 절차**
- ERROR 레벨 이슈: 즉시 수정 (작업 완료 불가)
- WARNING 레벨 이슈: 가능한 경우 수정 (선택사항)
- INFO 레벨 이슈: 무시 가능 (스타일 권고사항)

#### **3. 완료 보고 조건**
```markdown
✅ **작업 완료 보고**
- 기능 구현 완료
- `flutter analyze`: ERROR 0개 확인
- 컴파일 및 빌드 가능 상태
- Git 커밋 및 푸시 완료
```

#### **4. Git 커밋 및 푸시 절차**
```bash
# 변경사항 스테이징
git add .

# 의미 있는 커밋 메시지로 커밋
git commit -m "작업 내용 요약"

# 원격 저장소로 푸시
git push
```

### **코드 품질 기준**
- **ERROR**: 즉시 수정 필요 (컴파일 불가)
- **WARNING**: 권장 수정 (런타임 이슈 가능성)  
- **INFO**: 선택 수정 (스타일 가이드 권고)

### **자동화 규칙**
1. ✅ 모든 Flutter 작업 후 `flutter analyze` 실행
2. ✅ ERROR 이슈 발견 시 자동 수정 시도
3. ✅ 수정 불가능한 ERROR는 사용자에게 보고
4. ✅ 작업 완료 시 Git 커밋 및 푸시 자동 실행
5. ❌ ERROR가 있는 상태로 작업 완료 보고 금지
6. ❌ Git 커밋 없이 작업 완료 보고 금지

---

**🎯 Remember: Consistency is key to maintainable, accessible, and professional Flutter applications.**
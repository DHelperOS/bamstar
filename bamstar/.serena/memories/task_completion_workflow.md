# BamStar Task Completion Workflow

## MANDATORY Task Completion Process

> **CRITICAL**: Every development task MUST follow this completion workflow. No exceptions.

## 1. Pre-Completion Validation

### Flutter Code Quality Check (MANDATORY)
```bash
# Run static analysis - ERROR level issues must be fixed
flutter analyze

# Expected output for completion:
# ✅ "No issues found!"
# ❌ "ERROR: [description]" → Must fix before proceeding
```

### Compilation Verification
```bash
# Ensure code compiles successfully
flutter run --dry-run

# Or attempt actual build
flutter build apk --debug
```

## 2. Code Quality Standards

### ❌ BLOCKING Issues (Cannot Complete):
- ERROR-level issues in `flutter analyze`
- Compilation failures
- Import errors or undefined references
- Missing required dependencies
- Hardcoded colors (`Color(0xFF...)`, `Colors.*`)
- Hardcoded text styles (`TextStyle(...)`)
- Legacy notification system (`SnackBar`, `ScaffoldMessenger`)

### ⚠️ WARNING Issues (Strongly Recommended):
- WARNING-level analysis issues
- Inconsistent naming conventions
- Missing error handling
- Non-semantic text styles usage

### ℹ️ INFO Issues (Optional):
- Style guide suggestions
- Documentation recommendations
- Performance optimization hints

## 3. Git Workflow (MANDATORY)

### Stage Changes
```bash
# Review all changes first
git diff

# Stage relevant files
git add .
# OR stage specific files
git add lib/scenes/new_feature.dart lib/providers/new_provider.dart
```

### Commit with Descriptive Message
```bash
# Use semantic commit messages
git commit -m "feat: implement user profile matching preferences

- Add matching preferences form with age/distance ranges
- Integrate with Supabase member_profiles table  
- Add validation for required fields
- Update UI with AppTextStyles and colorScheme"
```

### Push to Remote
```bash
# Push to feature branch
git push origin feature/matching-preferences

# Or push to main (if working directly)
git push origin main
```

## 4. Testing & Validation

### Manual Testing Checklist
- [ ] Feature works as expected in UI
- [ ] No runtime errors or crashes
- [ ] Responsive design on different screen sizes
- [ ] Toast notifications display correctly
- [ ] Navigation flows work properly
- [ ] Data persistence functions correctly

### Automated Testing (If Available)
```bash
# Run widget tests
flutter test

# Run integration tests (if configured)
flutter test integration_test/
```

## 5. Documentation Updates

### Update Relevant Documentation
- Update API documentation if backend changes
- Update README if setup process changes
- Add comments for complex business logic
- Update CLAUDE.md if new patterns established

### Feature Documentation Template
```markdown
## [Feature Name] Implementation

### Changes Made:
- [Brief list of changes]
- [Database schema updates]
- [New dependencies added]

### Usage:
```dart
// Code example of how to use the feature
```

### Testing:
- [Manual testing steps]
- [Edge cases covered]
```

## 6. Task Completion Report Format

### ✅ Successful Completion Report
```markdown
✅ **Task Completed Successfully**

**Feature**: [Brief description]
**Changes**: [List key changes made]
**Files Modified**: [Count and key files]

**Quality Checks**:
- `flutter analyze`: ✅ No ERROR issues
- Compilation: ✅ Successful
- Manual testing: ✅ Passed
- Git commit: ✅ Pushed to [branch_name]

**Next Steps**: [Any follow-up recommendations]
```

### ❌ Incomplete Task Report
```markdown
❌ **Task Incomplete - Blocked**

**Issue**: [Description of blocking issue]
**Error Details**: [Specific error messages]
**Files Affected**: [Problematic files]

**Resolution Required**:
- [Steps needed to fix]
- [User input needed]
- [External dependencies required]

**Current Status**: [What's been completed vs remaining]
```

## 7. Emergency/Rollback Procedures

### If Build Breaks
```bash
# Quick rollback to last working state
git log --oneline -5
git checkout [last_working_commit_hash]

# Or revert specific commit
git revert [problematic_commit_hash]
```

### If Supabase Changes Cause Issues
```bash
# Rollback database migration
supabase db reset --linked

# Reapply only working migrations
supabase db push --linked
```

## 8. Quality Gate Rules

### Cannot Mark Complete If:
- `flutter analyze` shows ERROR-level issues
- Code doesn't compile successfully
- Critical functionality is broken
- Git changes aren't committed and pushed
- Required code quality standards aren't met

### Can Mark Complete With Warnings If:
- All ERROR-level issues resolved
- Core functionality works correctly
- WARNING issues documented for future fix
- User explicitly approves proceeding with warnings

## 9. Collaboration Standards

### Before Merging PRs:
- All quality gates passed
- Code review completed
- Integration testing performed
- Documentation updated
- Supabase schema changes deployed

### Communication Template:
```markdown
**Ready for Review**: [Feature Name]

**Summary**: [What was implemented]
**Testing**: [How it was tested]  
**Dependencies**: [Any new dependencies]
**Migration**: [Database changes if any]
**Breaking Changes**: [If any]

**Quality Checks**:
- [ ] flutter analyze: No errors
- [ ] Manual testing: Passed
- [ ] Code follows CLAUDE.md standards
- [ ] Git commits: Descriptive messages
```
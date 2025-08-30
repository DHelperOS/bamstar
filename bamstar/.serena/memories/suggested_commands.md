# BamStar Development Commands

## Essential Flutter Commands

### Development & Testing
```bash
# Install dependencies
flutter pub get

# Run the app in development mode
flutter run

# Run on specific device
flutter run -d chrome        # Web browser
flutter run -d emulator-5554 # Android emulator
flutter run -d iPhone       # iOS simulator

# Hot reload during development (within running app)
# Press 'r' for hot reload
# Press 'R' for hot restart

# Clean build artifacts
flutter clean && flutter pub get

# Build for production
flutter build apk           # Android APK
flutter build ios           # iOS build
flutter build web           # Web build
```

### Code Quality & Analysis (MANDATORY)
```bash
# Static analysis - MUST be run after every change
flutter analyze

# Run tests
flutter test

# Format code
dart format lib/

# Check dependencies
flutter pub outdated
flutter pub upgrade
```

## Supabase Commands

### Authentication & Project Management
```bash
# Set access token (required for all Supabase commands)
export SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b

# List projects
supabase projects list

# Link to project
supabase link --project-ref tflvicpgyycvhttctcek

# Database operations
supabase db push --linked                    # Apply migrations
supabase db reset --linked                   # Reset local DB
supabase db dump --linked -f backup.sql     # Backup database

# Execute SQL directly
supabase sql --project-ref tflvicpgyycvhttctcek --file migration.sql
supabase sql --project-ref tflvicpgyycvhttctcek --execute "SELECT * FROM users LIMIT 5;"
```

### Edge Functions
```bash
# List edge functions
supabase functions list --project-ref tflvicpgyycvhttctcek

# Deploy function
supabase functions deploy function-name --project-ref tflvicpgyycvhttctcek

# Test function locally
supabase functions serve
```

### Migrations
```bash
# Create new migration
supabase migration new migration_name

# Apply migration to remote
supabase sql --project-ref tflvicpgyycvhttctcek --file supabase/migrations/filename.sql
```

## Git Workflow Commands

### Development Workflow
```bash
# Check status and current branch
git status && git branch

# Create feature branch
git checkout -b feature/feature-name

# Stage and commit changes
git add .
git commit -m "feat: descriptive commit message"

# Push to remote
git push origin feature/feature-name

# Merge to main (after PR approval)
git checkout main
git pull origin main
git merge feature/feature-name
git push origin main
```

## System Utilities (macOS)

### File Operations
```bash
# List files with details
ls -la

# Find files
find . -name "*.dart" -type f

# Search in files (use ripgrep if available)
grep -r "searchterm" lib/
rg "searchterm" lib/         # Faster alternative

# File permissions
chmod +x script.sh

# Directory operations
mkdir -p path/to/directory
```

### Process Management
```bash
# Find running processes
ps aux | grep flutter

# Kill process by PID
kill -9 <PID>

# Network ports
lsof -i :3000              # Check what's running on port 3000
```

## MCP Integration Commands (Claude Code)

### Supabase MCP
```bash
# Execute SQL queries via MCP
mcp__supabase__execute_sql --project-id tflvicpgyycvhttctcek --query "SELECT * FROM member_profiles LIMIT 5;"

# List tables
mcp__supabase__list_tables --project-id tflvicpgyycvhttctcek

# Apply migration
mcp__supabase__apply_migration --project-id tflvicpgyycvhttctcek --name migration_name --query "SQL_CONTENT"
```

## Development Environment Setup

### Initial Setup
```bash
# 1. Install Flutter dependencies
flutter doctor

# 2. Set up environment variables
cp .env.example .env
# Edit .env with proper API keys

# 3. Configure Supabase
supabase login
supabase link --project-ref tflvicpgyycvhttctcek

# 4. Install app dependencies
flutter pub get

# 5. Run first build
flutter clean && flutter run
```

### Daily Workflow
```bash
# 1. Pull latest changes
git pull origin main

# 2. Update dependencies if needed
flutter pub get

# 3. Start development
flutter run

# 4. Before committing (MANDATORY)
flutter analyze
# Fix any ERROR-level issues before proceeding

# 5. Commit and push
git add .
git commit -m "descriptive message"
git push
```
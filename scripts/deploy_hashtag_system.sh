#!/bin/bash

# 해시태그 자동화 시스템 배포 스크립트
# 이 스크립트는 다음을 수행합니다:
# 1. Supabase 마이그레이션 실행
# 2. Edge Functions 배포
# 3. 환경 변수 설정

set -e  # 에러 발생 시 스크립트 중단

# 색상 출력을 위한 함수
print_status() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

# Supabase CLI 설치 확인
if ! command -v supabase &> /dev/null; then
    print_error "Supabase CLI가 설치되지 않았습니다."
    print_status "설치 방법: npm install -g supabase"
    exit 1
fi

# 프로젝트 연결 확인
print_status "Supabase 프로젝트에 연결 중..."
PROJECT_REF="tflvicpgyycvhttctcek"

# 환경 변수 확인
if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
    print_error "SUPABASE_ACCESS_TOKEN 환경 변수가 설정되지 않았습니다."
    print_status "다음 명령어로 설정하세요:"
    print_status "export SUPABASE_ACCESS_TOKEN=your_token_here"
    exit 1
fi

# 1. 마이그레이션 실행
print_status "데이터베이스 마이그레이션 실행 중..."
supabase db push --project-ref $PROJECT_REF

if [ $? -eq 0 ]; then
    print_success "마이그레이션이 성공적으로 실행되었습니다."
else
    print_error "마이그레이션 실행에 실패했습니다."
    exit 1
fi

# 2. Edge Functions 배포
print_status "Edge Functions 배포 중..."

# hashtag-processor 함수 배포
print_status "hashtag-processor 함수 배포 중..."
supabase functions deploy hashtag-processor --project-ref $PROJECT_REF

if [ $? -eq 0 ]; then
    print_success "hashtag-processor 함수가 성공적으로 배포되었습니다."
else
    print_error "hashtag-processor 함수 배포에 실패했습니다."
    exit 1
fi

# daily-hashtag-curation 함수 배포
print_status "daily-hashtag-curation 함수 배포 중..."
supabase functions deploy daily-hashtag-curation --project-ref $PROJECT_REF

if [ $? -eq 0 ]; then
    print_success "daily-hashtag-curation 함수가 성공적으로 배포되었습니다."
else
    print_error "daily-hashtag-curation 함수 배포에 실패했습니다."
    exit 1
fi

# 3. Edge Functions에 환경 변수 설정
print_status "Edge Functions 환경 변수 설정 중..."

# Gemini API 키가 설정되어 있는지 확인
if [ ! -z "$GEMINI_API_KEY" ]; then
    supabase secrets set GEMINI_API_KEY="$GEMINI_API_KEY" --project-ref $PROJECT_REF
    print_success "GEMINI_API_KEY가 설정되었습니다."
else
    print_status "GEMINI_API_KEY가 설정되지 않았습니다. AI 추천 기능은 비활성화됩니다."
fi

# 4. 스케줄링 설정 (수동으로 설정해야 함)
print_status "스케줄링 설정 안내:"
print_status "daily-hashtag-curation 함수를 매일 실행하려면 다음을 수행하세요:"
print_status "1. Supabase 대시보드 > Edge Functions > daily-hashtag-curation"
print_status "2. Cron Jobs 섹션에서 스케줄 추가: '0 2 * * *' (매일 오전 2시)"
print_status "3. 또는 외부 크론 서비스를 사용하여 함수 호출"

print_success "해시태그 자동화 시스템 배포가 완료되었습니다!"
print_status "시스템 기능:"
print_status "✓ 실시간 해시태그 통계 업데이트"
print_status "✓ AI 기반 해시태그 추천"
print_status "✓ 트렌드 분석 및 카테고리 분류"
print_status "✓ 개인화된 해시태그 추천"
print_status "✓ 일일 큐레이션 및 정리"

print_status "배포된 함수 URL:"
print_status "hashtag-processor: https://$PROJECT_REF.supabase.co/functions/v1/hashtag-processor"
print_status "daily-hashtag-curation: https://$PROJECT_REF.supabase.co/functions/v1/daily-hashtag-curation"
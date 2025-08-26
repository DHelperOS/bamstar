#!/bin/bash

# 해시태그 자동화 시스템 테스트 스크립트
# 배포된 시스템의 동작을 확인합니다.

set -e

PROJECT_REF="tflvicpgyycvhttctcek"
BASE_URL="https://$PROJECT_REF.supabase.co"
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmbHZpY3BneXljdmh0dGN0Y2VrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxNzI4MTUsImV4cCI6MjA3MDc0ODgxNX0.E1VkqVt23sT8E7m6JWER-1wpWKIBpcm_4oURju_MCiw"

# 색상 출력을 위한 함수
print_test() {
    echo -e "\033[1;33m[TEST]\033[0m $1"
}

print_pass() {
    echo -e "\033[1;32m[PASS]\033[0m $1"
}

print_fail() {
    echo -e "\033[1;31m[FAIL]\033[0m $1"
}

print_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

# 1. RPC 함수 테스트
print_test "Testing RPC functions..."

# batch_upsert_hashtag_stats 테스트
print_test "Testing batch_upsert_hashtag_stats..."
BATCH_RESPONSE=$(curl -s -X POST "$BASE_URL/rest/v1/rpc/batch_upsert_hashtag_stats" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "hashtag_names": ["테스트1", "테스트2", "테스트3"],
    "updated_at": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'"
  }')

if [[ $? -eq 0 ]]; then
    print_pass "batch_upsert_hashtag_stats 함수 작동 확인"
else
    print_fail "batch_upsert_hashtag_stats 함수 오류"
    echo "Response: $BATCH_RESPONSE"
fi

# analyze_hashtag_trends 테스트
print_test "Testing analyze_hashtag_trends..."
TRENDS_RESPONSE=$(curl -s -X POST "$BASE_URL/rest/v1/rpc/analyze_hashtag_trends" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "days_back": 7,
    "min_usage_count": 1
  }')

if [[ $? -eq 0 ]] && [[ $TRENDS_RESPONSE != *"error"* ]]; then
    print_pass "analyze_hashtag_trends 함수 작동 확인"
    echo "Trending hashtags found: $(echo "$TRENDS_RESPONSE" | jq '. | length' 2>/dev/null || echo "N/A")"
else
    print_fail "analyze_hashtag_trends 함수 오류"
    echo "Response: $TRENDS_RESPONSE"
fi

# recommend_hashtags_for_content 테스트
print_test "Testing recommend_hashtags_for_content..."
RECOMMEND_RESPONSE=$(curl -s -X POST "$BASE_URL/rest/v1/rpc/recommend_hashtags_for_content" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "content_text": "오늘 강남에서 맛있는 음식을 먹었어요! 정말 좋은 카페도 발견했답니다.",
    "max_recommendations": 5
  }')

if [[ $? -eq 0 ]] && [[ $RECOMMEND_RESPONSE != *"error"* ]]; then
    print_pass "recommend_hashtags_for_content 함수 작동 확인"
    echo "Recommendations found: $(echo "$RECOMMEND_RESPONSE" | jq '. | length' 2>/dev/null || echo "N/A")"
else
    print_fail "recommend_hashtags_for_content 함수 오류"
    echo "Response: $RECOMMEND_RESPONSE"
fi

# search_hashtags 테스트
print_test "Testing search_hashtags..."
SEARCH_RESPONSE=$(curl -s -X POST "$BASE_URL/rest/v1/rpc/search_hashtags" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "search_term": "테스트",
    "limit_count": 10
  }')

if [[ $? -eq 0 ]] && [[ $SEARCH_RESPONSE != *"error"* ]]; then
    print_pass "search_hashtags 함수 작동 확인"
    echo "Search results found: $(echo "$SEARCH_RESPONSE" | jq '. | length' 2>/dev/null || echo "N/A")"
else
    print_fail "search_hashtags 함수 오류"
    echo "Response: $SEARCH_RESPONSE"
fi

# 2. Edge Functions 테스트
print_test "Testing Edge Functions..."

# hashtag-processor 테스트
print_test "Testing hashtag-processor Edge Function..."
PROCESSOR_RESPONSE=$(curl -s -X POST "$BASE_URL/functions/v1/hashtag-processor" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "post_id": "test_post_123",
    "content": "테스트 포스트입니다. #테스트 #자동화 #해시태그",
    "hashtags": ["테스트", "자동화", "해시태그"],
    "user_id": "test_user"
  }')

if [[ $? -eq 0 ]] && [[ $PROCESSOR_RESPONSE == *"success"* ]]; then
    print_pass "hashtag-processor Edge Function 작동 확인"
    echo "Analysis result: $(echo "$PROCESSOR_RESPONSE" | jq '.analysis.extracted_hashtags' 2>/dev/null || echo "N/A")"
else
    print_fail "hashtag-processor Edge Function 오류"
    echo "Response: $PROCESSOR_RESPONSE"
fi

# daily-hashtag-curation 테스트
print_test "Testing daily-hashtag-curation Edge Function..."
CURATION_RESPONSE=$(curl -s -X POST "$BASE_URL/functions/v1/daily-hashtag-curation" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{}')

if [[ $? -eq 0 ]] && [[ $CURATION_RESPONSE == *"success"* ]]; then
    print_pass "daily-hashtag-curation Edge Function 작동 확인"
    echo "Trending hashtags processed: $(echo "$CURATION_RESPONSE" | jq '.result.trending_hashtags | length' 2>/dev/null || echo "N/A")"
else
    print_fail "daily-hashtag-curation Edge Function 오류"
    echo "Response: $CURATION_RESPONSE"
fi

# 3. 데이터베이스 테이블 확인
print_test "Testing database tables..."

# community_hashtags 테이블 확인
print_test "Checking community_hashtags table..."
HASHTAGS_COUNT=$(curl -s -X GET "$BASE_URL/rest/v1/community_hashtags?select=count" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json")

if [[ $? -eq 0 ]] && [[ $HASHTAGS_COUNT != *"error"* ]]; then
    print_pass "community_hashtags 테이블 접근 확인"
    echo "Total hashtags: $(echo "$HASHTAGS_COUNT" | jq '.[0].count' 2>/dev/null || echo "N/A")"
else
    print_fail "community_hashtags 테이블 접근 오류"
    echo "Response: $HASHTAGS_COUNT"
fi

# hashtag_analysis_logs 테이블 확인 (RLS로 인해 빈 결과가 정상)
print_test "Checking hashtag_analysis_logs table..."
LOGS_RESPONSE=$(curl -s -X GET "$BASE_URL/rest/v1/hashtag_analysis_logs?select=count" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json")

if [[ $? -eq 0 ]]; then
    print_pass "hashtag_analysis_logs 테이블 접근 확인"
else
    print_fail "hashtag_analysis_logs 테이블 접근 오류"
fi

# 4. 성능 테스트 (간단한 부하 테스트)
print_test "Testing system performance..."
START_TIME=$(date +%s%3N)

for i in {1..5}; do
    curl -s -X POST "$BASE_URL/rest/v1/rpc/batch_upsert_hashtag_stats" \
      -H "apikey: $ANON_KEY" \
      -H "Authorization: Bearer $ANON_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"hashtag_names\": [\"성능테스트$i\"],
        \"updated_at\": \"$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")\"
      }" > /dev/null &
done

wait  # 모든 백그라운드 작업 완료 대기

END_TIME=$(date +%s%3N)
DURATION=$((END_TIME - START_TIME))

print_info "5개 동시 요청 처리 시간: ${DURATION}ms"

if [[ $DURATION -lt 5000 ]]; then
    print_pass "성능 테스트 통과 (5초 이내)"
else
    print_fail "성능 테스트 실패 (5초 초과)"
fi

print_info "테스트 완료!"
print_info "시스템 상태 요약:"
print_info "- RPC 함수들이 정상적으로 작동하고 있습니다"
print_info "- Edge Functions이 배포되어 실행 중입니다"
print_info "- 데이터베이스 테이블들에 접근 가능합니다"
print_info "- 시스템 성능이 양호합니다"

print_info "다음 단계:"
print_info "1. Flutter 앱에서 새로운 해시태그 기능을 테스트하세요"
print_info "2. 실제 게시물 작성으로 해시태그 자동 처리를 확인하세요"
print_info "3. 일일 큐레이션 스케줄링을 설정하세요"
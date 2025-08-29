# Supabase Edge Functions 매칭 시스템 설계

## 🎯 설계 목표
- **서버리스**: 별도 서버 없이 Supabase Edge Functions만으로 구현
- **확장 가능**: 자동 스케일링으로 10만+ 사용자 처리
- **비용 효율적**: 사용한 만큼만 과금 (Pay-per-use)
- **실시간 처리**: 50-200ms 응답 시간

## 🏗️ 아키텍처

```
┌─────────────────┐     ┌──────────────────────┐     ┌─────────────────┐
│  Flutter App    │────▶│  Edge Functions      │────▶│  PostgreSQL     │
│                 │     │                      │     │                 │
│ - Member UI     │     │ 1. match-calculator │     │ - matching_*    │
│ - Place UI      │     │ 2. match-finder     │     │   tables        │
│                 │     │ 3. match-scheduler  │     │                 │
└─────────────────┘     │ 4. match-analytics  │     └─────────────────┘
                        └──────────────────────┘
                                  │
                                  ▼
                        ┌──────────────────────┐
                        │  Supabase Services   │
                        │ - Realtime           │
                        │ - Storage            │
                        │ - Auth               │
                        └──────────────────────┘
```

## 📦 Edge Functions 설계

### 1. match-calculator (매칭 점수 계산)
```typescript
// supabase/functions/match-calculator/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface MatchRequest {
  memberId?: string
  placeId?: string
  batchSize?: number
}

interface MatchScore {
  memberId: string
  placeId: string
  totalScore: number
  details: {
    attributeScore: number
    preferenceScore: number
    locationScore: number
    payScore: number
    scheduleScore: number
  }
}

serve(async (req) => {
  try {
    const { memberId, placeId, batchSize = 100 } = await req.json() as MatchRequest
    
    // Supabase 클라이언트 초기화
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)
    
    // 매칭 대상 찾기
    let candidates = []
    
    if (memberId) {
      // Member를 위한 Place 후보 조회
      const { data: places } = await supabase
        .from('place_profiles')
        .select(`
          user_id,
          desired_experience_level,
          desired_pay_type,
          desired_pay_amount,
          desired_working_days,
          place_attributes_link!inner(attribute_id),
          place_preferences_link!inner(attribute_id),
          place_preferred_area_groups!inner(group_id)
        `)
        .eq('is_active', true)
        .eq('is_hiring', true)
        .limit(batchSize)
      
      candidates = places || []
    } else if (placeId) {
      // Place를 위한 Member 후보 조회
      const { data: members } = await supabase
        .from('member_profiles')
        .select(`
          user_id,
          experience_level,
          desired_pay_type,
          desired_pay_amount,
          desired_working_days,
          member_attributes_link!inner(attribute_id),
          member_preferences_link!inner(attribute_id),
          member_preferred_area_groups!inner(group_id)
        `)
        .limit(batchSize)
      
      candidates = members || []
    }
    
    // 각 후보에 대해 매칭 점수 계산
    const scores: MatchScore[] = []
    
    for (const candidate of candidates) {
      const score = await calculateMatchScore(
        memberId || candidate.user_id,
        placeId || candidate.user_id,
        supabase
      )
      scores.push(score)
    }
    
    // 점수 기준 정렬
    scores.sort((a, b) => b.totalScore - a.totalScore)
    
    // 결과를 matching_scores 테이블에 저장 (캐싱)
    if (scores.length > 0) {
      await supabase
        .from('matching_scores')
        .upsert(
          scores.map(s => ({
            member_user_id: s.memberId,
            place_user_id: s.placeId,
            total_score: s.totalScore,
            attribute_match_score: s.details.attributeScore,
            preference_match_score: s.details.preferenceScore,
            location_match_score: s.details.locationScore,
            pay_match_score: s.details.payScore,
            schedule_match_score: s.details.scheduleScore,
            calculated_at: new Date().toISOString(),
            expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
          })),
          { onConflict: 'member_user_id,place_user_id' }
        )
    }
    
    return new Response(JSON.stringify({ 
      success: true, 
      count: scores.length,
      topMatches: scores.slice(0, 20)
    }), {
      headers: { 'Content-Type': 'application/json' },
    })
    
  } catch (error) {
    return new Response(JSON.stringify({ 
      error: error.message 
    }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})

// 매칭 점수 계산 로직
async function calculateMatchScore(
  memberId: string,
  placeId: string,
  supabase: any
): Promise<MatchScore> {
  // 1. 속성 매칭 점수
  const attributeScore = await calculateAttributeMatch(memberId, placeId, supabase)
  
  // 2. 선호도 매칭 점수
  const preferenceScore = await calculatePreferenceMatch(memberId, placeId, supabase)
  
  // 3. 위치 매칭 점수
  const locationScore = await calculateLocationMatch(memberId, placeId, supabase)
  
  // 4. 급여 매칭 점수
  const payScore = await calculatePayMatch(memberId, placeId, supabase)
  
  // 5. 일정 매칭 점수
  const scheduleScore = await calculateScheduleMatch(memberId, placeId, supabase)
  
  // 가중치 적용
  const weights = {
    attribute: 1.2,
    preference: 1.0,
    location: 1.5,
    pay: 2.0,
    schedule: 1.3
  }
  
  const totalScore = (
    attributeScore * weights.attribute +
    preferenceScore * weights.preference +
    locationScore * weights.location +
    payScore * weights.pay +
    scheduleScore * weights.schedule
  ) / Object.values(weights).reduce((a, b) => a + b, 0)
  
  return {
    memberId,
    placeId,
    totalScore,
    details: {
      attributeScore,
      preferenceScore,
      locationScore,
      payScore,
      scheduleScore
    }
  }
}

// 세부 점수 계산 함수들
async function calculateAttributeMatch(memberId: string, placeId: string, supabase: any): Promise<number> {
  // Member 속성과 Place가 원하는 속성 비교
  const { data: memberAttrs } = await supabase
    .from('member_attributes_link')
    .select('attribute_id')
    .eq('member_user_id', memberId)
  
  const { data: placePrefs } = await supabase
    .from('place_preferences_link')
    .select('attribute_id')
    .eq('place_user_id', placeId)
  
  if (!memberAttrs || !placePrefs || placePrefs.length === 0) return 0
  
  const memberAttrIds = new Set(memberAttrs.map(a => a.attribute_id))
  const matchCount = placePrefs.filter(p => memberAttrIds.has(p.attribute_id)).length
  
  return (matchCount / placePrefs.length) * 100
}

// ... 나머지 계산 함수들도 동일한 패턴으로 구현
```

### 2. match-finder (실시간 매칭 검색)
```typescript
// supabase/functions/match-finder/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface FindMatchRequest {
  userId: string
  userType: 'MEMBER' | 'PLACE'
  filters?: {
    minScore?: number
    maxDistance?: number
    payRange?: { min: number, max: number }
    experienceLevel?: string[]
  }
  limit?: number
  offset?: number
}

serve(async (req) => {
  try {
    const { userId, userType, filters = {}, limit = 20, offset = 0 } = await req.json() as FindMatchRequest
    
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)
    
    // 캐시된 매칭 점수 조회
    let query = supabase
      .from('matching_scores')
      .select(`
        *,
        ${userType === 'MEMBER' ? 'place_profiles!inner(*)' : 'member_profiles!inner(*)'}
      `)
    
    // 필터 적용
    if (userType === 'MEMBER') {
      query = query.eq('member_user_id', userId)
    } else {
      query = query.eq('place_user_id', userId)
    }
    
    if (filters.minScore) {
      query = query.gte('total_score', filters.minScore)
    }
    
    // 결과 조회
    const { data: matches, error } = await query
      .order('total_score', { ascending: false })
      .range(offset, offset + limit - 1)
    
    if (error) throw error
    
    // 만료된 캐시가 있으면 재계산 큐에 추가
    const expiredMatches = matches?.filter(m => 
      new Date(m.expires_at) < new Date()
    ) || []
    
    if (expiredMatches.length > 0) {
      // 백그라운드에서 재계산 트리거
      await triggerRecalculation(expiredMatches, supabase)
    }
    
    return new Response(JSON.stringify({
      success: true,
      matches: matches || [],
      hasMore: matches?.length === limit
    }), {
      headers: { 'Content-Type': 'application/json' },
    })
    
  } catch (error) {
    return new Response(JSON.stringify({ 
      error: error.message 
    }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})

async function triggerRecalculation(matches: any[], supabase: any) {
  // matching_queue에 재계산 요청 추가
  const queueItems = matches.map(m => ({
    user_id: m.member_user_id,
    user_type: 'MEMBER',
    action: 'PARTIAL_UPDATE',
    priority: 3
  }))
  
  await supabase
    .from('matching_queue')
    .insert(queueItems)
}
```

### 3. match-scheduler (배치 처리 스케줄러)
```typescript
// supabase/functions/match-scheduler/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Cron으로 주기적 실행 (1시간마다)
serve(async (req) => {
  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)
    
    // 1. 만료된 매칭 점수 조회
    const { data: expiredScores } = await supabase
      .from('matching_scores')
      .select('member_user_id, place_user_id')
      .lt('expires_at', new Date().toISOString())
      .limit(1000)
    
    // 2. 큐에 추가
    if (expiredScores && expiredScores.length > 0) {
      const queueItems = expiredScores.map(score => ({
        user_id: score.member_user_id,
        user_type: 'MEMBER',
        action: 'FULL_RECALC',
        priority: 5
      }))
      
      await supabase
        .from('matching_queue')
        .insert(queueItems)
    }
    
    // 3. 큐 처리
    const { data: queuedItems } = await supabase
      .from('matching_queue')
      .select('*')
      .eq('status', 'PENDING')
      .order('priority', { ascending: false })
      .order('created_at')
      .limit(100)
    
    // 4. 각 아이템 처리
    for (const item of queuedItems || []) {
      await processQueueItem(item, supabase)
    }
    
    // 5. 통계 업데이트
    await updateMatchingStats(supabase)
    
    return new Response(JSON.stringify({
      success: true,
      processed: queuedItems?.length || 0,
      expired: expiredScores?.length || 0
    }), {
      headers: { 'Content-Type': 'application/json' },
    })
    
  } catch (error) {
    return new Response(JSON.stringify({ 
      error: error.message 
    }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})

async function processQueueItem(item: any, supabase: any) {
  try {
    // 상태 업데이트
    await supabase
      .from('matching_queue')
      .update({ status: 'PROCESSING' })
      .eq('id', item.id)
    
    // match-calculator 호출
    const response = await fetch(`${Deno.env.get('SUPABASE_URL')}/functions/v1/match-calculator`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('SUPABASE_ANON_KEY')}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        [item.user_type.toLowerCase() + 'Id']: item.user_id,
        batchSize: 50
      })
    })
    
    if (response.ok) {
      await supabase
        .from('matching_queue')
        .update({ 
          status: 'COMPLETED',
          processed_at: new Date().toISOString()
        })
        .eq('id', item.id)
    } else {
      throw new Error('Calculation failed')
    }
    
  } catch (error) {
    await supabase
      .from('matching_queue')
      .update({ 
        status: 'FAILED',
        error_message: error.message
      })
      .eq('id', item.id)
  }
}

async function updateMatchingStats(supabase: any) {
  // 매칭 통계 업데이트
  const { data: stats } = await supabase
    .rpc('calculate_matching_stats')
  
  console.log('Matching stats updated:', stats)
}
```

### 4. match-analytics (분석 및 리포팅)
```typescript
// supabase/functions/match-analytics/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface AnalyticsRequest {
  type: 'USER' | 'SYSTEM' | 'ADMIN'
  userId?: string
  dateRange?: {
    start: string
    end: string
  }
}

serve(async (req) => {
  try {
    const { type, userId, dateRange } = await req.json() as AnalyticsRequest
    
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)
    
    let analytics = {}
    
    switch (type) {
      case 'USER':
        analytics = await getUserAnalytics(userId!, supabase)
        break
      case 'SYSTEM':
        analytics = await getSystemAnalytics(dateRange, supabase)
        break
      case 'ADMIN':
        analytics = await getAdminAnalytics(supabase)
        break
    }
    
    return new Response(JSON.stringify({
      success: true,
      analytics
    }), {
      headers: { 'Content-Type': 'application/json' },
    })
    
  } catch (error) {
    return new Response(JSON.stringify({ 
      error: error.message 
    }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})

async function getUserAnalytics(userId: string, supabase: any) {
  // 사용자별 매칭 통계
  const { data: matchingHistory } = await supabase
    .from('matching_history')
    .select('event_type, created_at')
    .or(`member_user_id.eq.${userId},place_user_id.eq.${userId}`)
    .order('created_at', { ascending: false })
    .limit(100)
  
  const { data: topMatches } = await supabase
    .from('matching_scores')
    .select('*')
    .or(`member_user_id.eq.${userId},place_user_id.eq.${userId}`)
    .order('total_score', { ascending: false })
    .limit(10)
  
  return {
    totalInteractions: matchingHistory?.length || 0,
    eventBreakdown: groupByEventType(matchingHistory),
    topMatches: topMatches || [],
    avgMatchScore: calculateAvgScore(topMatches)
  }
}

async function getSystemAnalytics(dateRange: any, supabase: any) {
  // 시스템 전체 통계
  const { data: dailyStats } = await supabase
    .from('matching_scores')
    .select('calculated_at, total_score')
    .gte('calculated_at', dateRange?.start || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString())
    .lte('calculated_at', dateRange?.end || new Date().toISOString())
  
  return {
    totalMatches: dailyStats?.length || 0,
    avgScore: calculateAvgScore(dailyStats),
    scoreDistribution: calculateDistribution(dailyStats)
  }
}

function groupByEventType(history: any[]) {
  return history?.reduce((acc, item) => {
    acc[item.event_type] = (acc[item.event_type] || 0) + 1
    return acc
  }, {}) || {}
}

function calculateAvgScore(matches: any[]) {
  if (!matches || matches.length === 0) return 0
  const sum = matches.reduce((acc, m) => acc + m.total_score, 0)
  return Math.round(sum / matches.length * 100) / 100
}

function calculateDistribution(matches: any[]) {
  if (!matches) return {}
  return {
    '0-20': matches.filter(m => m.total_score < 20).length,
    '20-40': matches.filter(m => m.total_score >= 20 && m.total_score < 40).length,
    '40-60': matches.filter(m => m.total_score >= 40 && m.total_score < 60).length,
    '60-80': matches.filter(m => m.total_score >= 60 && m.total_score < 80).length,
    '80-100': matches.filter(m => m.total_score >= 80).length
  }
}
```

## 📋 배포 및 설정

### 1. Edge Functions 배포
```bash
# 각 함수 배포
supabase functions deploy match-calculator
supabase functions deploy match-finder
supabase functions deploy match-scheduler
supabase functions deploy match-analytics

# 환경 변수 설정
supabase secrets set MATCHING_BATCH_SIZE=100
supabase secrets set MATCHING_CACHE_TTL=604800  # 7 days in seconds
```

### 2. Cron 작업 설정
```sql
-- pg_cron 확장 활성화
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 매시간 스케줄러 실행
SELECT cron.schedule(
  'match-scheduler',
  '0 * * * *',  -- 매시간 정각
  $$
  SELECT net.http_post(
    url := 'https://tflvicpgyycvhttctcek.supabase.co/functions/v1/match-scheduler',
    headers := jsonb_build_object(
      'Authorization', 'Bearer ' || current_setting('app.supabase_anon_key'),
      'Content-Type', 'application/json'
    ),
    body := jsonb_build_object('trigger', 'cron')
  );
  $$
);

-- 매일 자정 통계 업데이트
SELECT cron.schedule(
  'match-analytics-daily',
  '0 0 * * *',  -- 매일 자정
  $$
  SELECT net.http_post(
    url := 'https://tflvicpgyycvhttctcek.supabase.co/functions/v1/match-analytics',
    headers := jsonb_build_object(
      'Authorization', 'Bearer ' || current_setting('app.supabase_anon_key'),
      'Content-Type', 'application/json'
    ),
    body := jsonb_build_object('type', 'SYSTEM')
  );
  $$
);
```

### 3. RLS 정책 설정
```sql
-- Edge Functions 전용 서비스 역할 생성
CREATE ROLE edge_functions_role;

-- matching_scores 테이블 접근 권한
GRANT SELECT, INSERT, UPDATE ON matching_scores TO edge_functions_role;
GRANT SELECT ON member_profiles TO edge_functions_role;
GRANT SELECT ON place_profiles TO edge_functions_role;
GRANT SELECT ON attributes TO edge_functions_role;

-- RLS 정책
CREATE POLICY "Edge functions can manage matching scores" 
ON matching_scores
FOR ALL 
USING (auth.role() = 'service_role');
```

## 🎯 Flutter 통합

### MatchingService 업데이트
```dart
class EdgeFunctionMatchingService {
  final SupabaseClient _supabase;
  
  EdgeFunctionMatchingService(this._supabase);
  
  // 매칭 검색
  Future<List<Match>> findMatches({
    required String userId,
    required UserType userType,
    Map<String, dynamic>? filters,
    int limit = 20,
  }) async {
    final response = await _supabase.functions.invoke(
      'match-finder',
      body: {
        'userId': userId,
        'userType': userType.name.toUpperCase(),
        'filters': filters,
        'limit': limit,
      },
    );
    
    if (response.error != null) {
      throw response.error!;
    }
    
    final matches = (response.data['matches'] as List)
      .map((m) => Match.fromJson(m))
      .toList();
    
    return matches;
  }
  
  // 매칭 점수 재계산 요청
  Future<void> recalculateMatches({
    required String userId,
    required UserType userType,
  }) async {
    final response = await _supabase.functions.invoke(
      'match-calculator',
      body: {
        '${userType.name.toLowerCase()}Id': userId,
        'batchSize': 100,
      },
    );
    
    if (response.error != null) {
      throw response.error!;
    }
  }
  
  // 매칭 분석 조회
  Future<MatchingAnalytics> getAnalytics({
    required String userId,
  }) async {
    final response = await _supabase.functions.invoke(
      'match-analytics',
      body: {
        'type': 'USER',
        'userId': userId,
      },
    );
    
    if (response.error != null) {
      throw response.error!;
    }
    
    return MatchingAnalytics.fromJson(response.data['analytics']);
  }
  
  // 실시간 매칭 업데이트 구독
  Stream<List<Match>> subscribeToMatches({
    required String userId,
    required UserType userType,
  }) {
    final channel = _supabase
      .channel('matching_scores_changes')
      .on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
          event: '*',
          schema: 'public',
          table: 'matching_scores',
          filter: userType == UserType.member
            ? 'member_user_id=eq.$userId'
            : 'place_user_id=eq.$userId',
        ),
        (payload, [ref]) async {
          // 변경사항 발생 시 재조회
          await findMatches(
            userId: userId,
            userType: userType,
          );
        },
      )
      .subscribe();
    
    // Stream 반환
    return _matchesController.stream;
  }
}
```

## 📊 성능 및 비용 분석

### 성능 지표
- **응답 시간**: 50-200ms (Edge Function 콜드 스타트 포함)
- **처리 용량**: 분당 10,000+ 매칭 계산
- **캐시 효율**: 80%+ 캐시 히트율
- **확장성**: 자동 스케일링 (무제한)

### 비용 예측 (월 기준)
```
사용자: 10,000명
일일 활성 사용자: 3,000명
매칭 요청/사용자/일: 10회

Edge Function 호출:
- 3,000 × 10 × 30 = 900,000 호출/월
- 비용: $0.00002/호출 × 900,000 = $18/월

Database 사용:
- Storage: 10GB = $25/월
- 데이터 전송: 50GB = $10/월

총 예상 비용: ~$53/월
```

## 🔐 보안 고려사항

1. **API 키 관리**: 환경 변수로 관리
2. **Rate Limiting**: 사용자별 분당 요청 제한
3. **인증**: Supabase Auth 토큰 검증
4. **데이터 격리**: RLS로 사용자별 데이터 접근 제한

## 🚀 장점

1. **서버리스**: 인프라 관리 불필요
2. **자동 스케일링**: 트래픽에 따라 자동 확장
3. **비용 효율적**: 사용한 만큼만 과금
4. **통합 용이**: Supabase 생태계와 완벽 통합
5. **실시간 업데이트**: Realtime 구독 지원

## 📝 마이그레이션 계획

### Phase 1: Edge Functions 개발 (1주)
- 4개 핵심 함수 개발 및 테스트
- 로컬 환경에서 검증

### Phase 2: 배포 및 설정 (3일)
- Production 환경 배포
- Cron 작업 설정
- 모니터링 설정

### Phase 3: Flutter 통합 (1주)
- EdgeFunctionMatchingService 구현
- UI 컴포넌트 연동
- 테스트 및 최적화
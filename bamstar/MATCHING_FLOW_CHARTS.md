# 🎯 BamStar Matching System Flow Charts

## 📊 System Overview

```mermaid
graph TB
    subgraph "Users"
        M[Member/Star<br/>구직자]
        P[Place<br/>사업장]
    end
    
    subgraph "Edge Functions Layer"
        EF1[match-calculator<br/>점수 계산]
        EF2[match-finder<br/>매칭 검색]
        EF3[hearts-manager<br/>좋아요 관리]
        EF4[favorites-manager<br/>즐겨찾기]
        EF5[batch-processor<br/>배치 처리]
    end
    
    subgraph "Database Layer"
        subgraph "Profile Data"
            MP[member_profiles]
            PP[place_profiles]
            MA[member_attributes]
            PA[place_attributes]
        end
        
        subgraph "Matching Data"
            MS[matching_scores<br/>7-day cache]
            MW[matching_weights]
            MF[matching_filters]
            MQ[matching_queue]
        end
        
        subgraph "Interaction Data"
            MH[member_hearts]
            PH[place_hearts]
            MFV[member_favorites]
            PFV[place_favorites]
            MM[mutual_matches<br/>VIEW]
        end
    end
    
    M -->|검색| EF2
    P -->|검색| EF2
    
    EF2 -->|캐시 조회| MS
    EF2 -->|없으면| EF1
    
    M -->|좋아요| EF3
    P -->|좋아요| EF3
    
    EF3 -->|저장| MH
    EF3 -->|저장| PH
    EF3 -->|확인| MM
    
    M -->|즐겨찾기| EF4
    P -->|즐겨찾기| EF4
    
    EF4 -->|저장| MFV
    EF4 -->|저장| PFV
    
    EF5 -->|주기적| MQ
    EF5 -->|계산| EF1
    
    EF1 -->|조회| MP
    EF1 -->|조회| PP
    EF1 -->|저장| MS
```

---

## 🔄 Matching Score Calculation Flow

```mermaid
sequenceDiagram
    participant U as User
    participant MF as match-finder
    participant MC as match-calculator
    participant DB as Database
    participant C as Cache

    U->>MF: 매칭 요청
    MF->>C: 캐시 확인
    
    alt 캐시 있음
        C-->>MF: 캐시된 점수
        MF-->>U: 즉시 반환 (<10ms)
    else 캐시 없음
        MF->>MC: 점수 계산 요청
        
        par 병렬 데이터 조회
            MC->>DB: Member 데이터
            DB-->>MC: Profile + Attributes
        and
            MC->>DB: Place 데이터
            DB-->>MC: Profile + Attributes
        end
        
        MC->>MC: 6개 카테고리 점수 계산
        Note over MC: 1. Job Role (40%)<br/>2. Industry (20%)<br/>3. Style (15%)<br/>4. Location (15%)<br/>5. Pay (10%)<br/>6. Welfare (Bonus)
        
        MC->>DB: 가중치 조회
        DB-->>MC: User weights
        
        MC->>MC: 총점 계산
        MC->>C: 캐시 저장 (7일)
        MC->>DB: DB 저장
        
        MC-->>MF: 계산된 점수
        MF-->>U: 결과 반환 (<200ms)
    end
```

---

## 💝 Hearts (좋아요) Interaction Flow

```mermaid
stateDiagram-v2
    [*] --> 좋아요_보내기
    
    좋아요_보내기 --> 단방향_좋아요: 상대방 미응답
    좋아요_보내기 --> 상호_매칭: 상대방도 좋아요
    
    단방향_좋아요 --> 알림_발송
    알림_발송 --> 응답_대기
    
    응답_대기 --> 수락: Accept
    응답_대기 --> 거절: Reject
    응답_대기 --> 무응답: Timeout
    
    수락 --> 상호_매칭
    거절 --> [*]
    무응답 --> [*]
    
    상호_매칭 --> 채팅_활성화
    채팅_활성화 --> 연락처_공개
    연락처_공개 --> 면접_진행
```

### Detailed Hearts Flow

```mermaid
graph LR
    subgraph "Member Side"
        M1[Member 프로필 보기]
        M2[♥ 좋아요 클릭]
        M3[member_hearts 저장]
    end
    
    subgraph "System Check"
        S1{상대방도<br/>좋아요?}
        S2[place_hearts 확인]
        S3[상호 매칭!]
        S4[단방향 좋아요]
    end
    
    subgraph "Place Side"
        P1[알림 수신]
        P2[프로필 확인]
        P3[수락/거절]
    end
    
    subgraph "Mutual Match"
        MM1[채팅방 생성]
        MM2[양방향 알림]
        MM3[연락 가능]
    end
    
    M1 --> M2
    M2 --> M3
    M3 --> S2
    S2 --> S1
    S1 -->|Yes| S3
    S1 -->|No| S4
    S4 --> P1
    P1 --> P2
    P2 --> P3
    P3 -->|Accept| S3
    S3 --> MM1
    MM1 --> MM2
    MM2 --> MM3
```

---

## ⭐ Favorites (즐겨찾기) Flow

```mermaid
graph TD
    subgraph "즐겨찾기 특징"
        F1[알림 없음<br/>Private]
        F2[메모 가능]
        F3[나중에 확인]
        F4[일괄 관리]
    end
    
    subgraph "Member 즐겨찾기"
        MA[Place 목록 보기]
        MB[⭐ 클릭]
        MC[member_favorites 저장]
        MD[메모 입력<br/>선택사항]
        ME[즐겨찾기 목록]
    end
    
    subgraph "Place 즐겨찾기"
        PA[Member 목록 보기]
        PB[⭐ 클릭]
        PC[place_favorites 저장]
        PD[메모 입력<br/>인재풀 관리]
        PE[인재풀 목록]
    end
    
    MA --> MB --> MC --> MD --> ME
    PA --> PB --> PC --> PD --> PE
    
    ME -->|정기 확인| MA
    PE -->|채용 시| PA
```

---

## 📍 Location-based Matching Logic

```mermaid
graph TD
    subgraph "Member Preferences"
        MP1[선호 지역 1<br/>강남구 역삼동]
        MP2[선호 지역 2<br/>강남구 삼성동]
        MP3[선호 지역 3<br/>서초구 서초동]
    end
    
    subgraph "Place Location"
        PL1[좌표<br/>37.5, 127.0]
        PL2[주소 → area_group_id]
        PL3[강남구 논현동<br/>group_id: 15]
    end
    
    subgraph "Matching Score"
        MS1{같은 area_group?}
        MS2{같은 category?}
        MS3{다른 지역?}
        
        S100[100점<br/>정확히 일치]
        S70[70점<br/>같은 카테고리]
        S30[30점<br/>다른 지역]
    end
    
    MP1 --> MS1
    MP2 --> MS1
    MP3 --> MS1
    PL3 --> MS1
    
    MS1 -->|Yes| S100
    MS1 -->|No| MS2
    MS2 -->|Yes| S70
    MS2 -->|No| MS3
    MS3 --> S30
```

---

## 🔄 Batch Processing Flow

```mermaid
sequenceDiagram
    participant Cron as Cron Job
    participant BP as batch-processor
    participant Q as matching_queue
    participant MC as match-calculator
    participant DB as Database
    
    Cron->>BP: 5분마다 실행
    BP->>Q: 대기 항목 조회
    Q-->>BP: Pending items
    
    loop For each item
        BP->>Q: Status = processing
        BP->>MC: 점수 계산 요청
        
        par 병렬 처리
            MC->>DB: Calculate score 1
        and
            MC->>DB: Calculate score 2
        and
            MC->>DB: Calculate score 3
        end
        
        MC-->>BP: 계산 완료
        BP->>Q: Status = completed
    end
    
    BP->>DB: 통계 업데이트
    Note over BP: Processed: 100<br/>Success: 98<br/>Failed: 2
```

---

## 👤 User Journey - Member (Star)

```mermaid
journey
    title Member 사용자 여정
    
    section 가입 및 설정
      회원가입: 5: Member
      프로필 작성: 4: Member
      스킬 선택: 5: Member
      선호지역 설정: 4: Member
    
    section 매칭 탐색
      매칭 리스트 확인: 5: Member
      점수 상세 보기: 5: Member
      필터 적용: 4: Member
      프로필 상세 확인: 5: Member
    
    section 관심 표현
      좋아요 보내기: 5: Member
      즐겨찾기 추가: 4: Member
      응답 대기: 3: Member
      매칭 성립: 5: Member, Place
    
    section 커뮤니케이션
      채팅 시작: 5: Member, Place
      면접 일정 조율: 4: Member, Place
      면접 진행: 4: Member, Place
      최종 결과: 5: Member, Place
```

---

## 🏢 User Journey - Place

```mermaid
journey
    title Place 사용자 여정
    
    section 사업장 등록
      사업자 가입: 5: Place
      사업장 정보 입력: 4: Place
      사업자등록증 업로드: 4: Place
      AI 검증: 5: System
      승인 완료: 5: Place
    
    section 조건 설정
      필요 직무 선택: 5: Place
      제공 급여 입력: 4: Place
      복지 혜택 설정: 4: Place
      선호 스타일 선택: 4: Place
    
    section 인재 탐색
      매칭 리스트 확인: 5: Place
      프로필 검토: 5: Place
      경력 확인: 4: Place
      스킬 매칭 확인: 5: Place
    
    section 채용 프로세스
      좋아요 보내기: 5: Place
      인재풀 관리: 4: Place
      매칭 성립: 5: Member, Place
      면접 진행: 4: Member, Place
      채용 결정: 5: Place
```

---

## 📊 Performance Metrics Dashboard

```mermaid
graph LR
    subgraph "Real-time Metrics"
        RT1[응답시간<br/>< 200ms]
        RT2[캐시 히트율<br/>> 85%]
        RT3[동시 사용자<br/>10,000+]
        RT4[일일 매칭<br/>100,000+]
    end
    
    subgraph "Business Metrics"
        BM1[매칭 정확도<br/>> 75%]
        BM2[전환율<br/>> 15%]
        BM3[사용자 만족도<br/>> 4.5/5]
        BM4[월 성장률<br/>> 20%]
    end
    
    subgraph "Cost Metrics"
        CM1[월 비용<br/>< $100]
        CM2[요청당 비용<br/>$0.002]
        CM3[인프라 비용<br/>$53/월]
        CM4[ROI<br/>566x]
    end
```

---

## 🚀 Migration Timeline

```mermaid
gantt
    title BamStar Matching System Migration
    dateFormat  YYYY-MM-DD
    
    section Phase 1 - Database
    Create Place tables           :done, db1, 2024-01-01, 1d
    Create Interaction tables     :done, db2, after db1, 1d
    Create Matching tables        :active, db3, after db2, 1d
    Create Functions & Indexes    :db4, after db3, 1d
    
    section Phase 2 - Edge Functions
    Develop match-calculator      :ef1, after db4, 2d
    Develop match-finder          :ef2, after db4, 2d
    Develop hearts-manager        :ef3, after ef1, 1d
    Develop favorites-manager     :ef4, after ef2, 1d
    Deploy to Supabase           :ef5, after ef4, 1d
    
    section Phase 3 - Flutter
    Update Place screens          :fl1, after ef5, 2d
    Create matching services      :fl2, after fl1, 2d
    Implement hearts/favorites    :fl3, after fl2, 1d
    Update UI components          :fl4, after fl3, 1d
    
    section Phase 4 - Testing
    Unit testing                  :test1, after fl4, 1d
    Load testing (100K records)   :test2, after test1, 1d
    User acceptance testing       :test3, after test2, 2d
    Performance optimization      :test4, after test3, 1d
    
    section Phase 5 - Deployment
    Staging deployment            :dep1, after test4, 1d
    Production deployment         :dep2, after dep1, 1d
    Monitoring setup              :dep3, after dep2, 1d
```

---

## 🎯 Success Criteria

```mermaid
graph TD
    subgraph "Technical Success"
        TS1[✓ < 200ms response]
        TS2[✓ 100K records/batch]
        TS3[✓ 85% cache hit]
        TS4[✓ Zero downtime]
    end
    
    subgraph "Business Success"
        BS1[✓ 75% match accuracy]
        BS2[✓ 15% conversion rate]
        BS3[✓ 4.5/5 satisfaction]
        BS4[✓ 20% monthly growth]
    end
    
    subgraph "Cost Success"
        CS1[✓ < $100/month]
        CS2[✓ 566x cost reduction]
        CS3[✓ Serverless scaling]
        CS4[✓ No dedicated server]
    end
    
    TS1 & TS2 & TS3 & TS4 --> SUCCESS
    BS1 & BS2 & BS3 & BS4 --> SUCCESS
    CS1 & CS2 & CS3 & CS4 --> SUCCESS
    
    SUCCESS[🎉 Project Success]
```
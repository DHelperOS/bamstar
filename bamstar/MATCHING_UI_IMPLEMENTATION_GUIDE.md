# 📱 BamStar 매칭 시스템 구현 가이드

## 🎯 핵심 원칙
- **Member(스타)는 Place(플레이스)만 조회 가능**
- **Place(플레이스)는 Member(스타)만 조회 가능**
- **채팅 탭은 제외** (이미 네비게이션바에 존재)

## 📊 시스템 아키텍처

```
┌────────────────────────────────────────┐
│          BamStar 매칭 시스템           │
├────────────────────────────────────────┤
│     Navigation Bar (Bottom)            │
├────┬────┬────┬────┬────────────────────┤
│추천│탐색│지도│하트│즐겨찾기         │
└────┴────┴────┴────┴────────────────────┘
```

## 🗂️ 탭 구조 상세 설계

### 1️⃣ 추천 탭 (AI 매칭)

#### **기능 명세**
- AI 매칭 점수 기반 카드 스와이프
- Member → Place 프로필만 표시
- Place → Member 프로필만 표시

#### **카드 디자인**
```
┌─────────────────────────────────┐
│        [프로필 이미지]          │
│         ● ● ○ ○ ○              │ ← 이미지 인디케이터
├─────────────────────────────────┤
│ 매칭점수: 92점 ⭐⭐⭐⭐⭐         │
├─────────────────────────────────┤
│ [FOR MEMBER VIEW]               │
│ 카페 델라루나 | 강남점          │
│ 📍 강남구 역삼동 (2.3km)       │
│ 💰 시급 13,000-15,000원        │
│ 📅 평일/주말 협의가능          │
│ 🏷️ #라떼아트교육 #식사제공    │
├─────────────────────────────────┤
│ [FOR PLACE VIEW]                │
│ 김민수 | 바리스타 3년차        │
│ 📍 강남구 거주                 │
│ 💰 희망시급 15,000원           │
│ 📅 평일 오전 가능              │
│ 🏷️ #라떼아트 #로스팅자격증    │
├─────────────────────────────────┤
│   ❌      ⭐      ❤️      👁️   │
│  패스  즐겨찾기  좋아요   상세  │
└─────────────────────────────────┘
```

#### **제스처 인터랙션**
```dart
// 스와이프 액션 정의
onHorizontalDragEnd: (details) {
  if (details.velocity.pixelsPerSecond.dx > threshold) {
    // 오른쪽 스와이프 → 좋아요
    _sendLike(currentProfile);
  } else if (details.velocity.pixelsPerSecond.dx < -threshold) {
    // 왼쪽 스와이프 → 패스
    _passProfile(currentProfile);
  }
}

onVerticalDragEnd: (details) {
  if (details.velocity.pixelsPerSecond.dy < -threshold) {
    // 위로 스와이프 → 즐겨찾기
    _addToFavorites(currentProfile);
  }
}
```

### 2️⃣ 탐색 탭 (필터링 검색)

#### **필터 시스템**
```
┌─────────────────────────────────┐
│      🔍 스마트 필터 프리셋      │
├─────────────────────────────────┤
│ [🔥 오늘의 추천] [📍 내 지역]  │
│ [💎 프리미엄] [🚀 즉시 가능]   │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│      ⚙️ 상세 필터              │
├─────────────────────────────────┤
│ 📍 지역: [강남구 ▼] + 2km     │
│ 💰 급여: ₩12,000 ━━━●━━ ₩20,000│
│ 📊 경력: [신입] [1-3년] [3년+] │
│ 🕐 시간: [오전] [오후] [저녁]  │
│ 🏢 업종: [카페] [음식점] [판매]│
└─────────────────────────────────┘
```

#### **그리드/리스트 토글**
```dart
// 보기 모드 전환
enum ViewMode { grid, list }

Widget _buildSearchResults() {
  return viewMode == ViewMode.grid 
    ? _buildGridView()  // 3열 그리드
    : _buildListView(); // 상세 리스트
}
```

### 3️⃣ 지도 탭 (내 주변)

#### **구현 가능성: ✅ 완전 가능**

##### **기술 스택**
1. **Flutter**: `google_maps_flutter` 패키지
2. **Supabase**: PostGIS 확장 (이미 latitude/longitude 필드 존재)
3. **실시간 위치**: `geolocator` 패키지

##### **구현 방법**

```dart
// 1. 위치 권한 요청
import 'package:geolocator/geolocator.dart';

Future<Position> _getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  
  return await Geolocator.getCurrentPosition();
}
```

```dart
// 2. 지도 위젯 구현
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearbyMapTab extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(currentLat, currentLng),
        zoom: 14.0,
      ),
      markers: _markers,
      circles: {
        Circle(
          circleId: CircleId('searchRadius'),
          center: LatLng(currentLat, currentLng),
          radius: searchRadius * 1000, // km to meters
          fillColor: Colors.blue.withOpacity(0.1),
          strokeColor: Colors.blue,
        ),
      },
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        _loadNearbyMatches();
      },
    );
  }
}
```

```sql
-- 3. PostGIS 쿼리 (Supabase)
CREATE OR REPLACE FUNCTION find_nearby_matches(
  p_user_id UUID,
  p_user_type TEXT,
  p_lat DOUBLE PRECISION,
  p_lng DOUBLE PRECISION,
  p_radius_km INTEGER DEFAULT 5
) RETURNS TABLE (
  match_id UUID,
  match_name TEXT,
  match_type TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  distance_km DOUBLE PRECISION,
  matching_score DECIMAL
) AS $$
BEGIN
  IF p_user_type = 'MEMBER' THEN
    -- Member는 Place만 조회
    RETURN QUERY
    SELECT 
      pp.user_id,
      pp.place_name,
      'PLACE'::TEXT,
      pp.latitude,
      pp.longitude,
      ST_Distance(
        ST_MakePoint(pp.longitude, pp.latitude)::geography,
        ST_MakePoint(p_lng, p_lat)::geography
      ) / 1000 AS distance_km,
      ms.total_score
    FROM place_profiles pp
    LEFT JOIN matching_scores ms ON 
      ms.place_user_id = pp.user_id AND 
      ms.member_user_id = p_user_id
    WHERE ST_DWithin(
      ST_MakePoint(pp.longitude, pp.latitude)::geography,
      ST_MakePoint(p_lng, p_lat)::geography,
      p_radius_km * 1000
    )
    ORDER BY distance_km ASC;
  ELSE
    -- Place는 Member만 조회
    -- Member는 정확한 주소가 아닌 선호 지역만 있으므로
    -- areas 테이블과 조인하여 대략적 위치 표시
    RETURN QUERY
    SELECT 
      mp.user_id,
      u.nickname,
      'MEMBER'::TEXT,
      a.latitude,  -- 지역 중심점
      a.longitude, -- 지역 중심점
      ST_Distance(
        ST_MakePoint(a.longitude, a.latitude)::geography,
        ST_MakePoint(p_lng, p_lat)::geography
      ) / 1000 AS distance_km,
      ms.total_score
    FROM member_profiles mp
    JOIN users u ON mp.user_id = u.id
    JOIN member_preferred_area_groups mpag ON mp.user_id = mpag.member_user_id
    JOIN areas a ON mpag.area_id = a.id
    LEFT JOIN matching_scores ms ON 
      ms.member_user_id = mp.user_id AND 
      ms.place_user_id = p_user_id
    WHERE ST_DWithin(
      ST_MakePoint(a.longitude, a.latitude)::geography,
      ST_MakePoint(p_lng, p_lat)::geography,
      p_radius_km * 1000
    )
    ORDER BY distance_km ASC;
  END IF;
END;
$$ LANGUAGE plpgsql;
```

##### **지도 UI 디자인**
```
┌─────────────────────────────────┐
│    📍 내 위치 주변 5km          │
│ ┌─────────────────────────────┐ │
│ │                             │ │
│ │         [Google Map]        │ │
│ │     📍(나)                  │ │
│ │   🏢  🏢   🏢              │ │ ← Place 마커
│ │     🏢   🏢                │ │
│ │   👤  👤     👤            │ │ ← Member 마커
│ │                             │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ 반경: [1km][3km][5km][10km] │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ 📍 카페 델라루나 (0.5km)    │ │
│ │    매칭도 89% | 시급 15,000 │ │
│ ├─────────────────────────────┤ │
│ │ 📍 스타벅스 역삼점 (0.8km)  │ │
│ │    매칭도 85% | 시급 13,000 │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

##### **마커 클러스터링**
```dart
// 많은 마커 처리를 위한 클러스터링
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';

class PlaceClusterItem extends ClusterItem {
  final String placeId;
  final String placeName;
  final LatLng position;
  final int matchingScore;
  
  PlaceClusterItem({
    required this.placeId,
    required this.placeName,
    required this.position,
    required this.matchingScore,
  });
}

// 클러스터 매니저 설정
ClusterManager<PlaceClusterItem> _clusterManager = ClusterManager(
  items,
  _updateMarkers,
  markerBuilder: _markerBuilder,
  levels: [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5, 20.0],
);
```

### 4️⃣ 하트 탭 (좋아요 관리)

#### **탭 구조**
```
┌─────────────────────────────────┐
│  받은(3) │ 보낸(5) │ 매칭(2)  │
├─────────────────────────────────┤
│ [받은 좋아요 리스트]            │
│ ┌─────────────────────────────┐ │
│ │ 🆕 카페 델라루나            │ │
│ │ 2분 전 | 매칭도 92%         │ │
│ │ [수락] [거절] [프로필 보기] │ │
│ ├─────────────────────────────┤ │
│ │ 스타벅스 강남점             │ │
│ │ 1시간 전 | 매칭도 87%       │ │
│ │ [수락] [거절] [프로필 보기] │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

#### **상태 관리**
```dart
// 좋아요 상태 enum
enum HeartStatus {
  pending,   // 대기중
  accepted,  // 수락됨 (상호 매칭)
  rejected,  // 거절됨
  expired    // 만료됨 (7일 후)
}

// 실시간 업데이트
StreamBuilder<List<Heart>>(
  stream: supabase
    .from(userType == UserType.member ? 'place_hearts' : 'member_hearts')
    .stream(primaryKey: ['id'])
    .eq(userType == UserType.member 
      ? 'member_user_id' 
      : 'place_user_id', currentUserId),
  builder: (context, snapshot) {
    // UI 업데이트
  }
);
```

### 5️⃣ 즐겨찾기 탭

#### **폴더 시스템**
```
┌─────────────────────────────────┐
│ 📁 전체 (12) │ + 새 폴더       │
├─────────────────────────────────┤
│ 📁 관심있음 (5)                │
│ 📁 면접예정 (3)                │
│ 📁 보류 (4)                    │
├─────────────────────────────────┤
│ [즐겨찾기 프로필 그리드]        │
└─────────────────────────────────┘
```

## 🔐 단방향 매칭 로직

### **핵심 규칙**
```typescript
// Edge Function: match-finder
if (userType === 'MEMBER') {
  // Member는 Place만 조회
  query = query.from('place_profiles')
} else if (userType === 'PLACE') {
  // Place는 Member만 조회
  query = query.from('member_profiles')
}
```

### **Flutter 구현**
```dart
class MatchingService {
  final UserType currentUserType;
  
  Future<List<Profile>> getMatchingProfiles() async {
    if (currentUserType == UserType.member) {
      // Place 프로필만 반환
      return await _fetchPlaceProfiles();
    } else {
      // Member 프로필만 반환
      return await _fetchMemberProfiles();
    }
  }
  
  // 프로필 타입 체크
  bool isValidProfileType(Profile profile) {
    if (currentUserType == UserType.member) {
      return profile.type == ProfileType.place;
    } else {
      return profile.type == ProfileType.member;
    }
  }
}
```

## 📱 Flutter 구현 구조

### **디렉토리 구조**
```
lib/
├── screens/
│   └── matching/
│       ├── matching_screen.dart          # 메인 컨테이너
│       ├── tabs/
│       │   ├── recommendation_tab.dart   # 추천 탭
│       │   ├── search_tab.dart          # 탐색 탭
│       │   ├── map_tab.dart             # 지도 탭
│       │   ├── hearts_tab.dart          # 하트 탭
│       │   └── favorites_tab.dart       # 즐겨찾기 탭
│       ├── widgets/
│       │   ├── matching_card.dart       # 매칭 카드
│       │   ├── filter_sheet.dart        # 필터 바텀시트
│       │   ├── profile_modal.dart       # 상세 프로필
│       │   └── map_marker.dart          # 지도 마커
│       └── services/
│           ├── matching_service.dart     # 매칭 로직
│           ├── location_service.dart     # 위치 서비스
│           └── heart_service.dart        # 좋아요 관리
```

### **상태 관리 (Riverpod)**
```dart
// 매칭 프로필 Provider
final matchingProfilesProvider = StreamProvider.family<List<Profile>, UserType>(
  (ref, userType) async* {
    final supabase = ref.read(supabaseProvider);
    
    yield* supabase.functions
      .invoke('match-finder', body: {
        'userId': currentUserId,
        'userType': userType.name,
      })
      .asStream()
      .map((response) => Profile.fromJsonList(response.data));
  },
);

// 위치 Provider
final currentLocationProvider = FutureProvider<Position>((ref) async {
  return await Geolocator.getCurrentPosition();
});

// 필터 상태 Provider
final filterStateProvider = StateNotifierProvider<FilterNotifier, FilterState>(
  (ref) => FilterNotifier(),
);
```

## 🎨 UI/UX 가이드라인

### **색상 시스템**
```dart
// 매칭 점수별 색상
Color getScoreColor(double score) {
  if (score >= 90) return Colors.green;      // 90+ 최고 매칭
  if (score >= 70) return Colors.amber;      // 70+ 좋은 매칭
  if (score >= 50) return Colors.orange;     // 50+ 보통 매칭
  return Colors.grey;                        // 50- 낮은 매칭
}

// 액션 버튼 색상
const heartColor = Color(0xFFFF6B6B);        // 좋아요
const starColor = Color(0xFFFFD93D);         // 즐겨찾기
const passColor = Color(0xFF95A5A6);         // 패스
```

### **애니메이션**
```dart
// 카드 스와이프 애니메이션
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeOutBack,
  transform: Matrix4.identity()
    ..rotateZ(_swipeAngle)
    ..translate(_swipeOffset.dx, _swipeOffset.dy),
  child: MatchingCard(),
);

// 좋아요 하트 애니메이션
AnimatedScale(
  scale: _isLiked ? 1.2 : 1.0,
  duration: Duration(milliseconds: 200),
  child: Icon(Icons.favorite, color: heartColor),
);
```

## 📊 데이터베이스 쿼리 최적화

### **인덱스 추가**
```sql
-- 지도 검색용 공간 인덱스
CREATE INDEX idx_place_location 
ON place_profiles 
USING GIST (ST_MakePoint(longitude, latitude));

-- 매칭 점수 조회 최적화
CREATE INDEX idx_matching_scores_member_sorted 
ON matching_scores(member_user_id, total_score DESC)
WHERE expires_at > NOW();

CREATE INDEX idx_matching_scores_place_sorted 
ON matching_scores(place_user_id, total_score DESC)
WHERE expires_at > NOW();
```

### **캐싱 전략**
```dart
// 메모리 캐싱
class MatchingCache {
  static final Map<String, List<Profile>> _cache = {};
  static final Map<String, DateTime> _cacheTime = {};
  
  static const Duration cacheValidDuration = Duration(minutes: 5);
  
  static List<Profile>? get(String key) {
    if (_cacheTime[key] != null) {
      if (DateTime.now().difference(_cacheTime[key]!) < cacheValidDuration) {
        return _cache[key];
      }
    }
    return null;
  }
  
  static void set(String key, List<Profile> data) {
    _cache[key] = data;
    _cacheTime[key] = DateTime.now();
  }
}
```

## 🚀 구현 우선순위

### **Phase 1: 핵심 기능 (Week 1)**
1. ✅ 추천 탭 (카드 스와이프)
2. ✅ 단방향 매칭 로직
3. ✅ 좋아요/패스 기능

### **Phase 2: 탐색 기능 (Week 2)**
1. ✅ 탐색 탭 (필터링)
2. ✅ 하트 탭 (좋아요 관리)
3. ✅ 즐겨찾기 기능

### **Phase 3: 지도 기능 (Week 3)**
1. ✅ 지도 탭 구현
2. ✅ 위치 기반 검색
3. ✅ 마커 클러스터링

### **Phase 4: 최적화 (Week 4)**
1. ✅ 성능 최적화
2. ✅ 애니메이션 개선
3. ✅ 사용성 테스트

## 📈 성공 지표

### **기술 지표**
- 매칭 쿼리 응답: < 200ms
- 지도 마커 로딩: < 1초
- 앱 크래시율: < 0.1%

### **사용자 지표**
- 첫 매칭까지: < 3분
- 일일 활성 사용자: > 60%
- 좋아요 전환율: > 20%

## 🔑 핵심 차별화 포인트

1. **단방향 매칭**: Member↔Place 명확한 구분
2. **지도 기반 탐색**: 실제 거리 고려한 현실적 매칭
3. **투명한 점수**: 매칭 이유를 명확히 표시
4. **즐겨찾기 시스템**: 부담 없는 관심 표현
5. **실시간 업데이트**: Supabase Realtime 활용

이 구현 가이드는 **기술적 실현 가능성**과 **사용자 경험**을 모두 고려하여 작성되었습니다.

모든 기능은 현재 Supabase 인프라와 Flutter 생태계에서 **100% 구현 가능**하며, 특히 지도 기능은 PostGIS와 Google Maps를 활용하여 **고성능 위치 기반 서비스**를 제공할 수 있습니다.
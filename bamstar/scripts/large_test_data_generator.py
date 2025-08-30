#!/usr/bin/env python3
"""
BamStar 대량 테스트 데이터 생성기
- 스타 50명, 플레이스 30명 생성
- 실제 밤알바 업종 및 특성 반영
- 기존 attributes 데이터 활용
"""

import json
import random
from datetime import datetime, date, timedelta
import psycopg2
import uuid

# DB 연결 설정
DB_CONNECTION = "postgresql://postgres.tflvicpgyycvhttctcek:!@Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres"

def get_existing_attributes():
    """기존 attributes 데이터 조회"""
    conn = psycopg2.connect(DB_CONNECTION)
    cur = conn.cursor()
    
    cur.execute("SELECT id, type, name, description FROM attributes WHERE is_active = true")
    attributes = cur.fetchall()
    
    # 타입별로 분류
    attr_by_type = {}
    for attr in attributes:
        attr_id, attr_type, name, desc = attr
        if attr_type not in attr_by_type:
            attr_by_type[attr_type] = []
        attr_by_type[attr_type].append({"id": attr_id, "name": name, "desc": desc})
    
    cur.close()
    conn.close()
    
    return attr_by_type

def get_existing_auth_users():
    """기존 auth.users ID 조회"""
    conn = psycopg2.connect(DB_CONNECTION)
    cur = conn.cursor()
    
    cur.execute("SELECT id FROM auth.users WHERE email LIKE 'bamstar%@example.com' ORDER BY email")
    users = [row[0] for row in cur.fetchall()]
    
    cur.close()
    conn.close()
    
    return users

# 한국 이름 데이터
KOREAN_SURNAMES = ["김", "이", "박", "최", "정", "강", "조", "윤", "장", "임", "오", "한", "신", "서", "권", "황", "안", "송", "전", "홍"]
KOREAN_MALE_NAMES = ["민준", "서준", "도윤", "예준", "시우", "주원", "하준", "지호", "건우", "우진", "선우", "연우", "현우", "정우", "승우", "민재", "재윤", "유준", "승현", "승민"]
KOREAN_FEMALE_NAMES = ["서윤", "서연", "지우", "서현", "민서", "하은", "지유", "예은", "채원", "지민", "다은", "수아", "소율", "예린", "시은", "유나", "윤서", "예원", "유진", "사랑"]

# 밤알바 플레이스 이름 템플릿
PLACE_NAMES = [
    # 강남 지역
    "강남 프리미엄 모던 바", "압구정 럭셔리 토크 바", "신사동 VIP 캐주얼 펍", "청담 골든 가라오케", "역삼 다이아몬드 카페",
    "서초 플래티넘 테라피", "강남역 로얄 클럽", "압구정역 엘리트 바", "신논현 프라임 펍", "교대역 크라운 카페",
    
    # 홍대 지역  
    "홍대 로얄 토크 바", "상수동 프리미엄 펍", "합정역 모던 카페", "홍익대 골든 바", "상수역 다이아몬드 클럽",
    "홍대입구 플래티넘 가라오케", "마포구 크리스탈 테라피", "상수동 엘리트 펍", "홍대거리 프라임 바", "합정동 로얄 카페",
    
    # 강서/강북 지역
    "강서 프리미엄 바", "노원구 모던 펙", "강북구 럭셔리 카페", "은평구 VIP 토크 바", "중랑구 골든 테라피",
    "도봉구 다이아몬드 펍", "강북역 플래티넘 클럽", "수유역 크리스탈 바", "미아역 프라임 카페", "성북구 엘리트 가라오케"
]

# 업종별 특성
BUSINESS_TYPES = {
    "모던 바": {"pay_min": 3500000, "pay_max": 6500000, "features": ["고급스러운", "경력자우대", "텃세없음"]},
    "토크 바": {"pay_min": 3200000, "pay_max": 5800000, "features": ["가족같은", "초보환영", "편안한"]},
    "캐주얼 펍": {"pay_min": 2800000, "pay_max": 5200000, "features": ["자유복장", "친구랑같이", "파티분위기"]},
    "가라오케": {"pay_min": 2500000, "pay_max": 4800000, "features": ["야간근무", "주말근무", "유연근무"]},
    "카페": {"pay_min": 2300000, "pay_max": 4200000, "features": ["초보환영", "편안한", "자유복장"]},
    "테라피": {"pay_min": 4200000, "pay_max": 8500000, "features": ["고급스러운", "경력자우대", "전문기술"]}
}

def generate_large_test_data():
    """대량 테스트 데이터 생성"""
    
    # 기존 데이터 조회
    attributes = get_existing_attributes()
    auth_user_ids = get_existing_auth_users()
    
    if len(auth_user_ids) < 80:
        print("❌ auth.users가 부족합니다. 최소 80명 필요")
        return
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # SQL 파일 생성
    sql_content = f"""-- BamStar 대량 테스트 데이터 삽입
-- 생성일: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
-- 스타 50명, 플레이스 30명

BEGIN;

-- 1. 사용자 데이터 (스타 50명 + 플레이스 30명)
"""
    
    # 스타 사용자 50명 생성
    star_users = []
    for i in range(50):
        auth_id = auth_user_ids[i]
        surname = random.choice(KOREAN_SURNAMES)
        gender = random.choice(['MALE', 'FEMALE'])
        if gender == 'MALE':
            given_name = random.choice(KOREAN_MALE_NAMES)
        else:
            given_name = random.choice(KOREAN_FEMALE_NAMES)
        
        real_name = surname + given_name
        nickname = f"스타#{i+1}"
        
        star_users.append({
            'auth_id': auth_id,
            'nickname': nickname,
            'real_name': real_name,
            'gender': gender,
            'role_id': 2  # STAR
        })
        
        sql_content += f"""
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES ('{auth_id}', '{nickname}', 'bamstar{i+1}@example.com', '010-{1000+i:04d}-{random.randint(1000,9999)}', 2, true, NOW() - INTERVAL '{random.randint(1,180)} days', NOW());
"""
    
    # 플레이스 사용자 30명 생성
    place_users = []
    for i in range(30):
        auth_id = auth_user_ids[50 + i]
        place_name = random.choice(PLACE_NAMES)
        nickname = f"플레이스#{i+1}"
        
        place_users.append({
            'auth_id': auth_id,
            'nickname': nickname,
            'place_name': place_name,
            'role_id': 3  # PLACE
        })
        
        sql_content += f"""
INSERT INTO users (id, nickname, email, phone_number, role_id, is_active, created_at, updated_at)
VALUES ('{auth_id}', '{nickname}', 'bamstar{50+i+1}@example.com', '010-{2000+i:04d}-{random.randint(1000,9999)}', 3, true, NOW() - INTERVAL '{random.randint(1,180)} days', NOW());
"""
    
    # 2. 스타 프로필 50명 생성
    sql_content += "\n-- 2. 스타 프로필 생성\n"
    
    for i, user in enumerate(star_users):
        experience_levels = ['NEWBIE', 'JUNIOR', 'SENIOR', 'PROFESSIONAL']
        pay_types = ['TC', 'DAILY', 'MONTHLY']
        
        experience = random.choice(experience_levels)
        pay_type = random.choice(pay_types)
        
        # 경력에 따른 급여 설정
        base_pay = {
            'NEWBIE': 3000000,
            'JUNIOR': 4000000, 
            'SENIOR': 5500000,
            'PROFESSIONAL': 7000000
        }[experience]
        
        pay_amount = base_pay + random.randint(-500000, 1000000)
        
        # 이미지 URL 생성
        image_count = random.randint(1, 3)
        image_urls = [f"https://bamstar-profile.s3.amazonaws.com/star_{user['auth_id']}_{j+1}.jpg" for j in range(image_count)]
        
        # 근무 가능 요일
        all_days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY']
        working_days = random.sample(all_days, random.randint(3, 6))
        
        # 매칭 조건 (JSON)
        matching_conditions = {
            "preferred_business_types": random.sample(list(BUSINESS_TYPES.keys()), random.randint(2, 4)),
            "work_style_preferences": random.sample(["team_work", "individual", "flexible", "stable"], random.randint(1, 3)),
            "location_flexibility": random.choice(["high", "medium", "low"])
        }
        
        sql_content += f"""
INSERT INTO member_profiles (
    user_id, real_name, gender, contact_phone, profile_image_urls, bio,
    experience_level, desired_pay_type, desired_pay_amount, desired_working_days,
    available_from, can_relocate, level, experience_points, title, age, matching_conditions
) VALUES (
    '{user['auth_id']}',
    '{user['real_name']}',
    '{user['gender']}',
    '010-{3000+i:04d}-{random.randint(1000,9999)}',
    ARRAY{image_urls},
    '{user['real_name']}님은 {experience.lower()} 레벨의 열정적인 스타입니다.',
    '{experience}',
    '{pay_type}',
    {pay_amount},
    ARRAY{working_days},
    '{(date.today() + timedelta(days=random.randint(1, 30))).isoformat()}',
    {random.choice(['true', 'false'])},
    {random.randint(1, 10)},
    {random.randint(0, 5000)},
    '{random.choice(["신입", "경력", "전문가", "리더"])}',
    {random.randint(20, 35)},
    '{json.dumps(matching_conditions, ensure_ascii=False)}'
);
"""
    
    # 3. 플레이스 프로필 30명 생성
    sql_content += "\n-- 3. 플레이스 프로필 생성\n"
    
    for i, user in enumerate(place_users):
        business_type = random.choice(list(BUSINESS_TYPES.keys()))
        business_info = BUSINESS_TYPES[business_type]
        
        # 사업자 번호 생성
        business_number = f"{random.randint(100,999)}-{random.randint(10,99)}-{random.randint(10000,99999)}"
        
        # 주소 생성 (서울 주요 지역)
        seoul_areas = ["강남구", "서초구", "마포구", "용산구", "중구", "종로구", "강서구", "강북구", "성북구", "동대문구"]
        area = random.choice(seoul_areas)
        address = f"서울특별시 {area} {random.choice(['역삼동', '서초동', '홍대동', '압구정동', '청담동'])}"
        
        # 급여 범위 조정
        offered_min = business_info["pay_min"] + random.randint(-300000, 0)
        offered_max = business_info["pay_max"] + random.randint(0, 500000)
        
        # 운영시간 (JSON)
        operating_hours = {
            "monday": {"open": "18:00", "close": "02:00"},
            "tuesday": {"open": "18:00", "close": "02:00"},
            "wednesday": {"open": "18:00", "close": "02:00"},
            "thursday": {"open": "18:00", "close": "03:00"},
            "friday": {"open": "18:00", "close": "04:00"},
            "saturday": {"open": "18:00", "close": "04:00"},
            "sunday": {"open": "18:00", "close": "01:00"}
        }
        
        # 매니저 정보
        manager_names = ["김매니저", "이실장", "박매니저", "최사장", "윤매니저", "장원장", "한실장", "오사장"]
        manager_name = random.choice(manager_names)
        
        # 이미지 URL
        image_count = random.randint(1, 5)
        image_urls = [f"https://bamstar-place.s3.amazonaws.com/place_{user['auth_id']}_{j+1}.jpg" for j in range(image_count)]
        
        sql_content += f"""
INSERT INTO place_profiles (
    user_id, place_name, business_type, business_number, business_verified,
    address, manager_name, manager_phone, intro, profile_image_urls,
    operating_hours, offered_pay_type, offered_min_pay, offered_max_pay,
    desired_experience_level, created_at, updated_at
) VALUES (
    '{user['auth_id']}',
    '{user['place_name']}',
    '{business_type}',
    '{business_number}',
    {random.choice(['true', 'false'])},
    '{address}',
    '{manager_name}',
    '010-{4000+i:04d}-{random.randint(1000,9999)}',
    '{user['place_name']}는 {business_type} 전문업체입니다. 좋은 환경에서 함께 일하실 분을 찾습니다.',
    ARRAY{image_urls},
    '{json.dumps(operating_hours, ensure_ascii=False)}',
    '{random.choice(['TC', '일급', '월급'])}',
    {offered_min},
    {offered_max},
    '{random.choice(['NEWBIE', 'JUNIOR', 'SENIOR', 'PROFESSIONAL'])}',
    NOW() - INTERVAL '{random.randint(1, 180)} days',
    NOW()
);
"""
    
    # 4. 속성 연결 생성
    sql_content += "\n-- 4. 스타 속성 연결\n"
    
    member_styles = attributes.get('MEMBER_STYLE', [])
    for user in star_users:
        # 각 스타마다 2-4개 스타일 부여
        selected_styles = random.sample(member_styles, random.randint(2, min(4, len(member_styles))))
        for style in selected_styles:
            sql_content += f"INSERT INTO member_attributes_link (member_user_id, attribute_id) VALUES ('{user['auth_id']}', {style['id']});\n"
    
    sql_content += "\n-- 5. 플레이스 산업 연결\n"
    
    industries = attributes.get('INDUSTRY', [])
    industry_by_name = {ind['name']: ind for ind in industries}
    
    for user in place_users:
        # 각 플레이스의 business_type에 맞는 산업 연결
        place_business_type = random.choice(list(BUSINESS_TYPES.keys()))
        if place_business_type in industry_by_name:
            industry_id = industry_by_name[place_business_type]['id']
            sql_content += f"INSERT INTO place_industries (place_user_id, attribute_id) VALUES ('{user['auth_id']}', {industry_id});\n"
    
    sql_content += "\n-- 6. 플레이스 특성 연결\n"
    
    place_features = attributes.get('PLACE_FEATURE', [])
    for user in place_users:
        # 각 플레이스마다 2-5개 특성 부여
        selected_features = random.sample(place_features, random.randint(2, min(5, len(place_features))))
        for feature in selected_features:
            sql_content += f"INSERT INTO place_attributes_link (place_user_id, attribute_id) VALUES ('{user['auth_id']}', {feature['id']});\n"
    
    sql_content += "\nCOMMIT;\n\n-- 검증 쿼리\nSELECT 'Stars' as type, COUNT(*) as count FROM member_profiles mp JOIN users u ON mp.user_id = u.id WHERE u.email LIKE 'bamstar%@example.com';\nSELECT 'Places' as type, COUNT(*) as count FROM place_profiles pp JOIN users u ON pp.user_id = u.id WHERE u.email LIKE 'bamstar%@example.com';\n"
    
    # 파일 저장
    filename = f"large_bamstar_test_data_{timestamp}.sql"
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(sql_content)
    
    print(f"✅ 대량 테스트 데이터 생성 완료: {filename}")
    print(f"📊 생성된 데이터: 스타 50명, 플레이스 30명")
    print(f"🔗 속성 연결: 스타 속성 {len(star_users) * 3}개 예상, 플레이스 특성 {len(place_users) * 3}개 예상")
    
    return filename

if __name__ == "__main__":
    generate_large_test_data()
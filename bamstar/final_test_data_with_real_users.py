#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
실제 auth.users ID를 사용한 BamStar 테스트 데이터 생성기
"""

import json
import random
import uuid
from datetime import datetime, timedelta
import psycopg2

# 데이터베이스 연결 설정
DB_CONFIG = {
    'host': 'aws-1-ap-northeast-2.pooler.supabase.com',
    'port': 6543,
    'database': 'postgres',
    'user': 'postgres.tflvicpgyycvhttctcek',
    'password': '!@Wnrsmsek1'
}

def get_auth_user_ids():
    """auth.users에서 테스트 유저 ID들을 가져옴"""
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    
    cur.execute("""
        SELECT id, email FROM auth.users 
        WHERE email LIKE 'bamstar%@example.com' 
        ORDER BY email
    """)
    
    users = cur.fetchall()
    cur.close()
    conn.close()
    
    return users

def generate_test_data_sql():
    """실제 auth 유저 ID를 사용해 테스트 데이터 SQL 생성"""
    
    print("🔍 auth.users에서 테스트 유저 ID 조회 중...")
    auth_users = get_auth_user_ids()
    print(f"✅ {len(auth_users)}개 auth 유저 발견")
    
    if len(auth_users) < 60:
        print("❌ 충분한 auth 유저가 없습니다. 먼저 auth 유저를 생성하세요.")
        return
    
    # 역할 배분
    place_users = auth_users[:18]  # 플레이스 18개
    star_users = auth_users[18:42]  # 스타 24개  
    guest_users = auth_users[42:60]  # 게스트 18개
    
    print(f"👥 역할 배분:")
    print(f"   - 플레이스: {len(place_users)}개")
    print(f"   - 스타: {len(star_users)}개")
    print(f"   - 게스트: {len(guest_users)}개")
    
    # SQL 파일 생성
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    sql_filename = f"final_test_data_real_users_{timestamp}.sql"
    
    with open(sql_filename, 'w', encoding='utf-8') as f:
        f.write("-- BamStar 테스트 데이터 (실제 auth.users ID 사용)\n")
        f.write(f"-- 생성일: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        
        # 1. users 테이블
        f.write("-- 1. users 테이블 데이터\n")
        f.write("INSERT INTO users (id, role_id, ci, is_adult, email, phone, created_at, profile_img, nickname, last_sign_in, updated_at) VALUES\n")
        
        user_values = []
        all_users = []
        
        # 플레이스 유저들
        for i, (user_id, email) in enumerate(place_users):
            user_data = {
                'id': user_id,
                'role_id': 3,  # PLACE
                'email': email,
                'phone': f'010-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}',
                'nickname': f'플레이스#{i+1}',
                'created_at': (datetime.now() - timedelta(days=random.randint(1, 180))).isoformat(),
                'last_sign_in': (datetime.now() - timedelta(days=random.randint(0, 7))).isoformat(),
                'updated_at': datetime.now().isoformat(),
                'profile_img': f'https://picsum.photos/300/300?random={random.randint(1000, 9999)}'
            }
            all_users.append(user_data)
            user_values.append(f"('{user_id}', 3, NULL, true, '{email}', '{user_data['phone']}', '{user_data['created_at']}', '{user_data['profile_img']}', '{user_data['nickname']}', '{user_data['last_sign_in']}', '{user_data['updated_at']}')")
        
        # 스타 유저들
        for i, (user_id, email) in enumerate(star_users):
            user_data = {
                'id': user_id,
                'role_id': 2,  # STAR
                'email': email,
                'phone': f'010-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}',
                'nickname': f'스타#{i+1}',
                'created_at': (datetime.now() - timedelta(days=random.randint(1, 180))).isoformat(),
                'last_sign_in': (datetime.now() - timedelta(days=random.randint(0, 7))).isoformat(),
                'updated_at': datetime.now().isoformat(),
                'profile_img': f'https://picsum.photos/300/300?random={random.randint(1000, 9999)}'
            }
            all_users.append(user_data)
            user_values.append(f"('{user_id}', 2, NULL, true, '{email}', '{user_data['phone']}', '{user_data['created_at']}', '{user_data['profile_img']}', '{user_data['nickname']}', '{user_data['last_sign_in']}', '{user_data['updated_at']}')")
        
        # 게스트 유저들
        for i, (user_id, email) in enumerate(guest_users):
            user_data = {
                'id': user_id,
                'role_id': 1,  # GUEST
                'email': email,
                'phone': f'010-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}',
                'nickname': f'게스트#{i+1}',
                'created_at': (datetime.now() - timedelta(days=random.randint(1, 180))).isoformat(),
                'last_sign_in': (datetime.now() - timedelta(days=random.randint(0, 7))).isoformat(),
                'updated_at': datetime.now().isoformat(),
                'profile_img': f'https://picsum.photos/300/300?random={random.randint(1000, 9999)}'
            }
            all_users.append(user_data)
            user_values.append(f"('{user_id}', 1, NULL, true, '{email}', '{user_data['phone']}', '{user_data['created_at']}', '{user_data['profile_img']}', '{user_data['nickname']}', '{user_data['last_sign_in']}', '{user_data['updated_at']}')")
        
        f.write(',\n'.join(user_values) + ';\n\n')
        
        # 2. member_profiles 테이블 (스타용)
        f.write("-- 2. member_profiles 테이블 데이터\n")
        f.write("INSERT INTO member_profiles (user_id, real_name, gender, contact_phone, profile_image_urls, social_links, bio, experience_level, desired_pay_type, desired_pay_amount, desired_working_days, available_from, can_relocate, level, experience_points, title, updated_at, age, matching_conditions, business_verification_id, is_business_verified, business_verification_level, business_verified_at) VALUES\n")
        
        member_values = []
        first_names = ['민준', '서윤', '도윤', '예은', '시우', '하은', '주원', '지유', '건우', '서현']
        last_names = ['김', '이', '박', '최', '정', '강', '조', '윤', '장', '임']
        
        for user_id, email in star_users:
            age = random.randint(20, 35)
            experience_level = random.choice(['NEWBIE', 'JUNIOR', 'SENIOR', 'PROFESSIONAL'])
            
            # 경력에 따른 급여
            pay_ranges = {
                'NEWBIE': (2500000, 4000000),
                'JUNIOR': (3500000, 5500000),
                'SENIOR': (4500000, 7000000),
                'PROFESSIONAL': (6000000, 10000000)
            }
            pay_range = pay_ranges[experience_level]
            
            profile_images = [
                f'https://picsum.photos/400/500?random={random.randint(2000, 8999)}',
                f'https://picsum.photos/400/500?random={random.randint(2000, 8999)}'
            ]
            
            social_links = {
                'service': random.choice(['카카오톡', '인스타그램']),
                'handle': f'star{random.randint(100, 999)}'
            }
            
            industries = ['모던 바', '토크 바', '캐주얼 펍', '가라오케', '카페', '테라피', '라이브 방송', '이벤트']
            job_roles = ['매니저', '실장', '바텐더', '스탭', '가드', '주방', 'BJ']
            member_styles = ['긍정적', '활발함', '차분함', '성실함', '대화리드', '리액션요정', '패션센스', '좋은비율']
            place_features = ['초보환영', '경력자우대', '가족같은', '파티분위기', '고급스러운', '편안한', '텃세없음', '친구랑같이', '술강요없음', '자유복장']
            welfare_benefits = ['당일지급', '선불/마이킹', '인센티브', '4대보험', '퇴직금', '경조사비', '숙소 제공', '교통비 지원', '주차 지원', '식사 제공', '의상/유니폼', '자유 출퇴근', '헤어/메이크업', '성형 지원', '휴가/월차']
            
            matching_conditions = {
                "MUST_HAVE": random.sample(industries, k=random.randint(2, 4)) + 
                           random.sample(job_roles, k=random.randint(1, 3)) + 
                           [f"페이: TC {random.randint(pay_range[0], pay_range[1])}원",
                            f"근무일: {', '.join(random.sample(['월', '화', '수', '목', '금', '토', '일'], k=random.randint(3, 5)))}",
                            f"경력: {experience_level.lower()}"],
                "PEOPLE": {
                    "team_dynamics": [],
                    "communication_style": random.sample(member_styles, k=random.randint(1, 3))
                },
                "ENVIRONMENT": {
                    "workplace_features": random.sample(place_features, k=random.randint(2, 4)) + 
                                        random.sample(welfare_benefits, k=random.randint(2, 3)),
                    "location_preferences": random.sample(['강남·서초', '잠실·송파·강동', '종로·중구', '용산·이태원·한남', '홍대·합정·마포·서대문'], k=random.randint(1, 3))
                },
                "AVOID": []
            }
            
            profile_images_str = "'{" + ','.join([f'"{url}"' for url in profile_images]) + "}'"
            social_links_str = json.dumps(social_links).replace("'", "''")
            matching_conditions_str = json.dumps(matching_conditions).replace("'", "''")
            working_days_str = "'{" + ','.join(random.sample(['월', '화', '수', '목', '금', '토', '일'], k=random.randint(3, 6))) + "}'"
            
            member_values.append(f"('{user_id}', '{random.choice(last_names)}{random.choice(first_names)}', '{random.choice(['MALE', 'FEMALE'])}', '010-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}', {profile_images_str}, '{social_links_str}', '{experience_level.lower()} 레벨의 전문 서비스를 제공합니다.', '{experience_level}', '{random.choice(['TC', 'DAILY', 'MONTHLY'])}', {random.randint(pay_range[0], pay_range[1])}, {working_days_str}, NULL, {str(random.choice([True, False])).lower()}, {random.randint(1, 10)}, {random.randint(0, 5000)}, '새로운 스타', '{datetime.now().isoformat()}', {age}, '{matching_conditions_str}', NULL, false, 'none', NULL)")
        
        f.write(',\n'.join(member_values) + ';\n\n')
        
        # 3. place_profiles 테이블
        f.write("-- 3. place_profiles 테이블 데이터\n")
        f.write("INSERT INTO place_profiles (user_id, place_name, business_type, business_number, business_verified, address, detail_address, postcode, road_address, jibun_address, latitude, longitude, area_group_id, manager_name, manager_phone, manager_gender, sns_type, sns_handle, intro, profile_image_urls, representative_image_index, operating_hours, offered_pay_type, offered_min_pay, offered_max_pay, desired_experience_level, desired_working_days, created_at, updated_at) VALUES\n")
        
        place_values = []
        place_prefixes = ['강남', '홍대', '압구정', '이태원', '건대', '신촌', '역삼', '논현', '청담', '서초']
        place_suffixes = ['프리미엄', '로얄', 'VIP', '골든', '다이아몬드', '플래티넘', '크라운', '임페리얼']
        business_types = ['모던 바', '토크 바', '캐주얼 펍', '가라오케', '카페', '테라피', '라이브 방송', '이벤트']
        area_groups = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        
        for i, (user_id, email) in enumerate(place_users):
            business_type = random.choice(business_types)
            area_group_id = random.choice(area_groups)
            
            # 업종별 급여 설정
            if business_type in ['모던 바', '토크 바']:
                pay_range = (3000000, 6000000)
            elif business_type in ['캐주얼 펍', '가라오케']:
                pay_range = (2500000, 5000000)
            elif business_type == '테라피':
                pay_range = (4000000, 8000000)
            elif business_type in ['라이브 방송', 'BJ']:
                pay_range = (3500000, 7000000)
            else:
                pay_range = (2500000, 5000000)
            
            profile_images = [
                f'https://picsum.photos/600/400?random={random.randint(3000, 7999)}',
                f'https://picsum.photos/600/400?random={random.randint(3000, 7999)}'
            ]
            
            operating_hours = {
                'days': ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
                'start_hour': random.choice([18.0, 19.0, 20.0]),
                'end_hour': random.choice([2.0, 3.0, 4.0])
            }
            
            profile_images_str = "'{" + ','.join([f'"{url}"' for url in profile_images]) + "}'"
            operating_hours_str = json.dumps(operating_hours).replace("'", "''")
            working_days_str = "'{" + ','.join(random.sample(['월', '화', '수', '목', '금', '토', '일'], k=random.randint(4, 7))) + "}'"
            
            place_values.append(f"('{user_id}', '{random.choice(place_prefixes)} {random.choice(place_suffixes)} {business_type}', '{business_type}', '{random.randint(100, 999)}-{random.randint(10, 99)}-{random.randint(10000, 99999)}', {str(random.choice([True, False])).lower()}, '서울시 강남구 테헤란로 {random.randint(1, 999)}', '{random.randint(1, 20)}층', '{random.randint(10000, 99999)}', '서울시 강남구 테헤란로 {random.randint(1, 999)}', '서울시 강남구 역삼동 {random.randint(1, 999)}-{random.randint(1, 50)}', {round(37.5 + random.uniform(-0.1, 0.1), 8)}, {round(127.0 + random.uniform(-0.1, 0.1), 8)}, {area_group_id}, '{random.choice(last_names)}{random.choice(first_names)}', '010-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}', '{random.choice(['남', '여'])}', '{random.choice(['카카오톡', '인스타그램', '기타'])}', 'place{random.randint(100, 999)}', '{business_type} 전문점으로 최고의 서비스를 제공합니다.', {profile_images_str}, 0, '{operating_hours_str}', '{random.choice(['TC', '일급', '월급'])}', {pay_range[0]}, {pay_range[1]}, '{random.choice(['무관', '신입', '주니어', '시니어'])}', {working_days_str}, '{(datetime.now() - timedelta(days=random.randint(1, 120))).isoformat()}', '{datetime.now().isoformat()}')")
        
        f.write(',\n'.join(place_values) + ';\n\n')
        f.write("-- 데이터 삽입 완료\n")
    
    print(f"✅ SQL 파일 생성: {sql_filename}")
    return sql_filename

if __name__ == "__main__":
    print("🌟 실제 auth.users ID 기반 테스트 데이터 생성기")
    print("="*70)
    
    sql_file = generate_test_data_sql()
    
    if sql_file:
        print(f"\n🚀 DB 삽입 명령어:")
        print(f"psql \"postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres\" -f {sql_file}")
    else:
        print("❌ 테스트 데이터 생성 실패")
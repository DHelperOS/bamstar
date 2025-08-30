#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BamStar 최종 테스트 데이터 생성기
- 기존 attributes 데이터 활용
- 실제 스키마에 완벽 대응
- 밤알바 특성 반영
"""

import json
import random
import uuid
from datetime import datetime, timedelta

class FinalBamStarDataGenerator:
    def __init__(self):
        # 기존 DB의 attributes 데이터
        self.industries = [
            {'id': 1, 'name': '모던 바'},
            {'id': 2, 'name': '토크 바'},
            {'id': 3, 'name': '캐주얼 펍'},
            {'id': 4, 'name': '가라오케'},
            {'id': 5, 'name': '카페'},
            {'id': 6, 'name': '테라피'},
            {'id': 7, 'name': '라이브 방송'},
            {'id': 8, 'name': '이벤트'}
        ]
        
        self.job_roles = [
            {'id': 9, 'name': '매니저'},
            {'id': 10, 'name': '실장'},
            {'id': 11, 'name': '바텐더'},
            {'id': 12, 'name': '스탭'},
            {'id': 13, 'name': '가드'},
            {'id': 14, 'name': '주방'},
            {'id': 15, 'name': 'BJ'}
        ]
        
        self.welfare_benefits = [
            {'id': 16, 'name': '당일지급'},
            {'id': 17, 'name': '선불/마이킹'},
            {'id': 18, 'name': '인센티브'},
            {'id': 19, 'name': '4대보험'},
            {'id': 20, 'name': '퇴직금'},
            {'id': 21, 'name': '경조사비'},
            {'id': 22, 'name': '숙소 제공'},
            {'id': 23, 'name': '교통비 지원'},
            {'id': 24, 'name': '주차 지원'},
            {'id': 25, 'name': '식사 제공'},
            {'id': 26, 'name': '의상/유니폼'},
            {'id': 27, 'name': '자유 출퇴근'},
            {'id': 28, 'name': '헤어/메이크업'},
            {'id': 29, 'name': '성형 지원'},
            {'id': 30, 'name': '휴가/월차'}
        ]
        
        self.place_features = [
            {'id': 31, 'name': '초보환영'},
            {'id': 32, 'name': '경력자우대'},
            {'id': 33, 'name': '가족같은'},
            {'id': 34, 'name': '파티분위기'},
            {'id': 35, 'name': '고급스러운'},
            {'id': 36, 'name': '편안한'},
            {'id': 37, 'name': '텃세없음'},
            {'id': 38, 'name': '친구랑같이'},
            {'id': 39, 'name': '술강요없음'},
            {'id': 40, 'name': '자유복장'}
        ]
        
        self.member_styles = [
            {'id': 41, 'name': '긍정적'},
            {'id': 42, 'name': '활발함'},
            {'id': 43, 'name': '차분함'},
            {'id': 44, 'name': '성실함'},
            {'id': 45, 'name': '대화리드'},
            {'id': 46, 'name': '리액션요정'},
            {'id': 47, 'name': '패션센스'},
            {'id': 48, 'name': '좋은비율'}
        ]
        
        # 실제 area_groups 데이터
        self.area_groups = [
            {'group_id': 1, 'name': '강남·서초'},
            {'group_id': 2, 'name': '잠실·송파·강동'},  
            {'group_id': 3, 'name': '종로·중구'},
            {'group_id': 4, 'name': '용산·이태원·한남'},
            {'group_id': 5, 'name': '홍대·합정·마포·서대문'},
            {'group_id': 6, 'name': '영등포·여의도·강서'},
            {'group_id': 7, 'name': '구로·관악·동작'},
            {'group_id': 8, 'name': '건대·성수·왕십리'},
            {'group_id': 9, 'name': '대학로·성북·동대문'},
            {'group_id': 10, 'name': '노원·중랑·강북'}
        ]
        
        # 한국 이름들
        self.last_names = ['김', '이', '박', '최', '정', '강', '조', '윤', '장', '임', '한', '오', '서', '신', '권', '황']
        self.first_names = ['민준', '서윤', '도윤', '예은', '시우', '하은', '주원', '지유', '건우', '서현', 
                          '민서', '예준', '하린', '지호', '수빈', '지민', '윤서', '준우', '채원', '시은']

    def generate_users_data(self, count=60):
        """유저 데이터 생성"""
        users = []
        
        for i in range(count):
            user_id = str(uuid.uuid4())
            
            # 역할 배분 (PLACE: 30%, STAR: 40%, GUEST: 30%)
            role_choice = random.random()
            if role_choice < 0.3:
                role_id = 3  # PLACE
                nickname_prefix = "플레이스"
            elif role_choice < 0.7:
                role_id = 2  # STAR  
                nickname_prefix = "스타"
            else:
                role_id = 1  # GUEST
                nickname_prefix = "게스트"
            
            user = {
                'id': user_id,
                'role_id': role_id,
                'ci': None,
                'is_adult': True,  # 밤알바이므로 모두 성인
                'email': f'bamstar{i+1:03d}@example.com',
                'phone': f'010-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}',
                'created_at': self.random_datetime_within_days(180).isoformat(),
                'profile_img': f'https://picsum.photos/300/300?random={random.randint(1000, 9999)}',
                'nickname': f'{nickname_prefix}#{i+1}',
                'last_sign_in': self.random_datetime_within_days(7).isoformat(),
                'updated_at': datetime.now().isoformat()
            }
            users.append(user)
        
        return users

    def generate_member_profiles_data(self, star_user_ids):
        """멤버 프로필 데이터 생성 (스타용)"""
        profiles = []
        
        for user_id in star_user_ids:
            age = random.randint(20, 35)
            
            # 나이에 따른 경력 레벨
            if age <= 22:
                experience_level = random.choice(['NEWBIE', 'JUNIOR'])
                pay_range = (2500000, 4000000)
            elif age <= 27:
                experience_level = random.choice(['JUNIOR', 'SENIOR'])
                pay_range = (3500000, 5500000)
            elif age <= 32:
                experience_level = random.choice(['SENIOR', 'PROFESSIONAL'])
                pay_range = (4500000, 7000000)
            else:
                experience_level = 'PROFESSIONAL'
                pay_range = (6000000, 10000000)
            
            # 매칭 조건 생성
            must_have_industries = random.sample([ind['name'] for ind in self.industries], k=random.randint(2, 4))
            must_have_jobs = random.sample([job['name'] for job in self.job_roles], k=random.randint(1, 3))
            must_have_pay = f"페이: TC {random.randint(pay_range[0], pay_range[1])}원"
            must_have_days = f"근무일: {', '.join(random.sample(['월', '화', '수', '목', '금', '토', '일'], k=random.randint(3, 5)))}"
            must_have_experience = f"경력: {experience_level.lower()}"
            
            matching_conditions = {
                "MUST_HAVE": must_have_industries + must_have_jobs + [must_have_pay, must_have_days, must_have_experience],
                "PEOPLE": {
                    "team_dynamics": [],
                    "communication_style": random.sample([style['name'] for style in self.member_styles], k=random.randint(1, 3))
                },
                "ENVIRONMENT": {
                    "workplace_features": random.sample([feat['name'] for feat in self.place_features], k=random.randint(2, 4)) + 
                                        random.sample([welf['name'] for welf in self.welfare_benefits], k=random.randint(2, 3)),
                    "location_preferences": random.sample([area['name'] for area in self.area_groups], k=random.randint(1, 3))
                },
                "AVOID": []
            }
            
            profile = {
                'user_id': user_id,
                'real_name': random.choice(self.last_names) + random.choice(self.first_names),
                'gender': random.choice(['MALE', 'FEMALE']),
                'contact_phone': f'010-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}',
                'profile_image_urls': [
                    f'https://picsum.photos/400/500?random={random.randint(2000, 8999)}',
                    f'https://picsum.photos/400/500?random={random.randint(2000, 8999)}'
                ],
                'social_links': {
                    'service': random.choice(['카카오톡', '인스타그램']),
                    'handle': f'star{random.randint(100, 999)}'
                },
                'bio': f'{experience_level.lower()} 레벨의 전문 서비스를 제공합니다.',
                'experience_level': experience_level,
                'desired_pay_type': random.choice(['TC', 'DAILY', 'MONTHLY']),
                'desired_pay_amount': random.randint(pay_range[0], pay_range[1]),
                'desired_working_days': random.sample(['월', '화', '수', '목', '금', '토', '일'], k=random.randint(3, 6)),
                'available_from': None,
                'can_relocate': random.choice([True, False]),
                'level': random.randint(1, 10),
                'experience_points': random.randint(0, 5000),
                'title': '새로운 스타',
                'updated_at': datetime.now().isoformat(),
                'age': age,
                'matching_conditions': matching_conditions,
                'business_verification_id': None,
                'is_business_verified': False,
                'business_verification_level': 'none',
                'business_verified_at': None
            }
            profiles.append(profile)
        
        return profiles

    def generate_place_profiles_data(self, place_user_ids):
        """플레이스 프로필 데이터 생성"""
        profiles = []
        
        place_prefixes = ['강남', '홍대', '압구정', '이태원', '건대', '신촌', '역삼', '논현', '청담', '서초']
        place_suffixes = ['프리미엄', '로얄', 'VIP', '골든', '다이아몬드', '플래티넘', '크라운', '임페리얼']
        
        for i, user_id in enumerate(place_user_ids):
            area_group = random.choice(self.area_groups)
            industry = random.choice(self.industries)
            
            # 업종별 급여 설정
            if industry['name'] in ['모던 바', '토크 바']:
                pay_range = (3000000, 6000000)
            elif industry['name'] in ['캐주얼 펍', '가라오케']:
                pay_range = (2500000, 5000000)
            elif industry['name'] in ['테라피']:
                pay_range = (4000000, 8000000)
            elif industry['name'] in ['라이브 방송', 'BJ']:
                pay_range = (3500000, 7000000)
            else:
                pay_range = (2500000, 5000000)
            
            profile = {
                'user_id': user_id,
                'place_name': f'{random.choice(place_prefixes)} {random.choice(place_suffixes)} {industry["name"]}',
                'business_type': industry['name'],
                'business_number': f'{random.randint(100, 999)}-{random.randint(10, 99)}-{random.randint(10000, 99999)}',
                'business_verified': random.choice([True, False]),
                'address': f'서울시 {area_group["name"].split("·")[0]}구 {random.choice(["대로", "로", "길"])} {random.randint(1, 999)}',
                'detail_address': f'{random.randint(1, 20)}층' if random.choice([True, False]) else None,
                'postcode': f'{random.randint(10000, 99999)}',
                'road_address': f'서울시 {area_group["name"].split("·")[0]}구 {random.choice(["대로", "로"])} {random.randint(1, 999)}',
                'jibun_address': f'서울시 {area_group["name"].split("·")[0]}구 {random.choice(["동", "로"])} {random.randint(1, 999)}-{random.randint(1, 50)}',
                'latitude': round(37.5 + random.uniform(-0.1, 0.1), 8),
                'longitude': round(127.0 + random.uniform(-0.1, 0.1), 8),
                'area_group_id': area_group['group_id'],
                'manager_name': random.choice(self.last_names) + random.choice(self.first_names),
                'manager_phone': f'010-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}',
                'manager_gender': random.choice(['남', '여']),
                'sns_type': random.choice(['카카오톡', '인스타그램', '기타']),
                'sns_handle': f'place{random.randint(100, 999)}',
                'intro': f'{industry["name"]} 전문점으로 최고의 서비스를 제공합니다.',
                'profile_image_urls': [
                    f'https://picsum.photos/600/400?random={random.randint(3000, 7999)}',
                    f'https://picsum.photos/600/400?random={random.randint(3000, 7999)}'
                ],
                'representative_image_index': 0,
                'operating_hours': {
                    'days': ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
                    'start_hour': random.choice([18.0, 19.0, 20.0]),
                    'end_hour': random.choice([2.0, 3.0, 4.0])
                },
                'offered_pay_type': random.choice(['TC', '일급', '월급']),
                'offered_min_pay': pay_range[0],
                'offered_max_pay': pay_range[1],
                'desired_experience_level': random.choice(['무관', '신입', '주니어', '시니어']),
                'desired_working_days': random.sample(['월', '화', '수', '목', '금', '토', '일'], k=random.randint(4, 7)),
                'created_at': self.random_datetime_within_days(120).isoformat(),
                'updated_at': datetime.now().isoformat()
            }
            profiles.append(profile)
        
        return profiles

    def generate_attribute_links(self, users, member_profiles, place_profiles):
        """속성 연결 데이터 생성"""
        member_links = []
        place_links = []
        member_pref_links = []
        place_pref_links = []
        place_industries = []
        member_area_preferences = []
        
        # 멤버 속성 연결
        for profile in member_profiles:
            user_id = profile['user_id']
            
            # 멤버 스타일 속성 연결
            selected_styles = random.sample(self.member_styles, k=random.randint(2, 4))
            for style in selected_styles:
                member_links.append({
                    'member_user_id': user_id,
                    'attribute_id': style['id']
                })
            
            # 멤버 선호 직무 연결 (member_preferences_link)
            selected_jobs = random.sample(self.job_roles, k=random.randint(1, 3))
            for job in selected_jobs:
                member_pref_links.append({
                    'member_user_id': user_id,
                    'attribute_id': job['id']
                })
            
            # 멤버 선호 지역 연결
            selected_areas = random.sample(self.area_groups, k=random.randint(1, 3))
            for area in selected_areas:
                member_area_preferences.append({
                    'member_user_id': user_id,
                    'group_id': area['group_id']
                })
        
        # 플레이스 속성 연결
        for profile in place_profiles:
            user_id = profile['user_id']
            
            # 플레이스 특징 속성 연결
            selected_features = random.sample(self.place_features, k=random.randint(2, 5))
            for feature in selected_features:
                place_links.append({
                    'place_user_id': user_id,
                    'attribute_id': feature['id']
                })
            
            # 플레이스 복지 혜택 연결 (place_preferences_link)
            selected_welfare = random.sample(self.welfare_benefits, k=random.randint(3, 6))
            for welfare in selected_welfare:
                place_pref_links.append({
                    'place_user_id': user_id,
                    'attribute_id': welfare['id']
                })
            
            # 플레이스 업종 연결
            # 프로필의 business_type과 매칭되는 industry 찾기
            matching_industry = next((ind for ind in self.industries if ind['name'] == profile['business_type']), 
                                  random.choice(self.industries))
            place_industries.append({
                'place_user_id': user_id,
                'attribute_id': matching_industry['id']
            })
        
        return {
            'member_attributes_link': member_links,
            'member_preferences_link': member_pref_links,
            'place_attributes_link': place_links,
            'place_preferences_link': place_pref_links,
            'place_industries': place_industries,
            'member_preferred_area_groups': member_area_preferences
        }

    def random_datetime_within_days(self, days):
        """지정된 일수 내의 랜덤 날짜 생성"""
        start_date = datetime.now() - timedelta(days=days)
        random_days = random.randint(0, days)
        return start_date + timedelta(days=random_days)

    def generate_all_test_data(self):
        """모든 테스트 데이터 생성"""
        print("🌟 BamStar 최종 테스트 데이터 생성 시작")
        print("="*70)
        
        # 1. 유저 데이터 생성
        print("👥 유저 데이터 생성 중...")
        users = self.generate_users_data(60)
        print(f"✅ {len(users)}개 유저 생성 완료")
        
        # 역할별로 분류
        place_user_ids = [u['id'] for u in users if u['role_id'] == 3]
        star_user_ids = [u['id'] for u in users if u['role_id'] == 2]
        guest_user_ids = [u['id'] for u in users if u['role_id'] == 1]
        
        print(f"   - 플레이스: {len(place_user_ids)}개")
        print(f"   - 스타: {len(star_user_ids)}개")
        print(f"   - 게스트: {len(guest_user_ids)}개")
        
        # 2. 멤버 프로필 생성 (스타용)
        print("\n⭐ 스타 프로필 생성 중...")
        member_profiles = self.generate_member_profiles_data(star_user_ids)
        print(f"✅ {len(member_profiles)}개 스타 프로필 생성 완료")
        
        # 3. 플레이스 프로필 생성
        print("\n🏢 플레이스 프로필 생성 중...")
        place_profiles = self.generate_place_profiles_data(place_user_ids)
        print(f"✅ {len(place_profiles)}개 플레이스 프로필 생성 완료")
        
        # 4. 속성 연결 데이터 생성
        print("\n🔗 속성 연결 데이터 생성 중...")
        attribute_links = self.generate_attribute_links(users, member_profiles, place_profiles)
        print(f"✅ 속성 연결 데이터 생성 완료")
        print(f"   - 멤버 속성: {len(attribute_links['member_attributes_link'])}개")
        print(f"   - 멤버 선호: {len(attribute_links['member_preferences_link'])}개")  
        print(f"   - 플레이스 속성: {len(attribute_links['place_attributes_link'])}개")
        print(f"   - 플레이스 선호: {len(attribute_links['place_preferences_link'])}개")
        print(f"   - 플레이스 업종: {len(attribute_links['place_industries'])}개")
        print(f"   - 멤버 지역 선호: {len(attribute_links['member_preferred_area_groups'])}개")
        
        return {
            'users': users,
            'member_profiles': member_profiles,
            'place_profiles': place_profiles,
            **attribute_links,
            'summary': {
                'total_users': len(users),
                'places': len(place_user_ids),
                'stars': len(star_user_ids), 
                'guests': len(guest_user_ids),
                'total_profiles': len(member_profiles) + len(place_profiles)
            }
        }

    def save_as_sql(self, data):
        """SQL INSERT 문으로 저장"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        sql_filename = f"final_bamstar_test_data_{timestamp}.sql"
        
        with open(sql_filename, 'w', encoding='utf-8') as f:
            f.write("-- BamStar 최종 테스트 데이터 INSERT 문\n")
            f.write(f"-- 생성일: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write("-- 기존 attributes 데이터 활용\n\n")
            
            # 1. users 테이블
            f.write("-- 1. users 테이블 데이터\n")
            f.write("INSERT INTO users (id, role_id, ci, is_adult, email, phone, created_at, profile_img, nickname, last_sign_in, updated_at) VALUES\n")
            user_values = []
            for user in data['users']:
                values = f"('{user['id']}', {user['role_id']}, NULL, {str(user['is_adult']).lower()}, '{user['email']}', '{user['phone']}', '{user['created_at']}', '{user['profile_img']}', '{user['nickname']}', '{user['last_sign_in']}', '{user['updated_at']}')"
                user_values.append(values)
            f.write(',\n'.join(user_values) + ';\n\n')
            
            # 2. member_profiles 테이블
            f.write("-- 2. member_profiles 테이블 데이터\n")
            f.write("INSERT INTO member_profiles (user_id, real_name, gender, contact_phone, profile_image_urls, social_links, bio, experience_level, desired_pay_type, desired_pay_amount, desired_working_days, available_from, can_relocate, level, experience_points, title, updated_at, age, matching_conditions, business_verification_id, is_business_verified, business_verification_level, business_verified_at) VALUES\n")
            member_values = []
            for profile in data['member_profiles']:
                profile_images = "'{" + ','.join([f'"{url}"' for url in profile['profile_image_urls']]) + "}'"
                social_links = json.dumps(profile['social_links']).replace("'", "''")
                matching_conditions = json.dumps(profile['matching_conditions']).replace("'", "''")
                working_days = "'{" + ','.join(profile['desired_working_days']) + "}'"
                available_from = 'NULL' if profile['available_from'] is None else f"'{profile['available_from']}'"
                
                values = f"('{profile['user_id']}', '{profile['real_name']}', '{profile['gender']}', '{profile['contact_phone']}', {profile_images}, '{social_links}', '{profile['bio']}', '{profile['experience_level']}', '{profile['desired_pay_type']}', {profile['desired_pay_amount']}, {working_days}, {available_from}, {str(profile['can_relocate']).lower()}, {profile['level']}, {profile['experience_points']}, '{profile['title']}', '{profile['updated_at']}', {profile['age']}, '{matching_conditions}', NULL, {str(profile['is_business_verified']).lower()}, '{profile['business_verification_level']}', NULL)"
                member_values.append(values)
            f.write(',\n'.join(member_values) + ';\n\n')
            
            # 3. place_profiles 테이블
            f.write("-- 3. place_profiles 테이블 데이터\n")
            f.write("INSERT INTO place_profiles (user_id, place_name, business_type, business_number, business_verified, address, detail_address, postcode, road_address, jibun_address, latitude, longitude, area_group_id, manager_name, manager_phone, manager_gender, sns_type, sns_handle, intro, profile_image_urls, representative_image_index, operating_hours, offered_pay_type, offered_min_pay, offered_max_pay, desired_experience_level, desired_working_days, created_at, updated_at) VALUES\n")
            place_values = []
            for profile in data['place_profiles']:
                profile_images = "'{" + ','.join([f'"{url}"' for url in profile['profile_image_urls']]) + "}'"
                operating_hours = json.dumps(profile['operating_hours']).replace("'", "''")
                working_days = "'{" + ','.join(profile['desired_working_days']) + "}'"
                detail_addr = 'NULL' if profile['detail_address'] is None else f"'{profile['detail_address']}'"
                
                values = f"('{profile['user_id']}', '{profile['place_name']}', '{profile['business_type']}', '{profile['business_number']}', {str(profile['business_verified']).lower()}, '{profile['address']}', {detail_addr}, '{profile['postcode']}', '{profile['road_address']}', '{profile['jibun_address']}', {profile['latitude']}, {profile['longitude']}, {profile['area_group_id']}, '{profile['manager_name']}', '{profile['manager_phone']}', '{profile['manager_gender']}', '{profile['sns_type']}', '{profile['sns_handle']}', '{profile['intro']}', {profile_images}, {profile['representative_image_index']}, '{operating_hours}', '{profile['offered_pay_type']}', {profile['offered_min_pay']}, {profile['offered_max_pay']}, '{profile['desired_experience_level']}', {working_days}, '{profile['created_at']}', '{profile['updated_at']}')"
                place_values.append(values)
            f.write(',\n'.join(place_values) + ';\n\n')
            
            # 4. 속성 연결 테이블들
            link_tables = [
                ('member_attributes_link', ['member_user_id', 'attribute_id']),
                ('member_preferences_link', ['member_user_id', 'attribute_id']),  
                ('place_attributes_link', ['place_user_id', 'attribute_id']),
                ('place_preferences_link', ['place_user_id', 'attribute_id']),
                ('place_industries', ['place_user_id', 'attribute_id']),
                ('member_preferred_area_groups', ['member_user_id', 'group_id'])
            ]
            
            for table_name, columns in link_tables:
                if table_name in data and data[table_name]:
                    f.write(f"-- {table_name} 테이블 데이터\n")
                    f.write(f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES\n")
                    link_values = []
                    for link in data[table_name]:
                        values = f"('{link[columns[0]]}', {link[columns[1]]})"
                        link_values.append(values)
                    f.write(',\n'.join(link_values) + ';\n\n')
            
            f.write("-- 데이터 삽입 완료\n")
        
        return sql_filename

    def save_as_json(self, data):
        """JSON으로도 저장"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        json_filename = f"final_bamstar_test_data_{timestamp}.json"
        
        with open(json_filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2, default=str)
        
        return json_filename

def main():
    print("🌟 BamStar 최종 테스트 데이터 생성기")
    print("="*70)
    print("✨ 기존 attributes 데이터 활용")
    print("🎯 실제 스키마 완벽 대응")
    print("🔗 매칭 시스템 완전 지원")
    print()
    
    generator = FinalBamStarDataGenerator()
    data = generator.generate_all_test_data()
    
    print("\n📁 파일 저장 중...")
    sql_file = generator.save_as_sql(data)
    json_file = generator.save_as_json(data)
    
    print(f"✅ SQL 파일: {sql_file}")
    print(f"✅ JSON 파일: {json_file}")
    
    print("\n" + "="*70)
    print("🎉 BamStar 최종 테스트 데이터 생성 완료!")
    print(f"📊 데이터 요약:")
    for key, value in data['summary'].items():
        print(f"   - {key}: {value}개")
    
    print(f"\n🚀 DB 삽입 명령어:")
    print(f"psql \"postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres\" -f {sql_file}")

if __name__ == "__main__":
    main()
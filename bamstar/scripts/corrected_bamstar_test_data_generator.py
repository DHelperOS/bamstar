#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BamStar 실제 스키마에 맞는 밤알바 테스트 데이터 생성기
- 실제 테이블 구조에 정확히 맞춤
- 밤알바 특성 반영
- 매칭 시스템용 데이터 생성
"""

import json
import random
import uuid
from datetime import datetime, timedelta

class BamStarTestDataGenerator:
    def __init__(self):
        # 밤알바 업종 (attributes 테이블용)
        self.business_types = [
            {'name': '룸싸롱', 'type': 'BUSINESS_TYPE', 'type_kor': '업종', 'description': '룸 서비스가 있는 주점', 'icon_name': 'room'},
            {'name': '텐프로', 'type': 'BUSINESS_TYPE', 'type_kor': '업종', 'description': '텐카페 프로 서비스', 'icon_name': 'ten'},
            {'name': '쩜오', 'type': 'BUSINESS_TYPE', 'type_kor': '업종', 'description': '0.5차 주점', 'icon_name': 'half'},
            {'name': '노래주점', 'type': 'BUSINESS_TYPE', 'type_kor': '업종', 'description': '노래와 함께하는 주점', 'icon_name': 'music'},
            {'name': '단란주점', 'type': 'BUSINESS_TYPE', 'type_kor': '업종', 'description': '단란한 분위기의 주점', 'icon_name': 'cozy'},
            {'name': 'BAR', 'type': 'BUSINESS_TYPE', 'type_kor': '업종', 'description': '칵테일 바', 'icon_name': 'cocktail'},
            {'name': '호스트바', 'type': 'BUSINESS_TYPE', 'type_kor': '업종', 'description': '호스트 서비스 바', 'icon_name': 'host'},
            {'name': '마사지', 'type': 'BUSINESS_TYPE', 'type_kor': '업종', 'description': '마사지 서비스', 'icon_name': 'massage'},
            {'name': '클럽', 'type': 'BUSINESS_TYPE', 'type_kor': '업종', 'description': '나이트클럽', 'icon_name': 'club'},
            {'name': 'KTV', 'type': 'BUSINESS_TYPE', 'type_kor': '업종', 'description': '노래방 서비스', 'icon_name': 'karaoke'},
            {'name': '퍼블릭', 'type': 'BUSINESS_TYPE', 'type_kor': '업종', 'description': '퍼블릭 룸', 'icon_name': 'public'},
            {'name': '하이퍼블릭', 'type': 'BUSINESS_TYPE', 'type_kor': '업종', 'description': '하이 퍼블릭 룸', 'icon_name': 'highpublic'},
            {'name': '셔츠룸', 'type': 'BUSINESS_TYPE', 'type_kor': '업종', 'description': '셔츠룸 서비스', 'icon_name': 'shirt'},
            {'name': '라운지', 'type': 'BUSINESS_TYPE', 'type_kor': '업종', 'description': '라운지 바', 'icon_name': 'lounge'},
            {'name': '나이트클럽', 'type': 'BUSINESS_TYPE', 'type_kor': '업종', 'description': '나이트클럽', 'icon_name': 'night'}
        ]
        
        # 직무 (attributes 테이블용)
        self.job_roles = [
            {'name': '웨이터', 'type': 'JOB_ROLE', 'type_kor': '직무', 'description': '서빙 업무', 'icon_name': 'waiter'},
            {'name': '웨이트리스', 'type': 'JOB_ROLE', 'type_kor': '직무', 'description': '서빙 업무', 'icon_name': 'waitress'},
            {'name': '도우미', 'type': 'JOB_ROLE', 'type_kor': '직무', 'description': '접객 도우미', 'icon_name': 'helper'},
            {'name': '바텐더', 'type': 'JOB_ROLE', 'type_kor': '직무', 'description': '음료 제조', 'icon_name': 'bartender'},
            {'name': '캐셔', 'type': 'JOB_ROLE', 'type_kor': '직무', 'description': '계산 업무', 'icon_name': 'cashier'},
            {'name': '매니저', 'type': 'JOB_ROLE', 'type_kor': '직무', 'description': '매니저 역할', 'icon_name': 'manager'},
            {'name': '실장', 'type': 'JOB_ROLE', 'type_kor': '직무', 'description': '실장 역할', 'icon_name': 'chief'},
            {'name': '홀매니저', 'type': 'JOB_ROLE', 'type_kor': '직무', 'description': '홀 관리', 'icon_name': 'hall'},
            {'name': '호스트', 'type': 'JOB_ROLE', 'type_kor': '직무', 'description': '호스트 서비스', 'icon_name': 'host'},
            {'name': '퍼포머', 'type': 'JOB_ROLE', 'type_kor': '직무', 'description': '공연 서비스', 'icon_name': 'performer'}
        ]
        
        # 스타일 속성
        self.style_attributes = [
            {'name': '친근한', 'type': 'STYLE', 'type_kor': '스타일', 'description': '친근한 분위기', 'icon_name': 'friendly'},
            {'name': '전문적인', 'type': 'STYLE', 'type_kor': '스타일', 'description': '전문적 서비스', 'icon_name': 'professional'},
            {'name': '활발한', 'type': 'STYLE', 'type_kor': '스타일', 'description': '활발한 성격', 'icon_name': 'active'},
            {'name': '차분한', 'type': 'STYLE', 'type_kor': '스타일', 'description': '차분한 성격', 'icon_name': 'calm'},
            {'name': '유머있는', 'type': 'STYLE', 'type_kor': '스타일', 'description': '유머 감각', 'icon_name': 'humor'},
            {'name': '성실한', 'type': 'STYLE', 'type_kor': '스타일', 'description': '성실한 태도', 'icon_name': 'sincere'}
        ]
        
        # 복지 혜택
        self.welfare_benefits = [
            {'name': '일당지급', 'type': 'WELFARE', 'type_kor': '복지', 'description': '일당 당일 지급', 'icon_name': 'daily_pay'},
            {'name': '팁별도지급', 'type': 'WELFARE', 'type_kor': '복지', 'description': '팁 별도 지급', 'icon_name': 'tip'},
            {'name': '식사제공', 'type': 'WELFARE', 'type_kor': '복지', 'description': '식사 제공', 'icon_name': 'meal'},
            {'name': '교통비지급', 'type': 'WELFARE', 'type_kor': '복지', 'description': '교통비 지급', 'icon_name': 'transport'},
            {'name': '숙식제공', 'type': 'WELFARE', 'type_kor': '복지', 'description': '숙박 제공', 'icon_name': 'accommodation'},
            {'name': '인센티브', 'type': 'WELFARE', 'type_kor': '복지', 'description': '성과 인센티브', 'icon_name': 'incentive'},
            {'name': '상여금', 'type': 'WELFARE', 'type_kor': '복지', 'description': '상여금 지급', 'icon_name': 'bonus'},
            {'name': '의상지원', 'type': 'WELFARE', 'type_kor': '복지', 'description': '유니폼 지원', 'icon_name': 'uniform'}
        ]
        
        # 서울 지역 정보 (실제 area_groups와 매칭)
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

    def generate_attributes_data(self):
        """속성 테이블 데이터 생성"""
        attributes = []
        id_counter = 1
        
        # 업종 속성
        for business_type in self.business_types:
            attributes.append({
                'id': id_counter,
                **business_type,
                'is_active': True
            })
            id_counter += 1
        
        # 직무 속성
        for job_role in self.job_roles:
            attributes.append({
                'id': id_counter,
                **job_role,
                'is_active': True
            })
            id_counter += 1
        
        # 스타일 속성
        for style in self.style_attributes:
            attributes.append({
                'id': id_counter,
                **style,
                'is_active': True
            })
            id_counter += 1
        
        # 복지 속성
        for welfare in self.welfare_benefits:
            attributes.append({
                'id': id_counter,
                **welfare,
                'is_active': True
            })
            id_counter += 1
        
        return attributes

    def generate_users_data(self, count=50):
        """유저 데이터 생성"""
        users = []
        
        for i in range(count):
            user_id = str(uuid.uuid4())
            
            # 역할 배분 (PLACE: 40%, STAR: 30%, GUEST: 30%)
            role_choice = random.random()
            if role_choice < 0.4:
                role_id = 3  # PLACE
            elif role_choice < 0.7:
                role_id = 2  # STAR
            else:
                role_id = 1  # GUEST
            
            user = {
                'id': user_id,
                'role_id': role_id,
                'ci': None,
                'is_adult': random.choice([True, False]),
                'email': f'testuser{i+1:03d}@bamstar.com',
                'phone': f'010-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}',
                'created_at': self.random_datetime_within_days(365).isoformat(),
                'profile_img': f'https://picsum.photos/300/300?random={random.randint(1000, 9999)}',
                'nickname': f'{"플레이스" if role_id == 3 else "스타" if role_id == 2 else "게스트"}#{i+1}',
                'last_sign_in': self.random_datetime_within_days(7).isoformat(),
                'updated_at': datetime.now().isoformat()
            }
            users.append(user)
        
        return users

    def generate_member_profiles_data(self, star_user_ids):
        """멤버 프로필 데이터 생성 (스타용)"""
        profiles = []
        
        first_names = ['민준', '서윤', '도윤', '예은', '시우', '하은', '주원', '지유', '건우', '서현']
        last_names = ['김', '이', '박', '최', '정', '강', '조', '윤', '장', '임']
        
        for user_id in star_user_ids:
            age = random.randint(20, 35)
            
            # 나이에 따른 경력 레벨
            if age <= 22:
                experience_level = random.choice(['NEWBIE', 'JUNIOR'])
            elif age <= 27:
                experience_level = random.choice(['JUNIOR', 'SENIOR'])
            elif age <= 32:
                experience_level = random.choice(['SENIOR', 'PROFESSIONAL'])
            else:
                experience_level = 'PROFESSIONAL'
            
            # 경력에 따른 급여
            pay_ranges = {
                'NEWBIE': (2500000, 4000000),
                'JUNIOR': (3000000, 5000000),
                'SENIOR': (4000000, 7000000),
                'PROFESSIONAL': (6000000, 10000000)
            }
            min_pay, max_pay = pay_ranges[experience_level]
            
            profile = {
                'user_id': user_id,
                'real_name': random.choice(last_names) + random.choice(first_names),
                'gender': random.choice(['MALE', 'FEMALE']),
                'contact_phone': f'010-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}',
                'profile_image_urls': [
                    f'https://picsum.photos/400/500?random={random.randint(2000, 8999)}',
                    f'https://picsum.photos/400/500?random={random.randint(2000, 8999)}'
                ],
                'social_links': {
                    'service': random.choice(['카카오톡', '인스타그램', '기타']),
                    'handle': f'star{random.randint(100, 999)}'
                },
                'bio': f'{experience_level.lower()} 레벨의 전문 서비스를 제공합니다.',
                'experience_level': experience_level,
                'desired_pay_type': random.choice(['TC', 'DAILY', 'MONTHLY']),
                'desired_pay_amount': random.randint(min_pay, max_pay),
                'desired_working_days': random.sample(['월', '화', '수', '목', '금', '토', '일'], 
                                                    k=random.randint(3, 6)),
                'available_from': (datetime.now() + timedelta(days=random.randint(0, 30))).date().isoformat(),
                'can_relocate': random.choice([True, False]),
                'level': random.randint(1, 10),
                'experience_points': random.randint(0, 5000),
                'title': f'{random.choice(["프로", "전문", "베테랑", "신입", "실력자"])} 스타',
                'updated_at': datetime.now().isoformat(),
                'age': age,
                'matching_conditions': self.generate_matching_conditions('STAR'),
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
        
        place_name_prefixes = ['강남', '홍대', '압구정', '이태원', '건대', '신촌', '역삼', '논현', '청담', '서초']
        place_name_suffixes = ['프리미엄', '로얄', 'VIP', '골든', '다이아몬드', '플래티넘', '크라운', '임페리얼', '엘리트', '그랜드']
        
        for i, user_id in enumerate(place_user_ids):
            area_group = random.choice(self.area_groups)
            business_type_name = random.choice([bt['name'] for bt in self.business_types])
            
            # 업종별 급여 설정
            pay_ranges = {
                '룸싸롱': (4000000, 8000000),
                '텐프로': (3500000, 6000000),
                '클럽': (3000000, 5500000),
                'BAR': (2500000, 4500000),
                '호스트바': (3500000, 6500000),
                'KTV': (2800000, 5000000)
            }
            min_pay, max_pay = pay_ranges.get(business_type_name, (2500000, 5000000))
            
            profile = {
                'user_id': user_id,
                'place_name': f'{random.choice(place_name_prefixes)} {random.choice(place_name_suffixes)} {business_type_name}',
                'business_type': business_type_name,
                'business_number': f'{random.randint(100, 999)}-{random.randint(10, 99)}-{random.randint(10000, 99999)}',
                'business_verified': random.choice([True, False]),
                'address': f'서울시 {area_group["name"].split("·")[0]}구 {random.choice(["강남대로", "테헤란로", "논현로", "압구정로", "홍익로"])} {random.randint(1, 999)}',
                'detail_address': f'{random.randint(1, 20)}층 {random.randint(101, 999)}호',
                'postcode': f'{random.randint(10000, 99999)}',
                'road_address': f'서울시 {area_group["name"].split("·")[0]}구 {random.choice(["강남대로", "테헤란로", "논현로"])} {random.randint(1, 999)}',
                'jibun_address': f'서울시 {area_group["name"].split("·")[0]}구 {random.choice(["역삼동", "논현동", "압구정동"])} {random.randint(1, 999)}-{random.randint(1, 50)}',
                'latitude': round(37.5 + random.uniform(-0.1, 0.1), 8),
                'longitude': round(127.0 + random.uniform(-0.1, 0.1), 8),
                'area_group_id': area_group['group_id'],
                'manager_name': f'{random.choice(["김", "이", "박", "최"])}{random.choice(["민수", "영희", "철수", "미나"])}',
                'manager_phone': f'010-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}',
                'manager_gender': random.choice(['남', '여']),
                'sns_type': random.choice(['카카오톡', '인스타그램', '기타']),
                'sns_handle': f'place{random.randint(100, 999)}',
                'intro': f'{business_type_name} 전문점으로 최고의 서비스를 제공합니다.',
                'profile_image_urls': [
                    f'https://picsum.photos/600/400?random={random.randint(3000, 7999)}',
                    f'https://picsum.photos/600/400?random={random.randint(3000, 7999)}',
                    f'https://picsum.photos/600/400?random={random.randint(3000, 7999)}'
                ],
                'representative_image_index': 0,
                'operating_hours': {
                    'days': ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
                    'start_hour': 18.0 + random.uniform(-1, 1),
                    'end_hour': 2.0 + random.uniform(-1, 2)
                },
                'offered_pay_type': random.choice(['TC', '일급', '월급', '협의']),
                'offered_min_pay': min_pay,
                'offered_max_pay': max_pay,
                'desired_experience_level': random.choice(['무관', '신입', '주니어', '시니어', '전문가']),
                'desired_working_days': random.sample(['월', '화', '수', '목', '금', '토', '일'], 
                                                    k=random.randint(4, 7)),
                'created_at': self.random_datetime_within_days(180).isoformat(),
                'updated_at': datetime.now().isoformat()
            }
            profiles.append(profile)
        
        return profiles

    def generate_matching_conditions(self, role_type):
        """매칭 조건 생성"""
        if role_type == 'STAR':
            return {
                'MUST_HAVE': random.sample([bt['name'] for bt in self.business_types], k=random.randint(2, 5)),
                'PEOPLE': {
                    'communication_style': random.sample([s['name'] for s in self.style_attributes], k=random.randint(1, 3)),
                    'team_dynamics': []
                },
                'ENVIRONMENT': {
                    'workplace_features': random.sample([w['name'] for w in self.welfare_benefits], k=random.randint(2, 4)),
                    'location_preferences': random.sample([ag['name'] for ag in self.area_groups], k=random.randint(1, 3))
                },
                'AVOID': []
            }
        else:  # PLACE
            return {
                'REQUIRED_SKILLS': random.sample([jr['name'] for jr in self.job_roles], k=random.randint(2, 4)),
                'PREFERRED_STYLE': random.sample([s['name'] for s in self.style_attributes], k=random.randint(1, 2)),
                'BENEFITS_OFFERED': random.sample([w['name'] for w in self.welfare_benefits], k=random.randint(3, 6))
            }

    def random_datetime_within_days(self, days):
        """지정된 일수 내의 랜덤 날짜 생성"""
        start_date = datetime.now() - timedelta(days=days)
        random_days = random.randint(0, days)
        return start_date + timedelta(days=random_days)

    def generate_all_test_data(self):
        """모든 테스트 데이터 생성"""
        print("🎯 BamStar 실제 스키마 맞춤 테스트 데이터 생성 시작")
        print("="*70)
        
        # 1. 속성 데이터 생성
        print("📋 속성 데이터 생성 중...")
        attributes = self.generate_attributes_data()
        print(f"✅ {len(attributes)}개 속성 생성 완료")
        
        # 2. 유저 데이터 생성
        print("\n👥 유저 데이터 생성 중...")
        users = self.generate_users_data(50)
        print(f"✅ {len(users)}개 유저 생성 완료")
        
        # 역할별로 분류
        place_user_ids = [u['id'] for u in users if u['role_id'] == 3]
        star_user_ids = [u['id'] for u in users if u['role_id'] == 2]
        guest_user_ids = [u['id'] for u in users if u['role_id'] == 1]
        
        print(f"   - 플레이스: {len(place_user_ids)}개")
        print(f"   - 스타: {len(star_user_ids)}개")
        print(f"   - 게스트: {len(guest_user_ids)}개")
        
        # 3. 멤버 프로필 생성 (스타용)
        print("\n⭐ 스타 프로필 생성 중...")
        member_profiles = self.generate_member_profiles_data(star_user_ids)
        print(f"✅ {len(member_profiles)}개 스타 프로필 생성 완료")
        
        # 4. 플레이스 프로필 생성
        print("\n🏢 플레이스 프로필 생성 중...")
        place_profiles = self.generate_place_profiles_data(place_user_ids)
        print(f"✅ {len(place_profiles)}개 플레이스 프로필 생성 완료")
        
        return {
            'attributes': attributes,
            'users': users,
            'member_profiles': member_profiles,
            'place_profiles': place_profiles,
            'summary': {
                'total_users': len(users),
                'places': len(place_user_ids),
                'stars': len(star_user_ids), 
                'guests': len(guest_user_ids),
                'attributes': len(attributes)
            }
        }

    def save_data_as_sql(self, data):
        """SQL INSERT 문으로 저장"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        sql_filename = f"bamstar_test_data_{timestamp}.sql"
        
        with open(sql_filename, 'w', encoding='utf-8') as f:
            f.write("-- BamStar 테스트 데이터 INSERT 문\n")
            f.write(f"-- 생성일: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            
            # 1. attributes 테이블
            f.write("-- 1. attributes 테이블 데이터\n")
            f.write("INSERT INTO attributes (id, type, type_kor, name, description, icon_name, is_active) VALUES\n")
            attr_values = []
            for attr in data['attributes']:
                values = f"({attr['id']}, '{attr['type']}', '{attr['type_kor']}', '{attr['name']}', '{attr['description']}', '{attr['icon_name']}', {str(attr['is_active']).lower()})"
                attr_values.append(values)
            f.write(',\n'.join(attr_values) + ';\n\n')
            
            # 2. users 테이블
            f.write("-- 2. users 테이블 데이터\n")
            f.write("INSERT INTO users (id, role_id, ci, is_adult, email, phone, created_at, profile_img, nickname, last_sign_in, updated_at) VALUES\n")
            user_values = []
            for user in data['users']:
                ci_val = 'NULL' if user['ci'] is None else f"'{user['ci']}'"
                values = f"('{user['id']}', {user['role_id']}, {ci_val}, {str(user['is_adult']).lower()}, '{user['email']}', '{user['phone']}', '{user['created_at']}', '{user['profile_img']}', '{user['nickname']}', '{user['last_sign_in']}', '{user['updated_at']}')"
                user_values.append(values)
            f.write(',\n'.join(user_values) + ';\n\n')
            
            # 3. member_profiles 테이블
            f.write("-- 3. member_profiles 테이블 데이터\n")
            f.write("INSERT INTO member_profiles (user_id, real_name, gender, contact_phone, profile_image_urls, social_links, bio, experience_level, desired_pay_type, desired_pay_amount, desired_working_days, available_from, can_relocate, level, experience_points, title, updated_at, age, matching_conditions, business_verification_id, is_business_verified, business_verification_level, business_verified_at) VALUES\n")
            member_values = []
            for profile in data['member_profiles']:
                profile_images = "'{" + ','.join(profile['profile_image_urls']) + "}'"
                social_links = json.dumps(profile['social_links']).replace("'", "''")
                matching_conditions = json.dumps(profile['matching_conditions']).replace("'", "''")
                working_days = "'{" + ','.join(profile['desired_working_days']) + "}'"
                bv_id = 'NULL' if profile['business_verification_id'] is None else f"'{profile['business_verification_id']}'"
                bv_at = 'NULL' if profile['business_verified_at'] is None else f"'{profile['business_verified_at']}'"
                
                values = f"('{profile['user_id']}', '{profile['real_name']}', '{profile['gender']}', '{profile['contact_phone']}', {profile_images}, '{social_links}', '{profile['bio']}', '{profile['experience_level']}', '{profile['desired_pay_type']}', {profile['desired_pay_amount']}, {working_days}, '{profile['available_from']}', {str(profile['can_relocate']).lower()}, {profile['level']}, {profile['experience_points']}, '{profile['title']}', '{profile['updated_at']}', {profile['age']}, '{matching_conditions}', {bv_id}, {str(profile['is_business_verified']).lower()}, '{profile['business_verification_level']}', {bv_at})"
                member_values.append(values)
            f.write(',\n'.join(member_values) + ';\n\n')
            
            # 4. place_profiles 테이블
            f.write("-- 4. place_profiles 테이블 데이터\n")
            f.write("INSERT INTO place_profiles (user_id, place_name, business_type, business_number, business_verified, address, detail_address, postcode, road_address, jibun_address, latitude, longitude, area_group_id, manager_name, manager_phone, manager_gender, sns_type, sns_handle, intro, profile_image_urls, representative_image_index, operating_hours, offered_pay_type, offered_min_pay, offered_max_pay, desired_experience_level, desired_working_days, created_at, updated_at) VALUES\n")
            place_values = []
            for profile in data['place_profiles']:
                profile_images = "'{" + ','.join(profile['profile_image_urls']) + "}'"
                operating_hours = json.dumps(profile['operating_hours']).replace("'", "''")
                working_days = "'{" + ','.join(profile['desired_working_days']) + "}'"
                
                values = f"('{profile['user_id']}', '{profile['place_name']}', '{profile['business_type']}', '{profile['business_number']}', {str(profile['business_verified']).lower()}, '{profile['address']}', '{profile['detail_address']}', '{profile['postcode']}', '{profile['road_address']}', '{profile['jibun_address']}', {profile['latitude']}, {profile['longitude']}, {profile['area_group_id']}, '{profile['manager_name']}', '{profile['manager_phone']}', '{profile['manager_gender']}', '{profile['sns_type']}', '{profile['sns_handle']}', '{profile['intro']}', {profile_images}, {profile['representative_image_index']}, '{operating_hours}', '{profile['offered_pay_type']}', {profile['offered_min_pay']}, {profile['offered_max_pay']}, '{profile['desired_experience_level']}', {working_days}, '{profile['created_at']}', '{profile['updated_at']}')"
                place_values.append(values)
            f.write(',\n'.join(place_values) + ';\n\n')
            
            f.write("-- 데이터 삽입 완료\n")
        
        return sql_filename

    def save_data_as_json(self, data):
        """JSON으로도 저장"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        json_filename = f"bamstar_test_data_{timestamp}.json"
        
        with open(json_filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        return json_filename

def main():
    print("🌟 BamStar 실제 스키마 맞춤 테스트 데이터 생성기")
    print("="*70)
    print("✨ 실제 테이블 구조에 완벽 대응")
    print("🎯 밤알바 특성 100% 반영")
    print("🔗 매칭 시스템 완벽 지원")
    print()
    
    generator = BamStarTestDataGenerator()
    data = generator.generate_all_test_data()
    
    print("\n📁 파일 저장 중...")
    sql_file = generator.save_data_as_sql(data)
    json_file = generator.save_data_as_json(data)
    
    print(f"✅ SQL 파일: {sql_file}")
    print(f"✅ JSON 파일: {json_file}")
    
    print("\n" + "="*70)
    print("🎉 BamStar 테스트 데이터 생성 완료!")
    print(f"📊 총 데이터 요약:")
    for key, value in data['summary'].items():
        print(f"   - {key}: {value}개")
    
    print(f"\n🚀 이제 다음 명령어로 DB에 삽입하세요:")
    print(f"psql \"postgresql://postgres.tflvicpgyycvhttctcek:%21%40Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres\" -f {sql_file}")

if __name__ == "__main__":
    main()
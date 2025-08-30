#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
밤알바 매칭 테스트 데이터 생성기
Fox알바에서 수집한 업종 정보를 기반으로 현실적인 테스트 데이터 생성
"""

import json
import random
import csv
from datetime import datetime, timedelta
import uuid

class NightJobTestDataGenerator:
    def __init__(self):
        # Fox알바에서 확인된 실제 업종들
        self.business_types = [
            '룸싸롱', '텐프로', '쩜오', '노래주점', '단란주점', 
            'BAR', '호스트바', '마사지', '요정', '다방', '카페',
            '클럽', 'KTV', '퍼블릭', '하이퍼블릭', '셔츠룸',
            '비즈니스클럽', '라운지', '나이트클럽'
        ]
        
        # 서울 주요 유흥가
        self.areas = {
            '강남구': ['강남', '역삼', '논현', '압구정', '청담', '신사', '삼성', '선릉'],
            '서초구': ['서초', '방배', '잠원', '반포'],  
            '마포구': ['홍대', '상수', '합정', '연남', '망원'],
            '용산구': ['이태원', '한남', '용산'],
            '중구': ['명동', '을지로', '충무로', '동대문', '종로'],
            '송파구': ['잠실', '신천', '문정'],
            '강동구': ['강동', '천호', '암사'],
            '성동구': ['건대', '성수', '왕십리'],
            '영등포구': ['여의도', '영등포', '당산'],
            '종로구': ['종로', '인사동', '대학로']
        }
        
        # 실제 급여 수준 (월급 기준)
        self.salary_ranges = {
            '룸싸롱': (3000000, 8000000),
            '텐프로': (2500000, 6000000),
            '쩜오': (2500000, 6000000),
            '노래주점': (2000000, 4500000),
            '단란주점': (1800000, 4000000),
            'BAR': (2000000, 5000000),
            '호스트바': (2500000, 7000000),
            '클럽': (2200000, 5500000),
            'KTV': (2000000, 5000000),
            '기타': (1800000, 4500000)
        }
        
        # 근무시간 패턴
        self.work_times = [
            '오후 6시 ~ 오전 2시',
            '오후 7시 ~ 오전 1시', 
            '오후 8시 ~ 오전 3시',
            '오후 9시 ~ 오전 4시',
            '오후 6시 ~ 오전 12시',
            '오후 8시 ~ 오전 2시'
        ]
        
        # 직급/포지션
        self.positions = [
            '웨이터', '웨이트리스', '도우미', '서빙', 
            '바텐더', '캐셔', '매니저', '실장',
            '홀매니저', '주방보조', '청소', '발렛파킹'
        ]
        
        # 업체명 생성 패턴
        self.name_prefixes = [
            '프리미엄', '로얄', 'VIP', '골드', '플래티넘', '다이아몬드',
            '크라운', '임페리얼', '그랜드', '엘리트', '프라임', '럭셔리'
        ]
        
        self.name_suffixes = [
            '클럽', '라운지', '바', '룸', 'KTV', '퍼블릭', '하우스', '홀'
        ]

    def generate_place_profiles(self, count=50):
        """업체 프로필 생성"""
        profiles = []
        
        for i in range(count):
            district = random.choice(list(self.areas.keys()))
            area = random.choice(self.areas[district])
            business_type = random.choice(self.business_types)
            
            # 급여 범위 설정
            salary_range = self.salary_ranges.get(business_type, self.salary_ranges['기타'])
            min_salary = random.randint(salary_range[0], salary_range[1] - 500000)
            max_salary = random.randint(min_salary + 500000, salary_range[1])
            
            profile = {
                'user_id': str(uuid.uuid4()),
                'place_name': self.generate_place_name(area, business_type),
                'business_type': business_type,
                'address': f'서울시 {district} {area}동 {random.randint(1, 999)}-{random.randint(1, 50)}',
                'latitude': round(37.5 + random.uniform(-0.1, 0.1), 6),
                'longitude': round(127.0 + random.uniform(-0.1, 0.1), 6),
                'manager_gender': random.choice(['남', '여']),
                'offered_min_pay': min_salary,
                'offered_max_pay': max_salary,
                'desired_experience_level': random.choice(['NEWCOMER', 'JUNIOR', 'INTERMEDIATE', 'SENIOR']),
                'profile_image_urls': [],
                'work_time': random.choice(self.work_times),
                'position_required': random.choice(self.positions),
                'description': self.generate_job_description(business_type),
                'benefits': self.generate_benefits(),
                'requirements': self.generate_requirements(),
                'created_at': self.random_date_within_days(30),
                'is_recruiting': True,
                'contact_method': random.choice(['전화', '문자', '카톡', '방문'])
            }
            
            profiles.append(profile)
        
        return profiles
    
    def generate_member_profiles(self, count=30):
        """구직자 프로필 생성"""
        profiles = []
        
        for i in range(count):
            age = random.randint(20, 35)
            experience_level = self.determine_experience_level(age)
            
            profile = {
                'user_id': str(uuid.uuid4()),
                'nickname': f'구직자{i+1:03d}',
                'age': age,
                'gender': random.choice(['MALE', 'FEMALE']),
                'experience_level': experience_level,
                'desired_pay_amount': random.randint(2000000, 6000000),
                'desired_business_types': random.sample(self.business_types, k=random.randint(2, 5)),
                'desired_areas': random.sample([area for areas in self.areas.values() for area in areas], 
                                             k=random.randint(2, 4)),
                'desired_working_days': random.sample(['월', '화', '수', '목', '금', '토', '일'], 
                                                    k=random.randint(3, 6)),
                'available_time': random.choice(self.work_times),
                'profile_image_urls': [],
                'self_introduction': self.generate_self_introduction(experience_level),
                'skills': self.generate_skills(),
                'preferred_work_style': random.choice(['개인플레이', '팀워크', '자유로운분위기', '전문적분위기']),
                'created_at': self.random_date_within_days(60),
                'is_job_seeking': True
            }
            
            profiles.append(profile)
        
        return profiles
    
    def generate_place_name(self, area, business_type):
        """업체명 생성"""
        patterns = [
            f"{random.choice(self.name_prefixes)} {area} {random.choice(self.name_suffixes)}",
            f"{area} {random.choice(self.name_prefixes)} {business_type}",
            f"{random.choice(['클럽', '바', '룸'])} {random.choice(['A', 'B', 'M', 'K', 'J', 'S'])}{random.randint(1, 99)}",
            f"{area} {business_type} {random.choice(['하우스', '플레이스', '스페이스'])}"
        ]
        
        return random.choice(patterns)
    
    def generate_job_description(self, business_type):
        """구인공고 설명 생성"""
        descriptions = {
            '룸싸롱': [
                "고급 룸살롱에서 웨이트리스 모집합니다. 경험자 우대, 신입도 환영합니다.",
                "프리미엄 룸에서 함께 일할 도우미를 찾습니다. 좋은 대우와 분위기 보장합니다.",
                "강남 고급 룸살롱 웨이트리스 급구. 일당 및 팁 별도 지급합니다."
            ],
            'BAR': [
                "트렌디한 바에서 바텐더/서버 모집. 칵테일 경험자 우대합니다.",
                "분위기 좋은 바에서 홀 서빙 스태프 구합니다. 주말 근무 가능자 우대.",
                "루프톱 바에서 함께 일할 동료를 찾습니다. 영어 가능자 우대."
            ],
            '클럽': [
                "핫한 클럽에서 웨이터/웨이트리스 모집. 체력 좋고 활발한 분 환영.",
                "강남 프리미엄 클럽 홀 스태프 구인. 주말 위주 근무, 높은 수입 보장.",
                "최신 음악과 함께하는 클럽 서비스 스태프 모집합니다."
            ]
        }
        
        if business_type in descriptions:
            return random.choice(descriptions[business_type])
        else:
            return f"{business_type}에서 함께 일할 직원을 모집합니다. 성실하고 책임감 있는 분을 찾습니다."
    
    def generate_benefits(self):
        """복리후생 생성"""
        benefits = [
            '일당지급', '팁별도지급', '식사제공', '교통비지급', 
            '숙식제공', '인센티브', '상여금', '4대보험',
            '연차수당', '명절수당', '주휴수당', '야간수당'
        ]
        return random.sample(benefits, k=random.randint(2, 5))
    
    def generate_requirements(self):
        """지원요건 생성"""
        requirements = [
            '성실한 성격', '책임감', '친화력', '서비스 마인드',
            '체력 좋은 분', '음주 가능', '흡연 무관', '외국어 가능자 우대',
            '경력자 우대', '신입 환영', '주말 근무 가능', '야간 근무 가능'
        ]
        return random.sample(requirements, k=random.randint(2, 4))
    
    def generate_self_introduction(self, experience_level):
        """자기소개 생성"""
        intros = {
            'NEWCOMER': [
                "처음이지만 열심히 배우겠습니다. 성실하게 일하겠습니다.",
                "신입이지만 빠르게 적응할 자신 있습니다. 잘 부탁드립니다.",
                "경험은 없지만 배우려는 의지는 누구보다 강합니다."
            ],
            'JUNIOR': [
                "6개월 정도 경험 있습니다. 더 발전하고 싶어서 지원했습니다.",
                "비슷한 업종에서 일해본 경험이 있어 빠르게 적응 가능합니다.",
                "기본적인 서비스는 할 수 있습니다. 더 배우고 싶습니다."
            ],
            'INTERMEDIATE': [
                "2년 정도 경험으로 안정적인 서비스 제공 가능합니다.",
                "다양한 업종에서 일해본 경험으로 어떤 상황이든 대처 가능합니다.",
                "고객 응대와 서비스에 자신 있습니다."
            ],
            'SENIOR': [
                "5년 이상 경험으로 매니지먼트도 가능합니다.",
                "오랜 경험으로 안정적이고 전문적인 서비스 제공합니다.",
                "신입 교육도 가능하며 팀을 이끌어 본 경험이 있습니다."
            ]
        }
        
        return random.choice(intros.get(experience_level, intros['NEWCOMER']))
    
    def generate_skills(self):
        """보유 스킬 생성"""
        skills = [
            '서비스 마인드', '고객 응대', '다국어 가능', '칵테일 제조',
            '음향장비 조작', '현금 관리', '예약 관리', '팀워크',
            '체력 관리', '스트레스 관리', '유연한 사고', '빠른 학습력'
        ]
        return random.sample(skills, k=random.randint(2, 5))
    
    def determine_experience_level(self, age):
        """나이에 따른 경력 수준 결정"""
        if age <= 22:
            return random.choice(['NEWCOMER', 'JUNIOR'])
        elif age <= 27:
            return random.choice(['JUNIOR', 'INTERMEDIATE'])
        elif age <= 32:
            return random.choice(['INTERMEDIATE', 'SENIOR'])
        else:
            return 'SENIOR'
    
    def random_date_within_days(self, days):
        """지정된 일수 내의 랜덤 날짜 생성"""
        start_date = datetime.now() - timedelta(days=days)
        random_days = random.randint(0, days)
        return (start_date + timedelta(days=random_days)).isoformat()
    
    def save_data(self, data, filename):
        """데이터 저장"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # JSON 저장
        json_filename = f"{filename}_{timestamp}.json"
        with open(json_filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"📄 JSON 파일 저장: {json_filename}")
        
        # CSV 저장
        if data:
            csv_filename = f"{filename}_{timestamp}.csv"
            with open(csv_filename, 'w', newline='', encoding='utf-8') as f:
                # 딕셔너리 내 리스트를 문자열로 변환
                processed_data = []
                for item in data:
                    processed_item = {}
                    for key, value in item.items():
                        if isinstance(value, list):
                            processed_item[key] = ', '.join(map(str, value))
                        else:
                            processed_item[key] = value
                    processed_data.append(processed_item)
                
                writer = csv.DictWriter(f, fieldnames=processed_data[0].keys())
                writer.writeheader()
                writer.writerows(processed_data)
            print(f"📊 CSV 파일 저장: {csv_filename}")
        
        return json_filename

def main():
    print("🌙 밤알바 매칭 테스트 데이터 생성기")
    print("=" * 50)
    
    generator = NightJobTestDataGenerator()
    
    # 1. 업체 프로필 생성
    print("\n🏢 업체 프로필 생성 중...")
    place_profiles = generator.generate_place_profiles(50)
    print(f"✅ {len(place_profiles)}개의 업체 프로필 생성 완료")
    
    # 2. 구직자 프로필 생성  
    print("\n👥 구직자 프로필 생성 중...")
    member_profiles = generator.generate_member_profiles(30)
    print(f"✅ {len(member_profiles)}개의 구직자 프로필 생성 완료")
    
    # 3. 데이터 저장
    print("\n💾 데이터 저장 중...")
    generator.save_data(place_profiles, "nightjob_places")
    generator.save_data(member_profiles, "nightjob_members")
    
    # 4. 통합 데이터 생성
    combined_data = {
        'places': place_profiles,
        'members': member_profiles,
        'generated_at': datetime.now().isoformat(),
        'total_places': len(place_profiles),
        'total_members': len(member_profiles)
    }
    
    generator.save_data([combined_data], "nightjob_combined")
    
    # 5. 샘플 데이터 출력
    print("\n🌟 생성된 데이터 샘플:")
    print("\n📍 업체 샘플:")
    for i, place in enumerate(place_profiles[:3]):
        print(f"{i+1}. {place['place_name']}")
        print(f"   업종: {place['business_type']}")
        print(f"   위치: {place['address']}")
        print(f"   급여: {place['offered_min_pay']:,}원 ~ {place['offered_max_pay']:,}원")
        print(f"   근무시간: {place['work_time']}")
    
    print("\n👤 구직자 샘플:")
    for i, member in enumerate(member_profiles[:3]):
        print(f"{i+1}. {member['nickname']} ({member['age']}세, {member['gender']})")
        print(f"   경력: {member['experience_level']}")
        print(f"   희망급여: {member['desired_pay_amount']:,}원")
        print(f"   희망업종: {', '.join(member['desired_business_types'][:3])}")
    
    print(f"\n🎉 테스트 데이터 생성 완료!")
    print(f"📊 총 {len(place_profiles)}개 업체 + {len(member_profiles)}개 구직자")

if __name__ == "__main__":
    main()
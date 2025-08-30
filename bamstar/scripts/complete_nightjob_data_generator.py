#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
완전한 밤알바 테스트 데이터 생성기
- 모든 이미지를 picsum.photos로 통일
- 스타 프로필 추가
- 유저 프로필 추가
- 업체 프로필 개선
"""

import json
import random
import csv
from datetime import datetime, timedelta
import uuid

class CompleteNightjobDataGenerator:
    def __init__(self):
        # 밤알바 업종
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
        
        # 스타 카테고리
        self.star_categories = [
            '룸스타', '클럽DJ', '바텐더', '호스트', '퍼포머', 
            '댄서', '가수', '모델', '인플루언서', 'MC'
        ]
        
        # 스타 스킬
        self.star_skills = [
            '노래', '춤', '연기', '마술', '요리', '칵테일 제조',
            '외국어', '악기연주', 'DJ믹싱', '사진촬영', '영상편집'
        ]

    def generate_picsum_urls(self, count=3, width=600, height=400):
        """picsum.photos를 사용한 이미지 URL 생성"""
        image_urls = []
        for _ in range(count):
            seed = random.randint(1000, 9999)
            url = f"https://picsum.photos/{width}/{height}?random={seed}"
            image_urls.append(url)
        return image_urls

    def generate_place_profiles(self, count=50):
        """업체 프로필 생성 (picsum 이미지)"""
        profiles = []
        
        place_names = [
            "강남 프리미엄 라운지", "홍대 클럽 에이스", "압구정 로얄바", 
            "이태원 VIP룸", "건대 골든클럽", "신촌 다이아몬드", 
            "역삼 플래티넘", "논현 크라운", "청담 임페리얼",
            "서초 엘리트", "잠실 프라임", "강동 럭셔리",
            "명동 그랜드", "을지로 킹", "종로 퀸", "홍대 스타",
            "강남 에이스", "압구정 킹덤", "이태원 글로벌", "건대 영",
            "신촌 블루", "역삼 골드", "논현 실버", "청담 브론즈",
            "서초 다이아", "잠실 루비", "강동 사파이어", "명동 에메랄드",
            "을지로 토파즈", "종로 자수정", "홍대 진주", "강남 오팔",
            "압구정 크리스탈", "이태원 레드", "건대 블랙", "신촌 화이트",
            "역삼 그린", "논현 블루", "청담 옐로우", "서초 핑크",
            "잠실 퍼플", "강동 오렌지", "명동 네이비", "을지로 브라운",
            "종로 그레이", "홍대 민트", "강남 코랄", "압구정 베이지", 
            "이태원 터키석", "건대 라벤더"
        ]
        
        for i in range(count):
            district = random.choice(list(self.areas.keys()))
            area = random.choice(self.areas[district])
            business_type = random.choice(self.business_types)
            
            # 업종별 급여 범위
            if '룸싸롱' in business_type:
                min_pay = random.randint(4000000, 6000000)
                max_pay = min_pay + random.randint(2000000, 4000000)
            elif '클럽' in business_type:
                min_pay = random.randint(3000000, 4500000) 
                max_pay = min_pay + random.randint(1500000, 3000000)
            elif 'BAR' in business_type or '바' in business_type:
                min_pay = random.randint(2500000, 4000000)
                max_pay = min_pay + random.randint(1000000, 2500000)
            else:
                min_pay = random.randint(2000000, 3500000)
                max_pay = min_pay + random.randint(1000000, 2000000)
            
            profile = {
                'user_id': str(uuid.uuid4()),
                'place_name': place_names[i] if i < len(place_names) else f"업체{i+1}",
                'business_type': business_type,
                'address': f'서울시 {district} {area}동 {random.randint(1, 999)}-{random.randint(1, 50)}',
                'latitude': round(37.5 + random.uniform(-0.1, 0.1), 6),
                'longitude': round(127.0 + random.uniform(-0.1, 0.1), 6),
                'manager_gender': random.choice(['남', '여']),
                'offered_min_pay': min_pay,
                'offered_max_pay': max_pay,
                'desired_experience_level': random.choice(['NEWCOMER', 'JUNIOR', 'INTERMEDIATE', 'SENIOR']),
                'profile_image_urls': self.generate_picsum_urls(count=random.randint(2, 4), width=600, height=400),
                'work_time': random.choice([
                    '오후 6시 ~ 오전 2시', '오후 7시 ~ 오전 1시', 
                    '오후 8시 ~ 오전 3시', '오후 9시 ~ 오전 4시'
                ]),
                'position_required': random.choice([
                    '웨이터', '웨이트리스', '도우미', '서빙', 
                    '바텐더', '캐셔', '매니저', '실장', '홀매니저'
                ]),
                'description': f"{business_type}에서 함께 일할 {random.choice(['성실하고 책임감 있는', '밝고 활발한', '친화력 좋은', '경험 많은'])} 분을 찾습니다.",
                'benefits': random.sample([
                    '일당지급', '팁별도지급', '식사제공', '교통비지급', 
                    '숙식제공', '인센티브', '상여금', '연차수당'
                ], k=random.randint(2, 5)),
                'dress_code': random.choice(['자유복장', '깔끔한복장', '정장', '업체복장제공']),
                'alcohol_service': random.choice([True, False]),
                'vip_service': random.choice([True, False]),
                'peak_hours': random.choice(['오후 9시-12시', '오후 10시-2시', '오후 11시-3시']),
                'atmosphere': random.choice(['고급스러운', '편안한', '활기찬', '조용한', '트렌디한']),
                'created_at': self.random_date_within_days(30),
                'is_recruiting': True
            }
            
            profiles.append(profile)
        
        return profiles

    def generate_member_profiles(self, count=30):
        """구직자 프로필 생성 (picsum 이미지)"""
        profiles = []
        
        member_nicknames = [
            "구직자001", "구직자002", "구직자003", "구직자004", "구직자005",
            "알바꿈나무", "야간전문가", "서비스킹", "친화력갑", "성실이",
            "책임감짱", "밝은미소", "활발한성격", "차분한매력", "프로워커",
            "경험많아요", "배우고싶어요", "열심히할게요", "믿음직한", "든든한동료",
            "소통왕", "팀워크좋아", "적응빨라", "꼼꼼해요", "센스있어요",
            "유머있어요", "긍정적", "도전정신", "성장지향", "안정추구"
        ]
        
        for i in range(count):
            age = random.randint(20, 35)
            experience_level = self.determine_experience_level(age)
            
            profile = {
                'user_id': str(uuid.uuid4()),
                'nickname': member_nicknames[i] if i < len(member_nicknames) else f'구직자{i+1:03d}',
                'real_name': f'김{random.choice(["민준", "서윤", "도윤", "예은", "시우", "하은", "주원", "지유", "건우", "서현"])}',
                'age': age,
                'gender': random.choice(['MALE', 'FEMALE']),
                'experience_level': experience_level,
                'desired_pay_amount': random.randint(2500000, 6000000),
                'desired_business_types': random.sample(self.business_types, k=random.randint(2, 5)),
                'desired_areas': random.sample([area for areas in self.areas.values() for area in areas], 
                                             k=random.randint(2, 4)),
                'desired_working_days': random.sample(['월', '화', '수', '목', '금', '토', '일'], 
                                                    k=random.randint(3, 6)),
                'available_time': random.choice([
                    '오후 6시 ~ 오전 2시', '오후 8시 ~ 오전 3시', 
                    '오후 9시 ~ 오전 4시', '오후 7시 ~ 오전 1시'
                ]),
                'profile_image_urls': self.generate_picsum_urls(count=random.randint(1, 3), width=300, height=400),
                'self_introduction': self.generate_self_introduction(experience_level),
                'alcohol_tolerance': random.choice(['상', '중', '하', '불가']),
                'work_style': random.choice(['적극적', '차분함', '친근함', '전문적']),
                'special_skills': random.sample([
                    '외국어', '음악', '댄스', '서비스', '요리', '칵테일', '사진'
                ], k=random.randint(0, 3)),
                'transportation': random.choice(['지하철', '버스', '택시', '자차', '도보']),
                'created_at': self.random_date_within_days(60),
                'is_job_seeking': True
            }
            
            profiles.append(profile)
        
        return profiles

    def generate_star_profiles(self, count=20):
        """스타 프로필 생성"""
        profiles = []
        
        star_names = [
            "김스타", "박프리미엄", "이골든", "최다이아", "정플래티넘",
            "장크라운", "윤킹", "임퀸", "한에이스", "강베스트",
            "오마스터", "서프로", "권엘리트", "조로얄", "신그랜드",
            "황럭셔리", "문프라임", "안슈퍼", "유톱", "송VIP"
        ]
        
        for i in range(count):
            category = random.choice(self.star_categories)
            
            # 스타 등급에 따른 가격
            star_level = random.choice(['신인', '일반', '인기', '탑급'])
            if star_level == '신인':
                price_range = (500000, 1000000)
            elif star_level == '일반':
                price_range = (1000000, 2000000) 
            elif star_level == '인기':
                price_range = (2000000, 5000000)
            else:  # 탑급
                price_range = (5000000, 10000000)
            
            profile = {
                'user_id': str(uuid.uuid4()),
                'stage_name': star_names[i] if i < len(star_names) else f'스타{i+1:03d}',
                'real_name': f'{random.choice(["김", "이", "박", "최", "정"])}{random.choice(["민수", "지영", "현우", "수진", "태민", "예린"])}',
                'age': random.randint(22, 40),
                'gender': random.choice(['MALE', 'FEMALE']),
                'category': category,
                'star_level': star_level,
                'price_per_hour': random.randint(price_range[0], price_range[1]),
                'experience_years': random.randint(1, 15),
                'profile_image_urls': self.generate_picsum_urls(count=random.randint(3, 6), width=400, height=500),
                'specialties': random.sample(self.star_skills, k=random.randint(2, 4)),
                'performance_areas': random.sample([area for areas in self.areas.values() for area in areas], 
                                                 k=random.randint(2, 5)),
                'available_days': random.sample(['월', '화', '수', '목', '금', '토', '일'], 
                                              k=random.randint(4, 7)),
                'performance_duration': random.choice(['30분', '1시간', '2시간', '3시간', '협의가능']),
                'introduction': f"{star_level} {category}로 활동하고 있습니다. {random.choice(['프로페셜한', '열정적인', '창의적인', '매력적인'])} 퍼포먼스를 선보입니다.",
                'portfolio_urls': [
                    f"https://picsum.photos/800/600?random={random.randint(5000, 9999)}",
                    f"https://picsum.photos/800/600?random={random.randint(5000, 9999)}"
                ],
                'rating': round(random.uniform(3.5, 5.0), 1),
                'total_bookings': random.randint(10, 500),
                'created_at': self.random_date_within_days(180),
                'is_available': True
            }
            
            profiles.append(profile)
        
        return profiles

    def generate_user_profiles(self, count=40):
        """일반 유저 프로필 생성 (고객용)"""
        profiles = []
        
        user_nicknames = [
            "고객001", "고객002", "고객003", "즐거운밤", "파티러버",
            "나이트킹", "클럽마스터", "바호핑", "소셜라이프", "네트워커",
            "엔터테이너", "비즈니스맨", "프리미엄고객", "VIP회원", "단골손님",
            "야간활동가", "문화생활러", "트렌드세터", "라이프스타일", "익스피어런스",
            "모임주최자", "이벤트러", "셀럽워처", "핫플레이스", "인사이더",
            "소셜미디어", "인플루언서", "크리에이터", "비지니스오너", "투자자",
            "스타트업", "프리랜서", "아티스트", "디자이너", "마케터",
            "기획자", "프로듀서", "매니저", "컨설턴트", "어드바이저"
        ]
        
        for i in range(count):
            age = random.randint(25, 50)
            
            # 나이대별 특성
            if age < 30:
                user_type = random.choice(['학생', '직장인', '프리랜서'])
                budget_range = (100000, 500000)
            elif age < 40:
                user_type = random.choice(['직장인', '사업가', '전문직'])
                budget_range = (200000, 1000000)
            else:
                user_type = random.choice(['사업가', '임원', '투자자'])
                budget_range = (500000, 2000000)
            
            profile = {
                'user_id': str(uuid.uuid4()),
                'nickname': user_nicknames[i] if i < len(user_nicknames) else f'유저{i+1:03d}',
                'age': age,
                'gender': random.choice(['MALE', 'FEMALE']),
                'user_type': user_type,
                'preferred_areas': random.sample([area for areas in self.areas.values() for area in areas], 
                                                k=random.randint(2, 4)),
                'preferred_business_types': random.sample(self.business_types, k=random.randint(2, 6)),
                'budget_range': f"{budget_range[0]:,}원 ~ {budget_range[1]:,}원",
                'visit_frequency': random.choice(['주 1회', '주 2-3회', '월 2-3회', '월 1회', '비정기']),
                'preferred_time': random.choice([
                    '오후 7-9시', '오후 9-11시', '오후 11시-새벽 1시', '새벽 1시 이후'
                ]),
                'group_size': random.choice(['혼자', '2-3명', '4-6명', '7-10명', '10명 이상']),
                'interests': random.sample([
                    '음악감상', '댄스', '네트워킹', '비즈니스미팅', 
                    '친목도모', '스트레스해소', '문화체험', '새로운경험'
                ], k=random.randint(2, 4)),
                'profile_image_urls': self.generate_picsum_urls(count=random.randint(1, 2), width=300, height=300),
                'membership_level': random.choice(['일반', '실버', '골드', 'VIP', 'VVIP']),
                'total_visits': random.randint(5, 200),
                'average_spending': random.randint(budget_range[0], budget_range[1]),
                'created_at': self.random_date_within_days(365),
                'is_active': True
            }
            
            profiles.append(profile)
        
        return profiles

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

    def generate_self_introduction(self, experience_level):
        """경력별 자기소개"""
        intros = {
            'NEWCOMER': [
                "처음이지만 열심히 배우겠습니다. 성실하게 일하겠습니다.",
                "신입이지만 빠르게 적응할 자신 있습니다.",
                "경험은 없지만 배우려는 의지는 누구보다 강합니다."
            ],
            'JUNIOR': [
                "6개월 정도 경험 있습니다. 더 발전하고 싶어서 지원했습니다.",
                "비슷한 업종에서 일해본 경험이 있어 빠르게 적응 가능합니다.",
                "기본적인 서비스는 할 수 있습니다."
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

    def random_date_within_days(self, days):
        """지정된 일수 내의 랜덤 날짜 생성"""
        start_date = datetime.now() - timedelta(days=days)
        random_days = random.randint(0, days)
        return (start_date + timedelta(days=random_days)).isoformat()

    def save_all_data(self):
        """모든 데이터 생성 및 저장"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # 1. 모든 프로필 생성
        print("🏢 업체 프로필 생성 중...")
        places = self.generate_place_profiles(50)
        print(f"✅ {len(places)}개 업체 프로필 생성 완료")
        
        print("\n👤 구직자 프로필 생성 중...")
        members = self.generate_member_profiles(30)
        print(f"✅ {len(members)}개 구직자 프로필 생성 완료")
        
        print("\n⭐ 스타 프로필 생성 중...")
        stars = self.generate_star_profiles(20)
        print(f"✅ {len(stars)}개 스타 프로필 생성 완료")
        
        print("\n👥 유저 프로필 생성 중...")
        users = self.generate_user_profiles(40)
        print(f"✅ {len(users)}개 유저 프로필 생성 완료")
        
        # 2. 개별 데이터 저장
        datasets = {
            'places': places,
            'members': members,
            'stars': stars,
            'users': users
        }
        
        filenames = {}
        for data_type, data in datasets.items():
            filename = f"complete_nightjob_{data_type}_{timestamp}.json"
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            filenames[data_type] = filename
            print(f"📄 {data_type} 데이터 저장: {filename}")
        
        # 3. 통합 데이터 저장
        combined_data = {
            **datasets,
            'generated_at': datetime.now().isoformat(),
            'totals': {k: len(v) for k, v in datasets.items()},
            'features': [
                'picsum_images_only',
                'star_profiles',
                'user_profiles', 
                'realistic_scenarios',
                'complete_nightjob_ecosystem'
            ]
        }
        
        combined_filename = f"complete_nightjob_all_{timestamp}.json"
        with open(combined_filename, 'w', encoding='utf-8') as f:
            json.dump(combined_data, f, ensure_ascii=False, indent=2)
        print(f"📄 통합 데이터 저장: {combined_filename}")
        
        return filenames, combined_filename, datasets

def main():
    print("🌙 완전한 밤알바 생태계 데이터 생성기")
    print("=" * 70)
    print("📸 모든 이미지: picsum.photos 통일")
    print("🎯 포함 데이터: 업체, 구직자, 스타, 유저")
    print()
    
    generator = CompleteNightjobDataGenerator()
    filenames, combined_filename, datasets = generator.save_all_data()
    
    print("\n" + "="*70)
    print("🎉 완전한 밤알바 데이터 생성 완료!")
    print(f"📊 총 {sum(len(data) for data in datasets.values())}개 프로필")
    print()
    for data_type, data in datasets.items():
        print(f"   {data_type}: {len(data)}개")
    
    print(f"\n📁 생성된 파일:")
    for data_type, filename in filenames.items():
        print(f"   - {filename}")
    print(f"   - {combined_filename}")
    
    print(f"\n🖼️ 모든 이미지가 picsum.photos로 통일되었습니다!")
    print("✅ 이제 Supabase에 삽입할 준비가 완료되었습니다.")

if __name__ == "__main__":
    main()
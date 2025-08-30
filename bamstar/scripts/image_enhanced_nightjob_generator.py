#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
이미지 포함 밤알바 데이터 생성기
프로필 이미지 URL과 함께 현실적인 테스트 데이터 생성
"""

import json
import random
import csv
from datetime import datetime, timedelta
import uuid
import requests
from urllib.parse import urlparse, urljoin
import os

class ImageEnhancedNightJobGenerator:
    def __init__(self):
        # 기존 데이터 로드
        self.load_existing_data()
        
        # 무료 이미지 API들
        self.image_sources = {
            'unsplash': 'https://source.unsplash.com',
            'picsum': 'https://picsum.photos',
            'placeholder': 'https://via.placeholder.com'
        }
        
        # 업체용 이미지 카테고리
        self.place_image_categories = [
            'restaurant', 'bar', 'nightclub', 'lounge', 'cafe', 'interior',
            'modern-bar', 'luxury-restaurant', 'night-scene', 'city-lights'
        ]
        
        # 사람 이미지 카테고리 (구직자용)
        self.person_image_categories = [
            'person', 'portrait', 'professional', 'young-adult', 'smiling',
            'business-casual', 'service-worker', 'friendly-face'
        ]

    def load_existing_data(self):
        """기존 생성된 데이터 로드"""
        try:
            with open('nightjob_places_20250830_205110.json', 'r', encoding='utf-8') as f:
                self.places_data = json.load(f)
            
            with open('nightjob_members_20250830_205110.json', 'r', encoding='utf-8') as f:
                self.members_data = json.load(f)
            
            print(f"📁 기존 데이터 로드: 업체 {len(self.places_data)}개, 구직자 {len(self.members_data)}개")
            
        except Exception as e:
            print(f"❌ 기존 데이터 로드 실패: {e}")
            self.places_data = []
            self.members_data = []

    def generate_image_urls(self, count=3, category='business', width=400, height=300):
        """다양한 소스에서 이미지 URL 생성"""
        image_urls = []
        
        for i in range(count):
            # 랜덤하게 이미지 소스 선택
            source_type = random.choice(['unsplash', 'picsum', 'placeholder'])
            
            if source_type == 'unsplash':
                # Unsplash - 고품질 이미지
                url = f"{self.image_sources['unsplash']}/{width}x{height}/?{category}"
                
            elif source_type == 'picsum':
                # Lorem Picsum - 랜덤 이미지
                seed = random.randint(1000, 9999)
                url = f"{self.image_sources['picsum']}/{width}/{height}?random={seed}"
                
            else:
                # Placeholder - 심플한 플레이스홀더
                color = random.choice(['FF5733', '33C3FF', 'FF33F1', '33FF57', 'FFD700'])
                url = f"{self.image_sources['placeholder']}/{width}x{height}/{color}/FFFFFF?text=Profile"
            
            image_urls.append(url)
        
        return image_urls

    def enhance_places_with_images(self):
        """업체 데이터에 이미지 추가"""
        print("\n🖼️ 업체 프로필에 이미지 추가 중...")
        
        enhanced_places = []
        
        for place in self.places_data:
            # 업종에 맞는 이미지 카테고리 선택
            business_type = place['business_type'].lower()
            
            if '클럽' in business_type or 'club' in business_type:
                category = 'nightclub'
            elif 'bar' in business_type or '바' in business_type:
                category = 'bar'
            elif '룸' in business_type or '노래' in business_type:
                category = 'karaoke'
            elif '마사지' in business_type:
                category = 'spa'
            else:
                category = random.choice(self.place_image_categories)
            
            # 이미지 URLs 생성 (2-4개)
            image_count = random.randint(2, 4)
            place['profile_image_urls'] = self.generate_image_urls(
                count=image_count, 
                category=category,
                width=600,
                height=400
            )
            
            # 추가 메타데이터
            place['has_images'] = True
            place['image_count'] = len(place['profile_image_urls'])
            place['main_image'] = place['profile_image_urls'][0] if place['profile_image_urls'] else None
            
            enhanced_places.append(place)
        
        self.places_data = enhanced_places
        print(f"✅ {len(enhanced_places)}개 업체에 이미지 추가 완료")

    def enhance_members_with_images(self):
        """구직자 데이터에 이미지 추가"""
        print("\n👤 구직자 프로필에 이미지 추가 중...")
        
        enhanced_members = []
        
        for member in self.members_data:
            # 성별에 따른 이미지 카테고리
            gender = member.get('gender', 'MALE')
            
            if gender == 'FEMALE':
                category = 'woman'
            else:
                category = 'man'
            
            # 나이대에 따른 세부 카테고리
            age = member.get('age', 25)
            if age < 25:
                category += ',young'
            elif age > 30:
                category += ',mature'
            
            # 이미지 URLs 생성 (1-3개)
            image_count = random.randint(1, 3)
            member['profile_image_urls'] = self.generate_image_urls(
                count=image_count,
                category=category,
                width=300,
                height=400
            )
            
            # 추가 메타데이터
            member['has_images'] = True
            member['image_count'] = len(member['profile_image_urls'])
            member['main_image'] = member['profile_image_urls'][0] if member['profile_image_urls'] else None
            
            enhanced_members.append(member)
        
        self.members_data = enhanced_members
        print(f"✅ {len(enhanced_members)}개 구직자에 이미지 추가 완료")

    def add_additional_nightjob_details(self):
        """밤알바 특성에 맞는 추가 정보"""
        print("\n🌙 밤알바 특화 정보 추가 중...")
        
        # 업체에 추가 정보
        for place in self.places_data:
            place.update({
                'dress_code': random.choice(['자유복장', '깔끔한복장', '정장', '업체복장제공']),
                'alcohol_service': random.choice([True, False]),
                'private_rooms': random.choice([True, False]),
                'vip_service': random.choice([True, False]),
                'reservation_required': random.choice([True, False]),
                'peak_hours': random.choice(['오후 9시-12시', '오후 10시-2시', '오후 11시-3시']),
                'staff_count': random.randint(5, 30),
                'customer_age_range': random.choice(['20-30대', '30-40대', '20-40대', '전연령']),
                'atmosphere': random.choice(['고급스러운', '편안한', '활기찬', '조용한', '트렌디한'])
            })
        
        # 구직자에 추가 정보
        for member in self.members_data:
            member.update({
                'available_dress_codes': random.sample(['자유복장', '깔끔한복장', '정장'], k=random.randint(1, 3)),
                'alcohol_tolerance': random.choice(['상', '중', '하', '불가']),
                'preferred_customer_age': random.choice(['20대', '30대', '40대', '무관']),
                'work_style': random.choice(['적극적', '차분함', '친근함', '전문적']),
                'special_skills': random.sample(['외국어', '음악', '댄스', '서비스', '요리'], k=random.randint(0, 3)),
                'transportation': random.choice(['지하철', '버스', '택시', '자차', '도보']),
                'emergency_contact': f"010-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}"
            })

    def create_realistic_scenarios(self):
        """현실적인 시나리오 데이터 추가"""
        print("\n🎭 현실적인 시나리오 추가 중...")
        
        # 실제 업체명 스타일로 변경
        realistic_names = [
            "강남 프리미엄 라운지", "홍대 클럽 에이스", "압구정 로얄바", 
            "이태원 VIP룸", "건대 골든클럽", "신촌 다이아몬드", 
            "역삼 플래티넘", "논현 크라운", "청담 임페리얼",
            "서초 엘리트", "잠실 프라임", "강동 럭셔리"
        ]
        
        for i, place in enumerate(self.places_data[:len(realistic_names)]):
            place['place_name'] = realistic_names[i]
            
        # 실제 급여 패턴으로 조정
        for place in self.places_data:
            business_type = place['business_type']
            
            # 업종별 현실적인 급여 설정
            if '룸싸롱' in business_type:
                base_min = random.randint(4000000, 6000000)
                base_max = base_min + random.randint(2000000, 4000000)
            elif '클럽' in business_type:
                base_min = random.randint(3000000, 4500000) 
                base_max = base_min + random.randint(1500000, 3000000)
            elif 'BAR' in business_type or '바' in business_type:
                base_min = random.randint(2500000, 4000000)
                base_max = base_min + random.randint(1000000, 2500000)
            else:
                base_min = random.randint(2000000, 3500000)
                base_max = base_min + random.randint(1000000, 2000000)
                
            place['offered_min_pay'] = base_min
            place['offered_max_pay'] = base_max

    def save_enhanced_data(self):
        """향상된 데이터 저장"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Places 데이터 저장
        places_filename = f"enhanced_nightjob_places_{timestamp}.json"
        with open(places_filename, 'w', encoding='utf-8') as f:
            json.dump(self.places_data, f, ensure_ascii=False, indent=2)
        print(f"📄 향상된 업체 데이터 저장: {places_filename}")
        
        # Members 데이터 저장
        members_filename = f"enhanced_nightjob_members_{timestamp}.json"
        with open(members_filename, 'w', encoding='utf-8') as f:
            json.dump(self.members_data, f, ensure_ascii=False, indent=2)
        print(f"📄 향상된 구직자 데이터 저장: {members_filename}")
        
        # 통합 데이터 저장
        combined_data = {
            'places': self.places_data,
            'members': self.members_data,
            'generated_at': datetime.now().isoformat(),
            'total_places': len(self.places_data),
            'total_members': len(self.members_data),
            'features': [
                'profile_images',
                'realistic_scenarios', 
                'nightjob_specifics',
                'enhanced_metadata'
            ]
        }
        
        combined_filename = f"enhanced_nightjob_combined_{timestamp}.json"
        with open(combined_filename, 'w', encoding='utf-8') as f:
            json.dump(combined_data, f, ensure_ascii=False, indent=2)
        print(f"📄 통합 데이터 저장: {combined_filename}")
        
        return places_filename, members_filename, combined_filename

    def show_enhanced_samples(self):
        """향상된 데이터 샘플 출력"""
        print("\n🌟 이미지 포함 데이터 샘플:")
        
        print("\n🏢 업체 샘플 (이미지 포함):")
        for i, place in enumerate(self.places_data[:3]):
            print(f"\n{i+1}. {place['place_name']}")
            print(f"   업종: {place['business_type']}")
            print(f"   주소: {place['address']}")
            print(f"   급여: {place['offered_min_pay']:,}원 ~ {place['offered_max_pay']:,}원")
            print(f"   근무시간: {place['work_time']}")
            print(f"   분위기: {place.get('atmosphere', 'N/A')}")
            print(f"   이미지 수: {place.get('image_count', 0)}개")
            if place.get('profile_image_urls'):
                print(f"   메인 이미지: {place['profile_image_urls'][0]}")
        
        print("\n👤 구직자 샘플 (이미지 포함):")
        for i, member in enumerate(self.members_data[:3]):
            print(f"\n{i+1}. {member['nickname']} ({member['age']}세, {member['gender']})")
            print(f"   경력: {member['experience_level']}")
            print(f"   희망급여: {member['desired_pay_amount']:,}원")
            print(f"   주류 허용도: {member.get('alcohol_tolerance', 'N/A')}")
            print(f"   이미지 수: {member.get('image_count', 0)}개")
            if member.get('profile_image_urls'):
                print(f"   메인 이미지: {member['profile_image_urls'][0]}")

def main():
    print("🌙 이미지 포함 밤알바 데이터 생성기")
    print("=" * 60)
    
    generator = ImageEnhancedNightJobGenerator()
    
    if not generator.places_data or not generator.members_data:
        print("❌ 기존 데이터가 없습니다. 먼저 기본 데이터를 생성해주세요.")
        return
    
    # 1. 이미지 추가
    generator.enhance_places_with_images()
    generator.enhance_members_with_images()
    
    # 2. 밤알바 특화 정보 추가
    generator.add_additional_nightjob_details()
    
    # 3. 현실적인 시나리오 적용
    generator.create_realistic_scenarios()
    
    # 4. 데이터 저장
    print("\n💾 향상된 데이터 저장 중...")
    places_file, members_file, combined_file = generator.save_enhanced_data()
    
    # 5. 샘플 출력
    generator.show_enhanced_samples()
    
    print(f"\n🎉 이미지 포함 밤알바 데이터 생성 완료!")
    print(f"📊 총 {len(generator.places_data)}개 업체 + {len(generator.members_data)}개 구직자")
    print(f"🖼️ 모든 프로필에 이미지 URL 포함")
    print(f"📁 생성된 파일들:")
    print(f"   - {places_file}")
    print(f"   - {members_file}")
    print(f"   - {combined_file}")

if __name__ == "__main__":
    main()
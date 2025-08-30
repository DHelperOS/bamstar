#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fox알바 Selenium 스크래핑 스크립트
밤알바 매칭 테스트 데이터 생성용
"""

from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import json
import time
import random
from datetime import datetime
import csv

class SeleniumFoxAlbaScraper:
    def __init__(self):
        self.base_url = "https://www.foxalba.com"
        self.setup_driver()
    
    def setup_driver(self):
        """Chrome WebDriver 설정"""
        chrome_options = Options()
        chrome_options.add_argument('--headless=new')  # 백그라운드 실행
        chrome_options.add_argument('--no-sandbox')
        chrome_options.add_argument('--disable-dev-shm-usage')
        chrome_options.add_argument('--disable-blink-features=AutomationControlled')
        chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
        chrome_options.add_experimental_option('useAutomationExtension', False)
        chrome_options.add_argument('--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
        
        service = Service(ChromeDriverManager().install())
        self.driver = webdriver.Chrome(service=service, options=chrome_options)
        
        # WebDriver 감지 방지
        self.driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
    
    def scrape_job_list(self, max_pages=3):
        """구인정보 리스트 페이지 스크래핑"""
        all_jobs = []
        
        try:
            # 메인 페이지로 이동해서 세션 시작
            print("🌐 Fox알바 메인 페이지로 이동 중...")
            self.driver.get(self.base_url)
            time.sleep(3)
            
            # 구인정보 페이지로 이동
            job_list_url = "https://www.foxalba.com/offer/offer_list.asp"
            
            for page in range(1, max_pages + 1):
                print(f"📄 페이지 {page} 스크래핑 중...")
                
                url = f"{job_list_url}?page={page}"
                self.driver.get(url)
                time.sleep(2)
                
                print(f"📄 현재 페이지 제목: {self.driver.title}")
                
                # 페이지 로드 대기
                try:
                    WebDriverWait(self.driver, 10).until(
                        lambda driver: driver.execute_script("return document.readyState") == "complete"
                    )
                except Exception as e:
                    print(f"⚠️ 페이지 로드 대기 실패: {e}")
                
                # 다양한 방법으로 구인정보 요소들 찾기
                job_elements = self.find_job_elements()
                
                if job_elements:
                    print(f"📋 발견된 구인정보: {len(job_elements)}개")
                    
                    for element in job_elements:
                        job_data = self.extract_job_data_selenium(element)
                        if job_data:
                            all_jobs.append(job_data)
                            print(f"✅ 수집: {job_data.get('title', 'Unknown')}")
                else:
                    print(f"❌ 페이지 {page}에서 구인정보를 찾을 수 없습니다.")
                    
                    # 디버깅: 페이지 소스 일부 출력
                    page_source = self.driver.page_source[:1000]
                    print(f"📝 페이지 소스 샘플: {page_source}...")
                
                # 페이지 간 딜레이
                time.sleep(random.uniform(2, 4))
            
            return all_jobs
            
        except Exception as e:
            print(f"❌ 스크래핑 중 오류 발생: {e}")
            return all_jobs
    
    def find_job_elements(self):
        """다양한 셀렉터로 구인정보 요소들 찾기"""
        job_elements = []
        
        # 시도할 셀렉터들
        selectors = [
            "tr.bg_white, tr.bg_gray",
            ".job-item",
            ".offer-item", 
            "table tr:not(:first-child)",
            "tbody tr",
            ".list-item",
            "[class*='job']",
            "[class*='offer']"
        ]
        
        for selector in selectors:
            try:
                elements = self.driver.find_elements(By.CSS_SELECTOR, selector)
                if elements:
                    print(f"🎯 셀렉터 '{selector}'로 {len(elements)}개 요소 발견")
                    job_elements = elements
                    break
            except Exception as e:
                print(f"⚠️ 셀렉터 '{selector}' 실패: {e}")
                continue
        
        return job_elements
    
    def extract_job_data_selenium(self, element):
        """Selenium 요소에서 데이터 추출"""
        try:
            data = {}
            
            # 요소 내 모든 텍스트 추출
            text_content = element.text.strip()
            if not text_content:
                return None
            
            # td 요소들 찾기
            tds = element.find_elements(By.TAG_NAME, "td")
            
            if len(tds) >= 3:
                # 테이블 구조로 파싱
                data['title'] = tds[0].text.strip() if len(tds) > 0 else ''
                data['location'] = tds[1].text.strip() if len(tds) > 1 else ''
                data['salary'] = tds[2].text.strip() if len(tds) > 2 else ''
                data['time'] = tds[3].text.strip() if len(tds) > 3 else ''
                data['date'] = tds[4].text.strip() if len(tds) > 4 else ''
            else:
                # 전체 텍스트에서 정보 추출
                lines = text_content.split('\n')
                data['title'] = lines[0] if len(lines) > 0 else text_content
                data['raw_text'] = text_content
            
            # 링크 찾기
            try:
                link_element = element.find_element(By.TAG_NAME, "a")
                data['url'] = link_element.get_attribute("href")
            except:
                pass
            
            # 필수 데이터 검증
            if data.get('title') or data.get('raw_text'):
                return data
                
        except Exception as e:
            print(f"⚠️ 데이터 추출 오류: {e}")
        
        return None
    
    def convert_to_nightjob_data(self, jobs_data):
        """수집된 데이터를 밤알바 매칭 데이터로 변환"""
        matching_data = []
        
        nightjob_types = [
            '룸', '퍼블릭', '강남클럽', '홍대클럽', 'KTV', '노래방', 
            '바', '호스트바', '주점', '카페', '라운지', '하이퍼블릭',
            '텐카페', '셔츠룸', '비즈니스클럽', '마사지', '안마',
            '유흥주점', '단란주점', '나이트클럽'
        ]
        
        areas = [
            '강남', '홍대', '이태원', '건대', '신촌', '명동', '압구정', 
            '청담', '논현', '역삼', '선릉', '삼성', '방배', '서초',
            '종로', '을지로', '동대문', '잠실', '송파', '강동',
            '마포', '용산', '성북', '강북'
        ]
        
        for idx, job in enumerate(jobs_data):
            place_profile = {
                'user_id': f'nightjob_place_{idx + 1}',
                'place_name': self.generate_place_name(nightjob_types),
                'business_type': random.choice(nightjob_types),
                'address': f'서울시 {random.choice(areas)}구',
                'latitude': None,
                'longitude': None,
                'manager_gender': random.choice(['남', '여']),
                'offered_min_pay': random.randint(150000, 300000),  # 밤알바 급여 수준
                'offered_max_pay': random.randint(300000, 800000),
                'desired_experience_level': random.choice(['NEWCOMER', 'JUNIOR', 'INTERMEDIATE']),
                'profile_image_urls': [],
                'work_time': random.choice(['오후 6시~오전 2시', '오후 8시~오전 4시', '오후 9시~오전 3시']),
                'job_description': job.get('title', job.get('raw_text', ''))[:100],
                'posted_date': datetime.now().strftime('%Y-%m-%d'),
                'original_data': job
            }
            
            matching_data.append(place_profile)
        
        return matching_data
    
    def generate_place_name(self, business_types):
        """업종별 적절한 업체명 생성"""
        prefixes = ['프리미엄', '고급', '로얄', '빅', '탑', '프라임', 'VIP', '골드', '플래티넘']
        suffixes = ['클럽', '라운지', '바', '룸', 'KTV', '퍼블릭', '카페']
        areas = ['강남', '홍대', '압구정', '청담', '이태원', '건대', '신촌']
        
        name_patterns = [
            f"{random.choice(prefixes)}{random.choice(areas)}{random.choice(suffixes)}",
            f"{random.choice(areas)}{random.choice(prefixes)}{random.choice(suffixes)}",
            f"{random.choice(['클럽', '바', '룸'])}{random.choice(['A', 'B', 'M', 'K', 'J'])}"
        ]
        
        return random.choice(name_patterns)
    
    def save_data(self, data, filename_prefix="nightjob_data"):
        """데이터 저장"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # JSON 저장
        json_filename = f"{filename_prefix}_{timestamp}.json"
        with open(json_filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"📄 JSON 파일 저장: {json_filename}")
        
        # CSV 저장
        if data:
            csv_filename = f"{filename_prefix}_{timestamp}.csv"
            with open(csv_filename, 'w', newline='', encoding='utf-8') as f:
                writer = csv.DictWriter(f, fieldnames=data[0].keys())
                writer.writeheader()
                writer.writerows(data)
            print(f"📊 CSV 파일 저장: {csv_filename}")
        
        return json_filename, csv_filename
    
    def close(self):
        """드라이버 종료"""
        if self.driver:
            self.driver.quit()

def main():
    """메인 실행 함수"""
    print("🌙 밤알바 매칭 데이터 수집 시작!")
    
    scraper = SeleniumFoxAlbaScraper()
    
    try:
        # 1. Fox알바에서 데이터 수집
        print("\n📋 Fox알바 구인정보 수집 중...")
        jobs_data = scraper.scrape_job_list(max_pages=3)
        
        if not jobs_data:
            print("❌ 실제 데이터 수집 실패. 가상 데이터를 생성합니다.")
            # 가상 데이터 생성
            jobs_data = [
                {'title': f'밤알바 구인 {i}', 'raw_text': f'구인정보 {i}'} 
                for i in range(1, 21)
            ]
        
        print(f"\n✅ 총 {len(jobs_data)}개의 구인정보를 수집했습니다.")
        
        # 2. 원본 데이터 저장
        print("\n💾 원본 데이터 저장 중...")
        scraper.save_data(jobs_data, "foxalba_raw")
        
        # 3. 밤알바 매칭 데이터로 변환
        print("\n🔄 밤알바 매칭 데이터로 변환 중...")
        matching_data = scraper.convert_to_nightjob_data(jobs_data)
        
        # 4. 매칭 데이터 저장
        print("\n💾 매칭 데이터 저장 중...")
        scraper.save_data(matching_data, "nightjob_matching")
        
        # 5. 샘플 데이터 출력
        print("\n🌙 생성된 밤알바 매칭 데이터 샘플:")
        for i, job in enumerate(matching_data[:5]):
            print(f"\n{i+1}. {job.get('place_name', 'Unknown')}")
            print(f"   업종: {job.get('business_type', 'Unknown')}")
            print(f"   지역: {job.get('address', 'Unknown')}")
            print(f"   급여: {job.get('offered_min_pay', 0):,}원 ~ {job.get('offered_max_pay', 0):,}원")
            print(f"   시간: {job.get('work_time', 'Unknown')}")
        
        print(f"\n🎉 데이터 생성 완료! 총 {len(matching_data)}개의 밤알바 매칭 데이터를 생성했습니다.")
        
    finally:
        scraper.close()

if __name__ == "__main__":
    main()
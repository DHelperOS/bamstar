#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fox알바 구인정보 스크래핑 스크립트
매칭 테스트 데이터 생성용
"""

import requests
from bs4 import BeautifulSoup
import json
import time
import random
from urllib.parse import urljoin, urlparse
import csv
from datetime import datetime

class FoxAlbaScraper:
    def __init__(self):
        self.base_url = "https://www.foxalba.com"
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'Accept-Language': 'ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7',
            'Accept-Encoding': 'gzip, deflate, br',
            'DNT': '1',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'Sec-Fetch-Dest': 'document',
            'Sec-Fetch-Mode': 'navigate',
            'Sec-Fetch-Site': 'none',
            'Sec-Fetch-User': '?1',
            'Cache-Control': 'max-age=0'
        })
        
        # 첫 방문으로 세션 쿠키 받기
        try:
            self.session.get(self.base_url)
        except:
            pass
        
    def scrape_job_list(self, max_pages=3):
        """구인정보 리스트 페이지 스크래핑"""
        all_jobs = []
        
        for page in range(1, max_pages + 1):
            print(f"📄 페이지 {page} 스크래핑 중...")
            
            url = f"https://www.foxalba.com/offer/offer_list.asp?page={page}"
            
            try:
                response = self.session.get(url)
                response.raise_for_status()
                soup = BeautifulSoup(response.content, 'html.parser')
                
                # HTML 구조 디버깅
                print(f"🔍 페이지 {page} HTML 구조 확인...")
                print(f"📄 Title: {soup.title.string if soup.title else 'No title'}")
                
                # 다양한 방법으로 구인정보 항목들 찾기 시도
                job_items = []
                
                # 방법 1: table row 찾기
                job_items = soup.find_all('tr', class_=['bg_white', 'bg_gray'])
                
                # 방법 2: div 기반으로 찾기
                if not job_items:
                    job_items = soup.find_all('div', class_=['job-item', 'job_list', 'offer-item'])
                
                # 방법 3: 일반적인 테이블 구조 찾기
                if not job_items:
                    tables = soup.find_all('table')
                    for table in tables:
                        rows = table.find_all('tr')
                        if len(rows) > 1:  # 헤더 제외하고 데이터가 있는지 확인
                            job_items = rows[1:]  # 첫 번째는 헤더이므로 제외
                            break
                
                # 방법 4: 모든 tr 태그 찾기
                if not job_items:
                    job_items = soup.find_all('tr')[1:] if soup.find_all('tr') else []
                
                print(f"📋 발견된 항목 수: {len(job_items)}")
                
                if not job_items:
                    # 응답 내용 일부 출력 (디버깅용)
                    print(f"📝 응답 내용 샘플: {str(soup)[:500]}...")
                    continue
                
                for item in job_items:
                    job_data = self.extract_job_data(item)
                    if job_data:
                        all_jobs.append(job_data)
                        print(f"✅ 수집: {job_data.get('company_name', 'Unknown')} - {job_data.get('job_title', 'Unknown')}")
                
                # 요청 간 딜레이 (서버 부하 방지)
                time.sleep(random.uniform(1, 2))
                
            except requests.RequestException as e:
                print(f"❌ 페이지 {page} 스크래핑 실패: {e}")
                continue
        
        return all_jobs
    
    def extract_job_data(self, item):
        """개별 구인정보 데이터 추출"""
        try:
            data = {}
            
            # 모든 td 요소들을 가져와서 순서대로 파싱
            tds = item.find_all('td')
            
            if len(tds) >= 4:
                # 일반적인 구인정보 테이블 구조 추정
                data['company_name'] = tds[0].get_text(strip=True) if len(tds) > 0 else ''
                data['job_title'] = tds[1].get_text(strip=True) if len(tds) > 1 else ''
                data['location'] = tds[2].get_text(strip=True) if len(tds) > 2 else ''
                data['salary'] = tds[3].get_text(strip=True) if len(tds) > 3 else ''
                data['work_time'] = tds[4].get_text(strip=True) if len(tds) > 4 else ''
                data['posted_date'] = tds[5].get_text(strip=True) if len(tds) > 5 else ''
                
                # 상세 링크 찾기
                link_elem = item.find('a')
                if link_elem and link_elem.get('href'):
                    data['detail_url'] = urljoin(self.base_url, link_elem['href'])
            else:
                # class 기반으로 시도
                # 회사명/업체명
                company_elem = item.find('td', class_='company') or item.find(text=lambda t: t and '회사' in str(t))
                if company_elem:
                    data['company_name'] = company_elem.get_text(strip=True) if hasattr(company_elem, 'get_text') else str(company_elem).strip()
                
                # 모든 텍스트 추출해서 분석
                all_text = item.get_text(strip=True)
                if all_text:
                    # 텍스트가 있으면 임시로 저장
                    data['raw_text'] = all_text
                    data['company_name'] = data.get('company_name', 'Unknown')
                    data['job_title'] = all_text[:50] + '...' if len(all_text) > 50 else all_text
            
            # 기본 검증: 최소한 텍스트가 있는지 확인
            if data.get('company_name') or data.get('job_title') or data.get('raw_text'):
                return data
            
        except Exception as e:
            print(f"⚠️ 데이터 추출 오류: {e}")
        
        return None
    
    def convert_to_matching_data(self, jobs_data):
        """Fox알바 데이터를 매칭 서비스용 데이터로 변환"""
        matching_data = []
        
        for idx, job in enumerate(jobs_data):
            # Place Profile 데이터로 변환
            place_profile = {
                'user_id': f'foxalba_place_{idx + 1}',
                'place_name': job.get('company_name', ''),
                'business_type': self.extract_business_type(job.get('job_title', '')),
                'address': job.get('location', ''),
                'latitude': None,  # 실제 서비스에서는 주소를 좌표로 변환 필요
                'longitude': None,
                'manager_gender': random.choice(['남', '여']),  # 임의 생성
                'offered_min_pay': self.extract_min_salary(job.get('salary', '')),
                'offered_max_pay': self.extract_max_salary(job.get('salary', '')),
                'desired_experience_level': random.choice(['NEWCOMER', 'JUNIOR', 'INTERMEDIATE']),
                'profile_image_urls': [],  # 실제 이미지 URL 필요시 추가
                'work_time': job.get('work_time', ''),
                'job_description': job.get('job_title', ''),
                'posted_date': job.get('posted_date', ''),
                'detail_url': job.get('detail_url', '')
            }
            
            matching_data.append(place_profile)
        
        return matching_data
    
    def extract_business_type(self, job_title):
        """직무 제목에서 업종 추출"""
        business_types = {
            '카페': ['카페', '커피', '스타벅스', '이디야', '할리스'],
            '음식점': ['음식점', '식당', '요리', '주방', '서빙', '홀', '치킨', '피자', '한식', '중식', '일식', '양식'],
            '편의점': ['편의점', 'GS25', 'CU', '세븐일레븐', '미니스톱'],
            '마트': ['마트', '이마트', '롯데마트', '홈플러스', '코스트코'],
            '학원': ['학원', '교습', '과외', '강사', '선생'],
            '사무직': ['사무', '관리', '회계', '경리', '총무'],
            '판매직': ['판매', '영업', '고객상담', '텔레마케팅'],
            '서비스직': ['청소', '경비', '배달', '운전', '택배'],
        }
        
        for business_type, keywords in business_types.items():
            if any(keyword in job_title for keyword in keywords):
                return business_type
        
        return '기타'
    
    def extract_min_salary(self, salary_text):
        """급여 텍스트에서 최소 급여 추출"""
        try:
            # 숫자만 추출
            import re
            numbers = re.findall(r'\d+', salary_text.replace(',', ''))
            if numbers:
                return int(numbers[0])
        except:
            pass
        return 10000  # 기본값
    
    def extract_max_salary(self, salary_text):
        """급여 텍스트에서 최대 급여 추출"""
        try:
            import re
            numbers = re.findall(r'\d+', salary_text.replace(',', ''))
            if len(numbers) >= 2:
                return int(numbers[-1])
            elif len(numbers) == 1:
                return int(numbers[0]) + 2000  # 최소급여 + 2000원
        except:
            pass
        return 12000  # 기본값
    
    def save_data(self, data, filename_prefix="foxalba_jobs"):
        """데이터를 JSON과 CSV 파일로 저장"""
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

def main():
    """메인 실행 함수"""
    print("🦊 Fox알바 구인정보 스크래핑 시작!")
    
    scraper = FoxAlbaScraper()
    
    # 1. 구인정보 리스트 스크래핑 (3페이지)
    print("\n📋 구인정보 리스트 스크래핑 중...")
    jobs_data = scraper.scrape_job_list(max_pages=3)
    
    if not jobs_data:
        print("❌ 스크래핑된 데이터가 없습니다.")
        return
    
    print(f"\n✅ 총 {len(jobs_data)}개의 구인정보를 수집했습니다.")
    
    # 2. 원본 데이터 저장
    print("\n💾 원본 데이터 저장 중...")
    scraper.save_data(jobs_data, "foxalba_raw")
    
    # 3. 매칭 서비스용 데이터로 변환
    print("\n🔄 매칭 서비스용 데이터로 변환 중...")
    matching_data = scraper.convert_to_matching_data(jobs_data)
    
    # 4. 변환된 데이터 저장
    print("\n💾 매칭 데이터 저장 중...")
    scraper.save_data(matching_data, "foxalba_matching")
    
    # 5. 샘플 데이터 출력
    print("\n📄 수집된 데이터 샘플:")
    for i, job in enumerate(jobs_data[:3]):
        print(f"\n{i+1}. {job.get('company_name', 'Unknown')}")
        print(f"   제목: {job.get('job_title', 'Unknown')}")
        print(f"   지역: {job.get('location', 'Unknown')}")
        print(f"   급여: {job.get('salary', 'Unknown')}")
    
    print(f"\n🎉 스크래핑 완료! 총 {len(jobs_data)}개의 구인정보를 수집했습니다.")
    print("📁 생성된 파일들을 확인해보세요.")

if __name__ == "__main__":
    main()
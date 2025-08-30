#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
밤알바 테스트 데이터를 Supabase에 삽입하는 스크립트
"""

import json
import random
import psycopg2
from datetime import datetime
import uuid

def connect_to_supabase():
    """Supabase PostgreSQL 연결"""
    connection_string = "postgresql://postgres.tflvicpgyycvhttctcek:!@Wnrsmsek1@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres"
    
    try:
        conn = psycopg2.connect(connection_string)
        print("✅ Supabase 연결 성공!")
        return conn
    except Exception as e:
        print(f"❌ Supabase 연결 실패: {e}")
        return None

def create_users_and_profiles(conn, places_data, members_data):
    """사용자 계정과 프로필을 생성"""
    cursor = conn.cursor()
    
    try:
        print("\n👥 사용자 계정 생성 중...")
        
        # Place 사용자들 생성
        place_users = []
        for place in places_data:
            user_data = {
                'id': place['user_id'],
                'email': f"place_{place['user_id'][:8]}@nightjob.test",
                'role_id': 2,  # Place role
                'created_at': place['created_at'],
                'updated_at': place['created_at']
            }
            place_users.append(user_data)
        
        # Member 사용자들 생성  
        member_users = []
        for member in members_data:
            user_data = {
                'id': member['user_id'],
                'email': f"member_{member['user_id'][:8]}@nightjob.test",
                'role_id': 1,  # Member role
                'created_at': member['created_at'],
                'updated_at': member['created_at']
            }
            member_users.append(user_data)
        
        # Users 테이블에 삽입
        all_users = place_users + member_users
        print(f"📝 {len(all_users)}개 사용자 계정 삽입 중...")
        
        for user in all_users:
            cursor.execute("""
                INSERT INTO users (id, email, role_id, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (id) DO UPDATE SET
                email = EXCLUDED.email,
                role_id = EXCLUDED.role_id,
                updated_at = EXCLUDED.updated_at
            """, (user['id'], user['email'], user['role_id'], user['created_at'], user['updated_at']))
        
        conn.commit()
        print(f"✅ {len(all_users)}개 사용자 계정 삽입 완료")
        
        return place_users, member_users
        
    except Exception as e:
        print(f"❌ 사용자 생성 실패: {e}")
        conn.rollback()
        return [], []

def insert_place_profiles(conn, places_data):
    """Place 프로필 데이터 삽입"""
    cursor = conn.cursor()
    
    try:
        print(f"\n🏢 {len(places_data)}개 업체 프로필 삽입 중...")
        
        for place in places_data:
            cursor.execute("""
                INSERT INTO place_profiles (
                    user_id, place_name, business_type, address, latitude, longitude,
                    manager_gender, offered_min_pay, offered_max_pay, desired_experience_level,
                    profile_image_urls, created_at, updated_at
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (user_id) DO UPDATE SET
                place_name = EXCLUDED.place_name,
                business_type = EXCLUDED.business_type,
                address = EXCLUDED.address,
                updated_at = EXCLUDED.updated_at
            """, (
                place['user_id'],
                place['place_name'],
                place['business_type'],
                place['address'],
                place['latitude'],
                place['longitude'],
                place['manager_gender'],
                place['offered_min_pay'],
                place['offered_max_pay'],
                place['desired_experience_level'],
                json.dumps(place['profile_image_urls']),
                place['created_at'],
                datetime.now().isoformat()
            ))
        
        conn.commit()
        print(f"✅ {len(places_data)}개 업체 프로필 삽입 완료")
        
    except Exception as e:
        print(f"❌ 업체 프로필 삽입 실패: {e}")
        conn.rollback()

def insert_member_profiles(conn, members_data):
    """Member 프로필 데이터 삽입"""
    cursor = conn.cursor()
    
    try:
        print(f"\n👤 {len(members_data)}개 구직자 프로필 삽입 중...")
        
        for member in members_data:
            cursor.execute("""
                INSERT INTO member_profiles (
                    user_id, real_name, gender, age, experience_level,
                    desired_pay_amount, desired_working_days, profile_image_urls,
                    created_at, updated_at
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (user_id) DO UPDATE SET
                real_name = EXCLUDED.real_name,
                gender = EXCLUDED.gender,
                age = EXCLUDED.age,
                updated_at = EXCLUDED.updated_at
            """, (
                member['user_id'],
                member['nickname'],  # real_name으로 사용
                member['gender'],
                member['age'],
                member['experience_level'],
                member['desired_pay_amount'],
                json.dumps(member['desired_working_days']),
                json.dumps(member['profile_image_urls']),
                member['created_at'],
                datetime.now().isoformat()
            ))
        
        conn.commit()
        print(f"✅ {len(members_data)}개 구직자 프로필 삽입 완료")
        
    except Exception as e:
        print(f"❌ 구직자 프로필 삽입 실패: {e}")
        conn.rollback()

def verify_data(conn):
    """삽입된 데이터 검증"""
    cursor = conn.cursor()
    
    try:
        print("\n🔍 데이터 검증 중...")
        
        # 사용자 수 확인
        cursor.execute("SELECT COUNT(*) FROM users")
        user_count = cursor.fetchone()[0]
        print(f"👥 총 사용자: {user_count}명")
        
        # 역할별 사용자 수 확인
        cursor.execute("SELECT r.name, COUNT(u.id) FROM users u JOIN roles r ON u.role_id = r.id GROUP BY r.name")
        role_counts = cursor.fetchall()
        for role_name, count in role_counts:
            print(f"   {role_name}: {count}명")
        
        # 프로필 수 확인
        cursor.execute("SELECT COUNT(*) FROM place_profiles")
        place_count = cursor.fetchone()[0]
        print(f"🏢 업체 프로필: {place_count}개")
        
        cursor.execute("SELECT COUNT(*) FROM member_profiles")
        member_count = cursor.fetchone()[0]
        print(f"👤 구직자 프로필: {member_count}개")
        
        # 샘플 데이터 출력
        print("\n📋 삽입된 데이터 샘플:")
        cursor.execute("""
            SELECT pp.place_name, pp.business_type, pp.address, 
                   pp.offered_min_pay, pp.offered_max_pay
            FROM place_profiles pp 
            LIMIT 3
        """)
        
        places_sample = cursor.fetchall()
        print("\n🏢 업체 샘플:")
        for i, (name, btype, addr, min_pay, max_pay) in enumerate(places_sample, 1):
            print(f"{i}. {name} ({btype})")
            print(f"   주소: {addr}")
            print(f"   급여: {min_pay:,}원 ~ {max_pay:,}원")
        
        cursor.execute("""
            SELECT mp.real_name, mp.age, mp.gender, mp.experience_level, mp.desired_pay_amount
            FROM member_profiles mp
            LIMIT 3
        """)
        
        members_sample = cursor.fetchall()
        print("\n👤 구직자 샘플:")
        for i, (name, age, gender, exp, pay) in enumerate(members_sample, 1):
            print(f"{i}. {name} ({age}세, {gender})")
            print(f"   경력: {exp}, 희망급여: {pay:,}원")
        
    except Exception as e:
        print(f"❌ 데이터 검증 실패: {e}")

def main():
    print("🌙 밤알바 테스트 데이터 Supabase 삽입")
    print("=" * 50)
    
    # 1. 데이터 파일 로드
    try:
        with open('nightjob_places_20250830_205110.json', 'r', encoding='utf-8') as f:
            places_data = json.load(f)
        
        with open('nightjob_members_20250830_205110.json', 'r', encoding='utf-8') as f:
            members_data = json.load(f)
        
        print(f"📁 데이터 로드 완료: 업체 {len(places_data)}개, 구직자 {len(members_data)}개")
        
    except Exception as e:
        print(f"❌ 데이터 파일 로드 실패: {e}")
        return
    
    # 2. Supabase 연결
    conn = connect_to_supabase()
    if not conn:
        return
    
    try:
        # 3. 사용자 계정 생성
        place_users, member_users = create_users_and_profiles(conn, places_data, members_data)
        
        if place_users and member_users:
            # 4. Place 프로필 삽입
            insert_place_profiles(conn, places_data)
            
            # 5. Member 프로필 삽입  
            insert_member_profiles(conn, members_data)
            
            # 6. 데이터 검증
            verify_data(conn)
            
            print(f"\n🎉 데이터 삽입 완료!")
            print(f"📊 총 {len(places_data)}개 업체 + {len(members_data)}개 구직자")
            print("💡 이제 매칭 앱에서 실제 밤알바 데이터로 테스트할 수 있습니다!")
        
    finally:
        conn.close()
        print("\n🔗 Supabase 연결 종료")

if __name__ == "__main__":
    main()
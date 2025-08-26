# BamStar Project Overview

## 프로젝트 목적 (Project Purpose)
BamStar는 Flutter로 개발된 **한국어 기반 소셜 커뮤니티 모바일 앱**입니다.

### 주요 기능 (Key Features)
- **사용자 인증**: Google, Apple, Kakao 소셜 로그인
- **커뮤니티 시스템**: 게시글 작성, 댓글, 이미지 업로드
- **매칭 시스템**: 사용자 프로필 매칭 기능
- **실시간 채팅**: 채팅 페이지 구현
- **위치 기반**: 지역 설정 및 장소 홈페이지
- **이미지 처리**: Cloudinary 기반 이미지 업로드/처리
- **한국어 특화**: 비속어 필터링, Pretendard 폰트 사용

### 앱 구조 (App Structure)
- **온보딩**: 앱 소개 및 첫 실행 경험
- **로그인**: 소셜 로그인 지원
- **역할 선택**: 사용자 역할 설정
- **홈**: 메인 화면 (장소 기반)
- **커뮤니티**: 게시글 작성/조회/댓글
- **프로필**: 사용자 프로필 관리

### 기술적 특징 (Technical Features)
- Material 3 디자인 시스템 적용
- Supabase 백엔드 연동 (PostgreSQL, RLS, Edge Functions)
- Firebase Analytics 통합
- 다국어 지원 (한국어 중심)
- 크로스 플랫폼 (iOS, Android, Web, Desktop)
- 반응형 디자인 (모바일 우선, PC 대응)
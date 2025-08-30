# BamStar Project Overview

## Project Purpose
**BamStar** is a Flutter mobile dating/matching application with Supabase backend integration. The app focuses on connecting users based on matching preferences, location-based matching, and community features.

## Key Features
- **Member Matching System**: Location-based matching with preference algorithms
- **Community Platform**: Posts, comments, hashtags, channel system
- **Authentication**: Multi-provider auth (Apple, Google, Kakao)
- **Business Verification**: Professional verification system
- **Place Matching**: Location-based preference matching
- **Push Notifications**: Firebase messaging integration
- **Content Moderation**: Korean profanity filtering, image labeling
- **Analytics**: Firebase analytics integration

## Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.9.0+ (Dart)
- **State Management**: flutter_riverpod ^2.6.1 + flutter_bloc ^9.1.1
- **Navigation**: go_router ^16.1.0
- **UI Standards**: Material 3, solar_icons, Pretendard font
- **Image Processing**: cached_network_image, image_picker, cloudinary_url_gen

### Backend (Supabase)
- **Database**: PostgreSQL with RLS (Row Level Security)
- **Auth**: Supabase Auth with social providers
- **Storage**: Supabase Storage for images
- **Edge Functions**: Matching algorithms, content processing
- **Real-time**: Supabase real-time subscriptions

### External Services
- **Push Notifications**: Firebase Cloud Messaging
- **Analytics**: Firebase Analytics
- **Image Storage**: Cloudinary integration
- **AI**: Google ML Kit, Gemini integration
- **Maps**: Korean postal service (kpostal)

## Project Architecture
```
├── lib/
│   ├── scenes/           # UI pages/screens (by feature)
│   ├── providers/        # Riverpod state management
│   ├── services/         # Business logic & API calls
│   ├── models/           # Data models
│   ├── widgets/          # Reusable UI components
│   ├── utils/            # Helper functions
│   ├── theme/            # Design system
│   └── auth/             # Authentication logic
├── supabase/
│   ├── functions/        # Edge functions
│   └── migrations/       # Database migrations
└── assets/               # Static assets (images, fonts)
```

## Key Design Principles
- **Mobile-First**: Touch-optimized, responsive design
- **Clean Architecture**: Separation of concerns (UI → Providers → Services → Models)
- **Material 3 Compliance**: Modern Material Design principles
- **Korean Localization**: Korean language support throughout
- **Accessibility**: Inclusive design practices
# BamStar Database Reference - Complete Schema

**Last Updated:** 2025-08-28  
**Project:** BamStar  
**Project ID:** `tflvicpgyycvhttctcek`  
**Region:** Northeast Asia (Seoul)  
**Database:** PostgreSQL 15+ with Supabase extensions

---

## 📊 Database Overview

**Total Tables:** 24  
**Custom Functions:** 7+  
**Edge Functions:** 5  
**Custom Enums:** 3  
**Triggers:** Multiple (auto role assignment, updated_at management)

---

## 🗃️ Database Tables

### **Core User Management**

#### `users` - Main user accounts
```sql
CREATE TABLE users (
    id uuid PRIMARY KEY,
    role_id integer REFERENCES roles(id),
    ci text,
    is_adult boolean,
    email text,
    phone text,
    created_at timestamp with time zone DEFAULT now(),
    profile_img text,
    nickname text,
    index bigint,
    last_sign_in timestamp with time zone
);
```

#### `roles` - User roles and permissions
```sql
CREATE TABLE roles (
    id integer PRIMARY KEY,
    name text NOT NULL, -- 'GUEST', 'STAR', 'PLACE', 'MEMBER'
    kor_name text NOT NULL -- Korean display names
);
```
**Data:**
- 1: GUEST (게스트)
- 2: STAR (스타)
- 3: PLACE (플레이스)  
- 4: MEMBER (멤버)

#### `member_profiles` - Extended user profile information
```sql
CREATE TABLE member_profiles (
    user_id uuid PRIMARY KEY REFERENCES users(id),
    real_name text,
    gender gender_enum,
    contact_phone text,
    profile_image_urls text[],
    social_links jsonb,
    bio text,
    experience_level experience_level_enum,
    desired_pay_type pay_type_enum,
    desired_pay_amount integer,
    desired_working_days text[],
    available_from date,
    can_relocate boolean,
    level integer DEFAULT 1,
    experience_points bigint DEFAULT 0,
    title text DEFAULT '새로운 스타',
    updated_at timestamp with time zone DEFAULT now(),
    age smallint,
    matching_conditions jsonb
);
```

### **Authentication & Devices**

#### `devices` - User device tracking
```sql
CREATE TABLE devices (
    id bigint PRIMARY KEY,
    user_id uuid REFERENCES users(id),
    device_uuid text UNIQUE,
    device_os text,
    last_login_at timestamp with time zone
);
```

#### `push_tokens` - Firebase FCM tokens
```sql
CREATE TABLE push_tokens (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES users(id),
    fcm_token text NOT NULL,
    device_id text,
    platform text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Row Level Security Policies
ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read their own tokens
CREATE POLICY "Enable read access for users" ON push_tokens
    FOR SELECT USING (auth.uid() = user_id);

-- Allow authenticated users to insert tokens if user exists in users table
CREATE POLICY "Enable insert for authenticated users" ON push_tokens
    FOR INSERT WITH CHECK (
        auth.uid() IS NOT NULL AND
        EXISTS (SELECT 1 FROM public.users WHERE id = push_tokens.user_id)
    );

-- Allow users to update their own tokens
CREATE POLICY "Enable update for users" ON push_tokens
    FOR UPDATE USING (auth.uid() = user_id);

-- Allow users to delete their own tokens
CREATE POLICY "Enable delete for users" ON push_tokens
    FOR DELETE USING (auth.uid() = user_id);
```

### **Attributes & Preferences System**

#### `attributes` - Master attributes table
```sql
CREATE TABLE attributes (
    id integer PRIMARY KEY,
    type text NOT NULL, -- 'INDUSTRY', 'JOB_ROLE', 'MEMBER_STYLE', 'PLACE_FEATURE', 'WELFARE'
    type_kor text NOT NULL,
    name text NOT NULL,
    description text,
    icon_name text,
    is_active boolean DEFAULT true
);
```

#### `member_attributes_link` - Member personal styles/strengths
```sql
CREATE TABLE member_attributes_link (
    member_user_id uuid REFERENCES users(id),
    attribute_id integer REFERENCES attributes(id),
    PRIMARY KEY (member_user_id, attribute_id)
);
```

#### `member_preferences_link` - Member job/industry preferences
```sql
CREATE TABLE member_preferences_link (
    member_user_id uuid REFERENCES users(id), 
    attribute_id integer REFERENCES attributes(id),
    PRIMARY KEY (member_user_id, attribute_id)
);
```

### **Location System**

#### `main_categories` - Main area categories
```sql
CREATE TABLE main_categories (
    category_id integer PRIMARY KEY,
    name character varying NOT NULL
);
```

#### `area_groups` - Area groupings by category
```sql
CREATE TABLE area_groups (
    group_id integer PRIMARY KEY,
    category_id integer REFERENCES main_categories(category_id),
    name character varying NOT NULL
);
```

#### `area_keywords` - Keywords for area matching
```sql
CREATE TABLE area_keywords (
    keyword_id integer PRIMARY KEY,
    keyword character varying NOT NULL,
    group_id integer REFERENCES area_groups(group_id)
);
```

#### `member_preferred_area_groups` - Member area preferences
```sql
CREATE TABLE member_preferred_area_groups (
    member_user_id uuid REFERENCES users(id),
    group_id integer REFERENCES area_groups(group_id),
    PRIMARY KEY (member_user_id, group_id)
);
```

### **Community System**

#### `community_posts` - User posts
```sql
CREATE TABLE community_posts (
    id bigint PRIMARY KEY,
    author_id uuid REFERENCES users(id),
    content text,
    is_anonymous boolean DEFAULT false,
    image_urls text[],
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    view_count integer DEFAULT 0
);
```

#### `community_comments` - Post comments with threading
```sql
CREATE TABLE community_comments (
    id bigint PRIMARY KEY,
    post_id bigint REFERENCES community_posts(id),
    author_id uuid REFERENCES users(id),
    content text,
    is_anonymous boolean DEFAULT false,
    parent_comment_id bigint REFERENCES community_comments(id),
    created_at timestamp with time zone DEFAULT now(),
    image_url text[]
);
```

#### `community_likes` - Likes for posts and comments
```sql
CREATE TABLE community_likes (
    id bigint PRIMARY KEY,
    user_id uuid REFERENCES users(id),
    post_id bigint REFERENCES community_posts(id),
    comment_id bigint REFERENCES community_comments(id),
    created_at timestamp with time zone DEFAULT now()
);
```

#### `community_hashtags` - Hashtag definitions
```sql
CREATE TABLE community_hashtags (
    id integer PRIMARY KEY,
    name text UNIQUE NOT NULL,
    category text,
    post_count integer DEFAULT 0,
    subscriber_count integer DEFAULT 0,
    last_used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    description text
);
```

#### `post_hashtags` - Post-hashtag relationships
```sql
CREATE TABLE post_hashtags (
    post_id bigint REFERENCES community_posts(id),
    hashtag_id integer REFERENCES community_hashtags(id),
    PRIMARY KEY (post_id, hashtag_id)
);
```

#### `community_subscriptions` - User hashtag/member subscriptions
```sql
CREATE TABLE community_subscriptions (
    id bigint PRIMARY KEY,
    subscriber_id uuid REFERENCES users(id),
    target_hashtag_id integer REFERENCES community_hashtags(id),
    target_member_id uuid REFERENCES users(id),
    created_at timestamp with time zone DEFAULT now()
);
```

#### `community_reports` - Content reporting system
```sql
CREATE TABLE community_reports (
    id bigint PRIMARY KEY,
    reporter_id uuid REFERENCES users(id),
    reported_post_id bigint REFERENCES community_posts(id),
    reported_user_id uuid REFERENCES users(id),
    report_reason text NOT NULL,
    report_details text,
    status text DEFAULT 'PENDING',
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
```

#### `user_blocks` - User blocking system
```sql
CREATE TABLE user_blocks (
    id bigint PRIMARY KEY,
    blocker_id uuid REFERENCES users(id),
    blocked_user_id uuid REFERENCES users(id),
    reason text,
    created_at timestamp with time zone DEFAULT now()
);
```

### **Hashtag Analytics**

#### `daily_hashtag_curation` - AI-curated trending data
```sql
CREATE TABLE daily_hashtag_curation (
    curation_date date PRIMARY KEY,
    trending_hashtags jsonb,
    ai_suggestions jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
```

#### `trending_hashtags_cache` - Performance cache for trending hashtags
```sql
CREATE TABLE trending_hashtags_cache (
    cache_key text PRIMARY KEY,
    hashtags jsonb NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);
```

### **Terms & Agreements**

#### `terms` - Terms and conditions documents
```sql
CREATE TABLE terms (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    title text NOT NULL,
    description text,
    content text NOT NULL,
    type text NOT NULL, -- 'PRIVACY', 'TERMS', 'MARKETING' etc.
    category text,
    version text NOT NULL,
    is_active boolean DEFAULT true,
    display_order integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
```

#### `user_term_agreements` - User agreement tracking
```sql
CREATE TABLE user_term_agreements (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES users(id),
    term_id uuid REFERENCES terms(id),
    is_agreed boolean NOT NULL,
    agreed_at timestamp with time zone,
    version_agreed text,
    ip_address inet,
    user_agent text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
```

---

## 🔢 Custom Enums

### `gender_enum`
```sql
CREATE TYPE gender_enum AS ENUM ('MALE', 'FEMALE', 'OTHER');
```

### `experience_level_enum`
```sql
CREATE TYPE experience_level_enum AS ENUM ('NEWBIE', 'JUNIOR', 'SENIOR', 'PROFESSIONAL');
```

### `pay_type_enum`
```sql
CREATE TYPE pay_type_enum AS ENUM ('TC', 'DAILY', 'WEEKLY', 'MONTHLY', 'NEGOTIABLE');
```

---

## ⚙️ Database Functions

### `add_experience_points(user_id_in uuid, points_to_add integer)`
Adds experience points to user and handles level-up logic with title updates.

### `analyze_hashtag_trends(days_back integer, min_usage_count integer)`
Analyzes hashtag usage trends over specified time period.

### `update_member_profile_and_conditions(...)`
Transactional function to update member profile and all related conditions (attributes, preferences, area groups) in a single operation.

---

## 🔄 Key Triggers

### Role Assignment Trigger
```sql
-- Automatically assigns GUEST role (id=1) to new users if role_id is NULL
CREATE OR REPLACE FUNCTION set_default_guest_role()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role_id IS NULL THEN
    SELECT r.id INTO NEW.role_id FROM public.roles r WHERE r.name = 'GUEST';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on users table
CREATE TRIGGER trg_users_default_role
    BEFORE INSERT ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION set_default_guest_role();
```

### Default Subscription Trigger
```sql
-- Automatically subscribes new users to default hashtag channels
CREATE OR REPLACE FUNCTION subscribe_default_channels_on_signup()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert default subscription for hashtag ID 8 ('오늘의tmi')
    INSERT INTO public.community_subscriptions (subscriber_id, target_hashtag_id)
    VALUES (NEW.id, 8)
    ON CONFLICT DO NOTHING; -- Prevent duplicate subscriptions
    
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Log errors but don't fail the user creation
        RAISE NOTICE 'Error creating default subscription for user %: %', NEW.id, SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on users table (AFTER INSERT to ensure user exists)
CREATE TRIGGER on_user_created_subscribe_default
    AFTER INSERT ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION subscribe_default_channels_on_signup();
```

### Updated At Triggers
Multiple tables have automatic `updated_at` timestamp triggers.

---

## 🚀 Edge Functions

1. **`image-safety-web`** - Image content moderation
2. **`cloudinary-signature`** - Image upload signature generation  
3. **`hashtag-processor`** - Hashtag extraction and processing
4. **`daily-hashtag-curation`** - AI-powered hashtag trend analysis
5. **`update-matching-conditions`** - Member profile and matching conditions updater

---

## 📝 Important Notes

### Role-Based Access
- **GUEST (1)**: Limited read access, can browse content
- **STAR (2)**: Full member access, can create profiles and apply to jobs  
- **PLACE (3)**: Business account, can post job listings
- **MEMBER (4)**: Extended member features

### Matching System
The `matching_conditions` JSONB field in `member_profiles` stores structured matching criteria:
```json
{
  "MUST_HAVE": ["requirements..."],
  "ENVIRONMENT": {
    "workplace_features": ["..."],
    "location_preferences": ["..."]
  },
  "PEOPLE": {
    "team_dynamics": ["..."],
    "communication_style": ["..."]
  },
  "AVOID": ["exclusions..."]
}
```

### Performance Considerations
- Hashtag trend data is cached in `trending_hashtags_cache`
- Daily curation runs automated analysis
- Experience point calculations use row-level locking
- All timestamp fields have automatic timezone handling

---

## 🔧 Maintenance Commands

See `SUPABASE_CONNECTION_GUIDE.md` for connection details and `SUPABASE_MANAGEMENT_GUIDE.md` for operational procedures.

---

**This document reflects the actual production database schema as of 2025-08-28. All table structures, functions, and relationships have been verified via direct database connection.**
# Master Prompt for Laravel Developer: Kids Entertainment Streaming Platform Backend & Admin Panel

> **Instructions for the Developer:**  
> Copy and read this specification carefully. You are tasked with developing a production-grade, scalable Laravel 11+ REST API and Filament v3 Admin Dashboard to power an existing Flutter Mobile (iOS/Android) and Android TV streaming client.

---

## 1. Project Context & Objectives
You are building the official backend for a multi-platform Kids Entertainment Streaming Platform:
- **Client Applications:** Flutter Mobile (Phones & Tablets) and Flutter Android TV (10-foot UI with D-pad remote navigation).
- **Guest-First Philosophy:** Unauthenticated users (guests) can freely browse public categories and stream public videos with zero friction. No forced registration.
- **Admin-Controlled Gating:** Administrators can dynamically configure which categories and platform features require user authentication.
- **Admin Dashboard:** A modern, high-speed CMS built with **Filament v3** (TALL stack: Tailwind, Alpine, Laravel, Livewire) for managing categories, videos, live TV channels, YouTube playlists, hero banners, and feature permissions.

---

## 2. Technical Stack Requirements
- **Framework:** Laravel 11.x on PHP 8.3+
- **Database:** PostgreSQL or MySQL 8.0+ (Use UUIDs for all primary keys)
- **Cache & Queues:** Redis (for session caching, rate limiting, and buffered video view counters)
- **API Authentication:** Laravel Sanctum (Bearer Token authentication for Flutter clients + Session auth for Filament Admin)
- **Admin Panel:** Filament v3 (`filament/filament:^3.2`)
- **Media Storage:** AWS S3 or Cloudflare R2 with CloudFront/Cloudflare CDN

---

## 3. Database Architecture & Migrations

### 3.1 `users`
- `id`: UUID (Primary Key)
- `name`: String
- `email`: String (Unique)
- `password`: String (Hashed via bcrypt/argon2id)
- `role`: Enum (`admin`, `user`) - default: `user`
- `avatar_url`: String (Nullable)
- `created_at`, `updated_at`: Timestamps

### 3.2 `categories`
- `id`: UUID (Primary Key)
- `name`: String (e.g., "Rhymes", "Cartoons", "Sports", "Live TV")
- `slug`: String (Unique, slugified)
- `description`: Text (Nullable)
- `icon_name`: String (e.g., `music_note`, `cruelty_free`, `sports_soccer`)
- `thumbnail_url`: String (Nullable)
- `color_hex`: String (default: `#6657E8`)
- `display_order`: Integer (default: 0)
- `is_featured`: Boolean (default: false)
- `is_visible`: Boolean (default: true)
- **`requires_login`**: Boolean (default: false) — *When true, guests cannot browse/stream this category without signing in*
- **`allow_favorites`**: Boolean (default: true)
- **`allow_sharing`**: Boolean (default: true)
- `created_at`, `updated_at`: Timestamps

### 3.3 `content_items` (Universal Video Management)
- `id`: UUID (Primary Key)
- `title`: String
- `description`: Text (Nullable)
- `thumbnail_url`: String
- `category_id`: UUID (Foreign Key -> `categories.id`, nullable on delete set null)
- `content_type`: Enum (`video`, `youtube_video`, `youtube_channel`, `live_stream`, `external_url`, `website_link`, `playlist`)
- `source_url`: Text (MP4 direct URL, HLS `.m3u8` manifest, YouTube video ID/URL)
- `duration_seconds`: Integer (default: 0)
- `views_count`: BigInteger (default: 0)
- `is_featured`: Boolean (default: false)
- `is_visible`: Boolean (default: true)
- `display_order`: Integer (default: 0)
- `tags`: JSON (default: `[]`)
- `extra_metadata`: JSON (default: `{}`)
- `created_at`, `updated_at`: Timestamps

### 3.4 `banners` (Hero Carousel)
- `id`: UUID (Primary Key)
- `title`: String
- `subtitle`: String (Nullable)
- `image_url`: String
- `action_type`: Enum (`content`, `category`, `external`, `live`)
- `action_target`: String (UUID of content/category or external URL)
- `display_order`: Integer (default: 0)
- `is_active`: Boolean (default: true)
- `created_at`, `updated_at`: Timestamps

### 3.5 `live_channels` (24/7 Kids Channels)
- `id`: UUID (Primary Key)
- `name`: String
- `stream_url`: Text (HLS `.m3u8` stream)
- `web_stream_url`: Text (Nullable MP4/web fallback)
- `logo_url`: String
- `channel_number`: String (Nullable, e.g., "01", "02")
- `category_id`: UUID (Foreign Key -> `categories.id`, nullable)
- `current_program`: String (Nullable)
- `is_active`: Boolean (default: true)
- `display_order`: Integer (default: 0)
- `created_at`, `updated_at`: Timestamps

### 3.6 `youtube_channels`
- `id`: UUID (Primary Key)
- `title`: String
- `channel_id`: String (Unique)
- `channel_url`: String
- `thumbnail_url`: String
- `subscriber_count`: String (Nullable, e.g., "175M")
- `video_count`: Integer (default: 0)
- `is_featured`: Boolean (default: false)
- `display_order`: Integer (default: 0)
- `created_at`, `updated_at`: Timestamps

### 3.7 `feature_permissions` (Admin-Controlled Feature Matrix)
- `feature_key`: String (Primary Key, e.g., `browse_videos`, `watch_videos`, `favorites`, `likes`, `watch_history`, `continue_watching`, `restricted_categories`, `search`, `share_videos`)
- `requires_login`: Boolean (default: false)
- `description`: String (Nullable)
- `updated_at`: Timestamp

### 3.8 User Interaction Tables (Authenticated Users Only)
- **`favorites`**: `id` (UUID), `user_id` (FK -> users), `content_item_id` (FK -> content_items), `created_at`. Unique index on `(user_id, content_item_id)`.
- **`video_likes`**: `id` (UUID), `user_id` (FK -> users), `content_item_id` (FK -> content_items), `created_at`. Unique index on `(user_id, content_item_id)`.
- **`watch_history`**: `id` (UUID), `user_id` (FK -> users), `content_item_id` (FK -> content_items), `last_position_seconds` (Int), `total_duration_seconds` (Int), `completed` (Bool), `updated_at`. Unique index on `(user_id, content_item_id)`.

---

## 4. API Endpoints Specification

All API endpoints must be prefixed with `/api/v1/` and return clean, standard JSON:
```json
{
  "success": true,
  "data": { ... },
  "message": "Optional status message"
}
```

### 4.1 Authentication (Sanctum)
- `POST /api/v1/auth/register` (name, email, password) -> `{user, token}`
- `POST /api/v1/auth/login` (email, password) -> `{user, token}`
- `POST /api/v1/auth/logout` (auth:sanctum) -> revoke token
- `POST /api/v1/auth/forgot-password` (email) -> send reset link
- `GET /api/v1/auth/profile` (auth:sanctum) -> current user info

### 4.2 Content & Streaming (Public / Guest Allowed)
- `GET /api/v1/categories` -> List visible categories. Include `requires_login`, `allow_favorites`, `allow_sharing`.
- `GET /api/v1/categories/{id}` -> Category details + content items. **Middleware Check**: If `requires_login == true` and the request has no valid Sanctum token, return HTTP 403:
  ```json
  {
    "success": false,
    "error_code": "LOGIN_REQUIRED",
    "message": "This category is reserved for Kids TV members. Please sign in to watch."
  }
  ```
- `GET /api/v1/content` -> Filterable items (`?category_id=...&is_featured=1&search=...&limit=20&page=1`).
- `GET /api/v1/content/{id}` -> Content item details + like count + `is_liked` (bool) + `is_favorite` (bool).
- `POST /api/v1/content/{id}/views` -> Increment views counter (buffered in Redis).
- `GET /api/v1/banners` -> Active home banners.
- `GET /api/v1/live-channels` -> Active 24/7 channels.
- `GET /api/v1/youtube-channels` -> Curated YouTube creators.
- `GET /api/v1/features/permissions` -> Key-value map of feature auth requirements.

### 4.3 User Personal Library (Requires `auth:sanctum`)
- `GET /api/v1/user/favorites` -> User's saved videos.
- `POST /api/v1/user/favorites/{content_id}` -> Toggle favorite. Return `{is_favorite: boolean}`.
- `POST /api/v1/user/likes/{content_id}` -> Toggle like. Return `{is_liked: boolean, likes_count: integer}`.
- `GET /api/v1/user/watch-history` -> Continue watching items sorted by latest activity.
- `POST /api/v1/user/watch-history` -> Upsert playback position (`content_id`, `position_seconds`, `total_duration_seconds`).
- `DELETE /api/v1/user/watch-history` -> Clear user's watch history.

---

## 5. Filament v3 Admin Panel Requirements

Install Filament v3 via `php artisan filament:install --panels`. Create the following resources:

1. **`CategoryResource`**:
   - Fields: Name (auto-slug), icon name dropdown, thumbnail image upload, color picker hex.
   - Access & Security Section:
     - `Toggle::make('is_visible')->label('Enable Category')->default(true)`
     - `Toggle::make('requires_login')->label('Require User Login (Guest Gate)')->default(false)`
     - `Toggle::make('is_featured')->label('Show on Homepage')->default(false)`
     - `Toggle::make('allow_favorites')->label('Allow Favorites')->default(true)`
     - `Toggle::make('allow_sharing')->label('Allow Sharing')->default(true)`
   - Reordering support (`spatie/eloquent-sortable` or Filament table reorder).

2. **`ContentItemResource`**:
   - Polymorphic inputs based on `content_type`:
     - If `video`: File upload to S3 or direct MP4 URL.
     - If `youtube_video`: YouTube URL or Video ID.
     - If `live_stream`: HLS M3U8 URL.
   - Thumbnail upload or automated YouTube thumbnail grabber.
   - Tags multi-select, duration in seconds, category dropdown, featured & visibility switches.

3. **`BannerResource`**:
   - Hero banner upload, title, subtitle, target action (content, category, live, external).

4. **`LiveChannelResource`**:
   - Name, HLS stream URL, MP4 fallback, logo upload, channel number, current program name.

5. **`FeaturePermissionsPage` (Custom Filament Page)**:
   - Live matrix of switches for all 9 platform features (`browse_videos`, `watch_videos`, `favorites`, `likes`, `watch_history`, `continue_watching`, `restricted_categories`, `search`, `share_videos`).
   - Toggling updates the database in real time.

6. **Admin Authorization**:
   - Enforce that only users with `role = 'admin'` can log in or access `/admin`.

---

## 6. Implementation Checklist & Acceptance Criteria
- [ ] Laravel 11 project bootstrapped with Sanctum & Filament v3.
- [ ] Database migrations with UUIDs and seeders matching initial 11 categories (Sports seeded with `requires_login = true`).
- [ ] All public endpoints accessible to unauthenticated guests with 0 CORS issues.
- [ ] `requires_login` category gate returns 403 `LOGIN_REQUIRED` when accessed without bearer token.
- [ ] Filament admin panel fully operational at `/admin`.
- [ ] Media uploads streamable with correct `video/mp4` and `application/x-mpegURL` content types.
- [ ] Postman / OpenAPI collection provided covering all endpoints.

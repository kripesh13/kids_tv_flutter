# Kids TV - Kids Entertainment Streaming Platform 🚀📺👶

A modern, colorful, secure, and child-friendly Kids Entertainment Streaming Platform built with **Flutter** and **Supabase**. The platform seamlessly powers both **Mobile Applications (Android / iOS / Tablets)** and **Android TV Applications (10-foot Leanback Experience)** from a unified clean architecture codebase.

---

## 🌟 Key Features

### 1. Unified Multi-Platform Codebase
* **Mobile & Tablets**:
  * Touch-first, bouncy, kid-friendly design system.
  * Rounded cards, soft shadows, vibrant gradient categories.
  * Auto-playing featured billboard carousel with animated indicator dots.
  * Bottom navigation: Home, Categories, Live TV, YouTube, Search.
* **Android TV (Leanback 10-ft Experience)**:
  * High-contrast cinematic dark palette (`#0E101A`, `#161928`).
  * Full D-pad remote control navigation (Up, Down, Left, Right, Select/Enter, Back, Media controls).
  * Expandable Left Sidebar Navigation (`TvShell`).
  * `TvFocusable` engine: Smooth focus scaling (1.06x), glowing gold border (`#FFB84D`), ambient drop-shadow, and automatic view-centering (`Scrollable.ensureVisible`).
  * Instant Platform Mode Switcher pill (`TV Mode` ↔ `Mobile Mode`) on any screen for direct testing.

### 2. Supabase Backend & Role-Based Access Control (RBAC)
* **Zero Barrier for Kids & Parents**: Regular users require no login or account creation to stream any published content.
* **Secure Admin Authentication**: Powered by Supabase Auth with Row Level Security (RLS) enforcement.
* **Granular Roles**:
  * 👑 **Super Admin**: Complete platform ownership, RBAC user role administration.
  * 🛡️ **Admin**: Full content, category, banner, live TV, and app settings management.
  * ✏️ **Editor**: Create and update content and categories (deletion restricted).
  * 👁️ **Viewer**: Read-only public streaming access.
* **Dynamic Local Fallback & Seed Data**: Out-of-the-box working experience with rich cartoons, nursery rhymes, live TV test streams, and YouTube channels, with seamless live Supabase synchronization when credentials are provided.

### 3. Dynamic Category Management
* Categories are 100% dynamic and managed via the Admin Dashboard.
* **Reorderable List View**: Drag and drop categories to reorder them; changes instantly reflect on Mobile and Android TV.
* Supports name, slug, description, theme color hex, Material icon selector, thumbnail URL, visibility toggle, and homepage featured status.

### 4. Universal Content Management System
* Flexible content model supporting:
  * Self-uploaded / direct video URLs (MP4 / WebM)
  * External video URLs
  * YouTube videos and channels
  * 24/7 Live HLS streams (`.m3u8`)
  * Interactive website links & playlists
  * Future custom media types via extensible JSONB metadata.
* Real-time search, multi-filter by category and content type, view counter tracking, and instant visibility toggles.

### 5. Media Playback & Live TV
* Universal player supporting MP4, WebM, and Live HLS streams.
* 10-second seek forward/backward, scrub timeline, duration formatter, and autoplay next video.
* TV Player with remote-focused controls, high contrast, and channel flipping.

---

## 🎨 Design System

| Role | Color | Hex |
|---|---|---|
| Primary Magic | Purple | `#6657E8` |
| Sunny Amber | Secondary | `#FFB84D` |
| Coral Delight | Accent | `#FF6B81` |
| Clouds Background | Background | `#F7F8FF` |
| Midnight Navy | Text | `#252344` |
| Emerald Fun | Success | `#42C98A` |
| TV Background | Deep Navy | `#0E101A` |
| TV Focus Border | Gold Glow | `#FFB84D` |

---

## 📂 Project Architecture

Feature-first Clean Architecture with Riverpod & GoRouter:

```
lib/
├── core/
│   ├── config/           # Supabase & Environment dynamic credentials
│   ├── constants/        # Storage keys & Hive configuration
│   ├── router/           # GoRouter declarative navigation with adaptive root
│   ├── theme/            # Mobile playful theme & Android TV dark theme
│   ├── tv/               # Android TV D-pad focus engine & remote key handler
│   └── utils/            # Duration formatting & responsive helpers
├── data/
│   ├── datasources/      # Supabase PostgREST client & rich seed fallback
│   ├── models/           # Category, ContentItem, Banner, LiveChannel, Profile
│   └── repositories/     # Auth, Category, Content, Banner, LiveTV, YouTube
├── domain/
│   └── enums/            # UserRole, ContentType, BannerAction
├── presentation/
│   ├── admin/            # Dashboard, Categories, Content, Banners, RBAC, Settings
│   ├── mobile/           # Shell, Home, Category, Details, Player, Live TV, YouTube, Search
│   ├── providers/        # Riverpod StateNotifiers & AsyncNotifiers
│   ├── shared/           # VideoCard, CategoryChip, BannerCarousel, UniversalPlayer
│   └── tv/               # TV Shell, Home Billboard, Category Grid, TV Player, Channel Guide
└── main.dart             # App entrypoint with Hive & Supabase initialization
```

---

## 🗄️ Supabase Database Migration

* **Project URL**: `https://klcbikttkeoisrhnunrt.supabase.co`
* **Direct SQL Editor**: [https://supabase.com/dashboard/project/klcbikttkeoisrhnunrt/sql](https://supabase.com/dashboard/project/klcbikttkeoisrhnunrt/sql)

The complete PostgreSQL migration script with table definitions, triggers, and Row Level Security policies is available in:
👉 `supabase/migrations/20261114000000_kids_tv_schema.sql`

### How to apply migration:
1. Open the Supabase SQL Editor: [https://supabase.com/dashboard/project/klcbikttkeoisrhnunrt/sql](https://supabase.com/dashboard/project/klcbikttkeoisrhnunrt/sql)
2. Copy and paste the entire contents of `supabase/migrations/20261114000000_kids_tv_schema.sql`.
3. Click **Run**. All tables (`profiles`, `categories`, `content_items`, `banners`, `live_channels`, `youtube_channels`), RLS policies, triggers, and initial seed data will be created automatically.

---

## 🚀 Running the Application

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run with Compile-Time Supabase Credentials (Optional)
```bash
flutter run \
  --dart-define=SUPABASE_URL="https://your-project.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="your-anon-key"
```
*(If run without parameters, the application automatically boots into dynamic offline/seed mode with full interactive content and admin capabilities!)*

### 3. Running on Android TV
```bash
flutter run -d <android-tv-device-or-emulator>
```
On Android TV, the app will automatically start in Leanback landscape mode with full remote control support.
To test TV mode on any mobile device, desktop, or web, click the **"📱 Mobile Mode" / "📺 TV Mode"** pill in the top header or settings!

### 4. Admin Test Credentials
* **Super Admin**: `admin@kidstv.stream` / `admin123`
* **Content Editor**: `editor@kidstv.stream` / `editor123`

### 5. Running Automated Tests
```bash
flutter test
```
All unit and widget tests pass with 0 errors.

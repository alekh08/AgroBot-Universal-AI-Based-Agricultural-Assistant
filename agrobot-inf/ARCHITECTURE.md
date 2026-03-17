# 🌾 AI-AgroBot — Project Architecture

> A comprehensive guide to the system architecture from both the **User (Farmer)** and **Admin** perspectives.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [High-Level Architecture Diagram](#3-high-level-architecture-diagram)
4. [Directory Structure](#4-directory-structure)
5. [Database Models](#5-database-models)
6. [User (Farmer) Perspective](#6-user-farmer-perspective)
   - [Registration & Login Flow](#61-registration--login-flow)
   - [User Dashboard](#62-user-dashboard)
   - [AI Chat (AgroBot)](#63-ai-chat-agrobot)
   - [Image Analysis](#64-image-analysis)
   - [Weather Module](#65-weather-module)
   - [Market Prices](#66-market-prices)
   - [Crop Planner](#67-crop-planner)
   - [Community Forum](#68-community-forum)
   - [Live Chat](#69-live-chat)
   - [Pest Database](#610-pest-database)
   - [Document Center](#611-document-center)
   - [Notifications](#612-notifications)
   - [Profile Management](#613-profile-management)
7. [Admin Perspective](#7-admin-perspective)
   - [Admin Dashboard](#71-admin-dashboard)
   - [User Management](#72-user-management)
   - [Chat Logs Monitor](#73-chat-logs-monitor)
   - [Knowledge Base Management](#74-knowledge-base-management)
   - [Analytics](#75-analytics)
   - [System Health](#76-system-health)
   - [Data Export](#77-data-export)
8. [API Endpoints Reference](#8-api-endpoints-reference)
9. [Real-Time Features (Socket.IO)](#9-real-time-features-socketio)
10. [AI Integration (Google Gemini)](#10-ai-integration-google-gemini)
11. [Security & Auth](#11-security--auth)
12. [Configuration & Environment](#12-configuration--environment)

---

## 1. Project Overview

**AI-AgroBot** is a full-stack web application built for Indian farmers. It provides AI-powered agricultural assistance, including crop advice, plant disease detection via image analysis, real-time weather data, market prices, a community forum, and a live chat system — all in one platform.

| Dimension        | Detail                                       |
|------------------|----------------------------------------------|
| Target Users     | Farmers (primary) + Admins (secondary)       |
| Language Support | English (multi-language-ready via `preferred_language`) |
| AI Provider      | Google Gemini (gemini-2.5-flash)             |
| Database         | SQLite (local) / PostgreSQL (production)     |
| Real-time        | WebSockets via Flask-SocketIO                |
| Deployment       | Python/Flask — runnable locally or on cloud  |

---

## 2. Tech Stack

| Layer            | Technology                                          |
|------------------|-----------------------------------------------------|
| **Backend**      | Python 3, Flask, Flask-SQLAlchemy, Flask-Login      |
| **Real-time**    | Flask-SocketIO (WebSocket)                          |
| **AI / LLM**     | Google Gemini API (`google-genai`)                  |
| **Database**     | SQLite (dev) / PostgreSQL (prod via `DATABASE_URL`) |
| **ORM**          | SQLAlchemy                                          |
| **Auth**         | Flask-Login + Werkzeug password hashing             |
| **File Storage** | Local filesystem (`static/uploads/`, `static/thumbnails/`) |
| **Image Proc**   | Pillow (fallback analysis)                          |
| **Weather API**  | OpenWeatherMap API                                  |
| **Frontend**     | Jinja2 HTML templates, Bootstrap, Vanilla JS        |
| **Packaging**    | `uv` / `pyproject.toml` + `requirements.txt`        |

---

## 3. High-Level Architecture Diagram

```
Browser (User / Admin)
        │
        ▼
  ┌──────────────┐     WebSocket (Socket.IO)
  │  Flask App   │◄────────────────────────────────────┐
  │  (app.py)    │                                     │
  └──────┬───────┘                                     │
         │                                             │
    ┌────▼────────────────────────────────────────┐    │
    │               Route Layer                   │    │
    │  Public │ Auth │ Farmer │ Admin │ API/JSON  │    │
    └────┬────────────────────────────────────────┘    │
         │                                             │
    ┌────▼────────────┐    ┌──────────────────────┐   │
    │  Business Logic │    │   Real-time Events   │───┘
    │  (helpers,      │    │   (join, message,    │
    │   AI calls,     │    │   reaction, typing)  │
    │   fallbacks)    │    └──────────────────────┘
    └────┬────────────┘
         │
    ┌────▼──────────────────────────────────────────┐
    │              SQLAlchemy ORM                    │
    │  Users │ ChatHistory │ CropPlan │ ForumThread  │
    │  MarketPrice │ WeatherAlert │ Document │ ...   │
    └────┬──────────────────────────────────────────┘
         │
    ┌────▼──────────────┐    ┌──────────────────────┐
    │  SQLite / PostgreSQL│   │  External APIs        │
    │  (data/agrobot.db) │   │  - Google Gemini      │
    └───────────────────┘    │  - OpenWeatherMap     │
                              └──────────────────────┘
```

---

## 4. Directory Structure

```
agrobot-inf/
├── app.py                  # Main Flask application (all routes, models, logic)
├── gemini_helper.py        # Optional Gemini helper utilities
├── .env                    # Environment variables (API keys, secrets)
├── pyproject.toml          # Project metadata & dependencies
├── requirements.txt        # Python dependencies
├── data/
│   └── agrobot.db          # SQLite database file
├── uploads/
│   └── documents/          # User-uploaded documents (PDFs, CSVs, etc.)
├── static/
│   ├── style.css           # Global styles
│   ├── css/                # Additional CSS files
│   ├── js/                 # JavaScript files
│   ├── images/             # Static images (SVGs, icons)
│   ├── uploads/            # Image uploads from chat/analysis
│   └── thumbnails/         # Auto-generated image thumbnails
└── templates/
    ├── base.html           # Shared layout (navbar, footer, flash messages)
    ├── home.html           # Public landing page
    ├── login.html          # Login form
    ├── register.html       # Registration form (detailed farmer profile)
    ├── dashboard.html      # Farmer overview dashboard
    ├── chat.html           # AI chat interface
    ├── livechat.html       # Real-time community chat
    ├── weather.html        # Weather information page
    ├── market.html         # Market prices page
    ├── crop_planner.html   # Crop planning & task tracker
    ├── community.html      # Community forum
    ├── community_search.html
    ├── pest_database.html  # Pest identification database
    ├── docs.html           # Document management center
    ├── notifications.html  # User notifications
    ├── profile.html        # User profile settings
    ├── about.html          # About page
    ├── features.html       # Features page
    ├── pricing.html        # Pricing page
    ├── contact.html        # Contact page
    ├── users.html          # (non-admin user list page)
    ├── view_user.html      # (non-admin user detail)
    └── admin/
        ├── analytics.html      # Admin analytics charts
        ├── chats.html          # Admin chat log viewer
        ├── knowledge_base.html # Farming tips & market price management
        ├── system_health.html  # System status dashboard
        ├── users.html          # Admin user management table
        └── view_user.html      # Admin individual user detail
```

---

## 5. Database Models

The entire data layer lives in `app.py` using SQLAlchemy ORM, backed by SQLite (dev) or PostgreSQL (prod).

| Model              | Table                  | Purpose                                           |
|--------------------|------------------------|---------------------------------------------------|
| `User`             | `users`                | All users (farmers & admins). Stores farm profile |
| `ChatHistory`      | `chat_history`         | AI chat Q&A history per user                      |
| `ImageAnalysis`    | `image_analyses`       | Plant/crop image analysis records                 |
| `FarmingTip`       | `farming_tips`         | Admin-managed farming tips                        |
| `MarketPrice`      | `market_prices`        | Crop price data per region                        |
| `UserActivity`     | `user_activities`      | Login, logout, registration audit trail           |
| `UserPoints`       | `user_points`          | Gamification — points ledger                      |
| `Referral`         | `referrals`            | Referral program tracking                         |
| `WeatherAlert`     | `weather_alerts`       | Weather notifications per user                    |
| `OTPVerification`  | `otp_verifications`    | OTP tokens for email/phone verification           |
| `CropPlan`         | `crop_plans`           | Farmer's crop plans                               |
| `CropTask`         | `crop_tasks`           | Tasks within a crop plan                          |
| `ForumCategory`    | `forum_categories`     | Forum category buckets                            |
| `ForumThread`      | `forum_threads`        | Forum discussion threads                          |
| `ForumPost`        | `forum_posts`          | Replies within a thread                           |
| `ForumLike`        | `forum_likes`          | Likes on forum posts                              |
| `ForumTag`         | `forum_tags`           | Tags for threads                                  |
| `ForumThreadTag`   | `forum_thread_tags`    | Thread ↔ Tag mapping                             |
| `UserFollow`       | `user_follows`         | Social following between users                    |
| `ChatMessage`      | `chat_messages`        | Real-time live chat messages                      |
| `MessageReaction`  | `message_reactions`    | Emoji reactions on chat messages                  |
| `PrivateMessage`   | `private_messages`     | Private messages between users                    |
| `Document`         | `documents`            | User-uploaded documents                           |

### Key Relationships

```
User
 ├── ChatHistory         (one-to-many)
 ├── ImageAnalysis       (one-to-many)
 ├── UserActivity        (one-to-many)
 ├── UserPoints          (one-to-many)
 ├── CropPlan → CropTask (one-to-many → one-to-many)
 ├── ForumThread         (one-to-many)
 ├── ForumPost           (one-to-many)
 ├── Document            (one-to-many)
 ├── UserFollow          (self-referential many-to-many)
 └── ChatMessage         (one-to-many)

ChatMessage → MessageReaction  (one-to-many)
ChatMessage → ChatMessage      (self-referential reply_to)
ForumPost   → ForumLike        (one-to-many)
```

---

## 6. User (Farmer) Perspective

### How a typical farmer interacts with the application:

```
Visit Home Page  →  Register / Login  →  Dashboard
                                              │
              ┌───────────────────────────────┤
              ▼               ▼               ▼            ▼
          AI Chat        Image Analysis   Weather      Crop Planner
              │
              ▼
     Community Forum / Live Chat / Market Prices / Pest DB / Docs
```

---

### 6.1 Registration & Login Flow

**Route:** `GET/POST /register`, `GET/POST /login`

**Registration fields collected:**
- Personal: Name, Email, Phone, WhatsApp, DOB, Gender, Password
- Farm Profile: Farm Name, Farm Size, Primary Crop, Secondary Crops, Soil Type, Irrigation Type, Region, District, Experience Level
- Preferences: Language, Notification preferences (weather/pests/market/tips), Farming interests (organic, hydroponics, precision, dairy, etc.)

**What happens on registration:**
1. Validates email uniqueness and phone format
2. Hashes the password with Werkzeug
3. Creates the `User` record with `role='farmer'` and `points_balance=100` (welcome bonus)
4. Logs a `UserActivity` entry (`registration` type)
5. Auto logs the user in and redirects to `/dashboard`

**Login:**
1. Checks email → verifies password hash
2. Checks `is_active` flag — inactive users are rejected
3. Updates `last_login` timestamp
4. Sets Flask session variables (`user_id`, `user_name`, `user_role`)
5. Redirects to `/dashboard` (or `next` param if redirected from a protected page)

---

### 6.2 User Dashboard

**Route:** `GET /dashboard`

Displays:
- Total AI chat count
- Last 5 AI chats preview
- Last 5 image analysis results with thumbnails
- Quick action cards to navigate to all features

---

### 6.3 AI Chat (AgroBot)

**Route:** `GET /chat` (page), `POST /api/chat` (API)

**Flow:**
```
User types message
       │
       ▼
LOCAL_KNOWLEDGE lookup (Rice, Wheat, Maize, Pest, Soil keywords)
       │
   Found? ──── Yes ──► Return local response instantly
       │
      No
       │
       ▼
Gemini API call (gemini-2.5-flash)
       │
   Success? ──── Yes ──► Return Gemini response
       │
      No (rate limit / error)
       │
       ▼
Enhanced Fallback (suggests Kisan Call Center, KVK, state agriculture dept)
       │
       ▼
Save to `chat_history` table
       │
       ▼
Return JSON response to browser
```

**User profile context** is injected into every Gemini prompt:
- Name, region, primary crop, experience level

**Chat history** is paginated, accessible via `GET /api/chat/history`.
Users can clear their own history via `POST /api/chat/clear`.

---

### 6.4 Image Analysis

**Route:** `POST /api/analyze-image`

**Supported formats:** PNG, JPG, JPEG, GIF, BMP, WEBP  
**Max upload size:** 16 MB

**Flow:**
```
User uploads crop/plant image
       │
       ▼
File is saved to static/uploads/ with unique ID
       │
       ▼
Thumbnail auto-generated at 200×200 (Pillow) → static/thumbnails/
       │
       ▼
Gemini Vision API (tries gemini-2.5-flash → gemini-1.5-flash → gemini-1.5-pro)
       │
   Success? ──── Yes ──► AI provides: plant ID, health assessment, pest/disease detection, recommendations
       │
      No (rate limit / not available)
       │
       ▼
Fallback: Pixel-level green ratio analysis (Pillow)
   - < 5% green → Severe discoloration
   - 5–40% green → Partial damage
   - > 40% green → Likely healthy
       │
       ▼
Saved to `image_analyses` table + `chat_history` (type="image")
       │
       ▼
Returns JSON with analysis + image URL + thumbnail URL
```

---

### 6.5 Weather Module

**Route:** `GET /weather` (page), `GET /api/weather` (API), `POST /update_location`

- Pulls current weather + 5-day forecast from **OpenWeatherMap API** using the user's registered `region`
- If the API fails or key is invalid → returns **mock data** (28°C, partly cloudy, etc.)
- Generates **farming recommendations** automatically:
  - Irrigation alerts (skip if rain >60%)
  - Pest/fungal risk alerts (high humidity + rain)
  - Fertilizer spray window (low wind + low rain)
  - Harvest urgency (heavy rain expected)
- Users can update their location dynamically via `POST /update_location`

---

### 6.6 Market Prices

**Route:** `GET /market` (page), `GET /api/market-prices` (API)

- Shows crop market prices from the `market_prices` table
- Data is populated by admins via the Knowledge Base panel
- Displays: crop name, price per unit, market name, region, date

---

### 6.7 Crop Planner

**Route:** `GET /crop-planner`, `POST /api/crop-planner/create`, `GET /api/crop-planner/plans`

**Features:**
- Create crop plans with: crop type, variety, start date, expected harvest date, area (acres), planting method, notes
- **Auto-generates 6 default tasks** upon plan creation:
  1. Land Preparation (7 days before start)
  2. Planting/Sowing (on start date)
  3. Irrigation Check (15 days after start)
  4. First Fertilizer Application (30 days after start)
  5. Pest Scouting (45 days after start)
  6. Harvest (on expected harvest date)
- Tasks can be marked as `pending`, `completed`, or `skipped`
- Current season (Rabi / Kharif / Zaid) is automatically detected from the current month
- Plan deletion via `DELETE /api/crop-planner/plan/<plan_id>/delete`

---

### 6.8 Community Forum

**Route:** `GET /community`, `POST /community/thread/new`, `GET /community/thread/<id>`, `POST /community/thread/<id>/reply`

**Default categories:**
- Crop Cultivation, Pest Control, Market & Sales, Equipment, Weather, Q&A

**Features:**
- Create threads with title, category, content, and multiple tags
- Reply to threads (prevented if thread is locked)
- Like/unlike forum posts (toggle via `POST /api/community/post/<id>/like`)
- Search threads by title or content (`GET /community/search?q=...`)
- View thread counts, pinned threads, trending tags (last 7 days)
- Top contributors leaderboard (ranked by post count)
- View online members count (last-login within 15 minutes)

---

### 6.9 Live Chat

**Route:** `GET /chat-community` (renders `livechat.html`)

**Built on Flask-SocketIO (WebSocket).**

**Features per user:**
- Join the `general` room on page load
- Send text messages, file attachments (image/voice), and reply-to messages
- Add/remove emoji reactions (👍, ❤️, 😂, etc.)
- Edit own messages
- Delete own messages
- Typing indicators ("X is typing...")
- Read receipts (seen notifications)
- Follow / Unfollow other users from their in-chat profile hover card
- View online users list in the room

**File uploads for chat:** `POST /upload-chat-file`  
**Social follow:** `POST /follow/<user_id>`, `POST /unfollow/<user_id>`

---

### 6.10 Pest Database

**Route:** `GET /pest-database` (page), `GET /api/pests` (API)

- Static knowledge base of common agricultural pests
- Includes: name, crops affected, symptoms, and control methods
- Examples: Aphids, Whiteflies, Bollworms

---

### 6.11 Document Center

**Route:** `GET /documents`, `GET /documents/list/`, `POST /documents/upload/`, `GET /documents/download/<doc_id>/`

**Supported file types:** PDF, TXT, DOC, DOCX, CSV, images, archives

**Features:**
- Upload documents (categorized as: uploads, reports, guides, etc.)
- List all personal documents with size, date, category
- Download own documents (enforces ownership — 403 if not owner)
- Auto-classifies file type (pdf, docs, spreadsheet, image, archive, other)

---

### 6.12 Notifications

**Route:** `GET /notifications`

- Renders the notifications page (backed by `WeatherAlert` model)
- Weather and pest alert notifications per user

---

### 6.13 Profile Management

**Route:** `GET/POST /profile`

- Update: Name, Primary Crop, Region, Farm Size, Experience Level, Preferred Language
- Upload profile picture (saved to `static/uploads/` as `profile_<user_id>_<timestamp>.<ext>`)
- View personal stats: total AI chats, total image analyses

---

## 7. Admin Perspective

Admins access all admin features under the `/admin/*` route prefix.  
Access is protected by both `@login_required` and `@admin_required` (checks `user.role == 'admin'`).

> **Default admin credentials (created on first run):**  
> Email: `admin@aiagrobot.com` / Password: `admin123`

---

### 7.1 Admin Dashboard

**Route:** `GET /admin`

Overview cards:
| Metric                  | Description                            |
|-------------------------|----------------------------------------|
| Total Users             | Count of all registered users          |
| Total Farmers           | Users with role `farmer`               |
| Total Admins            | Users with role `admin`                |
| Total AI Chats          | All chat interactions across all users |
| Today's Chats           | AI chats created today                 |
| Total Image Analyses    | All image uploads analyzed             |
| New Users (This Week)   | Registrations in last 7 days           |

Additional views:
- Recent 10 users (newest first)
- Recent 10 AI chat interactions
- Top 10 most active users (by chat count)
- User count breakdown by region

---

### 7.2 User Management

**Route:** `GET /admin/users`, `GET /admin/user/<id>`, `POST /admin/user/<id>/toggle-status`, `POST /admin/user/<id>/update-role`, `POST /admin/user/<id>/delete`

**User list features:**
- Paginated list (default 20 per page)
- Filter by: role (farmer/admin), status (active/inactive)
- Search by: name, email, phone, region

**User detail view shows:**
- Full farm profile (farm size, crops, soil type, irrigation, region, experience)
- Total AI chats & image analyses
- Last 50 chat messages
- Last 20 image analysis records
- Daily chat activity chart (last 7 days)

**Admin actions per user:**
| Action              | Restriction                                    |
|---------------------|------------------------------------------------|
| Toggle active/inactive | Cannot deactivate self or other admins      |
| Update role (farmer/admin/agent) | Cannot change own role            |
| Delete user         | Cannot delete self or any admin account        |

---

### 7.3 Chat Logs Monitor

**Route:** `GET /admin/chats`, `POST /admin/delete-chat/<chat_id>`

- Browse all chat interactions across all users
- Filter by: specific user, date range (today / this week / this month / all)
- Paginated (50 per page)
- Delete individual chat records
- Bulk clear all chats via `POST /admin/clear-chats`

---

### 7.4 Knowledge Base Management

**Route:** `GET /admin/knowledge-base`, `POST /admin/farming-tips/add`, `POST /admin/market-prices/add`

**Farming Tips:**
- Add new tips with: Title, Content, Category, Crop Type, Language
- Tips are served to users via `GET /api/farming-tips`

**Market Prices:**
- Add crop price entries: Crop Name, Market Name, Region, Price, Unit (kg/quintal), Source
- Prices are served to users via `GET /api/market-prices`

---

### 7.5 Analytics

**Route:** `GET /admin/analytics`

Charts and metrics:
| Chart               | Data                                          |
|---------------------|-----------------------------------------------|
| User Growth         | Daily new registrations over time             |
| Chat Activity       | Daily AI chat count over time                 |
| Top Crops           | Most popular primary crops among farmers      |

Summary stats:
- Total users
- Active users in last 30 days (with at least 1 chat)
- Average chats per user in last 30 days
- Total AI chats
- Total image analyses

---

### 7.6 System Health

**Route:** `GET /admin/system-health`

Real-time system diagnostics:
| Check                    | Detail                                   |
|--------------------------|------------------------------------------|
| Database status          | Verifies DB connectivity (`SELECT 1`)    |
| Upload folder existence  | Checks `static/uploads/` is present      |
| Upload folder writability| Checks write permission on upload dir    |
| Gemini API status        | Shows if API key is configured, working  |
| Disk usage               | Total / Used / Free GB + usage %         |

---

### 7.7 Data Export

**Route:** `GET /admin/export/users`, `GET /admin/export/chats`

| Export         | Fields                                                                                |
|----------------|---------------------------------------------------------------------------------------|
| Users CSV      | ID, Email, Name, Phone, Role, Region, Farm Size, Primary Crop, Experience, Status, Created At |
| Chats CSV      | ID, User ID, User Message (≤500 chars), Bot Response (≤500 chars), Type, Language, Created At |

Also available: `GET /backup-db` — creates a timestamped `.backup` copy of the SQLite file.

---

## 8. API Endpoints Reference

### Public Routes (no auth)

| Method | Route       | Description              |
|--------|-------------|--------------------------|
| GET    | `/`         | Home page                |
| GET    | `/features` | Features page            |
| GET    | `/pricing`  | Pricing page             |
| GET    | `/about`    | About page               |
| GET    | `/contact`  | Contact page             |
| GET    | `/health`   | Health check JSON        |

### Auth Routes

| Method | Route       | Description              |
|--------|-------------|--------------------------|
| GET    | `/register` | Registration form        |
| POST   | `/register` | Submit registration      |
| GET    | `/login`    | Login form               |
| POST   | `/login`    | Submit login             |
| GET    | `/logout`   | Logout                   |

### Farmer Routes (login required)

| Method | Route                                     | Description                       |
|--------|-------------------------------------------|-----------------------------------|
| GET    | `/dashboard`                              | Farmer dashboard                  |
| GET    | `/chat`                                   | AI chat page                      |
| POST   | `/api/chat`                               | Send AI chat message              |
| GET    | `/api/chat/history`                       | Load chat history                 |
| POST   | `/api/chat/clear`                         | Clear own chat history            |
| POST   | `/api/analyze-image`                      | Upload & analyze crop image       |
| GET    | `/api/image-analyses`                     | List own image analyses           |
| GET    | `/weather`                                | Weather page                      |
| GET    | `/api/weather`                            | Fetch weather data JSON           |
| POST   | `/update_location`                        | Update user location/region       |
| GET    | `/market`                                 | Market prices page                |
| GET    | `/api/market-prices`                      | Fetch market prices JSON          |
| GET    | `/pest-database`                          | Pest database page                |
| GET    | `/api/pests`                              | Fetch pests list JSON             |
| GET    | `/crop-planner`                           | Crop planner page                 |
| POST   | `/api/crop-planner/create`                | Create new crop plan              |
| GET    | `/api/crop-planner/plans`                 | Get own crop plans                |
| POST   | `/api/crop-planner/task/<id>/update`      | Update task status                |
| DELETE | `/api/crop-planner/plan/<id>/delete`      | Delete crop plan                  |
| GET    | `/community`                              | Community forum                   |
| POST   | `/community/thread/new`                   | Create forum thread               |
| GET    | `/community/thread/<id>`                  | View a thread                     |
| POST   | `/community/thread/<id>/reply`            | Reply to thread                   |
| POST   | `/api/community/post/<id>/like`           | Like/unlike a post                |
| GET    | `/community/search`                       | Search threads                    |
| GET    | `/chat-community`                         | Live chat page                    |
| POST   | `/upload-chat-file`                       | Upload file in live chat          |
| POST   | `/follow/<user_id>`                       | Follow a user                     |
| POST   | `/unfollow/<user_id>`                     | Unfollow a user                   |
| GET    | `/documents`                              | Document center page              |
| GET    | `/documents/list/`                        | List own documents JSON           |
| POST   | `/documents/upload/`                      | Upload document(s)                |
| GET    | `/documents/download/<id>/`               | Download own document             |
| GET    | `/notifications`                          | Notifications page                |
| GET/POST | `/profile`                             | View & update own profile         |
| GET    | `/api/farming-tips`                       | Get farming tips JSON             |
| POST   | `/api/crop-schedule`                      | Get crop schedule                 |

### Admin Routes (admin role required)

| Method | Route                                         | Description                     |
|--------|-----------------------------------------------|---------------------------------|
| GET    | `/admin`                                      | Admin main dashboard            |
| GET    | `/admin/users`                                | User management list            |
| GET    | `/admin/user/<id>`                            | View user detail                |
| POST   | `/admin/user/<id>/toggle-status`              | Activate/deactivate user        |
| POST   | `/admin/user/<id>/update-role`                | Change user role                |
| POST   | `/admin/user/<id>/delete`                     | Delete user                     |
| GET    | `/admin/chats`                                | Browse all chat logs            |
| POST   | `/admin/delete-chat/<id>`                     | Delete a specific chat          |
| POST   | `/admin/clear-chats`                          | Clear all chat records          |
| GET    | `/admin/analytics`                            | Analytics charts page           |
| GET    | `/admin/knowledge-base`                       | Manage tips & market prices     |
| POST   | `/admin/farming-tips/add`                     | Add farming tip                 |
| POST   | `/admin/market-prices/add`                    | Add market price                |
| GET    | `/admin/system-health`                        | System health check page        |
| GET    | `/admin/export/users`                         | Export users as CSV             |
| GET    | `/admin/export/chats`                         | Export chats as CSV             |
| GET    | `/backup-db`                                  | Backup SQLite database          |

---

## 9. Real-Time Features (Socket.IO)

The live chat system uses **Flask-SocketIO** for WebSocket-based real-time communication.

**Server-side events handled:**

| Event            | Description                                              |
|------------------|----------------------------------------------------------|
| `join`           | User joins a room (updates online user list)             |
| `disconnect`     | User leaves (removes from online list)                   |
| `typing`         | Broadcasts "X is typing..." to room                      |
| `send_message`   | Saves message to DB + broadcasts to all in room          |
| `edit_message`   | Updates message text in DB + broadcasts update           |
| `delete_message` | Deletes message from DB + broadcasts deletion            |
| `pin_message`    | Admin/moderator can pin a message                        |
| `reaction`       | Toggle emoji reaction on message + broadcast count       |
| `messages_seen`  | Sends read receipt to room                               |

**Client-side events emitted by server:**

| Event              | Description                                    |
|--------------------|------------------------------------------------|
| `status`           | "User X has joined the chat"                   |
| `user_count`       | Updated online user list + count               |
| `typing`           | Who is currently typing                        |
| `message`          | New message payload                            |
| `message_edited`   | Updated message content                        |
| `message_deleted`  | ID of deleted message                          |
| `message_pinned`   | ID of pinned message                           |
| `reaction_update`  | Emoji + count update for a message             |
| `read_receipt`     | Read receipt from a user                       |

**Online tracking:** In-memory `dict` — `online_users[room] = set(user_ids)` and `user_sid_map[sid] = user_id`.

> ⚠️ Note: In-memory online tracking resets on server restart. For production, use Redis as a message/session store.

---

## 10. AI Integration (Google Gemini)

**Three-tier response strategy:**

```
1. LOCAL_KNOWLEDGE (instant, no API call)
          ↓ (if no match)
2. Google Gemini API (gemini-2.5-flash)
          ↓ (if rate-limited or unavailable)
3. Enhanced Fallback (local fallback text + regional help references)
```

**Local knowledge base topics:** rice, wheat, maize, pest (aphids/fungus), soil

**Gemini prompt includes:**
- User name, region, primary crop, experience level as context
- Instructions: practical advice for Indian farming, simple language, safety precautions, government schemes, encouraging tone

**Vision analysis (image):**
- Tries: `gemini-2.5-flash` → `gemini-1.5-flash` → `gemini-1.5-pro`
- Prompt extracts: plant/crop ID, health assessment, pest/disease detection, recommendations
- Fallback: Pillow pixel green-ratio heuristic

---

## 11. Security & Auth

| Mechanism              | Implementation                                      |
|------------------------|-----------------------------------------------------|
| **Password hashing**   | `werkzeug.security.generate_password_hash` (PBKDF2) |
| **Session management** | Flask-Login (`login_required` decorator)            |
| **Admin protection**   | Custom `@admin_required` decorator (checks `user.role`) |
| **File validation**    | Whitelist of allowed extensions (images & docs)     |
| **File naming**        | UUID + timestamp prefix to prevent path traversal   |
| **CSRF**               | Flask secret key for session signing                |
| **Ownership checks**   | Document downloads + crop plan edits verify `user_id` |
| **Account deactivation** | Admin can set `is_active=False` to block login    |
| **Production DB**      | PostgreSQL via `DATABASE_URL` environment variable  |

---

## 12. Configuration & Environment

**`.env` file variables:**

| Variable           | Purpose                                              |
|--------------------|------------------------------------------------------|
| `FLASK_SECRET_KEY` | Session encryption key (change in production!)       |
| `GEMINI_API_KEY`   | Google Gemini API key                                |
| `DATABASE_URL`     | PostgreSQL URL (optional; defaults to SQLite)        |

**App config defaults:**

| Config Key                    | Default Value                           |
|--------------------------------|-----------------------------------------|
| `WEATHER_API_KEY`              | `65e1bfc3c34734109d78b1bdb4c9d05e`      |
| `WEATHER_API_URL`              | `https://api.openweathermap.org/data/2.5` |
| `MAX_CONTENT_LENGTH`           | 16 MB                                   |
| `SQLALCHEMY_TRACK_MODIFICATIONS` | `False`                               |

**Running locally:**

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables in .env

# Start the server
python app.py
# OR with uv:
uv run app.py
```

Server starts on `http://localhost:5000`  
Default admin: `admin@aiagrobot.com` / `admin123`  
Demo farmer: `demo@aiagrobot.com` / `demo123`

---

*This document was auto-generated from analysis of `app.py` and the `templates/` directory. Last updated: March 2026.*

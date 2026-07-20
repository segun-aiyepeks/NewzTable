# NewzTable — Topic-Personalized News App

A cross-platform news app built around user-chosen topics and zero-friction, device-based personalization (no email/password). Built as a commercial-standard, portfolio-grade project across mobile, web, and backend.

See [`UX-Case-Study-User-Journey.md`](./UX-Case-Study-User-Journey.md) for the full UI/UX case study and user journey this build is based on.

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter (Dart), MVVM via Provider |
| Web | Bootstrap 5 + Vanilla JavaScript (ES Modules), MVVM-style structure |
| Backend | Node.js + Express |
| Database | MongoDB (Atlas) |
| News Data | NewsData.io (primary, commercial-use free tier), The Guardian Open Platform (secondary, full-content English source) |
| Push Notifications | Firebase Cloud Messaging |
| Ads | Google AdMob (mobile), Google AdSense or native ad slot (web) |
| Auth Model | Anonymous device-ID based — no email/password |

## Architecture

```
┌───────────────┐     ┌───────────────┐
│  Flutter App   │     │   Web App      │
│  (MVVM)        │     │  (MVVM-style)  │
└───────┬───────┘     └───────┬───────┘
        │      REST / JSON     │
        └──────────┬───────────┘
                    ▼
          ┌─────────────────────┐
          │   Express API        │
          │  Routes→Controllers  │
          │       →Services      │
          └──────────┬───────────┘
                      │
         ┌────────────┼─────────────┐
         ▼                          ▼
 ┌───────────────┐         ┌─────────────────┐
 │   MongoDB       │         │  News Provider    │
 │ (users, topics,  │◄───────│  Service (cron-    │
 │  articles cache, │  cache │  fetches NewsData/  │
 │  bookmarks)       │        │  Guardian, dedupes) │
 └───────────────┘         └─────────────────┘
```

The Express backend is **not a pass-through proxy**. A scheduled job pulls and deduplicates articles into MongoDB on an interval, so the client feed is served from the cache — fast, and well within free-tier API rate limits.

### MVVM on each client

**Flutter**: `model/` (data classes + repositories) → `viewmodel/` (`ChangeNotifier` classes exposed via the `provider` package, holding UI state) → `view/` (widgets, no business logic, consumed via `Consumer`/`context.watch`).

**Web (Vanilla JS)**: `models/` (API service classes returning plain data) → `viewmodels/` (state modules exposing observable state + methods) → `views/` (DOM-rendering functions subscribed to viewmodel state). Bootstrap handles layout/styling only.

## Project Structure

```
newztable/
├── backend/
│   ├── src/
│   │   ├── routes/
│   │   ├── controllers/
│   │   ├── services/        # newsProvider, dedup, scheduler
│   │   ├── models/          # Mongoose schemas
│   │   └── middleware/      # device-id auth, rate limiting
│   ├── .env.example
│   └── package.json
├── web/
│   ├── index.html
│   ├── css/
│   ├── js/
│   │   ├── models/
│   │   ├── viewmodels/
│   │   └── views/
├── mobile/
│   └── lib/
│       ├── model/
│       ├── viewmodel/
│       ├── view/
│       └── services/
├── docs/
│   └── UX-Case-Study-User-Journey.md
└── README.md
```

## Core Features (v1)

- Onboarding-as-personalization topic selection (no signup)
- Topic-personalized home feed, cached & paginated
- Article detail with honest "continue reading on source" handoff
- Bookmarks synced to anonymous device ID
- Keyword search
- Dark mode
- Native ad placement every N feed items
- Push notifications for breaking news in subscribed topics (mobile)

## Environment Variables (backend)

```
PORT=5000
MONGODB_URI=
NEWSDATA_API_KEY=
GUARDIAN_API_KEY=
FCM_SERVER_KEY=
NEWS_FETCH_INTERVAL_MINUTES=15
```

## Local Setup

**Backend**
```bash
cd backend
npm install
cp .env.example .env   # fill in keys
npm run dev
```

**Web**
```bash
cd web
# any static server works, e.g.
npx serve .
```

**Mobile**
```bash
cd mobile
flutter pub get
flutter run
```

## Deployment (free tier)

| Component | Platform | Notes |
|---|---|---|
| Database | MongoDB Atlas | Free M0 cluster, 512MB |
| Backend API | Render or Railway | Free web service tier; set env vars in dashboard |
| Web App | Netlify or Vercel | Connect GitHub repo, auto-deploy on push, free SSL |
| Mobile | Google Play Console | One-time $25 developer fee, Play App Signing, internal testing track first |

A privacy policy page is required for Play Store submission (we collect a device ID + topic preferences) — to be hosted as a static page alongside the web app.

## Roadmap

See "§7 Roadmap" in the UX case study for post-v1 ideas (recovery codes, offline cache, digest notifications, admin curation dashboard).

## License

TBD — recommend MIT for a portfolio/commercial-demo project unless there's a specific reason to keep it private.

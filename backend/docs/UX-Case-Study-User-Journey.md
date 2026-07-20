# NewzTable — UI/UX Case Study & User Journey

## 1. Project Brief

NewzTable is a cross-platform news app (Flutter mobile + Bootstrap/Vanilla JS web, Node/Express + MongoDB backend) where the entire experience is built around **user-chosen topics** rather than a fixed editorial homepage or geography. There is no email/password signup — every user is identified by an anonymous **device ID**, so personalization works from the first launch with zero friction.

**Core design principles**
- Zero-friction entry: no signup screen blocking the first feed.
- Topics are the product: onboarding *is* the personalization step, not a buried settings menu.
- Respect the data: NewsData.io / Guardian API give headlines + descriptions, not always full bodies — design around "read more" handoffs instead of pretending we host full articles.
- Ads feel native, not bolted on: they sit inside the feed rhythm, not as intrusive interstitials.

## 2. Primary Persona

**"Tomi", 27, mobile-first professional**
Wants a 5-minute scroll over breakfast covering *fintech, Premier League, and Nigerian politics* — nothing else. Has abandoned three other news apps because they forced a signup or buried topic filters three menus deep. Values speed, low data usage, and the ability to bookmark something to read properly later.

## 3. Information Architecture

```
Onboarding (first launch only)
└── Topic Selection Screen
        │
        ▼
Home (Feed) ──┬── Article Detail ──┬── Bookmark
              │                    ├── Share
              │                    └── Related (same topic)
              ├── Search
              ├── Bookmarks (Saved)
              └── Settings ──┬── Edit Topics
                             ├── Dark Mode
                             └── About / Notifications toggle
```

## 4. Core User Journey

### 4.1 First Launch — Onboarding
1. App opens directly to a **Topic Selection** screen — a grid of tappable chips (Technology, Business, Sports, Health, Entertainment, Science, World, Politics, Nigeria, Crypto, etc.).
2. User selects 3–8 topics. A subtle counter nudges "Pick at least 3 for a good mix."
3. On confirm, the client:
   - Generates a UUID device ID (stored in `shared_preferences` on mobile, `localStorage` on web).
   - Sends `{ deviceId, topics: [...] }` to `POST /api/users/init`.
   - Backend upserts an anonymous user document keyed by `deviceId`.
4. User lands on the Home feed — already personalized. No password, no email, no verification screen.

*Why this matters:* the onboarding step doubles as the personalization step, so there's no "empty state" homepage and no second friction point later.

### 4.2 Home Feed
- Card-based feed, sorted by recency, pulling only from the user's selected topics (round-robin merged so one topic doesn't dominate).
- Pull-to-refresh (mobile) / refresh button (web).
- Infinite scroll with pagination against the backend's cached article store (not hitting NewsData.io per scroll — see §6).
- Every 6th card is a clearly labeled **native ad unit** (AdMob native ad on mobile, an ad slot div on web) — styled to match card height so the scroll rhythm isn't broken, but visually labeled "Sponsored."
- Each card shows: source name + logo, headline, thumbnail, time-ago, topic tag chip, bookmark icon.

### 4.3 Article Detail
- Hero image, headline, source, published time, full description/snippet returned by the API.
- Because most free-tier APIs don't license full-body redistribution, the screen ends with a clear **"Continue reading on [Source]"** button that opens the original article (in-app browser on mobile via `url_launcher`/WebView, new tab on web). This is a deliberate, honest design choice — not a limitation we hide.
- Bookmark, share, font-size adjust, and "More from this topic" carousel.

### 4.4 Bookmarks (Saved)
- Synced to the backend against the device ID (`GET/POST /api/bookmarks`), so bookmarks survive app reinstall **only if the same device ID persists** — clearing app storage resets it. This trade-off is explicitly accepted for v1 given "no account" is a requirement; a future "recovery code" feature is noted in the roadmap (§7) for users who want durability without email.

### 4.5 Search
- Simple keyword search bar, debounced input, hits `GET /api/articles/search?q=`, results unioned across the user's topics first, then global if no topic match.

### 4.6 Settings
- Edit topics any time (re-opens the same chip-selection UI from onboarding, pre-checked).
- Dark mode toggle (persisted locally + synced).
- Push notification toggle (mobile) for breaking news in subscribed topics, via Firebase Cloud Messaging.

## 5. Wireframe Notes (low-fidelity, text description)

**Mobile — Home**
```
┌─────────────────────────┐
│  NewzTable        🔍  🌙    │
├─────────────────────────┤
│ [Tech][Sports][Biz] >   │  ← horizontal topic filter chips
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │ [thumbnail]          │ │
│ │ Source · 2h ago       │ │
│ │ Headline text here    │ │
│ │ #Technology      🔖  │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │ Sponsored ad card     │ │
│ └─────────────────────┘ │
├─────────────────────────┤
│  🏠   🔍   🔖   ⚙️      │  ← bottom nav
└─────────────────────────┘
```

**Web — Home** mirrors this in a 3-column masonry grid on desktop, single column on mobile breakpoint (Bootstrap grid + responsive utility classes), with a left sidebar for topic toggles instead of horizontal chips.

## 6. Key UX/Technical Decisions Worth Calling Out in a Portfolio Write-Up

- **Anonymous-first identity model** — solves the "signup wall kills conversion" problem common in news apps, while still enabling real personalization and a saved-articles feature.
- **Backend as a caching/aggregation layer, not a pass-through** — Express fetches from NewsData.io (+ Guardian) on a schedule, deduplicates near-identical stories across sources, and serves from MongoDB. This avoids hammering the free-tier rate limit and gives sub-100ms feed responses regardless of upstream API speed.
- **Ad placement respects content rhythm** — fixed-interval native ad cards rather than full-screen interstitials, which is both better UX and a more defensible AdMob policy posture.
- **Graceful degradation when read-full-article isn't licensed** — handled as an intentional UX pattern, not hidden.

## 7. Roadmap (post-v1, optional)

- Optional "recovery code" so a device-based user can restore bookmarks/topics on a new phone without email.
- Offline article cache for the last N articles per topic.
- Topic-based push notification digest ("Your Tech digest: 5 new stories").
- Admin dashboard for manually featuring/curating top stories.

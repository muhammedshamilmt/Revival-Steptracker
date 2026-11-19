# ⚡ RevivalStep Tracker (@revivalSteps)

A hyper-crafted, neo-dark fitness, routine, and event-tracking Flutter application. RevivalStep combines cinematic visual design, fluid haptic feedback, real-time Mapbox geolocation, community event bookings, and gamified streak progression into a unified mobile experience.

---

## 📱 Visual Showcase & Key Highlights

- **Cinematic Video Onboarding**: High-definition looping video background (`onboarding.mp4`) with smooth multi-stop gradient overlays and typewriter brand reveal (`@revivalSteps`).
- **Interactive Mapbox Tracking**: Real-time GPS location tracking with customizable Mapbox vector styles, live pacing, distance calculation, and breadcrumb route rendering.
- **Precision Event & Routine Timeline**: 31-day horizontal timeline ruler with 10-subdivision minor ticks, magnetic month snapping, and 48px curved bottom card deck with progressive blur gradients.
- **Pass & Ticket Ecosystem**: Interactive digital boarding pass with dual circular scalloped perforations, cryptographic ticket hash, high-contrast QR code toggle, and 1-tap image/PDF export.
- **Multi-Step Sheet Registration**: Modular modal registration flow with horizontal attender count scrubber, real-time validation, and animated confirmation stamp.
- **Comprehensive Analytics & Gamified Streaks**: Dual-mode Dashboard with radial ray gauge animations, 2x2 metric grids, weekly activity heatmaps, and streak milestone badges.

---

## 🏗️ Architecture & Directory Layout

```
revivalstep-tracker/
├── assets/
│   ├── fonts/                   # Fredoka, Quicksand, & Nunito font families
│   ├── images/                  # Social vectors (Google, Apple, TikTok, IG, etc.) & pattern overlays
│   │   ├── cards/               # Event artwork cards
│   │   └── emoji/               # Reaction & milestone badges
│   └── videos/
│       └── onboarding.mp4       # Cinematic onboarding video
├── lib/
│   ├── main.dart                # App entrypoint, dotenv loading & system UI theme setup
│   ├── models/
│   │   └── onboarding_item.dart # Data models for onboarding & walkthroughs
│   ├── screens/
│   │   ├── activity_tracker_screen.dart   # Main HUD activity tracker screen
│   │   ├── dashboard_screen.dart          # Detailed Overview & Streak analytics
│   │   ├── event_detail_screen.dart       # Event overview, hosts, attendees & moments
│   │   ├── event_registration_sheet.dart  # 3-step modal registration workflow
│   │   ├── event_routine_screen.dart      # Interactive daily routine cards & ruler scrubber
│   │   ├── events_view.dart               # Embedded events controller view
│   │   ├── invite_modal_sheet.dart        # Viral referral & invite friends sheet
│   │   ├── login_screen.dart              # Red-to-black gradient social auth screen
│   │   ├── onboarding_screen.dart         # 6s cinematic video onboarding
│   │   ├── profile_view.dart              # 95% modal profile, settings, vibe & feedback
│   │   ├── running_start_screen.dart      # Fullscreen Mapbox runner with live GPS
│   │   ├── ticket_screen.dart             # Digital event ticket with barcode/QR & export
│   │   ├── user_onboarding_flow_screen.dart # 3-step user setup (Vibe, Age, Referral)
│   │   └── walk_view.dart                 # Standalone walk tracking view
│   ├── theme/
│   │   ├── app_colors.dart      # Signature gradients (#FF0050 to #000000) & palette
│   │   ├── app_theme.dart       # Material dark theme configuration
│   │   ├── app_typography.dart  # Fredoka, Quicksand & Nunito text styles
│   │   ├── huge_icons.dart      # Custom SVG & vector icon bindings
│   │   └── theme.dart           # Barrel export for theme utilities
│   └── widgets/
│       ├── bold_rounded_icons.dart        # Custom tactile iconography & button styles
│       └── onboarding/
│           └── activity_stats_overlay.dart# Floating stat pills & overlay widgets
├── test/
│   └── widget_test.dart         # Full end-to-end integration widget test suite
├── .env                         # Mapbox credentials & custom map style configuration
└── pubspec.yaml                 # Dependencies, assets & font manifests
```

---

## 🚀 Screen-by-Screen Breakdown

### 1. Cinematic Onboarding & Authentication
* **Files**: `lib/screens/onboarding_screen.dart`, `lib/screens/login_screen.dart`, `lib/screens/user_onboarding_flow_screen.dart`
* **Onboarding**: Plays `assets/videos/onboarding.mp4` with a multi-stop dark gradient veil. At 4 seconds, typed `@revivalSteps` animates in before automatically navigating to the Login screen.
* **Authentication**: Seamless vertical gradient (`#FF0050` into deep black) with one-tap Google and Apple buttons.
* **Profile Setup**: A 3-step sequence:
  1. **Pick your vibe name** (default: `kannapi`).
  2. **Age Selection** (default: `25`).
  3. **Referral Source** (Instagram, TikTok, App Store, YouTube, Twitter, etc.).

### 2. Main Activity Tracker (HUD)
* **File**: `lib/screens/activity_tracker_screen.dart`
* **Visibility Control**: Audience dropdown filter (`Everyone`, `Friends only`, `Just me (Private)`).
* **Live Activity Card**: Displays distance (`km`), current pace (`min/km`), moving time (`min/sec`), and live calories burned with haptic feedback on start/stop.
* **Bottom Control Dock**:
  - **Left**: Calendar icon opens the **Event & Routine Screen**.
  - **Center**: High-emphasis neon `+` button triggers the **Running Start Screen** with live GPS.
  - **Right**: Analytics button launches the **Dashboard Screen**.
  - **User Pill**: Tap `kannapi` to open the 95% **Profile Modal Sheet**.

### 3. Live Running Engine & Mapbox Integration
* **File**: `lib/screens/running_start_screen.dart`
* **Mapbox Engine**: Uses `flutter_map` with vector raster tiles streamed directly from Mapbox API endpoints using custom studio style IDs (`revivalstep/cmwly8jvm003c01sd1ryagazd`).
* **Map Styles**: Toggle between **RevivalStep Custom Dark**, **Satellite Streets**, and **Dark v11**.
* **GPS & Pacing**: Integrated with `geolocator` and `latlong2` for real-time positional updates, current range calculation, step count, and time elapsed.

### 4. Event & Routine Deck
* **File**: `lib/screens/event_routine_screen.dart`
* **Magnetic Month Picker**: Horizontal frosted-glass row (`January` through `December`) with auto-centering magnetic scroll.
* **Card Deck**: 48px bottom-radius canvas with tilted event preview cards (`The Lotus`, `Hydro Peak`, etc.), high-resolution artwork, and feathered progressive blur masks.
* **Timeline Ruler**: Horizontal 31-day ruler with 9 minor ticks per major day mark, centered glowing white indicator, and lateral gradient fade-outs.

### 5. Event Details, Ticketing & Registration
* **Files**: `lib/screens/event_detail_screen.dart`, `lib/screens/ticket_screen.dart`, `lib/screens/event_registration_sheet.dart`
* **Event Detail**: Quick stats (Spots left, Attendees joined, Duration), Host profile, overlapping attendee face avatars, location address with map thumbnail, and horizontal "Event Moments" photo gallery.
* **Ticket Screen**: Scalloped boarding pass with cryptographic verification hash, interactive vertical barcode, and tap-to-flip QR code view.
* **1-Tap Save**: Direct image export via `RepaintBoundary` into Photos / Downloads.
* **Registration Flow**: 3-step modal sheet featuring a custom horizontal ruler scrubber to select attendee count, instant email verification, and a scalloped completion badge.

### 6. Analytics & Streak Dashboard
* **File**: `lib/screens/dashboard_screen.dart`
* **Overview Tab**:
  - Daily step counter (e.g. `13,143 Steps`) with distance, active time, and calories.
  - Sleep health cards (`Time asleep 4h 18m`, `Sleep quality 54%`).
  - Weekly step heatmap (Monday through Sunday).
  - 2x2 Big metric matrix: Current Streak, Total Check-Ins, Average Log Time, and Goal Progress.
* **Streak Tab**:
  - Horizontal daily streak date scrubber.
  - Animated multi-color circular radial ray gauge.
  - Streak celebration badges with percentage progress increments (+18.4% growth).
  - Friends streak leaderboard and daily routines.

### 7. Profile, Referral & Feedback Sheets
* **Files**: `lib/screens/profile_view.dart`, `lib/screens/invite_modal_sheet.dart`
* **Profile Sheet**: Manage Vibe Name, Age, Terms of Service, Privacy Policy, and Feedback.
* **Invite Sheet**: Viral referral modal generating custom share links (`inviteeveryday.net/...`) with copy and native share actions.

---

## 🎨 Design Tokens & Aesthetics

| Token | Value / Spec | Purpose |
| :--- | :--- | :--- |
| **Primary Accent** | `#FF0050` (Electric Crimson) | Primary action buttons, neon glow highlights |
| **Accent Red** | `#FF3B30` | Alerts, sub-accents |
| **Accent Blue** | `#007AFF` | "Join Event" CTA, direction pills |
| **Background Dark** | `#000000` / `#0A0A0C` | Pure black AMOLED-optimized base |
| **Surface Dark** | `#121214` / `#18181B` | Card surfaces and frosted sheet containers |
| **Signature Gradient** | `[#FF0050, #8A002B, #2D000E, #000000]` | Auth screens, HUD background |
| **Typography** | `Fredoka`, `Quicksand`, `Nunito` | High readability, friendly geometric sans-serif |

---

## 🛠️ Tech Stack & Dependencies

| Package | Version | Usage |
| :--- | :--- | :--- |
| [`flutter`](https://flutter.dev) | SDK `>=3.12.2` | Core cross-platform framework |
| [`flutter_map`](https://pub.dev/packages/flutter_map) | `^8.3.2` | High-performance interactive map canvas |
| [`latlong2`](https://pub.dev/packages/latlong2) | `^0.10.1` | Coordinates, distance math, and polyline tracking |
| [`geolocator`](https://pub.dev/packages/geolocator) | `^14.1.2` | Real-time GPS location tracking and sensor polling |
| [`video_player`](https://pub.dev/packages/video_player) | `^2.14.1` | Background video playback for cinematic onboarding |
| [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv) | `^6.0.2` | Secure runtime loading of Mapbox credentials |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | `^8.2.1` | Typography fallbacks and dynamic text styling |
| [`flutter_svg`](https://pub.dev/packages/flutter_svg) | `^2.4.0` | Vector logo and iconography rendering |
| [`hugeicons`](https://pub.dev/packages/hugeicons) | `^4.4.0` | High-fidelity iconography library |

---

## ⚙️ Configuration & Environment Setup

Create or verify the `.env` file in the project root:

```env
# Mapbox Configuration
MAPBOX_ACCESS_TOKEN=your_mapbox_access_token_here
MAPBOX_STYLE_URL=mapbox://styles/revivalstep/cmwly8jvm003c01sd1ryagazd
MAPBOX_STYLE_ID=revivalstep/cmwly8jvm003c01sd1ryagazd
```

*(Note: If no `.env` file is present, the app contains fallback defaults configured in `lib/screens/running_start_screen.dart`.)*

---

## 🚦 Getting Started

### Prerequisites
- **Flutter SDK**: `>=3.12.2` (Dart 3.x)
- **Xcode** (for iOS simulator or device deployment on macOS)
- **Android Studio / Android SDK** (for Android target deployment)

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone <repo-url>
   cd revivalstep-tracker
   ```

2. **Install Flutter packages**:
   ```bash
   flutter pub get
   ```

3. **Verify static analysis**:
   ```bash
   flutter analyze
   ```

4. **Launch the app**:
   ```bash
   # Run on connected device or simulator
   flutter run
   ```

---

## 🧪 Testing & Verification

The project includes integration and widget test coverage simulating user flows:
- 6-second video onboarding transition to authentication.
- Multi-step user onboarding flow (Vibe Name, Age, Referral).
- Live HUD tracking, Mapbox runner launching, style switching, and save.
- Profile modal sheet updates (Vibe Name change, Age change, Feedback submission).
- Events deck navigation, timeline ruler scrubbing, Event Details, and 3-step Ticket Registration.
- Dual-mode Dashboard screen verification (Overview and Streak tabs).

Run the automated test suite:
```bash
flutter test
```

*Status*: **All 5 test suites pass with 0 errors.**

---

## 📄 License

This project is licensed under private proprietary terms for Herald Group / RevivalStep Tracker. All rights reserved.
# Revival-Steptracker

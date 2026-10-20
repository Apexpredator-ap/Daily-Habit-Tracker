# Production-Ready Daily Habit Tracker (Flutter + BLoC + Firebase)

An architecturally rigorous, production-grade Daily Habit Tracker built with Flutter, Dart, Clean Architecture, BLoC, and Cloud Firestore.

---

## 🏗 Architecture Overview

The project adheres strictly to **Clean Architecture** and SOLID design principles, dividing concerns into three isolated layers:

```
lib/
├── core/
│   ├── di/                 # GetIt centralized dependency injection
│   ├── error/              # Failure models & Exception classes (dartz functional handling)
│   ├── router/             # GoRouter declarative navigation
│   ├── theme/              # Centralized dark design system (colors, typography, spacing)
│   ├── usecases/           # Abstract UseCase & StreamUseCase contracts
│   └── utils/              # Localized calendar date utilities
├── features/
│   ├── authentication/     # Anonymous Auth & user session stream
│   │   ├── data/           # FirebaseAuth remote data source & repository impl
│   │   ├── domain/         # UserEntity, AuthRepository contract & use cases
│   │   └── presentation/   # AuthBloc & session events
│   ├── habits/             # Core habits management
│   │   ├── data/           # Cloud Firestore CRUD & subcollections
│   │   ├── domain/         # HabitEntity, CompletionEntity, Use Cases
│   │   └── presentation/   # TodayHabitsBloc, AddHabitBloc, UI Pages & Widgets
│   └── streaks/            # Calendar streak computation & visualization
│       ├── domain/         # StreakCalculator domain service, StreakInfo entity
│       └── presentation/   # StreaksBloc, 7-day visualization UI
└── main.dart               # MultiBlocProvider, DI bootstrap, & root app
```

---

## 🚀 Key Features

1. **Screen 1 — Today's Habits (`/`)**
   - Header with active date, today's total earned points, count ratio (e.g. `3 of 5 completed`), and dynamic progress bar.
   - Reactive list of user habits with strike-through completion styling and points pill.
   - Idempotent tap toggle with duplicate-tap debounce protection.
   - Swipe-to-archive functionality with snackbar feedback.
   - Empty state illustration with quick action.
   - Lifecycle observer detecting midnight / date transitions upon app resumption.

2. **Screen 2 — Add Habit (`/add-habit`)**
   - Clean creation form with title, positive points (1 - 1000), and optional description.
   - Domain validation guarding against empty titles, excessive length, or invalid point ranges.
   - Duplicate submission protection during asynchronous Firestore writes.

3. **Screen 3 — Habit Streaks (`/streaks`)**
   - Consecutive calendar days calculation based on persisted completion records.
   - Distinguishes current streak from historical best streak.
   - Handles month boundaries, year boundaries, leap years, and preserves yesterday's streak when today is still pending.
   - Interactive 7-day visualization displaying completed indicators and day numbers.

---

## 🗄️ Cloud Firestore Schema

Data is isolated per user under authenticated user document paths:

```
users/{userId}/habits/{habitId}
  ├── title: String
  ├── points: int
  ├── description: String?
  ├── isArchived: bool
  ├── createdAt: Timestamp
  └── updatedAt: Timestamp

users/{userId}/habits/{habitId}/completions/{yyyy-MM-dd}
  ├── isCompleted: bool
  ├── pointsEarned: int
  └── completedAt: Timestamp
```

### Security Rules (`firestore.rules`)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /habits/{habitId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;

        match /completions/{dateKey} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
    }
  }
}
```

---

## ⚙️ Setup & Verification Instructions

### 1. Configure Firebase Credentials
To link with your real Firebase Project:
1. Run `flutterfire configure` to generate `lib/firebase_options.dart` for your Android/iOS/Web target.
2. In Android, place `google-services.json` under `android/app/`.

### 2. Run Static Analysis & Format Check
```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
```

### 3. Run Automated Tests
```bash
flutter test
```
All 16 tests pass:
- `test/features/streaks/streak_calculator_test.dart` (Leap years, calendar breaks, streaks)
- `test/features/habits/create_habit_usecase_test.dart` (Validation boundaries)
- `test/features/habits/add_habit_bloc_test.dart` (BLoC states & duplicate guards)
- `test/widget_test.dart` (UI widget rendering & progress calculation)

---

## 📝 AI-Assisted Development Evidence

1. **AI Prompts Used:**
   - Prompt 1: Inspect environment, SDK constraints, connected targets, and architect Clean Architecture layout.
   - Prompt 2: Generate pure domain streak algorithm with calendar timezone logic and unit test edge cases.
   - Prompt 3: Implement Flutter Material 3 dark design system, GoRouter, GetIt DI, and Firestore remote data sources.

2. **Self-Correction Example:**
   - During static analysis with Flutter 3.32, `CardTheme` vs `CardThemeData` and `withOpacity` deprecations were flagged by the compiler. These were immediately refactored to `CardThemeData` and `.withAlpha()` to maintain clean code standards with zero warnings.

3. **Verification Command Log:**
   - `flutter pub add ...` (Exited 0)
   - `flutter analyze` (Exited 0, No issues found)
   - `dart format --output=none --set-exit-if-changed .` (Exited 0)
   - `flutter test` (Exited 0, 16/16 tests passed)

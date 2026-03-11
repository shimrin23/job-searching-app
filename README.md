# Job Search App — In-Depth Documentation

A comprehensive Flutter job searching application built with Clean Architecture, offline-first capabilities, and production-ready patterns. This document explains **every detail** of the project: architecture, data flow, every file, every pattern, and every decision.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture Deep Dive](#2-architecture-deep-dive)
3. [Project Structure — Every File Explained](#3-project-structure--every-file-explained)
4. [Application Entry Point](#4-application-entry-point)
5. [Core Layer](#5-core-layer)
6. [Domain Layer](#6-domain-layer)
7. [Data Layer](#7-data-layer)
8. [Business Logic Layer (BLoC)](#8-business-logic-layer-bloc)
9. [Presentation Layer](#9-presentation-layer)
10. [External Services](#10-external-services)
11. [State Management — Full BLoC Reference](#11-state-management--full-bloc-reference)
12. [Data Flow — Step by Step](#12-data-flow--step-by-step)
13. [Error Handling Strategy](#13-error-handling-strategy)
14. [Offline-First Caching Strategy](#14-offline-first-caching-strategy)
15. [Authentication Flow](#15-authentication-flow)
16. [Notification System](#16-notification-system)
17. [Theming System](#17-theming-system)
18. [Dependency Injection](#18-dependency-injection)
19. [Key Dependencies](#19-key-dependencies)
20. [Setup Instructions](#20-setup-instructions)
21. [Platform Support](#21-platform-support)

---

## 1. Project Overview

This is a **Flutter mobile application** that allows job seekers to:

- Browse and search real-time job listings sourced from both **The Muse public API** and a **Firebase Firestore** admin-managed collection.
- Save (bookmark) favorite jobs for later review.
- Apply to jobs via external links and track which ones they've applied to.
- Manage their user profile, including uploading a profile picture and a resume.
- Receive in-app notifications for saved jobs, submitted applications, and newly posted jobs.
- Use the app **offline** thanks to a Hive-based local cache.

The app targets Android, iOS, and Web (partial), and is structured for long-term maintainability using Clean Architecture.

---

## 2. Architecture Deep Dive

### Clean Architecture

The codebase is divided into four main layers that communicate strictly through abstractions:

```
┌──────────────────────────────────────────┐
│           Presentation Layer             │  ← UI: Screens, Widgets, Theme
│   (Flutter Widgets + BLoC consumers)     │
└──────────────┬───────────────────────────┘
               │ dispatches Events / reads State
┌──────────────▼───────────────────────────┐
│         Business Logic Layer             │  ← BLoC / Cubit
│   (Auth, Job, SavedJobs, Profile, Theme) │
└──────────────┬───────────────────────────┘
               │ calls Repository interfaces
┌──────────────▼───────────────────────────┐
│             Domain Layer                 │  ← Pure Dart: Entities + Repository interfaces
│      (No Flutter, no Firebase, no Dio)   │
└──────────────┬───────────────────────────┘
               │ implemented by
┌──────────────▼───────────────────────────┐
│              Data Layer                  │  ← Models, DataSources, Repository impls
│    (Firebase, Hive, Dio, The Muse API)   │
└──────────────────────────────────────────┘
```

**Why this matters:**
- The Domain layer has **zero external dependencies**. It contains plain Dart classes and abstract interfaces.
- The Data layer depends on the Domain layer (to implement interfaces), but the Domain layer never depends on Data.
- The BLoC layer depends only on Domain repository interfaces, not on concrete implementations.
- This means you can swap Firebase for another backend, or Hive for SQLite, without touching any BLoC or UI code.

### Key Design Patterns

| Pattern | Where Used | Purpose |
|---|---|---|
| **Repository Pattern** | `domain/repositories/` (interfaces) + `data/repositories/` (implementations) | Abstracts data sources from business logic |
| **BLoC Pattern** | `logic/` folder | Separates UI state from business logic using streams |
| **Dependency Injection** | `core/di/service_locator.dart` | Manages object creation and lifetimes centrally |
| **Offline-First** | `data/repositories/job_repository_impl.dart` | Network-first with automatic cache fallback |
| **Functional Error Handling** | `Either<Failure, T>` from `dartz` | Forces callers to handle both success and error paths explicitly |
| **Factory + Singleton** | `get_it` registration | Controls object lifecycle (lazy singletons vs. factories) |

---

## 3. Project Structure — Every File Explained

```
lib/
├── main.dart                          # App bootstrap: Firebase, Hive, DI, BLoC wiring
├── core/
│   ├── constants/
│   │   └── app_constants.dart         # All app-wide constants (URLs, box names, keys)
│   ├── di/
│   │   └── service_locator.dart       # GetIt dependency injection registry
│   ├── error/
│   │   ├── exceptions.dart            # Low-level exception types thrown by data sources
│   │   └── failures.dart              # High-level failure types returned by repositories
│   ├── network/
│   │   └── network_info.dart          # Connectivity check abstraction using connectivity_plus
│   └── utils/
│       ├── admin_helper.dart          # Admin role check utilities
│       ├── date_formatter.dart        # Human-readable date formatting
│       └── validators.dart            # Form field validators (email, password, name, phone)
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── job_local_datasource.dart    # Hive + Firestore cache for jobs, saved, applied
│   │   │   └── user_local_datasource.dart   # Hive cache for the current user
│   │   └── remote/
│   │       ├── auth_remote_datasource.dart  # Firebase Auth + Firestore user operations
│   │       └── job_remote_datasource.dart   # The Muse API + Firestore job fetching
│   ├── models/
│   │   ├── job_model.dart             # JobModel: HiveObject + fromJson/toJson + toEntity
│   │   ├── job_model_adapter.dart     # Hand-written Hive TypeAdapter for JobModel
│   │   ├── user_model.dart            # UserModel: HiveObject + fromJson/toJson + toEntity
│   │   └── user_model_adapter.dart    # Hand-written Hive TypeAdapter for UserModel
│   ├── repositories/
│   │   ├── auth_repository_impl.dart  # AuthRepository implementation (network-aware)
│   │   ├── job_repository_impl.dart   # JobRepository implementation (offline-first)
│   │   └── storage_repository_impl.dart # Firebase Storage for profile images and resumes
│   └── services/
│       └── notification_service.dart  # Firestore real-time notification listener (ChangeNotifier)
├── domain/
│   ├── entities/
│   │   ├── job.dart                   # Job entity + JobType + WorkLocation enums
│   │   ├── job_filters.dart           # JobFilters value object
│   │   ├── notification.dart          # AppNotification entity + NotificationType enum
│   │   └── user.dart                  # User entity
│   └── repositories/
│       ├── auth_repository.dart       # Abstract AuthRepository interface
│       ├── job_repository.dart        # Abstract JobRepository interface
│       └── storage_repository.dart    # Abstract StorageRepository interface
├── logic/
│   ├── auth/
│   │   ├── auth_bloc.dart             # AuthBloc: manages sign in/up/out/reset/profile update
│   │   ├── auth_event.dart            # AuthEvent subclasses
│   │   └── auth_state.dart            # AuthState (status + user + message)
│   ├── job/
│   │   ├── job_bloc.dart              # JobBloc: load, paginate, search, filter, save, apply
│   │   ├── job_event.dart             # JobEvent subclasses
│   │   └── job_state.dart             # JobState (status + jobs + pagination + filters)
│   ├── profile/
│   │   ├── profile_bloc.dart          # ProfileBloc: load, update, upload image, upload resume
│   │   ├── profile_event.dart         # ProfileEvent subclasses
│   │   └── profile_state.dart         # ProfileState (status + user + message)
│   ├── saved_jobs/
│   │   ├── saved_jobs_bloc.dart       # SavedJobsBloc: load and toggle saved jobs
│   │   ├── saved_jobs_event.dart      # SavedJobsEvent subclasses
│   │   └── saved_jobs_state.dart      # SavedJobsState
│   └── theme/
│       └── theme_cubit.dart           # ThemeCubit: persists light/dark mode in Hive
├── presentation/
│   ├── screens/
│   │   ├── admin/
│   │   │   ├── add_edit_job_screen.dart   # Admin: create or edit a job in Firestore
│   │   │   └── admin_panel_screen.dart    # Admin: list and manage all jobs
│   │   ├── auth/
│   │   │   ├── login_screen.dart          # Email + password sign-in form
│   │   │   └── signup_screen.dart         # Name + email + password sign-up form
│   │   ├── home/
│   │   │   └── home_screen.dart           # Job list with search, filters, infinite scroll
│   │   ├── job_details/
│   │   │   └── job_details_screen.dart    # Full job view: description, skills, apply button
│   │   ├── navigation/
│   │   │   └── main_navigation_screen.dart # Bottom nav: Home / Saved / Profile
│   │   ├── notifications/
│   │   │   └── notifications_screen.dart  # In-app notification list
│   │   ├── profile/
│   │   │   ├── edit_profile_screen.dart   # Edit name, phone, location, skills
│   │   │   └── profile_screen.dart        # Profile display with resume and applied jobs
│   │   ├── saved_jobs/
│   │   │   └── saved_jobs_screen.dart     # Bookmarked jobs list
│   │   └── settings/
│   │       └── settings_screen.dart       # App settings (theme toggle, notifications)
│   ├── theme/
│   │   └── app_theme.dart             # AppColors + light and dark ThemeData definitions
│   └── widgets/
│       ├── common_widgets.dart        # Shared widgets: loading, error, empty states
│       ├── filter_bottom_sheet.dart   # Bottom sheet UI for job filters
│       └── job_card.dart              # Job list item card widget
└── services/
    ├── muse_api_service.dart          # Dio-based client for The Muse public API
    └── storage_service.dart           # Helper for Firebase Storage upload/delete
```

---

## 4. Application Entry Point

**File:** `lib/main.dart`

`main()` performs the following startup sequence in order:

1. **`WidgetsFlutterBinding.ensureInitialized()`** — Required before any async work before `runApp`.
2. **`Firebase.initializeApp()`** — Connects to the Firebase project configured by the platform config files (`google-services.json` / `GoogleService-Info.plist`).
3. **`Hive.initFlutter()`** — Initializes the Hive key-value store, setting up the local storage directory.
4. **Register Hive Adapters** — `UserModelAdapter` (typeId: 0) and `JobModelAdapter` (typeId: 1) teach Hive how to serialize/deserialize each model.
5. **Clear old cache** — `Hive.deleteBoxFromDisk('users')` and `'jobs'` prevents binary format mismatches when the model schema changes.
6. **`setupServiceLocator()`** — Registers all dependencies with GetIt (see [Dependency Injection](#18-dependency-injection)).
7. **`runApp(MyApp())`** — Starts the widget tree.

### `MyApp` Widget

`MyApp` wraps the entire tree in `MultiBlocProvider`, providing:

| BLoC | Created by | Initial action |
|---|---|---|
| `AuthBloc` | `getIt<AuthBloc>()` | Fires `AuthStateChangeRequested` to check if a user is already signed in |
| `JobBloc` | `getIt<JobBloc>()` | Idle (jobs loaded lazily by `HomeScreen`) |
| `SavedJobsBloc` | `getIt<SavedJobsBloc>()` | Idle |
| `ProfileBloc` | `getIt<ProfileBloc>()` | Idle |
| `ThemeCubit` | `ThemeCubit()` | Loads persisted theme from Hive |

A `BlocBuilder<ThemeCubit, ThemeMode>` wraps `MaterialApp` so the theme reacts to toggle changes in real time.

### `AuthWrapper` Widget

`AuthWrapper` is the `home` of `MaterialApp`. It listens to `AuthBloc` and routes to:
- `MainNavigationScreen` when `AuthStatus.authenticated`
- `LoginScreen` when `AuthStatus.unauthenticated`
- A full-screen `CircularProgressIndicator` during the `initial` / `loading` state

---

## 5. Core Layer

### `core/constants/app_constants.dart`

Contains two classes:

**`AppConstants`** — Runtime constants used throughout the app:

| Constant | Value | Purpose |
|---|---|---|
| `baseUrl` | `'https://api.example.com/v1'` | Placeholder REST API base URL |
| `pageSize` | `20` | Jobs fetched per page |
| `jobsBox` | `'jobs_box'` | Hive box name for job cache |
| `userBox` | `'user_box'` | Hive box name for user cache |
| `savedJobsBox` | `'saved_jobs_box'` | Hive box name for saved job IDs |
| `cacheValidity` | `Duration(hours: 1)` | How long cached data is considered fresh |
| `usersCollection` | `'users'` | Firestore top-level collection |
| `jobsCollection` | `'jobs'` | Firestore top-level collection |
| `applicationsCollection` | `'applications'` | Firestore top-level collection |
| `resumesPath` | `'resumes'` | Firebase Storage folder |
| `profileImagesPath` | `'profile_images'` | Firebase Storage folder |

**`Routes`** — Named route strings for `MaterialApp` navigation.

### `core/di/service_locator.dart`

See [Dependency Injection](#18-dependency-injection).

### `core/error/exceptions.dart`

Low-level exceptions thrown **inside** data sources (remote and local). They are caught by the repository implementations and converted into `Failure` objects.

| Exception | Thrown When |
|---|---|
| `ServerException(message, statusCode?)` | HTTP errors or Firestore errors in remote sources |
| `NetworkException(message)` | No network connection |
| `CacheException(message)` | Hive read/write failures |
| `AuthException(message, code?)` | Firebase Auth errors (with Firebase error codes) |
| `ValidationException(message)` | Input validation failures |
| `ParsingException(message)` | JSON parsing failures |
| `StorageException(message)` | Firebase Storage errors |

### `core/error/failures.dart`

High-level `Failure` classes returned by repositories as `Left(failure)` in `Either<Failure, T>`. The BLoC layer converts these into user-visible error messages.

**Hierarchy:**

```
Failure (abstract, extends Equatable)
├── ServerFailure        — remote API errors
├── NetworkFailure       — no connectivity
├── TimeoutFailure       — request timed out
├── AuthFailure          — general auth errors
│   ├── InvalidCredentialsFailure
│   ├── WeakPasswordFailure
│   ├── EmailAlreadyInUseFailure
│   └── UserNotFoundFailure
├── CacheFailure         — local storage errors
├── ParsingFailure       — deserialization errors
├── NotFoundFailure      — resource not in cache or API
├── ValidationFailure    — invalid input
├── PermissionFailure    — missing OS permissions
├── StorageFailure       — Firebase Storage errors
│   └── FileUploadFailure
└── UnknownFailure       — unexpected errors
```

Each `Failure` carries a human-readable `message` string that is surfaced directly in the UI.

### `core/network/network_info.dart`

```dart
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}
```

`NetworkInfoImpl` wraps `connectivity_plus`'s `Connectivity` class. `isConnected` returns `true` if the result does not contain `ConnectivityResult.none`. The stream version allows widgets to react to connectivity changes in real time.

### `core/utils/validators.dart`

Static form validation methods returning `String? error` (compatible with `TextFormField.validator`):

- `validateEmail` — regex check for valid email format
- `validatePassword` — minimum 6 characters
- `validateName` — minimum 2 characters
- `validatePhone` — regex for `+? digits/spaces/dashes`, minimum 10 digits
- `validateRequired` — generic non-empty check

---

## 6. Domain Layer

The domain layer contains **pure Dart** — no Flutter widgets, no Firebase SDK, no Dio. It defines what the app *does*, not *how* it does it.

### Entities

Entities extend `Equatable` for value equality (used in BLoC state comparisons).

#### `Job` Entity

The core business object:

| Field | Type | Description |
|---|---|---|
| `id` | `String` | Unique identifier (from Firestore doc ID or Muse API numeric ID as string) |
| `title` | `String` | Job title |
| `company` | `String` | Company name |
| `companyLogoUrl` | `String?` | URL for the company logo image |
| `location` | `String` | City/region where the job is located |
| `workLocation` | `WorkLocation` | `onsite`, `remote`, or `hybrid` |
| `jobType` | `JobType` | `fullTime`, `partTime`, `contract`, `internship`, `temporary` |
| `description` | `String` | Full job description (may contain HTML from The Muse API) |
| `responsibilities` | `List<String>` | Bullet-point list of job responsibilities |
| `requirements` | `List<String>` | Bullet-point list of requirements |
| `benefits` | `List<String>` | List of offered benefits |
| `salaryRange` | `String?` | e.g., `"$80,000 – $120,000"` |
| `experienceLevel` | `String?` | e.g., `"Mid Level"`, `"Senior Level"` |
| `skills` | `List<String>` | Tags shown as chips on the job details screen |
| `applyUrl` | `String?` | External URL opened when the user taps "Apply" |
| `postedDate` | `DateTime` | When the job was posted |
| `deadline` | `DateTime?` | Application deadline |
| `isSaved` | `bool` | Whether the current user has saved this job |
| `isApplied` | `bool` | Whether the current user has applied to this job |

The `Job.copyWith()` method is used extensively by repository implementations to merge `isSaved`/`isApplied` flags onto fetched jobs.

#### `JobFilters` Entity

A value object (immutable, equatable) that holds the current search/filter criteria:

| Field | Type |
|---|---|
| `searchQuery` | `String?` |
| `jobTypes` | `List<JobType>?` |
| `workLocations` | `List<WorkLocation>?` |
| `location` | `String?` |
| `experienceLevel` | `String?` |
| `skills` | `List<String>?` |
| `postedAfter` | `DateTime?` |

`JobFilters.isEmpty` returns `true` when no filters are active, which the UI uses to show/hide the "clear filters" button.

#### `User` Entity

| Field | Type |
|---|---|
| `id` | `String` (Firebase UID) |
| `email` | `String` |
| `name` | `String?` |
| `phone` | `String?` |
| `profileImageUrl` | `String?` |
| `resumeUrl` | `String?` |
| `skills` | `List<String>` |
| `location` | `String?` |
| `createdAt` | `DateTime` |
| `updatedAt` | `DateTime?` |

#### `AppNotification` Entity

| Field | Type |
|---|---|
| `id` | `String` (Firestore doc ID) |
| `title` | `String` |
| `message` | `String` |
| `type` | `NotificationType` (jobAlert, applicationUpdate, newJob, recommendation, system) |
| `timestamp` | `DateTime` |
| `isRead` | `bool` |
| `jobId` | `String?` |
| `imageUrl` | `String?` |

### Repository Interfaces

#### `AuthRepository`

```dart
Future<Either<Failure, User>> signIn({email, password});
Future<Either<Failure, User>> signUp({email, password, name});
Future<Either<Failure, void>> signOut();
Future<Either<Failure, void>> resetPassword(String email);
Future<Either<Failure, User>> getCurrentUser();
Stream<User?> get authStateChanges;
Future<Either<Failure, User>> updateProfile({name, phone, location, skills, profileImageUrl});
```

#### `JobRepository`

```dart
Future<Either<Failure, List<Job>>> getJobs({int page, JobFilters? filters});
Future<Either<Failure, Job>> getJobById(String jobId);
Future<Either<Failure, List<Job>>> searchJobs(String query);
Future<Either<Failure, void>> saveJob(String jobId);
Future<Either<Failure, void>> unsaveJob(String jobId);
Future<Either<Failure, List<Job>>> getSavedJobs();
Future<Either<Failure, void>> applyToJob(String jobId);
Future<Either<Failure, List<Job>>> getAppliedJobs();
Future<Either<Failure, void>> clearCache();
```

#### `StorageRepository`

```dart
Future<Either<Failure, String>> uploadResume(File file, String userId);
Future<Either<Failure, String>> uploadProfileImage(File file, String userId);
Future<Either<Failure, void>> deleteFile(String fileUrl);
```

---

## 7. Data Layer

### Models

Models extend `HiveObject` (to support persistence in Hive boxes) and include both JSON serialization and entity conversion methods.

#### `JobModel`

- **`@HiveType(typeId: 1)`** — Identifies this model to Hive's binary serializer. Each field is annotated with `@HiveField(index)` mapping to binary field positions.
- **`fromJson(Map<String, dynamic> json)`** — Detects whether the JSON comes from The Muse API (checks for `'name'` key) or from Firestore/standard format, and delegates to the appropriate factory. **Known limitation:** this heuristic will break if Firestore job documents ever include a field named `'name'`. A more robust discriminator (e.g., a `source: 'muse'` field or checking for the numeric `id` type) should be used in production.
- **`fromMuseApi(json)`** — Maps The Muse API's non-standard structure: `json['name']` → `title`, `json['company']['name']` → `company`, `json['locations'][0]['name']` → `location`, `json['levels'][0]['name']` → `experienceLevel`, `json['categories']` → `skills`, `json['refs']['landing_page']` → `applyUrl`, `json['contents']` → `description`.
- **`toJson()`** — Serializes to Firestore-compatible map.
- **`fromEntity(Job job)`** — Converts a domain entity to a model for caching.
- **`toEntity()`** — Converts a model back to a domain entity.

#### `UserModel`

Same pattern as `JobModel` but for users. The `fromJson` handles both ISO-8601 string dates and raw `DateTime` objects (Firestore returns `Timestamp` objects that are pre-converted by the data source).

#### Hive Adapters

Because Hive uses binary serialization and these models are not code-generated (no `build_runner`), the adapters are **hand-written**:

- `JobModelAdapter` — `typeId: 1`, reads and writes all 19 fields in the exact same order. Dates are stored as Unix epoch milliseconds (`writeInt` / `readInt`).
- `UserModelAdapter` — `typeId: 0`, uses a `try/catch` block during `read()` to gracefully handle old cached data that was written with a smaller number of fields (backward compatibility).

### Remote Data Sources

#### `AuthRemoteDataSource` / `AuthRemoteDataSourceImpl`

Uses **Firebase Authentication** for credential management and **Firestore** for extended user profile data.

| Method | Firebase Auth | Firestore |
|---|---|---|
| `signIn` | `signInWithEmailAndPassword` | Reads `users/{uid}` doc |
| `signUp` | `createUserWithEmailAndPassword` | Writes new `users/{uid}` doc |
| `signOut` | `signOut()` | — |
| `resetPassword` | `sendPasswordResetEmail` | — |
| `getCurrentUser` | Reads `currentUser` | Reads `users/{uid}` doc |
| `authStateChanges` | `authStateChanges()` stream | Reads user doc on each auth event |
| `updateProfile` | — | Updates `users/{uid}` doc fields |

Firebase Auth error codes (e.g., `user-not-found`, `wrong-password`, `email-already-in-use`) are mapped to human-readable messages before being re-thrown as `AuthException`.

#### `JobRemoteDataSource` / `JobRemoteDataSourceImpl`

Aggregates jobs from **two sources** and merges them:

1. **Firestore** (`jobs` collection) — Jobs manually added by an admin through the admin panel. Supports basic `where` filtering by title prefix and ordered by `postedDate`.
2. **The Muse API** — Public job API (see [External Services](#10-external-services)). Returns paginated job listings from real companies.

Duplicates (same `id`) are removed using a `Map<String, JobModel>` de-duplication step.

For `searchJobs`: first tries company name search via The Muse API; if that returns nothing, fetches a general page of jobs and filters locally by title, company, and location substring match.

### Local Data Sources

#### `JobLocalDataSourceImpl`

Uses three Hive boxes:

| Box | Key | Value | Purpose |
|---|---|---|---|
| `jobs_box` | `job.id` | `JobModel` | Full job object cache |
| `saved_jobs_box` | `'$userId:$jobId'` | `String (jobId)` | Per-user saved job IDs (local copy) |
| `applied_jobs_box` | `'$userId:$jobId'` | `String (jobId)` | Per-user applied job IDs (local copy) |

Importantly, `saveJob` / `unsaveJob` / `markAsApplied` also write to **Firestore** sub-collections (`users/{uid}/saved_jobs/{jobId}`) so the data is persisted in the cloud and survives app reinstalls. The local Hive copy is used for faster offline reads.

#### `UserLocalDataSourceImpl`

Stores a single `UserModel` under the key `'current_user'` in the `user_box` Hive box. Cache is cleared on sign-out.

### Repository Implementations

#### `AuthRepositoryImpl`

Implements the **cache-first** strategy for `getCurrentUser`:
1. Try local Hive cache — if found, return immediately.
2. If not cached and connected, fetch from Firebase and cache result.

All network operations first check `networkInfo.isConnected` and return `Left(NetworkFailure())` if offline.

Converts low-level `AuthException` codes into specific `Failure` subclasses:
- `'user-not-found'` / `'wrong-password'` → `InvalidCredentialsFailure`
- `'email-already-in-use'` → `EmailAlreadyInUseFailure`
- `'weak-password'` → `WeakPasswordFailure`

#### `JobRepositoryImpl`

Implements the **network-first, cache-fallback** strategy for `getJobs`:

```
isConnected?
  YES → fetch from remote → cache results → merge isSaved/isApplied → return Right(jobs)
  NO  → get from Hive cache → merge isSaved/isApplied → return Right(jobs)
       (if cache is empty → return Left(NetworkFailure('No cached data available')))
```

On page 1, the cache is cleared before re-populating to avoid stale data. On subsequent pages (pagination), new jobs are appended to the cache.

`searchJobs` when offline: filters the in-memory Hive cache by title, company, and description substring match.

---

## 8. Business Logic Layer (BLoC)

All BLoCs use the `flutter_bloc` package and follow the event-driven pattern: the UI dispatches `Event` objects, the BLoC processes them and emits `State` objects, and the UI rebuilds in response.

### `AuthBloc`

**Events:**

| Event | Fields | Trigger |
|---|---|---|
| `SignInRequested` | `email`, `password` | User taps "Sign In" |
| `SignUpRequested` | `email`, `password`, `name` | User taps "Create Account" |
| `SignOutRequested` | — | User taps "Sign Out" |
| `ResetPasswordRequested` | `email` | User taps "Forgot Password" |
| `AuthStateChangeRequested` | — | App startup, checks for existing session |
| `UpdateProfileRequested` | `name?`, `phone?`, `location?`, `skills?` | User saves profile edits |

**State:**

```dart
class AuthState {
  final AuthStatus status;  // initial | loading | authenticated | unauthenticated | error
  final User? user;
  final String? message;
}
```

**Important detail:** The constructor subscribes to `authRepository.authStateChanges` (a `Stream<User?>`). This means the BLoC automatically emits `authenticated`/`unauthenticated` states whenever Firebase's auth state changes (e.g., token expiry, sign-in from another device), even without the UI dispatching an event.

### `JobBloc`

**Events:**

| Event | Fields | Trigger |
|---|---|---|
| `LoadJobs` | `refresh: bool`, `filters?` | Initial load, pull-to-refresh |
| `LoadNextPage` | — | User scrolls to 90% of list |
| `SearchJobs` | `query: String` | User submits search form |
| `ApplyFilters` | `filters: JobFilters` | User applies filter bottom sheet |
| `ToggleSaveJob` | `jobId: String` | User taps bookmark icon |
| `ApplyToJob` | `jobId: String` | User taps "Apply" on job details |
| `ClearCache` | — | Admin panel cache clear action |

**State:**

```dart
class JobState {
  final JobStatus status;      // initial | loading | loaded | error | refreshing
  final List<Job> jobs;
  final String? message;
  final int currentPage;
  final bool hasReachedMax;    // true when last fetched page had < 20 items
  final bool isFetchingMore;   // true during background pagination
  final JobFilters? filters;
}
```

**Pagination logic:** `LoadNextPage` is a no-op if `hasReachedMax` or `isFetchingMore` is already `true`. On success, new jobs are appended to `state.jobs` via `List.of(state.jobs)..addAll(newJobs)`.

**Save/unsave optimistic update:** `ToggleSaveJob` immediately flips the `isSaved` flag in the state (so the UI responds instantly), then calls the repository in the background. There is no rollback if the repository call fails — a known simplification for this portfolio project. Production code should reverse the optimistic update on failure (e.g., catch the error and emit the original state).

### `SavedJobsBloc`

Manages the separate "Saved Jobs" tab. Loads saved jobs from the repository and supports toggling (unsaving) directly from the saved list.

### `ProfileBloc`

**Events:**

| Event | Fields |
|---|---|
| `LoadProfile` | — |
| `UpdateProfile` | `user: User` |
| `UploadResume` | `filePath: String` |
| `UploadProfileImage` | `filePath: String` |

`UploadResume` and `UploadProfileImage` both:
1. Upload the file via `StorageRepository`
2. Update the user's `resumeUrl` / `profileImageUrl` in `AuthRepository`
3. Emit the updated `User` entity

### `ThemeCubit`

A simple `Cubit<ThemeMode>` that:
- Loads the persisted theme index from a Hive box named `'settings'` on construction.
- `toggleTheme()` switches between `ThemeMode.light` and `ThemeMode.dark` and persists the choice.

---

## 9. Presentation Layer

### Navigation

**`MainNavigationScreen`** implements a `BottomNavigationBar` with three tabs using `IndexedStack` (all three screens stay mounted, preserving scroll position):

| Index | Tab | Screen |
|---|---|---|
| 0 | Home | `HomeScreen` |
| 1 | Saved | `SavedJobsScreen` |
| 2 | Profile | `ProfileScreen` |

`MaterialApp` also registers named routes for auth screens and `onGenerateRoute` for `/job-details` (which passes a `Job` object as an argument).

### Screens

**`LoginScreen`** — Email/password form with validation, dispatches `SignInRequested`. Also links to `SignUpScreen` and a forgot-password dialog that dispatches `ResetPasswordRequested`.

**`SignUpScreen`** — Name/email/password form, dispatches `SignUpRequested`.

**`HomeScreen`** — The main job browsing screen:
- A `ScrollController` detects when the user has scrolled to 90% of the list and dispatches `LoadNextPage`.
- A `TextField` for search dispatches `SearchJobs` on submission.
- A filter icon opens `FilterBottomSheet`.
- A notification bell (with unread badge) navigates to `NotificationsScreen`.
- Connects to `NotificationService` via `addListener` to update the badge count.

**`JobDetailsScreen`** — Displays all `Job` fields. Renders `description` using `flutter_html` (since The Muse API returns HTML content). Provides an "Apply" button that opens `applyUrl` via `url_launcher`.

**`SavedJobsScreen`** — Lists saved jobs from `SavedJobsBloc`. Shows an empty state illustration when no jobs are saved.

**`ProfileScreen`** — Displays user info, resume download link, list of applied jobs, and a sign-out button.

**`EditProfileScreen`** — Form for updating name, phone, location, and skills. Skills are managed as a tag-input list.

**`NotificationsScreen`** — Reads from `NotificationService`, displays notifications in a list, supports swipe-to-delete and mark-all-as-read.

**`SettingsScreen`** — Theme toggle (light/dark) and notification preferences.

**`AdminPanelScreen`** — Visible only to users flagged as admin (checked by `admin_helper.dart`). Lists Firestore jobs and allows add/edit/delete.

**`AddEditJobScreen`** — Form for creating or editing a Firestore job document.

### Widgets

**`job_card.dart`** — Renders a single `Job` in a `Card`. Shows company logo (via `cached_network_image`), title, company, location badge, job type chip, posted date (via `timeago`), and a bookmark toggle button.

**`filter_bottom_sheet.dart`** — A `DraggableScrollableSheet` with checkboxes for `JobType`, `WorkLocation`, and text fields for location and experience level. Dispatches `ApplyFilters` on apply.

**`common_widgets.dart`** — Shared stateless widgets:
- `LoadingWidget` — `CircularProgressIndicator` centered
- `ErrorWidget` — Error message with a retry button
- `EmptyStateWidget` — Illustration + message for empty lists
- `ShimmerJobCard` — Shimmer loading placeholder for job cards

### Theme

**`AppColors`** — A sealed class of `const Color` values using Material Design grey scale and semantic colors (primary blue `0xFF2563EB`, secondary green `0xFF10B981`, success/error/warning/info).

**`AppTheme.lightTheme`** — Configures `AppBarTheme`, `CardThemeData`, `ElevatedButtonThemeData`, `OutlinedButtonThemeData`, `InputDecorationTheme`, `ChipThemeData`, and `BottomNavigationBarThemeData` — all using `AppColors` and consistent `BorderRadius.circular(8)` / `(12)` rounding.

**`AppTheme.darkTheme`** — Provides a dark `ColorScheme` using the lighter variants of primary and secondary colors against dark surface colors.

---

## 10. External Services

### The Muse API (`services/muse_api_service.dart`)

Base URL: `https://www.themuse.com/api/public`

| Method | Endpoint | Description |
|---|---|---|
| `getJobs(page, pageSize, category?, level?, location?, company?)` | `GET /jobs` | Paginated job listing |
| `getJobById(jobId)` | `GET /jobs/{id}` | Single job by numeric ID |
| `searchJobs(query, page?)` | `GET /jobs?company={query}` | Search by company name |
| `getCategories()` | `GET /categories` | Available job categories |

The API is **free** and requires no API key for basic usage. Response parsing is handled in `JobModel.fromMuseApi()`.

### Firebase Services

| Service | SDK Package | Usage |
|---|---|---|
| Firebase Auth | `firebase_auth` | User sign-in, sign-up, password reset, auth state stream |
| Cloud Firestore | `cloud_firestore` | User profiles, admin-managed jobs, saved/applied sub-collections, notifications |
| Firebase Storage | `firebase_storage` | Profile images and resume file uploads |
| Firebase Messaging | `firebase_messaging` | Registered in DI but not yet fully integrated for push notifications |

**Firestore Data Structure:**

```
users/
  {uid}/
    email, name, phone, profileImageUrl, resumeUrl, skills, location, createdAt, updatedAt
    saved_jobs/
      {jobId}/   → { jobId, savedAt: ServerTimestamp }
    applied_jobs/
      {jobId}/   → { jobId, appliedAt: ServerTimestamp }
    notifications/
      {notifId}/ → { title, message, type, timestamp, isRead, jobId?, imageUrl? }

jobs/
  {jobId}/
    title, company, location, workLocation, jobType, description,
    responsibilities[], requirements[], benefits[], salaryRange,
    experienceLevel, skills[], applyUrl, postedDate, deadline
```

### Hive (Local Storage)

Hive is used for offline-first caching:

| Box Name | Type | Content |
|---|---|---|
| `jobs_box` | `Box<JobModel>` | Job list cache, keyed by `jobId` |
| `user_box` | `Box<UserModel>` | Current user profile cache |
| `saved_jobs_box` | `Box<String>` | Saved job ID set (local copy) |
| `applied_jobs_box` | `Box<String>` | Applied job ID set (local copy) |
| `settings` | `Box<dynamic>` | Theme preference (index 0, 1, or 2) |

---

## 11. State Management — Full BLoC Reference

```
UI Widget
  │
  │ context.read<XBloc>().add(XEvent(...))
  ▼
XBloc.on<XEvent>(_handler)
  │
  │ emit(newState)
  ▼
BlocBuilder<XBloc, XState>(
  builder: (context, state) {
    // rebuild with new state
  }
)
```

All BLoC states implement `Equatable` so that `flutter_bloc` only triggers rebuilds when the state actually changes (deep equality comparison via `props`).

`BlocListener` is used for side effects (e.g., showing a `SnackBar` on error or success) without causing full widget rebuilds. `BlocConsumer` combines `BlocBuilder` + `BlocListener`.

---

## 12. Data Flow — Step by Step

### Job Listing on App Start

```
HomeScreen.initState()
  → JobBloc.add(LoadJobs())
  → JobBloc._onLoadJobs()
    → emit(state.copyWith(status: JobStatus.loading))
    → JobRepositoryImpl.getJobs(page: 1)
      → NetworkInfoImpl.isConnected → true
      → JobRemoteDataSourceImpl.getJobs()
        → Firestore.collection('jobs').get()   [admin jobs]
        → MuseApiService.getJobs(page: 0)      [public API jobs]
        → de-duplicate by id
        → return List<JobModel>
      → JobLocalDataSource.clearCache()
      → JobLocalDataSource.cacheJobs(models)
      → JobLocalDataSource.getSavedJobIds()    [Firestore sub-collection]
      → JobLocalDataSource.getAppliedJobIds()  [Firestore sub-collection]
      → merge isSaved/isApplied onto entities
      → return Right(List<Job>)
    → emit(state.copyWith(status: JobStatus.loaded, jobs: jobs))
  → BlocBuilder rebuilds JobList
```

### User Sign-In

```
LoginScreen taps "Sign In"
  → AuthBloc.add(SignInRequested(email, password))
  → emit(state.copyWith(status: AuthStatus.loading))
  → AuthRepositoryImpl.signIn(email, password)
    → NetworkInfoImpl.isConnected → true
    → AuthRemoteDataSourceImpl.signIn(email, password)
      → FirebaseAuth.signInWithEmailAndPassword()
      → Firestore.collection('users').doc(uid).get()
      → return UserModel
    → UserLocalDataSource.cacheUser(model)
    → return Right(user)
  → emit(state.copyWith(status: AuthStatus.authenticated, user: user))
  → AuthWrapper rebuilds → MainNavigationScreen
```

---

## 13. Error Handling Strategy

The app uses a **two-layer error conversion** strategy to keep concerns separated:

**Layer 1 — Data Sources throw Exceptions:**
```
AuthRemoteDataSourceImpl.signIn()
  → catch FirebaseAuthException → throw AuthException(message, code)
  → catch generic → throw AuthException('Failed to sign in: $e')
```

**Layer 2 — Repositories catch Exceptions, return Failures:**
```
AuthRepositoryImpl.signIn()
  → catch AuthException(code: 'user-not-found') → return Left(InvalidCredentialsFailure())
  → catch AuthException → return Left(AuthFailure(e.message))
  → catch NetworkException → return Left(NetworkFailure())
  → catch generic → return Left(UnknownFailure(e.toString()))
```

**Layer 3 — BLoC handles Failures, emits error state:**
```
result.fold(
  (failure) => emit(state.copyWith(status: AuthStatus.error, message: failure.message)),
  (user) => emit(state.copyWith(status: AuthStatus.authenticated, user: user)),
)
```

**Layer 4 — UI displays error message:**
```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message ?? 'An error occurred')),
      );
    }
  },
)
```

---

## 14. Offline-First Caching Strategy

```
Request arrives
      │
      ▼
Is device online?
  ┌────YES────┐         ┌────NO────┐
  │           │         │          │
  ▼           │         ▼          │
Fetch         │     Read Hive      │
from API/     │     cache          │
Firebase      │         │          │
  │           │         ▼          │
  ▼           │     Cache empty?   │
Write to      │       YES → return Left(NetworkFailure)
Hive cache    │       NO  → return Right(cachedData)
  │           │
  ▼           │
Merge         │
saved/applied │
flags         │
  │           │
  ▼           │
return        │
Right(data)   │
```

**Cache invalidation:** The job cache is fully cleared and re-populated on every page-1 fetch. Saved and applied job ID caches are refreshed from Firestore on every `getSavedJobIds()` / `getAppliedJobIds()` call (which happens on every `getJobs` call).

---

## 15. Authentication Flow

```
App Launch
    │
    ▼
AuthBloc receives AuthStateChangeRequested
    │
    ├─→ AuthRepository.getCurrentUser()
    │     ├─→ Local cache hit → emit(authenticated, cachedUser)
    │     └─→ No cache → Firebase.currentUser → fetch Firestore doc
    │
    ▼
Firebase authStateChanges stream (always active)
    │
    ├─→ User signed in → emit(authenticated)
    └─→ User signed out → emit(unauthenticated)

AuthWrapper reads state:
  authenticated → MainNavigationScreen
  unauthenticated → LoginScreen
  loading/initial → CircularProgressIndicator
```

On sign-out:
1. `AuthBloc.add(SignOutRequested())` 
2. `AuthRepository.signOut()` calls Firebase Auth `signOut()` and clears Hive user cache
3. Firebase's `authStateChanges` stream emits `null`
4. `AuthBloc` emits `unauthenticated`
5. `AuthWrapper` navigates to `LoginScreen`

---

## 16. Notification System

**File:** `lib/data/services/notification_service.dart`

`NotificationService` is a singleton `ChangeNotifier` that:

1. **Listens** to `users/{uid}/notifications` in Firestore using a real-time `snapshots()` stream.
2. **Converts** each Firestore document to an `AppNotification` entity.
3. **Calls `notifyListeners()`** so that widgets registered with `addListener()` (like `HomeScreen`) rebuild their notification badge count.

| Method | Action |
|---|---|
| `initializeNotifications()` | Starts the Firestore listener (idempotent) |
| `markAsRead(id)` | Updates `isRead: true` in Firestore |
| `markAllAsRead()` | Batch-updates all unread notifications |
| `deleteNotification(id)` | Deletes the Firestore document |
| `sendNotificationToUser(userId, ...)` | Creates a notification for one user |
| `sendNotificationToAll(...)` | Batch-creates notifications for all users |
| `notifyJobSaved(jobTitle)` | Convenience: sends a system notification on save |
| `notifyJobApplied(jobTitle, jobId)` | Convenience: sends applicationUpdate notification |
| `notifyNewJobPosted(jobTitle, jobId)` | Convenience: notifies all users of a new admin job |

The `unreadCount` getter is used by `HomeScreen` to display the red badge dot on the notification bell icon.

---

## 17. Theming System

The app supports **light and dark** themes. The `ThemeCubit` persists the user's preference in Hive and emits `ThemeMode` values that `MaterialApp.themeMode` reacts to.

**Color palette (light theme):**

| Role | Color | Hex |
|---|---|---|
| Primary | Blue | `#2563EB` |
| Secondary | Green | `#10B981` |
| Error | Red | `#EF4444` |
| Background | Light grey | `#F9FAFB` |
| Surface (cards) | White | `#FFFFFF` |

**Consistent design tokens applied to:**
- App bars: white background, no elevation, left-aligned title
- Cards: 1dp elevation, 12px border radius
- Buttons: no elevation, 8px border radius, 24/12px padding
- Inputs: filled grey background, 8px border radius, 2px primary border on focus
- Chips: light grey background, 16px border radius
- Bottom navigation: white, primary selected, grey unselected

---

## 18. Dependency Injection

**File:** `lib/core/di/service_locator.dart`

Uses `get_it` as a service locator. All registrations happen in `setupServiceLocator()` called at app startup.

**Registration types:**
- `registerLazySingleton` — created once on first access, shared thereafter (external services, repositories, data sources)
- `registerFactory` — creates a new instance on every `getIt<T>()` call (BLoCs — each screen gets a fresh BLoC)

**Registration order matters** — dependencies must be registered before the objects that use them:

```
1. SharedPreferences          (async await)
2. Firebase instances         (Auth, Firestore, Storage, Messaging)
3. Connectivity
4. Dio                        (with logging interceptor)
5. NetworkInfo                (depends on Connectivity)
6. StorageService
7. Local DataSources          (no external deps besides Hive)
8. Remote DataSources         (depend on Dio, Firestore, FirebaseAuth)
9. Repositories               (depend on both datasources + NetworkInfo)
10. BLoCs                     (depend on Repositories)
```

---

## 19. Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_bloc` | ^8.1.6 | BLoC/Cubit state management |
| `equatable` | ^2.0.5 | Value equality for BLoC states/events |
| `get_it` | ^8.0.2 | Dependency injection / service locator |
| `firebase_core` | ^3.8.1 | Firebase initialization |
| `firebase_auth` | ^5.3.4 | User authentication |
| `cloud_firestore` | ^5.5.3 | Cloud database for users, jobs, notifications |
| `firebase_storage` | ^12.3.8 | File uploads (profile images, resumes) |
| `firebase_messaging` | ^15.1.8 | Push notification infrastructure |
| `dio` | ^5.7.0 | HTTP client for The Muse API with interceptors |
| `connectivity_plus` | ^6.1.1 | Network connectivity detection |
| `hive` | ^2.2.3 | Embedded key-value store for offline cache |
| `hive_flutter` | ^1.1.0 | Flutter initialization helper for Hive |
| `shared_preferences` | ^2.3.3 | Simple key-value storage (preferences) |
| `flutter_secure_storage` | ^9.2.2 | Encrypted storage for sensitive data |
| `cached_network_image` | ^3.4.1 | Image caching with placeholder and error widgets |
| `image_picker` | ^1.1.2 | Camera and gallery image selection |
| `go_router` | ^14.6.2 | Declarative routing (available but Navigator 1.0 still used) |
| `flutter_svg` | ^2.0.10 | SVG asset rendering |
| `shimmer` | ^3.0.0 | Skeleton loading animation |
| `intl` | ^0.20.1 | Date formatting and internationalization |
| `url_launcher` | ^6.3.1 | Opens job application URLs in browser |
| `flutter_html` | ^3.0.0-beta.2 | Renders HTML job descriptions |
| `share_plus` | ^10.1.3 | Share job listings via system share sheet |
| `timeago` | ^3.7.0 | Human-readable relative times ("2 hours ago") |
| `webview_flutter` | ^4.10.0 | In-app web view for job pages |
| `file_picker` | ^8.1.6 | Resume PDF file selection |
| `path_provider` | ^2.1.5 | Device file system paths |
| `uuid` | ^4.5.1 | UUID generation for local IDs |
| `path` | ^1.9.0 | File path manipulation |
| `package_info_plus` | ^8.1.2 | App version info for the settings screen |
| `dartz` | ^0.10.1 | Functional programming: `Either`, `Option` |
| `logger` | ^2.5.0 | Structured logging |

---

## 20. Setup Instructions

### Prerequisites

- Flutter SDK `>= 3.9.2` and Dart SDK `^3.9.2`
- Firebase account (free Spark plan is sufficient)
- Android Studio (for Android) or Xcode (for iOS)

### Step 1 — Clone and install

```bash
git clone <repository-url>
cd job-searching-app
flutter pub get
```

### Step 2 — Configure Firebase

Follow the detailed steps in `FIREBASE_SETUP.md`. In summary:

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com/).
2. Add Android and/or iOS apps.
3. Download and place config files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
4. In the Firebase console, enable:
   - **Authentication** → Email/Password provider
   - **Firestore Database** → Create in production or test mode
   - **Cloud Storage** → Enable with default rules
   - **Cloud Messaging** → Enable (optional, for push notifications)

### Step 3 — Firestore Security Rules (recommended)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /saved_jobs/{jobId} { allow read, write: if request.auth.uid == userId; }
      match /applied_jobs/{jobId} { allow read, write: if request.auth.uid == userId; }
      match /notifications/{notifId} { allow read, write: if request.auth.uid == userId; }
    }
    match /jobs/{jobId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

### Step 4 — Run the app

```bash
# Debug mode
flutter run

# Specific platform
flutter run -d android
flutter run -d ios
flutter run -d chrome
```

### Step 5 — Run tests

```bash
flutter test
```

---

## 21. Platform Support

| Platform | Status | Notes |
|---|---|---|
| Android | ✅ Full | Primary target platform |
| iOS | ✅ Full | Requires Xcode and Apple Developer account |
| Web | ⚠️ Partial | Firebase works; Hive has web limitations; file picker may differ |
| Windows | ⚠️ Partial | Desktop build possible; Firebase desktop support may require additional config |
| macOS | ⚠️ Partial | Same as Windows |
| Linux | ⚠️ Partial | Same as Windows |

---

## Contributing

This is a learning and portfolio project. Feel free to fork and customize!

## License

MIT License

---

> **Production checklist before deploying:**
> - Replace placeholder `baseUrl` in `app_constants.dart` with your actual API.
> - Configure proper Firestore security rules.
> - Add API key management (do not hardcode secrets).
> - Implement comprehensive error logging and crash reporting (e.g., Firebase Crashlytics).
> - Add analytics (e.g., Firebase Analytics).
> - Set up CI/CD pipelines.
> - Perform a security audit.
> - Write comprehensive unit and widget tests.
> - Replace the `'name'` key heuristic in `JobModel.fromJson` with a reliable source discriminator (e.g., a `source` field) to avoid misclassification of Firestore jobs.
> - Add rollback logic for optimistic UI updates in `ToggleSaveJob` so that the UI reverts if the repository call fails.


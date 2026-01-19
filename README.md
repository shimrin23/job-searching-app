# Job Search App

A comprehensive Flutter job searching application with modern architecture, offline-first capabilities, and production-ready features.

## 🚀 Features

### ✅ Implemented Features

#### **Authentication**
- Sign up with email and password
- Sign in with Firebase Authentication
- Password reset functionality
- Persistent user sessions
- Secure logout

#### **Job Listings**
- Browse real-time job listings
- Infinite scroll pagination
- Pull-to-refresh
- Offline-first architecture with caching
- Search jobs by keywords
- Filter by location, job type, work location
- Save/bookmark favorite jobs

#### **Job Details**
- View comprehensive job information
- Company details and logo
- Responsibilities, requirements, and benefits
- Required skills tags
- Apply directly through external links
- Share job listings

#### **User Profile**
- View and edit profile information
- Upload profile picture
- Upload and manage resume
- Track applied jobs
- View saved jobs

#### **Architecture & Best Practices**
- **Clean Architecture** with separation of concerns
- **Dependency Injection** using get_it
- **State Management** with flutter_bloc
- **Offline-First** with Hive local storage
- **Repository Pattern** for data abstraction
- **Error Handling** with custom failures and exceptions
- **Network Awareness** with connectivity checks

## 📁 Project Structure

```
lib/
├── core/                          # Core utilities and configurations
│   ├── constants/                 # App constants
│   ├── di/                        # Dependency injection setup
│   ├── error/                     # Error handling (failures & exceptions)
│   ├── network/                   # Network connectivity
│   └── utils/                     # Utility functions
├── data/                          # Data layer
│   ├── datasources/
│   │   ├── local/                 # Hive local data sources
│   │   └── remote/                # API & Firebase data sources
│   ├── models/                    # Data models with JSON serialization
│   └── repositories/              # Repository implementations
├── domain/                        # Domain layer
│   ├── entities/                  # Business entities
│   └── repositories/              # Repository interfaces
├── logic/                         # Business logic (BLoC)
│   ├── auth/                      # Authentication BLoC
│   ├── job/                       # Job listing BLoC
│   ├── saved_jobs/                # Saved jobs BLoC
│   └── profile/                   # Profile BLoC
└── presentation/                  # UI layer
    ├── screens/                   # App screens
    ├── theme/                     # App theming
    └── widgets/                   # Reusable widgets
```

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (>= 3.9.2)
- Dart SDK
- Firebase account
- Android Studio / Xcode (for mobile development)

### Installation

1. **Clone the repository**
   ```bash
   cd job_searching_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Follow instructions in `FIREBASE_SETUP.md`
   - Download and place Firebase configuration files
   - Enable Firebase Authentication, Firestore, and Storage

4. **Generate code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### API Configuration
Update the API base URL in `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'YOUR_API_URL';
```

### Firebase Setup
1. Create a Firebase project
2. Add Android/iOS apps
3. Download config files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
4. Enable Authentication (Email/Password)
5. Create Firestore database
6. Enable Cloud Storage

## 📦 Key Dependencies

- **flutter_bloc** (^8.1.6) - State management
- **get_it** (^8.0.2) - Dependency injection
- **firebase_core** & **firebase_auth** - Authentication
- **cloud_firestore** - Cloud database
- **dio** (^5.7.0) - HTTP client
- **hive** (^2.2.3) - Local storage
- **dartz** (^0.10.1) - Functional programming
- **cached_network_image** (^3.4.1) - Image caching
- **connectivity_plus** (^6.1.1) - Network status

## 🏗️ Architecture

This app follows **Clean Architecture** principles:

### Layers
1. **Presentation Layer** - UI components and state management
2. **Domain Layer** - Business logic and entities
3. **Data Layer** - Data sources and repositories

### Key Patterns
- **Repository Pattern** - Abstract data sources
- **BLoC Pattern** - Reactive state management
- **Dependency Injection** - Loose coupling
- **Offline-First** - Cache-first data strategy

## 🎨 Features Breakdown

### Phase 1: Architecture Setup ✅
- Dependency injection with get_it
- Clean architecture folder structure
- Error handling framework
- Network connectivity management

### Phase 2: Authentication ✅
- Firebase Auth integration
- Sign in/Sign up flows
- Password reset
- Auth state management
- Secure session handling

### Phase 3: Data Layer ✅
- Offline-first repository pattern
- Hive local caching
- API integration with Dio
- Pagination support
- Network-aware data fetching

### Phase 4: Business Logic ✅
- Job listing with pagination
- Search and filters
- Save/unsave jobs
- Apply to jobs tracking
- Profile management

### Phase 5: UI Layer ✅
- Responsive design
- Loading states
- Error handling
- Pull-to-refresh
- Infinite scroll
- Bottom navigation

### Phase 6: Advanced Features (Planned)
- Deep linking for job sharing
- Push notifications
- Resume upload
- Advanced filters
- Job recommendations

## 🧪 Testing

Run tests:
```bash
flutter test
```

## 📱 Platforms Supported
- ✅ Android
- ✅ iOS
- ⚠️ Web (partial support)
- ⚠️ Windows/Mac/Linux (partial support)

## 🤝 Contributing
This is a learning/portfolio project. Feel free to fork and customize!

## 📄 License
MIT License

---

**Note**: This app is a demonstration project showcasing modern Flutter development practices. Before deploying to production, ensure you:
- Add proper API keys and secrets management
- Implement comprehensive error logging
- Add analytics
- Perform security audits
- Add comprehensive tests
- Configure CI/CD pipelines


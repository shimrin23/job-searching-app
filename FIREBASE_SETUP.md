# Firebase Configuration Setup

This project uses Firebase for authentication and backend services. Follow these steps to configure Firebase:

## Android Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing project
3. Add Android app
4. Download `google-services.json`
5. Place it in `android/app/`

## iOS Setup

1. In Firebase Console, add iOS app
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/`

## Web Setup

1. In Firebase Console, add Web app
2. Copy the configuration
3. Update `web/index.html` with Firebase config

## Enable Firebase Services

In Firebase Console, enable:
- Authentication (Email/Password)
- Firestore Database
- Cloud Storage
- Cloud Messaging (for push notifications)

## Update Configuration

After downloading the config files, run:
```bash
flutter pub get
```

Note: The google-services.json and GoogleService-Info.plist files are gitignored for security.

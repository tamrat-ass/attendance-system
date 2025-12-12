# MK Attendance - Flutter Mobile App

A mobile application for the MK Attendance Management System that syncs with your existing web application.

## 🚀 Features

- **Login/Authentication** - Secure login using your web app credentials
- **Mark Attendance** - Mobile-optimized attendance marking with Ethiopian calendar
- **Student Management** - Add, edit, and manage students
- **Reports** - View and export attendance reports
- **Real-time Sync** - Changes sync instantly with your web application
- **Offline Support** - Works offline and syncs when connected

## 📱 Screenshots

[Screenshots will be added after UI implementation]

## 🛠 Setup Instructions

### Prerequisites

1. **Install Flutter**: https://docs.flutter.dev/get-started/install
2. **Install Android Studio** (for Android development)
3. **Enable Developer Options** on your Android device

### Installation Steps

1. **Clone/Download this folder**
   ```bash
   cd mk-attendance-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate model files**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Connect your Android device or start emulator**
   ```bash
   flutter devices
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

The app is pre-configured to connect to your existing web application:

- **API Base URL**: `https://mk-attendance.vercel.app/api`
- **Database**: Uses your existing Neon PostgreSQL database
- **Authentication**: Same login credentials as web app

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart
│   ├── student.dart
│   └── attendance.dart
├── services/                 # API services
│   └── api_service.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── student_provider.dart
│   └── attendance_provider.dart
├── screens/                  # UI screens
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── attendance_screen.dart
│   ├── students_screen.dart
│   └── reports_screen.dart
└── widgets/                  # Reusable widgets
```

## 🔄 Synchronization

The mobile app syncs with your web application in real-time:

- **Same Database**: Both apps use the same Neon PostgreSQL database
- **Same API**: Mobile app calls the same API endpoints as web app
- **Instant Updates**: Changes made on mobile appear immediately on web and vice versa

## 🎯 Usage

1. **Login** with your existing web app credentials
2. **Mark Attendance** for students using the mobile interface
3. **Manage Students** - add, edit, or delete student records
4. **View Reports** - generate and export attendance reports
5. **Sync Data** - all changes sync automatically with the web app

## 🔒 Security

- Secure authentication using your existing login system
- All API calls use HTTPS encryption
- Local data is stored securely on device

## 📱 Supported Platforms

- ✅ Android 5.0+ (API level 21+)
- ✅ iOS 11.0+ (coming soon)

## 🆘 Troubleshooting

### Common Issues

1. **Build errors**: Run `flutter clean && flutter pub get`
2. **API connection issues**: Check your internet connection
3. **Login problems**: Verify credentials work on web app first

### Getting Help

- Check the Flutter documentation: https://docs.flutter.dev
- Report issues in the project repository

## 🔄 Updates

The mobile app will be updated regularly to match new features added to the web application.

## 📄 License

This project is part of the MK Attendance Management System.
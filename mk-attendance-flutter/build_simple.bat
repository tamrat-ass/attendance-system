@echo off
echo ========================================
echo Building Simple Attendance App
echo ========================================

echo.
echo 1. Cleaning previous builds...
flutter clean

echo.
echo 2. Getting dependencies...
flutter pub get

echo.
echo 3. Building APK...
flutter build apk --release

echo.
echo 4. Build complete!
echo APK location: build\app\outputs\flutter-apk\app-release.apk

echo.
echo 5. Copying APK to root folder...
copy "build\app\outputs\flutter-apk\app-release.apk" "..\MK-Attendance-Simple-FIXED.apk"

echo.
echo ========================================
echo ✅ Simple Attendance App Ready!
echo File: MK-Attendance-Simple-FIXED.apk
echo ========================================
pause
@echo off
echo ========================================
echo Building FIXED Mobile App APK
echo ========================================

cd mk-attendance-flutter

echo.
echo 1. Cleaning previous builds...
flutter clean

echo.
echo 2. Getting dependencies...
flutter pub get

echo.
echo 3. Building FIXED APK...
flutter build apk --release

echo.
echo 4. Copying APK to main folder...
copy "build\app\outputs\flutter-apk\app-release.apk" "..\MK-Attendance-SYNC-FIXED.apk"

echo.
echo ========================================
echo ✅ FIXED APK Ready!
echo File: MK-Attendance-SYNC-FIXED.apk
echo ========================================

echo.
echo Install this new APK to fix the sync issue!
pause
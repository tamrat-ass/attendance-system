@echo off
echo Building MK Attendance Flutter App...
echo.

echo Step 1: Cleaning previous builds...
flutter clean

echo Step 2: Getting dependencies...
flutter pub get

echo Step 3: Generating model files...
flutter packages pub run build_runner build --delete-conflicting-outputs

echo Step 4: Building release APK...
flutter build apk --release

echo.
echo Build completed successfully!
echo APK location: build\app\outputs\flutter-apk\app-release.apk
echo.

echo Step 5: Building App Bundle for Play Store...
flutter build appbundle --release

echo.
echo App Bundle location: build\app\outputs\bundle\release\app-release.aab
echo.

echo Build process completed!
echo You can now distribute the APK or upload the App Bundle to Google Play Store.
pause
@echo off
echo ========================================
echo Building MK Attendance APK with Overflow Fixes
echo ========================================

cd mk-attendance-flutter

echo Step 1: Cleaning build...
flutter clean

echo Step 2: Getting dependencies...
flutter pub get

echo Step 3: Building APK (this may take several minutes)...
flutter build apk --release --no-tree-shake-icons

echo Step 4: Checking for APK files...
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ APK built successfully!
    echo Copying APK to target location...
    copy "build\app\outputs\flutter-apk\app-release.apk" "C:\Users\HP\OneDrive\Desktop\224\mk-attendance-overflow-fixed.apk"
    echo ✅ APK copied to: C:\Users\HP\OneDrive\Desktop\224\mk-attendance-overflow-fixed.apk
) else (
    echo ❌ APK build failed or file not found
    echo Checking for other APK files...
    dir "build\app\outputs\flutter-apk\*.apk" /b
)

echo ========================================
echo Build process completed
echo ========================================
pause
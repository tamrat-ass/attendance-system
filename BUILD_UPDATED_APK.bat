@echo off
echo ========================================
echo Building Updated MK Attendance APK
echo With Corrected Ethiopian Date System
echo ========================================
echo.

echo IMPORTANT: Before running this script:
echo 1. Close ALL applications (Android Studio, VS Code, File Explorer)
echo 2. Restart your computer
echo 3. Run this script as Administrator
echo.
pause

cd mk-attendance-flutter

echo Step 1: Force cleaning build directories...
rmdir /s /q build 2>nul
rmdir /s /q .dart_tool 2>nul
rmdir /s /q windows\flutter\ephemeral 2>nul
rmdir /s /q ios\Flutter\ephemeral 2>nul

echo.
echo Step 2: Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo Error: Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo Step 3: Building APK with corrected Ethiopian date...
flutter build apk --release
if %errorlevel% neq 0 (
    echo Error: Build failed - try restarting computer and running as admin
    pause
    exit /b 1
)

echo.
echo ✅ SUCCESS! APK built with corrected Ethiopian date system!
echo.
echo Copying APK to Desktop...
copy "build\app\outputs\flutter-apk\app-release.apk" "C:\Users\HP\OneDrive\Desktop\224\mk-attendance-CORRECTED-ethiopian-date.apk"

echo.
echo ✅ COMPLETED!
echo.
echo New APK location: C:\Users\HP\OneDrive\Desktop\224\mk-attendance-CORRECTED-ethiopian-date.apk
echo This APK contains the corrected Ethiopian date system (23 ታኅሳስ 2018)
echo.
pause
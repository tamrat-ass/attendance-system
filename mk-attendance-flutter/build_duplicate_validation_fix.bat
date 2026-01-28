@echo off
echo ========================================
echo Building MK Attendance APK with Duplicate Validation Fix
echo ========================================

cd /d "%~dp0"

echo.
echo 🔧 Cleaning previous builds...
call flutter clean
if errorlevel 1 (
    echo ❌ Flutter clean failed
    pause
    exit /b 1
)

echo.
echo 📦 Getting dependencies...
call flutter pub get
if errorlevel 1 (
    echo ❌ Flutter pub get failed
    pause
    exit /b 1
)

echo.
echo 🏗️ Building optimized APK with duplicate validation fix...
call flutter build apk --release --target-platform android-arm64 --split-per-abi
if errorlevel 1 (
    echo ❌ Flutter build failed
    pause
    exit /b 1
)

echo.
echo ✅ Build completed successfully!
echo 📱 APK location: build\app\outputs\flutter-apk\app-arm64-v8a-release.apk

echo.
echo 📊 Checking APK size...
for %%I in (build\app\outputs\flutter-apk\app-arm64-v8a-release.apk) do echo APK Size: %%~zI bytes (%%~zI / 1024 / 1024 MB)

echo.
echo 🎯 Duplicate Validation Features:
echo - ✅ Enhanced duplicate detection for names and phone numbers
echo - ✅ Proper error handling for 409 status codes
echo - ✅ Clear error messages for duplicate students
echo - ✅ No retry on validation errors
echo - ✅ Separate validation for name vs phone duplicates

echo.
echo 📋 Installation Instructions:
echo 1. Copy APK to your device
echo 2. Enable "Install from unknown sources" in Settings
echo 3. Install the APK
echo 4. Test duplicate validation with existing student data

pause
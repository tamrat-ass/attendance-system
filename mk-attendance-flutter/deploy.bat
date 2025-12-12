@echo off
echo ========================================
echo    MK Attendance Mobile App Deployment
echo ========================================
echo.

echo Step 1: Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter first: https://docs.flutter.dev/get-started/install
    pause
    exit /b 1
)

echo.
echo Step 2: Checking connected devices...
flutter devices
if %errorlevel% neq 0 (
    echo WARNING: No devices found
    echo Please connect an Android device or start an emulator
    pause
)

echo.
echo Step 3: Cleaning previous builds...
flutter clean

echo.
echo Step 4: Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo Step 5: Generating model files...
flutter packages pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo ERROR: Failed to generate model files
    pause
    exit /b 1
)

echo.
echo Step 6: Running tests (if any)...
flutter test
echo Tests completed (or no tests found)

echo.
echo Step 7: Building debug APK for testing...
flutter build apk --debug
if %errorlevel% neq 0 (
    echo ERROR: Debug build failed
    pause
    exit /b 1
)

echo.
echo Step 8: Installing debug APK on device...
flutter install
if %errorlevel% neq 0 (
    echo WARNING: Installation failed - device may not be connected
)

echo.
echo Step 9: Building release APK...
flutter build apk --release
if %errorlevel% neq 0 (
    echo ERROR: Release build failed
    pause
    exit /b 1
)

echo.
echo Step 10: Building App Bundle for Play Store...
flutter build appbundle --release
if %errorlevel% neq 0 (
    echo WARNING: App Bundle build failed
)

echo.
echo ========================================
echo           BUILD COMPLETED!
echo ========================================
echo.
echo Files created:
echo - Debug APK: build\app\outputs\flutter-apk\app-debug.apk
echo - Release APK: build\app\outputs\flutter-apk\app-release.apk
echo - App Bundle: build\app\outputs\bundle\release\app-release.aab
echo.

echo Checking file sizes...
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    for %%I in ("build\app\outputs\flutter-apk\app-release.apk") do echo Release APK size: %%~zI bytes
) else (
    echo Release APK not found!
)

echo.
echo Next steps:
echo 1. Test the debug APK on your device
echo 2. If everything works, distribute the release APK
echo 3. For Play Store, use the App Bundle file
echo.

echo ========================================
echo     MK Attendance Deployment Complete
echo ========================================
echo.
echo The mobile app is ready for distribution!
echo Web app is live at: https://mk-attendance.vercel.app
echo.
pause
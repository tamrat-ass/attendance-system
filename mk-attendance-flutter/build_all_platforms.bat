@echo off
echo ========================================
echo    MK Attendance - Multi-Platform Build
echo ========================================
echo.

echo Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    pause
    exit /b 1
)

echo.
echo Cleaning previous builds...
flutter clean

echo.
echo Getting dependencies...
flutter pub get

echo.
echo Generating model files...
flutter packages pub run build_runner build --delete-conflicting-outputs

echo.
echo ========================================
echo           ANDROID BUILDS
echo ========================================

echo.
echo Building Android Debug APK...
flutter build apk --debug
if %errorlevel% neq 0 (
    echo ERROR: Android debug build failed
    pause
    exit /b 1
)

echo.
echo Building Android Release APK...
flutter build apk --release
if %errorlevel% neq 0 (
    echo ERROR: Android release build failed
    pause
    exit /b 1
)

echo.
echo Building Android App Bundle...
flutter build appbundle --release
if %errorlevel% neq 0 (
    echo WARNING: Android App Bundle build failed
)

echo.
echo ========================================
echo             iOS BUILDS
echo ========================================

echo.
echo Note: iOS builds require macOS with Xcode installed
echo If you're on Windows, iOS builds will be skipped

where /q xcodebuild
if %errorlevel% equ 0 (
    echo Building iOS Release...
    flutter build ios --release --no-codesign
    if %errorlevel% neq 0 (
        echo WARNING: iOS build failed
    )
) else (
    echo Skipping iOS build - Xcode not found (Windows environment)
)

echo.
echo ========================================
echo           WEB BUILD
echo ========================================

echo.
echo Building Web Application...
flutter build web --release
if %errorlevel% neq 0 (
    echo WARNING: Web build failed
)

echo.
echo ========================================
echo         BUILD SUMMARY
echo ========================================

echo.
echo Android Builds:
if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    for %%I in ("build\app\outputs\flutter-apk\app-debug.apk") do echo - Debug APK: %%~zI bytes
) else (
    echo - Debug APK: FAILED
)

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    for %%I in ("build\app\outputs\flutter-apk\app-release.apk") do echo - Release APK: %%~zI bytes
) else (
    echo - Release APK: FAILED
)

if exist "build\app\outputs\bundle\release\app-release.aab" (
    for %%I in ("build\app\outputs\bundle\release\app-release.aab") do echo - App Bundle: %%~zI bytes
) else (
    echo - App Bundle: FAILED
)

echo.
echo iOS Builds:
if exist "build\ios\iphoneos\Runner.app" (
    echo - iOS App: SUCCESS
) else (
    echo - iOS App: SKIPPED or FAILED
)

echo.
echo Web Build:
if exist "build\web\index.html" (
    echo - Web App: SUCCESS
) else (
    echo - Web App: FAILED
)

echo.
echo ========================================
echo        DEPLOYMENT LOCATIONS
echo ========================================
echo.
echo Android APK (Release): build\app\outputs\flutter-apk\app-release.apk
echo Android Bundle: build\app\outputs\bundle\release\app-release.aab
echo iOS App: build\ios\iphoneos\Runner.app
echo Web App: build\web\
echo.

echo ========================================
echo     MULTI-PLATFORM BUILD COMPLETE
echo ========================================
echo.
echo Your MK Attendance app is now built for:
echo - Android (APK and App Bundle)
echo - iOS (if on macOS with Xcode)
echo - Web (Progressive Web App)
echo.
echo The web app can be deployed to any web server
echo The Android APK can be distributed directly
echo The iOS app requires Xcode for final packaging
echo.
pause
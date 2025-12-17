@echo off
echo Building Optimized MK Attendance APK...
echo.

cd mk-attendance-flutter

echo Step 1: Cleaning previous builds...
flutter clean
if %errorlevel% neq 0 (
    echo Warning: Clean had some issues, continuing...
)

echo.
echo Step 2: Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo Error: Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo Step 3: Building optimized APK...
flutter build apk --release --target-platform android-arm64
if %errorlevel% neq 0 (
    echo Error: Build failed
    pause
    exit /b 1
)

echo.
echo ✅ Build completed successfully!
echo.
echo APK Location: mk-attendance-flutter\build\app\outputs\flutter-apk\app-release.apk
echo.

REM Check APK size
for %%I in ("mk-attendance-flutter\build\app\outputs\flutter-apk\app-release.apk") do (
    set /a size=%%~zI/1024/1024
    echo APK Size: !size! MB
)

echo.
echo To install on device: flutter install
echo.
pause
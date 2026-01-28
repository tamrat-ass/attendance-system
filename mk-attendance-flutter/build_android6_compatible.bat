@echo off
echo Building MK Attendance APK for Android 6+ compatibility...
echo.

REM Clean previous builds
echo Cleaning previous builds...
flutter clean
flutter pub get

REM Generate launcher icons
echo Generating launcher icons...
flutter pub run flutter_launcher_icons

REM Build APK with Android 6+ support
echo Building APK for Android 6.0+ (API 23+)...
flutter build apk --release --target-platform android-arm,android-arm64 --split-per-abi

REM Check if build was successful
if exist "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" (
    echo.
    echo ✅ Build successful! APK files created:
    echo - ARM64: build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
    echo - ARM32: build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk
    echo.
    echo 📱 Compatibility: Android 6.0+ (API 23+)
    echo 🎯 Architectures: ARM64 + ARM32 for maximum device support
    echo.
    
    REM Copy to easy access location
    if not exist "releases" mkdir releases
    copy "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "releases\MK-Attendance-Android6-ARM64.apk"
    copy "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" "releases\MK-Attendance-Android6-ARM32.apk"
    
    echo Files copied to releases folder:
    echo - MK-Attendance-Android6-ARM64.apk (for newer devices)
    echo - MK-Attendance-Android6-ARM32.apk (for older devices)
    echo.
    echo 🚀 Ready for installation on Android 6.0+ devices!
) else (
    echo.
    echo ❌ Build failed! Check the error messages above.
    echo.
    echo Common solutions:
    echo 1. Run: flutter doctor
    echo 2. Check Android SDK installation
    echo 3. Ensure Android SDK 34 is installed
    echo 4. Try: flutter clean && flutter pub get
)

echo.
pause
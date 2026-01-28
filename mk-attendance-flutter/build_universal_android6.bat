@echo off
echo ========================================
echo MK Attendance - Universal Android 6+ Builder
echo ========================================
echo.

REM Set build timestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "timestamp=%YYYY%-%MM%-%DD%_%HH%-%Min%"

echo Build started at: %timestamp%
echo Target: Android 6.0+ to Android 16 (API 23-36)
echo Latest: Android 16 (June 2025) - Cutting Edge Support
echo.

REM Clean and prepare
echo [1/6] Cleaning previous builds...
flutter clean > nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter clean failed
    goto :error
)

echo [2/6] Getting dependencies...
flutter pub get > nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter pub get failed
    goto :error
)

echo [3/6] Generating launcher icons...
flutter pub run flutter_launcher_icons > nul 2>&1

echo [4/6] Building universal APK (ARM64 + ARM32)...
flutter build apk --release --target-platform android-arm,android-arm64
if errorlevel 1 (
    echo ❌ Universal APK build failed
    goto :error
)

echo [5/6] Building split APKs for better compatibility...
flutter build apk --release --target-platform android-arm,android-arm64 --split-per-abi
if errorlevel 1 (
    echo ❌ Split APK build failed
    goto :error
)

echo [6/6] Organizing build outputs...

REM Create releases directory
if not exist "releases\android6-compatible" mkdir "releases\android6-compatible"

REM Copy universal APK
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "releases\android6-compatible\MK-Attendance-Universal-Android6.apk" > nul
    echo ✅ Universal APK: MK-Attendance-Universal-Android6.apk
) else (
    echo ⚠️  Universal APK not found
)

REM Copy split APKs
if exist "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" (
    copy "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "releases\android6-compatible\MK-Attendance-ARM64-Android6.apk" > nul
    echo ✅ ARM64 APK: MK-Attendance-ARM64-Android6.apk
) else (
    echo ⚠️  ARM64 APK not found
)

if exist "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" (
    copy "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" "releases\android6-compatible\MK-Attendance-ARM32-Android6.apk" > nul
    echo ✅ ARM32 APK: MK-Attendance-ARM32-Android6.apk
) else (
    echo ⚠️  ARM32 APK not found
)

echo.
echo ========================================
echo 🎉 BUILD SUCCESSFUL!
echo ========================================
echo.
echo 📱 Compatibility: Android 6.0 to Android 16 (API 23-36)
echo 🚀 Latest Support: Android 16 (June 2025)
echo 📁 Location: releases\android6-compatible\
echo.
echo 📦 Available APKs:
echo   1. MK-Attendance-Universal-Android6.apk (Recommended - works on all devices)
echo   2. MK-Attendance-ARM64-Android6.apk (For newer devices, smaller size)
echo   3. MK-Attendance-ARM32-Android6.apk (For older devices)
echo.
echo 💡 Installation Tips:
echo   - Try Universal APK first (works on most devices)
echo   - If installation fails, try ARM64 then ARM32
echo   - Enable "Unknown Sources" in device settings
echo   - Ensure device has Android 6.0 or higher
echo.
echo 📋 File Sizes:
for %%f in ("releases\android6-compatible\*.apk") do (
    echo   %%~nf: %%~zf bytes
)
echo.
echo Build completed at: %timestamp%
goto :end

:error
echo.
echo ❌ BUILD FAILED!
echo.
echo 🔧 Troubleshooting:
echo   1. Run: flutter doctor
echo   2. Check Android SDK installation
echo   3. Ensure you have Android SDK 34
echo   4. Try: flutter clean && flutter pub get
echo   5. Check internet connection
echo.

:end
echo.
pause
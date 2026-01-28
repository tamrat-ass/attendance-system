@echo off
echo ========================================
echo MK Attendance - Build and Install
echo ========================================
echo.

echo [1/7] Stopping any running processes...
taskkill /f /im "gradle*" >nul 2>&1
taskkill /f /im "java*" >nul 2>&1
timeout /t 2 >nul

echo [2/7] Cleaning build directory...
flutter clean >nul 2>&1
if exist "build" (
    rmdir /s /q "build" >nul 2>&1
    timeout /t 1 >nul
)

echo [3/7] Getting dependencies...
flutter pub get >nul 2>&1
if errorlevel 1 (
    echo ❌ Failed to get dependencies
    pause
    exit /b 1
)

echo [4/7] Generating launcher icons...
flutter pub run flutter_launcher_icons >nul 2>&1

echo [5/7] Building APK (ARM64 - most compatible)...
flutter build apk --release --target-platform android-arm64
if errorlevel 1 (
    echo ❌ Build failed! Trying universal build...
    echo [5b/7] Building universal APK...
    flutter build apk --release
    if errorlevel 1 (
        echo ❌ Universal build also failed
        echo.
        echo 🔧 Troubleshooting:
        echo 1. Check if Android Studio is running and close it
        echo 2. Restart your computer
        echo 3. Run: flutter doctor
        echo 4. Check Android SDK installation
        pause
        exit /b 1
    )
)

echo [6/7] Checking for APK file...
if exist "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" (
    set "APK_FILE=build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
    set "APK_NAME=MK-Attendance-ARM64.apk"
) else if exist "build\app\outputs\flutter-apk\app-release.apk" (
    set "APK_FILE=build\app\outputs\flutter-apk\app-release.apk"
    set "APK_NAME=MK-Attendance-Universal.apk"
) else (
    echo ❌ No APK file found!
    pause
    exit /b 1
)

echo [7/7] Installing to device...
echo.
echo 📱 APK built successfully: %APK_NAME%
echo 📁 Location: %APK_FILE%
echo.

REM Check if ADB is available
adb version >nul 2>&1
if errorlevel 1 (
    echo ⚠️  ADB not found. Manual installation required.
    echo.
    echo 📋 Manual Installation Steps:
    echo 1. Copy APK to your device: %APK_FILE%
    echo 2. Enable "Unknown Sources" in device settings
    echo 3. Open file manager on device
    echo 4. Navigate to the APK file
    echo 5. Tap to install
    echo.
    echo 💡 Or connect device via USB and run: adb install "%APK_FILE%"
    goto :end
)

REM Check if device is connected
adb devices | find "device" >nul
if errorlevel 1 (
    echo ⚠️  No device connected via USB.
    echo.
    echo 📋 Options:
    echo 1. Connect your device via USB cable
    echo 2. Enable USB debugging in Developer Options
    echo 3. Or manually copy APK: %APK_FILE%
    goto :end
)

echo 🔌 Device detected! Installing APK...
adb install -r "%APK_FILE%"
if errorlevel 1 (
    echo ❌ Installation failed via ADB
    echo.
    echo 📋 Try manual installation:
    echo 1. Copy APK to device: %APK_FILE%
    echo 2. Enable "Unknown Sources" in settings
    echo 3. Install via file manager
) else (
    echo ✅ Installation successful!
    echo.
    echo 🎉 MK Attendance is now installed on your device!
    echo 📱 Look for "MK Attendance" app icon
)

:end
echo.
echo 📊 Build Summary:
echo - APK File: %APK_NAME%
echo - Size: 
for %%f in ("%APK_FILE%") do echo   %%~zf bytes
echo - Compatibility: Android 6.0+
echo - Architecture: ARM64 (most devices)
echo.
pause
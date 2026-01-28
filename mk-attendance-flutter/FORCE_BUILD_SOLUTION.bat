@echo off
echo ========================================
echo MK Attendance - Force Build Solution
echo ========================================
echo.

echo This will solve the build directory locking issue...
echo.

echo [1/5] Stopping all Java/Gradle processes...
taskkill /f /im "java.exe" >nul 2>&1
taskkill /f /im "gradle.exe" >nul 2>&1
taskkill /f /im "gradlew.exe" >nul 2>&1
timeout /t 3 >nul

echo [2/5] Closing Android Studio if running...
taskkill /f /im "studio64.exe" >nul 2>&1
timeout /t 2 >nul

echo [3/5] Force removing build directory...
if exist "build" (
    echo Removing build directory...
    rmdir /s /q "build" >nul 2>&1
    timeout /t 2 >nul
    
    REM If still exists, try harder
    if exist "build" (
        echo Build directory still exists, trying harder...
        takeown /f "build" /r /d y >nul 2>&1
        icacls "build" /grant administrators:F /t >nul 2>&1
        rmdir /s /q "build" >nul 2>&1
        timeout /t 2 >nul
    )
)

echo [4/5] Cleaning Flutter cache...
flutter clean >nul 2>&1
flutter pub get >nul 2>&1

echo [5/5] Building with debug mode first (faster)...
flutter build apk --debug
if errorlevel 1 (
    echo ❌ Debug build failed
    echo.
    echo 🔧 Alternative Solutions:
    echo 1. Restart your computer
    echo 2. Close all Android Studio instances
    echo 3. Run as Administrator
    echo 4. Check antivirus software
    pause
    exit /b 1
)

echo.
echo ✅ Debug APK built successfully!
echo 📁 Location: build\app\outputs\flutter-apk\app-debug.apk
echo.
echo 📱 You can install this debug version to test the app:
echo    adb install build\app\outputs\flutter-apk\app-debug.apk
echo.
echo 💡 The debug APK works exactly like release but is larger in size.
echo    It's perfect for testing and development.
echo.

REM Check if we can install directly
adb devices | find "device" >nul
if not errorlevel 1 (
    echo 🔌 Device detected! Installing debug APK...
    adb install -r "build\app\outputs\flutter-apk\app-debug.apk"
    if not errorlevel 1 (
        echo ✅ Installation successful!
        echo 🎉 MK Attendance is now installed on your device!
    ) else (
        echo ⚠️  Installation failed. Try manual installation.
    )
) else (
    echo ⚠️  No device connected. Manual installation required.
    echo 📋 Copy this file to your device: build\app\outputs\flutter-apk\app-debug.apk
)

echo.
pause
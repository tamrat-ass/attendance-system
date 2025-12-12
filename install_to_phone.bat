@echo off
echo ========================================
echo   MK Attendance - Phone Install Script
echo ========================================
echo.

echo Step 1: Checking device connection...
adb devices
if %errorlevel% neq 0 (
    echo ERROR: ADB not found or device not connected
    echo Please ensure:
    echo 1. USB debugging is enabled on phone
    echo 2. Phone is connected via USB
    echo 3. ADB is installed
    pause
    exit /b 1
)

echo.
echo Step 2: Building Flutter app...
cd mk-attendance-flutter
call flutter clean
call flutter pub get
call flutter build apk --release
if %errorlevel% neq 0 (
    echo ERROR: Flutter build failed
    pause
    exit /b 1
)
cd ..

echo.
echo Step 3: Copying APK...
copy "mk-attendance-flutter\build\app\outputs\flutter-apk\app-release.apk" "MK-Attendance-App-LATEST.apk"
if %errorlevel% neq 0 (
    echo ERROR: Failed to copy APK
    pause
    exit /b 1
)

echo.
echo Step 4: Pushing APK to phone...
adb push "MK-Attendance-App-LATEST.apk" /data/local/tmp/
if %errorlevel% neq 0 (
    echo ERROR: Failed to push APK to phone
    pause
    exit /b 1
)

echo.
echo Step 5: Installing app on phone...
adb shell pm install -r /data/local/tmp/MK-Attendance-App-LATEST.apk
if %errorlevel% neq 0 (
    echo ERROR: Installation failed
    pause
    exit /b 1
)

echo.
echo Step 6: Launching app...
adb shell am start -n com.mkattendance.mk_attendance/.MainActivity

echo.
echo Step 7: Cleaning up...
adb shell rm /data/local/tmp/MK-Attendance-App-LATEST.apk

echo.
echo ========================================
echo   ✅ Installation Complete!
echo ========================================
echo.
echo The MK Attendance app should now be:
echo ✅ Installed on your phone
echo ✅ Launching automatically
echo ✅ Available in your app drawer
echo.
echo Features included:
echo • Blue color theme
echo • Fixed dashboard buttons
echo • "All Classes" filter in reports
echo • Correct Ethiopian date display
echo • Working change password
echo • Admin-only data management
echo.
pause
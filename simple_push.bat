@echo off
echo ========================================
echo   MK Attendance - Simple Push Script
echo ========================================

echo Step 1: Checking device connection...
adb devices

echo Step 2: Building APK...
cd mk-attendance-flutter
call flutter build apk --release
cd ..

echo Step 3: Copying APK...
copy "mk-attendance-flutter\build\app\outputs\flutter-apk\app-release.apk" "MK-Attendance-App.apk"

echo Step 4: Installing directly to phone...
adb push "MK-Attendance-App.apk" /data/local/tmp/
adb shell pm install -r /data/local/tmp/MK-Attendance-App.apk
adb shell am start -n com.mkattendance.mk_attendance/.MainActivity
adb shell rm /data/local/tmp/MK-Attendance-App.apk

echo ========================================
echo   ✅ App installed and launched!
echo ========================================
echo.
echo The app should now be running on your phone
echo and available in your app drawer as "MK Attendance"
echo.
pause
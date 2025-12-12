@echo off
echo Copying MK Attendance APK to Desktop...
copy "mk-attendance-flutter\build\app\outputs\flutter-apk\app-release.apk" "%USERPROFILE%\Desktop\MK-Attendance-App.apk"
echo.
echo APK copied to your Desktop as "MK-Attendance-App.apk"
echo.
echo Now you can:
echo 1. Copy this file to your phone
echo 2. Enable "Install from unknown sources" on your phone
echo 3. Tap the APK file to install
echo.
pause
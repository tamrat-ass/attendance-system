@echo off
echo ========================================
echo    MK Attendance System - APK Builder
echo         UPDATED VERSION WITH FIXES
echo ========================================
echo.

echo [1/4] Cleaning previous builds...
cd mk-attendance-flutter
call flutter clean
call flutter pub get

echo.
echo [2/4] Building release APK with latest updates...
echo    - Ethiopian calendar sync fixed
echo    - Duplicate validation enhanced  
echo    - Cross-platform sync improved
call flutter build apk --release --split-per-abi

echo.
echo [3/4] Copying APK to root directory...
copy "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "..\MK-Attendance-App-FINAL-UPDATED.apk"
copy "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" "..\MK-Attendance-App-ARM7-UPDATED.apk"
copy "build\app\outputs\flutter-apk\app-x86_64-release.apk" "..\MK-Attendance-App-x64-UPDATED.apk"

cd ..

echo.
echo [4/4] Creating universal APK...
cd mk-attendance-flutter
call flutter build apk --release
copy "build\app\outputs\flutter-apk\app-release.apk" "..\MK-Attendance-App-UNIVERSAL-UPDATED.apk"
cd ..

echo.
echo ✅ Updated APK built successfully!
echo 📱 Files created:
echo    - MK-Attendance-App-UNIVERSAL-UPDATED.apk (Universal - All devices)
echo    - MK-Attendance-App-FINAL-UPDATED.apk (ARM64 - Most modern devices)
echo    - MK-Attendance-App-ARM7-UPDATED.apk (ARM7 - Older devices)  
echo    - MK-Attendance-App-x64-UPDATED.apk (x64 - Emulators/Testing)
echo.
echo 🎯 Latest Features Included:
echo    ✅ Ethiopian calendar synchronization
echo    ✅ Duplicate attendance prevention
echo    ✅ Enhanced error handling
echo    ✅ Real-time web/mobile sync
echo.
echo 🚀 Ready to install on devices!
pause
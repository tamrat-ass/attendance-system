@echo off
color 0A
echo ========================================
echo    MK ATTENDANCE - INSTALL NOW
echo ========================================
echo.

echo 📱 Ready APK Files Available:
echo.
echo 1. MK-Attendance-Simple-Error-Messages.apk (25MB) - RECOMMENDED
echo    ✅ Optimized size, faster installation
echo    ✅ All core features included
echo    ✅ Works on all Android 6-16 devices
echo.
echo 2. APK_INSTALL_PACKAGE\mk-attendance.apk (68MB) - Full Version
echo    ✅ Complete feature set
echo    ✅ All libraries included
echo    ✅ Works on all Android 6-16 devices
echo.

set /p choice="Choose APK (1 or 2, or press Enter for recommended): "

if "%choice%"=="" set choice=1
if "%choice%"=="1" (
    set "APK_FILE=MK-Attendance-Simple-Error-Messages.apk"
    set "APK_NAME=MK Attendance (Optimized - 25MB)"
) else if "%choice%"=="2" (
    set "APK_FILE=APK_INSTALL_PACKAGE\mk-attendance.apk"
    set "APK_NAME=MK Attendance (Full - 68MB)"
) else (
    echo Invalid choice. Using recommended APK...
    set "APK_FILE=MK-Attendance-Simple-Error-Messages.apk"
    set "APK_NAME=MK Attendance (Optimized - 25MB)"
)

echo.
echo ========================================
echo Selected: %APK_NAME%
echo File: %APK_FILE%
echo ========================================
echo.

REM Check if APK exists
if not exist "%APK_FILE%" (
    echo ❌ ERROR: APK file not found!
    echo Expected location: %APK_FILE%
    echo.
    echo Please ensure the APK file exists in the current directory.
    echo Current directory: %CD%
    pause
    exit /b 1
)

echo ✅ APK file found!
for %%f in ("%APK_FILE%") do (
    echo 📊 File size: %%~zf bytes
    echo 📅 Modified: %%~tf
)
echo.

echo ========================================
echo    INSTALLATION INSTRUCTIONS
echo ========================================
echo.
echo 📱 STEP 1: Copy APK to Your Phone
echo --------------------------------
echo Choose ONE method:
echo.
echo Method A - USB Cable (Fastest):
echo   1. Connect your phone to this computer via USB
echo   2. Open your phone's file manager
echo   3. Copy this file: %APK_FILE%
echo   4. Paste it to your phone's Downloads folder
echo.
echo Method B - Cloud Storage (Easiest):
echo   1. Upload %APK_FILE% to Google Drive/Dropbox
echo   2. Download it on your phone from the cloud app
echo.
echo Method C - Email/Messaging:
echo   1. Email the APK file to yourself
echo   2. Download the attachment on your phone
echo.

pause
echo.

echo 📱 STEP 2: Enable Installation from Unknown Sources
echo --------------------------------------------------
echo On your Android phone:
echo.
echo For Android 6-7:
echo   Settings → Security → Enable "Unknown Sources"
echo.
echo For Android 8+:
echo   Settings → Apps → Special Access → Install Unknown Apps
echo   → Select your file manager → Allow from this source
echo.
echo For Android 10+:
echo   Settings → Security → Install Unknown Apps
echo   → Choose app (File Manager/Chrome) → Allow
echo.

pause
echo.

echo 📱 STEP 3: Install the APK
echo ---------------------------
echo On your Android phone:
echo.
echo   1. Open your file manager app
echo   2. Navigate to Downloads folder (or where you saved the APK)
echo   3. Find and tap: %APK_FILE%
echo   4. Tap "Install" when prompted
echo   5. Wait for installation to complete
echo   6. Tap "Open" or find "MK Attendance" in your app drawer
echo.

pause
echo.

echo 📱 STEP 4: First-Time Setup
echo ----------------------------
echo When you first open MK Attendance:
echo.
echo   1. Grant Camera permission (for QR code scanning)
echo   2. Grant Storage permission (for saving reports)
echo   3. Configure server URL if needed
echo   4. Login with your credentials
echo.

echo ========================================
echo    TROUBLESHOOTING
echo ========================================
echo.
echo ❌ "App not installed" error:
echo   → Try the other APK file (different size)
echo   → Check available storage (need 100MB+ free)
echo   → Restart phone and try again
echo.
echo ❌ "Parse error":
echo   → Re-download/re-copy the APK file
echo   → Make sure file wasn't corrupted during transfer
echo.
echo ❌ "Installation blocked":
echo   → Double-check "Unknown Sources" is enabled
echo   → Try installing from a different file manager
echo.

echo ========================================
echo    DEVICE REQUIREMENTS
echo ========================================
echo.
echo ✅ Android 6.0 or higher (your device must be from 2015+)
echo ✅ 2GB RAM minimum (4GB recommended)
echo ✅ 100MB free storage space
echo ✅ Camera (for QR code scanning)
echo ✅ Internet connection (for syncing data)
echo.

echo ========================================
echo    INSTALLATION COMPLETE!
echo ========================================
echo.
echo After successful installation:
echo.
echo 🎉 Look for "MK Attendance" app icon
echo 📱 Open the app and complete setup
echo 🔧 Grant required permissions
echo 🚀 Start using the attendance system!
echo.
echo Need help? Check the installation guides:
echo - SIMPLE_DEVICE_INSTALL.md
echo - DEVICE_INSTALLATION_GUIDE.md
echo - ANDROID_COMPATIBILITY_VERIFICATION.md
echo.

pause
echo.
echo Thank you for using MK Attendance! 🎉
pause
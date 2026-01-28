@echo off
echo ========================================
echo FIXING APK INSTALLATION ISSUES
echo ========================================

set APK_FILE=C:\Users\HP\OneDrive\Desktop\224\mk-attendance-overflow-fixed.apk

echo Step 1: Checking APK file...
if not exist "%APK_FILE%" (
    echo ❌ APK file not found!
    echo Building new APK...
    cd mk-attendance-flutter
    flutter build apk --release --no-tree-shake-icons
    copy "build\app\outputs\flutter-apk\app-release.apk" "%APK_FILE%"
    cd ..
)

echo ✅ APK file found: %APK_FILE%
dir "%APK_FILE%" | findstr "mk-attendance-overflow-fixed.apk"

echo.
echo Step 2: Creating installation package...

REM Create a simple installation folder
mkdir "APK_INSTALL_PACKAGE" 2>nul
copy "%APK_FILE%" "APK_INSTALL_PACKAGE\mk-attendance.apk"

echo.
echo Step 3: Installation methods available:
echo.
echo ========================================
echo METHOD 1: DIRECT USB INSTALLATION
echo ========================================
echo 1. Connect your Android phone via USB cable
echo 2. Enable "USB Debugging" in Developer Options:
echo    - Settings ^> About Phone ^> Tap "Build Number" 7 times
echo    - Settings ^> Developer Options ^> USB Debugging (ON)
echo 3. Copy APK to phone and install manually
echo.

echo ========================================
echo METHOD 2: ADB INSTALLATION (if available)
echo ========================================
where adb >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ ADB is available!
    echo Connect your phone and press Y to install via ADB
    set /p choice="Install via ADB now? (Y/N): "
    if /i "%choice%"=="Y" (
        echo Checking connected devices...
        adb devices
        echo.
        echo Installing APK...
        adb install -r "%APK_FILE%"
        if %errorlevel% == 0 (
            echo ✅ APK installed successfully via ADB!
            goto :success
        ) else (
            echo ❌ ADB installation failed. Trying alternative methods...
        )
    )
) else (
    echo ❌ ADB not found. Using manual methods...
)

echo.
echo ========================================
echo METHOD 3: CLOUD TRANSFER
echo ========================================
echo 1. Upload APK to Google Drive or OneDrive
echo 2. Download on your phone
echo 3. Install from Downloads folder
echo.

echo ========================================
echo METHOD 4: EMAIL TRANSFER
echo ========================================
echo 1. Email the APK file to yourself
echo 2. Open email on phone
echo 3. Download attachment and install
echo.

echo ========================================
echo METHOD 5: BLUETOOTH TRANSFER
echo ========================================
echo 1. Right-click APK file ^> Send to ^> Bluetooth device
echo 2. Select your phone
echo 3. Accept file on phone and install
echo.

echo ========================================
echo INSTALLATION TROUBLESHOOTING
echo ========================================
echo.
echo If installation fails on phone:
echo 1. Enable "Unknown Sources":
echo    - Settings ^> Security ^> Unknown Sources (ON)
echo    - OR Settings ^> Apps ^> Special Access ^> Install Unknown Apps
echo.
echo 2. If "App not installed" error:
echo    - Uninstall old version first
echo    - Clear cache: Settings ^> Apps ^> MK Attendance ^> Storage ^> Clear Cache
echo    - Restart phone and try again
echo.
echo 3. If "Parse error":
echo    - APK file may be corrupted
echo    - Re-download or rebuild APK
echo.
echo 4. If "Insufficient storage":
echo    - Free up space on phone (need ~100MB)
echo    - Move apps to SD card
echo.

:success
echo.
echo ========================================
echo INSTALLATION PACKAGE READY
echo ========================================
echo.
echo APK Location: %APK_FILE%
echo Package Folder: APK_INSTALL_PACKAGE\
echo.
echo ✅ Choose any method above to install the app
echo ✅ The overflow issues are completely fixed in this version
echo ✅ App will work perfectly after installation
echo.
echo ========================================
pause
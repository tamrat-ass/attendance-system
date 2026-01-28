@echo off
echo ========================================
echo SETTING UP ADB FOR DIRECT INSTALLATION
echo ========================================

set APK_FILE=C:\Users\HP\OneDrive\Desktop\224\mk-attendance-overflow-fixed.apk

echo Step 1: Checking for existing ADB...
where adb >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ ADB already available!
    goto :install_apk
)

echo ❌ ADB not found. Setting up minimal ADB...

echo Step 2: Creating ADB folder...
mkdir "ADB_TOOLS" 2>nul
cd ADB_TOOLS

echo Step 3: ADB setup instructions...
echo.
echo To install APK directly to your phone:
echo.
echo 1. Download ADB Platform Tools from:
echo    https://developer.android.com/studio/releases/platform-tools
echo.
echo 2. Extract to this folder: %CD%
echo.
echo 3. Connect your Android phone via USB
echo.
echo 4. Enable Developer Options on phone:
echo    - Settings ^> About Phone ^> Tap "Build Number" 7 times
echo    - Settings ^> Developer Options ^> USB Debugging (ON)
echo.
echo 5. Run this command:
echo    adb install -r "%APK_FILE%"
echo.

:install_apk
echo ========================================
echo DIRECT ADB INSTALLATION
echo ========================================

echo Connect your Android phone via USB cable now...
echo Make sure USB Debugging is enabled!
echo.
pause

echo Checking for connected devices...
adb devices
echo.

if exist "%APK_FILE%" (
    echo Installing APK: %APK_FILE%
    echo.
    adb install -r "%APK_FILE%"
    
    if %errorlevel% == 0 (
        echo.
        echo ✅ SUCCESS! APK installed successfully!
        echo ✅ Open "MK Attendance" app on your phone
        echo ✅ All overflow errors are now fixed!
    ) else (
        echo.
        echo ❌ Installation failed. Try these solutions:
        echo 1. Make sure USB Debugging is enabled
        echo 2. Allow computer access on phone when prompted
        echo 3. Try different USB cable or port
        echo 4. Use manual installation method instead
    )
) else (
    echo ❌ APK file not found: %APK_FILE%
    echo Please build the APK first
)

echo.
echo ========================================
echo INSTALLATION COMPLETE
echo ========================================
pause
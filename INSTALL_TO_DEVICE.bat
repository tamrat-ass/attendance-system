@echo off
echo ========================================
echo Installing MK Attendance APK to Device
echo ========================================

set APK_FILE=C:\Users\HP\OneDrive\Desktop\224\mk-attendance-overflow-fixed.apk

echo Checking if APK exists...
if not exist "%APK_FILE%" (
    echo ❌ APK file not found at: %APK_FILE%
    echo Please build the APK first using build_overflow_fix_apk.bat
    pause
    exit /b 1
)

echo ✅ APK found: %APK_FILE%
echo Size: 
dir "%APK_FILE%" | findstr "mk-attendance-overflow-fixed.apk"

echo.
echo ========================================
echo INSTALLATION OPTIONS
echo ========================================
echo.
echo 1. USB CABLE METHOD (Recommended):
echo    - Connect your Android phone via USB
echo    - Enable USB Debugging in Developer Options
echo    - Copy APK to phone and install manually
echo.
echo 2. CLOUD TRANSFER METHOD:
echo    - Upload APK to Google Drive/OneDrive
echo    - Download on phone and install
echo.
echo 3. BLUETOOTH METHOD:
echo    - Send APK via Bluetooth to phone
echo    - Accept file and install
echo.

echo Attempting to find ADB for direct installation...
where adb >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ ADB found! Checking for connected devices...
    adb devices
    echo.
    echo If your device is listed above, press Y to install directly
    set /p choice="Install directly via ADB? (Y/N): "
    if /i "%choice%"=="Y" (
        echo Installing APK...
        adb install -r "%APK_FILE%"
        if %errorlevel% == 0 (
            echo ✅ APK installed successfully!
        ) else (
            echo ❌ Installation failed. Try manual method.
        )
    )
) else (
    echo ❌ ADB not found. Please use manual installation method.
    echo.
    echo MANUAL INSTALLATION STEPS:
    echo 1. Copy this file to your phone: %APK_FILE%
    echo 2. On your phone, go to Settings ^> Security ^> Unknown Sources (Enable)
    echo 3. Open File Manager and find the APK file
    echo 4. Tap the APK and select "Install"
    echo 5. Open "MK Attendance" app and test the overflow fixes
)

echo.
echo ========================================
echo WHAT'S FIXED IN THIS VERSION:
echo ✅ NO MORE OVERFLOW ERRORS
echo ✅ NO MORE YELLOW STRIPES  
echo ✅ PROFESSIONAL UI
echo ✅ RESPONSIVE DESIGN
echo ========================================
pause
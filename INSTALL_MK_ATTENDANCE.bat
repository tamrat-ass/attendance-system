@echo off
echo ========================================
echo MK Attendance - Device Installation
echo ========================================
echo.

echo Available APK files:
echo 1. MK-Attendance-Simple-Error-Messages.apk (25MB) - Recommended
echo 2. APK_INSTALL_PACKAGE\mk-attendance.apk (68MB) - Full version
echo.

set /p choice="Choose APK to install (1 or 2): "

if "%choice%"=="1" (
    set "APK_FILE=MK-Attendance-Simple-Error-Messages.apk"
    set "APK_NAME=MK Attendance (Optimized)"
) else if "%choice%"=="2" (
    set "APK_FILE=APK_INSTALL_PACKAGE\mk-attendance.apk"
    set "APK_NAME=MK Attendance (Full)"
) else (
    echo Invalid choice. Using recommended APK...
    set "APK_FILE=MK-Attendance-Simple-Error-Messages.apk"
    set "APK_NAME=MK Attendance (Optimized)"
)

echo.
echo Selected: %APK_NAME%
echo File: %APK_FILE%
echo.

REM Check if APK exists
if not exist "%APK_FILE%" (
    echo ❌ APK file not found: %APK_FILE%
    echo Please ensure the file exists in the current directory.
    pause
    exit /b 1
)

echo 📱 APK Details:
for %%f in ("%APK_FILE%") do (
    echo - Size: %%~zf bytes (%%~zf bytes = ~%%~zf MB)
    echo - Modified: %%~tf
)
echo.

REM Check if ADB is available
echo [1/3] Checking ADB connection...
adb version >nul 2>&1
if errorlevel 1 (
    echo ⚠️  ADB not found in PATH
    goto :manual_install
)

echo ✅ ADB found
echo.

echo [2/3] Checking for connected devices...
adb devices > temp_devices.txt
findstr "device" temp_devices.txt | findstr /v "List" >nul
if errorlevel 1 (
    del temp_devices.txt >nul 2>&1
    echo ⚠️  No devices connected via USB
    goto :manual_install
)

del temp_devices.txt >nul 2>&1
echo ✅ Device connected
echo.

echo [3/3] Installing APK to device...
echo Installing %APK_NAME%...
adb install -r "%APK_FILE%"
if errorlevel 1 (
    echo ❌ Installation failed via ADB
    echo.
    echo Possible reasons:
    echo - USB debugging not enabled
    echo - Device not authorized
    echo - Insufficient storage space
    echo - App signature conflicts
    echo.
    goto :manual_install
) else (
    echo.
    echo ✅ Installation successful!
    echo.
    echo 🎉 MK Attendance is now installed on your device!
    echo 📱 Look for "MK Attendance" app icon on your home screen
    echo.
    echo 🔧 First-time setup:
    echo 1. Open the app
    echo 2. Grant camera permission (for QR scanning)
    echo 3. Grant storage permission (for reports)
    echo 4. Configure server URL if needed
    echo 5. Login with your credentials
    echo.
    goto :end
)

:manual_install
echo.
echo 📋 Manual Installation Required
echo ================================
echo.
echo Since automatic installation failed, please install manually:
echo.
echo 📱 Steps for your Android device:
echo 1. Copy this file to your device: %APK_FILE%
echo    - Use USB cable, Bluetooth, or cloud storage
echo.
echo 2. Enable "Unknown Sources" on your device:
echo    Android 6-7: Settings > Security > Unknown Sources
echo    Android 8+: Settings > Apps > Special Access > Install Unknown Apps
echo.
echo 3. Install the APK:
echo    - Open file manager on your device
echo    - Navigate to the copied APK file
echo    - Tap the APK file
echo    - Tap "Install" when prompted
echo    - Grant permissions when asked
echo.
echo 4. Launch the app:
echo    - Find "MK Attendance" in your app drawer
echo    - Grant camera and storage permissions
echo    - Configure and login
echo.

:end
echo.
echo 📊 Installation Summary:
echo - APK: %APK_NAME%
echo - File: %APK_FILE%
echo - Compatibility: Android 6.0+
echo - Features: QR Scanning, Reports, Offline Support
echo.
echo 📞 Need Help?
echo - Check device compatibility (Android 6.0+)
echo - Ensure sufficient storage space (100MB+)
echo - Enable USB debugging for automatic installation
echo - Contact support if issues persist
echo.
pause
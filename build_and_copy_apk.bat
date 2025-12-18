@echo off
echo ========================================
echo MK Attendance APK Builder
echo ========================================
echo.

REM Step 1: Stop OneDrive to prevent file locking
echo Step 1: Stopping OneDrive sync...
taskkill /F /IM OneDrive.exe >nul 2>&1
timeout /t 3 /nobreak >nul
echo OneDrive stopped.
echo.

REM Step 2: Clean build directory manually
echo Step 2: Cleaning build directory...
cd mk-attendance-flutter
if exist build (
    rmdir /s /q build 2>nul
    timeout /t 2 /nobreak >nul
)
if exist .dart_tool (
    rmdir /s /q .dart_tool 2>nul
    timeout /t 2 /nobreak >nul
)
echo Clean completed.
echo.

REM Step 3: Get dependencies
echo Step 3: Getting Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo Warning: pub get had issues, continuing...
)
echo.

REM Step 4: Build APK
echo Step 4: Building APK (this may take 2-5 minutes)...
flutter build apk --release
if %errorlevel% neq 0 (
    echo.
    echo ❌ Build failed!
    echo.
    echo Restarting OneDrive...
    start "" "%LOCALAPPDATA%\Microsoft\OneDrive\OneDrive.exe"
    pause
    exit /b 1
)
echo.

REM Step 5: Copy APK to destination
echo Step 5: Copying APK to destination...
set DEST_DIR=C:\Users\HP\OneDrive\Desktop\224
set APK_NAME=MK-Attendance-v2.1.apk

if not exist "%DEST_DIR%" (
    mkdir "%DEST_DIR%"
)

copy "build\app\outputs\flutter-apk\app-release.apk" "%DEST_DIR%\%APK_NAME%"
if %errorlevel% equ 0 (
    echo.
    echo ✅ SUCCESS!
    echo.
    echo APK Location: %DEST_DIR%\%APK_NAME%
    echo.
    
    REM Show file size
    for %%I in ("%DEST_DIR%\%APK_NAME%") do (
        set /a size=%%~zI/1024/1024
        echo APK Size: %%~zI bytes (approximately !size! MB)
    )
) else (
    echo ❌ Failed to copy APK
)

cd ..

REM Step 6: Restart OneDrive
echo.
echo Step 6: Restarting OneDrive...
start "" "%LOCALAPPDATA%\Microsoft\OneDrive\OneDrive.exe"
echo OneDrive restarted.

echo.
echo ========================================
echo Build process completed!
echo ========================================
pause

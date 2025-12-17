@echo off
echo ========================================
echo  MK Attendance - OneDrive Build Fix
echo ========================================
echo.

echo Step 1: Stopping OneDrive sync temporarily...
taskkill /f /im OneDrive.exe 2>nul
timeout /t 3 >nul

echo Step 2: Cleaning Flutter project...
cd mk-attendance-flutter

echo Removing build directories manually...
rmdir /s /q build 2>nul
rmdir /s /q .dart_tool 2>nul
rmdir /s /q windows\flutter\ephemeral 2>nul
rmdir /s /q ios\Flutter\ephemeral 2>nul
del .flutter-plugins-dependencies 2>nul

echo Step 3: Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo Warning: pub get had issues, continuing...
)

echo Step 4: Building APK...
flutter build apk --release --no-tree-shake-icons
if %errorlevel% neq 0 (
    echo Build failed, trying alternative method...
    flutter install --device-id=RF8Y40SBM3K
)

echo Step 5: Restarting OneDrive...
start "" "%LOCALAPPDATA%\Microsoft\OneDrive\OneDrive.exe"

echo.
echo ========================================
echo Build process completed!
echo ========================================
pause
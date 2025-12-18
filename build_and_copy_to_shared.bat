@echo off
echo ========================================
echo Building MK Attendance App for Sharing
echo ========================================
echo.

set SHARED_LOCATION=C:\Users\HP\OneDrive\Desktop\224
set TEMP_BUILD_DIR=C:\temp\mk-attendance-build
set APK_NAME=MK-Attendance-App.apk

echo Creating temporary build directory...
if exist "%TEMP_BUILD_DIR%" rmdir /s /q "%TEMP_BUILD_DIR%"
mkdir "%TEMP_BUILD_DIR%"

echo Copying Flutter project to temp directory...
xcopy "mk-attendance-flutter" "%TEMP_BUILD_DIR%" /E /I /H /Y

echo Changing to temp build directory...
cd /d "%TEMP_BUILD_DIR%"

echo Step 1: Cleaning previous builds...
flutter clean

echo Step 2: Getting dependencies...
flutter pub get

echo Step 3: Building release APK...
flutter build apk --release --no-tree-shake-icons

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo.
    echo Build successful! Copying APK to shared location...
    
    if not exist "%SHARED_LOCATION%" mkdir "%SHARED_LOCATION%"
    
    copy "build\app\outputs\flutter-apk\app-release.apk" "%SHARED_LOCATION%\%APK_NAME%"
    
    echo.
    echo ========================================
    echo ✅ SUCCESS!
    echo ========================================
    echo APK copied to: %SHARED_LOCATION%\%APK_NAME%
    
    for %%I in ("%SHARED_LOCATION%\%APK_NAME%") do echo File size: %%~zI bytes
    
) else (
    echo.
    echo ❌ Build failed - APK not found
    echo Check the error messages above
)

echo.
echo Cleaning up temporary directory...
cd /d C:\
rmdir /s /q "%TEMP_BUILD_DIR%"

echo.
echo Build process completed!
pause
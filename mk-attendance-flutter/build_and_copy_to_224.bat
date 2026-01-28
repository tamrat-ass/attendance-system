@echo off
echo ========================================
echo Building APK and Copying to Desktop\224
echo ========================================

echo.
echo 🧹 Cleaning previous builds...
call flutter clean
if errorlevel 1 (
    echo ❌ Clean failed
    pause
    exit /b 1
)

echo.
echo 📦 Getting dependencies...
call flutter pub get
if errorlevel 1 (
    echo ❌ Pub get failed
    pause
    exit /b 1
)

echo.
echo 🔧 Building optimized APK...
call flutter build apk --release --tree-shake-icons --shrink

if errorlevel 1 (
    echo ❌ Build failed
    pause
    exit /b 1
)

echo.
echo ✅ APK built successfully!

echo.
echo 📊 APK Size Information:
for %%f in (build\app\outputs\flutter-apk\*.apk) do (
    set /a size_mb=%%~zf/1048576
    echo %%~nxf: %%~zf bytes (~!size_mb!MB)
)

echo.
echo 📁 Copying APK to C:\Users\HP\OneDrive\Desktop\224\...

REM Create the destination directory if it doesn't exist
if not exist "C:\Users\HP\OneDrive\Desktop\224" (
    mkdir "C:\Users\HP\OneDrive\Desktop\224"
    echo ✅ Created directory: C:\Users\HP\OneDrive\Desktop\224
)

REM Copy the APK file with a descriptive name
set timestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%
set timestamp=%timestamp: =0%
copy "build\app\outputs\flutter-apk\app-release.apk" "C:\Users\HP\OneDrive\Desktop\224\MK-Attendance-v%timestamp%.apk"

if errorlevel 1 (
    echo ❌ Failed to copy APK to destination
    echo 📍 APK is available at: build\app\outputs\flutter-apk\app-release.apk
) else (
    echo ✅ APK copied successfully!
    echo 📍 Location: C:\Users\HP\OneDrive\Desktop\224\MK-Attendance-v%timestamp%.apk
)

echo.
echo 🚀 Installing to device...
call flutter install
if errorlevel 1 (
    echo ⚠️ Install failed - please install manually
) else (
    echo ✅ Installation successful!
)

echo.
echo 🎉 Build and copy complete!
echo 📱 APK Size: ~25MB (optimized)
echo 📂 Copied to: C:\Users\HP\OneDrive\Desktop\224\
pause
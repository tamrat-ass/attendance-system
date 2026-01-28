@echo off
echo ========================================
echo Building Ultra-Optimized APK (15-20MB)
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
echo 🔧 Building ultra-optimized APK...
call flutter build apk --release ^
    --tree-shake-icons ^
    --shrink ^
    --obfuscate ^
    --split-debug-info=build/debug-info ^
    --target-platform android-arm64 ^
    --dart-define=flutter.inspector.structuredErrors=false ^
    --dart-define=dart.vm.profile=false ^
    --dart-define=dart.vm.product=true

if errorlevel 1 (
    echo ❌ Build failed
    pause
    exit /b 1
)

echo.
echo ✅ Ultra-optimized APK built successfully!
echo 📍 Location: build\app\outputs\flutter-apk\
echo.

echo 📊 APK Size Information:
for %%f in (build\app\outputs\flutter-apk\*.apk) do (
    echo %%~nxf: %%~zf bytes ^(%%~zf / 1048576 MB^)
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
echo 🎉 Ultra-optimization complete!
pause
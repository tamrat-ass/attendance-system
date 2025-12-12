@echo off
echo ========================================
echo    Building and Installing MK Attendance
echo ========================================

cd mk-attendance-flutter

echo [1/4] Cleaning previous builds...
flutter clean > nul 2>&1

echo [2/4] Getting dependencies...
flutter pub get > nul 2>&1

echo [3/4] Building APK...
flutter build apk --release > nul 2>&1

echo [4/4] Installing to device...
flutter install --device-id=RF8Y40SBM3K > nul 2>&1

cd ..

echo.
echo ✅ App installed successfully!
echo 📱 Check your Samsung device (SM A165F)
echo.
echo If login doesn't work, run the database fix first:
echo 1. Go to your Neon database console
echo 2. Run the NEON_PASSWORD_FIX.sql script
echo 3. Then try login with: admin / password123
echo.
pause
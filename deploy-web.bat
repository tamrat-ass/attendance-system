@echo off
echo ========================================
echo    MK Attendance System - Web Deployment
echo ========================================
echo.

echo [1/4] Installing dependencies...
call npm install
if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo [2/4] Building the application...
call npm run build
if %errorlevel% neq 0 (
    echo ❌ Build failed
    pause
    exit /b 1
)

echo.
echo [3/4] Running production build test...
call npm run start &
timeout /t 5 /nobreak > nul
taskkill /f /im node.exe > nul 2>&1

echo.
echo [4/4] Deploying to Vercel...
call vercel --prod
if %errorlevel% neq 0 (
    echo ❌ Deployment failed
    pause
    exit /b 1
)

echo.
echo ✅ Web app deployed successfully!
echo 🌐 Your attendance system is now live
echo.
pause
@echo off
echo ========================================
echo    Deploying Login API Fix to Vercel
echo ========================================

echo [1/3] Adding changes to git...
git add app/api/auth/login/route.ts
git add app/api/auth/change-password/route.ts

echo [2/3] Committing changes...
git commit -m "Fix login API: use password_hash column and remove status check"

echo [3/3] Pushing to trigger Vercel deployment...
git push

echo.
echo ✅ Changes pushed to git!
echo 🚀 Vercel will automatically deploy the changes
echo ⏳ Wait 2-3 minutes for deployment to complete
echo.
echo Then test login with:
echo   Username: admin
echo   Password: password123
echo.
pause
@echo off
echo ========================================
echo   MK Attendance - Auto Install Script
echo ========================================
echo.

echo Step 1: Copying APK to phone storage...
echo Looking for connected phone...

:: Try to copy APK to phone via MTP
for /f "tokens=*" %%i in ('wmic logicaldisk where "drivetype=2" get deviceid /value 2^>nul ^| find "="') do (
    for /f "tokens=2 delims==" %%j in ("%%i") do (
        if exist "%%j\" (
            echo Found removable drive: %%j
            if exist "%%j\Download" (
                copy "MK-Attendance-App.apk" "%%j\Download\" >nul 2>&1
                if !errorlevel! == 0 (
                    echo ✓ APK copied to %%j\Download\
                    echo.
                    echo SUCCESS! APK is now on your phone.
                    echo.
                    echo Next steps on your phone:
                    echo 1. Go to Downloads folder
                    echo 2. Tap MK-Attendance-App.apk
                    echo 3. Allow installation from unknown sources
                    echo 4. Tap Install
                    echo.
                    pause
                    exit /b 0
                )
            )
            if exist "%%j\Downloads" (
                copy "MK-Attendance-App.apk" "%%j\Downloads\" >nul 2>&1
                if !errorlevel! == 0 (
                    echo ✓ APK copied to %%j\Downloads\
                    echo.
                    echo SUCCESS! APK is now on your phone.
                    echo.
                    echo Next steps on your phone:
                    echo 1. Go to Downloads folder
                    echo 2. Tap MK-Attendance-App.apk
                    echo 3. Allow installation from unknown sources
                    echo 4. Tap Install
                    echo.
                    pause
                    exit /b 0
                )
            )
        )
    )
)

echo.
echo Could not automatically copy to phone.
echo Please manually copy MK-Attendance-App.apk to your phone's Downloads folder.
echo.
pause
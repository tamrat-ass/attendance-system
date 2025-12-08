@echo off
echo Choose what to export from XAMPP:
echo.
echo 1. Complete database (structure + data)
echo 2. Students data only
echo 3. Users data only
echo 4. Classes data only
echo 5. All tables data (no structure)
echo.
set /p choice="Enter your choice (1-5): "

REM Change to XAMPP MySQL bin directory
cd /d "C:\xampp\mysql\bin"

REM Create timestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%"
set "datestamp=%YYYY%-%MM%-%DD%_%HH%-%Min%"

echo.
echo You will be prompted for MySQL password (usually just press Enter for XAMPP)
echo.

if "%choice%"=="1" (
    echo Exporting complete database...
    mysqldump -u root -p attendance_system > "%~dp0attendance_system_complete_%datestamp%.sql"
    echo ✅ Complete database exported!
) else if "%choice%"=="2" (
    echo Exporting students table...
    mysqldump -u root -p attendance_system students > "%~dp0students_data_%datestamp%.sql"
    echo ✅ Students data exported!
) else if "%choice%"=="3" (
    echo Exporting users table...
    mysqldump -u root -p attendance_system users > "%~dp0users_data_%datestamp%.sql"
    echo ✅ Users data exported!
) else if "%choice%"=="4" (
    echo Exporting classes table...
    mysqldump -u root -p attendance_system classes > "%~dp0classes_data_%datestamp%.sql"
    echo ✅ Classes data exported!
) else if "%choice%"=="5" (
    echo Exporting all data without structure...
    mysqldump -u root -p --no-create-info attendance_system > "%~dp0attendance_data_only_%datestamp%.sql"
    echo ✅ All data exported!
) else (
    echo ❌ Invalid choice!
    goto end
)

echo.
echo File saved in: %~dp0
echo.

:end
pause
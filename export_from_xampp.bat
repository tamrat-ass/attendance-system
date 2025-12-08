@echo off
echo Exporting attendance_system database from XAMPP...

REM Change to XAMPP MySQL bin directory
cd /d "C:\xampp\mysql\bin"

REM Create timestamp for filename
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%"
set "datestamp=%YYYY%-%MM%-%DD%_%HH%-%Min%"

echo.
echo Exporting database to your project folder...
echo You will be prompted for MySQL password (usually empty for XAMPP)
echo.

REM Export to your project directory
mysqldump -u root -p attendance_system > "%~dp0attendance_system_backup_%datestamp%.sql"

echo.
echo ✅ Database exported successfully!
echo File saved as: attendance_system_backup_%datestamp%.sql
echo Location: %~dp0
echo.
pause
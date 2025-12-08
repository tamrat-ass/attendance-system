@echo off
echo Exporting attendance_system database...

REM Set the current date and time for filename
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"

REM Export database with structure and data
mysqldump -u root -p --databases attendance_system > "attendance_system_backup_%datestamp%.sql"

echo Database exported to: attendance_system_backup_%datestamp%.sql
echo.
echo To restore this backup later, use:
echo mysql -u root -p < attendance_system_backup_%datestamp%.sql
pause
@echo off
echo Exporting attendance_system database data only...

REM Set the current date and time for filename
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"

REM Export only data (no CREATE TABLE statements)
mysqldump -u root -p --no-create-info --databases attendance_system > "attendance_system_data_%datestamp%.sql"

echo Data exported to: attendance_system_data_%datestamp%.sql
pause
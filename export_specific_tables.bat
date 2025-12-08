@echo off
echo Exporting specific tables from attendance_system database...

REM Set the current date and time for filename
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"

echo Choose what to export:
echo 1. Students only
echo 2. Users only  
echo 3. Classes only
echo 4. All main tables (students, users, classes)
echo 5. Everything
set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" (
    mysqldump -u root -p attendance_system students > "students_backup_%datestamp%.sql"
    echo Students exported to: students_backup_%datestamp%.sql
) else if "%choice%"=="2" (
    mysqldump -u root -p attendance_system users > "users_backup_%datestamp%.sql"
    echo Users exported to: users_backup_%datestamp%.sql
) else if "%choice%"=="3" (
    mysqldump -u root -p attendance_system classes > "classes_backup_%datestamp%.sql"
    echo Classes exported to: classes_backup_%datestamp%.sql
) else if "%choice%"=="4" (
    mysqldump -u root -p attendance_system students users classes > "main_tables_backup_%datestamp%.sql"
    echo Main tables exported to: main_tables_backup_%datestamp%.sql
) else if "%choice%"=="5" (
    mysqldump -u root -p --databases attendance_system > "full_backup_%datestamp%.sql"
    echo Full database exported to: full_backup_%datestamp%.sql
) else (
    echo Invalid choice!
)

pause
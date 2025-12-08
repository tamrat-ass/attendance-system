@echo off
echo Cleaning MySQL data directory...

REM Navigate to MySQL data directory
cd /d C:\xampp\mysql\data

REM Remove the attendance_system folder completely
if exist "attendance_system" (
    echo Removing attendance_system folder...
    rmdir /s /q "attendance_system"
    echo Folder removed successfully!
) else (
    echo attendance_system folder not found
)

echo.
echo MySQL data cleaned. Now start MySQL in XAMPP and try creating the database again.
pause
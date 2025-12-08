@echo off
echo Attempting to extract data from backup folder...

REM Change this path to where your backup folder is located
set BACKUP_PATH=C:\path\to\your\backup\attendance_system

echo Looking for backup files in: %BACKUP_PATH%
if exist "%BACKUP_PATH%" (
    echo Backup folder found!
    dir "%BACKUP_PATH%"
    
    echo.
    echo To extract data, we need to:
    echo 1. Copy the backup folder to C:\xampp\mysql\data\
    echo 2. Make sure MySQL is stopped
    echo 3. Start MySQL again
    echo.
    echo Or we can try to export the data to SQL format
) else (
    echo Backup folder not found at: %BACKUP_PATH%
    echo Please update the BACKUP_PATH in this script
)

pause
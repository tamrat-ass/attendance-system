@echo off
echo Restoring attendance_system database...
cd /d C:\xampp\mysql\bin
mysql -u root -p < "%~dp0RESTORE_DATABASE.sql"
echo Database restoration complete!
pause
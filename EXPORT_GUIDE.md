# Database Export Guide

## Method 1: Command Line (Recommended)

### Full Database Export
```bash
# Run the export_database.bat file
# Or manually run:
mysqldump -u root -p --databases attendance_system > attendance_system_backup.sql
```

### Data Only Export
```bash
# Run the export_data_only.bat file
# Or manually run:
mysqldump -u root -p --no-create-info --databases attendance_system > attendance_system_data.sql
```

## Method 2: Using phpMyAdmin

1. Open phpMyAdmin in your browser (usually http://localhost/phpmyadmin)
2. Select the `attendance_system` database
3. Click on the "Export" tab
4. Choose export method:
   - **Quick**: Default settings
   - **Custom**: More options
5. Select format (SQL recommended)
6. Click "Go" to download

## Method 3: Using MySQL Workbench

1. Open MySQL Workbench
2. Connect to your database
3. Go to Server → Data Export
4. Select `attendance_system` database
5. Choose tables to export
6. Select "Export to Self-Contained File"
7. Click "Start Export"

## Method 4: Using XAMPP Control Panel

If you're using XAMPP:
1. Open XAMPP Control Panel
2. Click "Admin" next to MySQL
3. This opens phpMyAdmin
4. Follow phpMyAdmin steps above

## What Gets Exported

Your database contains these tables:
- `users` - User accounts and permissions
- `students` - Student information
- `classes` - Class information
- `attendance` - Attendance records (if exists)
- `user_logs` - Activity logs

## File Locations

Exported files will be saved in your current directory with timestamps:
- `attendance_system_backup_YYYY-MM-DD_HH-MM-SS.sql`
- `attendance_system_data_YYYY-MM-DD_HH-MM-SS.sql`

## Restoring Database

To restore from backup:
```bash
mysql -u root -p < attendance_system_backup.sql
```

## Security Note

⚠️ **Important**: Exported SQL files contain sensitive data including:
- User passwords (hashed)
- Personal information
- System configuration

Keep backup files secure and don't share them publicly!
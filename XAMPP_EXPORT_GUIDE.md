# 📥 How to Export Database from XAMPP

## Method 1: phpMyAdmin (Recommended - Easy)

### Step-by-Step:

1. **Start XAMPP**
   - Open XAMPP Control Panel
   - Start Apache and MySQL services

2. **Open phpMyAdmin**
   - Click "Admin" button next to MySQL in XAMPP
   - Or visit: http://localhost/phpmyadmin

3. **Select Database**
   - Click on `attendance_system` in the left sidebar

4. **Export Database**
   - Click the **"Export"** tab at the top
   - Select **"Quick"** export method
   - Format: **SQL**
   - Click **"Go"** button

5. **Download**
   - Your browser will automatically download the `.sql` file
   - File will be named something like `attendance_system.sql`

## Method 2: Command Line (Advanced)

1. **Run the batch file**
   - Double-click `export_from_xampp.bat`
   - Press Enter when prompted for password (XAMPP default has no password)

## Method 3: Custom Export

1. **Run the batch file**
   - Double-click `export_xampp_data.bat`
   - Choose what you want to export (1-5)
   - Press Enter for password

## 📁 File Locations

Your exported files will be saved in your project folder with timestamps:
- `attendance_system_backup_2025-12-07_14-30.sql`
- `students_data_2025-12-07_14-30.sql`
- etc.

## 🔄 To Import Later

To restore your database later:
1. Open phpMyAdmin
2. Create new database (or select existing)
3. Click "Import" tab
4. Choose your `.sql` file
5. Click "Go"

## ⚠️ Notes

- XAMPP default MySQL password is usually empty (just press Enter)
- Make sure XAMPP MySQL service is running
- Exported files contain all your data and structure
- Keep backups in a safe location
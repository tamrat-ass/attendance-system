# Update Database for Attendance Feature

## Step 1: Run this SQL in phpMyAdmin

1. Open **phpMyAdmin** (http://localhost/phpmyadmin)
2. Select your **attendance_system** database
3. Click on **SQL** tab
4. Copy and paste this SQL:

```sql
-- Create attendance table
CREATE TABLE IF NOT EXISTS attendance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  date DATE NOT NULL,
  status ENUM('present', 'absent', 'late', 'permission') NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  UNIQUE KEY unique_attendance (student_id, date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

5. Click **Go** to execute

## Step 2: Restart your dev server

1. Stop the server (Ctrl+C)
2. Run: `npm run dev`
3. Refresh your browser

## Done!

Now when you mark attendance and click "Save Attendance", it will be saved to the database and appear in the Reports tab!

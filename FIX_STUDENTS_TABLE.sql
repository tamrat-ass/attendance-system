-- First, check current students table structure
DESCRIBE students;

-- Check if there are any issues with the table
SHOW CREATE TABLE students;

-- Check for any triggers that might delete data
SHOW TRIGGERS WHERE `Table` = 'students';

-- If you need to recreate the table (WARNING: This will delete all data!)
-- Only run this if you're sure you want to start fresh

-- Step 1: Backup your data first
CREATE TABLE students_backup AS SELECT * FROM students;

-- Step 2: Drop and recreate the table
DROP TABLE IF EXISTS attendance;  -- Must drop this first due to foreign key
DROP TABLE IF EXISTS students;

-- Step 3: Recreate students table
CREATE TABLE students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  class VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 4: Recreate attendance table
CREATE TABLE attendance (
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

-- Step 5: Restore your data
INSERT INTO students SELECT * FROM students_backup;

-- Step 6: Verify the data
SELECT COUNT(*) as total_students FROM students;
SELECT * FROM students ORDER BY id DESC LIMIT 10;

-- Step 7: Drop backup table
DROP TABLE students_backup;

-- =====================================================
-- MK ATTENDANCE - MANDATORY EMAIL SETUP
-- Email is now REQUIRED for all student registrations
-- =====================================================

USE attendance_system;

-- =====================================================
-- 1. UPDATE STUDENTS TABLE - MAKE EMAIL MANDATORY
-- =====================================================

-- First, add the columns if they don't exist (with email as nullable temporarily)
ALTER TABLE students 
ADD COLUMN IF NOT EXISTS gender VARCHAR(10) DEFAULT 'Male',
ADD COLUMN IF NOT EXISTS email VARCHAR(255) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS qr_code TEXT DEFAULT NULL;

-- =====================================================
-- 2. HANDLE EXISTING STUDENTS WITHOUT EMAILS
-- =====================================================

-- Check if there are students without emails
SELECT COUNT(*) as students_without_email 
FROM students 
WHERE email IS NULL OR email = '';

-- You have two options for existing students:

-- OPTION A: Delete students without emails (if they're test data)
-- DELETE FROM students WHERE email IS NULL OR email = '';

-- OPTION B: Manually add emails for existing students
-- UPDATE students SET email = 'student1@gmail.com' WHERE id = 1;
-- UPDATE students SET email = 'student2@gmail.com' WHERE id = 2;
-- ... (add real email addresses for each student)

-- =====================================================
-- 3. MAKE EMAIL COLUMN NOT NULL (after handling existing data)
-- =====================================================

-- WARNING: This will fail if any students have NULL or empty emails
-- Make sure all existing students have valid email addresses first

-- ALTER TABLE students 
-- MODIFY COLUMN email VARCHAR(255) NOT NULL;

-- =====================================================
-- 4. ADD CONSTRAINTS AND INDEXES
-- =====================================================

-- Add unique constraint on email (each student must have unique email)
-- ALTER TABLE students ADD CONSTRAINT unique_email UNIQUE (email);

-- Add indexes for performance
ALTER TABLE students 
ADD INDEX IF NOT EXISTS idx_email (email),
ADD INDEX IF NOT EXISTS idx_gender (gender),
ADD INDEX IF NOT EXISTS idx_qr_code (qr_code(255));

-- =====================================================
-- 5. CREATE REQUIRED TABLES
-- =====================================================

-- Email logs table
CREATE TABLE IF NOT EXISTS email_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type ENUM('registration', 'bulk') NOT NULL,
  recipient VARCHAR(255) NOT NULL,
  sender VARCHAR(255) NOT NULL,
  content TEXT,
  status ENUM('success', 'failed') NOT NULL,
  error_message TEXT,
  student_id INT,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE SET NULL,
  INDEX idx_type (type),
  INDEX idx_status (status),
  INDEX idx_timestamp (timestamp),
  INDEX idx_recipient (recipient)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- QR attendance logs table
CREATE TABLE IF NOT EXISTS qr_attendance_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  qr_data TEXT NOT NULL,
  scan_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('success', 'failed', 'duplicate') NOT NULL,
  error_message TEXT,
  scanner_info VARCHAR(255),
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  INDEX idx_student_id (student_id),
  INDEX idx_scan_timestamp (scan_timestamp),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 6. VERIFICATION QUERIES
-- =====================================================

-- Check current table structure
DESCRIBE students;

-- Show students and their email status
SELECT id, full_name, phone, class, gender, email,
       CASE 
         WHEN email IS NULL OR email = '' THEN '❌ No Email'
         WHEN email LIKE '%@gmail.com' THEN '✅ Gmail'
         ELSE '⚠️ Other Domain'
       END as email_status
FROM students;

-- Count email statistics
SELECT 
  COUNT(*) as total_students,
  COUNT(CASE WHEN email IS NOT NULL AND email != '' THEN 1 END) as with_email,
  COUNT(CASE WHEN email IS NULL OR email = '' THEN 1 END) as without_email,
  COUNT(CASE WHEN email LIKE '%@gmail.com' THEN 1 END) as gmail_addresses
FROM students;

-- =====================================================
-- 7. INSTRUCTIONS FOR COMPLETION
-- =====================================================

/*
TO COMPLETE THE MANDATORY EMAIL SETUP:

1. First, run this script to add columns and create tables

2. Handle existing students without emails:
   - Either delete test students: DELETE FROM students WHERE email IS NULL;
   - Or add real emails: UPDATE students SET email = 'real@gmail.com' WHERE id = X;

3. After all students have emails, run these commands:
   ALTER TABLE students MODIFY COLUMN email VARCHAR(255) NOT NULL;
   ALTER TABLE students ADD CONSTRAINT unique_email UNIQUE (email);

4. Test the system:
   - Try to register a student without email (should fail)
   - Try to register with non-Gmail email (should fail)
   - Register with valid Gmail address (should succeed and send email)
*/

SELECT 'Mandatory email setup prepared!' as Status;
SELECT 'Next: Handle existing students, then make email NOT NULL' as NextStep;
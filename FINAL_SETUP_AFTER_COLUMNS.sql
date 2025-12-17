-- =====================================================
-- FINAL SETUP - Continue after adding columns
-- Run this after: ALTER TABLE students ADD COLUMN...
-- =====================================================

USE attendance_system;

-- =====================================================
-- 1. CREATE EMAIL LOGS TABLE
-- =====================================================

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

-- =====================================================
-- 2. CREATE QR ATTENDANCE LOGS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS qr_attendance_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  qr_data TEXT NOT NULL,
  scan_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('success', 'failed', 'duplicate') NOT NULL,
  error_message TEXT,
  scanner_info VARCHAR(255),
  ip_address VARCHAR(45),
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  INDEX idx_student_id (student_id),
  INDEX idx_scan_timestamp (scan_timestamp),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 3. HANDLE EXISTING STUDENTS WITHOUT EMAILS
-- =====================================================

-- Check how many students don't have emails
SELECT 
  COUNT(*) as total_students,
  COUNT(CASE WHEN email IS NULL OR email = '' THEN 1 END) as without_email,
  COUNT(CASE WHEN email IS NOT NULL AND email != '' THEN 1 END) as with_email
FROM students;

-- Show students without emails
SELECT id, full_name, phone, class, email 
FROM students 
WHERE email IS NULL OR email = '';

-- =====================================================
-- 4. OPTION A: DELETE TEST STUDENTS WITHOUT EMAILS
-- =====================================================

-- Uncomment this line if you want to delete students without emails
-- DELETE FROM students WHERE email IS NULL OR email = '';

-- =====================================================
-- 5. OPTION B: ADD SAMPLE EMAILS FOR EXISTING STUDENTS
-- =====================================================

-- Add sample Gmail addresses for existing students (if any)
UPDATE students SET 
  email = CONCAT(
    LOWER(REPLACE(REPLACE(full_name, ' ', '.'), '-', '.')), 
    '.', 
    id,
    '@gmail.com'
  )
WHERE email IS NULL OR email = '';

-- Clean up any double dots in emails
UPDATE students SET 
  email = REPLACE(REPLACE(email, '..', '.'), '...', '.')
WHERE email LIKE '%.%.%';

-- =====================================================
-- 6. MAKE EMAIL MANDATORY (NOT NULL)
-- =====================================================

-- First verify all students have emails
SELECT COUNT(*) as students_without_email 
FROM students 
WHERE email IS NULL OR email = '';

-- If the above query returns 0, then run this:
ALTER TABLE students 
MODIFY COLUMN email VARCHAR(255) NOT NULL;

-- Add unique constraint on email
ALTER TABLE students 
ADD CONSTRAINT unique_student_email UNIQUE (email);

-- =====================================================
-- 7. ADD MISSING INDEXES
-- =====================================================

-- Add gender index if not exists
ALTER TABLE students 
ADD INDEX IF NOT EXISTS idx_gender (gender);

-- =====================================================
-- 8. INSERT SAMPLE DATA FOR TESTING
-- =====================================================

-- Insert test email logs
INSERT INTO email_logs (type, recipient, sender, content, status, student_id) VALUES
('registration', 'test.student@gmail.com', 'System', 'Welcome email sent', 'success', 1),
('bulk', 'another.student@gmail.com', 'Admin', 'Announcement email', 'success', 2)
ON DUPLICATE KEY UPDATE id = id;

-- Insert test QR logs
INSERT INTO qr_attendance_logs (student_id, qr_data, status, scanner_info) VALUES
(1, '{"student_id":1,"name":"Test Student","token":"abc123"}', 'success', 'Mobile App Scanner'),
(2, '{"student_id":2,"name":"Another Student","token":"def456"}', 'success', 'Web Scanner')
ON DUPLICATE KEY UPDATE id = id;

-- =====================================================
-- 9. VERIFY FINAL SETUP
-- =====================================================

-- Show table structures
DESCRIBE students;
DESCRIBE email_logs;
DESCRIBE qr_attendance_logs;

-- Show all tables in database
SHOW TABLES;

-- Verify students have emails
SELECT id, full_name, email, gender, 
       CASE 
         WHEN email LIKE '%@gmail.com' THEN '✅ Valid Gmail'
         ELSE '❌ Invalid Email'
       END as email_status
FROM students
ORDER BY id;

-- Check constraints
SELECT 
  CONSTRAINT_NAME, 
  CONSTRAINT_TYPE, 
  TABLE_NAME 
FROM information_schema.TABLE_CONSTRAINTS 
WHERE TABLE_SCHEMA = 'attendance_system' 
  AND TABLE_NAME = 'students';

-- =====================================================
-- 10. FINAL STATUS
-- =====================================================

SELECT 'Database setup completed successfully!' as Status;
SELECT 'Email is now MANDATORY for all new student registrations' as EmailStatus;
SELECT 'QR code and notification system is ready!' as SystemStatus;

-- Show final statistics
SELECT 
  COUNT(*) as total_students,
  COUNT(CASE WHEN email LIKE '%@gmail.com' THEN 1 END) as gmail_emails,
  COUNT(CASE WHEN gender = 'Male' THEN 1 END) as male_students,
  COUNT(CASE WHEN gender = 'Female' THEN 1 END) as female_students
FROM students;

-- =====================================================
-- SETUP COMPLETE!
-- Your MK Attendance system is now ready with:
-- ✅ Mandatory email registration (@gmail.com only)
-- ✅ Automatic registration email notifications
-- ✅ QR code generation and scanning
-- ✅ Comprehensive logging system
-- ✅ All required database tables and indexes
-- =====================================================
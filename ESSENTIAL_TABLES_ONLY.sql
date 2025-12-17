-- =====================================================
-- MK ATTENDANCE - ESSENTIAL TABLES ONLY
-- Quick setup for notification and QR system
-- =====================================================

USE attendance_system;

-- =====================================================
-- 1. UPDATE STUDENTS TABLE (Add missing columns)
-- =====================================================

ALTER TABLE students 
ADD COLUMN IF NOT EXISTS gender VARCHAR(10) DEFAULT 'Male',
ADD COLUMN IF NOT EXISTS email VARCHAR(255) NOT NULL,
ADD COLUMN IF NOT EXISTS qr_code TEXT DEFAULT NULL;

-- Add indexes
ALTER TABLE students 
ADD INDEX IF NOT EXISTS idx_email (email),
ADD INDEX IF NOT EXISTS idx_qr_code (qr_code(255));

-- =====================================================
-- 2. EMAIL LOGS TABLE
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
  INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 3. QR ATTENDANCE LOGS TABLE
-- =====================================================

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
-- 4. UPDATE EXISTING DATA
-- =====================================================

-- Remove auto-generation of emails - Email is now MANDATORY
-- Students must provide their own email addresses during registration

-- Set gender based on names (basic logic)
UPDATE students SET gender = 'Female' 
WHERE (full_name LIKE '%Fatima%' OR full_name LIKE '%Sara%' OR full_name LIKE '%Meron%' 
       OR full_name LIKE '%Almaz%' OR full_name LIKE '%Zara%' OR full_name LIKE '%Feven%' 
       OR full_name LIKE '%Kalkidan%' OR full_name LIKE '%Qedest%' OR full_name LIKE '%Urael%' 
       OR full_name LIKE '%Veronica%') 
AND gender = 'Male';

-- =====================================================
-- 5. VERIFY SETUP
-- =====================================================

-- Check tables exist
SHOW TABLES LIKE '%email_logs%';
SHOW TABLES LIKE '%qr_attendance_logs%';

-- Check students table structure
DESCRIBE students;

-- Show sample data
SELECT id, full_name, phone, class, gender, email FROM students LIMIT 3;

SELECT 'Essential tables created successfully!' as Status;
-- =====================================================
-- MK ATTENDANCE SYSTEM - COMPLETE DATABASE SETUP
-- Notification System + QR Code System
-- =====================================================

-- Use your existing database
USE attendance_system;

-- =====================================================
-- 1. UPDATE EXISTING STUDENTS TABLE
-- =====================================================

-- Add new columns to existing students table
ALTER TABLE students 
ADD COLUMN IF NOT EXISTS gender VARCHAR(10) DEFAULT 'Male',
ADD COLUMN IF NOT EXISTS email VARCHAR(255) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS qr_code TEXT DEFAULT NULL;

-- Add indexes for better performance
ALTER TABLE students 
ADD INDEX IF NOT EXISTS idx_email (email),
ADD INDEX IF NOT EXISTS idx_gender (gender),
ADD INDEX IF NOT EXISTS idx_qr_code (qr_code(255));

-- =====================================================
-- 2. CREATE EMAIL LOGS TABLE
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
  INDEX idx_student_id (student_id),
  INDEX idx_recipient (recipient)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 3. CREATE QR ATTENDANCE LOGS TABLE
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
  user_agent TEXT,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  INDEX idx_student_id (student_id),
  INDEX idx_scan_timestamp (scan_timestamp),
  INDEX idx_status (status),
  INDEX idx_date_status (scan_timestamp, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 4. UPDATE SAMPLE DATA WITH NEW FIELDS
-- =====================================================

-- Update existing students with sample email addresses and gender
UPDATE students SET 
  gender = 'Male',
  email = CONCAT(LOWER(REPLACE(full_name, ' ', '.')), '@gmail.com')
WHERE gender IS NULL AND full_name LIKE '%Ahmed%' OR full_name LIKE '%Mohamed%' OR full_name LIKE '%Omar%';

UPDATE students SET 
  gender = 'Female',
  email = CONCAT(LOWER(REPLACE(full_name, ' ', '.')), '@gmail.com')
WHERE gender IS NULL AND full_name LIKE '%Fatima%' OR full_name LIKE '%Sara%';

-- Set default gender for any remaining students
UPDATE students SET gender = 'Male' WHERE gender IS NULL;

-- =====================================================
-- 5. CREATE NOTIFICATION SETTINGS TABLE (OPTIONAL)
-- =====================================================

CREATE TABLE IF NOT EXISTS notification_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(100) NOT NULL UNIQUE,
  setting_value TEXT,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_setting_key (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default notification settings
INSERT INTO notification_settings (setting_key, setting_value, description) VALUES
('email_enabled', 'true', 'Enable/disable email notifications'),
('smtp_host', 'smtp.gmail.com', 'SMTP server host'),
('smtp_port', '587', 'SMTP server port'),
('email_from_name', 'MK Attendance System', 'Default sender name for emails'),
('registration_email_enabled', 'true', 'Enable registration confirmation emails'),
('bulk_email_enabled', 'true', 'Enable bulk email functionality')
ON DUPLICATE KEY UPDATE 
setting_value = VALUES(setting_value),
updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 6. CREATE EMAIL TEMPLATES TABLE (OPTIONAL)
-- =====================================================

CREATE TABLE IF NOT EXISTS email_templates (
  id INT AUTO_INCREMENT PRIMARY KEY,
  template_name VARCHAR(100) NOT NULL UNIQUE,
  subject VARCHAR(255) NOT NULL,
  html_content TEXT NOT NULL,
  text_content TEXT,
  variables JSON,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_template_name (template_name),
  INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default email templates
INSERT INTO email_templates (template_name, subject, html_content, text_content, variables) VALUES
(
  'student_registration',
  'Welcome to MK Attendance System - Registration Confirmed',
  '<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Welcome to MK Attendance</title>
</head>
<body style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f5f5f5;">
    <div style="max-width: 600px; margin: 0 auto; background-color: white;">
        <div style="background: linear-gradient(135deg, #6A5ACD, #9370DB); padding: 20px; text-align: center;">
            <h1 style="color: white; margin: 0;">MK Attendance System</h1>
            <p style="color: white; margin: 5px 0;">Student Registration Confirmation</p>
        </div>
        
        <div style="padding: 30px;">
            <h2 style="color: #333;">Welcome, {{student_name}}!</h2>
            <p>Congratulations! You have been successfully registered in the MK Attendance System.</p>
            
            <div style="background: #f9f9f9; padding: 20px; border-radius: 8px; margin: 20px 0;">
                <h3 style="color: #6A5ACD;">Your Registration Details:</h3>
                <p><strong>Student ID:</strong> {{student_id}}</p>
                <p><strong>Full Name:</strong> {{student_name}}</p>
                <p><strong>Class:</strong> {{student_class}}</p>
                <p><strong>Phone:</strong> {{student_phone}}</p>
                <p><strong>Gender:</strong> {{student_gender}}</p>
            </div>
            
            <div style="background: #e8f4fd; padding: 15px; border-radius: 8px;">
                <p style="margin: 0; color: #1976D2;">
                    <strong>Important:</strong> Keep this information safe. Your Student ID will be used for attendance tracking.
                </p>
            </div>
        </div>
        
        <div style="background: #333; padding: 20px; text-align: center;">
            <p style="color: #ccc; margin: 0;">© 2024 MK Attendance System. All rights reserved.</p>
        </div>
    </div>
</body>
</html>',
  'Welcome to MK Attendance System!\n\nDear {{student_name}},\n\nYou have been successfully registered.\n\nStudent ID: {{student_id}}\nClass: {{student_class}}\nPhone: {{student_phone}}\n\nThank you!',
  '["student_name", "student_id", "student_class", "student_phone", "student_gender"]'
)
ON DUPLICATE KEY UPDATE 
html_content = VALUES(html_content),
updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 7. CREATE SYSTEM LOGS TABLE (OPTIONAL)
-- =====================================================

CREATE TABLE IF NOT EXISTS system_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  log_type ENUM('info', 'warning', 'error', 'debug') NOT NULL,
  module VARCHAR(100) NOT NULL,
  message TEXT NOT NULL,
  details JSON,
  user_id INT,
  ip_address VARCHAR(45),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_log_type (log_type),
  INDEX idx_module (module),
  INDEX idx_timestamp (timestamp),
  INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 8. VERIFY TABLE CREATION
-- =====================================================

-- Show all tables to verify creation
SHOW TABLES;

-- Show structure of updated students table
DESCRIBE students;

-- Show structure of new tables
DESCRIBE email_logs;
DESCRIBE qr_attendance_logs;
DESCRIBE notification_settings;
DESCRIBE email_templates;

-- =====================================================
-- 9. INSERT TEST DATA (OPTIONAL)
-- =====================================================

-- Insert some test email logs
INSERT INTO email_logs (type, recipient, sender, content, status, student_id) VALUES
('registration', 'test@example.com', 'System', 'Welcome email sent', 'success', 1),
('bulk', 'student@example.com', 'Admin', 'Announcement email', 'success', 2);

-- Insert some test QR logs
INSERT INTO qr_attendance_logs (student_id, qr_data, status, scanner_info) VALUES
(1, '{"student_id":1,"name":"Test Student"}', 'success', 'Mobile App Scanner'),
(2, '{"student_id":2,"name":"Another Student"}', 'success', 'Web Scanner');

-- =====================================================
-- 10. GRANT PERMISSIONS (IF NEEDED)
-- =====================================================

-- Grant permissions to your application user (replace 'your_app_user' with actual username)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON attendance_system.email_logs TO 'your_app_user'@'%';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON attendance_system.qr_attendance_logs TO 'your_app_user'@'%';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON attendance_system.notification_settings TO 'your_app_user'@'%';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON attendance_system.email_templates TO 'your_app_user'@'%';

-- =====================================================
-- SETUP COMPLETE!
-- =====================================================

SELECT 'Database setup completed successfully!' as Status;
SELECT 'Email and QR notification system is ready!' as Message;

-- Show final table count
SELECT COUNT(*) as total_tables FROM information_schema.tables 
WHERE table_schema = 'attendance_system';

-- Show students with new fields
SELECT id, full_name, phone, class, gender, email, 
       CASE WHEN qr_code IS NOT NULL THEN 'Generated' ELSE 'Not Generated' END as qr_status
FROM students 
LIMIT 5;
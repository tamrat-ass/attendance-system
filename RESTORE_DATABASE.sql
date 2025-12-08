-- ============================================
-- RESTORE ATTENDANCE SYSTEM DATABASE
-- This will recreate the database structure
-- ============================================

-- Drop and recreate database to start fresh
DROP DATABASE IF EXISTS attendance_system;
CREATE DATABASE attendance_system;
USE attendance_system;

-- Create students table
CREATE TABLE students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  class VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_class (class),
  INDEX idx_name (full_name),
  INDEX idx_phone (phone)
);

-- Create users table
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE,
  full_name VARCHAR(255),
  role ENUM('admin', 'manager', 'user') DEFAULT 'user',
  status ENUM('active', 'inactive') DEFAULT 'active',
  
  -- Permissions
  can_manage_students BOOLEAN DEFAULT TRUE,
  can_add_student BOOLEAN DEFAULT TRUE,
  can_update_student BOOLEAN DEFAULT TRUE,
  can_upload_students BOOLEAN DEFAULT TRUE,
  can_delete_student BOOLEAN DEFAULT FALSE,
  can_mark_attendance BOOLEAN DEFAULT TRUE,
  can_view_reports BOOLEAN DEFAULT FALSE,
  can_export_data BOOLEAN DEFAULT FALSE,
  can_manage_users BOOLEAN DEFAULT FALSE,
  can_delete_user BOOLEAN DEFAULT FALSE,
  can_manage_passwords BOOLEAN DEFAULT FALSE,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create attendance table
CREATE TABLE attendance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  date DATE NOT NULL,
  status ENUM('present', 'absent', 'late', 'permission') NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  UNIQUE KEY unique_attendance (student_id, date),
  INDEX idx_date (date),
  INDEX idx_status (status),
  INDEX idx_student_date (student_id, date)
);

-- Create user logs table
CREATE TABLE user_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  username VARCHAR(50),
  action VARCHAR(100) NOT NULL,
  target_type VARCHAR(50),
  target_id INT,
  details TEXT,
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_user_id (user_id),
  INDEX idx_action (action),
  INDEX idx_created_at (created_at)
);

-- Insert default admin user
INSERT INTO users (
  username, 
  password_hash, 
  email, 
  full_name, 
  role, 
  status,
  can_manage_students,
  can_add_student,
  can_update_student,
  can_upload_students,
  can_delete_student,
  can_mark_attendance,
  can_view_reports,
  can_export_data,
  can_manage_users,
  can_delete_user,
  can_manage_passwords
) VALUES (
  'admin',
  'password123',
  'admin@example.com',
  'System Administrator',
  'admin',
  'active',
  TRUE,
  TRUE,
  TRUE,
  TRUE,
  TRUE,
  TRUE,
  TRUE,
  TRUE,
  TRUE,
  TRUE,
  TRUE
);

-- Show created tables
SHOW TABLES;
SELECT 'Database structure recreated successfully!' as status;
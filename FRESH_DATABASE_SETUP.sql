-- ============================================
-- COMPLETE FRESH ATTENDANCE SYSTEM DATABASE
-- This will create everything from scratch
-- ============================================

-- Drop existing database if it exists and create fresh
DROP DATABASE IF EXISTS attendance_system;
CREATE DATABASE attendance_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE attendance_system;

-- ============================================
-- 1. STUDENTS TABLE
-- ============================================
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    class VARCHAR(100) NOT NULL,
    email VARCHAR(255) NULL,
    address TEXT NULL,
    parent_name VARCHAR(255) NULL,
    parent_phone VARCHAR(20) NULL,
    status ENUM('active', 'inactive', 'graduated') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes for better performance
    INDEX idx_class (class),
    INDEX idx_name (full_name),
    INDEX idx_phone (phone),
    INDEX idx_status (status)
);

-- ============================================
-- 2. USERS TABLE (with all permissions)
-- ============================================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NULL,
    full_name VARCHAR(255) NULL,
    role ENUM('admin', 'manager', 'teacher', 'user') DEFAULT 'user',
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    
    -- Student Management Permissions
    can_manage_students BOOLEAN DEFAULT TRUE,
    can_add_student BOOLEAN DEFAULT TRUE,
    can_update_student BOOLEAN DEFAULT TRUE,
    can_delete_student BOOLEAN DEFAULT FALSE,
    can_upload_students BOOLEAN DEFAULT TRUE,
    can_export_students BOOLEAN DEFAULT FALSE,
    
    -- Attendance Permissions
    can_mark_attendance BOOLEAN DEFAULT TRUE,
    can_view_attendance BOOLEAN DEFAULT TRUE,
    can_edit_attendance BOOLEAN DEFAULT FALSE,
    can_delete_attendance BOOLEAN DEFAULT FALSE,
    
    -- Reports Permissions
    can_view_reports BOOLEAN DEFAULT FALSE,
    can_export_reports BOOLEAN DEFAULT FALSE,
    can_view_analytics BOOLEAN DEFAULT FALSE,
    
    -- User Management Permissions
    can_manage_users BOOLEAN DEFAULT FALSE,
    can_add_user BOOLEAN DEFAULT FALSE,
    can_update_user BOOLEAN DEFAULT FALSE,
    can_delete_user BOOLEAN DEFAULT FALSE,
    can_manage_passwords BOOLEAN DEFAULT FALSE,
    can_reset_passwords BOOLEAN DEFAULT FALSE,
    
    -- System Permissions
    can_view_logs BOOLEAN DEFAULT FALSE,
    can_manage_system BOOLEAN DEFAULT FALSE,
    can_backup_data BOOLEAN DEFAULT FALSE,
    
    -- Profile settings
    last_login TIMESTAMP NULL,
    login_attempts INT DEFAULT 0,
    locked_until TIMESTAMP NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_status (status)
);

-- ============================================
-- 3. ATTENDANCE TABLE
-- ============================================
CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    date DATE NOT NULL,
    status ENUM('present', 'absent', 'late', 'permission', 'sick', 'excused') NOT NULL,
    notes TEXT NULL,
    marked_by INT NULL,
    marked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (marked_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,
    
    -- Unique constraint to prevent duplicate attendance for same student on same date
    UNIQUE KEY unique_student_date (student_id, date),
    
    -- Indexes for better performance
    INDEX idx_date (date),
    INDEX idx_status (status),
    INDEX idx_student_date (student_id, date),
    INDEX idx_marked_by (marked_by)
);

-- ============================================
-- 4. USER LOGS TABLE (Activity tracking)
-- ============================================
CREATE TABLE user_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    username VARCHAR(50) NULL,
    action VARCHAR(100) NOT NULL,
    target_type VARCHAR(50) NULL,
    target_id INT NULL,
    details TEXT NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    status ENUM('success', 'failed', 'warning') DEFAULT 'success',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_username (username),
    INDEX idx_action (action),
    INDEX idx_target_type (target_type),
    INDEX idx_created_at (created_at),
    INDEX idx_status (status)
);

-- ============================================
-- 5. CLASSES TABLE (Optional - for better class management)
-- ============================================
CREATE TABLE classes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    class_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT NULL,
    teacher_id INT NULL,
    academic_year VARCHAR(20) NULL,
    status ENUM('active', 'inactive', 'archived') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign key
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE SET NULL,
    
    -- Indexes
    INDEX idx_class_name (class_name),
    INDEX idx_teacher_id (teacher_id),
    INDEX idx_status (status)
);

-- ============================================
-- 6. SYSTEM SETTINGS TABLE (Optional)
-- ============================================
CREATE TABLE system_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NULL,
    description TEXT NULL,
    updated_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign key
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,
    
    -- Index
    INDEX idx_setting_key (setting_key)
);

-- ============================================
-- INSERT DEFAULT DATA
-- ============================================

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
    can_delete_student,
    can_upload_students,
    can_export_students,
    can_mark_attendance,
    can_view_attendance,
    can_edit_attendance,
    can_delete_attendance,
    can_view_reports,
    can_export_reports,
    can_view_analytics,
    can_manage_users,
    can_add_user,
    can_update_user,
    can_delete_user,
    can_manage_passwords,
    can_reset_passwords,
    can_view_logs,
    can_manage_system,
    can_backup_data
) VALUES (
    'admin',
    'password123',
    'admin@school.com',
    'System Administrator',
    'admin',
    'active',
    TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,  -- Student permissions
    TRUE, TRUE, TRUE, TRUE,              -- Attendance permissions
    TRUE, TRUE, TRUE,                    -- Reports permissions
    TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,  -- User management permissions
    TRUE, TRUE, TRUE                     -- System permissions
);

-- Insert sample teacher user
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
    can_delete_student,
    can_upload_students,
    can_export_students,
    can_mark_attendance,
    can_view_attendance,
    can_edit_attendance,
    can_delete_attendance,
    can_view_reports,
    can_export_reports,
    can_view_analytics
) VALUES (
    'teacher1',
    'teacher123',
    'teacher@school.com',
    'John Teacher',
    'teacher',
    'active',
    TRUE, TRUE, TRUE, FALSE, TRUE, TRUE,  -- Student permissions
    TRUE, TRUE, TRUE, FALSE,              -- Attendance permissions
    TRUE, TRUE, FALSE                     -- Reports permissions
);

-- Insert sample classes
INSERT INTO classes (class_name, description, academic_year, status) VALUES
('Grade 10-A', 'Grade 10 Section A', '2024-2025', 'active'),
('Grade 10-B', 'Grade 10 Section B', '2024-2025', 'active'),
('Grade 11-A', 'Grade 11 Section A', '2024-2025', 'active'),
('Grade 11-B', 'Grade 11 Section B', '2024-2025', 'active'),
('Grade 12-A', 'Grade 12 Section A', '2024-2025', 'active');

-- Insert sample students
INSERT INTO students (full_name, phone, class, email, parent_name, parent_phone, status) VALUES
('Alice Johnson', '1234567890', 'Grade 10-A', 'alice@email.com', 'Robert Johnson', '1234567891', 'active'),
('Bob Smith', '2345678901', 'Grade 10-A', 'bob@email.com', 'Mary Smith', '2345678902', 'active'),
('Carol Davis', '3456789012', 'Grade 10-B', 'carol@email.com', 'James Davis', '3456789013', 'active'),
('David Wilson', '4567890123', 'Grade 11-A', 'david@email.com', 'Linda Wilson', '4567890124', 'active'),
('Emma Brown', '5678901234', 'Grade 11-B', 'emma@email.com', 'Michael Brown', '5678901235', 'active'),
('Frank Miller', '6789012345', 'Grade 12-A', 'frank@email.com', 'Sarah Miller', '6789012346', 'active');

-- Insert some sample attendance records
INSERT INTO attendance (student_id, date, status, marked_by) VALUES
(1, CURDATE(), 'present', 1),
(2, CURDATE(), 'present', 1),
(3, CURDATE(), 'absent', 1),
(4, CURDATE(), 'late', 1),
(5, CURDATE(), 'present', 1),
(6, CURDATE(), 'present', 1);

-- Insert system settings
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('school_name', 'Sample School', 'Name of the school'),
('academic_year', '2024-2025', 'Current academic year'),
('attendance_cutoff_time', '09:00', 'Time after which students are marked late'),
('backup_frequency', 'daily', 'How often to backup data'),
('max_login_attempts', '5', 'Maximum failed login attempts before account lock');

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Show all created tables
SHOW TABLES;

-- Show table structures
DESCRIBE students;
DESCRIBE users;
DESCRIBE attendance;
DESCRIBE user_logs;
DESCRIBE classes;
DESCRIBE system_settings;

-- Show sample data counts
SELECT 'Students' as table_name, COUNT(*) as record_count FROM students
UNION ALL
SELECT 'Users' as table_name, COUNT(*) as record_count FROM users
UNION ALL
SELECT 'Attendance' as table_name, COUNT(*) as record_count FROM attendance
UNION ALL
SELECT 'User Logs' as table_name, COUNT(*) as record_count FROM user_logs
UNION ALL
SELECT 'Classes' as table_name, COUNT(*) as record_count FROM classes
UNION ALL
SELECT 'System Settings' as table_name, COUNT(*) as record_count FROM system_settings;

-- Show students by class
SELECT class, COUNT(*) as student_count 
FROM students 
WHERE status = 'active'
GROUP BY class 
ORDER BY class;

-- Show users and their roles
SELECT username, full_name, role, status, 
       can_manage_students, can_mark_attendance, can_view_reports, can_manage_users
FROM users 
ORDER BY role, username;

SELECT 'Database setup completed successfully!' as status;
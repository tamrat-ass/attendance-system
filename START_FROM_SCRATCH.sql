-- ============================================
-- START FROM SCRATCH - SIMPLE DATABASE SETUP
-- ============================================

-- Step 1: Drop and create database
DROP DATABASE IF EXISTS attendance_system;
CREATE DATABASE attendance_system;
USE attendance_system;

-- Step 2: Create students table (basic)
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    class VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Step 3: Create users table (basic)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    role ENUM('admin', 'user') DEFAULT 'user',
    status ENUM('active', 'inactive') DEFAULT 'active',
    
    -- Basic permissions
    can_manage_students BOOLEAN DEFAULT TRUE,
    can_mark_attendance BOOLEAN DEFAULT TRUE,
    can_view_reports BOOLEAN DEFAULT FALSE,
    can_manage_users BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Step 4: Create attendance table (basic)
CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    date DATE NOT NULL,
    status ENUM('present', 'absent', 'late') NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    UNIQUE KEY unique_attendance (student_id, date)
);

-- Step 5: Create user_logs table (basic)
CREATE TABLE user_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    username VARCHAR(50),
    action VARCHAR(100) NOT NULL,
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Step 6: Insert admin user
INSERT INTO users (username, password_hash, full_name, role, can_manage_students, can_mark_attendance, can_view_reports, can_manage_users) 
VALUES ('admin', 'password123', 'Administrator', 'admin', TRUE, TRUE, TRUE, TRUE);

-- Step 7: Show what we created
SHOW TABLES;
SELECT 'Database created successfully!' as message;
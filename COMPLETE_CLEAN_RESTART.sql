-- Complete clean restart
-- Step 1: Drop the entire database
DROP DATABASE IF EXISTS attendance_system;

-- Step 2: Create fresh database
CREATE DATABASE attendance_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Step 3: Use the database
USE attendance_system;

-- Step 4: Create users table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    role ENUM('admin', 'user') DEFAULT 'user',
    status ENUM('active', 'inactive') DEFAULT 'active',
    can_manage_students BOOLEAN DEFAULT TRUE,
    can_mark_attendance BOOLEAN DEFAULT TRUE,
    can_view_reports BOOLEAN DEFAULT FALSE,
    can_manage_users BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 5: Insert admin user
INSERT INTO users (username, password_hash, full_name, role, can_manage_students, can_mark_attendance, can_view_reports, can_manage_users) 
VALUES ('admin', 'password123', 'Administrator', 'admin', TRUE, TRUE, TRUE, TRUE);

-- Step 6: Create students table
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    class VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 7: Create attendance table
CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    date DATE NOT NULL,
    status ENUM('present', 'absent', 'late') NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);

-- Step 8: Create user_logs table
CREATE TABLE user_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    username VARCHAR(50),
    action VARCHAR(100) NOT NULL,
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 9: Verify everything
SHOW TABLES;
SELECT * FROM users;
SELECT 'Clean restart completed successfully!' as result;
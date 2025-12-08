-- STEP 1: Create database
CREATE DATABASE IF NOT EXISTS attendance_system;

-- STEP 2: Use the database
USE attendance_system;

-- STEP 3: Create users table first
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- STEP 4: Insert admin user
INSERT INTO users (username, password_hash, full_name, role, can_manage_students, can_mark_attendance, can_view_reports, can_manage_users) 
VALUES ('admin', 'password123', 'Administrator', 'admin', TRUE, TRUE, TRUE, TRUE);

-- STEP 5: Check if user was created
SELECT * FROM users;

-- STEP 6: Create students table
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    class VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- STEP 7: Create attendance table
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

-- STEP 8: Create user_logs table
CREATE TABLE user_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    username VARCHAR(50),
    action VARCHAR(100) NOT NULL,
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- STEP 9: Show all tables
SHOW TABLES;

-- STEP 10: Final check
SELECT 'Setup completed successfully!' as result;
-- Create classes table for proper class management
-- Run these commands in phpMyAdmin one by one

USE attendance_system;

-- Create classes table
CREATE TABLE classes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    class_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert existing classes from students table
INSERT IGNORE INTO classes (class_name) 
SELECT DISTINCT class FROM students WHERE class IS NOT NULL AND class != '';

-- Check the created table
SELECT * FROM classes ORDER BY class_name;
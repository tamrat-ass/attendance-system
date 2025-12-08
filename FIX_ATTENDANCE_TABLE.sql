-- Fix attendance table and add missing columns
-- Run these commands in phpMyAdmin one by one

USE attendance_system;

-- Add missing updated_at column to attendance table
ALTER TABLE attendance 
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at;

-- Add a unique constraint to prevent duplicate attendance records for same student on same date
ALTER TABLE attendance 
ADD UNIQUE KEY unique_student_date (student_id, date);

-- Check the updated table structure
DESCRIBE attendance;

-- Add some sample students if none exist
INSERT IGNORE INTO students (full_name, phone, class) VALUES 
('John Doe', '123-456-7890', 'Class A'),
('Jane Smith', '098-765-4321', 'Class B'),
('Mike Johnson', '555-123-4567', 'Class A'),
('Sarah Wilson', '444-555-6666', 'Class B'),
('Tom Brown', '777-888-9999', 'Class A');

-- Add some sample attendance data for testing reports
INSERT IGNORE INTO attendance (student_id, date, status, notes) VALUES 
(1, CURDATE(), 'present', 'On time'),
(2, CURDATE(), 'absent', 'Sick'),
(3, CURDATE(), 'late', 'Traffic'),
(4, CURDATE(), 'present', 'On time'),
(5, CURDATE(), 'permission', 'Family event'),
(1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'present', 'On time'),
(2, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'present', 'On time'),
(3, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'absent', 'Sick'),
(4, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'late', 'Overslept'),
(5, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'present', 'On time');

-- Check if data was inserted
SELECT COUNT(*) as total_students FROM students;
SELECT COUNT(*) as total_attendance_records FROM attendance;

-- Test the attendance API query
SELECT a.*, s.full_name, s.phone, s.class 
FROM attendance a 
JOIN students s ON a.student_id = s.id
ORDER BY a.date DESC, s.full_name ASC
LIMIT 10;
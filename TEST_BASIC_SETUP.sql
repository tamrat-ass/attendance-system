-- Test the basic setup
USE attendance_system;

-- Check tables exist
SHOW TABLES;

-- Check users table
SELECT * FROM users;

-- Add a test student
INSERT INTO students (full_name, phone, class) VALUES ('Test Student', '1234567890', 'Grade 10-A');

-- Check students
SELECT * FROM students;

-- Add test attendance
INSERT INTO attendance (student_id, date, status) VALUES (1, CURDATE(), 'present');

-- Check attendance
SELECT * FROM attendance;

SELECT 'Basic setup test completed!' as result;
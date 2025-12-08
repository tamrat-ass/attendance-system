-- ============================================
-- IMPORT DATA FROM BACKUP
-- Run this AFTER restoring the database structure
-- ============================================

USE attendance_system;

-- If you have a backup SQL file, you can import specific data
-- Replace the INSERT statements below with your actual backup data

-- Example: If you remember some of your students, add them here
-- INSERT INTO students (full_name, phone, class) VALUES
-- ('Your Student Name', 'Phone Number', 'Class Name');

-- Example: If you remember your users, add them here
-- INSERT INTO users (username, password_hash, full_name, role) VALUES
-- ('your_username', 'your_password', 'Your Name', 'admin');

-- Check what data we have
SELECT 'Current students:' as info;
SELECT * FROM students;

SELECT 'Current users:' as info;
SELECT * FROM users;

SELECT 'Current attendance records:' as info;
SELECT * FROM attendance;
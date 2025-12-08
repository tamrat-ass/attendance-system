-- Debug classes issue
-- Run these commands in phpMyAdmin one by one

USE attendance_system;

-- 1. Check if classes table exists
SHOW TABLES LIKE 'classes';

-- 2. If it exists, check its structure
DESCRIBE classes;

-- 3. Check what's in the classes table
SELECT * FROM classes;

-- 4. Check what classes exist in students table
SELECT DISTINCT class FROM students WHERE class IS NOT NULL AND class != '';

-- 5. If classes table is empty, populate it from students
INSERT IGNORE INTO classes (class_name) 
SELECT DISTINCT class FROM students WHERE class IS NOT NULL AND class != '';

-- 6. Check again
SELECT * FROM classes ORDER BY class_name;
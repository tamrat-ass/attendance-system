-- Debug the permission issue in reports
-- Run these commands in phpMyAdmin one by one to check what's happening

USE attendance_system;

-- 1. Check what attendance records exist
SELECT 
    a.id,
    a.student_id,
    a.date,
    a.status,
    a.notes,
    s.full_name,
    s.class
FROM attendance a 
JOIN students s ON a.student_id = s.id
ORDER BY a.date DESC, s.full_name;

-- 2. Check specifically for permission records
SELECT 
    a.id,
    a.student_id,
    a.date,
    a.status,
    a.notes,
    s.full_name,
    s.class
FROM attendance a 
JOIN students s ON a.student_id = s.id
WHERE a.status = 'permission'
ORDER BY a.date DESC;

-- 3. Check the exact status values in the database
SELECT DISTINCT status FROM attendance;

-- 4. Count records by status
SELECT 
    status,
    COUNT(*) as count
FROM attendance 
GROUP BY status;

-- 5. Check if there are any records with different status values
SELECT 
    status,
    LENGTH(status) as status_length,
    ASCII(status) as first_char_ascii
FROM attendance 
GROUP BY status;

-- 6. Test the exact query that the reports API uses
SELECT a.*, s.full_name, s.phone, s.class 
FROM attendance a 
JOIN students s ON a.student_id = s.id
WHERE a.date BETWEEN CURDATE() - INTERVAL 30 DAY AND CURDATE()
ORDER BY a.date DESC, s.full_name ASC;
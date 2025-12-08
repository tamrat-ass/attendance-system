-- Fix role update issue - comprehensive solution
-- Run these commands in phpMyAdmin one by one

USE attendance_system;

-- 1. First, check if role column is ENUM and fix it
ALTER TABLE users 
MODIFY COLUMN role ENUM('admin', 'manager', 'user') DEFAULT 'user';

-- 2. Update the specific user to manager role
UPDATE users SET role = 'manager' WHERE id = 4;

-- 3. Verify the update worked
SELECT id, username, email, full_name, role, status FROM users WHERE id = 4;

-- 4. Check all users to see their roles
SELECT id, username, role, status FROM users ORDER BY id;

-- 5. Test the API query that the frontend uses
SELECT id, username, email, full_name, role, status, 
       can_manage_students, can_add_student, can_upload_students, can_delete_student,
       can_mark_attendance, can_view_reports, can_export_data, 
       can_manage_users, can_delete_user, can_manage_passwords, created_at 
FROM users ORDER BY created_at DESC;
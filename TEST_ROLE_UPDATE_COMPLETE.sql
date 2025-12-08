-- Complete test for role update issue
-- Run these commands in phpMyAdmin one by one

USE attendance_system;

-- 1. Show current state of user with ID 4
SELECT id, username, email, full_name, role, status, 
       can_manage_students, can_add_student, can_update_student, can_upload_students, can_delete_student,
       can_mark_attendance, can_view_reports, can_export_data, 
       can_manage_users, can_delete_user, can_manage_passwords
FROM users WHERE id = 4;

-- 2. Test the exact same UPDATE query that the API would run
UPDATE users SET 
    username = 'user2',
    email = 'tamrat.assu23@gmail.com',
    full_name = 'Regular User 2',
    role = 'manager',
    status = 'active',
    can_manage_students = 0,
    can_add_student = 1,
    can_update_student = 1,
    can_upload_students = 1,
    can_delete_student = 0,
    can_mark_attendance = 1,
    can_view_reports = 0,
    can_export_data = 0,
    can_manage_users = 0,
    can_delete_user = 0,
    can_manage_passwords = 0
WHERE id = 4;

-- 3. Check if the update worked
SELECT id, username, email, full_name, role, status FROM users WHERE id = 4;

-- 4. Check if there are any triggers or constraints preventing the update
SHOW TRIGGERS LIKE 'users';

-- 5. Check table constraints
SELECT 
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
WHERE TABLE_SCHEMA = 'attendance_system' 
AND TABLE_NAME = 'users';

-- 6. If role is still not 'manager', let's check what values are allowed
SELECT 
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_DEFAULT,
    IS_NULLABLE,
    EXTRA
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'attendance_system' 
AND TABLE_NAME = 'users' 
AND COLUMN_NAME = 'role';

-- 7. Try different role values to see what works
UPDATE users SET role = 'admin' WHERE id = 4;
SELECT role FROM users WHERE id = 4;

UPDATE users SET role = 'user' WHERE id = 4;
SELECT role FROM users WHERE id = 4;

UPDATE users SET role = 'manager' WHERE id = 4;
SELECT role FROM users WHERE id = 4;
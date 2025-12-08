-- Manual test to check and update permissions
USE attendance_system;

-- 1. Check current permissions for all users
SELECT id, username, role, 
       can_manage_students, can_mark_attendance, 
       can_view_reports, can_export_data, can_manage_users 
FROM users;

-- 2. Manually update manager user (ID 2) - change these values as needed
UPDATE users 
SET can_manage_students = 0,
    can_mark_attendance = 1,
    can_view_reports = 1,
    can_export_data = 0,
    can_manage_users = 0
WHERE username = 'manager';

-- 3. Verify the update worked
SELECT id, username, role, 
       can_manage_students, can_mark_attendance, 
       can_view_reports, can_export_data, can_manage_users 
FROM users 
WHERE username = 'manager';

-- 4. If columns don't exist, create them:
-- ALTER TABLE users 
--   ADD COLUMN can_manage_students TINYINT(1) DEFAULT 1,
--   ADD COLUMN can_mark_attendance TINYINT(1) DEFAULT 1,
--   ADD COLUMN can_view_reports TINYINT(1) DEFAULT 0,
--   ADD COLUMN can_export_data TINYINT(1) DEFAULT 0,
--   ADD COLUMN can_manage_users TINYINT(1) DEFAULT 0;

-- Debug role update issue
-- Run these commands in phpMyAdmin one by one

USE attendance_system;

-- 1. Check current users table structure
DESCRIBE users;

-- 2. Check current user data (especially roles)
SELECT id, username, email, full_name, role, status FROM users ORDER BY id;

-- 3. Check if role column has any constraints
SHOW CREATE TABLE users;

-- 4. Test manual role update to see if it works
UPDATE users SET role = 'manager' WHERE id = 4;

-- 5. Check if the manual update worked
SELECT id, username, role FROM users WHERE id = 4;

-- 6. Check if role column is ENUM with limited values
SELECT 
    COLUMN_NAME,
    COLUMN_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'attendance_system' 
AND TABLE_NAME = 'users' 
AND COLUMN_NAME = 'role';

-- 7. If role is ENUM, check what values are allowed
SELECT 
    COLUMN_TYPE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'attendance_system' 
AND TABLE_NAME = 'users' 
AND COLUMN_NAME = 'role';

-- 8. Check recent user_logs to see what's being attempted
SELECT * FROM user_logs 
WHERE action LIKE '%USER%' 
ORDER BY created_at DESC 
LIMIT 10;
-- Simple role update test without system tables
-- Run these commands in phpMyAdmin one by one

USE attendance_system;

-- 1. Check current user data
SELECT id, username, role, status FROM users WHERE id = 4;

-- 2. Check the table structure (this should work)
DESCRIBE users;

-- 3. Try to update role to 'manager'
UPDATE users SET role = 'manager' WHERE id = 4;

-- 4. Check if it worked
SELECT id, username, role FROM users WHERE id = 4;

-- 5. Try other role values
UPDATE users SET role = 'admin' WHERE id = 4;
SELECT id, username, role FROM users WHERE id = 4;

-- 6. Try 'user' role
UPDATE users SET role = 'user' WHERE id = 4;
SELECT id, username, role FROM users WHERE id = 4;

-- 7. Try 'manager' again
UPDATE users SET role = 'manager' WHERE id = 4;
SELECT id, username, role FROM users WHERE id = 4;

-- 8. Show all users to see their roles
SELECT id, username, role FROM users ORDER BY id;
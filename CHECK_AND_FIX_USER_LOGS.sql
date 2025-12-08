-- Check and fix user_logs table structure
-- Run these commands in phpMyAdmin one by one

USE attendance_system;

-- 1. First, check the current structure of user_logs table
DESCRIBE user_logs;

-- 2. Check what columns currently exist
SHOW COLUMNS FROM user_logs;

-- 3. Add the missing columns (run this even if you think you already did)
ALTER TABLE user_logs 
ADD COLUMN IF NOT EXISTS target_type VARCHAR(50) AFTER action,
ADD COLUMN IF NOT EXISTS target_id INT AFTER target_type;

-- 4. Verify the columns were added
DESCRIBE user_logs;

-- 5. Test insert to make sure it works
INSERT INTO user_logs (user_id, username, action, target_type, target_id, details, ip_address) 
VALUES (1, 'admin', 'TEST_FIX', 'user', 999, 'Testing the fix', '127.0.0.1');

-- 6. Check if the test insert worked
SELECT * FROM user_logs WHERE action = 'TEST_FIX';

-- 7. Clean up the test record
DELETE FROM user_logs WHERE action = 'TEST_FIX';
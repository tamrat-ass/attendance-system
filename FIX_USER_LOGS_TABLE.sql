-- Fix user_logs table by adding missing columns
-- Run these commands in phpMyAdmin one by one

USE attendance_system;

-- Add missing columns to user_logs table
ALTER TABLE user_logs 
ADD COLUMN target_type VARCHAR(50) AFTER action,
ADD COLUMN target_id INT AFTER target_type;

-- Check the updated table structure
DESCRIBE user_logs;

-- Test the logging functionality with a sample insert
INSERT INTO user_logs (user_id, username, action, target_type, target_id, details, ip_address) 
VALUES (1, 'admin', 'TEST_LOG', 'user', 1, 'Test log entry', '127.0.0.1');

-- Check if the test insert worked
SELECT * FROM user_logs ORDER BY created_at DESC LIMIT 5;
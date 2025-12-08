-- Fix the users table by adding all missing columns
-- Run these commands in phpMyAdmin one by one

USE attendance_system;

-- Add missing columns to users table
ALTER TABLE users 
ADD COLUMN email VARCHAR(255) AFTER username,
ADD COLUMN can_add_student BOOLEAN DEFAULT TRUE AFTER can_manage_students,
ADD COLUMN can_update_student BOOLEAN DEFAULT TRUE AFTER can_add_student,
ADD COLUMN can_upload_students BOOLEAN DEFAULT TRUE AFTER can_update_student,
ADD COLUMN can_delete_student BOOLEAN DEFAULT FALSE AFTER can_upload_students,
ADD COLUMN can_export_data BOOLEAN DEFAULT FALSE AFTER can_view_reports,
ADD COLUMN can_delete_user BOOLEAN DEFAULT FALSE AFTER can_manage_users,
ADD COLUMN can_manage_passwords BOOLEAN DEFAULT FALSE AFTER can_delete_user;

-- Add ip_address column to user_logs table (also needed)
ALTER TABLE user_logs 
ADD COLUMN ip_address VARCHAR(45) AFTER details;

-- Update existing admin user with email and proper permissions
UPDATE users 
SET email = 'admin@example.com',
    can_add_student = TRUE,
    can_update_student = TRUE,
    can_upload_students = TRUE,
    can_delete_student = TRUE,
    can_export_data = TRUE,
    can_delete_user = TRUE,
    can_manage_passwords = TRUE
WHERE username = 'admin';

-- Check the updated table structure
DESCRIBE users;

-- Check if admin user has all permissions
SELECT * FROM users WHERE username = 'admin';
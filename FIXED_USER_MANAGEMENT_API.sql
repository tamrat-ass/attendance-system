-- Fix User Management API Database Schema
-- Run this to add missing permission columns and fix the users table

USE attendance_system;

-- Add missing permission columns if they don't exist
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS can_add_student TINYINT(1) DEFAULT 1 AFTER status,
ADD COLUMN IF NOT EXISTS can_update_student TINYINT(1) DEFAULT 1 AFTER can_add_student,
ADD COLUMN IF NOT EXISTS can_upload_students TINYINT(1) DEFAULT 1 AFTER can_update_student,
ADD COLUMN IF NOT EXISTS can_delete_student TINYINT(1) DEFAULT 0 AFTER can_upload_students,
ADD COLUMN IF NOT EXISTS can_mark_attendance TINYINT(1) DEFAULT 1 AFTER can_delete_student,
ADD COLUMN IF NOT EXISTS can_view_reports TINYINT(1) DEFAULT 0 AFTER can_mark_attendance,
ADD COLUMN IF NOT EXISTS can_export_data TINYINT(1) DEFAULT 0 AFTER can_view_reports,
ADD COLUMN IF NOT EXISTS can_manage_users TINYINT(1) DEFAULT 0 AFTER can_export_data,
ADD COLUMN IF NOT EXISTS can_delete_user TINYINT(1) DEFAULT 0 AFTER can_manage_users,
ADD COLUMN IF NOT EXISTS can_manage_passwords TINYINT(1) DEFAULT 0 AFTER can_delete_user;

-- Set default permissions based on role
UPDATE users SET
    can_add_student = 1,
    can_update_student = 1,
    can_upload_students = CASE WHEN role IN ('admin', 'manager') THEN 1 ELSE 0 END,
    can_delete_student = CASE WHEN role = 'admin' THEN 1 ELSE 0 END,
    can_mark_attendance = 1,
    can_view_reports = CASE WHEN role IN ('admin', 'manager') THEN 1 ELSE 0 END,
    can_export_data = CASE WHEN role IN ('admin', 'manager') THEN 1 ELSE 0 END,
    can_manage_users = CASE WHEN role = 'admin' THEN 1 ELSE 0 END,
    can_delete_user = CASE WHEN role = 'admin' THEN 1 ELSE 0 END,
    can_manage_passwords = CASE WHEN role = 'admin' THEN 1 ELSE 0 END;

-- Verify the changes
SELECT id, username, role, 
       can_add_student, can_update_student, can_upload_students, can_delete_student,
       can_mark_attendance, can_view_reports, can_export_data,
       can_manage_users, can_delete_user, can_manage_passwords
FROM users;

-- Show table structure
DESCRIBE users;
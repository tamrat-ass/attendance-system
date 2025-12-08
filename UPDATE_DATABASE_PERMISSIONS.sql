-- Add permissions columns to users table
-- Run this in phpMyAdmin or MySQL command line

USE attendance_system;

-- Add permission columns to users table
ALTER TABLE users 
  ADD COLUMN IF NOT EXISTS can_manage_students BOOLEAN DEFAULT TRUE AFTER status,
  ADD COLUMN IF NOT EXISTS can_mark_attendance BOOLEAN DEFAULT TRUE AFTER can_manage_students,
  ADD COLUMN IF NOT EXISTS can_view_reports BOOLEAN DEFAULT TRUE AFTER can_mark_attendance,
  ADD COLUMN IF NOT EXISTS can_export_data BOOLEAN DEFAULT FALSE AFTER can_view_reports,
  ADD COLUMN IF NOT EXISTS can_manage_users BOOLEAN DEFAULT FALSE AFTER can_export_data;

-- Set default permissions based on role
UPDATE users SET 
  can_manage_students = TRUE,
  can_mark_attendance = TRUE,
  can_view_reports = TRUE,
  can_export_data = TRUE,
  can_manage_users = TRUE
WHERE role = 'admin';

UPDATE users SET 
  can_manage_students = TRUE,
  can_mark_attendance = TRUE,
  can_view_reports = TRUE,
  can_export_data = TRUE,
  can_manage_users = FALSE
WHERE role = 'manager';

UPDATE users SET 
  can_manage_students = FALSE,
  can_mark_attendance = TRUE,
  can_view_reports = FALSE,
  can_export_data = FALSE,
  can_manage_users = FALSE
WHERE role = 'user';

-- Verify the changes
SELECT id, username, role, can_manage_students, can_mark_attendance, can_view_reports, can_export_data, can_manage_users FROM users;

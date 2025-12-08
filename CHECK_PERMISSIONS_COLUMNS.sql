-- Check if permission columns exist in users table
USE attendance_system;

-- Show table structure
DESCRIBE users;

-- Check current permission values
SELECT id, username, role, 
       can_manage_students, can_mark_attendance, 
       can_view_reports, can_export_data, can_manage_users 
FROM users;

-- If columns don't exist, run this:
-- ALTER TABLE users 
--   ADD COLUMN IF NOT EXISTS can_manage_students BOOLEAN DEFAULT TRUE,
--   ADD COLUMN IF NOT EXISTS can_mark_attendance BOOLEAN DEFAULT TRUE,
--   ADD COLUMN IF NOT EXISTS can_view_reports BOOLEAN DEFAULT TRUE,
--   ADD COLUMN IF NOT EXISTS can_export_data BOOLEAN DEFAULT FALSE,
--   ADD COLUMN IF NOT EXISTS can_manage_users BOOLEAN DEFAULT FALSE;

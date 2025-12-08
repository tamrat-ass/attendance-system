-- Fix the can_update_student permission for all users

-- First, check if the column exists
SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'users' 
AND COLUMN_NAME = 'can_update_student';

-- If the column doesn't exist, add it
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS can_update_student BOOLEAN DEFAULT TRUE;

-- Update all existing users to have the update student permission
UPDATE users 
SET can_update_student = TRUE 
WHERE can_update_student IS NULL OR can_update_student = FALSE;

-- Verify the update
SELECT 
    id,
    username,
    role,
    can_manage_students,
    can_add_student,
    can_update_student,
    can_upload_students,
    can_delete_student
FROM users 
ORDER BY id;
-- Add can_update_student permission column
ALTER TABLE users 
ADD COLUMN can_update_student TINYINT(1) DEFAULT 1 AFTER can_add_student;

-- Set default values based on existing permissions
UPDATE users 
SET can_update_student = 1 
WHERE can_manage_students = 1 OR can_add_student = 1;

-- Verify the changes
SELECT id, username, role, 
       can_manage_students, can_add_student, can_update_student, can_upload_students, can_delete_student
FROM users;

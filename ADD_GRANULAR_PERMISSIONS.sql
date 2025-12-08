-- Add granular permissions to users table
-- Split can_manage_students into specific actions

ALTER TABLE users 
ADD COLUMN can_add_student TINYINT(1) DEFAULT 0 AFTER can_manage_students,
ADD COLUMN can_upload_students TINYINT(1) DEFAULT 0 AFTER can_add_student,
ADD COLUMN can_delete_student TINYINT(1) DEFAULT 0 AFTER can_upload_students,
ADD COLUMN can_delete_user TINYINT(1) DEFAULT 0 AFTER can_manage_passwords;

-- Set default values based on existing can_manage_students permission
-- Users who can manage students get all student permissions
UPDATE users 
SET can_add_student = can_manage_students,
    can_upload_students = can_manage_students,
    can_delete_student = can_manage_students
WHERE can_manage_students = 1;

-- Admins get delete user permission
UPDATE users 
SET can_delete_user = 1 
WHERE role = 'admin' OR can_manage_users = 1;

-- Verify the changes
SELECT id, username, role, 
       can_manage_students, can_add_student, can_upload_students, can_delete_student,
       can_manage_users, can_delete_user
FROM users;

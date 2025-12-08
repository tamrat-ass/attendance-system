-- Add password management permission to users table
ALTER TABLE users 
ADD COLUMN can_manage_passwords TINYINT(1) DEFAULT 0 AFTER can_manage_users;

-- Update existing admins to have password management permission
UPDATE users 
SET can_manage_passwords = 1 
WHERE role = 'admin';

-- Verify the changes
SELECT id, username, role, can_manage_users, can_manage_passwords 
FROM users;

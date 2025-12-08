-- Check if the can_manage_passwords column exists and has data
DESCRIBE users;

-- Check current values
SELECT id, username, role, can_manage_users, can_manage_passwords 
FROM users;

-- If column doesn't exist, add it:
-- ALTER TABLE users ADD COLUMN can_manage_passwords TINYINT(1) DEFAULT 0 AFTER can_manage_users;

-- Set it to 1 for your admin user (replace 'admin' with your username):
-- UPDATE users SET can_manage_passwords = 1 WHERE username = 'admin' OR role = 'admin';

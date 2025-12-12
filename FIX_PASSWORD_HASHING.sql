-- ============================================
-- FIX PASSWORD HASHING FOR MOBILE LOGIN
-- This script updates all plain text passwords to bcrypt hashes
-- ============================================

-- Update admin user password (password123 -> bcrypt hash)
UPDATE users 
SET password_hash = '$2b$10$.F.cL.cIuQZDOtKIvfaUZOVFgO6NnaN888m1psdzBjQ3/8nzuuhBq'
WHERE username = 'admin' AND password_hash = 'password123';

-- Update teacher1 user password (teacher123 -> bcrypt hash)  
UPDATE users 
SET password_hash = '$2b$10$ZQZDGIF0gRHOu32MUOrDlutFc313sg6YCyDxT5zqytZP1GORb/kZe'
WHERE username = 'teacher1' AND password_hash = 'teacher123';

-- Update manager user password (manager123 -> bcrypt hash)
UPDATE users 
SET password_hash = '$2b$10$rglT01g.O17KErtu4aEg3eF4hsU5w1MI3LnwSs/zTWrv19ek7/kGG'
WHERE username = 'manager' AND password_hash = 'manager123';

-- Update any user with password123 (common default)
UPDATE users 
SET password_hash = '$2b$10$.F.cL.cIuQZDOtKIvfaUZOVFgO6NnaN888m1psdzBjQ3/8nzuuhBq'
WHERE password_hash = 'password123';

-- Update any user with user123
UPDATE users 
SET password_hash = '$2b$10$UEX4f2n0B2seeIFVkHsCRuI3X8QIq2yPTDAjzPN.NcJtax/MPCYjS'
WHERE password_hash = 'user123';

-- Show all users after update
SELECT id, username, full_name, role, 
       CASE 
         WHEN password_hash = '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi' THEN 'password123 (hashed)'
         WHEN password_hash = '$2a$10$TKh8H1.PfQx37YgCzwiKb.KjNyWgaHb9cbcoQgdIVFlYg7B77UdFm' THEN 'teacher123/manager123/user123 (hashed)'
         ELSE 'Other password'
       END as password_info
FROM users;

-- ============================================
-- PASSWORD REFERENCE:
-- password123 -> $2b$10$.F.cL.cIuQZDOtKIvfaUZOVFgO6NnaN888m1psdzBjQ3/8nzuuhBq
-- teacher123 -> $2b$10$ZQZDGIF0gRHOu32MUOrDlutFc313sg6YCyDxT5zqytZP1GORb/kZe
-- manager123 -> $2b$10$rglT01g.O17KErtu4aEg3eF4hsU5w1MI3LnwSs/zTWrv19ek7/kGG
-- user123 -> $2b$10$UEX4f2n0B2seeIFVkHsCRuI3X8QIq2yPTDAjzPN.NcJtax/MPCYjS
-- ============================================
-- ============================================
-- NEON DATABASE PASSWORD FIX
-- Run this in your Neon SQL Editor to fix password hashing
-- ============================================

-- Update admin user password (password123 -> bcrypt hash)
UPDATE users 
SET password_hash = '$2b$10$.F.cL.cIuQZDOtKIvfaUZOVFgO6NnaN888m1psdzBjQ3/8nzuuhBq'
WHERE username = 'admin' AND password_hash = 'password123';

-- Update manager user password (manager123 -> bcrypt hash)
UPDATE users 
SET password_hash = '$2b$10$rglT01g.O17KErtu4aEg3eF4hsU5w1MI3LnwSs/zTWrv19ek7/kGG'
WHERE username = 'manager' AND password_hash = 'manager123';

-- Update user1 password (user123 -> bcrypt hash)
UPDATE users 
SET password_hash = '$2b$10$UEX4f2n0B2seeIFVkHsCRuI3X8QIq2yPTDAjzPN.NcJtax/MPCYjS'
WHERE username = 'user1' AND password_hash = 'user123';

-- Update any remaining plain text passwords
UPDATE users 
SET password_hash = '$2b$10$.F.cL.cIuQZDOtKIvfaUZOVFgO6NnaN888m1psdzBjQ3/8nzuuhBq'
WHERE password_hash = 'password123';

UPDATE users 
SET password_hash = '$2b$10$rglT01g.O17KErtu4aEg3eF4hsU5w1MI3LnwSs/zTWrv19ek7/kGG'
WHERE password_hash = 'manager123';

UPDATE users 
SET password_hash = '$2b$10$UEX4f2n0B2seeIFVkHsCRuI3X8QIq2yPTDAjzPN.NcJtax/MPCYjS'
WHERE password_hash = 'user123';

-- Verify the fix
SELECT 
  id, 
  username, 
  full_name, 
  role,
  CASE 
    WHEN LENGTH(password_hash) > 50 THEN 'HASHED ✓'
    ELSE 'PLAIN TEXT ✗'
  END as password_status,
  status
FROM users 
ORDER BY id;

-- ============================================
-- AFTER RUNNING THIS SCRIPT, USE THESE CREDENTIALS:
-- Username: admin     | Password: password123
-- Username: manager   | Password: manager123  
-- Username: user1     | Password: user123
-- ============================================
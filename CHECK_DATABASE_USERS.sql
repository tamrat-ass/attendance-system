-- ============================================
-- CHECK DATABASE USERS STATUS
-- Run this in your Neon SQL Editor to see current user status
-- ============================================

-- Check all users and their password status
SELECT 
  id,
  username,
  full_name,
  role,
  status,
  CASE 
    WHEN LENGTH(password_hash) > 50 THEN '✅ HASHED'
    WHEN LENGTH(password_hash) < 20 THEN '❌ PLAIN TEXT'
    ELSE '⚠️ UNKNOWN'
  END as password_status,
  LEFT(password_hash, 20) || '...' as password_preview
FROM users 
ORDER BY id;

-- Count users by status
SELECT 
  CASE 
    WHEN LENGTH(password_hash) > 50 THEN 'HASHED'
    ELSE 'PLAIN TEXT'
  END as password_type,
  COUNT(*) as count
FROM users 
GROUP BY 
  CASE 
    WHEN LENGTH(password_hash) > 50 THEN 'HASHED'
    ELSE 'PLAIN TEXT'
  END;

-- Show specific users that need fixing
SELECT username, password_hash
FROM users 
WHERE LENGTH(password_hash) < 20
ORDER BY username;
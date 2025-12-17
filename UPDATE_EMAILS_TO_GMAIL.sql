-- =====================================================
-- UPDATE EXISTING STUDENT EMAILS TO GMAIL DOMAIN
-- Run this if you already have students in your database
-- =====================================================

USE attendance_system;

-- =====================================================
-- 1. UPDATE ALL EXISTING STUDENTS TO USE @gmail.com
-- =====================================================

-- Update students who already have emails with different domains
UPDATE students SET 
  email = CONCAT(
    SUBSTRING_INDEX(email, '@', 1), 
    '@gmail.com'
  )
WHERE email IS NOT NULL 
  AND email != '' 
  AND email NOT LIKE '%@gmail.com';

-- =====================================================
-- 2. ADD GMAIL EMAILS FOR STUDENTS WITHOUT EMAILS
-- =====================================================

-- Generate Gmail addresses for students without emails
UPDATE students SET 
  email = CONCAT(
    LOWER(REPLACE(REPLACE(full_name, ' ', '.'), '-', '.')), 
    '@gmail.com'
  )
WHERE email IS NULL OR email = '';

-- =====================================================
-- 3. CLEAN UP DUPLICATE DOTS AND SPECIAL CHARACTERS
-- =====================================================

-- Remove multiple consecutive dots
UPDATE students SET 
  email = REPLACE(REPLACE(email, '..', '.'), '...', '.')
WHERE email LIKE '%.%.%';

-- Remove dots at the beginning of email (before @)
UPDATE students SET 
  email = CONCAT(
    TRIM(LEADING '.' FROM SUBSTRING_INDEX(email, '@', 1)),
    '@gmail.com'
  )
WHERE email LIKE '.%@gmail.com';

-- =====================================================
-- 4. HANDLE SPECIAL CASES FOR ETHIOPIAN NAMES
-- =====================================================

-- Update common Ethiopian name patterns for better email format
UPDATE students SET 
  email = REPLACE(email, 'ä', 'a')
WHERE email LIKE '%ä%';

UPDATE students SET 
  email = REPLACE(email, 'ë', 'e')
WHERE email LIKE '%ë%';

UPDATE students SET 
  email = REPLACE(email, 'ï', 'i')
WHERE email LIKE '%ï%';

UPDATE students SET 
  email = REPLACE(email, 'ö', 'o')
WHERE email LIKE '%ö%';

UPDATE students SET 
  email = REPLACE(email, 'ü', 'u')
WHERE email LIKE '%ü%';

-- =====================================================
-- 5. ENSURE UNIQUE EMAILS (ADD NUMBERS IF DUPLICATES)
-- =====================================================

-- This will add numbers to duplicate emails
SET @row_number = 0;

UPDATE students s1 
JOIN (
  SELECT email, 
         ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) as rn,
         id
  FROM students 
  WHERE email IN (
    SELECT email 
    FROM students 
    GROUP BY email 
    HAVING COUNT(*) > 1
  )
) s2 ON s1.id = s2.id
SET s1.email = CONCAT(
  SUBSTRING_INDEX(s1.email, '@', 1), 
  s2.rn, 
  '@gmail.com'
)
WHERE s2.rn > 1;

-- =====================================================
-- 6. VERIFY RESULTS
-- =====================================================

-- Show updated emails
SELECT id, full_name, email, 
       CASE 
         WHEN email LIKE '%@gmail.com' THEN '✅ Gmail' 
         ELSE '❌ Not Gmail' 
       END as email_status
FROM students 
ORDER BY id;

-- Count students with Gmail addresses
SELECT 
  COUNT(*) as total_students,
  COUNT(CASE WHEN email LIKE '%@gmail.com' THEN 1 END) as gmail_emails,
  COUNT(CASE WHEN email IS NULL OR email = '' THEN 1 END) as no_email
FROM students;

-- Show any potential issues
SELECT id, full_name, email, 'Duplicate Email' as issue
FROM students 
WHERE email IN (
  SELECT email 
  FROM students 
  GROUP BY email 
  HAVING COUNT(*) > 1
)
UNION
SELECT id, full_name, email, 'Invalid Format' as issue
FROM students 
WHERE email NOT REGEXP '^[A-Za-z0-9._%+-]+@gmail\.com$'
  AND email IS NOT NULL 
  AND email != '';

SELECT 'Email update completed! All students now have @gmail.com addresses.' as Status;
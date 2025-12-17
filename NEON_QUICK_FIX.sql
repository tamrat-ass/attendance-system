-- NEON QUICK FIX - Check and fix any email issues
-- Run these commands in your Neon SQL Editor

-- 1. Check if there are any students with NULL or empty emails
SELECT id, full_name, email, 
       CASE 
           WHEN email IS NULL THEN 'NULL'
           WHEN email = '' THEN 'EMPTY'
           WHEN email LIKE '%@gmail.com' THEN 'VALID'
           ELSE 'INVALID'
       END as email_status
FROM students 
ORDER BY id DESC;

-- 2. Count students by email status
SELECT 
    COUNT(CASE WHEN email IS NULL THEN 1 END) as null_emails,
    COUNT(CASE WHEN email = '' THEN 1 END) as empty_emails,
    COUNT(CASE WHEN email LIKE '%@gmail.com' THEN 1 END) as valid_emails,
    COUNT(*) as total_students
FROM students;

-- 3. If there are any NULL or empty emails, fix them
-- UPDATE students 
-- SET email = CONCAT('student', id, '@gmail.com') 
-- WHERE email IS NULL OR email = '';

-- 4. Test a manual insert to see if it works
INSERT INTO students (full_name, phone, class, gender, email) 
VALUES ('Manual Test Student', '0999999999', 'Grade 10', 'Male', 'manualtest@gmail.com');

-- 5. Check if the insert worked
SELECT * FROM students WHERE email = 'manualtest@gmail.com';

-- 6. Clean up the test (optional)
DELETE FROM students WHERE email = 'manualtest@gmail.com';

-- 7. Show the last 5 students to verify data
SELECT id, full_name, phone, email, class, created_at 
FROM students 
ORDER BY id DESC 
LIMIT 5;
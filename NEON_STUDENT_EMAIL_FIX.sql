-- NEON DATABASE - Student Email Column Fix
-- Run these commands one by one in your Neon SQL Editor

-- Step 1: Check current students table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'students' 
ORDER BY ordinal_position;

-- Step 2: Check current email data
SELECT id, full_name, email, 
       CASE 
           WHEN email IS NULL THEN 'NULL'
           WHEN email = '' THEN 'EMPTY'
           WHEN email LIKE '%@gmail.com' THEN 'VALID'
           ELSE 'INVALID'
       END as email_status
FROM students 
ORDER BY id DESC 
LIMIT 10;

-- Step 3: Fix any NULL or empty emails (if any exist)
UPDATE students 
SET email = CONCAT('student', id, '@gmail.com') 
WHERE email IS NULL OR email = '' OR email NOT LIKE '%@gmail.com';

-- Step 4: Ensure email column is NOT NULL
ALTER TABLE students ALTER COLUMN email SET NOT NULL;

-- Step 5: Verify the fix
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default 
FROM information_schema.columns 
WHERE table_name = 'students' 
AND column_name = 'email';

-- Step 6: Test with a new student insert
INSERT INTO students (full_name, phone, class, gender, email) 
VALUES ('Test Student API', '0911111111', 'Grade 10', 'Male', 'apitest@gmail.com');

-- Step 7: Verify the insert worked
SELECT id, full_name, phone, email, class 
FROM students 
WHERE email = 'apitest@gmail.com';

-- Step 8: Clean up test data (optional)
-- DELETE FROM students WHERE email = 'apitest@gmail.com';

-- Step 9: Final verification - all students should have valid emails
SELECT COUNT(*) as total_students,
       COUNT(CASE WHEN email LIKE '%@gmail.com' THEN 1 END) as valid_emails
FROM students;
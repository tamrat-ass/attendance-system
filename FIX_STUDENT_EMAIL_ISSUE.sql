-- Fix Student Email Column Issue - NEON/PostgreSQL Version
-- This script ensures the email column is properly configured for Neon database

-- 1. Check current table structure (PostgreSQL way)
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'students' 
ORDER BY ordinal_position;

-- 2. Check if email column exists and its constraints
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default 
FROM information_schema.columns 
WHERE table_name = 'students' 
AND column_name = 'email';

-- 3. If email column doesn't exist, add it
-- ALTER TABLE students ADD COLUMN email VARCHAR(255);

-- 4. Make email column NOT NULL with default (if needed)
-- First set default for existing NULL values
UPDATE students SET email = 'student@gmail.com' WHERE email IS NULL OR email = '';

-- Then set NOT NULL constraint
ALTER TABLE students ALTER COLUMN email SET NOT NULL;

-- 5. Verify the changes
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default 
FROM information_schema.columns 
WHERE table_name = 'students' 
AND column_name = 'email';

-- 6. Check existing data to make sure all emails are valid
SELECT id, full_name, phone, email, class FROM students ORDER BY id DESC LIMIT 10;

-- 7. Test insert (uncomment to test)
-- INSERT INTO students (full_name, phone, class, gender, email) 
-- VALUES ('Test Student New', '0987654321', 'Grade 10', 'Male', 'testnew@gmail.com');

-- 8. Check for any students with invalid emails
SELECT id, full_name, email 
FROM students 
WHERE email IS NULL 
   OR email = '' 
   OR email NOT LIKE '%@gmail.com';

-- 9. Count total students
SELECT COUNT(*) as total_students FROM students;
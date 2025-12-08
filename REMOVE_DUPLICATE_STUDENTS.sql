-- ============================================
-- REMOVE DUPLICATE STUDENTS FROM DATABASE
-- ============================================
-- This script removes duplicate students based on full_name and phone
-- It keeps the OLDEST record (lowest ID) and deletes the duplicates

-- STEP 1: Check for duplicates BEFORE deletion
-- Run this first to see what duplicates exist
SELECT 
    full_name, 
    phone, 
    COUNT(*) as duplicate_count,
    GROUP_CONCAT(id ORDER BY id) as all_ids
FROM students
GROUP BY full_name, phone
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- STEP 2: See detailed list of duplicate students
-- This shows all duplicate records with their IDs
SELECT s1.*
FROM students s1
INNER JOIN (
    SELECT full_name, phone
    FROM students
    GROUP BY full_name, phone
    HAVING COUNT(*) > 1
) s2 ON s1.full_name = s2.full_name AND s1.phone = s2.phone
ORDER BY s1.full_name, s1.phone, s1.id;

-- STEP 3: DELETE duplicates (keeps the oldest/first record)
-- WARNING: This will permanently delete duplicate records!
-- Make sure to backup your database first!

DELETE s1 FROM students s1
INNER JOIN students s2 
WHERE 
    s1.full_name = s2.full_name 
    AND s1.phone = s2.phone
    AND s1.id > s2.id;

-- STEP 4: Verify duplicates are removed
-- This should return 0 rows if all duplicates are removed
SELECT 
    full_name, 
    phone, 
    COUNT(*) as count
FROM students
GROUP BY full_name, phone
HAVING COUNT(*) > 1;

-- STEP 5: Check total student count
SELECT COUNT(*) as total_students FROM students;

-- ============================================
-- ALTERNATIVE: Delete duplicates but keep the NEWEST record
-- ============================================
-- If you want to keep the newest record instead of oldest, use this:

-- DELETE s1 FROM students s1
-- INNER JOIN students s2 
-- WHERE 
--     s1.full_name = s2.full_name 
--     AND s1.phone = s2.phone
--     AND s1.id < s2.id;

-- ============================================
-- PREVENT FUTURE DUPLICATES
-- ============================================
-- Add a unique constraint to prevent duplicates in the future
-- WARNING: This will fail if duplicates still exist!

-- ALTER TABLE students 
-- ADD UNIQUE KEY unique_student (full_name, phone);

-- ============================================
-- BACKUP BEFORE DELETION (RECOMMENDED)
-- ============================================
-- Create a backup table before deleting duplicates

-- CREATE TABLE students_backup_before_cleanup AS 
-- SELECT * FROM students;

-- After cleanup, you can drop the backup:
-- DROP TABLE students_backup_before_cleanup;

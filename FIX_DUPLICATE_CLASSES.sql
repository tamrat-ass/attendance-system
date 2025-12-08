-- Fix duplicate class names by normalizing to uppercase
-- This will merge all variations like "Class A", "class A", "CLASS A" into "CLASS A"

-- Step 1: See current duplicates
SELECT class, COUNT(*) as count
FROM students
GROUP BY LOWER(class)
HAVING COUNT(*) > 0
ORDER BY LOWER(class);

-- Step 2: Update all class names to uppercase format
UPDATE students
SET class = UPPER(class);

-- Step 3: Verify the fix
SELECT DISTINCT class, COUNT(*) as student_count
FROM students
GROUP BY class
ORDER BY class;

-- Expected result: All classes should now be like "CLASS A", "CLASS B", etc.
-- No more duplicates like "Class A" and "class A"

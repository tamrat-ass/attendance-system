-- Step 1: Check how many students you currently have
SELECT COUNT(*) as total_students FROM students;

-- Step 2: See all students
SELECT * FROM students ORDER BY id;

-- Step 3: Check the auto_increment value
SELECT AUTO_INCREMENT 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'attendance_system' 
AND TABLE_NAME = 'students';

-- Step 4: Check for any triggers
SHOW TRIGGERS WHERE `Table` = 'students';

-- Step 5: Check table engine and charset
SHOW CREATE TABLE students;

-- Step 6: Add a test student manually
INSERT INTO students (full_name, phone, class) 
VALUES ('Test Student 1', '1111111111', 'Test Class');

-- Step 7: Check if it was added
SELECT * FROM students WHERE full_name = 'Test Student 1';

-- Step 8: Add another test student
INSERT INTO students (full_name, phone, class) 
VALUES ('Test Student 2', '2222222222', 'Test Class');

-- Step 9: Check total count again
SELECT COUNT(*) as total_students FROM students;

-- Step 10: View all students to confirm both are there
SELECT id, full_name, phone, class FROM students ORDER BY id;

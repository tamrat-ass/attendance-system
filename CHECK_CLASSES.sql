-- Check all unique classes in the students table
SELECT DISTINCT class, COUNT(*) as student_count
FROM students
GROUP BY class
ORDER BY class;

-- Check all students with their classes
SELECT id, full_name, phone, class, created_at
FROM students
ORDER BY class, id;

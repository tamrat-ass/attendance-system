-- Check for any triggers on students table
SHOW TRIGGERS WHERE `Table` = 'students';

-- Check for foreign key constraints
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE
    TABLE_SCHEMA = 'attendance_system'
    AND (TABLE_NAME = 'students' OR REFERENCED_TABLE_NAME = 'students');

-- Check table structure
DESCRIBE students;

-- Check if there's any CASCADE DELETE
SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME,
    REFERENCED_TABLE_NAME,
    DELETE_RULE,
    UPDATE_RULE
FROM
    INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
WHERE
    CONSTRAINT_SCHEMA = 'attendance_system'
    AND (TABLE_NAME = 'students' OR REFERENCED_TABLE_NAME = 'students');

-- Check the attendance table structure to see allowed status values
USE attendance_system;

-- Check table structure
DESCRIBE attendance;

-- Check if status column has ENUM constraint
SHOW CREATE TABLE attendance;
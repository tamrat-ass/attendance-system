-- Clean up phone numbers by removing dashes and other non-digit characters

-- First, let's see what phone numbers currently look like
SELECT id, full_name, phone, 'BEFORE' as status FROM students ORDER BY id;

-- Remove all non-digit characters from phone numbers
UPDATE students 
SET phone = REGEXP_REPLACE(phone, '[^0-9]', '');

-- Show the cleaned phone numbers
SELECT id, full_name, phone, 'AFTER' as status FROM students ORDER BY id;

-- Optional: Fix any phone numbers that don't start with 09 but should
-- (This is just in case some numbers were stored incorrectly)
SELECT 
    id, 
    full_name, 
    phone,
    CASE 
        WHEN LENGTH(phone) = 10 AND phone LIKE '09%' THEN 'VALID'
        WHEN LENGTH(phone) = 10 AND phone NOT LIKE '09%' THEN 'INVALID_PREFIX'
        WHEN LENGTH(phone) != 10 THEN 'INVALID_LENGTH'
        ELSE 'OTHER'
    END as validation_status
FROM students 
ORDER BY validation_status, id;
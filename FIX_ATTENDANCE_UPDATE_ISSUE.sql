-- Fix Attendance Update Issue in Neon Database
-- Run this in your Neon SQL Editor

-- Step 1: Check if unique constraint exists
SELECT 
    conname as constraint_name,
    contype as constraint_type
FROM pg_constraint 
WHERE conrelid = 'attendance'::regclass;

-- Step 2: If no unique constraint exists, add it
-- First, remove any duplicate records (keep the latest one)
DELETE FROM attendance a1 
USING attendance a2 
WHERE a1.id < a2.id 
  AND a1.student_id = a2.student_id 
  AND a1.date = a2.date;

-- Step 3: Add the unique constraint if it doesn't exist
ALTER TABLE attendance 
ADD CONSTRAINT unique_student_date 
UNIQUE (student_id, date);

-- Step 4: Test the update functionality
-- Insert a test record
INSERT INTO attendance (student_id, date, status, notes) 
VALUES (1, CURRENT_DATE, 'present', 'test record')
ON CONFLICT (student_id, date) 
DO UPDATE SET 
  status = EXCLUDED.status,
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

-- Step 5: Try to update the same record
INSERT INTO attendance (student_id, date, status, notes) 
VALUES (1, CURRENT_DATE, 'absent', 'updated record')
ON CONFLICT (student_id, date) 
DO UPDATE SET 
  status = EXCLUDED.status,
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

-- Step 6: Verify the update worked
SELECT * FROM attendance WHERE student_id = 1 AND date = CURRENT_DATE;

-- Step 7: Clean up test data
DELETE FROM attendance WHERE student_id = 1 AND date = CURRENT_DATE;

-- Verification complete!
SELECT 'Attendance update fix applied successfully!' as result;
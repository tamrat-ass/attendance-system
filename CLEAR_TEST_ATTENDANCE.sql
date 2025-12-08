-- Clear attendance data for testing
-- Run this in phpMyAdmin to reset attendance for date 2025-12-06

DELETE FROM attendance WHERE date = '2025-12-06';

-- Verify it's cleared
SELECT * FROM attendance WHERE date = '2025-12-06';

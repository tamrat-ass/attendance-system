-- Create QR attendance logs table for tracking QR code scans
CREATE TABLE IF NOT EXISTS qr_attendance_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  qr_data TEXT NOT NULL,
  scan_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('success', 'failed', 'duplicate') NOT NULL,
  error_message TEXT,
  scanner_info VARCHAR(255),
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  INDEX idx_student_id (student_id),
  INDEX idx_scan_timestamp (scan_timestamp),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add QR code field to students table for storing generated QR data
ALTER TABLE students ADD COLUMN IF NOT EXISTS qr_code TEXT DEFAULT NULL;

-- Add index on QR code for faster lookups
ALTER TABLE students ADD INDEX IF NOT EXISTS idx_qr_code (qr_code(255));
-- Create email_logs table for tracking email notifications
CREATE TABLE IF NOT EXISTS email_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type ENUM('registration', 'bulk') NOT NULL,
  recipient VARCHAR(255) NOT NULL,
  sender VARCHAR(255) NOT NULL,
  content TEXT,
  status ENUM('success', 'failed') NOT NULL,
  error_message TEXT,
  student_id INT,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE SET NULL,
  INDEX idx_type (type),
  INDEX idx_status (status),
  INDEX idx_timestamp (timestamp),
  INDEX idx_student_id (student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add email column to students table if it doesn't exist
ALTER TABLE students ADD COLUMN IF NOT EXISTS email VARCHAR(255) DEFAULT NULL;

-- Add index on email column for better performance
ALTER TABLE students ADD INDEX IF NOT EXISTS idx_email (email);
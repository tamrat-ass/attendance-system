-- Create user activity logs table (tracks ALL user actions)
-- Run this in phpMyAdmin or MySQL command line

USE attendance_system;

-- Drop old table if exists and create new one
DROP TABLE IF EXISTS admin_logs;

-- Create user_logs table (renamed from admin_logs to track all users)
CREATE TABLE IF NOT EXISTS user_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  username VARCHAR(100) NOT NULL,
  action VARCHAR(255) NOT NULL,
  target_type VARCHAR(50),
  target_id INT,
  details TEXT,
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_created_at (created_at),
  INDEX idx_action (action)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Verify the table was created
DESCRIBE user_logs;

-- Sample query to view logs
SELECT * FROM user_logs ORDER BY created_at DESC LIMIT 10;

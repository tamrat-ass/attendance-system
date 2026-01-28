-- Active Sessions Management Table
-- This table tracks all active user sessions for security and management purposes

USE attendance_system;

-- Create active_sessions table
CREATE TABLE IF NOT EXISTS active_sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  session_id VARCHAR(255) UNIQUE NOT NULL,
  user_id INT NOT NULL,
  username VARCHAR(100) NOT NULL,
  login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ip_address VARCHAR(45),
  user_agent TEXT,
  device_info VARCHAR(255),
  browser_info VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  logout_time TIMESTAMP NULL,
  logout_type ENUM('normal', 'forced', 'expired') NULL,
  forced_by_user_id INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (forced_by_user_id) REFERENCES users(id) ON DELETE SET NULL,
  
  INDEX idx_session_id (session_id),
  INDEX idx_user_id (user_id),
  INDEX idx_is_active (is_active),
  INDEX idx_last_activity (last_activity),
  INDEX idx_login_time (login_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create session_audit_logs table for tracking session actions
CREATE TABLE IF NOT EXISTS session_audit_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  session_id VARCHAR(255) NOT NULL,
  user_id INT NOT NULL,
  action ENUM('login', 'logout', 'force_logout', 'session_expired', 'activity_update') NOT NULL,
  performed_by_user_id INT NULL,
  ip_address VARCHAR(45),
  user_agent TEXT,
  details TEXT,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (performed_by_user_id) REFERENCES users(id) ON DELETE SET NULL,
  
  INDEX idx_session_id (session_id),
  INDEX idx_user_id (user_id),
  INDEX idx_action (action),
  INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add session management permissions to users table if not exists
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS can_manage_sessions BOOLEAN DEFAULT FALSE;

-- Grant session management permission to admin users
UPDATE users SET can_manage_sessions = TRUE WHERE role = 'admin';

-- Clean up expired sessions (older than 24 hours)
DELETE FROM active_sessions 
WHERE last_activity < DATE_SUB(NOW(), INTERVAL 24 HOUR) 
   OR (is_active = FALSE AND logout_time < DATE_SUB(NOW(), INTERVAL 7 DAY));

COMMIT;
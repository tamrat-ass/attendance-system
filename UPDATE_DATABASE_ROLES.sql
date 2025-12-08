-- Update database for role management system
-- Run this in phpMyAdmin or MySQL command line

USE attendance_system;

-- Drop existing users table if you want to start fresh
-- WARNING: This will delete all existing users!
-- DROP TABLE IF EXISTS users;

-- Modify users table to add new columns
ALTER TABLE users 
  ADD COLUMN IF NOT EXISTS username VARCHAR(100) UNIQUE AFTER id,
  ADD COLUMN IF NOT EXISTS full_name VARCHAR(255) AFTER email,
  MODIFY COLUMN role ENUM('admin', 'manager', 'user') DEFAULT 'user',
  ADD COLUMN IF NOT EXISTS status ENUM('active', 'inactive') DEFAULT 'active' AFTER role;

-- Add unique constraint on username if not exists
ALTER TABLE users ADD UNIQUE INDEX idx_username (username);

-- Update existing users to have usernames (if they don't have one)
UPDATE users SET username = SUBSTRING_INDEX(email, '@', 1) WHERE username IS NULL OR username = '';

-- Insert default admin, manager, and user accounts
-- Password is 'password123' (in production, this should be hashed!)
INSERT INTO users (username, email, password_hash, full_name, role, status) VALUES
('admin', 'admin@example.com', 'password123', 'System Administrator', 'admin', 'active'),
('manager', 'manager@example.com', 'password123', 'Manager User', 'manager', 'active'),
('user', 'user@example.com', 'password123', 'Regular User', 'user', 'active')
ON DUPLICATE KEY UPDATE 
  role = VALUES(role),
  status = VALUES(status),
  full_name = VALUES(full_name);

-- Verify the changes
SELECT id, username, email, full_name, role, status, created_at FROM users;

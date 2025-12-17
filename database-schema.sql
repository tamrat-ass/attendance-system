-- Attendance System Database Schema
-- Run this in phpMyAdmin or MySQL command line

-- Create database (if not already created)
CREATE DATABASE IF NOT EXISTS attendance_system;
USE attendance_system;

-- Students table
CREATE TABLE IF NOT EXISTS students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  class VARCHAR(100) NOT NULL,
  gender VARCHAR(10) DEFAULT 'Male',
  email VARCHAR(255) NOT NULL,
  qr_code TEXT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_qr_code (qr_code(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Users table (for authentication)
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255),
  role ENUM('admin', 'manager', 'user') DEFAULT 'user',
  status ENUM('active', 'inactive') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Recovery codes table (for password recovery)
CREATE TABLE IF NOT EXISTS recovery_codes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  code VARCHAR(6) NOT NULL,
  email VARCHAR(255) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  used_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Attendance table
CREATE TABLE IF NOT EXISTS attendance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  date DATE NOT NULL,
  status ENUM('present', 'absent', 'late', 'permission') NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  UNIQUE KEY unique_attendance (student_id, date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample data for testing
INSERT INTO students (full_name, phone, class, gender, email) VALUES
('Ahmed Ali', '09012345678', 'Grade 10-A', 'Male', 'ahmed.ali@gmail.com'),
('Fatima Hassan', '09098765432', 'Grade 10-B', 'Female', 'fatima.hassan@gmail.com'),
('Mohamed Ibrahim', '09123456789', 'Grade 11-A', 'Male', 'mohamed.ibrahim@gmail.com'),
('Sara Ahmed', '09234567890', 'Grade 11-B', 'Female', 'sara.ahmed@gmail.com'),
('Omar Khaled', '09156789012', 'Grade 12-A', 'Male', 'omar.khaled@gmail.com');

-- Email logs table (for tracking email notifications)
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

-- QR attendance logs table (for tracking QR code scans)
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

-- Insert test users (password: 'password123' - you should hash this in production)
INSERT INTO users (username, email, password_hash, full_name, role, status) VALUES
('admin', 'admin@example.com', 'password123', 'System Administrator', 'admin', 'active'),
('manager', 'manager@example.com', 'password123', 'Manager User', 'manager', 'active'),
('user', 'user@example.com', 'password123', 'Regular User', 'user', 'active');

-- Super simple setup after cleaning
CREATE DATABASE attendance_system;
USE attendance_system;

-- Create users table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    role VARCHAR(20) DEFAULT 'user'
);

-- Insert admin
INSERT INTO users (username, password_hash, full_name, role) 
VALUES ('admin', 'password123', 'Administrator', 'admin');

-- Test
SELECT * FROM users;
SHOW TABLES;
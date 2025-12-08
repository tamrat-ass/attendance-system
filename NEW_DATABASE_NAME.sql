-- Use a different database name to avoid conflicts
CREATE DATABASE attendance_app;
USE attendance_app;

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

-- Create students table
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    class VARCHAR(100) NOT NULL
);

-- Test
SELECT * FROM users;
SHOW TABLES;
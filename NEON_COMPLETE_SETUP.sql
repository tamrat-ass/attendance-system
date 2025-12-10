-- ============================================
-- NEON DATABASE COMPLETE SETUP
-- Run this entire file in Neon SQL Editor
-- ============================================

-- Step 1: Drop existing tables if any
DROP TABLE IF EXISTS user_logs CASCADE;
DROP TABLE IF EXISTS attendance CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS classes CASCADE;

-- Step 2: Create classes table
CREATE TABLE classes (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 3: Create students table
CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  class VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 4: Create users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE,
  full_name VARCHAR(255),
  role VARCHAR(20) DEFAULT 'user',
  status VARCHAR(20) DEFAULT 'active',
  can_manage_students BOOLEAN DEFAULT TRUE,
  can_add_student BOOLEAN DEFAULT TRUE,
  can_update_student BOOLEAN DEFAULT TRUE,
  can_upload_students BOOLEAN DEFAULT TRUE,
  can_delete_student BOOLEAN DEFAULT FALSE,
  can_mark_attendance BOOLEAN DEFAULT TRUE,
  can_view_reports BOOLEAN DEFAULT FALSE,
  can_export_data BOOLEAN DEFAULT FALSE,
  can_manage_users BOOLEAN DEFAULT FALSE,
  can_delete_user BOOLEAN DEFAULT FALSE,
  can_manage_passwords BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 5: Create attendance table
CREATE TABLE attendance (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL,
  date DATE NOT NULL,
  status VARCHAR(20) NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  UNIQUE(student_id, date)
);

-- Step 6: Create user_logs table
CREATE TABLE user_logs (
  id SERIAL PRIMARY KEY,
  user_id INTEGER,
  username VARCHAR(50),
  action VARCHAR(100) NOT NULL,
  details TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Step 7: Create indexes
CREATE INDEX idx_classes_name ON classes(name);
CREATE INDEX idx_students_class ON students(class);
CREATE INDEX idx_attendance_date ON attendance(date);
CREATE INDEX idx_attendance_student ON attendance(student_id);

-- Step 8: Insert default classes
INSERT INTO classes (name, description) VALUES 
('Grade 1', 'First Grade Class'),
('Grade 2', 'Second Grade Class'),
('Grade 3', 'Third Grade Class'),
('Grade 4', 'Fourth Grade Class'),
('Grade 5', 'Fifth Grade Class'),
('Grade 6', 'Sixth Grade Class'),
('Grade 7', 'Seventh Grade Class'),
('Grade 8', 'Eighth Grade Class');

-- Step 9: Insert admin user
INSERT INTO users (
  username, password_hash, email, full_name, role,
  can_manage_students, can_add_student, can_update_student, can_upload_students,
  can_delete_student, can_mark_attendance, can_view_reports, can_export_data,
  can_manage_users, can_delete_user, can_manage_passwords
) VALUES (
  'admin', 'password123', 'admin@example.com', 'Administrator', 'admin',
  TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE
);

-- Step 10: Insert manager user
INSERT INTO users (
  username, password_hash, email, full_name, role,
  can_manage_students, can_add_student, can_update_student, can_upload_students,
  can_delete_student, can_mark_attendance, can_view_reports, can_export_data,
  can_manage_users, can_delete_user, can_manage_passwords
) VALUES (
  'manager', 'manager123', 'manager@example.com', 'Manager', 'manager',
  TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE
);

-- Step 11: Insert regular user
INSERT INTO users (
  username, password_hash, email, full_name, role,
  can_manage_students, can_add_student, can_update_student, can_upload_students,
  can_delete_student, can_mark_attendance, can_view_reports, can_export_data,
  can_manage_users, can_delete_user, can_manage_passwords
) VALUES (
  'user1', 'user123', 'user@example.com', 'Regular User', 'user',
  TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE
);

-- Step 12: Insert sample students
INSERT INTO students (full_name, phone, class) VALUES 
('Abebe Kebede', '0911234567', 'Grade 1'),
('Almaz Haile', '0922345678', 'Grade 1'),
('Dawit Tesfaye', '0933456789', 'Grade 2'),
('Hanan Mohammed', '0944567890', 'Grade 2'),
('Kidist Girma', '0955678901', 'Grade 3'),
('Meron Desta', '0966789012', 'Grade 3'),
('Natnael Yohannes', '0977890123', 'Grade 4'),
('Rahel Mulugeta', '0988901234', 'Grade 4'),
('Samuel Getachew', '0999012345', 'Grade 5'),
('Tigist Assefa', '0900123456', 'Grade 5'),
('Yonas Berhe', '0911234568', 'Grade 6'),
('Zara Abdella', '0922345679', 'Grade 6'),
('Biniam Tekle', '0933456780', 'Grade 7'),
('Danait Mehari', '0944567891', 'Grade 7'),
('Ephrem Tadele', '0955678902', 'Grade 8'),
('Feven Solomon', '0966789013', 'Grade 8'),
('Getnet Alemu', '0977890124', 'Grade 1'),
('Helen Tsegaye', '0988901235', 'Grade 2'),
('Israel Berhanu', '0999012346', 'Grade 3'),
('Jemila Seid', '0900123457', 'Grade 4');

-- Verify setup
SELECT 'Setup Complete!' as status;
SELECT COUNT(*) as total_classes FROM classes;
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_students FROM students;
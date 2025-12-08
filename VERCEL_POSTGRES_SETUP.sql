-- ============================================
-- VERCEL POSTGRES DATABASE SETUP
-- Perfect for Vercel deployment + 100% FREE
-- Complete with all 5 tables matching local database
-- ============================================

-- Create classes table
CREATE TABLE classes (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create students table
CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  class VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE,
  full_name VARCHAR(255),
  role VARCHAR(20) DEFAULT 'user',
  status VARCHAR(20) DEFAULT 'active',
  
  -- Permissions (using BOOLEAN for efficiency)
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

-- Create attendance table
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

-- Create user_logs table (simplified for storage efficiency)
CREATE TABLE user_logs (
  id SERIAL PRIMARY KEY,
  user_id INTEGER,
  username VARCHAR(50),
  action VARCHAR(100) NOT NULL,
  details TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Create essential indexes only (to save space)
CREATE INDEX idx_classes_name ON classes(name);
CREATE INDEX idx_students_class ON students(class);
CREATE INDEX idx_attendance_date ON attendance(date);
CREATE INDEX idx_attendance_student ON attendance(student_id);

-- Insert default classes
INSERT INTO classes (name, description) VALUES 
('Grade 1', 'First Grade Class'),
('Grade 2', 'Second Grade Class'),
('Grade 3', 'Third Grade Class'),
('Grade 4', 'Fourth Grade Class'),
('Grade 5', 'Fifth Grade Class'),
('Grade 6', 'Sixth Grade Class'),
('Grade 7', 'Seventh Grade Class'),
('Grade 8', 'Eighth Grade Class');

-- Insert admin user
INSERT INTO users (
  username, password_hash, email, full_name, role,
  can_manage_students, can_add_student, can_update_student, can_upload_students,
  can_delete_student, can_mark_attendance, can_view_reports, can_export_data,
  can_manage_users, can_delete_user, can_manage_passwords
) VALUES (
  'admin', 'password123', 'admin@example.com', 'Administrator', 'admin',
  TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE
);

-- Insert manager user (instead of teacher)
INSERT INTO users (
  username, password_hash, email, full_name, role,
  can_manage_students, can_add_student, can_update_student, can_upload_students,
  can_delete_student, can_mark_attendance, can_view_reports, can_export_data,
  can_manage_users, can_delete_user, can_manage_passwords
) VALUES (
  'manager', 'manager123', 'manager@example.com', 'Manager', 'manager',
  TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE
);

-- Insert regular user
INSERT INTO users (
  username, password_hash, email, full_name, role,
  can_manage_students, can_add_student, can_update_student, can_upload_students,
  can_delete_student, can_mark_attendance, can_view_reports, can_export_data,
  can_manage_users, can_delete_user, can_manage_passwords
) VALUES (
  'user1', 'user123', 'user@example.com', 'Regular User', 'user',
  TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE
);

-- Insert sample Ethiopian students
INSERT INTO students (full_name, phone, class) VALUES 
('Abebe Kebede Tadesse', '+251911234567', 'Grade 1'),
('Almaz Haile Mariam', '+251922345678', 'Grade 1'),
('Dawit Tesfaye Wolde', '+251933456789', 'Grade 2'),
('Hanan Mohammed Ali', '+251944567890', 'Grade 2'),
('Kidist Girma Bekele', '+251955678901', 'Grade 3'),
('Meron Desta Amare', '+251966789012', 'Grade 3'),
('Natnael Yohannes Gebre', '+251977890123', 'Grade 4'),
('Rahel Mulugeta Teshome', '+251988901234', 'Grade 4'),
('Samuel Getachew Negash', '+251999012345', 'Grade 5'),
('Tigist Assefa Lemma', '+251900123456', 'Grade 5'),
('Yonas Berhe Kahsay', '+251911234568', 'Grade 6'),
('Zara Abdella Hussein', '+251922345679', 'Grade 6'),
('Biniam Tekle Hagos', '+251933456780', 'Grade 7'),
('Danait Mehari Gebru', '+251944567891', 'Grade 7'),
('Ephrem Tadele Worku', '+251955678902', 'Grade 8'),
('Feven Solomon Desta', '+251966789013', 'Grade 8'),
('Getnet Alemu Shiferaw', '+251977890124', 'Grade 1'),
('Helen Tsegaye Molla', '+251988901235', 'Grade 2'),
('Israel Berhanu Tilahun', '+251999012346', 'Grade 3'),
('Jemila Seid Ahmed', '+251900123457', 'Grade 4');

-- Verify all tables were created
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Show student count
SELECT 
  class,
  COUNT(*) as student_count
FROM students 
GROUP BY class 
ORDER BY class;

-- Show setup completion
SELECT 'Complete setup with all 5 tables and 20 Ethiopian students completed successfully!' as status;
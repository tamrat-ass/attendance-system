-- ============================================
-- SUPABASE (PostgreSQL) DATABASE SETUP
-- 100% FREE FOREVER
-- ============================================

-- Create students table
CREATE TABLE IF NOT EXISTS students (
  id SERIAL PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  class VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE,
  full_name VARCHAR(255),
  role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('admin', 'manager', 'user')),
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  
  -- Permissions
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
CREATE TABLE IF NOT EXISTS attendance (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  status VARCHAR(20) NOT NULL CHECK (status IN ('present', 'absent', 'late', 'permission')),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(student_id, date)
);

-- Create user logs table
CREATE TABLE IF NOT EXISTS user_logs (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  username VARCHAR(50),
  action VARCHAR(100) NOT NULL,
  target_type VARCHAR(50),
  target_id INTEGER,
  details TEXT,
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_students_class ON students(class);
CREATE INDEX IF NOT EXISTS idx_students_name ON students(full_name);
CREATE INDEX IF NOT EXISTS idx_attendance_date ON attendance(date);
CREATE INDEX IF NOT EXISTS idx_attendance_student_date ON attendance(student_id, date);
CREATE INDEX IF NOT EXISTS idx_user_logs_user_id ON user_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_user_logs_created_at ON user_logs(created_at);

-- Insert default admin user
INSERT INTO users (
  username, password_hash, email, full_name, role, status,
  can_manage_students, can_add_student, can_update_student, can_upload_students,
  can_delete_student, can_mark_attendance, can_view_reports, can_export_data,
  can_manage_users, can_delete_user, can_manage_passwords
) VALUES (
  'admin', 'password123', 'admin@example.com', 'System Administrator', 'admin', 'active',
  TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE
) ON CONFLICT (username) DO NOTHING;

-- Insert sample teacher
INSERT INTO users (
  username, password_hash, email, full_name, role, status,
  can_manage_students, can_add_student, can_update_student, can_upload_students,
  can_delete_student, can_mark_attendance, can_view_reports, can_export_data,
  can_manage_users, can_delete_user, can_manage_passwords
) VALUES (
  'teacher1', 'teacher123', 'teacher@example.com', 'John Teacher', 'user', 'active',
  TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE
) ON CONFLICT (username) DO NOTHING;

-- Insert sample students
INSERT INTO students (full_name, phone, class) VALUES
('Alice Johnson', '1234567890', 'Grade 10-A'),
('Bob Smith', '2345678901', 'Grade 10-A'),
('Carol Davis', '3456789012', 'Grade 10-B'),
('David Wilson', '4567890123', 'Grade 11-A'),
('Emma Brown', '5678901234', 'Grade 11-B')
ON CONFLICT DO NOTHING;

-- Show table counts
SELECT 'users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'students' as table_name, COUNT(*) as count FROM students
UNION ALL
SELECT 'attendance' as table_name, COUNT(*) as count FROM attendance;
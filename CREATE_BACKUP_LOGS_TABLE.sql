-- Backup logs table for tracking backup operations
CREATE TABLE IF NOT EXISTS backup_logs (
  id SERIAL PRIMARY KEY,
  backup_type VARCHAR(50) NOT NULL DEFAULT 'google_sheets',
  status VARCHAR(20) NOT NULL CHECK (status IN ('success', 'failed', 'in_progress')),
  students_count INTEGER DEFAULT 0,
  attendance_count INTEGER DEFAULT 0,
  error_message TEXT,
  duration_ms INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Note: Indexes will be created separately for PostgreSQL
);

-- Create indexes for performance (PostgreSQL syntax)
CREATE INDEX IF NOT EXISTS idx_backup_status ON backup_logs(status);
CREATE INDEX IF NOT EXISTS idx_backup_created_at ON backup_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_backup_type ON backup_logs(backup_type);

-- Insert initial log entry
INSERT INTO backup_logs (backup_type, status, students_count, attendance_count, error_message) 
VALUES ('google_sheets', 'success', 0, 0, 'Backup system initialized');

-- View recent backup history
CREATE OR REPLACE VIEW recent_backups AS
SELECT 
  id,
  backup_type,
  status,
  students_count,
  attendance_count,
  error_message,
  duration_ms,
  created_at,
  CASE 
    WHEN status = 'success' THEN '✅'
    WHEN status = 'failed' THEN '❌'
    ELSE '🔄'
  END as status_icon
FROM backup_logs 
ORDER BY created_at DESC 
LIMIT 20;
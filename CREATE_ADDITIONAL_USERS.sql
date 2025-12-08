-- Create additional users for testing
-- Run these commands in phpMyAdmin one by one

-- 1. Create a Manager user
INSERT INTO users (username, password_hash, full_name, role, can_manage_students, can_mark_attendance, can_view_reports, can_manage_users) 
VALUES ('manager', 'manager123', 'Manager User', 'user', TRUE, TRUE, TRUE, FALSE);

-- 2. Create Regular User 1
INSERT INTO users (username, password_hash, full_name, role, can_manage_students, can_mark_attendance, can_view_reports, can_manage_users) 
VALUES ('user1', 'user123', 'Regular User 1', 'user', FALSE, TRUE, FALSE, FALSE);

-- 3. Create Regular User 2
INSERT INTO users (username, password_hash, full_name, role, can_manage_students, can_mark_attendance, can_view_reports, can_manage_users) 
VALUES ('user2', 'user123', 'Regular User 2', 'user', FALSE, TRUE, FALSE, FALSE);

-- 4. Check all users
SELECT id, username, full_name, role, can_manage_students, can_mark_attendance, can_view_reports, can_manage_users FROM users;
-- Check current user permissions
SELECT 
    id,
    username,
    role,
    can_manage_students,
    can_add_student,
    can_update_student,
    can_upload_students,
    can_delete_student,
    can_mark_attendance,
    can_view_reports,
    can_export_data,
    can_manage_users,
    can_delete_user,
    can_manage_passwords
FROM users 
ORDER BY id;

-- Check if can_update_student column exists
DESCRIBE users;
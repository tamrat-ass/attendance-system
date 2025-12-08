# Granular Permissions Implementation - TODO

## Status: IN PROGRESS

### ✅ Completed
1. Created SQL script (`ADD_GRANULAR_PERMISSIONS.sql`)
2. Updated User interface with new permission fields
3. Updated formData state with new permissions
4. Created DEFAULT_FORM_DATA constant
5. Updated formData reset locations (handleAddUser, handleUpdateUser, cancelEdit)
6. Updated startEdit to include new permissions

### 🔄 Remaining Tasks

#### 1. Frontend - Admin Panel UI
- [ ] Add 4 new permission switches in the permissions section:
  - Add Student (individual)
  - Upload Students (bulk CSV)
  - Delete Student
  - Delete User

#### 2. Backend - API Routes
- [ ] Update `app/api/admin/users/route.ts` (GET and POST)
- [ ] Update `app/api/admin/users/[id]/route.ts` (PUT)
- [ ] Update `app/api/auth/login/route.ts`
- [ ] Update `app/api/auth/refresh-permissions/route.ts`

#### 3. Permission Enforcement
- [ ] Update student management component to check permissions
- [ ] Hide/disable "Add Student" button based on `can_add_student`
- [ ] Hide/disable "Upload CSV" button based on `can_upload_students`
- [ ] Hide/disable "Delete" button based on `can_delete_student`
- [ ] Hide/disable "Delete User" button based on `can_delete_user`

#### 4. Database
- [ ] Run `ADD_GRANULAR_PERMISSIONS.sql` to add columns

## New Permissions Breakdown

| Old Permission | New Permissions | Description |
|---|---|---|
| `can_manage_students` | `can_add_student` | Add individual students |
| | `can_upload_students` | Bulk upload via CSV |
| | `can_delete_student` | Delete students |
| `can_manage_users` | `can_delete_user` | Delete users (separate from manage) |

## Notes
- `can_manage_students` will remain for backward compatibility
- Users with `can_manage_students=1` will get all student permissions by default
- Admins will get `can_delete_user=1` by default

## Next Steps
1. Run the SQL script
2. Add UI switches for new permissions
3. Update all API routes
4. Implement permission checks in components
5. Test thoroughly

Would you like me to continue with the remaining tasks?

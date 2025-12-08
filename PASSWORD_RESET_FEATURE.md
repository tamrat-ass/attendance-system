# Password Reset Feature - Complete Implementation

## Overview
Implemented a permission-based password reset system where only users with `can_manage_passwords` permission can reset other users' passwords.

## Features Implemented

### 1. Permission-Based Access Control
- **Password field visibility**: Only shown to users with `can_manage_passwords` permission when editing users
- **New user creation**: Password field always shown (required for new users)
- **Permission denied message**: Users without permission see a clear message

### 2. Activity Logging
- **Password reset actions** are logged separately with action type `RESET_PASSWORD`
- **Log details include**:
  - Who performed the reset (admin user)
  - Target user whose password was reset
  - Timestamp
  - IP address (if available)

### 3. User Experience
- **Visual indicator**: 🔑 icon shows when password field is for resetting
- **Helper text**: Reminds users that password changes are logged
- **Optional field**: When editing, password can be left blank to keep current password
- **Required field**: When creating new users, password is required

## How It Works

### For Admins (with can_manage_passwords = 1)
1. Go to Admin Panel → Manage Users
2. Click Edit on any user
3. See the password field with reset indicator
4. Enter new password (or leave blank to keep current)
5. Click Update User
6. Action is logged in Activity Logs as "RESET_PASSWORD"

### For Users Without Permission (can_manage_passwords = 0)
1. Go to Admin Panel → Manage Users
2. Click Edit on any user
3. Password field is hidden
4. See message: "You don't have permission to change user passwords"
5. Can still update other user details and permissions

## Activity Log Entries

When a password is reset, TWO log entries are created:

1. **RESET_PASSWORD** action:
   ```
   Action: RESET_PASSWORD
   Details: Reset password for user: [username]
   ```

2. **UPDATE_USER** action (includes password reset note):
   ```
   Action: UPDATE_USER
   Details: Updated user: [username] (role) - Permissions: [...] | Password Reset
   ```

## Testing

1. **Test with admin user**:
   - Login as admin
   - Edit a user
   - Change password
   - Check Activity Logs for RESET_PASSWORD entry

2. **Test without permission**:
   - Create a user with `can_manage_passwords = 0`
   - Login as that user
   - Try to edit another user
   - Verify password field is hidden

3. **Verify logging**:
   ```sql
   SELECT * FROM admin_logs 
   WHERE action = 'RESET_PASSWORD' 
   ORDER BY created_at DESC;
   ```

## Security Notes

⚠️ **Important**: In production, you should:
1. Hash passwords using bcrypt or similar
2. Add password strength requirements
3. Consider adding password reset confirmation
4. Send email notifications when passwords are changed
5. Implement password history to prevent reuse

## Database Schema

```sql
-- Users table includes:
can_manage_passwords TINYINT(1) DEFAULT 0

-- Admin logs table tracks:
action = 'RESET_PASSWORD'
target_type = 'user'
target_id = [user_id]
details = 'Reset password for user: [username]'
```

## Files Modified

1. `components/dashboard/admin-panel.tsx`
   - Added conditional password field rendering
   - Added password reset logging
   - Added permission check UI

2. `app/api/admin/users/[id]/route.ts`
   - Already handles password updates
   - Logs are created from frontend

3. Database
   - `can_manage_passwords` column added to users table

## Default Permissions

- **Admin role**: `can_manage_passwords = 1` (enabled)
- **Manager role**: `can_manage_passwords = 0` (disabled)
- **User role**: `can_manage_passwords = 0` (disabled)

Admins can grant this permission to specific users as needed.

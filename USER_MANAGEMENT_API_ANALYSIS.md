# User Management API Analysis & Issues

## Current API Endpoints

### 1. **GET /api/admin/users** - List All Users
- **Status**: ✅ Working
- **Returns**: All users with permissions
- **Issues**: Expects granular permissions that may not exist in DB

### 2. **POST /api/admin/users** - Create New User
- **Status**: ⚠️ Partial Issues
- **Issues**: 
  - Uses granular permissions that may not exist
  - Password is stored as plain text (security issue)
  - Missing validation for some fields

### 3. **PUT /api/admin/users/[id]** - Update User
- **Status**: ⚠️ Has Issues
- **Issues**:
  - Complex permission handling
  - Expects `can_update_student` field that may not exist
  - Password update without hashing
  - Verbose logging that could expose sensitive data

### 4. **DELETE /api/admin/users/[id]** - Delete User
- **Status**: ✅ Working
- **Issues**: None major

### 5. **POST /api/admin/users/[id]/reset-password** - Reset Password
- **Status**: ⚠️ Security Issue
- **Issues**: Password stored as plain text

### 6. **POST /api/auth/change-password** - Self-Service Password Change
- **Status**: ⚠️ Security Issue
- **Issues**: Password comparison and storage in plain text

## Database Schema Issues

### Missing Permissions Columns
The API expects these permissions that may not exist:
- `can_update_student`
- `can_add_student` 
- `can_upload_students`
- `can_delete_student`
- `can_mark_attendance`
- `can_view_reports`
- `can_export_data`
- `can_manage_users`
- `can_delete_user`
- `can_manage_passwords`

### Security Issues
1. **Plain Text Passwords**: All password operations store/compare plain text
2. **No Password Hashing**: Critical security vulnerability
3. **Verbose Logging**: Sensitive data in console logs

## Recommended Fixes

### 1. Database Schema Update
```sql
-- Add missing permission columns
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS can_add_student TINYINT(1) DEFAULT 1,
ADD COLUMN IF NOT EXISTS can_update_student TINYINT(1) DEFAULT 1,
ADD COLUMN IF NOT EXISTS can_upload_students TINYINT(1) DEFAULT 1,
ADD COLUMN IF NOT EXISTS can_delete_student TINYINT(1) DEFAULT 0,
ADD COLUMN IF NOT EXISTS can_mark_attendance TINYINT(1) DEFAULT 1,
ADD COLUMN IF NOT EXISTS can_view_reports TINYINT(1) DEFAULT 0,
ADD COLUMN IF NOT EXISTS can_export_data TINYINT(1) DEFAULT 0,
ADD COLUMN IF NOT EXISTS can_manage_users TINYINT(1) DEFAULT 0,
ADD COLUMN IF NOT EXISTS can_delete_user TINYINT(1) DEFAULT 0,
ADD COLUMN IF NOT EXISTS can_manage_passwords TINYINT(1) DEFAULT 0;
```

### 2. Password Security
- Implement bcrypt or similar hashing
- Hash passwords before storage
- Compare hashed passwords for authentication

### 3. API Improvements
- Add proper validation
- Remove sensitive logging
- Implement proper error handling
- Add rate limiting for password operations

### 4. Permission Management
- Set default permissions based on role
- Implement role-based permission inheritance
- Add permission validation

## Flutter App Compatibility

The Flutter app expects these API methods:
- `getUsers()` - ✅ Compatible
- `createUser()` - ⚠️ Needs permission handling
- `updateUser()` - ⚠️ Needs permission handling  
- `deleteUser()` - ✅ Compatible
- `resetUserPassword()` - ⚠️ Needs security fix
- `changePassword()` - ⚠️ Needs security fix

## Priority Fixes

### High Priority (Security)
1. Implement password hashing
2. Fix plain text password storage
3. Remove sensitive logging

### Medium Priority (Functionality)
1. Add missing permission columns
2. Fix permission handling in APIs
3. Improve validation

### Low Priority (Enhancement)
1. Add rate limiting
2. Improve error messages
3. Add audit logging
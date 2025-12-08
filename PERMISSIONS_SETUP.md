# User Permissions Setup Guide

## Overview
The admin panel now includes granular permission controls for each user. Admins can enable/disable specific features for individual users using toggle switches.

## Available Permissions

1. **Manage Students** - Add, edit, and delete students
2. **Mark Attendance** - Record student attendance
3. **View Reports** - Access attendance reports and analytics
4. **Export Data** - Download reports and student data
5. **Manage Users** - Access admin panel and manage users

## Setup Instructions

### Step 1: Update Database Schema
Run the SQL script to add permission columns to your database:

```bash
# Open phpMyAdmin: http://localhost/phpmyadmin
# Select your database: attendance_system
# Go to SQL tab and run the contents of: UPDATE_DATABASE_PERMISSIONS.sql
```

This will:
- Add 5 new permission columns to the users table
- Set default permissions based on user roles
- Update existing users with appropriate permissions

### Step 2: Test the Application

1. Start your development server:
   ```bash
   npm run dev
   ```

2. Login as admin:
   - Username: `admin`
   - Password: `password123`

3. Go to Admin Panel and test:
   - Create a new user with custom permissions
   - Edit existing users and toggle their permissions
   - Verify permissions are saved correctly

## Default Permissions by Role

### Admin
- ✅ Manage Students
- ✅ Mark Attendance
- ✅ View Reports
- ✅ Export Data
- ✅ Manage Users

### Manager
- ✅ Manage Students
- ✅ Mark Attendance
- ✅ View Reports
- ✅ Export Data
- ❌ Manage Users

### User
- ❌ Manage Students
- ✅ Mark Attendance
- ❌ View Reports
- ❌ Export Data
- ❌ Manage Users

## How to Use

1. **Login as Admin** - Only admins can access the admin panel
2. **Navigate to Admin Panel** - Click on the admin panel menu
3. **Add/Edit User** - Go to "Add User" or "Edit User" tab
4. **Set Permissions** - Use the toggle switches in the "Permissions" section
5. **Save** - Click "Add User" or "Update User" to save changes

## Files Modified

- `components/dashboard/admin-panel.tsx` - Added permission toggles
- `app/api/admin/users/route.ts` - Added permission fields to GET/POST
- `app/api/admin/users/[id]/route.ts` - Added permission fields to PUT
- `UPDATE_DATABASE_PERMISSIONS.sql` - Database migration script

## Next Steps

To implement permission checks in your application:

1. Store user permissions in localStorage after login
2. Check permissions before showing/hiding features
3. Validate permissions on the backend API routes

Example:
```typescript
// Check if user can manage students
const user = JSON.parse(localStorage.getItem('user') || '{}');
if (user.can_manage_students) {
  // Show student management features
}
```

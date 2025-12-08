# Testing Permission Toggles

## Quick Test

1. **Check Database Columns**
   Run this in phpMyAdmin to verify columns exist:
   ```sql
   DESCRIBE users;
   ```
   You should see the 5 permission columns with type `tinyint(1)`

2. **Check Current Values**
   ```sql
   SELECT id, username, role, can_manage_students, can_mark_attendance, 
          can_view_reports, can_export_data, can_manage_users 
   FROM users;
   ```

3. **Manual Test Update**
   Try updating a user manually:
   ```sql
   UPDATE users 
   SET can_manage_students = 0, 
       can_view_reports = 1 
   WHERE username = 'manager';
   
   -- Check if it worked
   SELECT username, can_manage_students, can_view_reports FROM users WHERE username = 'manager';
   ```

## What to Check in Browser

1. Open browser console (F12)
2. Go to Admin Panel
3. Edit a user
4. Toggle some permissions
5. Click "Update User"
6. Check the Network tab to see what data is being sent
7. Look for the PUT request to `/api/admin/users/[id]`
8. Check the request payload - it should show the permission values

## Common Issues

- **Toggles don't save**: Check browser console for errors
- **Values reset**: Database might not have the columns
- **All toggles same**: Check if formData is being updated correctly

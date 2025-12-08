# Password Management Permission Setup

## Overview
Added a new permission `can_manage_passwords` to control who can change user passwords in the admin panel.

## Steps to Complete Setup

### 1. Run the SQL Script
Execute the SQL file to add the new column to your database:

```bash
# In phpMyAdmin or MySQL command line, run:
```

Open `ADD_PASSWORD_PERMISSION.sql` and execute it in your database.

This will:
- Add the `can_manage_passwords` column to the `users` table
- Set it to `1` (enabled) for all existing admin users
- Set it to `0` (disabled) for other users by default

### 2. Restart Your Development Server
```bash
# Stop the server (Ctrl + C)
# Then restart:
npm run dev
```

### 3. Test the New Permission

1. **Go to Admin Panel** → Manage Users
2. **Click Edit** on any user
3. **You should now see** a new permission switch:
   - **Manage Passwords** - Change user passwords

4. **Toggle the permission** on/off and save
5. **Verify in database**:
   ```sql
   SELECT id, username, can_manage_passwords FROM users;
   ```

## What Changed

### Database
- Added `can_manage_passwords` column (TINYINT, default 0)

### Frontend (`components/dashboard/admin-panel.tsx`)
- Added `can_manage_passwords` to User interface
- Added switch in permissions section
- Updated all formData reset locations
- Added to permission summary display

### Backend API Routes
- `app/api/admin/users/route.ts` - GET and POST updated
- `app/api/admin/users/[id]/route.ts` - PUT updated

## Permission Behavior

- **Enabled (1)**: User can change passwords for other users
- **Disabled (0)**: User cannot change passwords (password field hidden/disabled)

## Default Values
- **Admin role**: Enabled by default
- **Manager/User roles**: Disabled by default
- **New users**: Disabled by default

## Next Steps (Optional)

If you want to actually enforce this permission (hide password field based on permission):

1. Check the current user's `can_manage_passwords` permission
2. Conditionally show/hide the password field in the edit form
3. Add backend validation to prevent password changes if user lacks permission

Let me know if you want me to implement the enforcement logic!

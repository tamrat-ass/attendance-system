# Admin Guide: Reset Forgotten Username & Password

## Overview
This guide explains how administrators can help users who have forgotten their username or password.

---

## For Users Who Forgot Their Username

### Step 1: User Contacts Admin
The user should contact an administrator (via phone, email, or in person) and provide:
- Their full name
- Their email address (if they remember it)
- Any other identifying information

### Step 2: Admin Finds the Username
1. Login to the Attendance System as an administrator
2. Go to **Admin Panel** tab
3. Click on **Manage Users** tab
4. Use the search box to search by:
   - Email address
   - Full name
   - Or scroll through the user list

### Step 3: Admin Provides Username
Once found, the admin can tell the user their username:
- Username is displayed in the "Username" column
- Email is shown in the "Email" column
- Full name is shown in the "Full Name" column

---

## For Users Who Forgot Their Password

### Step 1: User Contacts Admin
The user should contact an administrator and provide:
- Their username (if they remember it)
- OR their email/full name so admin can find them

### Step 2: Admin Resets the Password

#### Method 1: Reset via Admin Panel
1. Login to the Attendance System as an administrator
2. Go to **Admin Panel** tab
3. Click on **Manage Users** tab
4. Find the user in the list (use search if needed)
5. Click the **Edit** button next to the user
6. In the edit form:
   - Scroll down to the **Password** field
   - Enter a new temporary password (minimum 6 characters)
   - Leave other fields unchanged
7. Click **✓ Update User** button
8. The system will log this password reset in Activity Logs

#### Method 2: Check Activity Logs
- Go to **Admin Panel** → **Activity Logs** tab
- Look for "RESET PASSWORD" actions to see password reset history

### Step 3: Admin Provides New Password
1. Tell the user their new temporary password
2. Recommend they change it immediately after logging in
3. Users can change their own password by clicking **Change Password** button in the header

---

## Admin Requirements

To reset user passwords, the administrator must have:
- `can_manage_users` permission (to access Admin Panel)
- `can_manage_passwords` permission (to change user passwords)

If you don't see the password field when editing a user, you don't have the `can_manage_passwords` permission. Contact a super admin.

---

## Security Best Practices

### For Admins:
1. **Verify Identity**: Always verify the user's identity before resetting their password
2. **Use Temporary Passwords**: Give them a temporary password and tell them to change it
3. **Document**: All password resets are automatically logged in Activity Logs
4. **Secure Communication**: Share new passwords securely (in person, phone, encrypted message)
5. **Never Share**: Don't share passwords via email or public channels

### For Users:
1. **Change Immediately**: Change the temporary password as soon as you login
2. **Use Strong Passwords**: Use at least 6 characters (longer is better)
3. **Keep It Secret**: Don't share your password with anyone
4. **Remember It**: Write it down in a secure place if needed

---

## Quick Reference

### Finding a User:
```
Admin Panel → Manage Users → Search by name/email/username
```

### Resetting Password:
```
Admin Panel → Manage Users → Click "Edit" → Enter new password → Update User
```

### Viewing Reset History:
```
Admin Panel → Activity Logs → Look for "RESET PASSWORD" actions
```

### User Changes Own Password:
```
Header → Change Password button → Enter current & new password
```

---

## Troubleshooting

### "I can't see the password field when editing a user"
- You don't have `can_manage_passwords` permission
- Contact a super admin to grant you this permission

### "The Edit button is disabled"
- You might not have `can_manage_users` permission
- Contact a super admin

### "User can't login with new password"
- Double-check the password was entered correctly
- Make sure the user account status is "Active"
- Check if username is correct (case-sensitive)

### "I need to reset my own password"
- Click **Change Password** button in the header
- Enter your current password and new password
- If you forgot your own password, ask another admin to reset it

---

## Example Scenario

**User calls:** "Hi, I forgot my password. My name is John Smith."

**Admin response:**
1. "Let me look up your account..."
2. *Searches for "John Smith" in Admin Panel*
3. "I found your account. Your username is 'jsmith'"
4. *Clicks Edit, enters new password "TempPass123"*
5. "I've reset your password to 'TempPass123'"
6. "Please login and change it immediately using the Change Password button"
7. "Is there anything else I can help you with?"

---

## Contact

If you need additional help or have questions about password resets, contact your system administrator or IT support team.

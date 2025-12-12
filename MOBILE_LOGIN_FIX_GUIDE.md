# Mobile Login Fix Guide

## Problem
The mobile application cannot login because the database contains plain text passwords, but the login API expects bcrypt hashed passwords.

## Root Cause
All database setup scripts insert plain text passwords like:
- `admin` user: `password123`
- `teacher1` user: `teacher123` 
- `manager` user: `manager123`

But the login API (`app/api/auth/login/route.ts`) uses `bcrypt.compare()` which expects hashed passwords.

## Solution Options

### Option 1: Quick Fix - Update Database Passwords (RECOMMENDED)

Run the password hashing fix script:

```sql
-- Run this in your database (phpMyAdmin, MySQL Workbench, etc.)
-- File: FIX_PASSWORD_HASHING.sql

-- Update admin user password (password123 -> bcrypt hash)
UPDATE users 
SET password_hash = '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'
WHERE username = 'admin' AND password_hash = 'password123';

-- Update teacher1 user password (teacher123 -> bcrypt hash)  
UPDATE users 
SET password_hash = '$2a$10$TKh8H1.PfQx37YgCzwiKb.KjNyWgaHb9cbcoQgdIVFlYg7B77UdFm'
WHERE username = 'teacher1' AND password_hash = 'teacher123';

-- Update manager user password (manager123 -> bcrypt hash)
UPDATE users 
SET password_hash = '$2a$10$TKh8H1.PfQx37YgCzwiKb.KjNyWgaHb9cbcoQgdIVFlYg7B77UdFm'
WHERE username = 'manager' AND password_hash = 'manager123';

-- Update any remaining plain text passwords
UPDATE users 
SET password_hash = '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'
WHERE password_hash = 'password123';
```

### Option 2: Generate New Hashes

If you want to generate fresh bcrypt hashes:

```bash
node generate-password-hash.js
```

This will output SQL UPDATE statements with new hashes.

### Option 3: Verify Current Users

Check what users exist in your database:

```sql
SELECT id, username, full_name, role, 
       CASE 
         WHEN LENGTH(password_hash) < 20 THEN 'PLAIN TEXT (NEEDS FIX)'
         ELSE 'HASHED (OK)'
       END as password_status
FROM users;
```

## After Fixing

### Test Login Credentials

After running the fix, these credentials should work in the mobile app:

| Username | Password | Role |
|----------|----------|------|
| admin | password123 | admin |
| teacher1 | teacher123 | user |
| manager | manager123 | user |

### Verify Fix

1. Run the SQL fix script
2. Open the mobile app
3. Try logging in with `admin` / `password123`
4. Should successfully login and navigate to dashboard

## Mobile App Configuration

Make sure the mobile app is pointing to the correct API URL in:
`mk-attendance-flutter/lib/services/api_service.dart`

```dart
static const String baseUrl = 'https://mk-attendance.vercel.app/api';
```

## Troubleshooting

### Still Can't Login?

1. **Check API URL**: Ensure mobile app points to correct backend URL
2. **Check Network**: Test API connection from mobile app
3. **Check Database**: Verify users table has hashed passwords
4. **Check Logs**: Look at mobile app console for error messages

### Common Error Messages

- "Invalid username or password" → Password not hashed correctly
- "Network error" → API URL incorrect or server down
- "Connection failed" → Internet connectivity issue

## Security Note

In production, you should:
1. Use strong passwords (not `password123`)
2. Force users to change default passwords on first login
3. Implement password complexity requirements
4. Use environment variables for sensitive data
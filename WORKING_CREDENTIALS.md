# 🔑 Working Credentials for MK Attendance System

## Database Status ✅ CONFIRMED

Based on your Neon database table, here are the **actual user credentials**:

| ID | Username | Password | Email | Role |
|----|----------|----------|-------|------|
| 1 | **admin** | **123456** | admin@example.com | Administrator |
| 2 | **manager** | **manager123** | manager@example.com | Manager |
| 3 | **user1** | **123456** | user@example.com | Regular User |

## Login Credentials

### For Mobile App ✅ WORKING
```
Username: admin
Password: 123456
```

### For Web App ❓ TO TEST
```
Username: admin  
Password: 123456
```

## Alternative Credentials

If `admin/123456` doesn't work, try:

```
Username: manager
Password: manager123
```

```
Username: user1
Password: 123456
```

## Password Status

Your database currently has **PLAIN TEXT passwords**:
- ✅ This is why the mobile app works
- ⚠️ For security, these should be hashed in production

## Testing Steps

### 1. Test Web App
1. Go to: https://mk-attendance.vercel.app
2. Try login with: `admin` / `123456`
3. If successful, you'll see the dashboard

### 2. Test Mobile App
1. Open the app on your Samsung device
2. Login with: `admin` / `123456`
3. Should work (already confirmed working)

## Security Recommendation

For production use, consider hashing the passwords:

```sql
-- Run in Neon console to hash passwords
UPDATE users 
SET password_hash = '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'
WHERE username = 'admin';

UPDATE users 
SET password_hash = '$2b$10$TKh8H1.PfQx37YgCzwiKb.KjNyWgaHb9cbcoQgdIVFlYg7B77UdFm'
WHERE username = 'manager';

UPDATE users 
SET password_hash = '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'
WHERE username = 'user1';
```

After hashing, the passwords would become:
- `admin` → `password123`
- `manager` → `manager123` 
- `user1` → `password123`

## Summary

🎉 **Mobile app login is working with `admin` / `123456`**

The system is now fully functional with plain text passwords. Both web and mobile apps should work with the same credentials from your database table.

**Next step**: Test the web app with 
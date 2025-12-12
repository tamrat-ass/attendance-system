# Mobile App Debug Guide

## Issue Analysis
Your Flutter app builds successfully (23.9MB APK) and installs on the device, but crashes immediately after launch with "Application finished."

## Most Likely Causes

### 1. Login/Authentication Issue (MOST LIKELY)
The app is probably crashing because it can't authenticate with the backend due to the password hashing issue we identified earlier.

**Solution**: Run the password fix first:
```sql
-- Run FIX_PASSWORD_HASHING.sql in your database
UPDATE users 
SET password_hash = '$2b$10$.F.cL.cIuQZDOtKIvfaUZOVFgO6NnaN888m1psdzBjQ3/8nzuuhBq'
WHERE username = 'admin' AND password_hash = 'password123';
```

### 2. Network/API Connection Issue
The app might be failing to connect to your backend API.

**Check**: Make sure your backend is running and accessible at:
`https://mk-attendance.vercel.app/api`

### 3. Debug Steps

#### Step 1: Check Device Logs
Run this command while the app is running to see crash logs:
```bash
adb logcat | grep flutter
```

#### Step 2: Test API Connection
Test if your API is accessible:
```bash
curl https://mk-attendance.vercel.app/api/students?limit=1
```

#### Step 3: Build Debug Version
Build a debug version to get better error messages:
```bash
cd mk-attendance-flutter
flutter run --debug
```

#### Step 4: Check Database Connection
Verify your database has users with hashed passwords:
```sql
SELECT username, 
       CASE 
         WHEN LENGTH(password_hash) < 20 THEN 'PLAIN TEXT (NEEDS FIX)'
         ELSE 'HASHED (OK)'
       END as password_status
FROM users;
```

## Quick Fix Sequence

1. **Fix Database Passwords** (Run FIX_PASSWORD_HASHING.sql)
2. **Verify Backend is Running** (Check Vercel deployment)
3. **Rebuild and Install App**:
   ```bash
   cd mk-attendance-flutter
   flutter clean
   flutter pub get
   flutter build apk --release
   flutter install
   ```

## Test Credentials After Fix
- Username: `admin`
- Password: `password123`

## Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| "Application finished" immediately | Authentication failure | Fix database passwords |
| Network timeout | Backend not accessible | Check Vercel deployment |
| "Invalid username or password" | Password not hashed | Run password fix script |

## If Still Crashing

1. **Check Android logs**:
   ```bash
   adb logcat -s flutter
   ```

2. **Build debug version**:
   ```bash
   flutter run --debug
   ```

3. **Test individual components**:
   - Test API endpoints manually
   - Check database connectivity
   - Verify all dependencies are installed

## Success Indicators
- App launches and shows splash screen
- Transitions to login screen after 3 seconds
- Login with admin/password123 works
- Dashboard loads with data

The most likely fix is running the password hashing script we created earlier.
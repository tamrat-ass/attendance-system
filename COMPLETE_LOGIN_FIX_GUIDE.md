# Complete Login Fix Guide

## Issues Found & Fixed

### 1. Database Column Mismatch ✅ FIXED
**Problem**: Login API was checking `user.password` but database column is `password_hash`
**Fixed**: Updated login API to use `user.password_hash`

### 2. Plain Text Passwords in Database ⚠️ NEEDS DATABASE UPDATE
**Problem**: Neon database has plain text passwords like `password123`
**Solution**: Run the password fix script

### 3. Change Password API Issues ✅ FIXED
**Problem**: Change password API had same column mismatch issues
**Fixed**: Updated to use `password_hash` column correctly

## Step-by-Step Fix Process

### Step 1: Update Database Passwords
Run this SQL script in your **Neon SQL Editor**:

```sql
-- Copy and paste NEON_PASSWORD_FIX.sql content
UPDATE users 
SET password_hash = '$2b$10$.F.cL.cIuQZDOtKIvfaUZOVFgO6NnaN888m1psdzBjQ3/8nzuuhBq'
WHERE username = 'admin' AND password_hash = 'password123';

UPDATE users 
SET password_hash = '$2b$10$rglT01g.O17KErtu4aEg3eF4hsU5w1MI3LnwSs/zTWrv19ek7/kGG'
WHERE username = 'manager' AND password_hash = 'manager123';

UPDATE users 
SET password_hash = '$2b$10$UEX4f2n0B2seeIFVkHsCRuI3X8QIq2yPTDAjzPN.NcJtax/MPCYjS'
WHERE username = 'user1' AND password_hash = 'user123';
```

### Step 2: Deploy Web App Changes
The API fixes are already applied. Deploy to Vercel:
```bash
git add .
git commit -m "Fix login API password_hash column issues"
git push
```

### Step 3: Test Web App Login
Go to your web app and test login:
- Username: `admin`
- Password: `password123`

### Step 4: Test Mobile App
Rebuild and test the mobile app:
```bash
cd mk-attendance-flutter
flutter clean
flutter pub get
flutter build apk --release
flutter install
```

## Test Credentials (After Database Fix)

| Username | Password | Role | Access Level |
|----------|----------|------|--------------|
| admin | password123 | admin | Full access |
| manager | manager123 | manager | Limited admin |
| user1 | user123 | user | Basic user |

## Verification Steps

### 1. Check Database
```sql
SELECT 
  username, 
  CASE 
    WHEN LENGTH(password_hash) > 50 THEN 'HASHED ✓'
    ELSE 'PLAIN TEXT ✗'
  END as password_status
FROM users;
```

### 2. Test Web Login
- Go to your web app
- Login with admin/password123
- Should work without errors

### 3. Test Mobile Login
- Open mobile app
- Login with admin/password123
- Should navigate to dashboard

## Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| "Invalid username or password" | Passwords not hashed | Run database fix script |
| "User not found" | Database connection issue | Check Neon database status |
| App crashes on mobile | Authentication failure | Ensure database is fixed first |
| "Network error" | API not deployed | Deploy latest changes to Vercel |

## Files Updated
- ✅ `app/api/auth/login/route.ts` - Fixed password_hash column
- ✅ `app/api/auth/change-password/route.ts` - Fixed password_hash column
- 📄 `NEON_PASSWORD_FIX.sql` - Database password fix script

## Next Steps
1. Run the database fix script in Neon
2. Deploy the API changes to Vercel
3. Test both web and mobile apps
4. Both should now work with the same credentials!
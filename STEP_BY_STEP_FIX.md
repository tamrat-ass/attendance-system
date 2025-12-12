# Step-by-Step Login Fix Guide

## Issue: Login still not working + Flutter showing debug commands

Let's fix this systematically:

## Step 1: Check Database Status

1. **Go to your Neon database console**
2. **Run this query** to check user status:
   ```sql
   SELECT username, 
          CASE 
            WHEN LENGTH(password_hash) > 50 THEN 'HASHED ✅'
            ELSE 'PLAIN TEXT ❌'
          END as status,
          LEFT(password_hash, 20) as preview
   FROM users;
   ```

## Step 2: Fix Database (If Needed)

If you see "PLAIN TEXT ❌", run this fix:
```sql
UPDATE users 
SET password_hash = '$2b$10$.F.cL.cIuQZDOtKIvfaUZOVFgO6NnaN888m1psdzBjQ3/8nzuuhBq'
WHERE username = 'admin' AND LENGTH(password_hash) < 20;

UPDATE users 
SET password_hash = '$2b$10$rglT01g.O17KErtu4aEg3eF4hsU5w1MI3LnwSs/zTWrv19ek7/kGG'
WHERE username = 'manager' AND LENGTH(password_hash) < 20;

UPDATE users 
SET password_hash = '$2b$10$UEX4f2n0B2seeIFVkHsCRuI3X8QIq2yPTDAjzPN.NcJtax/MPCYjS'
WHERE username = 'user1' AND LENGTH(password_hash) < 20;
```

## Step 3: Test API Directly

Run this command to test the login API:
```bash
node test-login-api.js
```

This will test all three users and show you exactly what's happening.

## Step 4: Deploy API Changes

Make sure your API changes are deployed:
```bash
git add .
git commit -m "Fix login API password_hash issues"
git push
```

Wait for Vercel to deploy (check your Vercel dashboard).

## Step 5: Test Web Login First

1. Go to your web app: https://mk-attendance.vercel.app
2. Try login with: `admin` / `password123`
3. If this works, the API is fixed

## Step 6: Build Mobile App (Clean)

Use the new clean build script:
```bash
build_and_install_simple.bat
```

This will build and install without showing debug commands.

## Step 7: Test Mobile Login

1. Open the app on your Samsung device
2. Try login with: `admin` / `password123`
3. Should work if Steps 1-5 were successful

## Troubleshooting

### If API test fails:
- Check if Vercel deployment is complete
- Verify database connection in Neon
- Run the database fix script again

### If web login fails:
- Database passwords are still plain text
- Run Step 2 again in Neon console

### If mobile login fails but web works:
- Mobile app is using cached old API
- Rebuild the mobile app completely
- Check internet connection on device

### If you still see Flutter debug commands:
- Use `build_and_install_simple.bat` instead
- Or press `q` to quit the debug session first

## Expected Results

✅ **Database check**: All users show "HASHED ✅"  
✅ **API test**: All three users return "SUCCESS"  
✅ **Web login**: Works with admin/password123  
✅ **Mobile login**: Works with admin/password123  

## Quick Test Commands

```bash
# Test API
node test-login-api.js

# Build mobile app (clean)
build_and_install_simple.bat

# Check database
# (Run CHECK_DATABASE_USERS.sql in Neon)
```
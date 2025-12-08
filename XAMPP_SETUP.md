# XAMPP Setup Guide for Attendance System

## Prerequisites
- XAMPP installed on your Windows machine
- Node.js installed

## Step-by-Step Setup

### 1. Start XAMPP Services
1. Open **XAMPP Control Panel**
2. Click **Start** for **Apache**
3. Click **Start** for **MySQL**
4. Both should show green status

### 2. Create Database
1. Open your browser and go to: `http://localhost/phpmyadmin`
2. Click on **SQL** tab at the top
3. Copy and paste the contents of `database-schema.sql` file
4. Click **Go** to execute

**OR** you can import the file:
1. Click **Import** tab
2. Choose file: `database-schema.sql`
3. Click **Go**

### 3. Verify Database Connection
Your database configuration is already set in `lib/db.ts`:
```typescript
host: "localhost",
user: "root",
password: "",  // Default XAMPP has no password
database: "attendance_system"
```

### 4. Test the Connection
Run the development server:
```bash
npm run dev
```

Then visit: `http://localhost:3000/api/test-db`

You should see a JSON response with student data.

### 5. Common XAMPP MySQL Settings
- **Host:** localhost
- **Port:** 3306 (default)
- **Username:** root
- **Password:** (empty by default)

## Troubleshooting

### MySQL Won't Start
- **Port 3306 is busy:** Another MySQL service might be running
  - Open Task Manager → Services → Stop any MySQL services
  - Or change XAMPP MySQL port in `my.ini`

### Connection Error: ECONNREFUSED
- Make sure MySQL is running in XAMPP Control Panel
- Check if port 3306 is correct
- Verify database name is `attendance_system`

### Access Denied Error
- Default XAMPP MySQL has no password for root user
- If you set a password, update `lib/db.ts`:
  ```typescript
  password: "your_password_here"
  ```

### Database Not Found
- Make sure you ran the `database-schema.sql` script
- Check database exists in phpMyAdmin

## Changing MySQL Password (Optional)

If you want to secure your XAMPP MySQL:

1. Go to phpMyAdmin
2. Click **User accounts** tab
3. Find **root** user with **localhost** host
4. Click **Edit privileges**
5. Click **Change password**
6. Set new password
7. Update `lib/db.ts` with the new password

## Next Steps

After successful setup:
1. Run `npm install` (if not done already)
2. Run `npm run dev`
3. Open `http://localhost:3000`
4. Test the student management features

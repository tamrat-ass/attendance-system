# User Activity Logs Setup

## Overview
Track ALL user activities including logins, logouts, and admin actions (user creation, updates, deletions) with timestamps, IP addresses, and detailed information.

## Setup Instructions

### Step 1: Create Logs Table
Run the SQL script in phpMyAdmin:

1. Open: `http://localhost/phpmyadmin`
2. Select database: `attendance_system`
3. Go to SQL tab
4. Copy and paste contents of: `UPDATE_DATABASE_LOGS.sql`
5. Click **Go**

### Step 2: Test the Feature

1. Refresh your browser (Ctrl + F5)
2. Login as admin
3. Go to **Admin Panel**
4. You'll see a new **Activity Logs** tab

### Step 3: Generate Some Logs

Try these actions to see logs in action:
- Create a new user
- Edit an existing user
- Delete a user
- Check the Activity Logs tab to see all actions

## What Gets Logged

### User Actions
- **LOGIN** - When any user logs into the system
- **LOGOUT** - When any user logs out

### Admin Actions
- **CREATE_USER** - When a new user is created
- **UPDATE_USER** - When user details or permissions are changed
- **DELETE_USER** - When a user is deleted

Each log includes:
- Date and time
- Admin who performed the action
- Action type
- Details (what was changed)
- IP address

## Features

- **Real-time tracking** - Logs are created instantly
- **Audit trail** - See who did what and when
- **IP tracking** - Know where actions came from
- **User details** - Full name and username of admin
- **Action details** - Specific information about what changed

## Viewing Logs

The Activity Logs tab shows:
- Most recent logs first
- Color-coded badges for different actions
- Admin user information
- Timestamps in your local timezone
- IP addresses for security tracking

## Future Enhancements

You can extend this to log:
- Student management actions
- Attendance changes
- Report exports
- Login attempts
- Failed actions

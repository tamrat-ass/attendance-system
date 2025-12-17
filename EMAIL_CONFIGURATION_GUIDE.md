# Email Configuration for QR Code Notifications

## Quick Setup for Vercel

To enable automatic email notifications with QR codes after student registration:

### 1. Create Gmail App Password
1. Go to your Gmail account settings
2. Enable 2-Factor Authentication
3. Generate an "App Password" for this application
4. Copy the 16-character password

### 2. Set Vercel Environment Variables
In your Vercel dashboard, add these environment variables:

```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-16-character-app-password
```

### 3. Test Configuration
After setting up:
1. Deploy the changes
2. Register a new student
3. Check if email with QR code is sent

## Features Enabled
✅ **Automatic registration emails**
✅ **QR code generation and sending**
✅ **Student creation works even if email fails**
✅ **Proper error handling**

## Fallback Behavior
- If email is not configured: Student creation still works
- If email fails: Student is created, but no email sent
- If email succeeds: Student gets registration email with QR code

## Email Template Includes
- Welcome message
- Student details (name, class, phone)
- Personal QR code image
- Instructions for QR code usage
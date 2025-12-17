# Email Notification Setup Guide

## Overview
The MK Attendance Flutter app now includes a comprehensive email notification system with two main features:

1. **Automatic Registration Email**: Sent when a student registers with an email address
2. **Admin Bulk Email**: Allows admins to send messages to selected students

## Environment Variables Setup

Add these environment variables to your `.env.local` file:

```env
# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# Base URL for API calls
NEXT_PUBLIC_BASE_URL=https://mk-attendance.vercel.app
```

## Gmail Setup (Recommended)

1. **Enable 2-Factor Authentication** on your Gmail account
2. **Generate App Password**:
   - Go to Google Account settings
   - Security → 2-Step Verification → App passwords
   - Generate a new app password for "Mail"
   - Use this password in `SMTP_PASS`

## Database Setup

Run the SQL script to create the email logs table:

```sql
-- Run this in your database
CREATE TABLE IF NOT EXISTS email_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type ENUM('registration', 'bulk') NOT NULL,
  recipient VARCHAR(255) NOT NULL,
  sender VARCHAR(255) NOT NULL,
  content TEXT,
  status ENUM('success', 'failed') NOT NULL,
  error_message TEXT,
  student_id INT,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE SET NULL
);

-- Add email column to students table
ALTER TABLE students ADD COLUMN IF NOT EXISTS email VARCHAR(255) DEFAULT NULL;
```

## Features

### 1. Automatic Registration Email
- **Trigger**: When a student is registered with an email address
- **Content**: Welcome message with student details (ID, name, class, phone, gender)
- **Security**: No passwords or sensitive data included
- **Logging**: All attempts logged with success/failure status

### 2. Admin Bulk Email
- **Access**: Admin and Manager users only
- **Recipients**: Single, multiple, or all students with email addresses
- **Filtering**: Filter by class before selecting recipients
- **Batch Processing**: Asynchronous sending with rate limiting
- **Logging**: Each email logged individually with delivery status

### 3. Email Logs
- **Tracking**: All emails logged with timestamp, status, and error details
- **Admin Access**: View logs through "Send Message" → History icon
- **Filtering**: Filter by email type (registration/bulk)

## Flutter App Integration

### New Screens Added:
1. **Send Message Screen**: `/lib/screens/send_message_screen.dart`
2. **Email Logs Screen**: Accessible from Send Message screen

### Updated Components:
1. **Student Model**: Added email field
2. **Student Registration**: Added email input field
3. **Dashboard**: Added "Send Message" quick action for admins
4. **Notification Service**: Handles all email operations

### Navigation:
- **Dashboard** → "Send Message" (Admin/Manager only)
- **Students** → Add/Edit Student → Email field included
- **Send Message** → History icon → Email Logs

## API Endpoints

### Registration Email
```
POST /api/notifications/registration
Body: {
  student_id, full_name, email, phone, class, gender
}
```

### Bulk Email
```
POST /api/notifications/bulk
Body: {
  message, student_ids[], sender_name
}
```

### Email Logs
```
GET /api/notifications/logs?limit=50&type=registration
```

## Security Features

1. **Email Validation**: Proper email format validation
2. **Rate Limiting**: Small delays between bulk emails
3. **Error Handling**: Graceful failure handling
4. **Logging**: Comprehensive audit trail
5. **Permission Control**: Admin/Manager access only for bulk emails

## Testing

1. **Add a student with email** → Check registration email
2. **Use Send Message** → Select students → Send bulk email
3. **Check Email Logs** → Verify delivery status
4. **Test error handling** → Use invalid email addresses

## Troubleshooting

### Common Issues:
1. **Gmail Authentication**: Use App Password, not regular password
2. **SMTP Settings**: Verify host and port settings
3. **Firewall**: Ensure SMTP port 587 is not blocked
4. **Rate Limits**: Gmail has sending limits for new accounts

### Debug Steps:
1. Check console logs for email errors
2. Verify environment variables are loaded
3. Test SMTP connection separately
4. Check email logs table for error messages

## Production Considerations

1. **Email Service**: Consider using SendGrid, AWS SES, or similar for production
2. **Rate Limiting**: Implement proper rate limiting for bulk emails
3. **Queue System**: Use job queues for large bulk email operations
4. **Monitoring**: Set up email delivery monitoring and alerts
5. **Templates**: Create professional email templates
6. **Unsubscribe**: Add unsubscribe functionality for compliance

## Future Enhancements

1. **Email Templates**: Rich HTML templates with school branding
2. **Scheduled Emails**: Send emails at specific times
3. **Email Analytics**: Track open rates and engagement
4. **SMS Integration**: Add SMS notifications alongside emails
5. **Parent Notifications**: Send attendance updates to parents
6. **Multilingual**: Support for multiple languages in emails
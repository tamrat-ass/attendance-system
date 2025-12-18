# Bulk Student Upload with Email Integration

## Overview
The enhanced bulk upload feature allows you to upload multiple students at once while automatically sending registration emails with QR codes to each student.

## Features
- **Bulk Upload**: Upload multiple students via CSV or Excel files
- **Email Integration**: Automatically send registration emails to each student
- **QR Code Generation**: Generate unique, non-expiring QR codes for each student
- **Email Logging**: Track email delivery status for each student
- **Validation**: Comprehensive validation for all student data including email addresses

## How It Works

### 1. File Upload
- Supports CSV (.csv) and Excel (.xlsx, .xls) formats
- Required columns: `full_name`, `phone`, `gender`, `class`, `email`
- Email addresses must be @gmail.com format
- Phone numbers must be in format: 09xxxxxxxx

### 2. Email Processing
When the "Send registration emails with QR codes" option is enabled:
- Each student receives a personalized registration email
- Email includes student details and unique QR code
- QR codes are generated using external API service
- Email delivery is logged to the database

### 3. QR Code Generation
- Each QR code contains: student_id, full_name, class, phone, timestamp, security token
- QR codes are non-expiring and unique per student
- Generated using https://api.qrserver.com service
- Stored in database for future reference

## API Endpoints

### New Endpoint: `/api/students/bulk-with-email`
- **Method**: POST
- **Purpose**: Bulk upload with email notifications
- **Payload**: `{ students: Array<StudentData> }`
- **Response**: Includes email delivery results

### Existing Endpoint: `/api/students/bulk`
- **Method**: POST  
- **Purpose**: Bulk upload without emails
- **Payload**: `{ students: Array<StudentData> }`
- **Response**: Standard upload results

## Usage Instructions

### 1. Download Template
1. Click "Download Excel Template" button
2. Template includes sample data with all required columns
3. Replace sample data with actual student information

### 2. Prepare Data
Ensure your file has these columns:
- `full_name`: Student's full name
- `phone`: Phone number (09xxxxxxxx format)
- `gender`: Male or Female
- `class`: Student's class/grade
- `email`: Gmail address (@gmail.com)

### 3. Upload Process
1. Select your prepared CSV/Excel file
2. Choose whether to send emails (checkbox)
3. Click "Upload Students" button
4. Monitor progress and results

### 4. Results
The system will show:
- Total students processed
- Successfully added students
- Skipped duplicates
- Email delivery results (if enabled)

## Email Template Features
- **Professional Design**: Clean, mobile-friendly layout
- **Student Details**: Complete registration information
- **QR Code**: Large, scannable QR code image
- **Instructions**: Clear usage instructions
- **YouTube Promotion**: Channel subscription link
- **Branding**: MK Attendance System branding

## Error Handling
- **Validation Errors**: Detailed error messages for invalid data
- **Duplicate Detection**: Skips students with same name+phone
- **Email Failures**: Logs failed emails, continues processing
- **File Format Issues**: Clear guidance for file format problems

## Database Changes
- **email_logs table**: Tracks all email delivery attempts
- **students table**: Now requires email field
- **QR code storage**: Enhanced QR data with security tokens

## Configuration Requirements
- **SMTP Settings**: Gmail SMTP credentials required for email functionality
- **Environment Variables**: SMTP_USER and SMTP_PASS must be configured
- **Database**: email_logs table must exist

## Benefits
1. **Efficiency**: Process hundreds of students in minutes
2. **Automation**: No manual email sending required
3. **Tracking**: Complete audit trail of email delivery
4. **User Experience**: Students receive immediate confirmation
5. **Security**: Secure QR codes with validation tokens
6. **Scalability**: Handles large batches efficiently

## Best Practices
1. **File Size**: Keep uploads under 1000 students per batch
2. **Data Quality**: Validate data before upload
3. **Email Testing**: Test with small batch first
4. **Backup**: Keep backup of original data files
5. **Monitoring**: Check email logs for delivery issues

## Troubleshooting
- **Email Not Configured**: System works without emails, logs warning
- **Invalid Email Format**: Only @gmail.com addresses accepted
- **Duplicate Students**: Identified by name+phone combination
- **File Format Issues**: Use provided template for correct format
- **Large Files**: Split into smaller batches if upload fails
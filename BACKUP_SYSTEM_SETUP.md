# Automatic Backup System Setup Guide

## Overview
This system automatically backs up your Neon PostgreSQL database to Google Sheets using Vercel Cron Jobs.

## Features
- ✅ **Automatic daily backups** at 2 AM UTC
- ✅ **Students table**: Complete overwrite backup
- ✅ **Attendance table**: Incremental append-only backup
- ✅ **Error handling** and retry logic
- ✅ **Backup logging** and monitoring
- ✅ **Manual backup triggers**
- ✅ **Google Sheets formatting**
- ✅ **Production-ready security**

## Prerequisites

### 1. Install Required Dependencies
```bash
npm install googleapis pg @types/pg
```

### 2. Google Cloud Setup

#### Step 1: Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the Google Sheets API

#### Step 2: Create Service Account
1. Go to IAM & Admin > Service Accounts
2. Click "Create Service Account"
3. Name: `attendance-backup-service`
4. Description: `Service account for automatic database backups`
5. Click "Create and Continue"

#### Step 3: Generate Service Account Key
1. Click on the created service account
2. Go to "Keys" tab
3. Click "Add Key" > "Create new key"
4. Choose "JSON" format
5. Download the JSON file

#### Step 4: Create Google Sheet
1. Go to [Google Sheets](https://sheets.google.com)
2. Create a new spreadsheet
3. Name it: `Attendance System Backup`
4. Copy the spreadsheet ID from URL: `https://docs.google.com/spreadsheets/d/{SPREADSHEET_ID}/edit`
5. Share the sheet with your service account email (found in the JSON file)
6. Give "Editor" permissions

## Environment Variables Setup

Add these to your Vercel environment variables:

### Required Variables
```env
# Database
DATABASE_URL=postgresql://username:password@host:5432/database?sslmode=require

# Google Sheets
GOOGLE_SPREADSHEET_ID=your_spreadsheet_id_here
GOOGLE_SERVICE_ACCOUNT_KEY={"type":"service_account","project_id":"..."}

# Security
BACKUP_API_KEY=your_secure_random_key_here

# Optional
NODE_ENV=production
VERCEL_URL=https://your-app.vercel.app
```

### Setting Environment Variables in Vercel
1. Go to your Vercel dashboard
2. Select your project
3. Go to Settings > Environment Variables
4. Add each variable:
   - **DATABASE_URL**: Your Neon PostgreSQL connection string
   - **GOOGLE_SPREADSHEET_ID**: The ID from your Google Sheet URL
   - **GOOGLE_SERVICE_ACCOUNT_KEY**: Paste the entire JSON content from downloaded file
   - **BACKUP_API_KEY**: Generate a secure random string (use: `openssl rand -hex 32`)

## Database Setup

Run this SQL in your Neon database:

```sql
-- Create backup logs table
CREATE TABLE IF NOT EXISTS backup_logs (
  id SERIAL PRIMARY KEY,
  backup_type VARCHAR(50) NOT NULL DEFAULT 'google_sheets',
  status VARCHAR(20) NOT NULL CHECK (status IN ('success', 'failed', 'in_progress')),
  students_count INTEGER DEFAULT 0,
  attendance_count INTEGER DEFAULT 0,
  error_message TEXT,
  duration_ms INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_backup_status ON backup_logs(status);
CREATE INDEX IF NOT EXISTS idx_backup_created_at ON backup_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_backup_type ON backup_logs(backup_type);
```

## Deployment Steps

### 1. Deploy to Vercel
```bash
# Make sure vercel.json is in your root directory
vercel --prod
```

### 2. Setup Google Sheets
```bash
# Call the setup API to initialize sheets
curl -X POST https://your-app.vercel.app/api/backup/setup
```

### 3. Test Manual Backup
```bash
# Test the backup system
curl -X POST https://your-app.vercel.app/api/backup/manual \
  -H "Authorization: Bearer YOUR_BACKUP_API_KEY"
```

### 4. Verify Cron Job
- Cron jobs run automatically on Vercel Pro plans
- Check Vercel dashboard > Functions tab for cron execution logs
- First automatic backup will run at 2 AM UTC

## API Endpoints

### 1. Main Backup API
- **URL**: `/api/backup`
- **Method**: POST (automatic cron) / GET (status check)
- **Purpose**: Performs the actual backup operation

### 2. Setup API
- **URL**: `/api/backup/setup`
- **Method**: POST (setup) / GET (check status)
- **Purpose**: Initialize Google Sheets structure

### 3. Manual Backup API
- **URL**: `/api/backup/manual`
- **Method**: POST (trigger) / GET (status)
- **Purpose**: Manually trigger backups with authentication

## Backup Schedule

### Automatic Backup
- **Time**: 2:00 AM UTC daily
- **Frequency**: Once per day
- **Timeout**: 5 minutes maximum

### Manual Backup
- Available anytime via API
- Requires authentication token
- Same process as automatic backup

## Backup Process

### Students Table Backup
1. **Method**: Complete overwrite
2. **Reason**: Students data changes infrequently
3. **Process**:
   - Clear existing Google Sheet data
   - Export all students from database
   - Write to Google Sheets with headers
   - Format headers (bold, gray background)

### Attendance Table Backup
1. **Method**: Incremental append
2. **Reason**: Attendance data grows continuously
3. **Process**:
   - Find last backed up attendance ID
   - Export only new attendance records
   - Append to Google Sheets
   - Include student names via JOIN

## Monitoring and Logging

### Backup Logs Table
- Tracks every backup attempt
- Records success/failure status
- Stores record counts and error messages
- Includes execution duration

### Log Monitoring
```sql
-- Check recent backup status
SELECT * FROM backup_logs ORDER BY created_at DESC LIMIT 10;

-- Check backup success rate
SELECT 
  status,
  COUNT(*) as count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM backup_logs 
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY status;
```

## Error Handling

### Common Issues and Solutions

#### 1. Google Sheets Authentication Error
- **Error**: "Google Sheets authentication failed"
- **Solution**: 
  - Verify GOOGLE_SERVICE_ACCOUNT_KEY is valid JSON
  - Check service account has access to spreadsheet
  - Ensure Google Sheets API is enabled

#### 2. Database Connection Error
- **Error**: "Database connection failed"
- **Solution**:
  - Verify DATABASE_URL is correct
  - Check Neon database is running
  - Verify SSL settings

#### 3. Spreadsheet Not Found
- **Error**: "Spreadsheet not found"
- **Solution**:
  - Verify GOOGLE_SPREADSHEET_ID is correct
  - Check service account has access
  - Run setup API to create sheets

#### 4. Cron Job Not Running
- **Issue**: Backups not executing automatically
- **Solution**:
  - Verify Vercel Pro plan (required for cron)
  - Check vercel.json configuration
  - Monitor Vercel dashboard logs

## Security Best Practices

### 1. Environment Variables
- Never commit sensitive data to git
- Use Vercel's encrypted environment variables
- Rotate API keys regularly

### 2. Service Account Security
- Use dedicated service account for backups only
- Grant minimum required permissions
- Monitor service account usage

### 3. API Security
- Protect manual backup API with authentication
- Use strong, random API keys
- Consider IP whitelisting for manual triggers

### 4. Data Security
- Google Sheets are private by default
- Only share with necessary users
- Consider additional encryption for sensitive data

## Maintenance

### Regular Tasks
1. **Monthly**: Review backup logs for failures
2. **Quarterly**: Test manual backup process
3. **Annually**: Rotate service account keys
4. **As needed**: Update backup retention policies

### Backup Retention
- Google Sheets: Unlimited (manual cleanup if needed)
- Backup logs: Consider archiving after 1 year
- Failed backups: Investigate and resolve promptly

## Troubleshooting Commands

### Test Database Connection
```bash
# Test if database is accessible
curl https://your-app.vercel.app/api/backup?action=status
```

### Test Google Sheets Access
```bash
# Test Google Sheets setup
curl https://your-app.vercel.app/api/backup/setup
```

### Manual Backup Test
```bash
# Trigger manual backup
curl -X POST https://your-app.vercel.app/api/backup/manual \
  -H "Authorization: Bearer YOUR_BACKUP_API_KEY"
```

### Check Backup Logs
```sql
-- Recent backup attempts
SELECT 
  id,
  status,
  students_count,
  attendance_count,
  error_message,
  created_at
FROM backup_logs 
ORDER BY created_at DESC 
LIMIT 5;
```

## Support and Monitoring

### Vercel Dashboard
- Monitor function execution logs
- Check cron job status
- View error messages and stack traces

### Google Sheets
- Verify data is being written correctly
- Check timestamps for backup frequency
- Monitor sheet size and performance

### Database Monitoring
- Check backup_logs table regularly
- Set up alerts for backup failures
- Monitor database performance during backups

This backup system provides reliable, automated protection for your attendance system data with comprehensive monitoring and error handling.
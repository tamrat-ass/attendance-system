# Backup System Deployment Checklist

## Pre-Deployment Setup

### ✅ 1. Install Dependencies
```bash
npm install googleapis pg @types/pg
```

### ✅ 2. Google Cloud Setup
- [ ] Create Google Cloud project
- [ ] Enable Google Sheets API
- [ ] Create service account
- [ ] Download service account JSON key
- [ ] Create Google Sheet
- [ ] Share sheet with service account email

### ✅ 3. Database Setup
- [ ] Run `CREATE_BACKUP_LOGS_TABLE.sql` in Neon database
- [ ] Verify tables exist: `students`, `attendance`, `backup_logs`
- [ ] Test database connection

### ✅ 4. Environment Variables
- [ ] `DATABASE_URL` - Neon PostgreSQL connection string
- [ ] `GOOGLE_SPREADSHEET_ID` - Google Sheet ID from URL
- [ ] `GOOGLE_SERVICE_ACCOUNT_KEY` - Complete JSON from downloaded file
- [ ] `BACKUP_API_KEY` - Secure random string (32+ characters)
- [ ] `VERCEL_URL` - Your app URL (optional, auto-detected)

## Deployment Steps

### ✅ 1. Code Deployment
```bash
# Commit all backup system files
git add .
git commit -m "feat: Add automatic backup system with Google Sheets integration"
git push origin main

# Deploy to Vercel
vercel --prod
```

### ✅ 2. Verify File Structure
Ensure these files are deployed:
- [ ] `app/api/backup/route.ts`
- [ ] `app/api/backup/setup/route.ts`
- [ ] `app/api/backup/manual/route.ts`
- [ ] `vercel.json`
- [ ] `components/backup-dashboard.tsx` (optional)

### ✅ 3. Environment Variables in Vercel
1. Go to Vercel Dashboard > Project > Settings > Environment Variables
2. Add each required variable:
   - [ ] `DATABASE_URL`
   - [ ] `GOOGLE_SPREADSHEET_ID`
   - [ ] `GOOGLE_SERVICE_ACCOUNT_KEY`
   - [ ] `BACKUP_API_KEY`

### ✅ 4. Initial Setup
```bash
# Setup Google Sheets structure
curl -X POST https://your-app.vercel.app/api/backup/setup

# Expected response:
# {
#   "success": true,
#   "message": "Google Sheets setup completed successfully",
#   "spreadsheetId": "your-sheet-id",
#   "sheets": ["Students", "Attendance"]
# }
```

### ✅ 5. Test Manual Backup
```bash
# Trigger manual backup
curl -X POST https://your-app.vercel.app/api/backup/manual \
  -H "Authorization: Bearer YOUR_BACKUP_API_KEY"

# Expected response:
# {
#   "success": true,
#   "message": "Manual backup completed",
#   "result": {
#     "success": true,
#     "data": {
#       "studentsCount": 5,
#       "attendanceCount": 10,
#       "duration": "2341ms",
#       "timestamp": "2024-01-15T10:30:00.000Z"
#     }
#   }
# }
```

### ✅ 6. Verify Cron Job
- [ ] Check Vercel Dashboard > Functions tab
- [ ] Verify cron job is scheduled (Pro plan required)
- [ ] Wait for first automatic execution at 2 AM UTC
- [ ] Check execution logs in Vercel dashboard

## Post-Deployment Verification

### ✅ 1. Google Sheets Verification
- [ ] Open your Google Sheet
- [ ] Verify "Students" sheet exists with headers
- [ ] Verify "Attendance" sheet exists with headers
- [ ] Check data is populated after backup runs

### ✅ 2. Database Verification
```sql
-- Check backup logs table
SELECT * FROM backup_logs ORDER BY created_at DESC LIMIT 5;

-- Verify recent successful backup
SELECT 
  status,
  students_count,
  attendance_count,
  created_at
FROM backup_logs 
WHERE status = 'success' 
ORDER BY created_at DESC 
LIMIT 1;
```

### ✅ 3. API Endpoints Testing
```bash
# Test backup status
curl https://your-app.vercel.app/api/backup?action=status

# Test setup status
curl https://your-app.vercel.app/api/backup/setup

# Test manual backup (with auth)
curl -X POST https://your-app.vercel.app/api/backup/manual \
  -H "Authorization: Bearer YOUR_BACKUP_API_KEY"
```

### ✅ 4. Error Handling Testing
```bash
# Test with invalid auth (should fail)
curl -X POST https://your-app.vercel.app/api/backup/manual \
  -H "Authorization: Bearer invalid-key"

# Expected: 401 Unauthorized
```

## Monitoring Setup

### ✅ 1. Backup Monitoring
- [ ] Set up alerts for backup failures
- [ ] Monitor backup_logs table regularly
- [ ] Check Google Sheets data integrity weekly

### ✅ 2. Performance Monitoring
- [ ] Monitor Vercel function execution times
- [ ] Check database connection performance
- [ ] Monitor Google Sheets API quota usage

### ✅ 3. Security Monitoring
- [ ] Rotate service account keys quarterly
- [ ] Monitor API key usage
- [ ] Review Google Sheets access permissions

## Troubleshooting Common Issues

### ❌ Issue: "Google Sheets authentication failed"
**Solution:**
1. Verify `GOOGLE_SERVICE_ACCOUNT_KEY` is valid JSON
2. Check service account has access to spreadsheet
3. Ensure Google Sheets API is enabled in Google Cloud

### ❌ Issue: "Database connection failed"
**Solution:**
1. Verify `DATABASE_URL` is correct
2. Check Neon database is running
3. Verify SSL settings in connection string

### ❌ Issue: "Cron job not executing"
**Solution:**
1. Verify Vercel Pro plan (required for cron)
2. Check `vercel.json` configuration
3. Monitor Vercel dashboard for cron logs

### ❌ Issue: "Backup logs table doesn't exist"
**Solution:**
1. Run `CREATE_BACKUP_LOGS_TABLE.sql` in database
2. Verify table creation with `\dt` command
3. Check database permissions

## Success Criteria

### ✅ Deployment is successful when:
- [ ] Manual backup completes successfully
- [ ] Google Sheets are populated with data
- [ ] Backup logs show successful entries
- [ ] Cron job is scheduled in Vercel
- [ ] All API endpoints respond correctly
- [ ] Error handling works as expected

### ✅ System is production-ready when:
- [ ] Automatic backups run daily at 2 AM UTC
- [ ] Students table is completely backed up
- [ ] Attendance table shows incremental backups
- [ ] Backup failures are logged and alerting works
- [ ] Manual backup triggers work with authentication
- [ ] Google Sheets formatting is applied correctly

## Maintenance Schedule

### Daily
- [ ] Check backup_logs for failures

### Weekly  
- [ ] Verify Google Sheets data integrity
- [ ] Review backup performance metrics

### Monthly
- [ ] Test manual backup process
- [ ] Review error logs and resolve issues

### Quarterly
- [ ] Rotate service account keys
- [ ] Update backup retention policies
- [ ] Performance optimization review

## Emergency Procedures

### If Backups Fail
1. Check Vercel function logs
2. Verify environment variables
3. Test database connectivity
4. Check Google Sheets API quotas
5. Trigger manual backup to isolate issue

### If Data Loss Occurs
1. Check most recent Google Sheets backup
2. Verify backup_logs for last successful backup
3. Restore from Google Sheets if needed
4. Investigate root cause of data loss

### If Google Sheets Access Lost
1. Verify service account permissions
2. Check if spreadsheet was deleted/moved
3. Create new spreadsheet if needed
4. Update `GOOGLE_SPREADSHEET_ID` environment variable
5. Run setup API to recreate structure

This checklist ensures a reliable, monitored backup system that protects your attendance data with comprehensive error handling and recovery procedures.
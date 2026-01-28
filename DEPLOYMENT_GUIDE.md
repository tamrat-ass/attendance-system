# Vercel Deployment Guide - Web Application Only

## Pre-deployment Checklist ✅
- [x] Build successful (`npm run build` completed)
- [x] Flutter app excluded from deployment
- [x] Environment variables configured
- [x] Vercel configuration updated

## Deployment Steps

### Option 1: Via Vercel Dashboard (Recommended)
1. Go to: https://vercel.com/ttu301982-8296s-projects
2. Click "Add New..." → "Project"
3. Choose "Import Git Repository"
4. Select: `kingta-glitch/school-attendance-management-system`
5. Configure project settings:
   - Framework: Next.js
   - Root Directory: ./
   - Build Command: npm run build
6. Add environment variables (see below)
7. Deploy!

### Option 2: Via CLI (if authentication works)
```bash
vercel --prod
```

## Required Environment Variables
Set these in your Vercel project settings:

```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=tame.assu23@gmail.com
SMTP_PASS=your-16-character-app-password-here
NEXT_PUBLIC_BASE_URL=https://your-project-name.vercel.app
```

## Database Setup
Your project uses Vercel Postgres. Make sure to:
1. Add Vercel Postgres to your project
2. Run your database setup scripts
3. Update connection strings

## Files Excluded from Deployment
- mk-attendance-flutter/ (Flutter app)
- *.apk files
- *.bat files
- *.sql files
- Test files
- Documentation files

## Post-deployment
1. Test all API endpoints
2. Verify database connections
3. Test email functionality
4. Check cron jobs are working
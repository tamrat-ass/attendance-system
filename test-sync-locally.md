# Test Attendance Sync Locally

## Quick Local Test Setup

### 1. Start Local Server
```bash
npm run dev
# Server will run on http://localhost:3000
```

### 2. Find Your Local IP
```bash
# Windows
ipconfig
# Look for IPv4 Address (e.g., 192.168.1.15)

# Or check the Next.js output - it shows Network IP
```

### 3. Update Mobile App for Local Testing
The Flutter app is now configured to use: `http://192.168.1.15:3000/api`

### 4. Build & Install Mobile App
```bash
cd mk-attendance-flutter
flutter build apk --release
# Install the APK on your phone
```

### 5. Test Sync
1. Open web app: `http://localhost:3000`
2. Open mobile app on phone
3. Mark attendance on mobile → should appear on web in 5 seconds
4. Mark attendance on web → should appear on mobile on refresh

### 6. Revert for Production
When ready for production, change back to:
```dart
static const String baseUrl = 'https://mk-attendance.vercel.app/api';
```

## Alternative: Test with Production Web + Local Mobile

Keep your web app on Vercel, just test mobile app locally:
1. Web stays at: `https://mk-attendance.vercel.app`
2. Mobile points to local: `http://192.168.1.15:3000/api`
3. Both use same Neon database
4. Test sync between them

## What to Test
- [ ] Mobile save → Web shows notification
- [ ] Web save → Mobile sees on refresh  
- [ ] Sync status indicators work
- [ ] No duplicate records
- [ ] Cache clearing works
- [ ] Error handling works
# MK Attendance Mobile App - Deployment Guide

## 🚀 Production Deployment Options

### Option 1: Direct APK Distribution (Recommended for Internal Use)

#### Build Release APK
```bash
# Windows
build_release.bat

# Or manually:
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter build apk --release
```

#### Distribute APK
1. **APK Location**: `build/app/outputs/flutter-apk/app-release.apk`
2. **File Size**: ~15-20 MB
3. **Distribution Methods**:
   - Email to users
   - Upload to company server
   - Share via cloud storage (Google Drive, Dropbox)
   - WhatsApp/Telegram for small groups

#### User Installation
1. Download APK to Android device
2. Enable "Install from unknown sources" in Settings
3. Tap APK file to install
4. Open app and login with web app credentials

### Option 2: Google Play Store (For Public Distribution)

#### Prepare for Play Store
```bash
# Build App Bundle (required for Play Store)
flutter build appbundle --release
```

#### Play Store Steps
1. **Create Developer Account** ($25 one-time fee)
2. **Upload App Bundle**: `build/app/outputs/bundle/release/app-release.aab`
3. **Fill App Information**:
   - Title: "MK Attendance"
   - Description: "Mobile attendance management system"
   - Category: Education
   - Screenshots: Take from app
4. **Review Process**: 1-3 days
5. **Publish**: Available worldwide

### Option 3: Internal App Distribution

#### Firebase App Distribution (Free)
1. Create Firebase project
2. Add Android app
3. Upload APK to Firebase
4. Share download links with users

#### Microsoft App Center (Free)
1. Create App Center account
2. Create new app
3. Upload APK
4. Distribute to testers

## 📱 App Information

### Technical Details
- **Package Name**: `com.mkattendance.mk_attendance`
- **Version**: 1.0.0
- **Min Android**: 5.0 (API 21)
- **Target Android**: Latest
- **Permissions**: Internet, Storage
- **Size**: ~15-20 MB

### Features
- ✅ Login with web app credentials
- ✅ Mark attendance (offline capable)
- ✅ Manage students
- ✅ Generate reports
- ✅ Export CSV files
- ✅ Ethiopian calendar support
- ✅ Real-time sync with web app

## 🔧 Configuration

### API Endpoint
The app is pre-configured to connect to:
```
https://mk-attendance.vercel.app/api
```

### Database
Uses your existing Neon PostgreSQL database (no changes needed)

### Authentication
Same login credentials as web application

## 📊 User Guide

### First Time Setup
1. Install APK on Android device
2. Open "MK Attendance" app
3. Login with web app username/password
4. Start using all features

### Daily Usage
1. **Mark Attendance**: Select date, class, mark students
2. **Manage Students**: Add, edit, delete student records
3. **View Reports**: Generate attendance reports
4. **Export Data**: Download CSV files to device

### Offline Mode
- App works without internet connection
- Data syncs automatically when connected
- All features available offline

## 🔒 Security

### Data Protection
- All API calls encrypted (HTTPS)
- User credentials stored securely
- No sensitive data cached
- Automatic logout after inactivity

### Privacy
- No data collection
- No analytics tracking
- No ads or third-party services
- Local data only

## 🐛 Troubleshooting

### Common Issues

#### "App not installed"
- Enable "Install from unknown sources"
- Check available storage space
- Try downloading APK again

#### "Login failed"
- Check internet connection
- Verify credentials work on web app
- Ensure web app is accessible

#### "Sync issues"
- Check internet connection
- Verify API endpoint is reachable
- Try logout and login again

### Support
1. Check web app is working first
2. Verify internet connection
3. Try restarting the app
4. Clear app data if needed

## 📈 Updates

### Updating the App
1. Build new APK with updated version
2. Distribute new APK to users
3. Users install over existing app
4. Data is preserved during update

### Version Management
- Update version in `pubspec.yaml`
- Build new release
- Test thoroughly before distribution

## 🎯 Success Metrics

### Expected Performance
- **App Launch**: Under 3 seconds
- **Login Time**: Under 5 seconds
- **Data Sync**: Under 10 seconds
- **Offline Mode**: Instant response

### User Adoption
- Easy installation process
- Familiar interface (matches web app)
- Offline capability advantage
- Mobile-optimized experience

## 📞 Support Information

### For Users
- Login issues: Check web app first
- Technical problems: Contact admin
- Feature requests: Submit feedback

### For Administrators
- APK distribution: Use secure channels
- User training: Provide demo session
- Updates: Plan regular update cycles

Your MK Attendance mobile app is ready for production deployment! 🎉
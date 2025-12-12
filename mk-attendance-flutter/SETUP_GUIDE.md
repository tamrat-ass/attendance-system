# Flutter Setup Guide for MK Attendance Mobile App

## 🚀 Quick Start (5 minutes)

### Step 1: Install Flutter

**Windows:**
1. Download Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter`
3. Add `C:\flutter\bin` to your PATH environment variable
4. Run `flutter doctor` in command prompt

**macOS:**
1. Download Flutter SDK: https://docs.flutter.dev/get-started/install/macos
2. Extract to `/Users/[username]/flutter`
3. Add to PATH in `.zshrc` or `.bash_profile`
4. Run `flutter doctor` in terminal

### Step 2: Install Android Studio

1. Download: https://developer.android.com/studio
2. Install with default settings
3. Open Android Studio → Configure → SDK Manager
4. Install latest Android SDK

### Step 3: Setup Android Device

**Option A: Physical Device**
1. Enable Developer Options on your Android phone
2. Enable USB Debugging
3. Connect via USB cable

**Option B: Emulator**
1. Open Android Studio → AVD Manager
2. Create Virtual Device
3. Choose Pixel 4 or similar
4. Download system image (API 30+)
5. Start emulator

### Step 4: Run the App

```bash
cd mk-attendance-flutter
flutter pub get
flutter packages pub run build_runner build
flutter run
```

## 🔧 Detailed Setup

### Prerequisites Checklist

- [ ] Flutter SDK installed
- [ ] Android Studio installed
- [ ] Android device/emulator ready
- [ ] Internet connection for API calls

### Verify Installation

Run these commands to verify everything is working:

```bash
flutter doctor
flutter devices
flutter --version
```

You should see:
- ✅ Flutter (Channel stable)
- ✅ Android toolchain
- ✅ Connected device

### Build the App

1. **Get dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate model files:**
   ```bash
   flutter packages pub run build_runner build
   ```

3. **Run on device:**
   ```bash
   flutter run
   ```

4. **Build APK (optional):**
   ```bash
   flutter build apk --release
   ```

## 📱 Testing the App

### Login Test
1. Open the app
2. Use your web app login credentials
3. Should redirect to dashboard

### Sync Test
1. Mark attendance on mobile
2. Check web app - changes should appear
3. Add student on web app
4. Refresh mobile - new student should appear

## 🐛 Common Issues & Solutions

### Issue: "Flutter not found"
**Solution:** Add Flutter to your PATH environment variable

### Issue: "No connected devices"
**Solution:** 
- Enable USB debugging on phone
- Or start Android emulator

### Issue: "Build failed"
**Solution:**
```bash
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Issue: "API connection failed"
**Solution:**
- Check internet connection
- Verify web app is running at https://mk-attendance.vercel.app
- Try login on web app first

## 🎯 Next Steps

Once the app is running:

1. **Test all features** - login, attendance, students, reports
2. **Verify sync** - make changes on both mobile and web
3. **Install on multiple devices** - share APK with team
4. **Customize** - modify colors, logos, etc. if needed

## 📞 Support

If you encounter issues:

1. Run `flutter doctor` and fix any issues shown
2. Check the error messages in terminal
3. Verify your web app API is working
4. Try on a different device/emulator

The mobile app uses your existing web application's API, so if the web app works, the mobile app should work too!

## 🚀 Production Deployment

To deploy to Google Play Store:

1. **Build release APK:**
   ```bash
   flutter build apk --release
   ```

2. **Build App Bundle:**
   ```bash
   flutter build appbundle --release
   ```

3. **Upload to Play Console**
4. **Follow Google Play guidelines**

Your MK Attendance mobile app is now ready! 🎉
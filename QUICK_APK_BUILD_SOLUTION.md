# Quick APK Build Solution

## Problem
OneDrive is locking files and preventing the Flutter build process.

## Immediate Solutions

### Option 1: Temporary OneDrive Pause (Fastest)
1. **Right-click OneDrive icon** in system tray
2. **Select "Pause syncing"** → Choose "2 hours"
3. **Run build command**:
   ```bash
   cd mk-attendance-flutter
   flutter build apk --release --target-platform android-arm64
   ```
4. **Resume OneDrive** after build completes

### Option 2: Move Project (Recommended)
1. **Copy entire project** to: `C:\temp\attendance-system`
2. **Open command prompt** in new location
3. **Run build**:
   ```bash
   cd C:\temp\attendance-system\mk-attendance-flutter
   flutter build apk --release --target-platform android-arm64
   ```

### Option 3: Use Build Script
1. **Run as Administrator**: `build_optimized_apk.bat`
2. **If fails**, try Option 1 or 2 first

## Expected Results After Build

### APK Location
```
mk-attendance-flutter\build\app\outputs\flutter-apk\app-release.apk
```

### APK Size
- **Target**: 30-45 MB (optimized)
- **Compatible**: ARM64 Android devices (99% of modern phones)

### Sharing the APK
1. **Copy APK** from build folder
2. **Rename** to: `MK-Attendance-v1.0.apk`
3. **Share via**:
   - Email attachment
   - Google Drive/Dropbox
   - USB transfer
   - WhatsApp (if under 100MB)

## Installation Instructions for Users

### For Android Users:
1. **Enable "Unknown Sources"**:
   - Settings → Security → Unknown Sources (ON)
   - OR Settings → Apps → Special Access → Install Unknown Apps
2. **Download APK** to phone
3. **Tap APK file** → Install
4. **Open app** and login

### Default Login Credentials:
- **Username**: admin
- **Password**: admin123
- **Or check**: WORKING_CREDENTIALS.md

## Optimizations Applied ✅
- Code shrinking enabled
- Resource optimization
- Unused dependencies removed
- ProGuard optimization
- Icon tree-shaking (99.5% reduction)
- ARM64 target only

## Troubleshooting

### If Build Still Fails:
1. **Close all IDEs** (VS Code, Android Studio)
2. **End Flutter processes** in Task Manager
3. **Restart computer**
4. **Try Option 2** (move project)

### If APK Too Large:
- Current optimizations should reduce to 30-45MB
- If still large, we can remove more features

The optimized APK will be ready for distribution once the OneDrive issue is resolved!
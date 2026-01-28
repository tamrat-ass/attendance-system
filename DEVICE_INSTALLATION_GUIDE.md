# 📱 MK Attendance - Device Installation Guide

## 🚀 Quick Installation Steps

### Method 1: Automatic Installation (Recommended)
1. **Connect your device** via USB cable
2. **Enable USB Debugging**:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times to enable Developer Options
   - Go to Settings > Developer Options
   - Enable "USB Debugging"
3. **Run the installer**: `build_and_install.bat`
4. **Allow installation** when prompted on device

### Method 2: Manual Installation
1. **Copy APK** to your device from: `build/app/outputs/flutter-apk/`
2. **Enable Unknown Sources**:
   - Settings > Security > Unknown Sources (Android 6-7)
   - Settings > Apps > Special Access > Install Unknown Apps (Android 8+)
3. **Install APK**:
   - Open file manager on device
   - Navigate to APK file
   - Tap to install
   - Grant permissions when asked

## 🔧 Troubleshooting

### "App not installed" Error
- **Solution 1**: Try different APK architecture
  - ARM64: `app-arm64-v8a-release.apk` (newer devices)
  - ARM32: `app-armeabi-v7a-release.apk` (older devices)
  - Universal: `app-release.apk` (works on all devices)

### "Parse Error"
- **Cause**: Wrong architecture or corrupted download
- **Solution**: Download correct APK for your device

### "Installation blocked"
- **Cause**: Security settings
- **Solution**: Enable "Unknown Sources" or "Install Unknown Apps"

## 📋 Device Requirements
- **Android Version**: 6.0 or higher
- **RAM**: 2GB minimum, 4GB recommended
- **Storage**: 50MB free space
- **Architecture**: ARM64 or ARM32

## 🔍 Check Your Device Architecture
1. Install **CPU-Z** from Play Store
2. Go to **SOC** tab
3. Check **Architecture**:
   - ARMv8 = Use ARM64 APK
   - ARMv7 = Use ARM32 APK

## 📞 Installation Support
If installation fails:
1. Check Android version (must be 6.0+)
2. Ensure sufficient storage space
3. Try different APK architecture
4. Restart device and try again
5. Contact support with device model and Android version

## ✅ Post-Installation
After successful installation:
1. **Grant Permissions**: Camera, Storage (if requested)
2. **Configure Server**: Enter your server URL
3. **Test Login**: Use your credentials
4. **Check QR Scanner**: Test camera functionality

---
**Need Help?** Check your device specifications and try the appropriate APK file.
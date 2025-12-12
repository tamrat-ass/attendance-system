# 📱 Quick Install Reference

## 🚀 One-Click Installation

Just run any of these scripts:

```bash
# Option 1: Batch file (Windows)
simple_push.bat

# Option 2: PowerShell (Recommended)
install_to_phone.ps1

# Option 3: Full featured
install_to_phone.bat
```

## ⚡ Manual Commands (If needed)

```bash
# 1. Check device
adb devices

# 2. Build app
cd mk-attendance-flutter && flutter build apk --release && cd ..

# 3. Install (Working Method)
adb push "mk-attendance-flutter\build\app\outputs\flutter-apk\app-release.apk" /data/local/tmp/
adb shell pm install -r /data/local/tmp/app-release.apk
adb shell am start -n com.mkattendance.mk_attendance/.MainActivity
```

## ✅ Success Indicators

- Device shows in `adb devices`
- Build completes without errors  
- Install shows "Success"
- App launches automatically
- "MK Attendance" appears in phone

## 🔧 Prerequisites

1. **USB Debugging enabled** on phone
2. **Phone connected** via USB
3. **ADB installed** (comes with Android SDK)
4. **Flutter SDK** installed

---

*This method has been tested and works reliably!*
@echo off
echo Building Mobile App (Fixed Version)...
cd mk-attendance-flutter
flutter clean
flutter pub get
flutter build apk --release
copy "build\app\outputs\flutter-apk\app-release.apk" "..\MK-Attendance-App-FIXED.apk"
cd ..
echo ✅ APK created: MK-Attendance-App-FIXED.apk
pause
@echo off
echo Building MK Attendance Flutter APK...
cd mk-attendance-flutter
flutter clean
flutter pub get
flutter build apk --release
cd ..
copy "mk-attendance-flutter\build\app\outputs\flutter-apk\app-release.apk" "MK-Attendance-Latest-v1.5.apk"
echo APK built successfully: MK-Attendance-Latest-v1.5.apk
pause
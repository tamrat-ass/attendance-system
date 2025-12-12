# MK Attendance - Phone Install Script (PowerShell)
Write-Host "========================================" -ForegroundColor Green
Write-Host "  MK Attendance - Phone Install Script" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Function to check command success
function Test-Command {
    param($Command, $ErrorMessage)
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: $ErrorMessage" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Step 1: Check device connection
Write-Host "Step 1: Checking device connection..." -ForegroundColor Yellow
$devices = adb devices
Test-Command "adb devices" "ADB not found or device not connected"

if ($devices -match "device$") {
    Write-Host "✅ Device connected successfully" -ForegroundColor Green
} else {
    Write-Host "ERROR: No device detected" -ForegroundColor Red
    Write-Host "Please ensure:" -ForegroundColor Yellow
    Write-Host "1. USB debugging is enabled on phone"
    Write-Host "2. Phone is connected via USB"
    Write-Host "3. Allow debugging prompt accepted"
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 2: Build Flutter app
Write-Host ""
Write-Host "Step 2: Building Flutter app..." -ForegroundColor Yellow
Set-Location "mk-attendance-flutter"
flutter clean
Test-Command "flutter clean" "Flutter clean failed"

flutter pub get
Test-Command "flutter pub get" "Flutter pub get failed"

flutter build apk --release
Test-Command "flutter build apk --release" "Flutter build failed"
Set-Location ".."

Write-Host "✅ Flutter build completed" -ForegroundColor Green

# Step 3: Copy APK
Write-Host ""
Write-Host "Step 3: Copying APK..." -ForegroundColor Yellow
Copy-Item "mk-attendance-flutter\build\app\outputs\flutter-apk\app-release.apk" "MK-Attendance-App-LATEST.apk"
if (Test-Path "MK-Attendance-App-LATEST.apk") {
    Write-Host "✅ APK copied successfully" -ForegroundColor Green
} else {
    Write-Host "ERROR: Failed to copy APK" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 4: Push APK to phone
Write-Host ""
Write-Host "Step 4: Pushing APK to phone..." -ForegroundColor Yellow
adb push "MK-Attendance-App-LATEST.apk" /data/local/tmp/
Test-Command "adb push" "Failed to push APK to phone"
Write-Host "✅ APK pushed to phone" -ForegroundColor Green

# Step 5: Install app
Write-Host ""
Write-Host "Step 5: Installing app on phone..." -ForegroundColor Yellow
$installResult = adb shell pm install -r /data/local/tmp/MK-Attendance-App-LATEST.apk
if ($installResult -match "Success") {
    Write-Host "✅ App installed successfully" -ForegroundColor Green
} else {
    Write-Host "ERROR: Installation failed" -ForegroundColor Red
    Write-Host "Result: $installResult" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 6: Launch app
Write-Host ""
Write-Host "Step 6: Launching app..." -ForegroundColor Yellow
adb shell am start -n com.mkattendance.mk_attendance/.MainActivity
Write-Host "✅ App launch command sent" -ForegroundColor Green

# Step 7: Clean up
Write-Host ""
Write-Host "Step 7: Cleaning up..." -ForegroundColor Yellow
adb shell rm /data/local/tmp/MK-Attendance-App-LATEST.apk
Write-Host "✅ Temporary files cleaned" -ForegroundColor Green

# Success message
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   ✅ Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "The MK Attendance app should now be:" -ForegroundColor Cyan
Write-Host "✅ Installed on your phone" -ForegroundColor Green
Write-Host "✅ Launching automatically" -ForegroundColor Green
Write-Host "✅ Available in your app drawer" -ForegroundColor Green
Write-Host ""
Write-Host "Features included:" -ForegroundColor Cyan
Write-Host "• Blue color theme" -ForegroundColor White
Write-Host "• Fixed dashboard buttons" -ForegroundColor White
Write-Host "• 'All Classes' filter in reports" -ForegroundColor White
Write-Host "• Correct Ethiopian date display" -ForegroundColor White
Write-Host "• Working change password" -ForegroundColor White
Write-Host "• Admin-only data management" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit"
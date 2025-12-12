# MK Attendance - Phone Push Script
Write-Host "🚀 Pushing MK Attendance App to your phone..." -ForegroundColor Green
Write-Host ""

# Look for MTP devices (phones)
$shell = New-Object -ComObject Shell.Application
$devices = $shell.NameSpace(17).Items() | Where-Object { $_.Name -like "*A16*" -or $_.Name -like "*Android*" -or $_.Name -like "*Phone*" }

if ($devices) {
    foreach ($device in $devices) {
        Write-Host "📱 Found device: $($device.Name)" -ForegroundColor Yellow
        
        # Try to access the device
        try {
            $deviceFolder = $device.GetFolder()
            $internalStorage = $deviceFolder.Items() | Where-Object { $_.Name -like "*Internal*" -or $_.Name -like "*Storage*" }
            
            if ($internalStorage) {
                $storageFolder = $internalStorage.GetFolder()
                $downloadFolder = $storageFolder.Items() | Where-Object { $_.Name -eq "Download" -or $_.Name -eq "Downloads" }
                
                if ($downloadFolder) {
                    Write-Host "📁 Found Downloads folder" -ForegroundColor Green
                    
                    # Copy APK
                    $apkPath = "MK-Attendance-App.apk"
                    if (Test-Path $apkPath) {
                        $downloadFolder.CopyHere($apkPath, 4)
                        Write-Host "✅ APK successfully copied to phone!" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "📱 Next steps on your phone:" -ForegroundColor Cyan
                        Write-Host "1. Open Downloads folder"
                        Write-Host "2. Tap MK-Attendance-App.apk"
                        Write-Host "3. Allow installation from unknown sources"
                        Write-Host "4. Tap Install"
                        exit 0
                    }
                }
            }
        }
        catch {
            Write-Host "❌ Could not access device: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "❌ Could not automatically push to phone" -ForegroundColor Red
Write-Host "📋 Manual steps:" -ForegroundColor Yellow
Write-Host "1. Open File Explorer"
Write-Host "2. Find your phone (Tamrat's A16)"
Write-Host "3. Copy MK-Attendance-App.apk to Downloads folder"
Write-Host "4. Install on phone"
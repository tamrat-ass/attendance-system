@echo off
echo Installing Flutter...

:: Create Flutter directory
if not exist "C:\flutter" mkdir "C:\flutter"

:: Download Flutter
echo Downloading Flutter SDK...
powershell -Command "Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip' -OutFile 'C:\flutter\flutter.zip'"

:: Extract Flutter
echo Extracting Flutter...
powershell -Command "Expand-Archive -Path 'C:\flutter\flutter.zip' -DestinationPath 'C:\' -Force"

:: Add to PATH
echo Adding Flutter to PATH...
setx PATH "%PATH%;C:\flutter\bin" /M

:: Clean up
del "C:\flutter\flutter.zip"

echo Flutter installation complete!
echo Please restart your command prompt and run: flutter doctor
pause
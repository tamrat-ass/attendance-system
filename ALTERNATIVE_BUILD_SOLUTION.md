# Alternative Build Solutions for OneDrive Issues

## Problem
OneDrive is locking Flutter build files, preventing successful compilation.

## Solution 1: Temporary OneDrive Stop (Recommended)

### Manual Steps:
1. **Stop OneDrive**:
   - Press `Ctrl + Shift + Esc` (Task Manager)
   - Find "Microsoft OneDrive" 
   - Right-click → End Task

2. **Clean Project**:
   ```cmd
   cd mk-attendance-flutter
   rmdir /s /q build
   rmdir /s /q .dart_tool
   flutter pub get
   ```

3. **Build & Install**:
   ```cmd
   flutter install --device-id=RF8Y40SBM3K
   ```

4. **Restart OneDrive**:
   - Press `Win + R`
   - Type: `%LOCALAPPDATA%\Microsoft\OneDrive\OneDrive.exe`
   - Press Enter

## Solution 2: Move Project (Permanent Fix)

### Steps:
1. **Copy entire project** to: `C:\temp\mk-attendance`
2. **Open Command Prompt** in new location
3. **Build normally**:
   ```cmd
   cd C:\temp\mk-attendance\mk-attendance-flutter
   flutter clean
   flutter pub get
   flutter install --device-id=RF8Y40SBM3K
   ```

## Solution 3: Use Automated Script

Run the `FIX_ONEDRIVE_BUILD_ISSUE.bat` file as Administrator.

## Solution 4: Debug Mode Build

If release build fails, try debug mode:
```cmd
flutter run --device-id=RF8Y40SBM3K --debug
```

## Expected Results After Fix

- ✅ No OneDrive file lock errors
- ✅ Clean build process
- ✅ Updated app installed on phone
- ✅ Removed reports/admin features
- ✅ Improved MK logo display

## Verification Steps

After successful build:
1. Open MK Attendance app on phone
2. Check bottom navigation (should have 3 tabs only)
3. Verify no "Reports" or "Admin" options
4. Check MK logo in welcome card
5. Test core functionality (login, attendance, students)

Choose the solution that works best for your setup!
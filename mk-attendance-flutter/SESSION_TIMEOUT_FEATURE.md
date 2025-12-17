# 🔐 Session Timeout Feature

## ✅ IMPLEMENTATION COMPLETE

This feature automatically logs out users after a period of inactivity to enhance security.

### 🔧 How It Works

1. **Session Tracking**: App saves timestamp when going to background
2. **Resume Check**: When app resumes, checks if session expired
3. **Auto Logout**: If expired, clears session and redirects to login

### ⚙️ Configuration

**Timeout Duration**: 3 minutes (configurable in `session_manager.dart`)

```dart
static const int sessionTimeoutMinutes = 3; // 🔴 Enhanced security - 3 minutes
```

### 📁 Files Modified

1. **`lib/services/session_manager.dart`** - Core session management
2. **`lib/main.dart`** - App lifecycle detection
3. **`lib/screens/login_screen.dart`** - Save session on login
4. **`lib/providers/auth_provider.dart`** - Clear session on logout

### 🚀 Features

- ✅ Automatic session timeout detection
- ✅ Background/foreground state tracking
- ✅ Secure session clearing
- ✅ Seamless user experience
- ✅ Configurable timeout duration

### 🔄 User Flow

1. User logs in → Session starts
2. User minimizes app → Timestamp saved
3. User returns after 3+ minutes → Auto logout
4. User sees login screen → Must re-authenticate

### 🛡️ Security Benefits

- Prevents unauthorized access on shared devices
- Protects sensitive attendance data
- Complies with security best practices
- Automatic cleanup of user sessions

### 🎯 Usage

The feature works automatically - no user interaction required. Users will be prompted to login again if they return to the app after the timeout period.
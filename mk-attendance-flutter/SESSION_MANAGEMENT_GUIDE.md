# 🔐 Session Management Guide

## 🎯 How Session Timeout Works

### 📱 **Current Implementation**

The session timeout feature automatically logs out users after **3 minutes** of inactivity for enhanced security.

### 🔧 **How It Works Behind the Scenes**

1. **Login**: When user logs in → Save current timestamp
2. **Background**: When app goes to background → Save "last active" time
3. **Resume**: When app resumes → Check if 3+ minutes passed
4. **Timeout**: If expired → Auto logout + redirect to login

---

## 🧪 **How to Test Session Timeout**

### **Method 1: Real-Time Testing (5 Minutes)**
1. **Login** to the app
2. **Minimize** the app (press home button)
3. **Wait 3+ minutes** (do other things)
4. **Reopen** the app
5. **Result**: Should automatically logout and show login screen

### **Method 2: Quick Testing (Instant)**
1. **Login** to the app
2. **Add test code** to simulate old session:
```dart
// Add this to any screen temporarily
final prefs = await SharedPreferences.getInstance();
final sixMinutesAgo = DateTime.now().subtract(Duration(minutes: 6));
await prefs.setInt('last_active_time', sixMinutesAgo.millisecondsSinceEpoch);
```
3. **Minimize and reopen** the app
4. **Result**: Should immediately logout

### **Method 3: Debug Testing**
1. **Add debug prints** to main.dart:
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) async {
  print('🔍 App State Changed: $state'); // Add this line
  
  if (state == AppLifecycleState.paused ||
      state == AppLifecycleState.detached) {
    await SessionManager.saveLastActiveTime();
    print('💾 Session saved on background'); // Add this line
  }

  if (state == AppLifecycleState.resumed) {
    final expired = await SessionManager.isSessionExpired();
    print('⏰ Session expired: $expired'); // Add this line
    
    if (expired) {
      print('🚪 Auto-logout triggered'); // Add this line
      // ... rest of logout code
    }
  }
}
```

---

## ⚙️ **Session Configuration**

### **Timeout Duration**
Located in `lib/services/session_manager.dart`:
```dart
static const int sessionTimeoutMinutes = 5; // 🔴 CHANGE TIME HERE
```

**To Change Timeout:**
1. Open `session_manager.dart`
2. Change the number (e.g., `10` for 10 minutes)
3. Rebuild the app

### **Supported Values:**
- `1` = 1 minute (testing)
- `3` = 3 minutes (current - enhanced security)
- `10` = 10 minutes (relaxed)
- `30` = 30 minutes (very relaxed)

---

## 🔍 **Troubleshooting Session Issues**

### **Session Not Working?**

#### **Check 1: App Lifecycle Detection**
```dart
// In main.dart, verify this exists:
class _MKAttendanceAppState extends State<MKAttendanceApp>
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ← Must be here
  }
}
```

#### **Check 2: Session Saving on Login**
```dart
// In login_screen.dart, verify this exists:
if (success) {
  await SessionManager.saveLastActiveTime(); // ← Must be here
}
```

#### **Check 3: SharedPreferences**
```dart
// Test if SharedPreferences works:
final prefs = await SharedPreferences.getInstance();
await prefs.setInt('test', 123);
final test = prefs.getInt('test');
print('SharedPreferences test: $test'); // Should print 123
```

### **Common Issues & Solutions**

#### **❌ "Session never expires"**
- **Cause**: App lifecycle not detected
- **Fix**: Ensure `WidgetsBindingObserver` is properly implemented

#### **❌ "Session expires immediately"**
- **Cause**: Session not saved on login
- **Fix**: Verify `SessionManager.saveLastActiveTime()` is called after successful login

#### **❌ "App doesn't logout automatically"**
- **Cause**: Navigation context issues
- **Fix**: Ensure `mounted` check and proper context usage

---

## 📊 **Session States Explained**

### **App Lifecycle States**
- **`resumed`**: App is active and visible
- **`paused`**: App is minimized but still in memory
- **`detached`**: App is completely closed
- **`inactive`**: App is transitioning (brief state)

### **Session Logic Flow**
```
Login → Save Time → Use App → Minimize (Save Time) → 
Wait 5+ Min → Resume → Check Time → Expired? → Logout
```

---

## 🛡️ **Security Benefits**

### **Why 3 Minutes?**
- **Shared Devices**: Prevents unauthorized access
- **Sensitive Data**: Protects student information
- **Compliance**: Meets security best practices
- **User Experience**: Quick enough for security, reasonable for normal use

### **What Gets Cleared on Timeout**
- ✅ User authentication token
- ✅ Cached user data
- ✅ Session timestamp
- ✅ All SharedPreferences data

---

## 🧪 **Manual Testing Checklist**

### **Basic Test**
- [ ] Login successfully
- [ ] Minimize app for 6+ minutes
- [ ] Reopen app
- [ ] Verify auto-logout to login screen

### **Edge Cases**
- [ ] Test with airplane mode on/off
- [ ] Test with app force-closed
- [ ] Test with device restart
- [ ] Test with multiple rapid minimize/resume cycles

### **Expected Behaviors**
- ✅ **Under 3 min**: Stay logged in
- ✅ **Over 3 min**: Auto logout
- ✅ **No session**: Redirect to login
- ✅ **Network issues**: Still logout (local check)

---

## 🔧 **Advanced Configuration**

### **Custom Timeout Per User Role**
```dart
// In session_manager.dart, you could add:
static int getTimeoutForRole(String role) {
  switch (role) {
    case 'admin': return 30; // 30 minutes for admins
    case 'manager': return 15; // 15 minutes for managers
    default: return 5; // 5 minutes for regular users
  }
}
```

### **Grace Period for Network Issues**
```dart
// Add network-aware timeout:
static Future<bool> isSessionExpiredWithGrace() async {
  final hasNetwork = await ConnectivityService.hasConnection();
  final baseTimeout = sessionTimeoutMinutes;
  final timeout = hasNetwork ? baseTimeout : baseTimeout * 2; // Double timeout offline
  
  // ... rest of logic
}
```

**Session Management is implemented and should be working!** Test it by minimizing the app for 5+ minutes. 🔐
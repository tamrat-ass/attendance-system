# 🚀 Quick Session Timeout Test

## 📱 **Instant Test Method**

### **Step 1: Add Test Code**
Add this code temporarily to any screen (like dashboard):

```dart
// Add this button to test session timeout instantly
ElevatedButton(
  onPressed: () async {
    // Simulate 6-minute old session
    final prefs = await SharedPreferences.getInstance();
    final sixMinutesAgo = DateTime.now().subtract(Duration(minutes: 6));
    await prefs.setInt('last_active_time', sixMinutesAgo.millisecondsSinceEpoch);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Session set to 6 minutes ago. Now minimize and reopen app!')),
    );
  },
  child: Text('Test Session Timeout'),
),
```

### **Step 2: Test Process**
1. **Tap** the "Test Session Timeout" button
2. **Minimize** the app (press home button)
3. **Reopen** the app immediately
4. **Result**: Should auto-logout and show login screen

---

## 🔍 **Debug Console Output**

When testing, you should see these logs in the console:

### **On App Minimize:**
```
🔍 App State Changed: AppLifecycleState.paused
💾 Session saved at: 2025-12-15 14:30:00.000
```

### **On App Resume (Normal):**
```
🔍 App State Changed: AppLifecycleState.resumed
⏰ Last active: 2025-12-15 14:30:00.000
⏰ Time elapsed: 2 minutes
⏰ Timeout limit: 5 minutes
⏰ Is expired: false
```

### **On App Resume (Expired):**
```
🔍 App State Changed: AppLifecycleState.resumed
⏰ Last active: 2025-12-15 14:25:00.000
⏰ Time elapsed: 6 minutes
⏰ Timeout limit: 5 minutes
⏰ Is expired: true
🚪 Auto-logout triggered
```

---

## ✅ **Expected Behavior**

### **Session Active (Under 3 min):**
- App resumes normally
- User stays logged in
- No logout occurs

### **Session Expired (Over 3 min):**
- App detects expired session
- Automatically logs out user
- Redirects to login screen
- Shows login form

---

## 🛠️ **If Session Timeout Isn't Working**

### **Check 1: Debug Logs**
- Look for the console output above
- If no logs appear, lifecycle detection isn't working

### **Check 2: SharedPreferences**
```dart
// Test SharedPreferences manually:
final prefs = await SharedPreferences.getInstance();
await prefs.setInt('test', 123);
final result = prefs.getInt('test');
print('SharedPreferences test: $result'); // Should print 123
```

### **Check 3: App Lifecycle**
- Ensure `WidgetsBindingObserver` is properly implemented
- Check that `addObserver` is called in `initState`

### **Check 4: Login Session Saving**
- Verify `SessionManager.saveLastActiveTime()` is called after login
- Check login screen implementation

---

## 🎯 **Real-World Test**

### **5-Minute Test:**
1. **Login** to the app
2. **Use the app** normally for a minute
3. **Minimize** the app (press home button)
4. **Wait exactly 4 minutes** (set a timer)
5. **Reopen** the app
6. **Expected**: Should automatically logout

### **Quick Test:**
1. **Login** to the app
2. **Add the test button code** above
3. **Tap** "Test Session Timeout"
4. **Minimize** and **reopen** immediately
5. **Expected**: Should automatically logout

**The session management is implemented and should work!** 🔐
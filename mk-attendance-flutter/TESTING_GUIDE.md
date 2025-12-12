# MK Attendance Mobile App - Testing Guide

## 🧪 **Complete Testing Checklist**

### **Pre-Testing Setup**
- [ ] Flutter SDK installed and working
- [ ] Android device/emulator connected
- [ ] Web app running at `https://mk-attendance.vercel.app`
- [ ] Test user credentials available

### **Build and Installation Testing**

#### **1. Build Process**
```bash
cd mk-attendance-flutter
flutter clean
flutter pub get
flutter packages pub run build_runner build
flutter run --debug
```

**Expected Results:**
- [ ] No build errors
- [ ] App launches successfully
- [ ] Splash screen appears for 3 seconds
- [ ] Login screen loads properly

#### **2. APK Build**
```bash
flutter build apk --release
```

**Expected Results:**
- [ ] APK builds without errors
- [ ] APK size is reasonable (~15-20 MB)
- [ ] APK installs on device
- [ ] App runs from APK installation

### **Functional Testing**

#### **3. Authentication Testing**

**Login Screen:**
- [ ] Username field accepts input
- [ ] Password field hides/shows password
- [ ] Validation works for empty fields
- [ ] Loading indicator shows during login
- [ ] Error messages display for invalid credentials
- [ ] Success login redirects to dashboard

**Test Cases:**
```
Valid Login:
- Username: [your web app username]
- Password: [your web app password]
- Expected: Successful login, redirect to dashboard

Invalid Login:
- Username: invalid
- Password: wrong
- Expected: Error message displayed

Empty Fields:
- Username: (empty)
- Password: (empty)
- Expected: Validation errors shown
```

#### **4. Dashboard Testing**

**Navigation:**
- [ ] Bottom navigation shows correct tabs based on permissions
- [ ] Tapping tabs switches screens correctly
- [ ] App bar shows correct title and date
- [ ] Logout menu works properly

**Permissions Testing:**
- [ ] Users see only tabs they have permission for
- [ ] Admin users see all tabs including Admin panel
- [ ] Regular users don't see Admin tab

#### **5. Attendance Marking Testing**

**Date Selection:**
- [ ] Date picker opens and works
- [ ] Ethiopian date displays correctly
- [ ] "Today" button sets current date
- [ ] Date changes trigger data reload

**Class Selection:**
- [ ] Dropdown shows all available classes
- [ ] Selecting class loads students for that class
- [ ] Student count displays correctly

**Student Search:**
- [ ] Search field filters students by name, ID, phone
- [ ] Clear button removes search filter
- [ ] Search works across all classes when searching

**Attendance Marking:**
- [ ] Status buttons (Present, Absent, Late, Permission) work
- [ ] Selected status highlights correctly
- [ ] Notes field accepts input
- [ ] Multiple students can be marked
- [ ] "Mark All Permission" button works

**Save Functionality:**
- [ ] Save button works with marked attendance
- [ ] Success message shows after save
- [ ] Saved attendance persists after app restart
- [ ] Changes sync with web app immediately

#### **6. Student Management Testing**

**Student List:**
- [ ] All students display correctly
- [ ] Search functionality works
- [ ] Class filter works
- [ ] Student cards show all information

**Add Student:**
- [ ] Add button opens dialog
- [ ] All fields validate properly
- [ ] Required fields show errors when empty
- [ ] Valid student saves successfully
- [ ] New student appears in list immediately
- [ ] New student syncs to web app

**Edit Student:**
- [ ] Edit menu option works
- [ ] Dialog pre-fills with existing data
- [ ] Changes save correctly
- [ ] Updated data syncs to web app

**Delete Student:**
- [ ] Delete confirmation dialog appears
- [ ] Deletion works correctly
- [ ] Student removed from list
- [ ] Deletion syncs to web app

#### **7. Reports Testing**

**Report Generation:**
- [ ] Class selection works
- [ ] Date range selection works
- [ ] Generate report button works
- [ ] Report data displays correctly
- [ ] Summary cards show correct totals

**Data Display:**
- [ ] Daily report table shows correct data
- [ ] Ethiopian dates display properly
- [ ] Status counts are accurate
- [ ] Percentages calculate correctly

**CSV Export:**
- [ ] Export button works
- [ ] CSV file generates successfully
- [ ] File saves to device storage
- [ ] CSV contains correct data with proper encoding

#### **8. Admin Panel Testing** (Admin users only)

**System Overview:**
- [ ] Status cards show correct information
- [ ] Student count is accurate
- [ ] Class count is accurate
- [ ] System status shows "Online"

**Admin Actions:**
- [ ] Export all data works
- [ ] Sync data works
- [ ] Clear cache works with confirmation
- [ ] Settings shows "coming soon" message

**User Information:**
- [ ] Current user details display correctly
- [ ] Permissions chips show correctly
- [ ] Role information is accurate

### **Synchronization Testing**

#### **9. Web-Mobile Sync Testing**

**Real-time Sync:**
- [ ] Add student on web → appears on mobile immediately
- [ ] Add student on mobile → appears on web immediately
- [ ] Mark attendance on web → shows on mobile
- [ ] Mark attendance on mobile → shows on web
- [ ] Edit student on web → updates on mobile
- [ ] Delete student on mobile → removes from web

**Data Consistency:**
- [ ] Student counts match between platforms
- [ ] Attendance records match exactly
- [ ] Class lists are identical
- [ ] User permissions sync correctly

#### **10. Offline Testing**

**Offline Mode:**
- [ ] App works without internet connection
- [ ] Previously loaded data remains available
- [ ] Offline indicator shows (if implemented)
- [ ] User can still navigate and view data

**Sync on Reconnect:**
- [ ] App detects when connection restored
- [ ] Pending changes sync automatically
- [ ] Conflicts resolve correctly
- [ ] Success message shows after sync

### **Performance Testing**

#### **11. Performance Metrics**

**App Launch:**
- [ ] Splash screen loads in < 1 second
- [ ] Login screen appears in < 3 seconds
- [ ] Dashboard loads in < 5 seconds

**Navigation:**
- [ ] Tab switching is instant
- [ ] Screen transitions are smooth
- [ ] No lag or stuttering

**Data Loading:**
- [ ] Student list loads in < 5 seconds
- [ ] Attendance data loads in < 3 seconds
- [ ] Reports generate in < 10 seconds

**Memory Usage:**
- [ ] App uses reasonable memory (< 100MB)
- [ ] No memory leaks during extended use
- [ ] App doesn't crash under normal use

### **UI/UX Testing**

#### **12. User Interface**

**Visual Design:**
- [ ] All text is readable
- [ ] Colors are consistent
- [ ] Icons are clear and appropriate
- [ ] Spacing and alignment look good

**Touch Interactions:**
- [ ] Buttons are large enough for touch
- [ ] Touch feedback works (ripple effects)
- [ ] Scrolling is smooth
- [ ] Gestures work as expected

**Responsive Design:**
- [ ] App works on different screen sizes
- [ ] Portrait and landscape orientations work
- [ ] Text scales appropriately
- [ ] No UI elements are cut off

#### **13. Ethiopian Calendar**

**Date Display:**
- [ ] Ethiopian dates show correctly
- [ ] Amharic text renders properly
- [ ] Date conversion is accurate
- [ ] Format matches web app

### **Error Handling Testing**

#### **14. Network Errors**

**Connection Issues:**
- [ ] Graceful handling of no internet
- [ ] Appropriate error messages
- [ ] Retry functionality works
- [ ] App doesn't crash on network errors

**Server Errors:**
- [ ] 500 errors handled gracefully
- [ ] Timeout errors show appropriate messages
- [ ] API errors display user-friendly messages

#### **15. Data Validation**

**Input Validation:**
- [ ] Empty required fields show errors
- [ ] Invalid data formats rejected
- [ ] Character limits enforced
- [ ] Special characters handled correctly

### **Security Testing**

#### **16. Authentication Security**

**Login Security:**
- [ ] Passwords are not stored in plain text
- [ ] Session management works correctly
- [ ] Auto-logout after inactivity (if implemented)
- [ ] Secure token handling

**Data Security:**
- [ ] API calls use HTTPS
- [ ] Sensitive data encrypted locally
- [ ] No data leakage in logs
- [ ] Proper permission checks

### **Device Testing**

#### **17. Multiple Devices**

**Test on Different Devices:**
- [ ] Low-end Android device (2GB RAM)
- [ ] Mid-range Android device (4GB RAM)
- [ ] High-end Android device (8GB+ RAM)
- [ ] Different screen sizes (5", 6", 7"+)
- [ ] Different Android versions (API 21+)

### **Final Acceptance Testing**

#### **18. End-to-End Scenarios**

**Complete Workflow:**
- [ ] Install app → Login → Mark attendance → Save → Verify on web
- [ ] Add student on mobile → Verify on web → Edit on web → Verify on mobile
- [ ] Generate report → Export CSV → Verify data accuracy
- [ ] Use app offline → Reconnect → Verify sync

**User Acceptance:**
- [ ] App meets all requirements
- [ ] Performance is acceptable
- [ ] UI is intuitive and user-friendly
- [ ] All features work as expected

## ✅ **Testing Sign-off**

**Tested by:** ________________  
**Date:** ________________  
**Version:** 1.0.0  
**Status:** ☐ Pass ☐ Fail  

**Notes:**
_________________________________
_________________________________
_________________________________

**Ready for Production:** ☐ Yes ☐ No

---

## 🚀 **Post-Testing Actions**

If all tests pass:
1. Build final release APK
2. Distribute to users
3. Monitor for issues
4. Collect user feedback

If tests fail:
1. Document issues
2. Fix problems
3. Re-test affected areas
4. Repeat until all tests pass
# Excel Report Column Fix

## Issue Fixed
The Excel report download was showing incorrect Amharic labels and wrong data mapping for attendance status columns.

## Problem
The column headers and data were mismatched:
- **Wrong**: `የተኘበት ቀን` was showing absent data
- **Wrong**: `የቀረበት ቀን` was showing present data

## Solution Applied

### ✅ **Corrected Column Headers:**
1. `የአባላቱ መለያ` - Student ID
2. `ሙሉ ስም` - Full Name  
3. `የሚያገለግሉበት ክፍል` - Class
4. `ስልክ` - Phone
5. `ጠቅላላ የጥናት ቀናት` - Total Study Days
6. `የተኙበት ቀን` - **Present** (day attended) ✅
7. `የቀሩበት ቀን` - **Absent** (day missed) ✅
8. `ዘግይቶ የመጣበት` - **Late** ✅
9. `ፈቃድ የተጠየቀበት` - **Permission** ✅
10. `ጠቅላላ የተገኙበት ቀናት` - Total Attended Days
11. `የመጣበት መጠን በ%` - Attendance Rate %

### ✅ **Corrected Data Mapping:**
```typescript
// Before (Wrong):
student.absent.toString(),     // was in የተኘበት ቀን column
student.present.toString(),    // was in የቀረበት ቀን column

// After (Fixed):
student.present.toString(),    // የተኙበት ቀን - present (day attended)
student.absent.toString(),     // የቀሩበት ቀን - absent (day missed)
student.late.toString(),       // ዘግይቶ የመጣበት - late
student.permission.toString(), // ፈቃድ የተጠየቀበት - permission
```

## Files Updated
- `components/dashboard/reports.tsx` - Fixed both Excel and CSV export functions

## What This Fixes
✅ **Excel Export**: Now shows correct Amharic labels with proper data mapping  
✅ **CSV Export**: Also fixed to match the correct column structure  
✅ **Data Accuracy**: Present/Absent data now appears in correct columns  
✅ **Amharic Labels**: All labels now match the expected Ethiopian terminology  

## Testing
After deployment, when you download the Excel report:
- `የተኙበት ቀን` column will show **present** days (students who attended)
- `የቀሩበት ቀን` column will show **absent** days (students who missed)
- `ዘግይቶ የመጣበት` column will show **late** instances
- `ፈቃድ የተጠየቀበት` column will show **permission** days

The Excel report will now have the correct Amharic headers with accurate attendance data mapping.
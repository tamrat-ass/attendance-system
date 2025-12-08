# Ethiopian Calendar Integration

## ✅ What's Been Added:

### 1. Ethiopian Date Utility (`lib/ethiopian-date.ts`)
- Converts between Gregorian and Ethiopian calendars
- Ethiopian calendar has 13 months (12 months of 30 days + Pagumen with 5-6 days)
- Ethiopian calendar is approximately 7-8 years behind Gregorian
- Includes Amharic month names: መስከረም, ጥቅምት, ኅዳር, etc.

### 2. Ethiopian Date Input Component (`components/ui/ethiopian-date-input.tsx`)
- Custom date picker with Ethiopian months and years
- Dropdown selectors for day, month, year
- Displays both Amharic and English month names
- Automatically handles month-specific day limits (Pagumen has max 6 days)

### 3. Updated Components:

**Attendance Marking:**
- Date picker now uses Ethiopian calendar
- Shows Ethiopian date in the header
- Stores dates as ISO strings (Gregorian) in database for compatibility

**Reports:**
- Date range filters use Ethiopian calendar
- Chart labels show Ethiopian dates (day/month format)
- Export includes Ethiopian date range in filename

**Header:**
- Shows current Ethiopian date prominently
- Also displays Gregorian date for reference

## 🔧 How It Works:

1. **User Interface**: All date inputs and displays use Ethiopian calendar
2. **Database Storage**: Dates are stored as Gregorian ISO strings for compatibility
3. **Conversion**: Automatic conversion between Ethiopian and Gregorian when needed
4. **Localization**: Uses Amharic month names with English fallback

## 📅 Ethiopian Calendar Info:

**Months:**
1. መስከረም (Meskerem) - 30 days
2. ጥቅምት (Tikimt) - 30 days  
3. ኅዳር (Hidar) - 30 days
4. ታኅሳስ (Tahsas) - 30 days
5. ጥር (Tir) - 30 days
6. የካቲት (Yekatit) - 30 days
7. መጋቢት (Megabit) - 30 days
8. ሚያዝያ (Miazia) - 30 days
9. ግንቦት (Ginbot) - 30 days
10. ሰኔ (Sene) - 30 days
11. ሐምሌ (Hamle) - 30 days
12. ነሐሴ (Nehase) - 30 days
13. ጳጉሜን (Pagumen) - 5 or 6 days

**New Year**: መስከረም 1 (around September 11 Gregorian)

## 🚀 Usage:

The system now automatically uses Ethiopian dates throughout. Users will see:
- Ethiopian date picker in attendance marking
- Ethiopian dates in reports
- Current Ethiopian date in header
- Ethiopian date ranges in exports

All database operations remain compatible with existing data.
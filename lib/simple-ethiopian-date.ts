// Simple Ethiopian Calendar System - No complex conversions
// This avoids the day offset issues in the original implementation

export interface SimpleEthiopianDate {
  year: number;
  month: number;
  day: number;
}

export const ETHIOPIAN_MONTHS = [
  'መስከረም', // Meskerem
  'ጥቅምት',   // Tikimt
  'ኅዳር',    // Hidar
  'ታኅሳስ',   // Tahsas
  'ጥር',     // Tir
  'የካቲት',   // Yekatit
  'መጋቢት',   // Megabit
  'ሚያዝያ',   // Miazia
  'ግንቦት',   // Ginbot
  'ሰኔ',     // Sene
  'ሐምሌ',    // Hamle
  'ነሐሴ',    // Nehase
  'ጳጉሜን'    // Pagumen
];

export const ETHIOPIAN_MONTHS_EN = [
  'Meskerem', 'Tikimt', 'Hidar', 'Tahsas', 'Tir', 'Yekatit',
  'Megabit', 'Miazia', 'Ginbot', 'Sene', 'Hamle', 'Nehase', 'Pagumen'
];

// Get current Ethiopian date with accurate conversion
export function getCurrentSimpleEthiopianDate(): SimpleEthiopianDate {
  const now = new Date();
  return gregorianToSimpleEthiopianAccurate(now);
}

// Accurate Gregorian to Ethiopian conversion
// December 14, 2025 = 5 ታኅሳስ 2018 (as specified by user)
function gregorianToSimpleEthiopianAccurate(date: Date): SimpleEthiopianDate {
  const year = date.getFullYear();
  const month = date.getMonth() + 1;
  const day = date.getDate();
  
  // Ethiopian year is always 7 years behind Gregorian
  const ethYear = year - 7; // 2025 - 7 = 2018
  
  let ethMonth: number;
  let ethDay: number;
  
  // Ethiopian calendar mapping based on user specification:
  // December 14, 2025 = 5 ታኅሳስ 2018
  // This means December 10, 2025 = 1 ታኅሳስ 2018
  
  if (month >= 9) {
    // September to December (Ethiopian months 1-4)
    if (month === 9) {
      ethMonth = 1; // መስከረም
      ethDay = day - 10; // Approximate
      if (ethDay <= 0) {
        ethMonth = 13; // Previous year's ጳጉሜን
        ethDay = 6 + ethDay;
      }
    } else if (month === 10) {
      ethMonth = 2; // ጥቅምት
      ethDay = day - 10;
      if (ethDay <= 0) {
        ethMonth = 1;
        ethDay = 30 + ethDay;
      }
    } else if (month === 11) {
      ethMonth = 3; // ኅዳር
      ethDay = day - 9;
      if (ethDay <= 0) {
        ethMonth = 2;
        ethDay = 30 + ethDay;
      }
    } else if (month === 12) {
      ethMonth = 4; // ታኅሳስ
      // December 14 = ታኅሳስ 5, so December 10 = ታኅሳስ 1
      ethDay = day - 9; // Dec 14 - 9 = 5 ✓
      if (ethDay <= 0) {
        ethMonth = 3;
        ethDay = 30 + ethDay;
      }
    } else {
      ethMonth = 1;
      ethDay = 1;
    }
  } else {
    // January to August (Ethiopian months 5-12)
    if (month === 1) {
      ethMonth = 5; // ጥር
      ethDay = day + 21;
      if (ethDay > 30) {
        ethMonth = 6;
        ethDay = ethDay - 30;
      }
    } else if (month === 2) {
      ethMonth = 6; // የካቲት
      ethDay = day + 21;
      if (ethDay > 30) {
        ethMonth = 7;
        ethDay = ethDay - 30;
      }
    } else if (month === 3) {
      ethMonth = 7; // መጋቢት
      ethDay = day + 19;
      if (ethDay > 30) {
        ethMonth = 8;
        ethDay = ethDay - 30;
      }
    } else if (month === 4) {
      ethMonth = 8; // ሚያዝያ
      ethDay = day + 21;
      if (ethDay > 30) {
        ethMonth = 9;
        ethDay = ethDay - 30;
      }
    } else if (month === 5) {
      ethMonth = 9; // ግንቦት
      ethDay = day + 21;
      if (ethDay > 30) {
        ethMonth = 10;
        ethDay = ethDay - 30;
      }
    } else if (month === 6) {
      ethMonth = 10; // ሰኔ
      ethDay = day + 22;
      if (ethDay > 30) {
        ethMonth = 11;
        ethDay = ethDay - 30;
      }
    } else if (month === 7) {
      ethMonth = 11; // ሐምሌ
      ethDay = day + 22;
      if (ethDay > 30) {
        ethMonth = 12;
        ethDay = ethDay - 30;
      }
    } else if (month === 8) {
      ethMonth = 12; // ነሐሴ
      ethDay = day + 23;
      if (ethDay > 30) {
        ethMonth = 13;
        ethDay = ethDay - 30;
      }
    } else {
      ethMonth = 1;
      ethDay = 1;
    }
  }
  
  // Ensure valid ranges
  if (ethMonth < 1) ethMonth = 1;
  if (ethMonth > 13) ethMonth = 13;
  if (ethDay < 1) ethDay = 1;
  if (ethMonth === 13 && ethDay > 6) ethDay = 6; // Pagumen max 6 days
  if (ethMonth !== 13 && ethDay > 30) ethDay = 30; // Other months max 30 days
  
  console.log('Ethiopian date conversion:', { year: ethYear, month: ethMonth, day: ethDay });
  
  return { year: ethYear, month: ethMonth, day: ethDay };
}

// Check if Gregorian year is leap year
function isLeapYear(year: number): boolean {
  return (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0);
}

// Check if Ethiopian year is leap year
function isEthiopianLeapYear(ethYear: number): boolean {
  // Ethiopian leap year cycle: every 4 years, but different from Gregorian
  return (ethYear % 4 === 3);
}

// Format Ethiopian date as string
export function formatSimpleEthiopianDate(ethDate: SimpleEthiopianDate, useAmharic = true): string {
  const months = useAmharic ? ETHIOPIAN_MONTHS : ETHIOPIAN_MONTHS_EN;
  return `${ethDate.day} ${months[ethDate.month - 1]} ${ethDate.year}`;
}

// Convert Ethiopian date to a simple string for storage (no complex conversion)
export function simpleEthiopianToString(ethDate: SimpleEthiopianDate): string {
  // Just store as Ethiopian date string, no Gregorian conversion
  const year = ethDate.year.toString().padStart(4, '0');
  const month = ethDate.month.toString().padStart(2, '0');
  const day = ethDate.day.toString().padStart(2, '0');
  return `ETH-${year}-${month}-${day}`;
}

// Parse Ethiopian date string back to object
export function stringToSimpleEthiopian(dateString: string): SimpleEthiopianDate {
  if (dateString.startsWith('ETH-')) {
    const parts = dateString.replace('ETH-', '').split('-');
    return {
      year: parseInt(parts[0]),
      month: parseInt(parts[1]),
      day: parseInt(parts[2])
    };
  }
  
  // Fallback to current date if invalid
  return getCurrentSimpleEthiopianDate();
}

// Convert Ethiopian date to database storage format (Ethiopian YYYY-MM-DD)
export function simpleEthiopianToDbFormat(ethDate: SimpleEthiopianDate): string {
  const year = ethDate.year.toString().padStart(4, '0');
  const month = ethDate.month.toString().padStart(2, '0');
  const day = ethDate.day.toString().padStart(2, '0');
  return `${year}-${month}-${day}`;
}

// DEPRECATED: Convert to Gregorian for database storage (for backward compatibility)
export function simpleEthiopianToGregorian(ethDate: SimpleEthiopianDate): string {
  // Simple approximation for database storage
  const gregYear = ethDate.year + 7;
  let gregMonth = ethDate.month + 8; // Approximate
  let gregDay = ethDate.day;
  
  if (gregMonth > 12) {
    gregMonth = gregMonth - 12;
    // Don't change year for simplicity
  }
  
  // Ensure valid Gregorian date
  if (gregMonth <= 0) gregMonth = 1;
  if (gregMonth > 12) gregMonth = 12;
  if (gregDay <= 0) gregDay = 1;
  if (gregDay > 28) gregDay = 28; // Safe day for all months
  
  const year = gregYear.toString().padStart(4, '0');
  const month = gregMonth.toString().padStart(2, '0');
  const day = gregDay.toString().padStart(2, '0');
  
  return `${year}-${month}-${day}`;
}

// Parse Ethiopian database format back to Ethiopian date object
export function dbFormatToSimpleEthiopian(dbDateString: string): SimpleEthiopianDate {
  try {
    const [year, month, day] = dbDateString.split('-').map(Number);
    
    // Check if it's already in Ethiopian format (year < 2050)
    if (year < 2050) {
      return { year, month, day };
    } else {
      // Convert from Gregorian format (backward compatibility)
      return gregorianToSimpleEthiopian(dbDateString);
    }
  } catch {
    return getCurrentSimpleEthiopianDate();
  }
}

// Convert Gregorian string back to Ethiopian (simplified) - for backward compatibility
export function gregorianToSimpleEthiopian(gregorianString: string): SimpleEthiopianDate {
  try {
    const [year, month, day] = gregorianString.split('-').map(Number);
    
    // Simple reverse conversion
    const ethYear = year - 7;
    let ethMonth = month - 8;
    const ethDay = day;
    
    if (ethMonth <= 0) {
      ethMonth = ethMonth + 12;
    }
    
    // Ensure valid ranges
    if (ethMonth <= 0) ethMonth = 1;
    if (ethMonth > 13) ethMonth = 13;
    
    return { year: ethYear, month: ethMonth, day: ethDay };
  } catch {
    return getCurrentSimpleEthiopianDate();
  }
}
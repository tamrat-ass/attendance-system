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

// More accurate Gregorian to Ethiopian conversion
function gregorianToSimpleEthiopianAccurate(date: Date): SimpleEthiopianDate {
  const year = date.getFullYear();
  const month = date.getMonth() + 1; // JS months are 0-based
  const day = date.getDate();
  
  // Ethiopian New Year starts on September 11 (or 12 in leap years)
  // Ethiopian calendar is 7-8 years behind Gregorian
  
  let ethYear: number;
  let ethMonth: number;
  let ethDay: number;
  
  // Determine if we're in the current Ethiopian year or previous
  const newYearStart = isLeapYear(year) ? 12 : 11; // Sept 11 or 12
  
  if (month > 9 || (month === 9 && day >= newYearStart)) {
    // We're in the new Ethiopian year
    ethYear = year - 7;
    
    // Calculate days since Ethiopian New Year
    const newYearDate = new Date(year, 8, newYearStart); // September is month 8 in JS
    const daysSinceNewYear = Math.floor((date.getTime() - newYearDate.getTime()) / (1000 * 60 * 60 * 24));
    
    // Convert days to Ethiopian month and day (0-indexed for calculation)
    ethMonth = Math.floor(daysSinceNewYear / 30) + 1;
    ethDay = (daysSinceNewYear % 30);
    
    // If day is 0, it means it's the 30th of the previous month
    if (ethDay === 0) {
      ethDay = 30;
    } else {
      ethDay = ethDay;
    }
    
    // Handle month 13 (Pagumen) - only 5 or 6 days
    if (ethMonth > 12) {
      ethMonth = 13;
      ethDay = daysSinceNewYear - (12 * 30);
      if (ethDay === 0) ethDay = 1;
      
      // Pagumen has max 5 days (6 in leap years)
      const maxPagumenDays = isEthiopianLeapYear(ethYear) ? 6 : 5;
      if (ethDay > maxPagumenDays) {
        ethYear++;
        ethMonth = 1;
        ethDay = ethDay - maxPagumenDays;
      }
    }
  } else {
    // We're still in the previous Ethiopian year
    ethYear = year - 8;
    
    // Calculate from the previous Ethiopian New Year
    const prevNewYearDate = new Date(year - 1, 8, isLeapYear(year - 1) ? 12 : 11);
    const daysSinceNewYear = Math.floor((date.getTime() - prevNewYearDate.getTime()) / (1000 * 60 * 60 * 24));
    
    ethMonth = Math.floor(daysSinceNewYear / 30) + 1;
    ethDay = (daysSinceNewYear % 30);
    
    if (ethDay === 0) {
      ethDay = 30;
    }
    
    if (ethMonth > 12) {
      ethMonth = 13;
      ethDay = daysSinceNewYear - (12 * 30);
      if (ethDay === 0) ethDay = 1;
    }
  }
  
  // Ensure valid ranges
  if (ethDay <= 0) ethDay = 1;
  if (ethMonth <= 0) ethMonth = 1;
  if (ethMonth > 13) ethMonth = 13;
  
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

// Convert to Gregorian for database storage (simplified)
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

// Convert Gregorian string back to Ethiopian (simplified)
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
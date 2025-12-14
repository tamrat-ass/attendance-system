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
function gregorianToSimpleEthiopianAccurate(date: Date): SimpleEthiopianDate {
  const year = date.getFullYear();
  const month = date.getMonth() + 1;
  const day = date.getDate();
  
  // Ethiopian New Year is September 11 (or 12 in leap year)
  // Ethiopian year is 7 or 8 years behind Gregorian
  
  let ethYear: number;
  let ethMonth: number;
  let ethDay: number;
  
  // Check if we're before or after Ethiopian New Year
  const ethNewYearDay = isLeapYear(year) ? 12 : 11;
  
  if (month < 9 || (month === 9 && day < ethNewYearDay)) {
    // Before Ethiopian New Year - still in previous Ethiopian year
    ethYear = year - 8;
    
    // Calculate from previous year's New Year
    const prevNewYearDay = isLeapYear(year - 1) ? 12 : 11;
    const prevNewYear = new Date(year - 1, 8, prevNewYearDay); // Sept is month 8
    const diffTime = date.getTime() - prevNewYear.getTime();
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24)) + 1; // +1 to include start day
    
    // Each Ethiopian month has exactly 30 days (except Pagumen)
    ethMonth = Math.floor(diffDays / 30) + 1;
    const remainder = diffDays % 30;
    ethDay = remainder === 0 ? 30 : remainder;
    
    // Adjust month if day is 30 and we calculated wrong month
    if (remainder === 0 && ethMonth > 1) {
      ethMonth = ethMonth - 1;
    }
  } else {
    // After Ethiopian New Year - in current Ethiopian year
    ethYear = year - 7;
    
    const newYear = new Date(year, 8, ethNewYearDay); // Sept is month 8
    const diffTime = date.getTime() - newYear.getTime();
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24)) + 1; // +1 to include start day
    
    // Each Ethiopian month has exactly 30 days (except Pagumen)
    ethMonth = Math.floor(diffDays / 30) + 1;
    const remainder = diffDays % 30;
    ethDay = remainder === 0 ? 30 : remainder;
    
    // Adjust month if day is 30 and we calculated wrong month
    if (remainder === 0 && ethMonth > 1) {
      ethMonth = ethMonth - 1;
    }
  }
  
  // Handle month 13 (Pagumen)
  if (ethMonth > 12) {
    ethMonth = 13;
    // Pagumen days calculation
    const totalDays = (ethMonth - 1) * 30 + ethDay;
    ethDay = totalDays - 360; // 12 months * 30 days
  }
  
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
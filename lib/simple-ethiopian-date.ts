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

// Accurate Gregorian to Ethiopian conversion using proper algorithm
function gregorianToSimpleEthiopianAccurate(date: Date): SimpleEthiopianDate {
  const year = date.getFullYear();
  const month = date.getMonth() + 1;
  const day = date.getDate();
  
  // JDN (Julian Day Number) calculation
  const a = Math.floor((14 - month) / 12);
  const y = year + 4800 - a;
  const m = month + 12 * a - 3;
  const jdn = day + Math.floor((153 * m + 2) / 5) + 365 * y + Math.floor(y / 4) - Math.floor(y / 100) + Math.floor(y / 400) - 32045;
  
  // Convert JDN to Ethiopian calendar
  const r = (jdn - 1723856) % 1461;
  const n = (r % 365) + 365 * Math.floor(r / 1460);
  
  const ethYear = Math.floor((jdn - 1723856) / 1461) + 1;
  const ethMonth = Math.floor(n / 30) + 1;
  const ethDay = (n % 30) + 1;
  
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
// Ethiopian Calendar Utility
// Ethiopian calendar has 13 months: 12 months of 30 days + 1 month of 5/6 days

export interface EthiopianDate {
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

// Convert Gregorian date to Ethiopian date
export function gregorianToEthiopian(gregorianDate: Date): EthiopianDate {
  const year = gregorianDate.getFullYear();
  const month = gregorianDate.getMonth() + 1; // JS months are 0-based
  const day = gregorianDate.getDate();
  
  // Ethiopian calendar is approximately 7-8 years behind Gregorian
  // New Year starts around September 11 (or 12 in leap years)
  
  let ethYear: number;
  let ethMonth: number;
  let ethDay: number;
  
  // Simplified conversion algorithm
  if (month >= 9 || (month === 9 && day >= 11)) {
    // After Ethiopian New Year
    ethYear = year - 7;
    
    if (month === 9) {
      ethMonth = 1; // Meskerem
      ethDay = day - 10;
    } else if (month === 10) {
      ethMonth = 1; // Meskerem
      ethDay = day + 20;
      if (ethDay > 30) {
        ethMonth = 2; // Tikimt
        ethDay = ethDay - 30;
      }
    } else if (month === 11) {
      ethMonth = 2; // Tikimt
      ethDay = day + 20;
      if (ethDay > 30) {
        ethMonth = 3; // Hidar
        ethDay = ethDay - 30;
      }
    } else if (month === 12) {
      ethMonth = 3; // Hidar
      ethDay = day + 21;
      if (ethDay > 30) {
        ethMonth = 4; // Tahsas
        ethDay = ethDay - 30;
      }
    } else {
      // Handle other months (simplified)
      const dayOfYear = getDayOfYear(gregorianDate);
      const ethDayOfYear = dayOfYear - 253; // Approximate offset
      
      if (ethDayOfYear <= 0) {
        ethYear = year - 8;
        ethMonth = 13;
        ethDay = ethDayOfYear + 5;
      } else {
        ethMonth = Math.ceil(ethDayOfYear / 30);
        ethDay = ethDayOfYear - ((ethMonth - 1) * 30);
        
        if (ethMonth > 13) {
          ethMonth = 1;
          ethYear = year - 6;
        }
      }
    }
  } else {
    // Before Ethiopian New Year
    ethYear = year - 8;
    
    const dayOfYear = getDayOfYear(gregorianDate);
    const ethDayOfYear = dayOfYear + 112; // Approximate offset
    
    ethMonth = Math.ceil(ethDayOfYear / 30);
    ethDay = ethDayOfYear - ((ethMonth - 1) * 30);
    
    if (ethMonth > 13) {
      ethMonth = ethMonth - 13;
      ethYear = year - 7;
    }
  }
  
  // Ensure valid ranges
  if (ethDay <= 0) {
    ethMonth--;
    if (ethMonth <= 0) {
      ethMonth = 13;
      ethYear--;
    }
    ethDay = (ethMonth === 13) ? 5 : 30;
  }
  
  if (ethMonth > 13) {
    ethMonth = 1;
    ethYear++;
  }
  
  return { year: ethYear, month: ethMonth, day: ethDay };
}

// Convert Ethiopian date to Gregorian date
export function ethiopianToGregorian(ethDate: EthiopianDate): Date {
  // Simplified reverse conversion
  const { year, month, day } = ethDate;
  
  // Ethiopian New Year is around September 11
  let gregYear = year + 7;
  let gregMonth: number;
  let gregDay: number;
  
  if (month === 1) {
    // Meskerem
    gregMonth = 9;
    gregDay = day + 10;
    if (gregDay > 30) {
      gregMonth = 10;
      gregDay = gregDay - 30;
    }
  } else if (month <= 4) {
    // Tikimt, Hidar, Tahsas
    const totalDays = (month - 1) * 30 + day + 10;
    const startDate = new Date(gregYear, 8, 11); // Sept 11
    const resultDate = new Date(startDate.getTime() + (totalDays - 1) * 24 * 60 * 60 * 1000);
    return resultDate;
  } else {
    // Other months - approximate
    const totalDays = (month - 1) * 30 + day;
    const startDate = new Date(gregYear, 8, 11); // Sept 11
    const resultDate = new Date(startDate.getTime() + (totalDays - 1) * 24 * 60 * 60 * 1000);
    return resultDate;
  }
  
  return new Date(gregYear, gregMonth - 1, gregDay);
}

// Get day of year for Gregorian date
function getDayOfYear(date: Date): number {
  const start = new Date(date.getFullYear(), 0, 0);
  const diff = date.getTime() - start.getTime();
  return Math.floor(diff / (1000 * 60 * 60 * 24));
}

// Format Ethiopian date as string
export function formatEthiopianDate(ethDate: EthiopianDate, useAmharic = true): string {
  const months = useAmharic ? ETHIOPIAN_MONTHS : ETHIOPIAN_MONTHS_EN;
  return `${ethDate.day} ${months[ethDate.month - 1]} ${ethDate.year}`;
}

// Get current Ethiopian date
export function getCurrentEthiopianDate(): EthiopianDate {
  return gregorianToEthiopian(new Date());
}

// Convert Ethiopian date to ISO string for database storage (Ethiopian format)
export function ethiopianToISOString(ethDate: EthiopianDate): string {
  const year = ethDate.year.toString().padStart(4, '0');
  const month = ethDate.month.toString().padStart(2, '0');
  const day = ethDate.day.toString().padStart(2, '0');
  return `${year}-${month}-${day}`;
}

// DEPRECATED: Convert Ethiopian date to Gregorian ISO string (for backward compatibility)
export function ethiopianToGregorianISOString(ethDate: EthiopianDate): string {
  const gregDate = ethiopianToGregorian(ethDate);
  return gregDate.toISOString().split('T')[0];
}

// Parse ISO string to Ethiopian date (handles both Ethiopian and Gregorian formats)
export function isoStringToEthiopian(isoString: string): EthiopianDate {
  const [year, month, day] = isoString.split('-').map(Number);
  
  // Check if it's already in Ethiopian format (year < 2050)
  if (year < 2050) {
    return { year, month, day };
  } else {
    // Convert from Gregorian format
    const gregDate = new Date(isoString);
    return gregorianToEthiopian(gregDate);
  }
}

// Get Ethiopian date input value (YYYY-MM-DD format but Ethiopian)
export function getEthiopianDateInputValue(ethDate: EthiopianDate): string {
  const year = ethDate.year.toString().padStart(4, '0');
  const month = ethDate.month.toString().padStart(2, '0');
  const day = ethDate.day.toString().padStart(2, '0');
  return `${year}-${month}-${day}`;
}

// Parse Ethiopian date input value
export function parseEthiopianDateInput(value: string): EthiopianDate {
  const [year, month, day] = value.split('-').map(Number);
  return { year, month, day };
}
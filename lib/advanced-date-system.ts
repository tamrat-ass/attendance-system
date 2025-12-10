// Smart Date System with Effective Working Date Logic
import { SimpleEthiopianDate, getCurrentSimpleEthiopianDate, simpleEthiopianToGregorian, gregorianToSimpleEthiopian } from './simple-ethiopian-date';

// System Parameters - Simplified
export interface DateSystemConfig {
  cutOffHour: number; // Hour when attendance day rolls over (e.g., 3 for 03:00 AM)
  maxHistoricalDays: number; // Maximum days back allowed (e.g., 30 days)
  maxFutureDays: number; // Maximum days forward allowed (e.g., 7 days)
}

export const DEFAULT_CONFIG: DateSystemConfig = {
  cutOffHour: 3, // 03:00 AM - after midnight work is for previous day
  maxHistoricalDays: 30, // 30 days back
  maxFutureDays: 7 // 7 days forward
};

export type DateStatus = 'EFFECTIVE' | 'ENABLED' | 'DISABLED';

export interface DateInfo {
  date: SimpleEthiopianDate;
  status: DateStatus;
  isEffectiveDate: boolean;
  isToday: boolean;
  reason?: string;
}

// Core Calculation: Effective Working Date (D_Effective)
// This handles late-night attendance marking for the previous day
export function getEffectiveWorkingDate(config: DateSystemConfig = DEFAULT_CONFIG): SimpleEthiopianDate {
  const now = new Date();
  const currentHour = now.getHours();
  
  console.log(`Current time: ${now.toLocaleTimeString()}, Hour: ${currentHour}, Cutoff: ${config.cutOffHour}`);
  
  // IF current time is BEFORE cutoff (e.g., 01:00 AM): Use yesterday as effective date
  // ELSE: Use today as effective date
  if (currentHour < config.cutOffHour) {
    const yesterday = new Date(now);
    yesterday.setDate(yesterday.getDate() - 1);
    const effectiveDate = gregorianToSimpleEthiopian(yesterday.toISOString().split('T')[0]);
    console.log('Before cutoff - Effective date is YESTERDAY:', effectiveDate);
    return effectiveDate;
  } else {
    const effectiveDate = getCurrentSimpleEthiopianDate();
    console.log('After cutoff - Effective date is TODAY:', effectiveDate);
    return effectiveDate;
  }
}

// Simple date validation functions
export function isDateInAllowedRange(date: SimpleEthiopianDate, config: DateSystemConfig = DEFAULT_CONFIG): boolean {
  const today = new Date();
  const dateGregorian = new Date(simpleEthiopianToGregorian(date));
  
  // Check historical limit
  const minDate = new Date(today);
  minDate.setDate(minDate.getDate() - config.maxHistoricalDays);
  
  // Check future limit
  const maxDate = new Date(today);
  maxDate.setDate(maxDate.getDate() + config.maxFutureDays);
  
  return dateGregorian >= minDate && dateGregorian <= maxDate;
}

// Check if date is the effective working date
export function isEffectiveDate(date: SimpleEthiopianDate, config: DateSystemConfig = DEFAULT_CONFIG): boolean {
  const effectiveDate = getEffectiveWorkingDate(config);
  return date.year === effectiveDate.year && 
         date.month === effectiveDate.month && 
         date.day === effectiveDate.day;
}

// Check if date is today (actual calendar day)
export function isToday(date: SimpleEthiopianDate): boolean {
  const today = getCurrentSimpleEthiopianDate();
  return date.year === today.year && date.month === today.month && date.day === today.day;
}

// Simplified Date Status Determination
export function getDateInfo(date: SimpleEthiopianDate, config: DateSystemConfig = DEFAULT_CONFIG): DateInfo {
  const dateInfo: DateInfo = {
    date,
    status: 'ENABLED',
    isEffectiveDate: isEffectiveDate(date, config),
    isToday: isToday(date)
  };
  
  // Check if date is within allowed range
  if (!isDateInAllowedRange(date, config)) {
    dateInfo.status = 'DISABLED';
    dateInfo.reason = `Date must be within ${config.maxHistoricalDays} days ago to ${config.maxFutureDays} days ahead`;
    return dateInfo;
  }
  
  // Mark effective date with special status
  if (dateInfo.isEffectiveDate) {
    dateInfo.status = 'EFFECTIVE';
    dateInfo.reason = 'Current working date (considering late-night cutoff)';
  }
  
  return dateInfo;
}

// Get smart default date for attendance system
export function getSmartDefaultDate(config: DateSystemConfig = DEFAULT_CONFIG): SimpleEthiopianDate {
  return getEffectiveWorkingDate(config);
}
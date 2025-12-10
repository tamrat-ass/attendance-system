'use client';

import { useState, useEffect } from 'react';
import { Label } from '@/components/ui/label';
import { Button } from '@/components/ui/button';
import { Calendar, ChevronDown } from 'lucide-react';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { 
  SimpleEthiopianDate, 
  ETHIOPIAN_MONTHS, 
  ETHIOPIAN_MONTHS_EN,
  getCurrentSimpleEthiopianDate,
  formatSimpleEthiopianDate,
  simpleEthiopianToGregorian,
  gregorianToSimpleEthiopian
} from '@/lib/simple-ethiopian-date';
import { getSmartDefaultDate, getDateInfo, isToday as checkIsToday } from '@/lib/advanced-date-system';

interface SimpleEthiopianDateInputProps {
  value?: string; // Gregorian ISO string for compatibility
  onChange: (gregorianIsoString: string) => void;
  label?: string;
  useAmharic?: boolean;
  className?: string;
}

export function SimpleEthiopianDateInput({ 
  value, 
  onChange, 
  label, 
  useAmharic = true,
  className = ""
}: SimpleEthiopianDateInputProps) {
  // Start with SMART default date (considers late-night work)
  const [ethDate, setEthDate] = useState<SimpleEthiopianDate>(() => {
    const smartDate = getSmartDefaultDate();
    console.log('Date picker initialized with SMART DEFAULT:', smartDate);
    return smartDate;
  });
  const [isOpen, setIsOpen] = useState(false);

  const months = useAmharic ? ETHIOPIAN_MONTHS : ETHIOPIAN_MONTHS_EN;

  // Force sync to smart default date on component mount
  useEffect(() => {
    const smartDate = getSmartDefaultDate();
    console.log('Force syncing to SMART DEFAULT:', smartDate);
    setEthDate(smartDate);
    
    // Notify parent component with smart default date
    const gregorianDate = simpleEthiopianToGregorian(smartDate);
    onChange(gregorianDate);
  }, []); // Empty dependency array - only run once on mount

  // Update when value changes (user selection)
  useEffect(() => {
    if (value) {
      const converted = gregorianToSimpleEthiopian(value);
      console.log('User selected date:', converted);
      setEthDate(converted);
    }
  }, [value]);

  // Simplified date change handling
  const handleDateChange = (newEthDate: SimpleEthiopianDate) => {
    setEthDate(newEthDate);
    const gregorianString = simpleEthiopianToGregorian(newEthDate);
    onChange(gregorianString);
  };

  const handleYearChange = (year: number) => {
    handleDateChange({ ...ethDate, year });
  };

  const handleMonthChange = (month: number) => {
    handleDateChange({ ...ethDate, month });
  };

  const handleDayClick = (day: number) => {
    handleDateChange({ ...ethDate, day });
    setIsOpen(false);
  };

  // Quick date buttons
  const goToToday = () => {
    const today = getCurrentSimpleEthiopianDate();
    handleDateChange(today);
    setIsOpen(false);
  };

  const goToPreviousDay = () => {
    let newDay = ethDate.day - 1;
    let newMonth = ethDate.month;
    let newYear = ethDate.year;
    
    if (newDay < 1) {
      newMonth = newMonth - 1;
      if (newMonth < 1) {
        newMonth = 13;
        newYear = newYear - 1;
      }
      newDay = newMonth === 13 ? 6 : 30;
    }
    
    handleDateChange({ year: newYear, month: newMonth, day: newDay });
  };

  const goToNextDay = () => {
    const maxDays = ethDate.month === 13 ? 6 : 30;
    let newDay = ethDate.day + 1;
    let newMonth = ethDate.month;
    let newYear = ethDate.year;
    
    if (newDay > maxDays) {
      newDay = 1;
      newMonth = newMonth + 1;
      if (newMonth > 13) {
        newMonth = 1;
        newYear = newYear + 1;
      }
    }
    
    handleDateChange({ year: newYear, month: newMonth, day: newDay });
  };

  // Generate year options
  const currentYear = getCurrentSimpleEthiopianDate().year;
  const yearOptions: number[] = [];
  for (let i = currentYear - 10; i <= currentYear + 5; i++) {
    yearOptions.push(i);
  }

  // Generate day options based on selected month
  const maxDays = ethDate.month === 13 ? 6 : 30; // Pagumen has 5-6 days
  const dayOptions: number[] = [];
  for (let i = 1; i <= maxDays; i++) {
    dayOptions.push(i);
  }

  // Check if selected date is today
  const today = getCurrentSimpleEthiopianDate();
  const isToday = today.year === ethDate.year && 
                  today.month === ethDate.month && 
                  today.day === ethDate.day;

  return (
    <div className={`space-y-2 ${className}`}>
      {label && <Label className="text-sm font-medium">{label}</Label>}
      
      {/* Quick navigation buttons */}
      <div className="flex gap-1">
        <Button
          variant="outline"
          size="sm"
          onClick={goToPreviousDay}
          className="px-2"
          title="Previous Day"
        >
          ←
        </Button>
        
        <Popover open={isOpen} onOpenChange={setIsOpen}>
          <PopoverTrigger asChild>
            <Button
              variant="outline"
              className={`flex-1 justify-between text-left font-normal ${
                isToday ? 'border-red-400 border-2 hover:border-red-500' : ''
              }`}
              onClick={() => setIsOpen(!isOpen)}
            >
              <div className="flex items-center gap-2">
                <Calendar className="h-4 w-4 text-muted-foreground" />
                <span>{formatSimpleEthiopianDate(ethDate, useAmharic)}</span>
              </div>
              <ChevronDown className="h-4 w-4 opacity-50" />
            </Button>
          </PopoverTrigger>
        
        <PopoverContent className="w-80 p-4 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 shadow-lg" align="start">
          <div className="space-y-4">
            {/* Year and Month selectors */}
            <div className="flex gap-2">
              <div className="flex-1">
                <Label className="text-xs text-muted-foreground">ዓመት (Year)</Label>
                <select 
                  value={ethDate.year} 
                  onChange={(e) => handleYearChange(parseInt(e.target.value))}
                  className="w-full mt-1 px-3 py-2 border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-ring bg-white dark:bg-gray-700"
                >
                  {yearOptions.map((year) => (
                    <option key={year} value={year}>{year}</option>
                  ))}
                </select>
              </div>
              
              <div className="flex-1">
                <Label className="text-xs text-muted-foreground">ወር (Month)</Label>
                <select 
                  value={ethDate.month} 
                  onChange={(e) => handleMonthChange(parseInt(e.target.value))}
                  className="w-full mt-1 px-3 py-2 border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-ring bg-white dark:bg-gray-700"
                >
                  {months.map((month, index) => (
                    <option key={index + 1} value={index + 1}>
                      {month}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            {/* Day grid - Simple and clean */}
            <div>
              <Label className="text-xs text-muted-foreground">ቀን (Day)</Label>
              <div className="grid grid-cols-5 gap-2 mt-2">
                {dayOptions.map((day) => {
                  const dayDate = { ...ethDate, day };
                  const dateInfo = getDateInfo(dayDate);
                  const isToday = checkIsToday(dayDate);
                  const isSelected = ethDate.day === day;
                  
                  let buttonClass = 'bg-white dark:bg-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600';
                  
                  if (dateInfo.status === 'DISABLED') {
                    buttonClass = 'bg-gray-200 text-gray-400 cursor-not-allowed';
                  } else if (dateInfo.status === 'EFFECTIVE') {
                    buttonClass = 'bg-blue-600 text-white hover:bg-blue-700 border-blue-600 font-bold';
                  } else if (isToday) {
                    buttonClass = 'bg-red-900 text-white hover:bg-red-800 border-red-900';
                  } else if (isSelected) {
                    buttonClass = 'bg-green-600 text-white hover:bg-green-700 border-green-600';
                  }
                  
                  return (
                    <Button
                      key={day}
                      variant="outline"
                      size="sm"
                      className={`h-9 w-full p-0 text-xs ${buttonClass}`}
                      onClick={() => handleDayClick(day)}
                      disabled={dateInfo.status === 'DISABLED'}
                      title={dateInfo.reason || ''}
                    >
                      {day}
                    </Button>
                  );
                })}
              </div>
            </div>

            {/* Today button and debug info */}
            <div className="flex justify-between items-center pt-2 border-t">
              <Button
                variant="outline"
                size="sm"
                onClick={() => {
                  const today = getCurrentSimpleEthiopianDate();
                  handleDateChange(today);
                  setIsOpen(false);
                }}
                className="text-xs bg-white dark:bg-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600"
              >
                ዛሬ (Today)
              </Button>
              
              <div className="text-xs text-muted-foreground">
                {months[ethDate.month - 1]} {ethDate.year}
                <br />
                <span className="text-xs text-green-600">Selected Day: {ethDate.day}</span>
              </div>
            </div>
          </div>
        </PopoverContent>
      </Popover>
      
      <Button
        variant="outline"
        size="sm"
        onClick={goToNextDay}
        className="px-2"
        title="Next Day"
      >
        →
      </Button>
      
      <Button
        variant="outline"
        size="sm"
        onClick={goToToday}
        className="px-3"
        title="Go to Today"
      >
        Today
      </Button>
      </div>
    </div>
  );
}
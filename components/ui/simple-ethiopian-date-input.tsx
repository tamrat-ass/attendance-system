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
  const [ethDate, setEthDate] = useState<SimpleEthiopianDate>(() => {
    const today = getCurrentSimpleEthiopianDate();
    console.log('Initial Ethiopian date:', today);
    if (value) {
      const converted = gregorianToSimpleEthiopian(value);
      console.log('Converted from value:', converted);
      return converted;
    }
    return today;
  });
  const [isOpen, setIsOpen] = useState(false);

  const months = useAmharic ? ETHIOPIAN_MONTHS : ETHIOPIAN_MONTHS_EN;

  // Update Ethiopian date when value prop changes OR when popover opens
  useEffect(() => {
    if (value) {
      const converted = gregorianToSimpleEthiopian(value);
      console.log('Effect - updating from value:', converted);
      setEthDate(converted);
    }
  }, [value]);
  
  // Sync to today when popover opens if no value
  useEffect(() => {
    if (isOpen && !value) {
      const today = getCurrentSimpleEthiopianDate();
      console.log('Effect - syncing to today on open:', today);
      setEthDate(today);
    }
  }, [isOpen]);

  // Handle date changes - NO COMPLEX CONVERSIONS
  const handleDateChange = (newEthDate: SimpleEthiopianDate) => {
    console.log('=== SIMPLE DATE CHANGE ===');
    console.log('New Ethiopian date:', newEthDate);
    
    // Update local state
    setEthDate(newEthDate);
    
    // Convert to Gregorian for database compatibility
    const gregorianString = simpleEthiopianToGregorian(newEthDate);
    console.log('Gregorian for database:', gregorianString);
    
    onChange(gregorianString);
  };

  const handleYearChange = (year: number) => {
    const newDate = { ...ethDate, year };
    handleDateChange(newDate);
  };

  const handleMonthChange = (month: number) => {
    const newDate = { ...ethDate, month };
    handleDateChange(newDate);
  };

  const handleDayClick = (day: number) => {
    console.log('=== DAY CLICK - SIMPLE VERSION ===');
    console.log('Day clicked:', day);
    console.log('Current Ethiopian date:', ethDate);
    
    const newDate = { ...ethDate, day: day };
    console.log('New Ethiopian date will be:', newDate);
    
    handleDateChange(newDate);
    setIsOpen(false);
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

  return (
    <div className={`space-y-2 ${className}`}>
      {label && <Label className="text-sm font-medium">{label}</Label>}
      
      <Popover open={isOpen} onOpenChange={setIsOpen}>
        <PopoverTrigger asChild>
          <Button
            variant="outline"
            className="w-full justify-between text-left font-normal"
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
                  const today = getCurrentSimpleEthiopianDate();
                  const isToday = today.year === ethDate.year && 
                                  today.month === ethDate.month && 
                                  today.day === day;
                  
                  return (
                    <Button
                      key={day}
                      variant="outline"
                      size="sm"
                      className={`h-9 w-full p-0 text-xs ${
                        isToday 
                          ? 'bg-red-900 text-white hover:bg-red-800 border-red-900' 
                          : 'bg-white dark:bg-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600'
                      }`}
                      onClick={() => handleDayClick(day)}
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
    </div>
  );
}
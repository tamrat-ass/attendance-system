'use client';

import { useState, useEffect } from 'react';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Button } from '@/components/ui/button';
import { Calendar, ChevronDown } from 'lucide-react';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { 
  EthiopianDate, 
  ETHIOPIAN_MONTHS, 
  ETHIOPIAN_MONTHS_EN,
  getCurrentEthiopianDate,
  ethiopianToISOString,
  isoStringToEthiopian,
  formatEthiopianDate
} from '@/lib/ethiopian-date';

interface EthiopianDateInputProps {
  value?: string; // ISO string
  onChange: (isoString: string) => void;
  label?: string;
  useAmharic?: boolean;
  className?: string;
}

export function EthiopianDateInput({ 
  value, 
  onChange, 
  label, 
  useAmharic = true,
  className = ""
}: EthiopianDateInputProps) {
  const [ethDate, setEthDate] = useState<EthiopianDate>(() => {
    if (value) {
      return isoStringToEthiopian(value);
    }
    return getCurrentEthiopianDate();
  });
  const [isOpen, setIsOpen] = useState(false);

  const months = useAmharic ? ETHIOPIAN_MONTHS : ETHIOPIAN_MONTHS_EN;

  // Update Ethiopian date when value prop changes
  useEffect(() => {
    if (value) {
      setEthDate(isoStringToEthiopian(value));
    }
  }, [value]);

  // Handle date changes
  const handleDateChange = (newEthDate: EthiopianDate) => {
    console.log('handleDateChange called with:', newEthDate);
    setEthDate(newEthDate);
    const isoString = ethiopianToISOString(newEthDate);
    console.log('ISO string generated:', isoString);
    onChange(isoString);
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
    console.log('=== DAY CLICK DEBUG ===');
    console.log('Day clicked:', day, typeof day);
    console.log('Current ethDate:', ethDate);
    
    const newDate = { ...ethDate, day: Number(day) };
    console.log('New date object:', newDate);
    
    // Update state directly first
    setEthDate(newDate);
    console.log('State updated to:', newDate);
    
    // Then try conversion
    try {
      const isoString = ethiopianToISOString(newDate);
      console.log('ISO conversion result:', isoString);
      
      // Test reverse conversion
      const backToEth = isoStringToEthiopian(isoString);
      console.log('Back to Ethiopian:', backToEth);
      
      onChange(isoString);
    } catch (error) {
      console.error('Conversion error:', error);
    }
    
    setIsOpen(false);
  };

  // Generate year options (current year ± 10)
  const currentYear = getCurrentEthiopianDate().year;
  const yearOptions = [];
  for (let i = currentYear - 10; i <= currentYear + 5; i++) {
    yearOptions.push(i);
  }

  // Generate day options based on selected month
  const maxDays = ethDate.month === 13 ? 6 : 30; // Pagumen has 5-6 days
  const dayOptions = [];
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
              <span>{formatEthiopianDate(ethDate, useAmharic)}</span>
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

            {/* Day grid - Simple 5 columns layout */}
            <div>
              <Label className="text-xs text-muted-foreground">ቀን (Day)</Label>
              <div className="grid grid-cols-5 gap-2 mt-2">
                {dayOptions.map((day) => {
                  const isSelected = Number(ethDate.day) === Number(day);
                  return (
                    <Button
                      key={day}
                      variant={isSelected ? "default" : "outline"}
                      size="sm"
                      className={`h-9 w-full p-0 text-xs ${isSelected ? 'bg-primary text-primary-foreground' : 'bg-white dark:bg-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600'}`}
                      onClick={() => handleDayClick(day)}
                    >
                      {day}
                    </Button>
                  );
                })}
              </div>
            </div>

            {/* Today button */}
            <div className="flex justify-between items-center pt-2 border-t">
              <Button
                variant="outline"
                size="sm"
                onClick={() => {
                  const today = getCurrentEthiopianDate();
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
                <span className="text-xs text-blue-600">Day: {ethDate.day}</span>
                <br />
                <button 
                  onClick={() => {
                    console.log('Current ethDate state:', ethDate);
                    console.log('dayOptions:', dayOptions);
                  }}
                  className="text-xs text-red-600 underline"
                >
                  Debug State
                </button>
              </div>
            </div>
          </div>
        </PopoverContent>
      </Popover>
    </div>
  );
}
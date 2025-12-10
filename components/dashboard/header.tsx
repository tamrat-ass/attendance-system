'use client';

import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { LogOut, Moon, Sun } from 'lucide-react';
import ChangePasswordDialog from './change-password-dialog';
import { getCurrentSimpleEthiopianDate, formatSimpleEthiopianDate } from '@/lib/simple-ethiopian-date';

interface HeaderProps {
  onLogout: () => void;
}
// Header component
export default function Header({ onLogout }: HeaderProps) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  
  const currentEthDate = getCurrentSimpleEthiopianDate();
  const ethiopianToday = formatSimpleEthiopianDate(currentEthDate, true);
  
  // Also show Gregorian date for reference
  const gregorianToday = new Date().toLocaleDateString('en-US', { 
    weekday: 'long', 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  });

  // Load theme from localStorage on mount
  useEffect(() => {
    const savedTheme = localStorage.getItem('theme') as 'light' | 'dark' | null;
    if (savedTheme) {
      setTheme(savedTheme);
      document.documentElement.classList.toggle('dark', savedTheme === 'dark');
    }
  }, []);

  // Toggle theme
  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
    localStorage.setItem('theme', newTheme);
    document.documentElement.classList.toggle('dark', newTheme === 'dark');
  };

  const handleLogout = async () => {
    // Log the logout action
    const userStr = localStorage.getItem('user');
    if (userStr) {
      try {
        const user = JSON.parse(userStr);
        await fetch('/api/auth/logout', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            user_id: user.id,
            username: user.username
          })
        });
      } catch (error) {
        console.error('Failed to log logout:', error);
      }
    }
    
    // Call the original logout function
    onLogout();
  };

// Render header with title, date, and logout button
  return (
    <header className="border-b border-border bg-card">
      <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <img 
            src="/apple-icon.png" 
            alt="Logo" 
            className="w-10 h-10 rounded-lg object-contain"
            loading="eager"
            width={40}
            height={40}
          />
          <div>{/* Title and date */}
            <h1 className="text-xl font-bold text-foreground">MK Member Attendance Management</h1>
            <div className="text-sm text-muted-foreground">
              <p className="font-medium text-foreground">{ethiopianToday}</p>
              <p className="text-xs">{gregorianToday}</p>
            </div>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={toggleTheme}
            className="flex items-center gap-2"
            title={theme === 'light' ? 'Switch to Dark Mode' : 'Switch to Light Mode'}
          >
            {theme === 'light' ? (
              <Moon className="w-4 h-4" />
            ) : (
              <Sun className="w-4 h-4" />
            )}
          </Button>
          <ChangePasswordDialog />
          <Button 
            variant="outline" 
            size="sm"
            onClick={handleLogout}
            className="flex items-center gap-2"
          >{/* Logout button */}
            <LogOut className="w-4 h-4" />
            Logout
          </Button>
        </div>
      </div>
    </header>
  );
}

'use client';

import { useState, useEffect } from 'react';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { Clock, X } from 'lucide-react';
import { SessionManager } from '@/lib/session-manager';

interface SessionTimeoutWarningProps {
  onExtendSession?: () => void;
}

export default function SessionTimeoutWarning({ onExtendSession }: SessionTimeoutWarningProps) {
  const [showWarning, setShowWarning] = useState(false);
  const [remainingTime, setRemainingTime] = useState(0);

  useEffect(() => {
    const checkSessionStatus = () => {
      if (!SessionManager.isAuthenticated()) {
        setShowWarning(false);
        return;
      }

      const remaining = SessionManager.getRemainingTime();
      setRemainingTime(remaining);

      // Show warning when 10 minutes or less remain
      if (remaining <= 600 && remaining > 0) {
        setShowWarning(true);
      } else {
        setShowWarning(false);
      }
    };

    // Check every second when warning is shown, every 10 seconds otherwise
    const interval = setInterval(checkSessionStatus, showWarning ? 1000 : 10000);
    
    // Initial check
    checkSessionStatus();

    return () => clearInterval(interval);
  }, [showWarning]);

  const handleExtendSession = () => {
    SessionManager.updateActivity();
    setShowWarning(false);
    if (onExtendSession) {
      onExtendSession();
    }
  };

  const handleDismiss = () => {
    setShowWarning(false);
  };

  if (!showWarning) {
    return null;
  }

  return (
    <div className="fixed top-4 right-4 z-50 max-w-sm">
      <Alert className="border-orange-200 bg-orange-50 dark:border-orange-900 dark:bg-orange-950">
        <Clock className="h-4 w-4 text-orange-600 dark:text-orange-400" />
        <div className="flex justify-between items-start">
          <div className="flex-1">
            <AlertDescription className="text-orange-800 dark:text-orange-200">
              <div className="font-medium mb-2">Session Expiring Soon</div>
              <div className="text-sm mb-3">
                Your session will expire in {Math.floor(remainingTime / 60)}:{(remainingTime % 60).toString().padStart(2, '0')} due to inactivity.
              </div>
              <div className="flex gap-2">
                <Button
                  size="sm"
                  onClick={handleExtendSession}
                  className="bg-orange-600 hover:bg-orange-700 text-white"
                >
                  Stay Logged In
                </Button>
                <Button
                  size="sm"
                  variant="outline"
                  onClick={handleDismiss}
                  className="border-orange-300 text-orange-700 hover:bg-orange-100 dark:border-orange-700 dark:text-orange-300 dark:hover:bg-orange-900"
                >
                  Dismiss
                </Button>
              </div>
            </AlertDescription>
          </div>
          <button
            onClick={handleDismiss}
            className="ml-2 text-orange-600 hover:text-orange-800 dark:text-orange-400 dark:hover:text-orange-200"
          >
            <X className="h-4 w-4" />
          </button>
        </div>
      </Alert>
    </div>
  );
}
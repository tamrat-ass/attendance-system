'use client';

import { useState, useEffect, lazy, Suspense } from 'react';
import LoginPage from '@/components/auth/login-page';
import { SessionManager } from '@/lib/session-manager';
import { usePagePerformance } from '@/hooks/use-performance';

// Lazy load Dashboard for better performance
const Dashboard = lazy(() => import('@/components/dashboard/dashboard'));

export default function Home() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  
  // Monitor page performance
  usePagePerformance('AttendanceSystem');

  useEffect(() => {
    // Fast authentication check
    const checkAuth = () => {
      const isAuth = SessionManager.isAuthenticated();
      setIsAuthenticated(isAuth);
      setIsLoading(false);
    };
    
    // Set up logout callback for auto-logout
    SessionManager.setLogoutCallback(() => {
      console.log('Auto-logout triggered due to 3 minutes of inactivity');
      setIsAuthenticated(false);
    });
    
    // Use requestAnimationFrame for faster rendering
    requestAnimationFrame(checkAuth);

    // Set up periodic checks every 10 seconds to catch session expiry
    const interval = setInterval(() => {
      const stillAuth = SessionManager.isAuthenticated();
      if (!stillAuth && isAuthenticated) {
        console.log('Session expired - logging out');
        setIsAuthenticated(false);
      }
    }, 10000);
    
    return () => {
      clearInterval(interval);
      // Clear logout callback on unmount
      SessionManager.setLogoutCallback(() => {});
    };
  }, [isAuthenticated]);

  const handleLogin = () => {
    setIsAuthenticated(true);
  };

  const handleLogout = async () => {
    try {
      // Call logout API
      await fetch('/api/auth/logout', { method: 'POST' });
    } catch (error) {
      console.error('Logout API error:', error);
    } finally {
      // Clear session data
      SessionManager.clearSession();
      setIsAuthenticated(false);
    }
  };

  // Show fast loading while checking authentication
  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary/10 to-accent/10">
        <div className="text-center">
          <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-primary mx-auto mb-2"></div>
          <p className="text-sm text-muted-foreground">Loading...</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <LoginPage onLogin={handleLogin} />;
  }

  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-4"></div>
          <p>Loading Dashboard...</p>
        </div>
      </div>
    }>
      <Dashboard onLogout={handleLogout} />
    </Suspense>
  );
}

'use client';

import { useState, useEffect } from 'react';
import LoginPage from '@/components/auth/login-page';
import Dashboard from '@/components/dashboard/dashboard';
import { SessionManager } from '@/lib/session-manager';

export default function Home() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Check initial authentication status
    const isAuth = SessionManager.isAuthenticated();
    setIsAuthenticated(isAuth);
    setIsLoading(false);
  }, []);

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

  // Show loading while checking authentication
  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-4"></div>
          <p>Loading...</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <LoginPage onLogin={handleLogin} />;
  }

  return <Dashboard onLogout={handleLogout} />;
}

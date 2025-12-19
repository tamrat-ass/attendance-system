// Session Management Utility with Auto-logout
// Handles user session with 3-minute inactivity timeout

export class SessionManager {
  private static readonly STORAGE_KEYS = {
    USER: 'user',
    LAST_ACTIVITY: 'lastActivity'
  };

  private static readonly TIMEOUT_DURATION = 15 * 60 * 1000; // 15 minutes total session
  private static readonly WARNING_THRESHOLD = 10 * 60 * 1000; // Show warning when 10 minutes remain
  private static timeoutId: NodeJS.Timeout | null = null;
  private static onLogoutCallback: (() => void) | null = null;

  // Check if user is authenticated and session is still valid
  static isAuthenticated(): boolean {
    try {
      const user = localStorage.getItem(this.STORAGE_KEYS.USER);
      const lastActivity = localStorage.getItem(this.STORAGE_KEYS.LAST_ACTIVITY);
      
      if (!user) return false;
      
      if (lastActivity) {
        const timeSinceLastActivity = Date.now() - parseInt(lastActivity);
        if (timeSinceLastActivity > this.TIMEOUT_DURATION) {
          // Session expired, clear it
          this.clearSession();
          return false;
        }
      }
      
      return true;
    } catch (error) {
      console.error('Error checking authentication:', error);
      return false;
    }
  }

  // Start a new session with activity tracking
  static startSession(userData: any): void {
    try {
      localStorage.setItem(this.STORAGE_KEYS.USER, JSON.stringify(userData));
      this.updateActivity();
      this.startActivityTracking();
    } catch (error) {
      console.error('Error starting session:', error);
    }
  }

  // Clear session data and stop tracking
  static clearSession(): void {
    try {
      localStorage.removeItem(this.STORAGE_KEYS.USER);
      localStorage.removeItem(this.STORAGE_KEYS.LAST_ACTIVITY);
      this.stopActivityTracking();
    } catch (error) {
      console.error('Error clearing session:', error);
    }
  }

  // Get current user data
  static getCurrentUser(): any {
    try {
      const user = localStorage.getItem(this.STORAGE_KEYS.USER);
      return user ? JSON.parse(user) : null;
    } catch (error) {
      console.error('Error getting current user:', error);
      return null;
    }
  }

  // Set callback for when auto-logout occurs
  static setLogoutCallback(callback: () => void): void {
    this.onLogoutCallback = callback;
  }

  // Update last activity timestamp
  static updateActivity(): void {
    try {
      localStorage.setItem(this.STORAGE_KEYS.LAST_ACTIVITY, Date.now().toString());
      this.resetTimeout();
    } catch (error) {
      console.error('Error updating activity:', error);
    }
  }

  // Start tracking user activity
  private static startActivityTracking(): void {
    // Track various user interactions
    const events = ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart', 'click'];
    
    const activityHandler = () => {
      this.updateActivity();
    };

    // Add event listeners
    events.forEach(event => {
      document.addEventListener(event, activityHandler, true);
    });

    // Store reference to remove listeners later
    (window as any).__sessionActivityHandler = activityHandler;
    (window as any).__sessionEvents = events;

    this.resetTimeout();
  }

  // Stop tracking user activity
  private static stopActivityTracking(): void {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }

    // Remove event listeners
    const activityHandler = (window as any).__sessionActivityHandler;
    const events = (window as any).__sessionEvents;
    
    if (activityHandler && events) {
      events.forEach((event: string) => {
        document.removeEventListener(event, activityHandler, true);
      });
    }

    delete (window as any).__sessionActivityHandler;
    delete (window as any).__sessionEvents;
  }

  // Reset the inactivity timeout
  private static resetTimeout(): void {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
    }

    this.timeoutId = setTimeout(() => {
      console.log('Session expired due to inactivity');
      this.clearSession();
      
      // Call logout callback if set
      if (this.onLogoutCallback) {
        this.onLogoutCallback();
      }
    }, this.TIMEOUT_DURATION);
  }

  // Check if session is about to expire (within 10 minutes)
  static isSessionExpiringSoon(): boolean {
    try {
      const lastActivity = localStorage.getItem(this.STORAGE_KEYS.LAST_ACTIVITY);
      if (!lastActivity) return false;
      
      const timeSinceLastActivity = Date.now() - parseInt(lastActivity);
      const timeUntilExpiry = this.TIMEOUT_DURATION - timeSinceLastActivity;
      
      return timeUntilExpiry <= this.WARNING_THRESHOLD; // 10 minutes
    } catch (error) {
      console.error('Error checking session expiry:', error);
      return false;
    }
  }

  // Get remaining session time in seconds
  static getRemainingTime(): number {
    try {
      const lastActivity = localStorage.getItem(this.STORAGE_KEYS.LAST_ACTIVITY);
      if (!lastActivity) return 0;
      
      const timeSinceLastActivity = Date.now() - parseInt(lastActivity);
      const remainingTime = this.TIMEOUT_DURATION - timeSinceLastActivity;
      
      return Math.max(0, Math.floor(remainingTime / 1000));
    } catch (error) {
      console.error('Error getting remaining time:', error);
      return 0;
    }
  }
}
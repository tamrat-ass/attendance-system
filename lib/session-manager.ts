// Simple Session Management Utility
// Handles user session without timeout functionality

export class SessionManager {
  private static readonly STORAGE_KEYS = {
    USER: 'user'
  };

  // Check if user is authenticated
  static isAuthenticated(): boolean {
    try {
      const user = localStorage.getItem(this.STORAGE_KEYS.USER);
      return !!user;
    } catch (error) {
      console.error('Error checking authentication:', error);
      return false;
    }
  }

  // Start a new session
  static startSession(userData: any): void {
    try {
      localStorage.setItem(this.STORAGE_KEYS.USER, JSON.stringify(userData));
    } catch (error) {
      console.error('Error starting session:', error);
    }
  }

  // Clear session data
  static clearSession(): void {
    try {
      localStorage.removeItem(this.STORAGE_KEYS.USER);
      // Also remove lastActivity if it exists from previous version
      localStorage.removeItem('lastActivity');
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
}
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _lastActiveKey = 'last_active_time';
  static const int sessionTimeoutMinutes = 60; // ✅ Reasonable timeout - 60 minutes (1 hour)

  /// Save current time when app goes background
  static Future<void> saveLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    prefs.setInt(
      _lastActiveKey,
      now.millisecondsSinceEpoch,
    );
    print('💾 Session saved at: $now');
  }

  /// Check if session expired
  static Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActive = prefs.getInt(_lastActiveKey);

    if (lastActive == null) {
      print('❌ No session found - expired');
      return true;
    }

    final lastTime = DateTime.fromMillisecondsSinceEpoch(lastActive);
    final difference = DateTime.now().difference(lastTime);
    final expired = difference.inMinutes >= sessionTimeoutMinutes;
    
    print('⏰ Last active: $lastTime');
    print('⏰ Time elapsed: ${difference.inMinutes} minutes');
    print('⏰ Timeout limit: $sessionTimeoutMinutes minutes');
    print('⏰ Is expired: $expired');

    return expired;
  }

  /// Update session time when user is active
  static Future<void> updateActivity() async {
    await saveLastActiveTime();
  }

  /// Clear session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastActiveKey);
    await prefs.remove('user');
    print('🗑️ Session cleared');
  }

  /// Get remaining session time in minutes
  static Future<int> getRemainingMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActive = prefs.getInt(_lastActiveKey);

    if (lastActive == null) return 0;

    final lastTime = DateTime.fromMillisecondsSinceEpoch(lastActive);
    final elapsed = DateTime.now().difference(lastTime).inMinutes;
    final remaining = sessionTimeoutMinutes - elapsed;
    
    return remaining > 0 ? remaining : 0;
  }
}
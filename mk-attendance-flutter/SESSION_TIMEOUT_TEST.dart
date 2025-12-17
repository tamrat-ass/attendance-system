import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lib/services/session_manager.dart';

/// Test file to verify session timeout functionality
/// Run this to test session management manually

class SessionTimeoutTest {
  
  /// Test 1: Check if session is saved on login
  static Future<void> testSessionSaving() async {
    print('🔍 Testing Session Saving...');
    
    // Simulate login
    await SessionManager.saveLastActiveTime();
    
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('last_active_time');
    
    if (savedTime != null) {
      final savedDateTime = DateTime.fromMillisecondsSinceEpoch(savedTime);
      print('✅ Session saved successfully at: $savedDateTime');
    } else {
      print('❌ Session NOT saved!');
    }
  }
  
  /// Test 2: Check session expiration logic
  static Future<void> testSessionExpiration() async {
    print('🔍 Testing Session Expiration...');
    
    // Save current time
    await SessionManager.saveLastActiveTime();
    
    // Check if session is NOT expired (should be false)
    bool expired = await SessionManager.isSessionExpired();
    print('Session expired immediately: $expired (should be false)');
    
    // Simulate old session (6 minutes ago)
    final prefs = await SharedPreferences.getInstance();
    final sixMinutesAgo = DateTime.now().subtract(Duration(minutes: 6));
    await prefs.setInt('last_active_time', sixMinutesAgo.millisecondsSinceEpoch);
    
    // Check if session IS expired (should be true)
    expired = await SessionManager.isSessionExpired();
    print('Session expired after 6 minutes: $expired (should be true)');
  }
  
  /// Test 3: Check session clearing
  static Future<void> testSessionClearing() async {
    print('🔍 Testing Session Clearing...');
    
    // Save session first
    await SessionManager.saveLastActiveTime();
    
    // Clear session
    await SessionManager.clearSession();
    
    // Check if cleared
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('last_active_time');
    
    if (savedTime == null) {
      print('✅ Session cleared successfully');
    } else {
      print('❌ Session NOT cleared!');
    }
  }
  
  /// Run all tests
  static Future<void> runAllTests() async {
    print('🚀 Starting Session Timeout Tests...\n');
    
    await testSessionSaving();
    print('');
    
    await testSessionExpiration();
    print('');
    
    await testSessionClearing();
    print('');
    
    print('✅ All tests completed!');
  }
}

/// Widget to test session timeout in the app
class SessionTimeoutTestScreen extends StatefulWidget {
  const SessionTimeoutTestScreen({super.key});

  @override
  State<SessionTimeoutTestScreen> createState() => _SessionTimeoutTestScreenState();
}

class _SessionTimeoutTestScreenState extends State<SessionTimeoutTestScreen> {
  String _testResults = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Timeout Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session Timeout Testing',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _runTests,
              child: const Text('Run Session Tests'),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _simulateTimeout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Simulate 6-Minute Timeout'),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _checkCurrentSession,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Check Current Session'),
            ),
            
            const SizedBox(height: 20),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults.isEmpty ? 'Test results will appear here...' : _testResults,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _runTests() async {
    setState(() {
      _testResults = 'Running tests...\n';
    });
    
    // Capture print output
    final buffer = StringBuffer();
    
    await SessionTimeoutTest.testSessionSaving();
    buffer.writeln('✅ Session Saving Test Complete');
    
    await SessionTimeoutTest.testSessionExpiration();
    buffer.writeln('✅ Session Expiration Test Complete');
    
    await SessionTimeoutTest.testSessionClearing();
    buffer.writeln('✅ Session Clearing Test Complete');
    
    setState(() {
      _testResults = buffer.toString();
    });
  }
  
  Future<void> _simulateTimeout() async {
    // Set session to 6 minutes ago
    final prefs = await SharedPreferences.getInstance();
    final sixMinutesAgo = DateTime.now().subtract(Duration(minutes: 6));
    await prefs.setInt('last_active_time', sixMinutesAgo.millisecondsSinceEpoch);
    
    setState(() {
      _testResults = '⏰ Session set to 6 minutes ago.\nNow minimize and reopen the app to test timeout.';
    });
  }
  
  Future<void> _checkCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('last_active_time');
    
    if (savedTime != null) {
      final savedDateTime = DateTime.fromMillisecondsSinceEpoch(savedTime);
      final difference = DateTime.now().difference(savedDateTime);
      final expired = await SessionManager.isSessionExpired();
      
      setState(() {
        _testResults = '''
📊 Current Session Status:
• Last Active: $savedDateTime
• Time Elapsed: ${difference.inMinutes} minutes
• Is Expired: $expired
• Timeout Limit: ${SessionManager.sessionTimeoutMinutes} minutes
        ''';
      });
    } else {
      setState(() {
        _testResults = '❌ No active session found';
      });
    }
  }
}
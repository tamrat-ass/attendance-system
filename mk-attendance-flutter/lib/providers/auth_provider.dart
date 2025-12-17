import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/direct_database_service.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../services/session_manager.dart';
import 'dart:convert';

enum LoginErrorType {
  none,
  offline,
  wrongUsername,
  wrongPassword,
  generic,
}

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  LoginErrorType _errorType = LoginErrorType.none;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  LoginErrorType get errorType => _errorType;
  
  // Backward compatibility
  bool get isOfflineError => _errorType == LoginErrorType.offline;

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        _user = User.fromJson(userData);
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _errorType = LoginErrorType.none;
    notifyListeners();

    try {
      // Check internet connectivity first
      final hasInternet = await ConnectivityService.hasInternetConnection();
      if (!hasInternet) {
        _errorMessage = 'Sorry please, turn on your mobile data associated with your MK attendance';
        _errorType = LoginErrorType.offline;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Call users table directly from database
      final result = await DirectDatabaseService.loginFromUsersTable(username, password);
      
      if (result['success']) {
        _user = User.fromJson(result['user']);
        _isAuthenticated = true;
        
        // Save user to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_user!.toJson()));
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Handle specific error messages based on the response
        String errorMsg = result['message'] ?? 'Login failed';
        
        if (errorMsg.contains('You entered wrong username')) {
          _errorMessage = 'You entered wrong username';
          _errorType = LoginErrorType.wrongUsername;
        } else if (errorMsg.contains('You entered wrong password')) {
          _errorMessage = 'You entered wrong password';
          _errorType = LoginErrorType.wrongPassword;
        } else if (errorMsg.toLowerCase().contains('invalid username or password')) {
          _errorMessage = 'You entered wrong username or password';
          _errorType = LoginErrorType.generic;
        } else {
          _errorMessage = errorMsg;
          _errorType = LoginErrorType.generic;
        }
        
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Check if it's a connectivity issue
      final hasInternet = await ConnectivityService.hasInternetConnection();
      if (!hasInternet) {
        _errorMessage = 'Sorry please, turn on your mobile data associated with your MK attendance';
        _errorType = LoginErrorType.offline;
      } else {
        _errorMessage = 'Network error. Please check your connection.';
        _errorType = LoginErrorType.generic;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Logout API call removed - just clear local data
    } catch (e) {
      debugPrint('Logout API error: $e');
    }

    // Clear local data and session
    await SessionManager.clearSession();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    
    _user = null;
    _isAuthenticated = false;
    _isLoading = false;
    _errorMessage = null;
    _errorType = LoginErrorType.none;
    
    notifyListeners();
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check internet connectivity first
      final hasInternet = await ConnectivityService.hasInternetConnection();
      if (!hasInternet) {
        _errorMessage = 'Sorry please, turn on your mobile data associated with your MK attendance';
        _errorType = LoginErrorType.offline;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final apiService = ApiService();
      final result = await apiService.changePassword(
        userId: _user?.id ?? 0,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      if (result['success']) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to change password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Check if it's a connectivity issue
      final hasInternet = await ConnectivityService.hasInternetConnection();
      if (!hasInternet) {
        _errorMessage = 'Sorry please, turn on your mobile data associated with your MK attendance';
        _errorType = LoginErrorType.offline;
      } else {
        _errorMessage = 'Network error. Please check your connection.';
        _errorType = LoginErrorType.generic;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
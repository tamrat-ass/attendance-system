import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../services/api_service.dart';

class ClassProvider with ChangeNotifier {
  List<ClassModel> _classes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ClassModel> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();

  // Load all classes with multiple fallback strategies
  Future<void> loadClasses() async {
    _setLoading(true);
    _clearError();

    try {
      print('🔥 CLASS PROVIDER: Starting to load classes...');
      
      // Strategy 1: Try main classes API
      List<Map<String, dynamic>> classesData;
      try {
        classesData = await _apiService.getClassesWithDetails();
        print('🔥 CLASS PROVIDER: Main API success - ${classesData.length} classes');
      } catch (e) {
        print('🔥 CLASS PROVIDER: Main API failed: $e');
        
        // Strategy 2: Try fallback - get classes from students data
        print('🔥 CLASS PROVIDER: Trying fallback method...');
        try {
          classesData = await _apiService.getClassesFromStudents();
          print('🔥 CLASS PROVIDER: Fallback success - ${classesData.length} classes');
        } catch (fallbackError) {
          print('🔥 CLASS PROVIDER: Fallback also failed: $fallbackError');
          
          // Strategy 3: Create default classes if user has permission
          if (e.toString().contains('404') || e.toString().contains('not found')) {
            print('🔥 CLASS PROVIDER: API not available, suggesting manual creation');
            _setError('Classes API not available. This appears to be a fresh installation. Please create your first class manually.');
            return;
          } else {
            // Re-throw original error with better message
            throw e;
          }
        }
      }
      
      _classes = classesData.map((data) => ClassModel.fromJson(data)).toList();
      print('🔥 CLASS PROVIDER: Successfully loaded ${_classes.length} classes');
      
      // If no classes found after all attempts
      if (_classes.isEmpty) {
        print('🔥 CLASS PROVIDER: No classes found after all attempts');
        _setError('No classes found. This appears to be a fresh installation. Please create your first class.');
      }
      
      notifyListeners();
    } catch (e) {
      print('🔥 CLASS PROVIDER ERROR: $e');
      
      // Provide specific error messages based on error type
      String errorMessage;
      if (e.toString().contains('Authentication failed') || e.toString().contains('401')) {
        errorMessage = 'Authentication failed. Please logout and login again.';
      } else if (e.toString().contains('Access denied') || e.toString().contains('403')) {
        errorMessage = 'Access denied. You may not have permission to view classes.';
      } else if (e.toString().contains('Network connection failed') || e.toString().contains('SocketException')) {
        errorMessage = 'Network connection failed. Please check your internet connection and try again.';
      } else if (e.toString().contains('Server error') || e.toString().contains('500')) {
        errorMessage = 'Server error. Please try again later or contact support.';
      } else if (e.toString().contains('404') || e.toString().contains('not found')) {
        errorMessage = 'Classes API endpoint not found. The server may not support class management yet.';
      } else {
        errorMessage = 'Failed to load classes: ${e.toString().replaceAll('Exception: ', '')}';
      }
      
      _setError(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Test API connectivity
  Future<bool> testConnection() async {
    try {
      final result = await ApiService.testApiConnection();
      return result;
    } catch (e) {
      print('🔥 CLASS PROVIDER: Connection test failed: $e');
      return false;
    }
  }

  // Force refresh with cache clearing
  Future<void> forceRefresh() async {
    print('🔥 CLASS PROVIDER: Force refresh initiated');
    _classes.clear();
    await loadClasses();
  }

  // Recovery method for authentication issues
  Future<void> recoverFromAuthError() async {
    print('🔥 CLASS PROVIDER: Attempting auth recovery');
    _setLoading(true);
    _clearError();

    try {
      // Wait a moment for any auth refresh
      await Future.delayed(const Duration(seconds: 2));
      
      // Retry loading
      await loadClasses();
    } catch (e) {
      _setError('Recovery failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create default classes for fresh installations (admin only)
  Future<bool> createDefaultClasses() async {
    final defaultClasses = [
      {'name': 'ዋናው መአከል', 'description': 'Main center class'},
      {'name': 'አዲስ አበባ ማእከል', 'description': 'Addis Ababa center'},
      {'name': 'ምስራቅ ማስተባበሪያ', 'description': 'Eastern coordination'},
    ];

    int successCount = 0;
    for (final classData in defaultClasses) {
      try {
        final success = await createClass(
          className: classData['name']!,
          description: classData['description'],
        );
        if (success) {
          successCount++;
          print('🔥 CLASS PROVIDER: Created default class: ${classData['name']}');
        }
      } catch (e) {
        print('🔥 CLASS PROVIDER: Failed to create default class ${classData['name']}: $e');
      }
    }

    return successCount > 0;
  }

  // Create new class - Enhanced with debugging
  Future<bool> createClass({
    required String className,
    String? description,
  }) async {
    print('🔥 CLASS PROVIDER: Creating class "$className"');
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.createClass(
        className: className,
        description: description,
      );

      print('🔥 CLASS PROVIDER: Create result: $result');

      if (result['success'] == true) {
        // Add the new class to local list
        final data = result['data'];
        final newClass = ClassModel(
          id: data['id'],
          className: data['name'],
          description: data['description'],
          createdAt: DateTime.now(),
        );
        _classes.add(newClass);
        _classes.sort((a, b) => a.className.compareTo(b.className));
        print('🔥 CLASS PROVIDER: Class created successfully, total classes: ${_classes.length}');
        notifyListeners();
        return true;
      } else {
        final errorMsg = result['message'] ?? 'Failed to create class';
        print('🔥 CLASS PROVIDER: Create failed: $errorMsg');
        _setError(errorMsg);
        return false;
      }
    } catch (e) {
      print('🔥 CLASS PROVIDER: Create exception: $e');
      _setError('Failed to create class: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update existing class - Enhanced with debugging
  Future<bool> updateClass({
    required int classId,
    required String className,
    String? description,
  }) async {
    print('🔥 CLASS PROVIDER: Updating class ID $classId to "$className"');
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.updateClass(
        classId: classId,
        className: className,
        description: description,
      );

      print('🔥 CLASS PROVIDER: Update result: $result');

      if (result['success'] == true) {
        // Update the class in local list
        final index = _classes.indexWhere((c) => c.id == classId);
        if (index != -1) {
          _classes[index] = _classes[index].copyWith(
            className: result['data']['name'],
            description: result['data']['description'],
          );
          _classes.sort((a, b) => a.className.compareTo(b.className));
          print('🔥 CLASS PROVIDER: Class updated successfully');
          notifyListeners();
        }
        return true;
      } else {
        final errorMsg = result['message'] ?? 'Failed to update class';
        print('🔥 CLASS PROVIDER: Update failed: $errorMsg');
        _setError(errorMsg);
        return false;
      }
    } catch (e) {
      print('🔥 CLASS PROVIDER: Update exception: $e');
      _setError('Failed to update class: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete class - Enhanced with debugging
  Future<bool> deleteClass(int classId) async {
    print('🔥 CLASS PROVIDER: Deleting class ID $classId');
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.deleteClass(classId);

      print('🔥 CLASS PROVIDER: Delete result: $result');

      if (result['success'] == true) {
        // Remove the class from local list
        final removedCount = _classes.length;
        _classes.removeWhere((c) => c.id == classId);
        print('🔥 CLASS PROVIDER: Class deleted successfully, remaining classes: ${_classes.length}');
        notifyListeners();
        return true;
      } else {
        final errorMsg = result['message'] ?? 'Failed to delete class';
        print('🔥 CLASS PROVIDER: Delete failed: $errorMsg');
        _setError(errorMsg);
        return false;
      }
    } catch (e) {
      print('🔥 CLASS PROVIDER: Delete exception: $e');
      _setError('Failed to delete class: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get class by ID
  ClassModel? getClassById(int id) {
    try {
      return _classes.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get class names only (for dropdowns)
  List<String> getClassNames() {
    return _classes.map((c) => c.className).toList();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Clear all data
  void clear() {
    _classes.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
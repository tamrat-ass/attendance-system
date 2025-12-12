import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class StudentProvider with ChangeNotifier {
  List<Student> _students = [];
  List<String> _classes = [];
  bool _isLoading = false;
  bool _isLoadingClasses = false;
  String? _errorMessage;

  List<Student> get students => _students;
  List<String> get classes => _classes;
  bool get isLoading => _isLoading;
  bool get isLoadingClasses => _isLoadingClasses;
  String? get errorMessage => _errorMessage;

  List<Student> getStudentsByClass(String className) {
    return _students.where((student) => student.className == className).toList();
  }

  Future<void> loadStudents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apiService = ApiService();
      _students = await apiService.getStudents();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadClasses() async {
    _isLoadingClasses = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apiService = ApiService();
      _classes = await apiService.getClasses();
      
      // If no classes from API, get unique classes from existing students
      if (_classes.isEmpty) {
        final uniqueClasses = <String>{};
        for (final student in _students) {
          if (student.className.isNotEmpty) {
            uniqueClasses.add(student.className);
          }
        }
        _classes = uniqueClasses.toList()..sort();
      }
      
      _isLoadingClasses = false;
      notifyListeners();
    } catch (e) {
      // Fallback to classes from existing students if API fails
      final uniqueClasses = <String>{};
      for (final student in _students) {
        if (student.className.isNotEmpty) {
          uniqueClasses.add(student.className);
        }
      }
      _classes = uniqueClasses.toList()..sort();
      
      _errorMessage = e.toString();
      _isLoadingClasses = false;
      notifyListeners();
    }
  }

  Future<bool> addStudent(Student student) async {
    try {
      final apiService = ApiService();
      final newStudent = await apiService.createStudent(student);
      
      // Refresh the entire student list to get the actual data from database
      await loadStudents();
      
      // Also refresh classes in case a new class was added
      refreshClasses();
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStudent(Student student) async {
    if (student.id == null) return false;
    
    try {
      final apiService = ApiService();
      final updatedStudent = await apiService.updateStudent(student.id!, student);
      
      // Update the student in the local list
      final index = _students.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        _students[index] = updatedStudent;
      }
      
      // Refresh classes in case the class name changed
      refreshClasses();
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStudent(int id) async {
    try {
      final apiService = ApiService();
      final success = await apiService.deleteStudent(id);
      if (success) {
        _students.removeWhere((student) => student.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<Student> searchStudents(String query) {
    if (query.isEmpty) return _students;
    
    final lowercaseQuery = query.toLowerCase();
    return _students.where((student) {
      return student.fullName.toLowerCase().contains(lowercaseQuery) ||
             student.phone.contains(query) ||
             student.id.toString().contains(query);
    }).toList();
  }

  // Class management methods - Classes come from existing students only
  void refreshClasses() {
    // Refresh classes from existing students
    final uniqueClasses = <String>{};
    for (final student in _students) {
      if (student.className.isNotEmpty) {
        uniqueClasses.add(student.className);
      }
    }
    _classes = uniqueClasses.toList()..sort();
    notifyListeners();
  }

  void updateClassName(String oldName, String newName) {
    // Update all students with the old class name to the new class name
    for (int i = 0; i < _students.length; i++) {
      if (_students[i].className == oldName) {
        _students[i] = Student(
          id: _students[i].id,
          fullName: _students[i].fullName,
          phone: _students[i].phone,
          className: newName,
        );
      }
    }
    notifyListeners();
  }

  void deleteClass(String className) {
    // In a real app, you'd need to handle students in this class
    // For now, we just notify listeners
    notifyListeners();
  }
}
import 'package:flutter/foundation.dart';
import '../models/attendance.dart';
import '../services/api_service.dart';

class AttendanceProvider with ChangeNotifier {
  List<Attendance> _attendanceRecords = [];
  final Map<int, String> _studentStatus = {};
  final Map<int, String> _studentNotes = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<Attendance> get attendanceRecords => _attendanceRecords;
  Map<int, String> get studentStatus => _studentStatus;
  Map<int, String> get studentNotes => _studentNotes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAttendance({String? date, String? className}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apiService = ApiService();
      print('Provider: Loading attendance for date=$date, class=$className');
      
      _attendanceRecords = await apiService.getAttendance(
        date: date,
        className: className,
      );
      
      print('Provider: Received ${_attendanceRecords.length} attendance records');
      for (final record in _attendanceRecords) {
        print('  - Student ${record.studentId}: ${record.status}');
      }
      
      // Update local status map
      _studentStatus.clear();
      _studentNotes.clear();
      
      for (final record in _attendanceRecords) {
        _studentStatus[record.studentId] = record.status;
        if (record.notes != null && record.notes!.isNotEmpty) {
          _studentNotes[record.studentId] = record.notes!;
        }
      }
      
      print('Provider: Updated student status map: $_studentStatus');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStudentStatus(int studentId, String status) {
    _studentStatus[studentId] = status;
    notifyListeners();
  }

  void setStudentNote(int studentId, String note) {
    if (note.isEmpty) {
      _studentNotes.remove(studentId);
    } else {
      _studentNotes[studentId] = note;
    }
    notifyListeners();
  }

  String? getStudentStatus(int studentId) {
    return _studentStatus[studentId];
  }

  String getStudentNote(int studentId) {
    return _studentNotes[studentId] ?? '';
  }

  Future<Map<String, dynamic>> saveAttendance(String date) async {
    if (_studentStatus.isEmpty) {
      _errorMessage = 'No attendance marked';
      notifyListeners();
      return {
        'success': false,
        'message': 'No attendance marked',
        'error': 'NO_ATTENDANCE_MARKED'
      };
    }

    // Don't set loading state - keep UI unchanged during save
    _errorMessage = null;

    try {
      final apiService = ApiService();
      
      // Create records in the format expected by the web API
      final List<Map<String, dynamic>> records = [];
      
      for (final entry in _studentStatus.entries) {
        final studentId = entry.key;
        final status = entry.value;
        final notes = _studentNotes[studentId] ?? '';
        
        records.add({
          'student_id': studentId,
          'date': date,
          'status': status,
          'notes': notes,
        });
      }
      
      print('Saving ${records.length} attendance records: $records');
      
      // Use the enhanced API method that returns detailed response
      final result = await apiService.saveAttendanceRecords(records);
      
      if (result['success'] == true) {
        _errorMessage = null;
        print('✅ Attendance saved successfully - Web app will auto-sync in 5 seconds');
        print('📊 Inserted: ${result['insertedCount'] ?? 0}, Updated: ${result['updatedCount'] ?? 0}');
      } else {
        _errorMessage = result['message'] ?? 'Failed to save attendance to server';
        
        // Handle specific error types
        if (result['error'] == 'DUPLICATE_ATTENDANCE') {
          print('❌ Duplicate attendance detected: ${result['message']}');
          if (result['duplicates'] != null) {
            print('📋 Duplicates: ${result['duplicates']}');
          }
        } else if (result['error'] == 'NO_CONNECTION') {
          print('❌ No internet connection');
        } else {
          print('❌ Save failed: ${result['message']}');
        }
      }

      // Don't notify listeners to avoid UI changes during save
      return result;
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': 'NETWORK_ERROR'
      };
    }
  }

  void clearAttendanceData() {
    _studentStatus.clear();
    _studentNotes.clear();
    notifyListeners();
  }

  void markAllAsPermission(List<int> studentIds) {
    for (final studentId in studentIds) {
      if (!_studentStatus.containsKey(studentId)) {
        _studentStatus[studentId] = 'permission';
      }
    }
    notifyListeners();
  }
}
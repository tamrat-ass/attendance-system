import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/student.dart';
import '../models/attendance.dart';
import 'api_service.dart';

class BackupService {
  static const String _backupFileName = 'mk_attendance_backup.json';
  
  /// Create a complete backup of all app data
  static Future<String?> createBackup() async {
    try {
      final apiService = ApiService();
      
      // Get all data
      final students = await apiService.getStudents();
      final attendance = await apiService.getAttendance();
      
      // Create backup data structure
      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'data': {
          'students': students.map((s) => s.toJson()).toList(),
          'attendance': attendance,
        }
      };
      
      // Convert to JSON
      final jsonString = jsonEncode(backupData);
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_backupFileName');
      await file.writeAsString(jsonString);
      
      return file.path;
    } catch (e) {
      debugPrint('Backup creation failed: $e');
      return null;
    }
  }
  
  /// Share backup file
  static Future<bool> shareBackup() async {
    try {
      final backupPath = await createBackup();
      if (backupPath != null) {
        // File sharing functionality removed to reduce app size
        // Backup saved to: $backupPath
        debugPrint('Backup created at: $backupPath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Backup sharing failed: $e');
      return false;
    }
  }
  
  /// Restore data from backup file (simplified - user needs to manually place file)
  static Future<bool> restoreFromFile() async {
    try {
      // For now, look for a backup file in the documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/restore_backup.json');
      
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        return await _processBackupData(jsonString);
      } else {
        debugPrint('No restore file found at ${file.path}');
        return false;
      }
    } catch (e) {
      debugPrint('Restore from file failed: $e');
      return false;
    }
  }
  
  /// Process and restore backup data
  static Future<bool> _processBackupData(String jsonString) async {
    try {
      final backupData = jsonDecode(jsonString);
      
      // Validate backup structure
      if (!_validateBackupData(backupData)) {
        return false;
      }
      
      final apiService = ApiService();
      
      // Restore students
      final studentsData = backupData['data']['students'] as List;
      for (final studentJson in studentsData) {
        final student = Student.fromJson(studentJson);
        await apiService.createStudent(student);
      }
      
      // Restore attendance
      final attendanceData = backupData['data']['attendance'] as List;
      for (final attendanceJson in attendanceData) {
        final attendance = Attendance.fromJson(attendanceJson);
        await apiService.saveAttendance([{
          'student_id': attendance.studentId,
          'date': attendance.date,
          'status': attendance.status,
        }]);
      }
      
      return true;
    } catch (e) {
      debugPrint('Backup data processing failed: $e');
      return false;
    }
  }
  
  /// Validate backup data structure
  static bool _validateBackupData(Map<String, dynamic> data) {
    return data.containsKey('version') &&
           data.containsKey('data') &&
           data['data'].containsKey('students') &&
           data['data'].containsKey('attendance');
  }
  
  /// Get backup file info
  static Future<Map<String, dynamic>?> getBackupInfo() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_backupFileName');
      
      if (await file.exists()) {
        final stat = await file.stat();
        return {
          'exists': true,
          'size': stat.size,
          'modified': stat.modified,
          'path': file.path,
        };
      }
      return {'exists': false};
    } catch (e) {
      debugPrint('Get backup info failed: $e');
      return null;
    }
  }
  
  /// Clear all cached data
  static Future<bool> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      // Clear backup files
      final backupFile = File('${directory.path}/$_backupFileName');
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
      
      // Clear temporary files
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        await tempDir.create();
      }
      
      return true;
    } catch (e) {
      debugPrint('Clear cache failed: $e');
      return false;
    }
  }
  
  /// Sync data with server
  static Future<bool> syncWithServer() async {
    try {
      final apiService = ApiService();
      
      // Force refresh all data from server
      await apiService.getStudents();
      await apiService.getAttendance();
      
      return true;
    } catch (e) {
      debugPrint('Sync with server failed: $e');
      return false;
    }
  }
}
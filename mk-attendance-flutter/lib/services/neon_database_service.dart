import 'dart:convert';
import 'package:http/http.dart' as http;

class NeonDatabaseService {
  // Your Neon database connection details
  static const String _neonApiUrl = 'https://mk-attendance.vercel.app/api'; // Your existing API
  
  // Alternative: Direct Neon connection (if you want to bypass Vercel API)
  // You would need to add postgres package and connect directly
  // static const String _neonConnectionString = 'postgresql://username:password@ep-xxx.neon.tech/neondb';

  static Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Reports and Analytics - Connect to Neon via your existing API
  static Future<Map<String, dynamic>> getReportStatistics({
    String? startDate,
    String? endDate,
    String? className,
  }) async {
    try {
      String url = '$_neonApiUrl/reports';
      List<String> params = [];
      
      if (startDate != null) params.add('start_date=$startDate');
      if (endDate != null) params.add('end_date=$endDate');
      if (className != null) params.add('class=$className');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('🔍 NEON DEBUG: Fetching reports from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      print('🔍 NEON DEBUG: Response status: ${response.statusCode}');
      print('🔍 NEON DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data'],
          };
        } else {
          throw Exception('Failed to load reports: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load reports: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('🔍 NEON DEBUG: Error: $e');
      throw Exception('Network error connecting to Neon database: $e');
    }
  }

  // Get classes from Neon database
  static Future<List<String>> getClasses() async {
    try {
      final response = await http.get(
        Uri.parse('$_neonApiUrl/classes'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> classesJson = data['data'] ?? [];
          return classesJson.map((classData) => classData['name'] as String).toList();
        } else {
          throw Exception('Failed to load classes: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load classes: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error loading classes from Neon: $e');
    }
  }

  // Get students from Neon database
  static Future<List<Map<String, dynamic>>> getStudents({String? className}) async {
    try {
      String url = '$_neonApiUrl/students';
      if (className != null) {
        url += '?class=$className';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> studentsJson = data['data'] ?? [];
        return List<Map<String, dynamic>>.from(studentsJson);
      } else {
        throw Exception('Failed to load students: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error loading students from Neon: $e');
    }
  }

  // Get attendance from Neon database
  static Future<List<Map<String, dynamic>>> getAttendance({
    String? date,
    String? className,
    String? startDate,
    String? endDate,
  }) async {
    try {
      String url = '$_neonApiUrl/attendance';
      List<String> params = [];
      
      if (date != null) params.add('date=$date');
      if (className != null) params.add('class=$className');
      if (startDate != null) params.add('start_date=$startDate');
      if (endDate != null) params.add('end_date=$endDate');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> attendanceJson = data['data'] ?? [];
        return List<Map<String, dynamic>>.from(attendanceJson);
      } else {
        throw Exception('Failed to load attendance: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error loading attendance from Neon: $e');
    }
  }

  // Sync local data to Neon database
  static Future<Map<String, dynamic>> syncAttendanceToNeon(List<Map<String, dynamic>> records) async {
    try {
      print('🔄 SYNC: Uploading ${records.length} records to Neon database');
      
      final response = await http.post(
        Uri.parse('$_neonApiUrl/attendance'),
        headers: await _getHeaders(),
        body: jsonEncode({'records': records}),
      ).timeout(const Duration(seconds: 30));

      print('🔄 SYNC: Response status: ${response.statusCode}');
      print('🔄 SYNC: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Data synced to Neon successfully',
          'insertedCount': data['insertedCount'] ?? 0,
          'updatedCount': data['updatedCount'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to sync to Neon: HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error syncing to Neon: $e',
      };
    }
  }

  // Sync students to Neon database
  static Future<Map<String, dynamic>> syncStudentsToNeon(List<Map<String, dynamic>> students) async {
    try {
      print('🔄 SYNC: Uploading ${students.length} students to Neon database');
      
      final response = await http.post(
        Uri.parse('$_neonApiUrl/students/bulk'),
        headers: await _getHeaders(),
        body: jsonEncode({'students': students}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Students synced to Neon successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to sync students to Neon: HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error syncing students to Neon: $e',
      };
    }
  }

  // Test connection to Neon database
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_neonApiUrl/health'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('🔍 NEON CONNECTION TEST: Failed - $e');
      return false;
    }
  }

  // Get database statistics from Neon
  static Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_neonApiUrl/admin'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception('Failed to load database stats: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load database stats: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error loading database stats from Neon: $e');
    }
  }
}
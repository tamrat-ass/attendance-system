import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UnifiedAttendanceAPI {
  static const String baseUrl = 'https://mk-attendance.vercel.app/api';
  
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Access-Control-Allow-Origin': '*',
    };
  }

  // Test API connection
  static Future<bool> testConnection() async {
    try {
      print('🔍 Testing unified API connection...');
      final response = await http.get(
        Uri.parse('$baseUrl/students?limit=1'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Connection test: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connection failed: $e');
      return false;
    }
  }

  // GET attendance records - UNIFIED
  static Future<Map<String, dynamic>> getAttendance({
    String? date,
    String? studentId,
    String? className,
    String? startDate,
    String? endDate,
  }) async {
    try {
      print('📥 Getting attendance - Unified API');
      
      String url = '$baseUrl/attendance';
      List<String> params = [];
      
      if (date != null) params.add('date=$date');
      if (studentId != null) params.add('student_id=$studentId');
      if (className != null) params.add('class=$className');
      if (startDate != null) params.add('start_date=$startDate');
      if (endDate != null) params.add('end_date=$endDate');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('🔗 GET URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      print('📡 GET Response: ${response.statusCode}');
      print('📄 GET Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? [],
          'count': data['count'] ?? 0,
          'message': data['message'] ?? 'Success'
        };
      } else {
        print('❌ GET failed: ${response.statusCode}');
        return {
          'success': false,
          'data': [],
          'count': 0,
          'message': 'Failed to fetch attendance'
        };
      }
    } catch (e) {
      print('❌ GET Error: $e');
      return {
        'success': false,
        'data': [],
        'count': 0,
        'message': 'Network error: $e'
      };
    }
  }

  // POST attendance records - UNIFIED
  static Future<Map<String, dynamic>> saveAttendance(List<Map<String, dynamic>> records) async {
    if (records.isEmpty) {
      print('⚠️ No records to save');
      return {
        'success': false,
        'message': 'No records provided'
      };
    }

    try {
      print('💾 Saving attendance - Unified API');
      print('📊 Records count: ${records.length}');
      
      // Ensure all records have the correct format
      final formattedRecords = records.map((record) => {
        'student_id': record['student_id'],
        'date': record['date'],
        'status': record['status'],
        'notes': record['notes'] ?? '',
      }).toList();
      
      final payload = {
        'records': formattedRecords,
      };
      
      print('📤 POST Payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse('$baseUrl/attendance'),
        headers: _getHeaders(),
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      print('📡 POST Response: ${response.statusCode}');
      print('📄 POST Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Attendance saved successfully',
          'count': data['count'] ?? records.length,
          'data': data['data'] ?? formattedRecords
        };
      } else {
        print('❌ POST failed: ${response.statusCode}');
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to save attendance',
          'error': errorData['error']
        };
      }
    } catch (e) {
      print('❌ POST Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // PUT attendance record - UNIFIED
  static Future<Map<String, dynamic>> updateAttendance({
    required int studentId,
    required String date,
    required String status,
    String? notes,
  }) async {
    try {
      print('🔄 Updating attendance - Unified API');
      
      final payload = {
        'student_id': studentId,
        'date': date,
        'status': status,
        'notes': notes ?? '',
      };
      
      print('📤 PUT Payload: ${jsonEncode(payload)}');

      final response = await http.put(
        Uri.parse('$baseUrl/attendance'),
        headers: _getHeaders(),
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      print('📡 PUT Response: ${response.statusCode}');
      print('📄 PUT Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Attendance updated successfully',
          'data': data['data']
        };
      } else {
        print('❌ PUT failed: ${response.statusCode}');
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to update attendance'
        };
      }
    } catch (e) {
      print('❌ PUT Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // DELETE attendance record - UNIFIED
  static Future<Map<String, dynamic>> deleteAttendance({
    required int studentId,
    required String date,
  }) async {
    try {
      print('🗑️ Deleting attendance - Unified API');
      
      final url = '$baseUrl/attendance?student_id=$studentId&date=$date';
      print('🔗 DELETE URL: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      print('📡 DELETE Response: ${response.statusCode}');
      print('📄 DELETE Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Attendance deleted successfully',
          'data': data['data']
        };
      } else {
        print('❌ DELETE failed: ${response.statusCode}');
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to delete attendance'
        };
      }
    } catch (e) {
      print('❌ DELETE Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }
}
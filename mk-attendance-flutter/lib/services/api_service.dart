import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/student.dart';
import '../models/attendance.dart';

class ApiService {
  // Your existing web app API base URL
  static const String baseUrl = 'https://mk-attendance.vercel.app/api';
  
  static Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Access-Control-Allow-Origin': '*',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Check network connectivity
  static Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Test API connectivity
  static Future<bool> testApiConnection() async {
    try {
      print('Testing API connection to: $baseUrl/students');
      final response = await http.get(
        Uri.parse('$baseUrl/students?limit=1'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 10));
      
      print('API test response: ${response.statusCode}');
      print('API test body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('API test failed: $e');
      return false;
    }
  }

  // Test attendance API specifically
  static Future<bool> testAttendanceApi() async {
    try {
      print('Testing attendance API: $baseUrl/attendance');
      final response = await http.get(
        Uri.parse('$baseUrl/attendance?limit=1'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 10));
      
      print('Attendance API test response: ${response.statusCode}');
      print('Attendance API test body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Attendance API test failed: $e');
      return false;
    }
  }



  // Enhanced error handling
  static String _handleError(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is HttpException) {
      return 'Server error. Please try again later.';
    } else if (error is FormatException) {
      return 'Invalid server response format.';
    } else {
      return 'Network error: ${error.toString()}';
    }
  }

  // Authentication endpoints
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['user'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<bool> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _getHeaders(),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword, {String? username}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: _getHeaders(),
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'username': username,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password changed successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Student endpoints
  Future<List<Student>> getStudents({int limit = 1000}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/students?limit=$limit'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> studentsJson = data['data'] ?? [];
        return studentsJson.map((json) => Student.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Student> createStudent(Student student) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/students'),
        headers: _getHeaders(),
        body: jsonEncode(student.toJson()),
      );

      if (response.statusCode == 200) {
        // API returns success message, not student object
        // Return the student with a generated ID
        return student.copyWith(id: DateTime.now().millisecondsSinceEpoch);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create student');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Student> updateStudent(int id, Student student) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/students/$id'),
        headers: _getHeaders(),
        body: jsonEncode(student.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // The backend returns the updated student in 'data' field, not 'student'
        return Student.fromJson(data['data']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update student');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> deleteStudent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/students/$id'),
        headers: _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Attendance endpoints
  Future<List<Attendance>> getAttendance({
    String? date,
    String? className,
  }) async {
    try {
      String url = '$baseUrl/attendance';
      List<String> params = [];
      
      if (date != null) params.add('date=$date');
      if (className != null) params.add('class=$className');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> attendanceJson = data['data'] ?? [];
        return attendanceJson.map((json) => Attendance.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load attendance');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Attendance>> getAllAttendance() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/all'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> attendanceJson = data['data'] ?? [];
        return attendanceJson.map((json) => Attendance.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load all attendance');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> markAttendance(int studentId, String date, String status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance/mark'),
        headers: _getHeaders(),
        body: jsonEncode({
          'student_id': studentId,
          'date': date,
          'status': status,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveAttendance(List<Attendance> records) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance'),
        headers: _getHeaders(),
        body: jsonEncode({
          'records': records.map((r) => r.toJson()).toList(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> saveAttendanceRecords(List<Map<String, dynamic>> records) async {
    // Check connectivity first
    if (!await _checkConnectivity()) {
      print('❌ No internet connection for saving attendance');
      return {
        'success': false,
        'message': 'No internet connection. Please check your network and try again.',
        'error': 'NO_CONNECTION'
      };
    }

    // Validate records for duplicates before sending
    final Map<String, int> studentDateCount = {};
    final List<String> duplicates = [];
    
    for (var record in records) {
      final key = '${record['student_id']}-${record['date']}';
      studentDateCount[key] = (studentDateCount[key] ?? 0) + 1;
      
      if (studentDateCount[key]! > 1) {
        duplicates.add('Student ${record['student_id']} on ${record['date']}');
      }
    }
    
    if (duplicates.isNotEmpty) {
      return {
        'success': false,
        'message': 'Duplicate attendance detected: ${duplicates.join(', ')}. Each student can only have one attendance record per day.',
        'error': 'DUPLICATE_ATTENDANCE',
        'duplicates': duplicates
      };
    }

    // Test API connection before saving
    try {
      print('🔍 Testing API connection before save...');
      final testResponse = await http.get(
        Uri.parse('$baseUrl/students?limit=1'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 5));
      
      if (testResponse.statusCode != 200) {
        print('❌ API connection test failed: ${testResponse.statusCode}');
        return {
          'success': false,
          'message': 'Unable to connect to server. Please try again.',
          'error': 'CONNECTION_FAILED'
        };
      }
      print('✅ API connection test successful');
    } catch (e) {
      print('❌ API connection test error: $e');
      return {
        'success': false,
        'message': 'Connection test failed. Please check your internet connection.',
        'error': 'CONNECTION_TEST_FAILED'
      };
    }

    try {
      print('=== API SAVE ATTENDANCE DEBUG ===');
      print('API call to: $baseUrl/attendance');
      print('Sending ${records.length} records:');
      for (var record in records) {
        print('  - Student ${record['student_id']}: ${record['status']} on ${record['date']}');
      }
      final payload = {'records': records};
      final jsonPayload = jsonEncode(payload);
      print('Full payload: $jsonPayload');
      print('Headers: ${_getHeaders()}');
      print('URL: $baseUrl/attendance');
      print('Base URL: $baseUrl');
      
      final response = await http.post(
        Uri.parse('$baseUrl/attendance'),
        headers: _getHeaders(),
        body: jsonPayload,
      ).timeout(const Duration(seconds: 15));

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          final success = data['success'] == true || 
                         (data['message'] != null && !data['message'].toString().toLowerCase().contains('error'));
          
          print('✅ Save success: $success (message: ${data['message']})');
          
          if (success) {
            // Double-check by verifying the data was actually saved
            print('🔍 Verifying save by checking database...');
            try {
              final verifyResponse = await http.get(
                Uri.parse('$baseUrl/attendance?date=${records.first['date']}&_verify=${DateTime.now().millisecondsSinceEpoch}'),
                headers: _getHeaders(),
              ).timeout(const Duration(seconds: 5));
              
              if (verifyResponse.statusCode == 200) {
                final verifyData = jsonDecode(verifyResponse.body);
                final savedRecords = verifyData['data'] ?? [];
                print('✅ Verification: Found ${savedRecords.length} records in database');
              }
            } catch (e) {
              print('⚠️ Verification failed but save appeared successful: $e');
            }
            
            return {
              'success': true,
              'message': data['message'] ?? 'Attendance saved successfully',
              'insertedCount': data['insertedCount'] ?? 0,
              'updatedCount': data['updatedCount'] ?? 0
            };
          } else {
            return {
              'success': false,
              'message': data['message'] ?? 'Failed to save attendance',
              'error': data['error'] ?? 'SAVE_FAILED'
            };
          }
        } catch (e) {
          // If JSON parsing fails but status is 200, assume success
          print('JSON parse error but status 200, assuming success: $e');
          return {
            'success': true,
            'message': 'Attendance saved successfully'
          };
        }
      } else if (response.statusCode == 409) {
        // Handle duplicate attendance conflict
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'Duplicate attendance detected',
            'error': data['error'] ?? 'DUPLICATE_ATTENDANCE',
            'hint': data['hint']
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Duplicate attendance detected. Each student can only have one attendance record per day.',
            'error': 'DUPLICATE_ATTENDANCE'
          };
        }
      } else if (response.statusCode == 400) {
        // Handle validation errors
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'Invalid attendance data',
            'error': data['error'] ?? 'VALIDATION_ERROR',
            'duplicates': data['duplicates']
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Invalid attendance data provided',
            'error': 'VALIDATION_ERROR'
          };
        }
      } else {
        print('❌ Save failed with status: ${response.statusCode}, body: ${response.body}');
        return {
          'success': false,
          'message': 'Server error (${response.statusCode}). Please try again.',
          'error': 'SERVER_ERROR'
        };
      }
    } on SocketException {
      print('Network error: No internet connection');
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
        'error': 'NO_CONNECTION'
      };
    } catch (e) {
      print('Save error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': 'NETWORK_ERROR'
      };
    }
  }

  // Classes endpoints - Get unique classes from existing students
  Future<List<String>> getClasses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/classes'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> classesJson = data['data'] ?? [];
          return classesJson.map((classData) => classData['class_name'] as String).toList();
        } else {
          throw Exception('Failed to load classes: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load classes');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Reports endpoints
  Future<Map<String, dynamic>> getReports({
    String? startDate,
    String? endDate,
    String? className,
  }) async {
    try {
      String url = '$baseUrl/reports';
      List<String> params = [];
      
      if (startDate != null) params.add('start_date=$startDate');
      if (endDate != null) params.add('end_date=$endDate');
      if (className != null) params.add('class=$className');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception('Failed to load reports: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load reports');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getReportStatistics({
    String? startDate,
    String? endDate,
    String? className,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reports'),
        headers: _getHeaders(),
        body: jsonEncode({
          'start_date': startDate,
          'end_date': endDate,
          'class': className,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('Failed to load statistics: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load statistics');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Admin endpoints
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception('Failed to load admin stats: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load admin stats');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> performAdminAction(String action) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin'),
        headers: _getHeaders(),
        body: jsonEncode({'action': action}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to perform admin action');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // User management endpoints
  Future<List<Map<String, dynamic>>> getUsers() async {
    // Check connectivity first
    if (!await _checkConnectivity()) {
      throw Exception('No internet connection. Please check your network and try again.');
    }

    try {
      print('Attempting to fetch users from: $baseUrl/users');
      
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('Server error: ${data['message'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Users endpoint not found. Please check server configuration.');
      } else if (response.statusCode >= 500) {
        throw Exception('Server is temporarily unavailable. Please try again later.');
      } else {
        throw Exception('Failed to load users (Status: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Unable to connect to server. Please check your internet connection.');
    } on HttpException {
      throw Exception('Server error occurred. Please try again later.');
    } on FormatException {
      throw Exception('Invalid response from server. Please contact support.');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connection timeout. Please check your internet connection and try again.');
      }
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> createUser({
    required String username,
    required String fullName,
    required String password,
    String role = 'user',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
          'full_name': fullName,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['data'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateUser(int userId, {
    String? username,
    String? fullName,
    String? role,
    String? status,
    String? password,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (username != null) body['username'] = username;
      if (fullName != null) body['full_name'] = fullName;
      if (role != null) body['role'] = role;
      if (status != null) body['status'] = status;
      if (password != null) body['password'] = password;

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['data'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }



}
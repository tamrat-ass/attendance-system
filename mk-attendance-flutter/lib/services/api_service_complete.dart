import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/student.dart';
import '../models/attendance.dart';
import 'auth_service.dart';

class ApiService {
  // Your existing web app API base URL
  static const String baseUrl = 'https://mk-attendance.vercel.app/api';
  
  static Future<Map<String, String>> _getHeaders({String? token}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Access-Control-Allow-Origin': '*',
    };
    
    // Use provided token or get from storage
    final authToken = token ?? await AuthService.getToken();
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
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
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));
      
      print('API test response: ${response.statusCode}');
      print('API test body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('API test failed: $e');
      return false;
    }
  }

  // Handle common errors
  static String _handleError(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Connection timeout. Please try again.';
    } else {
      return error.toString();
    }
  }

  // ========== AUTH METHODS ==========
  
  // Login - EXACT copy from website API
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': _handleError(e)
      };
    }
  }

  // Change Password - EXACT copy from website API
  Future<Map<String, dynamic>> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'userId': userId,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password changed successfully'
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to change password'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': _handleError(e)
      };
    }
  }

  // ========== STUDENTS METHODS ==========
  
  // Get Students - EXACT copy from website API
  Future<List<Student>> getStudents({
    String? search,
    String? name,
    String? phone,
    String? studentClass,
    int page = 1,
    int limit = 1000,
  }) async {
    try {
      String url = '$baseUrl/students';
      List<String> params = [];
      
      if (search != null) params.add('search=${Uri.encodeComponent(search)}');
      if (name != null) params.add('name=${Uri.encodeComponent(name)}');
      if (phone != null) params.add('phone=${Uri.encodeComponent(phone)}');
      if (studentClass != null) params.add('class=${Uri.encodeComponent(studentClass)}');
      params.add('page=$page');
      params.add('limit=$limit');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
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

  // Create Student - EXACT copy from website API
  Future<Student> createStudent(Student student) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/students'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'full_name': student.fullName,
          'phone': student.phone,
          'class': student.className,
          'gender': student.gender,
        }),
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

  // Update Student
  Future<Student> updateStudent(int id, Student student) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/students/$id'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'full_name': student.fullName,
          'phone': student.phone,
          'class': student.className,
          'gender': student.gender,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Student.fromJson(data['data']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update student');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete Student
  Future<bool> deleteStudent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/students/$id'),
        headers: await _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ========== ATTENDANCE METHODS ==========
  
  // Get Attendance - EXACT copy from website API
  Future<List<Map<String, dynamic>>> getAttendance({
    String? date,
    int? studentId,
    String? classParam,
    String? startDate,
    String? endDate,
  }) async {
    try {
      String url = '$baseUrl/attendance';
      List<String> params = [];
      
      if (date != null) params.add('date=$date');
      if (studentId != null) params.add('student_id=$studentId');
      if (classParam != null) params.add('class=${Uri.encodeComponent(classParam)}');
      if (startDate != null) params.add('start_date=$startDate');
      if (endDate != null) params.add('end_date=$endDate');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to load attendance');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Save Attendance - EXACT copy from website API
  Future<Map<String, dynamic>> saveAttendance(List<Map<String, dynamic>> records) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'records': records,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Attendance saved successfully',
          'count': data['count']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to save attendance'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // ========== CLASSES METHODS ==========
  
  // Get Classes - EXACT copy from website API
  Future<List<String>> getClasses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/classes'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> classesJson = data['data'] ?? [];
          return classesJson.map((classData) => classData['name'] as String).toList();
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

  // Create Class - EXACT copy from website API
  Future<Map<String, dynamic>> createClass({
    required String className,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/classes'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': className,
          'description': description,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Class created successfully',
          'data': data['data']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create class'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }
}
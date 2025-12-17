import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/student.dart';
import '../models/attendance.dart';
import 'auth_service.dart';

class ApiService {
  // Your existing web app API base URL - SAME DATABASE AS WEBSITE
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

  // Test Classes API specifically
  static Future<Map<String, dynamic>> testClassesApi() async {
    try {
      print('🔥 TESTING: Classes API at $baseUrl/classes');
      
      final headers = await _getHeaders();
      print('🔥 TESTING: Headers - ${headers.keys.join(', ')}');
      print('🔥 TESTING: Auth token present: ${headers['Authorization'] != null}');
      
      final response = await http.get(
        Uri.parse('$baseUrl/classes'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('🔥 TESTING: Response status: ${response.statusCode}');
      print('🔥 TESTING: Response headers: ${response.headers}');
      print('🔥 TESTING: Response body: ${response.body}');
      
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'body': response.body,
        'error': response.statusCode != 200 ? 'HTTP ${response.statusCode}' : null,
      };
    } catch (e) {
      print('🔥 TESTING: Classes API test failed: $e');
      return {
        'success': false,
        'statusCode': -1,
        'body': '',
        'error': e.toString(),
      };
    }
  }

  // Alternative method to get classes from students data (fallback)
  Future<List<Map<String, dynamic>>> getClassesFromStudents() async {
    try {
      print('🔥 FALLBACK: Getting classes from students data');
      
      final students = await getStudents(limit: 1000);
      final classSet = <String>{};
      
      for (final student in students) {
        if (student.className.isNotEmpty) {
          classSet.add(student.className);
        }
      }
      
      final classesList = classSet.map((className) => {
        'id': className.hashCode,
        'name': className,
        'description': 'Extracted from student data',
        'created_at': DateTime.now().toIso8601String(),
      }).toList();
      
      print('🔥 FALLBACK: Found ${classesList.length} classes from students');
      return classesList;
    } catch (e) {
      print('🔥 FALLBACK ERROR: $e');
      throw Exception('Fallback method failed: $e');
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

  // Create Student - Enhanced with better error handling
  Future<Student> createStudent(Student student) async {
    // Check connectivity first
    if (!await _checkConnectivity()) {
      throw Exception('No internet connection. Please check your network and try again.');
    }

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        print('🔄 Creating student (attempt ${retryCount + 1}/$maxRetries)...');
        
        // Bulletproof email validation and auto-fix
        String email = student.email?.trim() ?? '';
        
        // Auto-generate email if empty
        if (email.isEmpty) {
          email = 'student${DateTime.now().millisecondsSinceEpoch}@gmail.com';
          print('⚠️ Empty email detected, using: $email');
        }
        
        // Ensure @gmail.com format
        if (!email.endsWith('@gmail.com')) {
          if (email.contains('@')) {
            email = email.split('@')[0] + '@gmail.com';
          } else {
            email = email + '@gmail.com';
          }
          print('⚠️ Fixed email to: $email');
        }
        
        print('📧 Final email: $email');

        // Ensure all fields are never null or empty
        final fullName = student.fullName.trim().isEmpty ? 'Student Name' : student.fullName.trim();
        final phone = student.phone.trim().isEmpty ? '0912345678' : student.phone.trim();
        final className = student.className.trim().isEmpty ? 'Grade 10' : student.className.trim();
        final gender = student.gender?.trim().isEmpty == true ? 'Male' : (student.gender ?? 'Male');

        final requestBody = {
          'full_name': fullName,
          'phone': phone,
          'class': className,
          'gender': gender,
          'email': email,
        };
        
        print('📤 Request URL: $baseUrl/students');
        print('📤 Request body: ${jsonEncode(requestBody)}');
        print('📤 Headers: ${await _getHeaders()}');
        
        final response = await http.post(
          Uri.parse('$baseUrl/students'),
          headers: await _getHeaders(),
          body: jsonEncode(requestBody),
        ).timeout(const Duration(seconds: 15));

        print('📡 Response status: ${response.statusCode}');
        print('📡 Response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('✅ Student created successfully');
          // API returns success message, not student object
          // Return the student with a generated ID
          return student.copyWith(id: DateTime.now().millisecondsSinceEpoch);
        } else {
          print('❌ HTTP Error ${response.statusCode}');
          print('❌ Response body: ${response.body}');
          
          try {
            final error = jsonDecode(response.body);
            final errorMessage = error['message'] ?? 'Failed to create student';
            print('❌ Parsed error: $errorMessage');
            throw Exception(errorMessage);
          } catch (parseError) {
            print('❌ Failed to parse error response: $parseError');
            throw Exception('Server error (${response.statusCode}): ${response.body}');
          }
        }
      } catch (e) {
        retryCount++;
        print('⚠️ Attempt $retryCount failed: $e');
        
        if (retryCount >= maxRetries) {
          if (e.toString().contains('TimeoutException')) {
            throw Exception('Request timeout. Please check your internet connection and try again.');
          } else if (e.toString().contains('SocketException')) {
            throw Exception('Connection failed. Please check your internet connection.');
          } else {
            throw Exception('Failed to create student: ${e.toString().replaceAll('Exception: ', '')}');
          }
        }
        
        // Wait before retry
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
    
    throw Exception('Failed to create student after $maxRetries attempts');
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
          'email': student.email,
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

  // ========== QR ATTENDANCE METHODS ==========
  
  // Mark attendance via QR code
  Future<bool> markAttendanceViaQR({
    required String qrData,
    String? date,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance/qr'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'qr_data': qrData,
          'date': date,
          'notes': notes,
        }),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 409) {
        // Already marked - still consider as success
        return true;
      } else {
        print('QR attendance failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error marking QR attendance: $e');
      return false;
    }
  }

  // Validate QR code
  Future<Map<String, dynamic>?> validateQRCode(String qrData) async {
    try {
      final encodedQR = Uri.encodeComponent(qrData);
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/qr?qr_data=$encodedQR'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('QR validation failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error validating QR code: $e');
      return null;
    }
  }

  // Mark attendance (existing method enhanced)
  Future<bool> markAttendance({
    required int studentId,
    required String date,
    required String status,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'student_id': studentId,
          'date': date,
          'status': status,
          'notes': notes,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking attendance: $e');
      return false;
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

  // Get Classes with Full Details - Fixed with proper error handling
  Future<List<Map<String, dynamic>>> getClassesWithDetails() async {
    try {
      print('🔥 CLASS API: Fetching classes from $baseUrl/classes');
      
      // Get headers with authentication
      final headers = await _getHeaders();
      print('🔥 CLASS API: Auth token present: ${headers['Authorization'] != null}');
      
      final response = await http.get(
        Uri.parse('$baseUrl/classes'),
        headers: headers,
      );

      print('🔥 CLASS API: Response status: ${response.statusCode}');
      print('🔥 CLASS API: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> classesJson = data['data'] ?? [];
          print('🔥 CLASS API: Found ${classesJson.length} classes');
          return List<Map<String, dynamic>>.from(classesJson);
        } else {
          throw Exception('API Error: ${data['message'] ?? 'Unknown API error'}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 404) {
        // Classes endpoint might not exist - return empty list for fresh install
        print('🔥 CLASS API: Classes endpoint not found (404) - treating as fresh install');
        return [];
      } else {
        throw Exception('Server error (${response.statusCode}): ${response.reasonPhrase}');
      }
    } catch (e) {
      print('🔥 CLASS API ERROR: $e');
      
      // Handle specific error types
      if (e.toString().contains('SocketException') || e.toString().contains('HandshakeException')) {
        throw Exception('Network connection failed. Check your internet connection.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Please try again.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Invalid server response format.');
      } else {
        // Re-throw the original exception
        rethrow;
      }
    }
  }

  // Create Class - Enhanced with debugging
  Future<Map<String, dynamic>> createClass({
    required String className,
    String? description,
  }) async {
    try {
      print('🔥 CREATE CLASS: Creating class "$className"');
      
      final headers = await _getHeaders();
      final body = jsonEncode({
        'name': className,
        'description': description,
      });
      
      print('🔥 CREATE CLASS: Headers - Auth: ${headers['Authorization'] != null}');
      print('🔥 CREATE CLASS: Body: $body');
      
      final response = await http.post(
        Uri.parse('$baseUrl/classes'),
        headers: headers,
        body: body,
      );

      print('🔥 CREATE CLASS: Response status: ${response.statusCode}');
      print('🔥 CREATE CLASS: Response body: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('🔥 CREATE CLASS: Success!');
        return {
          'success': true,
          'message': data['message'] ?? 'Class created successfully',
          'data': data['data']
        };
      } else {
        print('🔥 CREATE CLASS: Failed with status ${response.statusCode}');
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create class (${response.statusCode})'
        };
      }
    } catch (e) {
      print('🔥 CREATE CLASS ERROR: $e');
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Update Class - Enhanced with debugging
  Future<Map<String, dynamic>> updateClass({
    required int classId,
    required String className,
    String? description,
  }) async {
    try {
      print('🔥 UPDATE CLASS: Updating class ID $classId to "$className"');
      
      final headers = await _getHeaders();
      final body = jsonEncode({
        'name': className,
        'description': description,
      });
      
      print('🔥 UPDATE CLASS: URL: $baseUrl/classes/$classId');
      print('🔥 UPDATE CLASS: Headers - Auth: ${headers['Authorization'] != null}');
      print('🔥 UPDATE CLASS: Body: $body');
      
      final response = await http.put(
        Uri.parse('$baseUrl/classes/$classId'),
        headers: headers,
        body: body,
      );

      print('🔥 UPDATE CLASS: Response status: ${response.statusCode}');
      print('🔥 UPDATE CLASS: Response body: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        print('🔥 UPDATE CLASS: Success!');
        return {
          'success': true,
          'message': data['message'] ?? 'Class updated successfully',
          'data': data['data']
        };
      } else {
        print('🔥 UPDATE CLASS: Failed with status ${response.statusCode}');
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update class (${response.statusCode})'
        };
      }
    } catch (e) {
      print('🔥 UPDATE CLASS ERROR: $e');
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Delete Class - Enhanced with debugging
  Future<Map<String, dynamic>> deleteClass(int classId) async {
    try {
      print('🔥 DELETE CLASS: Deleting class ID $classId');
      
      final headers = await _getHeaders();
      
      print('🔥 DELETE CLASS: URL: $baseUrl/classes/$classId');
      print('🔥 DELETE CLASS: Headers - Auth: ${headers['Authorization'] != null}');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/classes/$classId'),
        headers: headers,
      );

      print('🔥 DELETE CLASS: Response status: ${response.statusCode}');
      print('🔥 DELETE CLASS: Response body: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        print('🔥 DELETE CLASS: Success!');
        return {
          'success': true,
          'message': data['message'] ?? 'Class deleted successfully'
        };
      } else {
        print('🔥 DELETE CLASS: Failed with status ${response.statusCode}');
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete class (${response.statusCode})'
        };
      }
    } catch (e) {
      print('🔥 DELETE CLASS ERROR: $e');
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

class DirectDatabaseService {
  // Direct connection to your website's database via API
  static const String baseUrl = 'https://mk-attendance.vercel.app/api';
  
  static Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ========== DIRECT ATTENDANCE TABLE CALLS ==========
  
  // Get attendance records directly from attendance table
  static Future<List<Map<String, dynamic>>> getAttendanceFromTable({
    String? date,
    String? className,
    String? startDate,
    String? endDate,
  }) async {
    try {
      String url = '$baseUrl/attendance';
      List<String> params = [];
      
      if (date != null) params.add('date=$date');
      if (className != null) params.add('class=${Uri.encodeComponent(className)}');
      if (startDate != null) params.add('start_date=$startDate');
      if (endDate != null) params.add('end_date=$endDate');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('📊 DIRECT DB: Calling attendance table: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      print('📊 DIRECT DB: Response status: ${response.statusCode}');
      print('📊 DIRECT DB: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to get attendance from table: ${response.statusCode}');
      }
    } catch (e) {
      print('📊 DIRECT DB ERROR: $e');
      throw Exception('Database connection error: $e');
    }
  }

  // Save attendance records directly to attendance table
  static Future<Map<String, dynamic>> saveAttendanceToTable(List<Map<String, dynamic>> records) async {
    try {
      print('📊 DIRECT DB: Saving ${records.length} records to attendance table');
      
      final response = await http.post(
        Uri.parse('$baseUrl/attendance'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'records': records,
        }),
      );

      print('📊 DIRECT DB: Save response status: ${response.statusCode}');
      print('📊 DIRECT DB: Save response body: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Attendance saved to table successfully',
          'count': data['count']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to save to attendance table'
        };
      }
    } catch (e) {
      print('📊 DIRECT DB SAVE ERROR: $e');
      return {
        'success': false,
        'message': 'Database save error: $e'
      };
    }
  }

  // ========== DIRECT STUDENTS TABLE CALLS ==========
  
  // Get students directly from students table
  static Future<List<Map<String, dynamic>>> getStudentsFromTable({
    String? search,
    String? className,
    int limit = 1000,
  }) async {
    try {
      String url = '$baseUrl/students';
      List<String> params = [];
      
      if (search != null) params.add('search=${Uri.encodeComponent(search)}');
      if (className != null) params.add('class=${Uri.encodeComponent(className)}');
      params.add('limit=$limit');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('👥 DIRECT DB: Calling students table: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      print('👥 DIRECT DB: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to get students from table: ${response.statusCode}');
      }
    } catch (e) {
      print('👥 DIRECT DB ERROR: $e');
      throw Exception('Students table error: $e');
    }
  }

  // ========== DIRECT CLASSES TABLE CALLS ==========
  
  // Get classes directly from classes table
  static Future<List<String>> getClassesFromTable() async {
    try {
      print('🏫 DIRECT DB: Calling classes table');

      final response = await http.get(
        Uri.parse('$baseUrl/classes'),
        headers: await _getHeaders(),
      );

      print('🏫 DIRECT DB: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> classesJson = data['data'] ?? [];
          return classesJson.map((classData) => classData['name'] as String).toList();
        } else {
          throw Exception('Failed to load classes: ${data['message']}');
        }
      } else {
        throw Exception('Failed to get classes from table: ${response.statusCode}');
      }
    } catch (e) {
      print('🏫 DIRECT DB ERROR: $e');
      throw Exception('Classes table error: $e');
    }
  }

  // ========== DIRECT USERS TABLE CALLS ==========
  
  // Login directly from users table
  static Future<Map<String, dynamic>> loginFromUsersTable(String username, String password) async {
    try {
      print('🔐 DIRECT DB: Calling users table for login');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('🔐 DIRECT DB: Login response status: ${response.statusCode}');
      print('🔐 DIRECT DB: Login response body: ${response.body}');

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
      print('🔐 DIRECT DB LOGIN ERROR: $e');
      return {
        'success': false,
        'message': 'Users table login error: $e'
      };
    }
  }

  // ========== DATABASE CONNECTION TEST ==========
  
  // Test direct connection to database
  static Future<bool> testDatabaseConnection() async {
    try {
      print('🔍 DIRECT DB: Testing database connection');
      
      final response = await http.get(
        Uri.parse('$baseUrl/students?limit=1'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 5));
      
      print('🔍 DIRECT DB: Test response: ${response.statusCode}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('🔍 DIRECT DB TEST ERROR: $e');
      return false;
    }
  }

  // Get database table info
  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      // Test all main tables
      final studentsTest = await http.get(Uri.parse('$baseUrl/students?limit=1'), headers: await _getHeaders());
      final attendanceTest = await http.get(Uri.parse('$baseUrl/attendance?limit=1'), headers: await _getHeaders());
      final classesTest = await http.get(Uri.parse('$baseUrl/classes'), headers: await _getHeaders());
      
      return {
        'students_table': studentsTest.statusCode == 200 ? 'Connected' : 'Error ${studentsTest.statusCode}',
        'attendance_table': attendanceTest.statusCode == 200 ? 'Connected' : 'Error ${attendanceTest.statusCode}',
        'classes_table': classesTest.statusCode == 200 ? 'Connected' : 'Error ${classesTest.statusCode}',
        'database_url': baseUrl,
        'connection_status': 'Direct connection to website database'
      };
    } catch (e) {
      return {
        'error': 'Database connection failed: $e',
        'database_url': baseUrl,
        'connection_status': 'Failed'
      };
    }
  }
}
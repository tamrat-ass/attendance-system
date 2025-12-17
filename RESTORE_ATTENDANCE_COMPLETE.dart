// COMPLETE ATTENDANCE API METHODS - TO BE ADDED TO API SERVICE

  // ========== ATTENDANCE METHODS ==========
  
  // Get attendance for a specific date and class
  Future<List<Attendance>> getAttendance({
    required String date,
    String? className,
  }) async {
    try {
      String url = '$baseUrl/attendance';
      List<String> params = ['date=$date'];
      if (className != null && className.isNotEmpty) {
        params.add('class=${Uri.encodeComponent(className)}');
      }
      url += '?${params.join('&')}';

      print('🔍 Getting attendance from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      print('📊 Attendance response: ${response.statusCode}');
      print('📊 Attendance body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> attendanceJson = data['data'] ?? [];
          return attendanceJson.map((json) => Attendance.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load attendance: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load attendance (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('❌ Attendance error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Save bulk attendance data
  Future<Map<String, dynamic>> saveAttendance(List<Map<String, dynamic>> attendanceData) async {
    try {
      print('💾 Saving attendance data: ${attendanceData.length} records');
      
      final response = await http.post(
        Uri.parse('$baseUrl/attendance'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'attendance': attendanceData,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      print('💾 Save response: ${response.statusCode}');
      print('💾 Save body: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Attendance saved successfully',
          'data': data['data']
        };
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': 'Duplicate attendance detected',
          'error': 'DUPLICATE_ATTENDANCE',
          'duplicates': data['duplicates']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to save attendance',
          'error': 'SERVER_ERROR'
        };
      }
    } catch (e) {
      print('❌ Save error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': 'NETWORK_ERROR'
      };
    }
  }

  // Mark individual student attendance
  Future<Map<String, dynamic>> markAttendance({
    required int studentId,
    required String date,
    required String status,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance/mark'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'student_id': studentId,
          'date': date,
          'status': status,
          'notes': notes,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Attendance marked successfully'
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to mark attendance'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Update existing attendance
  Future<Map<String, dynamic>> updateAttendance({
    required int attendanceId,
    required String status,
    String? notes,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/attendance/$attendanceId'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'status': status,
          'notes': notes,
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Attendance updated successfully'
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update attendance'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Delete attendance record
  Future<Map<String, dynamic>> deleteAttendance(int attendanceId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/attendance/$attendanceId'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Attendance deleted successfully'
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete attendance'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Get attendance statistics
  Future<Map<String, dynamic>> getAttendanceStats({
    String? startDate,
    String? endDate,
    String? className,
  }) async {
    try {
      String url = '$baseUrl/attendance/stats';
      List<String> params = [];
      
      if (startDate != null) params.add('start_date=$startDate');
      if (endDate != null) params.add('end_date=$endDate');
      if (className != null) params.add('class=${Uri.encodeComponent(className)}');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': 'Statistics loaded successfully'
        };
      } else {
        throw Exception('Failed to load statistics');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
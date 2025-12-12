import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/simple_attendance.dart';

class SimpleAPI {
  static const String baseUrl = 'https://mk-attendance.vercel.app/api';
  
  // Test connection
  static Future<bool> testConnection() async {
    try {
      print('🔍 Testing API connection...');
      final response = await http.get(
        Uri.parse('$baseUrl/students?limit=1'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Connection test: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connection failed: $e');
      return false;
    }
  }

  // Get existing attendance for a date
  static Future<List<SimpleAttendance>> getAttendance(String date) async {
    try {
      print('📥 Getting attendance for date: $date');
      
      final response = await http.get(
        Uri.parse('$baseUrl/attendance?date=$date'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      print('📡 Get response: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> records = data['data'] ?? [];
        
        List<SimpleAttendance> attendance = records
            .map((json) => SimpleAttendance.fromJson(json))
            .toList();
            
        print('✅ Loaded ${attendance.length} attendance records');
        return attendance;
      } else {
        print('❌ Failed to get attendance: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error getting attendance: $e');
      return [];
    }
  }

  // Save attendance records
  static Future<bool> saveAttendance(List<SimpleAttendance> records) async {
    if (records.isEmpty) {
      print('⚠️ No records to save');
      return false;
    }

    try {
      print('💾 Saving ${records.length} attendance records...');
      
      // Convert to the format expected by the API
      final payload = {
        'records': records.map((r) => r.toJson()).toList(),
      };
      
      print('📤 Payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse('$baseUrl/attendance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      print('📡 Save response: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Save successful: ${data['message']}');
        return true;
      } else {
        print('❌ Save failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error saving attendance: $e');
      return false;
    }
  }
}
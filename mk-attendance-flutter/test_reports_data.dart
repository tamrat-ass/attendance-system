import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔥 Testing Reports Data...');
  
  try {
    // Test students API
    final studentsResponse = await http.get(
      Uri.parse('https://mk-attendance.vercel.app/api/students?limit=1000'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    print('🔥 Students Response: ${studentsResponse.statusCode}');
    
    if (studentsResponse.statusCode == 200) {
      final studentsData = jsonDecode(studentsResponse.body);
      final students = List<Map<String, dynamic>>.from(studentsData['data'] ?? []);
      print('🔥 Students found: ${students.length}');
      
      if (students.isNotEmpty) {
        print('🔥 First student: ${students[0]}');
        print('🔥 Student IDs: ${students.take(5).map((s) => s['id']).toList()}');
      }
    }

    // Test attendance API
    final attendanceResponse = await http.get(
      Uri.parse('https://mk-attendance.vercel.app/api/attendance'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    print('🔥 Attendance Response: ${attendanceResponse.statusCode}');
    
    if (attendanceResponse.statusCode == 200) {
      final attendanceData = jsonDecode(attendanceResponse.body);
      final attendance = List<Map<String, dynamic>>.from(attendanceData['data'] ?? []);
      print('🔥 Attendance records found: ${attendance.length}');
      
      if (attendance.isNotEmpty) {
        print('🔥 First attendance: ${attendance[0]}');
        print('🔥 Attendance student_ids: ${attendance.take(5).map((a) => a['student_id']).toList()}');
        print('🔥 Attendance statuses: ${attendance.take(5).map((a) => a['status']).toList()}');
        print('🔥 Attendance dates: ${attendance.take(5).map((a) => a['date']).toList()}');
      }
    }

    // Test data matching
    if (studentsResponse.statusCode == 200 && attendanceResponse.statusCode == 200) {
      final studentsData = jsonDecode(studentsResponse.body);
      final students = List<Map<String, dynamic>>.from(studentsData['data'] ?? []);
      
      final attendanceData = jsonDecode(attendanceResponse.body);
      final attendance = List<Map<String, dynamic>>.from(attendanceData['data'] ?? []);
      
      print('\n🔥 DATA MATCHING TEST:');
      print('Students: ${students.length}, Attendance: ${attendance.length}');
      
      // Check if student IDs match attendance student_ids
      final studentIds = students.map((s) => s['id']).toSet();
      final attendanceStudentIds = attendance.map((a) => a['student_id']).toSet();
      
      print('Student IDs: ${studentIds.take(5)}');
      print('Attendance Student IDs: ${attendanceStudentIds.take(5)}');
      
      final matchingIds = studentIds.intersection(attendanceStudentIds);
      print('Matching IDs: ${matchingIds.length}');
      
      if (matchingIds.isEmpty) {
        print('❌ NO MATCHING IDs - This is the problem!');
        print('Student ID types: ${students.take(3).map((s) => '${s['id']} (${s['id'].runtimeType})').toList()}');
        print('Attendance ID types: ${attendance.take(3).map((a) => '${a['student_id']} (${a['student_id'].runtimeType})').toList()}');
      } else {
        print('✅ Found ${matchingIds.length} matching student IDs');
      }
      
      // Test status distribution
      final statusCounts = <String, int>{};
      for (final record in attendance) {
        final status = record['status']?.toString() ?? 'unknown';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }
      print('Status distribution: $statusCounts');
    }

  } catch (e) {
    print('🔥 Exception: $e');
  }
}
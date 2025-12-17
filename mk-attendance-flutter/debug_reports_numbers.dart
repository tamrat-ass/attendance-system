import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔥 DEBUGGING REPORTS NUMBERS');
  print('============================');
  
  try {
    // Get students data
    final studentsResponse = await http.get(
      Uri.parse('https://mk-attendance.vercel.app/api/students?limit=1000'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    );
    
    // Get attendance data
    final attendanceResponse = await http.get(
      Uri.parse('https://mk-attendance.vercel.app/api/attendance'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    );

    if (studentsResponse.statusCode == 200 && attendanceResponse.statusCode == 200) {
      final studentsData = jsonDecode(studentsResponse.body);
      final students = List<Map<String, dynamic>>.from(studentsData['data'] ?? []);
      
      final attendanceData = jsonDecode(attendanceResponse.body);
      final allAttendance = List<Map<String, dynamic>>.from(attendanceData['data'] ?? []);
      
      print('📊 RAW DATA:');
      print('Students: ${students.length}');
      print('All Attendance Records: ${allAttendance.length}');
      
      // Test date filtering (last 30 days)
      final now = DateTime.now();
      final lastMonth = now.subtract(const Duration(days: 30));
      final startDate = lastMonth.toIso8601String().split('T')[0];
      final endDate = now.toIso8601String().split('T')[0];
      
      final filteredAttendance = allAttendance.where((a) {
        final dateStr = a['date']?.toString() ?? '';
        if (dateStr.isEmpty) return false;
        
        final date = dateStr.split('T')[0];
        return date.compareTo(startDate) >= 0 && date.compareTo(endDate) <= 0;
      }).toList();
      
      print('\n📅 DATE FILTERING:');
      print('Date Range: $startDate to $endDate');
      print('Filtered Attendance: ${filteredAttendance.length}');
      
      // Test status counting
      print('\n📈 STATUS COUNTING:');
      
      final presentCount = filteredAttendance.where((a) => 
        a['status']?.toString().toLowerCase() == 'present').length;
      final absentCount = filteredAttendance.where((a) => 
        a['status']?.toString().toLowerCase() == 'absent').length;
      final lateCount = filteredAttendance.where((a) => 
        a['status']?.toString().toLowerCase() == 'late').length;
      final permissionCount = filteredAttendance.where((a) => 
        a['status']?.toString().toLowerCase() == 'permission').length;
      
      print('Present: $presentCount');
      print('Absent: $absentCount');
      print('Late: $lateCount');
      print('Permission: $permissionCount');
      print('Total: ${presentCount + absentCount + lateCount + permissionCount}');
      
      final overallRate = filteredAttendance.length > 0 ? 
        (presentCount * 100.0 / filteredAttendance.length).toStringAsFixed(1) : '0.0';
      print('Overall Rate: $overallRate%');
      
      // Test class filtering
      print('\n🏫 CLASS ANALYSIS:');
      final classes = students.map((s) => s['class']).toSet().toList();
      print('Total Classes: ${classes.length}');
      
      for (final className in classes.take(3)) {
        final classStudentIds = students
            .where((s) => s['class'] == className)
            .map((s) => s['id'])
            .toSet();
        
        final classAttendance = filteredAttendance
            .where((a) => classStudentIds.contains(a['student_id']))
            .toList();
        
        final classPresent = classAttendance.where((a) => 
          a['status']?.toString().toLowerCase() == 'present').length;
        
        final classRate = classAttendance.length > 0 ? 
          (classPresent * 100.0 / classAttendance.length).toStringAsFixed(1) : '0.0';
        
        print('$className: ${classStudentIds.length} students, ${classAttendance.length} records, $classRate% rate');
      }
      
      // Test student lists
      print('\n👥 STUDENT LISTS:');
      
      final studentMap = <int, Map<String, dynamic>>{};
      for (final student in students) {
        studentMap[student['id']] = student;
      }

      final presentStudents = <Map<String, dynamic>>[];
      final absentStudents = <Map<String, dynamic>>[];
      
      for (final record in filteredAttendance) {
        final studentId = record['student_id'];
        final status = record['status']?.toString().toLowerCase() ?? '';
        final student = studentMap[studentId];
        
        if (student != null) {
          final studentInfo = {
            ...student,
            'attendance_date': record['date'],
            'notes': record['notes'],
          };

          switch (status) {
            case 'present':
              presentStudents.add(studentInfo);
              break;
            case 'absent':
              absentStudents.add(studentInfo);
              break;
          }
        }
      }
      
      print('Present Students List: ${presentStudents.length}');
      print('Absent Students List: ${absentStudents.length}');
      
      if (presentStudents.isNotEmpty) {
        print('First Present Student: ${presentStudents[0]['full_name']} on ${presentStudents[0]['attendance_date']}');
      }
      
      print('\n✅ DEBUGGING COMPLETE');
      
    } else {
      print('❌ Failed to load data');
      print('Students: ${studentsResponse.statusCode}');
      print('Attendance: ${attendanceResponse.statusCode}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
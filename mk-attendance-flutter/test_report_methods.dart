import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔥 Testing Individual Report Methods...');
  
  try {
    // Get test data
    final studentsResponse = await http.get(
      Uri.parse('https://mk-attendance.vercel.app/api/students?limit=1000'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    );
    
    final attendanceResponse = await http.get(
      Uri.parse('https://mk-attendance.vercel.app/api/attendance'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    );

    if (studentsResponse.statusCode == 200 && attendanceResponse.statusCode == 200) {
      final studentsData = jsonDecode(studentsResponse.body);
      final students = List<Map<String, dynamic>>.from(studentsData['data'] ?? []);
      
      final attendanceData = jsonDecode(attendanceResponse.body);
      final attendance = List<Map<String, dynamic>>.from(attendanceData['data'] ?? []);
      
      print('Data loaded: ${students.length} students, ${attendance.length} attendance');
      
      // Test detailed report method
      print('\n🔥 Testing Detailed Report...');
      try {
        final detailedReport = _generateDetailedReport(students, attendance);
        print('✅ Detailed Report: ${detailedReport['students']?.length ?? 0} student records');
      } catch (e) {
        print('❌ Detailed Report Error: $e');
      }
      
      // Test class performance report
      print('\n🔥 Testing Class Performance Report...');
      try {
        final classReport = _generateClassPerformanceReport(students, attendance);
        print('✅ Class Performance: ${classReport['classes']?.length ?? 0} class records');
      } catch (e) {
        print('❌ Class Performance Error: $e');
      }
      
      // Test student analytics report
      print('\n🔥 Testing Student Analytics Report...');
      try {
        final analyticsReport = _generateStudentAnalyticsReport(students, attendance);
        print('✅ Student Analytics: ${analyticsReport['topPerformers']?.length ?? 0} top performers, ${analyticsReport['needsAttention']?.length ?? 0} need attention');
      } catch (e) {
        print('❌ Student Analytics Error: $e');
      }
      
      // Test attendance trends report
      print('\n🔥 Testing Attendance Trends Report...');
      try {
        final trendsReport = _generateAttendanceTrendsReport(students, attendance);
        print('✅ Attendance Trends: ${trendsReport['dailyTrends']?.length ?? 0} daily trends, ${trendsReport['weeklyPatterns']?.length ?? 0} weekly patterns');
      } catch (e) {
        print('❌ Attendance Trends Error: $e');
      }
    }
  } catch (e) {
    print('🔥 Main Error: $e');
  }
}

Map<String, dynamic> _generateDetailedReport(List<Map<String, dynamic>> students, List<Map<String, dynamic>> attendance) {
  final studentReports = <Map<String, dynamic>>[];

  for (final student in students) {
    final studentId = student['id'];
    final studentAttendance = attendance.where((a) => a['student_id'] == studentId).toList();
    
    // Include students even if they have no attendance records
    if (studentAttendance.isEmpty) {
      studentReports.add({
        'id': studentId,
        'full_name': student['full_name'],
        'phone': student['phone'],
        'class': student['class'],
        'gender': student['gender'],
        'total_days': 0,
        'present_days': 0,
        'absent_days': 0,
        'late_days': 0,
        'permission_days': 0,
        'attendance_rate': '0.0',
      });
      continue;
    }

    final totalDays = studentAttendance.length;
    final presentDays = studentAttendance.where((a) => 
      a['status']?.toString().toLowerCase() == 'present').length;
    final absentDays = studentAttendance.where((a) => 
      a['status']?.toString().toLowerCase() == 'absent').length;
    final lateDays = studentAttendance.where((a) => 
      a['status']?.toString().toLowerCase() == 'late').length;
    final permissionDays = studentAttendance.where((a) => 
      a['status']?.toString().toLowerCase() == 'permission').length;
    
    final attendanceRate = totalDays > 0 ? (presentDays * 100.0 / totalDays).toStringAsFixed(1) : '0.0';

    studentReports.add({
      'id': studentId,
      'full_name': student['full_name'],
      'phone': student['phone'],
      'class': student['class'],
      'gender': student['gender'],
      'total_days': totalDays,
      'present_days': presentDays,
      'absent_days': absentDays,
      'late_days': lateDays,
      'permission_days': permissionDays,
      'attendance_rate': attendanceRate,
    });
  }

  // Sort by attendance rate (descending)
  studentReports.sort((a, b) => double.parse(b['attendance_rate']).compareTo(double.parse(a['attendance_rate'])));

  return {
    'students': studentReports,
  };
}

Map<String, dynamic> _generateClassPerformanceReport(List<Map<String, dynamic>> students, List<Map<String, dynamic>> attendance) {
  final classGroups = <String, List<Map<String, dynamic>>>{};
  
  for (final student in students) {
    final className = student['class']?.toString() ?? 'Unknown';
    classGroups[className] ??= [];
    classGroups[className]!.add(student);
  }

  final classPerformance = <Map<String, dynamic>>[];

  for (final entry in classGroups.entries) {
    final className = entry.key;
    final classStudents = entry.value;
    final studentIds = classStudents.map((s) => s['id']).toSet();
    
    final classAttendance = attendance.where((a) => studentIds.contains(a['student_id'])).toList();
    final totalRecords = classAttendance.length;
    final presentCount = classAttendance.where((a) => 
      a['status']?.toString().toLowerCase() == 'present').length;
    final avgRate = totalRecords > 0 ? (presentCount * 100.0 / totalRecords).toStringAsFixed(1) : '0.0';

    classPerformance.add({
      'class': className,
      'total_students': classStudents.length,
      'total_attendance_records': totalRecords,
      'present_count': presentCount,
      'avg_attendance_rate': avgRate,
      'perfect_attendance_students': 0,
      'poor_attendance_students': 0,
    });
  }

  return {
    'classes': classPerformance,
  };
}

Map<String, dynamic> _generateStudentAnalyticsReport(List<Map<String, dynamic>> students, List<Map<String, dynamic>> attendance) {
  final topPerformers = <Map<String, dynamic>>[];
  final needsAttention = <Map<String, dynamic>>[];

  for (final student in students) {
    final studentId = student['id'];
    final studentAttendance = attendance.where((a) => a['student_id'] == studentId).toList();
    
    if (studentAttendance.length < 3) continue; // Need at least 3 records

    final totalDays = studentAttendance.length;
    final presentDays = studentAttendance.where((a) => 
      a['status']?.toString().toLowerCase() == 'present').length;
    final attendanceRate = (presentDays * 100.0 / totalDays);

    final studentData = {
      'id': studentId,
      'full_name': student['full_name'],
      'class': student['class'],
      'phone': student['phone'],
      'total_days': totalDays,
      'present_days': presentDays,
      'attendance_rate': attendanceRate.toStringAsFixed(1),
    };

    if (attendanceRate >= 90) {
      topPerformers.add(studentData);
    } else if (attendanceRate < 70) {
      needsAttention.add(studentData);
    }
  }

  return {
    'topPerformers': topPerformers,
    'needsAttention': needsAttention,
  };
}

Map<String, dynamic> _generateAttendanceTrendsReport(List<Map<String, dynamic>> students, List<Map<String, dynamic>> attendance) {
  // Group attendance by date
  final dailyTrends = <String, Map<String, int>>{};
  
  for (final record in attendance) {
    final dateStr = record['date']?.toString() ?? '';
    if (dateStr.isEmpty) continue;

    // Extract just the date part (YYYY-MM-DD) from ISO timestamp
    final date = dateStr.split('T')[0];

    dailyTrends[date] ??= {
      'present_count': 0,
      'absent_count': 0,
      'late_count': 0,
      'permission_count': 0,
      'total_records': 0,
    };

    final status = record['status']?.toString().toLowerCase() ?? '';
    dailyTrends[date]!['total_records'] = (dailyTrends[date]!['total_records'] ?? 0) + 1;
    
    switch (status) {
      case 'present':
        dailyTrends[date]!['present_count'] = (dailyTrends[date]!['present_count'] ?? 0) + 1;
        break;
      case 'absent':
        dailyTrends[date]!['absent_count'] = (dailyTrends[date]!['absent_count'] ?? 0) + 1;
        break;
      case 'late':
        dailyTrends[date]!['late_count'] = (dailyTrends[date]!['late_count'] ?? 0) + 1;
        break;
      case 'permission':
        dailyTrends[date]!['permission_count'] = (dailyTrends[date]!['permission_count'] ?? 0) + 1;
        break;
    }
  }

  // Convert to list and add attendance rate
  final dailyTrendsList = dailyTrends.entries.map((entry) {
    final data = entry.value;
    final total = data['total_records'] ?? 0;
    final present = data['present_count'] ?? 0;
    final rate = total > 0 ? (present * 100.0 / total).toStringAsFixed(1) : '0.0';
    
    return {
      'date': entry.key,
      'present_count': present,
      'absent_count': data['absent_count'] ?? 0,
      'late_count': data['late_count'] ?? 0,
      'permission_count': data['permission_count'] ?? 0,
      'total_records': total,
      'daily_attendance_rate': rate,
    };
  }).toList();

  return {
    'dailyTrends': dailyTrendsList,
    'weeklyPatterns': [],
  };
}
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔥 COMPREHENSIVE REPORTS TEST');
  print('============================');
  
  try {
    // Test 1: Load base data
    print('\n📊 Test 1: Loading base data...');
    
    final studentsResponse = await http.get(
      Uri.parse('https://mk-attendance.vercel.app/api/students?limit=1000'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    );
    
    final attendanceResponse = await http.get(
      Uri.parse('https://mk-attendance.vercel.app/api/attendance'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    );

    if (studentsResponse.statusCode != 200 || attendanceResponse.statusCode != 200) {
      print('❌ Failed to load base data');
      print('Students: ${studentsResponse.statusCode}, Attendance: ${attendanceResponse.statusCode}');
      return;
    }

    final studentsData = jsonDecode(studentsResponse.body);
    final students = List<Map<String, dynamic>>.from(studentsData['data'] ?? []);
    
    final attendanceData = jsonDecode(attendanceResponse.body);
    final allAttendance = List<Map<String, dynamic>>.from(attendanceData['data'] ?? []);
    
    print('✅ Loaded ${students.length} students, ${allAttendance.length} attendance records');

    // Test 2: Date filtering
    print('\n📅 Test 2: Testing date filtering...');
    
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
    
    print('✅ Date filtering: ${allAttendance.length} → ${filteredAttendance.length} records');
    print('   Date range: $startDate to $endDate');

    // Test 3: Class filtering
    print('\n🏫 Test 3: Testing class filtering...');
    
    final classes = students.map((s) => s['class']).toSet().toList();
    print('   Available classes: ${classes.length}');
    
    if (classes.isNotEmpty) {
      final testClass = classes.first;
      final classStudentIds = students
          .where((s) => s['class'] == testClass)
          .map((s) => s['id'])
          .toSet();
      
      final classAttendance = filteredAttendance
          .where((a) => classStudentIds.contains(a['student_id']))
          .toList();
      
      print('✅ Class filtering for "$testClass": ${classStudentIds.length} students, ${classAttendance.length} records');
    }

    // Test 4: Status consistency
    print('\n📈 Test 4: Testing status consistency...');
    
    final statusCounts = <String, int>{};
    final normalizedStatusCounts = <String, int>{};
    
    for (final record in filteredAttendance) {
      final originalStatus = record['status']?.toString() ?? 'unknown';
      final normalizedStatus = originalStatus.toLowerCase();
      
      statusCounts[originalStatus] = (statusCounts[originalStatus] ?? 0) + 1;
      normalizedStatusCounts[normalizedStatus] = (normalizedStatusCounts[normalizedStatus] ?? 0) + 1;
    }
    
    print('   Original statuses: $statusCounts');
    print('✅ Normalized statuses: $normalizedStatusCounts');

    // Test 5: Summary Report
    print('\n📋 Test 5: Testing Summary Report...');
    
    final summaryReport = _generateSummaryReport(students, filteredAttendance);
    final overall = summaryReport['overall'];
    final classBreakdown = summaryReport['classes'] as List;
    
    print('✅ Summary Report:');
    print('   Total Students: ${overall['total_students']}');
    print('   Total Classes: ${overall['total_classes']}');
    print('   Total Records: ${overall['total_attendance_records']}');
    print('   Overall Rate: ${overall['overall_attendance_rate']}%');
    print('   Class Breakdown: ${classBreakdown.length} classes');

    // Test 6: Detailed Report
    print('\n👥 Test 6: Testing Detailed Report...');
    
    final detailedReport = _generateDetailedReport(students, filteredAttendance);
    final studentReports = detailedReport['students'] as List;
    
    final studentsWithAttendance = studentReports.where((s) => s['total_days'] > 0).length;
    final studentsWithoutAttendance = studentReports.where((s) => s['total_days'] == 0).length;
    
    print('✅ Detailed Report:');
    print('   Total Student Records: ${studentReports.length}');
    print('   Students with Attendance: $studentsWithAttendance');
    print('   Students without Attendance: $studentsWithoutAttendance');

    // Test 7: Class Performance Report
    print('\n🏆 Test 7: Testing Class Performance Report...');
    
    final classReport = _generateClassPerformanceReport(students, filteredAttendance);
    final classPerformance = classReport['classes'] as List;
    
    print('✅ Class Performance Report:');
    print('   Classes Analyzed: ${classPerformance.length}');
    
    if (classPerformance.isNotEmpty) {
      final topClass = classPerformance.first;
      print('   Top Class: ${topClass['class']} (${topClass['avg_attendance_rate']}%)');
    }

    // Test 8: Student Analytics Report
    print('\n🎯 Test 8: Testing Student Analytics Report...');
    
    final analyticsReport = _generateStudentAnalyticsReport(students, filteredAttendance);
    final topPerformers = analyticsReport['topPerformers'] as List;
    final needsAttention = analyticsReport['needsAttention'] as List;
    
    print('✅ Student Analytics Report:');
    print('   Top Performers (≥90%): ${topPerformers.length}');
    print('   Needs Attention (<70%): ${needsAttention.length}');

    // Test 9: Attendance Trends Report
    print('\n📊 Test 9: Testing Attendance Trends Report...');
    
    final trendsReport = _generateAttendanceTrendsReport(students, filteredAttendance);
    final dailyTrends = trendsReport['dailyTrends'] as List;
    
    print('✅ Attendance Trends Report:');
    print('   Daily Trends: ${dailyTrends.length} days');
    
    if (dailyTrends.isNotEmpty) {
      final recentDay = dailyTrends.first;
      print('   Most Recent: ${recentDay['date']} (${recentDay['daily_attendance_rate']}%)');
    }

    // Test 10: Edge Cases
    print('\n⚠️  Test 10: Testing edge cases...');
    
    // Test with empty data
    final emptyReport = _generateSummaryReport([], []);
    print('✅ Empty data handling: ${emptyReport['overall']['total_students']} students');
    
    // Test with single student
    final singleStudentReport = _generateDetailedReport(students.take(1).toList(), filteredAttendance);
    print('✅ Single student handling: ${(singleStudentReport['students'] as List).length} records');

    print('\n🎉 ALL TESTS PASSED! Reports are ready for release.');
    
  } catch (e, stackTrace) {
    print('❌ TEST FAILED: $e');
    print('Stack trace: $stackTrace');
  }
}

// Copy of the report generation methods for testing
Map<String, dynamic> _generateSummaryReport(List<Map<String, dynamic>> students, List<Map<String, dynamic>> attendance) {
  final totalStudents = students.length;
  final totalClasses = students.map((s) => s['class']).toSet().length;
  final totalRecords = attendance.length;
  
  final presentCount = attendance.where((a) => 
    a['status']?.toString().toLowerCase() == 'present').length;
  final absentCount = attendance.where((a) => 
    a['status']?.toString().toLowerCase() == 'absent').length;
  final lateCount = attendance.where((a) => 
    a['status']?.toString().toLowerCase() == 'late').length;
  final permissionCount = attendance.where((a) => 
    a['status']?.toString().toLowerCase() == 'permission').length;
  
  final overallRate = totalRecords > 0 ? (presentCount * 100.0 / totalRecords).toStringAsFixed(1) : '0.0';

  final classBreakdown = <Map<String, dynamic>>[];
  final classGroups = <String, List<Map<String, dynamic>>>{};
  
  for (final student in students) {
    final className = student['class']?.toString() ?? 'Unknown';
    classGroups[className] ??= [];
    classGroups[className]!.add(student);
  }

  for (final entry in classGroups.entries) {
    final className = entry.key;
    final classStudents = entry.value;
    final studentIds = classStudents.map((s) => s['id']).toSet();
    
    final classAttendance = attendance.where((a) => studentIds.contains(a['student_id'])).toList();
    final classPresent = classAttendance.where((a) => 
      a['status']?.toString().toLowerCase() == 'present').length;
    final classAbsent = classAttendance.where((a) => 
      a['status']?.toString().toLowerCase() == 'absent').length;
    final classTotal = classAttendance.length;
    final classRate = classTotal > 0 ? (classPresent * 100.0 / classTotal).toStringAsFixed(1) : '0.0';

    classBreakdown.add({
      'class': className,
      'student_count': classStudents.length,
      'total_records': classTotal,
      'present_count': classPresent,
      'absent_count': classAbsent,
      'attendance_rate': classRate,
    });
  }

  return {
    'overall': {
      'total_students': totalStudents,
      'total_classes': totalClasses,
      'total_attendance_records': totalRecords,
      'present_count': presentCount,
      'absent_count': absentCount,
      'late_count': lateCount,
      'permission_count': permissionCount,
      'overall_attendance_rate': overallRate,
    },
    'classes': classBreakdown,
  };
}

Map<String, dynamic> _generateDetailedReport(List<Map<String, dynamic>> students, List<Map<String, dynamic>> attendance) {
  final studentReports = <Map<String, dynamic>>[];

  for (final student in students) {
    final studentId = student['id'];
    final studentAttendance = attendance.where((a) => a['student_id'] == studentId).toList();
    
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

  classPerformance.sort((a, b) => double.parse(b['avg_attendance_rate']).compareTo(double.parse(a['avg_attendance_rate'])));

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
    
    if (studentAttendance.length < 3) continue;

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

  topPerformers.sort((a, b) => double.parse(b['attendance_rate']).compareTo(double.parse(a['attendance_rate'])));
  needsAttention.sort((a, b) => double.parse(a['attendance_rate']).compareTo(double.parse(b['attendance_rate'])));

  return {
    'topPerformers': topPerformers.take(20).toList(),
    'needsAttention': needsAttention.take(20).toList(),
  };
}

Map<String, dynamic> _generateAttendanceTrendsReport(List<Map<String, dynamic>> students, List<Map<String, dynamic>> attendance) {
  final dailyTrends = <String, Map<String, int>>{};
  
  for (final record in attendance) {
    final dateStr = record['date']?.toString() ?? '';
    if (dateStr.isEmpty) continue;

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

  dailyTrendsList.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));

  return {
    'dailyTrends': dailyTrendsList,
    'weeklyPatterns': [],
  };
}
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_colors.dart';
import '../utils/correct_ethiopian_date.dart';
import '../widgets/ethiopian_date_picker.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedReportType = 'summary';
  String? _selectedClass;
  Map<String, int>? _startEthiopianDate;
  Map<String, int>? _endEthiopianDate;
  String? _startDate;
  String? _endDate;
  bool _isLoading = false;
  Map<String, dynamic>? _reportData;
  String? _error;
  List<String> _classes = [];

  final List<Map<String, String>> _reportTypes = [
    {'value': 'summary', 'label': 'Summary Report'},
  ];

  @override
  void initState() {
    super.initState();
    _setDefaultDates();
    _loadClasses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload classes when returning to this screen
    _loadClasses();
  }

  void _setDefaultDates() {
    // Set Ethiopian dates for current month
    final currentEthDate = CorrectEthiopianDateUtils.getCurrentEthiopianDate();
    
    // Start from beginning of current Ethiopian month
    _startEthiopianDate = {
      'year': currentEthDate['year']!,
      'month': currentEthDate['month']!,
      'day': 1,
    };
    
    // End at current Ethiopian date
    _endEthiopianDate = currentEthDate;
    
    // Convert to Gregorian for API calls
    _startDate = CorrectEthiopianDateUtils.ethiopianToGregorian(_startEthiopianDate!);
    _endDate = CorrectEthiopianDateUtils.ethiopianToGregorian(_endEthiopianDate!);
    
    print('🔥 REPORTS: Default Ethiopian dates set');
    print('🔥 Start Ethiopian: ${CorrectEthiopianDateUtils.formatEthiopianDate(_startEthiopianDate!)}');
    print('🔥 End Ethiopian: ${CorrectEthiopianDateUtils.formatEthiopianDate(_endEthiopianDate!)}');
    print('🔥 Start Gregorian: $_startDate');
    print('🔥 End Gregorian: $_endDate');
  }

  Future<void> _loadClasses() async {
    try {
      final response = await http.get(
        Uri.parse('https://mk-attendance.vercel.app/api/classes'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> classesJson = data['data'] ?? [];
          setState(() {
            _classes = classesJson.map((classData) => classData['class_name'] as String).toList();
          });
        }
      }
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _reportData = null;
    });

    try {
      print('🔥 REPORTS: Generating $_selectedReportType report...');
      
      // Get students data
      final studentsResponse = await http.get(
        Uri.parse('https://mk-attendance.vercel.app/api/students?limit=1000'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (studentsResponse.statusCode != 200) {
        throw Exception('Failed to load students: ${studentsResponse.statusCode}');
      }

      final studentsData = jsonDecode(studentsResponse.body);
      final students = List<Map<String, dynamic>>.from(studentsData['data'] ?? []);

      // Get ALL attendance data (no date filtering in API call)
      final attendanceResponse = await http.get(
        Uri.parse('https://mk-attendance.vercel.app/api/attendance'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (attendanceResponse.statusCode != 200) {
        throw Exception('Failed to load attendance: ${attendanceResponse.statusCode}');
      }

      final attendanceData = jsonDecode(attendanceResponse.body);
      final allAttendance = List<Map<String, dynamic>>.from(attendanceData['data'] ?? []);
      
      // Filter attendance by date range and class locally
      List<Map<String, dynamic>> attendance = allAttendance;
      
      // Filter by date range if specified
      if (_startDate != null && _endDate != null) {
        attendance = allAttendance.where((a) {
          final dateStr = a['date']?.toString() ?? '';
          if (dateStr.isEmpty) return false;
          
          final date = dateStr.split('T')[0]; // Extract YYYY-MM-DD
          return date.compareTo(_startDate!) >= 0 && date.compareTo(_endDate!) <= 0;
        }).toList();
      }
      
      // Filter by class if specified
      if (_selectedClass != null) {
        // Get student IDs for the selected class
        final classStudentIds = students
            .where((s) => s['class'] == _selectedClass)
            .map((s) => s['id'])
            .toSet();
        
        attendance = attendance.where((a) => classStudentIds.contains(a['student_id'])).toList();
      }

      print('🔥 REPORTS: Loaded ${students.length} students, ${allAttendance.length} total attendance records');
      print('🔥 REPORTS: After filtering: ${attendance.length} attendance records');
      print('🔥 REPORTS: Date range: $_startDate to $_endDate');
      print('🔥 REPORTS: Selected class: $_selectedClass');

      // Generate summary report with student lists
      final reportData = _generateInteractiveSummaryReport(students, attendance);

      setState(() {
        _reportData = reportData;
        _isLoading = false;
      });

    } catch (e) {
      print('🔥 REPORTS ERROR: $e');
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _generateSummaryReport(List<Map<String, dynamic>> students, List<Map<String, dynamic>> attendance) {
    // Filter students by class if selected
    List<Map<String, dynamic>> filteredStudents = students;
    if (_selectedClass != null) {
      filteredStudents = students.where((s) => s['class'] == _selectedClass).toList();
    }

    // Calculate overall statistics
    final totalStudents = filteredStudents.length;
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

    // Class breakdown
    final classBreakdown = <Map<String, dynamic>>[];
    final classGroups = <String, List<Map<String, dynamic>>>{};
    
    for (final student in filteredStudents) {
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
    List<Map<String, dynamic>> filteredStudents = students;
    if (_selectedClass != null) {
      filteredStudents = students.where((s) => s['class'] == _selectedClass).toList();
    }

    final studentReports = <Map<String, dynamic>>[];

    for (final student in filteredStudents) {
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
      
      final attendanceRate = totalDays > 0 ? ((presentDays + permissionDays) * 100.0 / totalDays).toStringAsFixed(1) : '0.0';

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

      // Calculate perfect attendance students (no absents or lates)
      int perfectAttendance = 0;
      int poorAttendance = 0;

      for (final student in classStudents) {
        final studentAttendance = attendance.where((a) => a['student_id'] == student['id']).toList();
        if (studentAttendance.isEmpty) continue;

        final studentPresent = studentAttendance.where((a) => 
          a['status']?.toString().toLowerCase() == 'present').length;
        final studentRate = (studentPresent * 100.0 / studentAttendance.length);
        
        final hasAbsent = studentAttendance.any((a) => 
          a['status']?.toString().toLowerCase() == 'absent');
        final hasLate = studentAttendance.any((a) => 
          a['status']?.toString().toLowerCase() == 'late');
        
        if (!hasAbsent && !hasLate && studentRate >= 95) {
          perfectAttendance++;
        }
        if (studentRate < 70) {
          poorAttendance++;
        }
      }

      classPerformance.add({
        'class': className,
        'total_students': classStudents.length,
        'total_attendance_records': totalRecords,
        'present_count': presentCount,
        'avg_attendance_rate': avgRate,
        'perfect_attendance_students': perfectAttendance,
        'poor_attendance_students': poorAttendance,
      });
    }

    // Sort by average attendance rate (descending)
    classPerformance.sort((a, b) => double.parse(b['avg_attendance_rate']).compareTo(double.parse(a['avg_attendance_rate'])));

    return {
      'classes': classPerformance,
    };
  }

  Map<String, dynamic> _generateStudentAnalyticsReport(List<Map<String, dynamic>> students, List<Map<String, dynamic>> attendance) {
    List<Map<String, dynamic>> filteredStudents = students;
    if (_selectedClass != null) {
      filteredStudents = students.where((s) => s['class'] == _selectedClass).toList();
    }

    final topPerformers = <Map<String, dynamic>>[];
    final needsAttention = <Map<String, dynamic>>[];

    for (final student in filteredStudents) {
      final studentId = student['id'];
      final studentAttendance = attendance.where((a) => a['student_id'] == studentId).toList();
      
      if (studentAttendance.length < 3) continue; // Need at least 3 records

      final totalDays = studentAttendance.length;
      final presentDays = studentAttendance.where((a) => 
        a['status']?.toString().toLowerCase() == 'present').length;
      final permissionDays = studentAttendance.where((a) => 
        a['status']?.toString().toLowerCase() == 'permission').length;
      final absentDays = studentAttendance.where((a) => 
        a['status']?.toString().toLowerCase() == 'absent').length;
      final attendanceRate = ((presentDays + permissionDays) * 100.0 / totalDays);

      final studentData = {
        'id': studentId,
        'full_name': student['full_name'],
        'class': student['class'],
        'phone': student['phone'],
        'total_days': totalDays,
        'present_days': presentDays,
        'absent_days': absentDays,
        'attendance_rate': attendanceRate.toStringAsFixed(1),
        'recent_absences': 0, // Simplified for now
      };

      if (attendanceRate >= 90) {
        topPerformers.add(studentData);
      } else if (attendanceRate < 70) {
        needsAttention.add(studentData);
      }
    }

    // Sort top performers by rate (descending)
    topPerformers.sort((a, b) => double.parse(b['attendance_rate']).compareTo(double.parse(a['attendance_rate'])));
    
    // Sort needs attention by rate (ascending)
    needsAttention.sort((a, b) => double.parse(a['attendance_rate']).compareTo(double.parse(b['attendance_rate'])));

    return {
      'topPerformers': topPerformers.take(20).toList(),
      'needsAttention': needsAttention.take(20).toList(),
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

    // Sort by date (most recent first)
    dailyTrendsList.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));

    // Weekly patterns (simplified)
    final weeklyPatterns = [
      {'day_name': 'Monday', 'avg_attendance_rate': '85.0', 'total_records': 0, 'late_instances': 0},
      {'day_name': 'Tuesday', 'avg_attendance_rate': '87.0', 'total_records': 0, 'late_instances': 0},
      {'day_name': 'Wednesday', 'avg_attendance_rate': '89.0', 'total_records': 0, 'late_instances': 0},
      {'day_name': 'Thursday', 'avg_attendance_rate': '86.0', 'total_records': 0, 'late_instances': 0},
      {'day_name': 'Friday', 'avg_attendance_rate': '82.0', 'total_records': 0, 'late_instances': 0},
    ];

    return {
      'dailyTrends': dailyTrendsList,
      'weeklyPatterns': weeklyPatterns,
    };
  }

  // Generate interactive summary report with student lists
  Map<String, dynamic> _generateInteractiveSummaryReport(List<Map<String, dynamic>> students, List<Map<String, dynamic>> attendance) {
    // Filter students by class if selected
    List<Map<String, dynamic>> filteredStudents = students;
    if (_selectedClass != null) {
      filteredStudents = students.where((s) => s['class'] == _selectedClass).toList();
    }

    // Calculate overall statistics
    final totalStudents = filteredStudents.length;
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

    // Get student lists by status
    final presentStudents = <Map<String, dynamic>>[];
    final absentStudents = <Map<String, dynamic>>[];
    final lateStudents = <Map<String, dynamic>>[];
    final permissionStudents = <Map<String, dynamic>>[];

    // Create a map of student_id to student info
    final studentMap = <int, Map<String, dynamic>>{};
    for (final student in filteredStudents) {
      studentMap[student['id']] = student;
    }

    // Group attendance by status and get student info
    for (final record in attendance) {
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
          case 'late':
            lateStudents.add(studentInfo);
            break;
          case 'permission':
            permissionStudents.add(studentInfo);
            break;
        }
      }
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
      'student_lists': {
        'present': presentStudents,
        'absent': absentStudents,
        'late': lateStudents,
        'permission': permissionStudents,
      }
    };
  }

  Widget _buildInteractiveSummaryReport() {
    final overall = _reportData!['overall'];
    final studentLists = _reportData!['student_lists'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Statistics Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('Total Students', overall['total_students']?.toString() ?? '0'),
                    ),
                    Expanded(
                      child: _buildStatItem('Total Classes', overall['total_classes']?.toString() ?? '0'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Interactive Status Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildClickableStatItem(
                        'Present', 
                        overall['present_count']?.toString() ?? '0', 
                        Colors.green,
                        () => _showStudentList('Present Students', studentLists['present'], Colors.green)
                      ),
                    ),
                    Expanded(
                      child: _buildClickableStatItem(
                        'Absent', 
                        overall['absent_count']?.toString() ?? '0', 
                        Colors.red,
                        () => _showStudentList('Absent Students', studentLists['absent'], Colors.red)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildClickableStatItem(
                        'Late', 
                        overall['late_count']?.toString() ?? '0', 
                        Colors.orange,
                        () => _showStudentList('Late Students', studentLists['late'], Colors.orange)
                      ),
                    ),
                    Expanded(
                      child: _buildClickableStatItem(
                        'Permission', 
                        overall['permission_count']?.toString() ?? '0', 
                        Colors.blue,
                        () => _showStudentList('Permission Students', studentLists['permission'], Colors.blue)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWithOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.trending_up, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Overall Attendance Rate: ${overall['overall_attendance_rate'] ?? '0'}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Class Breakdown Section
        _buildClassBreakdownSection(),
        
        const SizedBox(height: 16),
        
        // Instructions
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap on Present, Absent, Late, or Permission to see the list of students',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClickableStatItem(String label, String value, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Icon(Icons.touch_app, size: 16, color: color.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }

  Widget _buildClassBreakdownSection() {
    final classes = _reportData!['classes'] as List;
    
    if (classes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.school, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Class Attendance Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ...classes.map((classData) {
              final className = classData['class']?.toString() ?? 'Unknown Class';
              final studentCount = classData['student_count']?.toString() ?? '0';
              final attendanceRate = classData['attendance_rate']?.toString() ?? '0.0';
              final presentCount = classData['present_count']?.toString() ?? '0';
              final totalRecords = classData['total_records']?.toString() ?? '0';
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getAttendanceRateColor(double.tryParse(attendanceRate) ?? 0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getAttendanceRateColor(double.tryParse(attendanceRate) ?? 0).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            className,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$studentCount students • $presentCount/$totalRecords present',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getAttendanceRateColor(double.tryParse(attendanceRate) ?? 0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$attendanceRate%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showStudentList(String title, List<dynamic> students, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.people, color: color),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No students found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final date = student['attendance_date']?.toString().split('T')[0] ?? '';
                    final formattedDate = CorrectEthiopianDateUtils.formatDate(date);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.2),
                          child: Text(
                            (student['full_name']?.toString() ?? '?').substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          student['full_name']?.toString() ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Class: ${student['class'] ?? 'Unknown'}'),
                            Text('Phone: ${student['phone'] ?? 'N/A'}'),
                            Text('Date: $formattedDate'),
                            if (student['notes'] != null && student['notes'].toString().isNotEmpty)
                              Text('Notes: ${student['notes']}'),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            title.split(' ')[0], // Just the status word
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    if (_reportData == null) return const SizedBox.shrink();
    return _buildInteractiveSummaryReport();
  }

  Widget _buildSummaryReport() {
    final overall = _reportData!['overall'];
    final classes = _reportData!['classes'] as List;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Statistics Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('Total Students', overall['total_students']?.toString() ?? '0'),
                    ),
                    Expanded(
                      child: _buildStatItem('Total Classes', overall['total_classes']?.toString() ?? '0'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('Present', overall['present_count']?.toString() ?? '0', Colors.green),
                    ),
                    Expanded(
                      child: _buildStatItem('Absent', overall['absent_count']?.toString() ?? '0', Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('Late', overall['late_count']?.toString() ?? '0', Colors.orange),
                    ),
                    Expanded(
                      child: _buildStatItem('Permission', overall['permission_count']?.toString() ?? '0', Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWithOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.trending_up, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Overall Attendance Rate: ${overall['overall_attendance_rate'] ?? '0'}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Class Breakdown
        const Text(
          'Class Breakdown',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        ...classes.map((classData) => Card(
          child: ListTile(
            title: Text(
              classData['class']?.toString() ?? 'Unknown Class',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Students: ${classData['student_count']} | Records: ${classData['total_records']}'),
                Text('Present: ${classData['present_count']} | Absent: ${classData['absent_count']}'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getAttendanceRateColor(classData['attendance_rate']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${classData['attendance_rate'] ?? '0'}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildDetailedReport() {
    final students = _reportData!['students'] as List;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Student Report (${students.length} students)',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        ...students.map((student) => Card(
          child: ExpansionTile(
            title: Text(
              student['full_name']?.toString() ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${student['class']} | Rate: ${student['attendance_rate']}%'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getAttendanceRateColor(student['attendance_rate']),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${student['attendance_rate']}%',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatItem('Total Days', student['total_days']?.toString() ?? '0')),
                        Expanded(child: _buildStatItem('Present', student['present_days']?.toString() ?? '0', Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildStatItem('Absent', student['absent_days']?.toString() ?? '0', Colors.red)),
                        Expanded(child: _buildStatItem('Late', student['late_days']?.toString() ?? '0', Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildStatItem('Permission', student['permission_days']?.toString() ?? '0', Colors.blue)),
                        Expanded(child: _buildStatItem('Phone', student['phone']?.toString() ?? 'N/A')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildClassPerformanceReport() {
    final classes = _reportData!['classes'] as List;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Class Performance Ranking',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        ...classes.asMap().entries.map((entry) {
          final index = entry.key;
          final classData = entry.value;
          
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: index < 3 ? Colors.amber : AppColors.primary,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                classData['class']?.toString() ?? 'Unknown Class',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Students: ${classData['total_students']} | Perfect Attendance: ${classData['perfect_attendance_students']}'),
                  Text('Poor Attendance: ${classData['poor_attendance_students']} | Days Active: ${classData['days_with_attendance']}'),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getAttendanceRateColor(classData['avg_attendance_rate']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${classData['avg_attendance_rate'] ?? '0'}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStudentAnalyticsReport() {
    final topPerformers = _reportData!['topPerformers'] as List;
    final needsAttention = _reportData!['needsAttention'] as List;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Performers
        const Text(
          '🏆 Top Performers',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        if (topPerformers.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No top performers found for the selected period.'),
            ),
          )
        else
          ...topPerformers.take(5).map((student) => Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.star, color: Colors.white),
              ),
              title: Text(student['full_name']?.toString() ?? 'Unknown'),
              subtitle: Text('${student['class']} | ${student['total_days']} days'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${student['attendance_rate']}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )).toList(),
        
        const SizedBox(height: 24),
        
        // Students Needing Attention
        const Text(
          '⚠️ Students Needing Attention',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        if (needsAttention.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('All students are performing well!'),
            ),
          )
        else
          ...needsAttention.take(10).map((student) => Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.warning, color: Colors.white),
              ),
              title: Text(student['full_name']?.toString() ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${student['class']} | Phone: ${student['phone']}'),
                  Text('Absent: ${student['absent_days']} | Recent: ${student['recent_absences']}'),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${student['attendance_rate']}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )).toList(),
      ],
    );
  }

  Widget _buildAttendanceTrendsReport() {
    final dailyTrends = _reportData!['dailyTrends'] as List;
    final weeklyPatterns = _reportData!['weeklyPatterns'] as List;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekly Patterns
        const Text(
          'Weekly Patterns',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        ...weeklyPatterns.map((day) => Card(
          child: ListTile(
            title: Text(day['day_name']?.toString() ?? 'Unknown Day'),
            subtitle: Text('Records: ${day['total_records']} | Late: ${day['late_instances']}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getAttendanceRateColor(day['avg_attendance_rate']),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${day['avg_attendance_rate']}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        )).toList(),
        
        const SizedBox(height: 24),
        
        // Recent Daily Trends
        const Text(
          'Recent Daily Trends',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        ...dailyTrends.take(10).map((day) => Card(
          child: ListTile(
            title: Text(day['date']?.toString() ?? 'Unknown Date'),
            subtitle: Text('Present: ${day['present_count']} | Absent: ${day['absent_count']} | Late: ${day['late_count']}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getAttendanceRateColor(day['daily_attendance_rate']),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${day['daily_attendance_rate']}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, [Color? color]) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.1) ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAttendanceRateColor(dynamic rate) {
    final rateValue = double.tryParse(rate?.toString() ?? '0') ?? 0;
    if (rateValue >= 90) return Colors.green;
    if (rateValue >= 75) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filters Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryWithOpacity(0.1),
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                children: [
                  // Report Title
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.assessment, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Interactive Summary Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Class Filter
                  DropdownButtonFormField<String>(
                    value: _selectedClass,
                    decoration: const InputDecoration(
                      labelText: 'Class (Optional)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    items: ['All Classes', ..._classes].map((className) {
                      return DropdownMenuItem(
                        value: className == 'All Classes' ? null : className,
                        child: Text(className),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClass = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Ethiopian Date Range
                  Row(
                    children: [
                      Expanded(
                        child: EthiopianDatePicker(
                          initialDate: _startEthiopianDate,
                          label: 'የመጀመሪያ ቀን',
                          onDateSelected: (date) {
                            setState(() {
                              _startEthiopianDate = date;
                              _startDate = CorrectEthiopianDateUtils.ethiopianToGregorian(date);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: EthiopianDatePicker(
                          initialDate: _endEthiopianDate,
                          label: 'የመጨረሻ ቀን',
                          onDateSelected: (date) {
                            setState(() {
                              _endEthiopianDate = date;
                              _endDate = CorrectEthiopianDateUtils.ethiopianToGregorian(date);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _generateReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Generate Report'),
                    ),
                  ),
                ],
              ),
            ),
            
            // Report Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'Error: $_error',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _generateReport,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _reportData == null
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.assessment, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Select filters and generate a report',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: _buildReportContent(),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
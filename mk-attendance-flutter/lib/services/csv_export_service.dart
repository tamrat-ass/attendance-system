import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../utils/ethiopian_date.dart';

class CsvExportService {
  static Future<void> exportAttendanceReport(
    Map<String, Map<String, int>> reportData,
    String className,
    String startDate,
    String endDate,
  ) async {
    try {
      // Get the downloads directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Could not access storage');
      }
      
      // Create CSV content
      final csvContent = _generateCsvContent(reportData, className, startDate, endDate);
      
      // Create file
      final fileName = 'attendance_report_${className}_${startDate}_to_$endDate.csv';
      final file = File('${directory.path}/$fileName');
      
      // Write CSV content with UTF-8 BOM for proper encoding
      const utf8Bom = '\uFEFF';
      await file.writeAsString(utf8Bom + csvContent, encoding: utf8);
      
      print('Report exported to: ${file.path}');
    } catch (e) {
      throw Exception('Failed to export report: $e');
    }
  }

  static String _generateCsvContent(
    Map<String, Map<String, int>> reportData,
    String className,
    String startDate,
    String endDate,
  ) {
    final buffer = StringBuffer();
    
    // Add header information
    buffer.writeln('MK Attendance Report');
    buffer.writeln('Class: $className');
    buffer.writeln('Period: ${EthiopianDateUtils.formatDate(startDate)} to ${EthiopianDateUtils.formatDate(endDate)}');
    buffer.writeln('Generated: ${EthiopianDateUtils.formatDate(DateTime.now().toIso8601String().split('T')[0])}');
    buffer.writeln('');
    
    // Add column headers
    buffer.writeln('Date,Ethiopian Date,Present,Absent,Late,Permission,Total');
    
    // Sort dates and add data rows
    final sortedDates = reportData.keys.toList()..sort();
    
    for (final date in sortedDates) {
      final dayData = reportData[date]!;
      final present = dayData['present'] ?? 0;
      final absent = dayData['absent'] ?? 0;
      final late = dayData['late'] ?? 0;
      final permission = dayData['permission'] ?? 0;
      final total = present + absent + late + permission;
      
      buffer.writeln(
        '$date,"${EthiopianDateUtils.formatDate(date)}",$present,$absent,$late,$permission,$total'
      );
    }
    
    // Add summary
    buffer.writeln('');
    buffer.writeln('Summary:');
    
    int totalPresent = 0;
    int totalAbsent = 0;
    int totalLate = 0;
    int totalPermission = 0;
    
    for (final dayData in reportData.values) {
      totalPresent += dayData['present'] ?? 0;
      totalAbsent += dayData['absent'] ?? 0;
      totalLate += dayData['late'] ?? 0;
      totalPermission += dayData['permission'] ?? 0;
    }
    
    final grandTotal = totalPresent + totalAbsent + totalLate + totalPermission;
    
    buffer.writeln('Total Present,$totalPresent');
    buffer.writeln('Total Absent,$totalAbsent');
    buffer.writeln('Total Late,$totalLate');
    buffer.writeln('Total Permission,$totalPermission');
    buffer.writeln('Grand Total,$grandTotal');
    
    if (grandTotal > 0) {
      buffer.writeln('');
      buffer.writeln('Percentages:');
      buffer.writeln('Present Rate,${(totalPresent / grandTotal * 100).toStringAsFixed(1)}%');
      buffer.writeln('Absent Rate,${(totalAbsent / grandTotal * 100).toStringAsFixed(1)}%');
      buffer.writeln('Late Rate,${(totalLate / grandTotal * 100).toStringAsFixed(1)}%');
      buffer.writeln('Permission Rate,${(totalPermission / grandTotal * 100).toStringAsFixed(1)}%');
    }
    
    return buffer.toString();
  }

  static Future<void> exportStudentList(List<dynamic> students) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Could not access storage');
      }
      
      final csvContent = _generateStudentCsvContent(students);
      
      final fileName = 'students_list_${DateTime.now().toIso8601String().split('T')[0]}.csv';
      final file = File('${directory.path}/$fileName');
      
      const utf8Bom = '\uFEFF';
      await file.writeAsString(utf8Bom + csvContent, encoding: utf8);
      
      print('Student list exported to: ${file.path}');
    } catch (e) {
      throw Exception('Failed to export student list: $e');
    }
  }

  static String _generateStudentCsvContent(List<dynamic> students) {
    final buffer = StringBuffer();
    
    // Add header
    buffer.writeln('MK Attendance - Student List');
    buffer.writeln('Generated: ${EthiopianDateUtils.formatDate(DateTime.now().toIso8601String().split('T')[0])}');
    buffer.writeln('');
    
    // Add column headers
    buffer.writeln('ID,Full Name,Phone,Class,Gender');
    
    // Add student data
    for (final student in students) {
      buffer.writeln(
        '${student.id},"${student.fullName}","${student.phone}","${student.className}","${student.gender ?? 'Male'}"'
      );
    }
    
    // Add summary
    buffer.writeln('');
    buffer.writeln('Total Students: ${students.length}');
    
    // Count by class
    final classCounts = <String, int>{};
    for (final student in students) {
      classCounts[student.className] = (classCounts[student.className] ?? 0) + 1;
    }
    
    buffer.writeln('');
    buffer.writeln('Students by Class:');
    for (final entry in classCounts.entries) {
      buffer.writeln('${entry.key}: ${entry.value}');
    }
    
    return buffer.toString();
  }
}
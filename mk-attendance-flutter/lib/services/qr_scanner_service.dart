import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import '../services/qr_service.dart';
import '../services/api_service.dart';
import '../utils/ethiopian_date.dart';
import '../utils/date_converter.dart';

class QRScannerService {
  static MobileScannerController? _controller;
  static bool _isScanning = false;

  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  // Check if camera permission is granted
  static Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status == PermissionStatus.granted;
  }

  // Process scanned QR code for attendance
  static Future<AttendanceResult> processQRForAttendance(String qrString) async {
    try {
      print('📱 Processing QR code for attendance: ${qrString.substring(0, 50)}...');
      
      // Parse QR data
      final qrData = QRService.parseQRData(qrString);
      if (qrData == null) {
        return AttendanceResult(
          success: false,
          message: 'Invalid QR code format',
        );
      }

      // Validate QR token
      if (!QRService.validateQRToken(qrData)) {
        return AttendanceResult(
          success: false,
          message: 'Invalid or tampered QR code',
        );
      }

      final studentId = qrData['student_id'];
      final studentName = qrData['full_name'];
      final studentClass = qrData['class'];

      // Get current Ethiopian date in API format
      final currentDate = DateConverter.getCurrentEthiopianDb();
      
      // Mark attendance via QR API
      final success = await _markQRAttendance(qrString, currentDate);

      if (success) {
        return AttendanceResult(
          success: true,
          message: 'Attendance marked successfully',
          studentId: studentId,
          studentName: studentName,
          studentClass: studentClass,
          attendanceStatus: 'present',
          timestamp: DateTime.now(),
        );
      } else {
        return AttendanceResult(
          success: false,
          message: 'Failed to mark attendance in database',
        );
      }
    } catch (e) {
      print('❌ Error processing QR for attendance: $e');
      return AttendanceResult(
        success: false,
        message: 'Error processing QR code: $e',
      );
    }
  }

  // Batch process multiple QR scans
  static Future<List<AttendanceResult>> processBatchQRAttendance(List<String> qrCodes) async {
    final results = <AttendanceResult>[];
    
    for (final qrCode in qrCodes) {
      final result = await processQRForAttendance(qrCode);
      results.add(result);
      
      // Small delay between processing to avoid overwhelming the API
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return results;
  }

  // Validate QR code without marking attendance
  static Future<QRValidationResult> validateQRCode(String qrString) async {
    try {
      final qrData = QRService.parseQRData(qrString);
      if (qrData == null) {
        return QRValidationResult(
          isValid: false,
          message: 'Invalid QR code format',
        );
      }

      if (!QRService.validateQRToken(qrData)) {
        return QRValidationResult(
          isValid: false,
          message: 'Invalid or tampered QR code',
        );
      }

      return QRValidationResult(
        isValid: true,
        message: 'Valid student QR code',
        studentId: qrData['student_id'],
        studentName: qrData['full_name'],
        studentClass: qrData['class'],
        studentPhone: qrData['phone'],
        studentGender: qrData['gender'],
      );
    } catch (e) {
      return QRValidationResult(
        isValid: false,
        message: 'Error validating QR code: $e',
      );
    }
  }

  // Get QR scanner widget
  static Widget getQRScannerWidget({
    required Function(BarcodeCapture) onDetect,
  }) {
    _controller = MobileScannerController();
    return MobileScanner(
      controller: _controller!,
      onDetect: onDetect,
    );
  }

  // Stop scanning
  static void stopScanning() {
    _controller?.stop();
    _isScanning = false;
  }

  // Resume scanning
  static void resumeScanning() {
    _controller?.start();
    _isScanning = true;
  }

  // Dispose scanner
  static void dispose() {
    _controller?.dispose();
    _controller = null;
    _isScanning = false;
  }

  // Helper method to mark attendance via QR API
  static Future<bool> _markQRAttendance(String qrData, String date) async {
    try {
      final response = await http.post(
        Uri.parse('https://mk-attendance.vercel.app/api/attendance/qr'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'qr_data': qrData,
          'date': date,
          'notes': 'Marked via QR scan',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ QR attendance API error: $e');
      return false;
    }
  }
}

// Result classes
class AttendanceResult {
  final bool success;
  final String message;
  final int? studentId;
  final String? studentName;
  final String? studentClass;
  final String? attendanceStatus;
  final DateTime? timestamp;

  AttendanceResult({
    required this.success,
    required this.message,
    this.studentId,
    this.studentName,
    this.studentClass,
    this.attendanceStatus,
    this.timestamp,
  });
}

class QRValidationResult {
  final bool isValid;
  final String message;
  final int? studentId;
  final String? studentName;
  final String? studentClass;
  final String? studentPhone;
  final String? studentGender;

  QRValidationResult({
    required this.isValid,
    required this.message,
    this.studentId,
    this.studentName,
    this.studentClass,
    this.studentPhone,
    this.studentGender,
  });
}
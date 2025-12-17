import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import '../models/student.dart';

class QRService {
  // Generate QR code data for a student
  static String generateQRData(Student student) {
    final qrData = {
      'student_id': student.id,
      'full_name': student.fullName,
      'class': student.className,
      'phone': student.phone,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'token': _generateSecureToken(student),
    };
    
    return jsonEncode(qrData);
  }

  // Generate secure token for QR code validation
  static String _generateSecureToken(Student student) {
    final data = '${student.id}_${student.fullName}_${student.phone}_mk_attendance';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16); // Use first 16 characters
  }

  // Validate QR code token
  static bool validateQRToken(Map<String, dynamic> qrData) {
    try {
      final studentId = qrData['student_id'];
      final fullName = qrData['full_name'];
      final phone = qrData['phone'];
      final token = qrData['token'];
      
      if (studentId == null || fullName == null || phone == null || token == null) {
        return false;
      }

      final expectedToken = _generateSecureToken(Student(
        id: studentId,
        fullName: fullName,
        phone: phone,
        className: qrData['class'] ?? '',
      ));

      return token == expectedToken;
    } catch (e) {
      print('QR validation error: $e');
      return false;
    }
  }

  // Generate QR code widget
  static Widget generateQRWidget(String qrData, {double size = 200}) {
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
  }

  // Generate QR code as image bytes for email attachment
  static Future<Uint8List?> generateQRImageBytes(String qrData, {double size = 300}) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      );

      if (qrValidationResult.status != QrValidationStatus.valid) {
        print('QR validation failed: ${qrValidationResult.error}');
        return null;
      }

      final qrCode = qrValidationResult.qrCode!;
      final painter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
        color: Colors.black,
        emptyColor: Colors.white,
      );

      final picturRecorder = ui.PictureRecorder();
      final canvas = Canvas(picturRecorder);
      painter.paint(canvas, Size(size, size));
      
      final picture = picturRecorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error generating QR image: $e');
      return null;
    }
  }

  // Parse QR code data
  static Map<String, dynamic>? parseQRData(String qrString) {
    try {
      final data = jsonDecode(qrString) as Map<String, dynamic>;
      
      // Validate required fields
      if (data['student_id'] == null || 
          data['full_name'] == null || 
          data['token'] == null) {
        return null;
      }
      
      return data;
    } catch (e) {
      print('Error parsing QR data: $e');
      return null;
    }
  }

  // Generate student QR code for display
  static Future<Widget> generateStudentQRCard(Student student) async {
    final qrData = generateQRData(student);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Student QR Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            generateQRWidget(qrData, size: 200),
            const SizedBox(height: 16),
            Text(
              student.fullName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'ID: ${student.id} | Class: ${student.className}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan this QR code for attendance',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../services/qr_service.dart';

class NotificationService {
  static const String _baseUrl = 'https://mk-attendance.vercel.app/api';
  
  // Send automatic email when student registers (with QR code)
  static Future<bool> sendRegistrationEmailWithQR(Student student) async {
    try {
      print('📧 Sending registration email with QR code to ${student.email}');
      
      // Generate QR code data
      final qrData = QRService.generateQRData(student);
      final qrImageBytes = await QRService.generateQRImageBytes(qrData);
      
      if (qrImageBytes == null) {
        print('❌ Failed to generate QR code image');
        return false;
      }

      // Convert QR image to base64 for email attachment
      final qrBase64 = base64Encode(qrImageBytes);
      
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications/registration'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'student_id': student.id,
          'full_name': student.fullName,
          'email': student.email,
          'phone': student.phone,
          'class': student.className,
          'gender': student.gender,
          'qr_code_data': qrData,
          'qr_code_image': qrBase64,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Registration email with QR sent successfully: ${data['message']}');
        return true;
      } else {
        print('❌ Failed to send registration email: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Error sending registration email with QR: $e');
      return false;
    }
  }

  // Send automatic email when student registers (legacy method)
  static Future<bool> sendRegistrationEmail(Student student) async {
    return sendRegistrationEmailWithQR(student);
  }

  // Send bulk email to selected students
  static Future<Map<String, dynamic>> sendBulkEmail({
    required String message,
    required List<int> studentIds,
    required String senderName,
  }) async {
    try {
      print('📧 Sending bulk email to ${studentIds.length} students');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications/bulk'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'student_ids': studentIds,
          'sender_name': senderName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Bulk email sent successfully');
        return {
          'success': true,
          'message': data['message'],
          'sent_count': data['sent_count'],
          'failed_count': data['failed_count'],
        };
      } else {
        print('❌ Failed to send bulk email: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to send emails',
          'sent_count': 0,
          'failed_count': studentIds.length,
        };
      }
    } catch (e) {
      print('💥 Error sending bulk email: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
        'sent_count': 0,
        'failed_count': studentIds.length,
      };
    }
  }

  // Get email logs for admin
  static Future<List<Map<String, dynamic>>> getEmailLogs() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/logs'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['logs'] ?? []);
      } else {
        print('❌ Failed to fetch email logs: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('💥 Error fetching email logs: $e');
      return [];
    }
  }

  // UI Helper methods for settings screen
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
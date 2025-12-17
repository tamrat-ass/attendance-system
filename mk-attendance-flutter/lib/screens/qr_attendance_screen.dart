import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/qr_scanner_service.dart';
import '../utils/app_colors.dart';
import '../utils/ethiopian_date.dart';
import 'qr_confirmation_screen.dart';

class QRAttendanceScreen extends StatefulWidget {
  const QRAttendanceScreen({super.key});

  @override
  State<QRAttendanceScreen> createState() => _QRAttendanceScreenState();
}

class _QRAttendanceScreenState extends State<QRAttendanceScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;
  List<AttendanceResult> _attendanceResults = [];
  Set<int> _scannedStudentIds = {}; // Prevent duplicate scans

  @override
  void initState() {
    super.initState();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? qrCode = barcodes.first.rawValue;
      if (qrCode != null) {
        _processQRCode(qrCode);
      }
    }
  }

  Future<void> _processQRCode(String qrCode) async {
    setState(() {
      _isScanning = false;
    });

    try {
      // First validate the QR code
      final validation = await QRScannerService.validateQRCode(qrCode);
      
      if (!validation.isValid) {
        _showErrorDialog('Invalid QR Code', validation.message);
        _resumeScanning();
        return;
      }

      // Check if student already scanned today
      if (_scannedStudentIds.contains(validation.studentId)) {
        _showErrorDialog(
          'Already Scanned', 
          '${validation.studentName} has already been marked present today.',
        );
        _resumeScanning();
        return;
      }

      // Navigate to confirmation screen
      final confirmed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => QRConfirmationScreen(
            studentData: {
              'student_id': validation.studentId,
              'full_name': validation.studentName,
              'class': validation.studentClass,
              'phone': validation.studentPhone ?? 'N/A',
              'gender': validation.studentGender ?? 'N/A',
            },
            qrCode: qrCode,
          ),
        ),
      );

      // If confirmed, add to results
      if (confirmed == true) {
        final result = AttendanceResult(
          success: true,
          message: 'Attendance marked successfully',
          studentId: validation.studentId,
          studentName: validation.studentName,
          studentClass: validation.studentClass,
          attendanceStatus: 'present',
          timestamp: DateTime.now(),
        );
        
        setState(() {
          _attendanceResults.insert(0, result);
          if (validation.studentId != null) {
            _scannedStudentIds.add(validation.studentId!);
          }
        });
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to process QR code: $e');
    }

    // Resume scanning
    _resumeScanning();
  }

  void _resumeScanning() {
    if (mounted) {
      setState(() {
        _isScanning = true;
      });
    }
  }

  void _showSuccessDialog(AttendanceResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Success'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student: ${result.studentName}'),
            Text('Class: ${result.studentClass}'),
            Text('Status: ${result.attendanceStatus?.toUpperCase()}'),
            Text('Time: ${_formatTime(result.timestamp)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Attendance Scanner'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (_isScanning) {
                setState(() {
                  _isScanning = false;
                });
              } else {
                _resumeScanning();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () async {
              await controller.toggleTorch();
            },
          ),
        ],
      ),
      body: Column(
              children: [
                // Scanner Area
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: controller,
                        onDetect: _onDetect,
                      ),
                      if (!_isScanning)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: Text(
                              'Scanning Paused',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      // QR Scanner Overlay
                      Center(
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isScanning ? Colors.green : Colors.grey,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.primary.withOpacity(0.1),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Scan Student QR Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Point camera at student QR code to mark attendance',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${EthiopianDateUtils.formatEthiopianDate(EthiopianDateUtils.getCurrentEthiopianDate())}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Results List
                Expanded(
                  flex: 2,
                  child: _attendanceResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                'No attendance marked yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Today\'s Attendance',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${_scannedStudentIds.length} Present',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _attendanceResults.length,
                                itemBuilder: (context, index) {
                                  final result = _attendanceResults[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: result.success ? Colors.green : Colors.red,
                                        child: Icon(
                                          result.success ? Icons.check : Icons.error,
                                          color: Colors.white,
                                        ),
                                      ),
                                      title: Text(result.studentName ?? 'Unknown Student'),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (result.studentClass != null)
                                            Text('Class: ${result.studentClass}'),
                                          Text(result.message),
                                          if (result.timestamp != null)
                                            Text('Time: ${_formatTime(result.timestamp)}'),
                                        ],
                                      ),
                                      trailing: result.success
                                          ? Icon(Icons.check_circle, color: Colors.green)
                                          : Icon(Icons.error_outline, color: Colors.red),
                                      isThreeLine: true,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}
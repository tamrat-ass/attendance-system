import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';
import '../models/student.dart';
import '../utils/ethiopian_date.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? _selectedClass;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Map<int, String> _studentStatus = {};
  Map<int, String> _studentNotes = {};
  Set<int> _lockedStudents = {};
  Map<int, String> _savedStudentStatus = {}; // Track saved attendance separately
  bool _isEditMode = false;
  
  // Initialize with current Ethiopian date converted to Gregorian format
  String _selectedDate = _getCurrentEthiopianDateAsGregorian();
  
  // Helper method to get current Ethiopian date as Gregorian string for consistency with web app
  static String _getCurrentEthiopianDateAsGregorian() {
    final now = DateTime.now();
    final ethiopianDate = EthiopianDateUtils.gregorianToEthiopian(now);
    final gregorianString = _ethiopianToGregorianString(ethiopianDate);
    
    print('=== DATE SYNC DEBUG ===');
    print('Current Gregorian: ${now.toIso8601String().split('T')[0]}');
    print('Ethiopian Date: ${ethiopianDate['year']}-${ethiopianDate['month']}-${ethiopianDate['day']}');
    print('Converted to Gregorian: $gregorianString');
    print('=== END DATE SYNC DEBUG ===');
    
    // Convert Ethiopian date back to a consistent Gregorian format
    // This ensures both web and mobile use the same date representation
    return gregorianString;
  }
  
  // Convert Ethiopian date to Gregorian string format (YYYY-MM-DD)
  static String _ethiopianToGregorianString(Map<String, int> ethiopianDate) {
    // Simple conversion for consistency - this should match the web app logic
    final ethYear = ethiopianDate['year']!;
    final ethMonth = ethiopianDate['month']!;
    final ethDay = ethiopianDate['day']!;
    
    // Convert Ethiopian to approximate Gregorian (matching web app logic)
    final gregYear = ethYear + 7; // Ethiopian year + 7 = approximate Gregorian year
    int gregMonth = ethMonth + 8; // Approximate month conversion
    int gregDay = ethDay;
    
    // Handle month overflow
    if (gregMonth > 12) {
      gregMonth = gregMonth - 12;
    }
    
    // Ensure valid ranges
    if (gregMonth <= 0) gregMonth = 1;
    if (gregMonth > 12) gregMonth = 12;
    if (gregDay <= 0) gregDay = 1;
    if (gregDay > 28) gregDay = 28; // Safe day for all months
    
    final year = gregYear.toString().padLeft(4, '0');
    final month = gregMonth.toString().padLeft(2, '0');
    final day = gregDay.toString().padLeft(2, '0');
    
    return '$year-$month-$day';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    await studentProvider.loadStudents();
    await studentProvider.loadClasses();
    
    if (studentProvider.classes.isNotEmpty && _selectedClass == null) {
      setState(() {
        _selectedClass = studentProvider.classes.first;
      });
      _loadExistingAttendance();
    }
  }

  Future<void> _loadExistingAttendance() async {
    if (_selectedClass == null) return;
    
    print('=== LOADING EXISTING ATTENDANCE ===');
    print('Date: $_selectedDate');
    print('Class: $_selectedClass');
    
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    await attendanceProvider.loadAttendance(
      date: _selectedDate,
      className: _selectedClass,
    );
    
    print('Loaded attendance records: ${attendanceProvider.attendanceRecords.length}');
    print('Student status from provider: ${attendanceProvider.studentStatus}');
    print('Student notes from provider: ${attendanceProvider.studentNotes}');
    
    // Update local state with existing attendance
    setState(() {
      _savedStudentStatus = Map.from(attendanceProvider.studentStatus);
      _studentNotes = Map.from(attendanceProvider.studentNotes);
      _lockedStudents = Set.from(attendanceProvider.studentStatus.keys);
      // Load saved status into current status to show existing attendance
      _studentStatus = Map.from(attendanceProvider.studentStatus);
    });
    
    print('✅ Loaded existing attendance for ${_lockedStudents.length} students');
    
    print('Updated local state:');
    print('- Saved status: $_savedStudentStatus');
    print('- Current status: $_studentStatus');
    print('- Locked students: $_lockedStudents');
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (picked != null) {
      // Convert the picked Gregorian date to Ethiopian and back to ensure consistency
      final ethiopianDate = EthiopianDateUtils.gregorianToEthiopian(picked);
      final consistentDate = _ethiopianToGregorianString(ethiopianDate);
      
      print('=== DATE PICKER SYNC DEBUG ===');
      print('Picked Gregorian: ${picked.toIso8601String().split('T')[0]}');
      print('Converted Ethiopian: ${ethiopianDate['year']}-${ethiopianDate['month']}-${ethiopianDate['day']}');
      print('Final Consistent Date: $consistentDate');
      print('=== END DATE PICKER SYNC DEBUG ===');
      
      setState(() {
        _selectedDate = consistentDate;
        _studentStatus.clear();
        _studentNotes.clear();
        _lockedStudents.clear();
      });
      _loadExistingAttendance();
    }
  }

  void _handleStatusChange(int studentId, String status) {
    // Check if student is locked and not in edit mode
    if (_lockedStudents.contains(studentId) && !_isEditMode) {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final student = studentProvider.students.firstWhere(
        (s) => s.id == studentId,
        orElse: () => Student(id: studentId, fullName: 'Unknown Student', phone: '', className: ''),
      );
      
      _showMessage(
        '🔒 ${student.fullName} already has attendance saved. Use Edit Mode to make changes.',
        Colors.orange,
      );
      return;
    }
    
    // Check for duplicate attempt (trying to mark attendance when already marked)
    if (_savedStudentStatus.containsKey(studentId) && !_isEditMode) {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final student = studentProvider.students.firstWhere(
        (s) => s.id == studentId,
        orElse: () => Student(id: studentId, fullName: 'Unknown Student', phone: '', className: ''),
      );
      
      final existingStatus = _savedStudentStatus[studentId];
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text('Attendance Already Exists'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${student.fullName} already has attendance marked as "$existingStatus" for $_selectedDate.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Each student can only have one attendance record per day.',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Would you like to:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _toggleEditMode(); // Enable edit mode
                  // Then apply the status change
                  setState(() {
                    _studentStatus[studentId] = status;
                  });
                  _showMessage(
                    '✏️ Edit mode enabled. You can now modify ${student.fullName}\'s attendance.',
                    Colors.orange,
                  );
                },
                child: const Text('Edit Existing'),
              ),
            ],
          );
        },
      );
      return;
    }
    
    print('Marking student $studentId as $status (Edit mode: $_isEditMode)');
    setState(() {
      _studentStatus[studentId] = status;
    });
    
    // Show confirmation message for new attendance
    if (!_isEditMode) {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final student = studentProvider.students.firstWhere(
        (s) => s.id == studentId,
        orElse: () => Student(id: studentId, fullName: 'Unknown Student', phone: '', className: ''),
      );
      
      _showMessage(
        '✅ ${student.fullName} marked as $status',
        Colors.green,
      );
    }
    
    print('Current student status: $_studentStatus');
  }

  void _handleNotesChange(int studentId, String note) {
    // Allow changes if in edit mode, even for locked students
    if (_lockedStudents.contains(studentId) && !_isEditMode) return;
    
    setState(() {
      _studentNotes[studentId] = note;
    });
  }

  // Enhanced duplicate validation before saving
  bool _validateAttendanceData() {
    // Check for duplicate entries within current selection
    final Map<String, List<int>> studentDateMap = {};
    final List<String> duplicates = [];
    
    for (final entry in _studentStatus.entries) {
      final studentId = entry.key;
      final key = '$studentId-$_selectedDate';
      
      if (!studentDateMap.containsKey(key)) {
        studentDateMap[key] = [];
      }
      studentDateMap[key]!.add(studentId);
      
      if (studentDateMap[key]!.length > 1) {
        final studentProvider = Provider.of<StudentProvider>(context, listen: false);
        final student = studentProvider.students.firstWhere(
          (s) => s.id == studentId,
          orElse: () => Student(id: studentId, fullName: 'Unknown Student', phone: '', className: ''),
        );
        duplicates.add('${student.fullName} (ID: $studentId)');
      }
    }
    
    if (duplicates.isNotEmpty) {
      _showDuplicateValidationDialog(duplicates);
      return false;
    }
    
    return true;
  }

  void _showDuplicateValidationDialog(List<String> duplicates) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Duplicate Attendance Detected'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Multiple attendance entries found for the following students:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...duplicates.map((duplicate) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Text('• $duplicate'),
              )),
              const SizedBox(height: 12),
              const Text(
                'Each student can only have one attendance record per day. Please review your selections.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDuplicateErrorDialog(Map<String, dynamic> result) {
    final errorType = result['error'];
    final message = result['message'] ?? 'Duplicate attendance detected';
    final duplicates = result['duplicates'] as List?;
    final hint = result['hint'];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Expanded(child: Text('Duplicate Attendance Error')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (duplicates != null && duplicates.isNotEmpty) ...[
                  const Text(
                    'Duplicates found:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  ...duplicates.map((duplicate) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 2),
                    child: Text('• $duplicate'),
                  )),
                  const SizedBox(height: 12),
                ],
                if (hint != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hint,
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Each student can only have one attendance record per day. To modify existing attendance, use Edit Mode.',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (errorType == 'DUPLICATE_ATTENDANCE_EXISTS')
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _toggleEditMode(); // Enable edit mode
                },
                child: const Text('Enable Edit Mode'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveAttendance() async {
    print('=== SAVE ATTENDANCE DEBUG ===');
    print('Save button pressed');
    print('Edit mode: $_isEditMode');
    print('Selected class: $_selectedClass');
    print('Student status: $_studentStatus');
    print('Locked students: $_lockedStudents');
    print('Student notes: $_studentNotes');
    
    if (_selectedClass == null) {
      _showMessage('Please select a class first', Colors.red);
      return;
    }

    if (_studentStatus.isEmpty) {
      _showMessage('No attendance data to save. Please mark some students first.', Colors.orange);
      return;
    }
    
    // Validate for duplicates before proceeding
    if (!_validateAttendanceData()) {
      return; // Validation failed, don't proceed with save
    }
    
    // Test connectivity first
    final isConnected = await ApiService.testAttendanceApi();
    if (!isConnected) {
      _showMessage('❌ Cannot connect to attendance server. Please check your internet connection and try again.', Colors.red);
      return;
    }
    
    // Don't show loading message, just save silently
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    
    // Clear existing data and set new data
    attendanceProvider.studentStatus.clear();
    attendanceProvider.studentNotes.clear();
    
    // Add current status and notes
    attendanceProvider.studentStatus.addAll(_studentStatus);
    attendanceProvider.studentNotes.addAll(_studentNotes);
    
    print('Calling saveAttendance with date: $_selectedDate, isEdit: $_isEditMode');
    final result = await attendanceProvider.saveAttendance(_selectedDate, 1);
    print('Save result: $result');
    print('Provider error: ${attendanceProvider.errorMessage}');
    
    if (result['success'] == true) {
      // Store the count before clearing
      final savedCount = _studentStatus.length;
      final savedStudentIds = _studentStatus.keys.toSet();
      
      // Create detailed success message
      String message;
      final insertedCount = result['insertedCount'] ?? 0;
      final updatedCount = result['updatedCount'] ?? 0;
      
      if (insertedCount > 0 && updatedCount > 0) {
        message = '✅ Attendance saved: $insertedCount new, $updatedCount updated!';
      } else if (insertedCount > 0) {
        message = '✅ Attendance saved for $insertedCount students!';
      } else if (updatedCount > 0) {
        message = '✅ Attendance updated for $updatedCount students!';
      } else {
        message = _isEditMode 
            ? '✅ Attendance updated successfully for $savedCount students!'
            : '✅ Attendance saved successfully for $savedCount students!';
      }
      
      _showMessage(message, Colors.green);
      
      // Update saved status and lock the students
      setState(() {
        // Update the saved status with the new changes
        for (int studentId in savedStudentIds) {
          if (_studentStatus.containsKey(studentId)) {
            _savedStudentStatus[studentId] = _studentStatus[studentId]!;
          }
        }
        
        _lockedStudents.addAll(savedStudentIds);
        _studentStatus.clear(); // Clear to remove count from save button
        _studentNotes.clear(); // Clear notes too
        _isEditMode = false; // Exit edit mode after successful save
      });
    } else {
      print('Save error: ${result['message']}');
      String errorMsg = result['message'] ?? 'Unknown error';
      final errorType = result['error'];
      
      // Handle specific error types with appropriate messages
      if (errorType == 'DUPLICATE_ATTENDANCE' || errorType == 'DUPLICATE_ATTENDANCE_IN_REQUEST' || errorType == 'DUPLICATE_ATTENDANCE_EXISTS') {
        _showDuplicateErrorDialog(result);
        return; // Don't continue with generic error handling
      } else if (errorType == 'NO_CONNECTION' || errorMsg.contains('Network error') || errorMsg.contains('SocketException')) {
        errorMsg = '❌ No Internet Connection\n\nPlease check your network connection and try again.';
      } else if (errorType == 'CONNECTION_FAILED' || errorType == 'CONNECTION_TEST_FAILED') {
        errorMsg = '❌ Server Connection Failed\n\nUnable to connect to the attendance server. Please try again later.';
      } else if (errorType == 'SERVER_ERROR') {
        errorMsg = '❌ Server Error\n\nThe server encountered an error. Please try again or contact support.';
      } else if (errorType == 'VALIDATION_ERROR') {
        errorMsg = '❌ Validation Error\n\n${result['message']}\n\nPlease check your attendance data and try again.';
      } else if (errorMsg.contains('Failed to save attendance to server')) {
        errorMsg = '❌ Server Error\n\nFailed to save attendance. Please try again or contact support.';
      }
      
      _showMessage(errorMsg, Colors.red);
    }
    print('=== END SAVE DEBUG ===');
  }

  Future<void> _markAllPermission() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    
    // Get all students from ALL classes
    final allStudents = studentProvider.students;
    
    // Find unmarked students (not locked and not in current status)
    final unmarkedStudents = allStudents
        .where((student) => !_lockedStudents.contains(student.id) && !_studentStatus.containsKey(student.id))
        .toList();
    
    if (unmarkedStudents.isEmpty) {
      _showMessage('All students already have attendance marked', Colors.orange);
      return;
    }
    
    // Mark all unmarked students as permission
    final newStatus = <int, String>{};
    for (final student in unmarkedStudents) {
      newStatus[student.id!] = 'permission';
    }
    
    setState(() {
      _studentStatus.addAll(newStatus);
    });
    
    _showMessage('✅ Marked ${unmarkedStudents.length} students as permission', Colors.blue);
    
    // Auto-save after marking
    await Future.delayed(const Duration(milliseconds: 500));
    await _saveAttendance();
  }

  void _toggleEditMode() {
    print('Toggle edit mode called - current state: $_isEditMode');
    
    setState(() {
      _isEditMode = !_isEditMode;
      
      if (_isEditMode) {
        // When entering edit mode, load saved attendance into current status for editing
        _studentStatus.clear();
        _studentStatus.addAll(_savedStudentStatus);
        print('Edit mode enabled - loaded ${_savedStudentStatus.length} saved records for editing');
      } else {
        // When exiting edit mode, just clear current status (don't reload from server)
        _studentStatus.clear();
        print('Edit mode disabled - cleared current status');
      }
    });
    
    _showMessage(
      _isEditMode ? 'Edit mode enabled - You can now change saved attendance' : 'Edit mode disabled',
      _isEditMode ? Colors.orange : Colors.blue,
    );
  }

  Future<void> _testApiConnection() async {
    _showMessage('Testing API connection...', Colors.blue);
    
    final isConnected = await ApiService.testApiConnection();
    
    if (isConnected) {
      _showMessage('✅ API connection successful!', Colors.green);
      
      // Save format is already tested in the main save method
      _showMessage('✅ API connection successful!', Colors.green);
    } else {
      _showMessage('❌ API connection failed. Check console for details.', Colors.red);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'permission':
        return Colors.blue;
      default:
        return Colors.grey.shade300;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'present':
        return 'Present';
      case 'absent':
        return 'Absent';
      case 'late':
        return 'Late';
      case 'permission':
        return 'Permission';
      default:
        return 'Not Marked';
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'present':
        return Icons.check;
      case 'absent':
        return Icons.close;
      case 'late':
        return Icons.access_time;
      case 'permission':
        return Icons.assignment_turned_in;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Mark Attendance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Date Selection
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              EthiopianDateUtils.formatDate(_selectedDate),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Class Selection
                    Consumer<StudentProvider>(
                      builder: (context, studentProvider, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedClass,
                              hint: const Text(
                                'Select Class',
                                style: TextStyle(color: Colors.white70),
                              ),
                              dropdownColor: AppColors.primary,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                              isExpanded: true,
                              items: studentProvider.classes.map((className) {
                                return DropdownMenuItem(
                                  value: className,
                                  child: Text(className, style: const TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedClass = value;
                                  _studentStatus.clear();
                                  _studentNotes.clear();
                                  _lockedStudents.clear();
                                });
                                _loadExistingAttendance();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by ID, name, or phone (across all classes)...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Action Buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _markAllPermission,
                    icon: const Icon(Icons.assignment_turned_in, size: 18),
                    label: const Text('Mark All Permission', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _saveAttendance,
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Save Attendance', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      print('Edit button tapped! Current edit mode: $_isEditMode');
                      _toggleEditMode();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isEditMode ? Colors.orange : Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _isEditMode ? Icons.edit_off : Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Status Legend
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('Present', Colors.green, Icons.check),
                _buildLegendItem('Absent', Colors.red, Icons.close),
                _buildLegendItem('Late', Colors.orange, Icons.access_time),
                _buildLegendItem('Permission', Colors.blue, Icons.assignment_turned_in),
              ],
            ),
          ),
          
          // Students List
          Expanded(
            child: Consumer<StudentProvider>(
              builder: (context, studentProvider, child) {
                if (studentProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (_selectedClass == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.class_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Please select a class to continue',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                List<Student> students;
                
                if (_searchQuery.isNotEmpty) {
                  // Search across ALL students from ALL classes
                  students = studentProvider.students.where((student) {
                    return student.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           student.phone.contains(_searchQuery) ||
                           student.id.toString().contains(_searchQuery);
                  }).toList();
                } else {
                  // Show only students from selected class when no search
                  students = studentProvider.getStudentsByClass(_selectedClass!);
                }
                
                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty 
                              ? 'No students found matching "$_searchQuery"'
                              : 'No students in $_selectedClass',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final isLocked = _lockedStudents.contains(student.id);
                    // In edit mode, always use current status; otherwise use saved status for locked students
                    final status = _isEditMode 
                        ? _studentStatus[student.id] 
                        : (isLocked ? _savedStudentStatus[student.id] : _studentStatus[student.id]);
                    
                    // Check if this student has duplicate attendance attempts
                    final hasDuplicateAttempt = _studentStatus.containsKey(student.id) && 
                                              _savedStudentStatus.containsKey(student.id) && 
                                              !_isEditMode;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: hasDuplicateAttempt 
                            ? Border.all(color: Colors.red.shade300, width: 2)
                            : isLocked 
                                ? Border.all(color: Colors.green.shade300, width: 2) 
                                : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Student Info Row
                            Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                    child: status != null
                                        ? Icon(
                                            _getStatusIcon(status),
                                            color: Colors.white,
                                            size: 24,
                                          )
                                        : Text(
                                            student.fullName.substring(0, 1).toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Student Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.fullName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ID: ${student.id} • ${student.phone}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      if (_searchQuery.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            'Class: ${student.className ?? 'Unknown'}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (hasDuplicateAttempt) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.red.shade200),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.warning, size: 12, color: Colors.red.shade700),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Already has attendance - Use Edit Mode',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.red.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                
                                // Lock/Edit indicator
                                if (isLocked)
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: _isEditMode ? Colors.orange.shade100 : Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      _isEditMode ? Icons.edit : Icons.lock,
                                      color: _isEditMode ? Colors.orange.shade700 : Colors.green.shade700,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Status Buttons
                            if (isLocked && status != null && !_isEditMode) ...[
                              // Show only the selected status when locked and not in edit mode
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(_getStatusIcon(status), color: Colors.white, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_getStatusLabel(status)} (Saved)',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              // Show all buttons when not locked OR in edit mode
                              Row(
                                children: [
                                  _buildStatusButton('Present', 'present', Colors.green, Icons.check, status, student.id!, isLocked && !_isEditMode),
                                  const SizedBox(width: 8),
                                  _buildStatusButton('Absent', 'absent', Colors.red, Icons.close, status, student.id!, isLocked && !_isEditMode),
                                  const SizedBox(width: 8),
                                  _buildStatusButton('Late', 'late', Colors.orange, Icons.access_time, status, student.id!, isLocked && !_isEditMode),
                                  const SizedBox(width: 8),
                                  _buildStatusButton('Permission', 'permission', Colors.blue, Icons.assignment_turned_in, status, student.id!, isLocked && !_isEditMode),
                                ],
                              ),
                            ],
                            
                            // Notes Field
                            const SizedBox(height: 12),
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'Notes (optional)',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                suffixIcon: _isEditMode && isLocked 
                                    ? Icon(Icons.edit, color: Colors.orange, size: 16)
                                    : null,
                              ),
                              onChanged: (value) => _handleNotesChange(student.id!, value),
                              controller: TextEditingController(text: _studentNotes[student.id] ?? '')
                                ..selection = TextSelection.fromPosition(
                                  TextPosition(offset: (_studentNotes[student.id] ?? '').length),
                                ),
                              enabled: !isLocked || _isEditMode,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatusButton(
    String label,
    String statusValue,
    Color color,
    IconData icon,
    String? currentStatus,
    int studentId,
    bool isLocked,
  ) {
    final isSelected = currentStatus == statusValue;
    
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: isLocked ? null : () => _handleStatusChange(studentId, statusValue),
        icon: Icon(icon, size: 14),
        label: Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.white : Colors.grey.shade700,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
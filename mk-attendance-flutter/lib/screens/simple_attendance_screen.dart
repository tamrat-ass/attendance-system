import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../models/simple_attendance.dart';
import '../providers/student_provider.dart';
import '../services/simple_api.dart';
import '../utils/app_colors.dart';

class SimpleAttendanceScreen extends StatefulWidget {
  const SimpleAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<SimpleAttendanceScreen> createState() => _SimpleAttendanceScreenState();
}

class _SimpleAttendanceScreenState extends State<SimpleAttendanceScreen> {
  String _selectedDate = DateTime.now().toIso8601String().split('T')[0];
  String? _selectedClass;
  Map<int, String> _attendanceStatus = {}; // studentId -> status
  Map<int, String> _savedStatus = {}; // Already saved attendance
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudents();
    });
  }

  Future<void> _loadStudents() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    await studentProvider.loadStudents();
    
    if (studentProvider.classes.isNotEmpty) {
      setState(() {
        _selectedClass = studentProvider.classes.first;
      });
      _loadExistingAttendance();
    }
  }

  Future<void> _loadExistingAttendance() async {
    if (_selectedClass == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      print('🔄 Loading existing attendance for $_selectedDate');
      final attendance = await SimpleAPI.getAttendance(_selectedDate);
      
      // Filter by current class students
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final classStudents = studentProvider.students
          .where((s) => s.className == _selectedClass)
          .toList();
      
      Map<int, String> savedStatus = {};
      for (final record in attendance) {
        // Only include if student is in current class
        if (classStudents.any((s) => s.id == record.studentId)) {
          savedStatus[record.studentId] = record.status;
        }
      }
      
      setState(() {
        _savedStatus = savedStatus;
        _attendanceStatus = Map.from(savedStatus); // Copy saved to current
      });
      
      print('✅ Loaded attendance for ${savedStatus.length} students');
    } catch (e) {
      print('❌ Error loading attendance: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAttendance() async {
    if (_attendanceStatus.isEmpty) {
      _showMessage('No attendance marked', Colors.orange);
      return;
    }

    // Test connection first
    final connected = await SimpleAPI.testConnection();
    if (!connected) {
      _showMessage('❌ No internet connection', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create attendance records
      List<SimpleAttendance> records = [];
      _attendanceStatus.forEach((studentId, status) {
        records.add(SimpleAttendance(
          studentId: studentId,
          date: _selectedDate,
          status: status,
        ));
      });

      print('💾 Saving attendance for ${records.length} students');
      final success = await SimpleAPI.saveAttendance(records);

      if (success) {
        setState(() {
          _savedStatus = Map.from(_attendanceStatus);
        });
        _showMessage('✅ Attendance saved successfully!', Colors.green);
      } else {
        _showMessage('❌ Failed to save attendance', Colors.red);
      }
    } catch (e) {
      _showMessage('❌ Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _markStudent(int studentId, String status) {
    setState(() {
      _attendanceStatus[studentId] = status;
    });
    print('📝 Marked student $studentId as $status');
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present': return Colors.green;
      case 'absent': return Colors.red;
      case 'late': return Colors.orange;
      case 'permission': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'present': return Icons.check;
      case 'absent': return Icons.close;
      case 'late': return Icons.access_time;
      case 'permission': return Icons.assignment_turned_in;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Attendance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary,
            child: Column(
              children: [
                // Date Picker
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Date: $_selectedDate',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.parse(_selectedDate),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date.toIso8601String().split('T')[0];
                            _attendanceStatus.clear();
                            _savedStatus.clear();
                          });
                          _loadExistingAttendance();
                        }
                      },
                      child: const Text('Change', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Class Selector
                Consumer<StudentProvider>(
                  builder: (context, studentProvider, child) {
                    return DropdownButton<String>(
                      value: _selectedClass,
                      hint: const Text('Select Class', style: TextStyle(color: Colors.white70)),
                      dropdownColor: AppColors.primary,
                      style: const TextStyle(color: Colors.white),
                      isExpanded: true,
                      items: studentProvider.classes.map((className) {
                        return DropdownMenuItem(
                          value: className,
                          child: Text(className),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClass = value;
                          _attendanceStatus.clear();
                          _savedStatus.clear();
                        });
                        _loadExistingAttendance();
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // Status Legend
          Container(
            padding: const EdgeInsets.all(8),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Consumer<StudentProvider>(
                    builder: (context, studentProvider, child) {
                      final students = studentProvider.students
                          .where((s) => s.className == _selectedClass)
                          .toList();

                      if (students.isEmpty) {
                        return const Center(
                          child: Text('No students in selected class'),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final currentStatus = _attendanceStatus[student.id!];
                          final isSaved = _savedStatus.containsKey(student.id!);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Student Info
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: currentStatus != null 
                                            ? _getStatusColor(currentStatus)
                                            : Colors.grey,
                                        child: currentStatus != null
                                            ? Icon(_getStatusIcon(currentStatus), color: Colors.white)
                                            : Text(student.fullName.substring(0, 1)),
                                      ),
                                      const SizedBox(width: 12),
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
                                            Text(
                                              'ID: ${student.id} • ${student.phone}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSaved)
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.cloud_done,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Status Buttons
                                  Row(
                                    children: [
                                      _buildStatusButton(student.id!, 'present', 'Present', Colors.green, Icons.check, currentStatus),
                                      const SizedBox(width: 8),
                                      _buildStatusButton(student.id!, 'absent', 'Absent', Colors.red, Icons.close, currentStatus),
                                      const SizedBox(width: 8),
                                      _buildStatusButton(student.id!, 'late', 'Late', Colors.orange, Icons.access_time, currentStatus),
                                      const SizedBox(width: 8),
                                      _buildStatusButton(student.id!, 'permission', 'Permission', Colors.blue, Icons.assignment_turned_in, currentStatus),
                                    ],
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

          // Save Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveAttendance,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Saving...' : 'Save Attendance (${_attendanceStatus.length})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
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
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildStatusButton(int studentId, String status, String label, Color color, IconData icon, String? currentStatus) {
    final isSelected = currentStatus == status;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _markStudent(studentId, status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 16,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
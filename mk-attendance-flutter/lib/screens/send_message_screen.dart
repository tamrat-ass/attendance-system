import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_colors.dart';
import '../models/student.dart';
import '../services/notification_service.dart';
import '../providers/auth_provider.dart';

class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({super.key});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _selectedStudents = [];
  bool _isLoading = false;
  bool _isSending = false;
  bool _selectAll = false;
  String? _selectedClass;
  List<String> _classes = [];

  @override
  void initState() {
    super.initState();
    _loadStudentsAndClasses();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentsAndClasses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load students and classes in parallel
      final studentsResponse = http.get(
        Uri.parse('https://mk-attendance.vercel.app/api/students'),
        headers: {'Content-Type': 'application/json'},
      );
      
      final classesResponse = http.get(
        Uri.parse('https://mk-attendance.vercel.app/api/classes'),
        headers: {'Content-Type': 'application/json'},
      );

      final responses = await Future.wait([studentsResponse, classesResponse]);
      final studentResp = responses[0];
      final classResp = responses[1];

      if (studentResp.statusCode == 200) {
        final studentData = jsonDecode(studentResp.body);
        final students = List<Map<String, dynamic>>.from(studentData['data'] ?? []);
        
        // Filter students with email addresses only
        final studentsWithEmail = students.where((student) => 
          student['email'] != null && 
          student['email'].toString().isNotEmpty
        ).toList();

        List<String> availableClasses = ['All Classes'];
        if (classResp.statusCode == 200) {
          final classData = jsonDecode(classResp.body);
          final classes = List<dynamic>.from(classData['data'] ?? []);
          availableClasses.addAll(classes.map((c) => c['name'].toString()).toList()..sort());
        }

        setState(() {
          _students = studentsWithEmail;
          _classes = availableClasses;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load students');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Connection error: $e');
    }
  }

  List<Map<String, dynamic>> get _filteredStudents {
    if (_selectedClass == null || _selectedClass == 'All Classes') {
      return _students;
    }
    return _students.where((student) => 
      student['class']?.toString() == _selectedClass
    ).toList();
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      if (_selectAll) {
        _selectedStudents = List.from(_filteredStudents);
      } else {
        _selectedStudents.clear();
      }
    });
  }

  void _toggleStudentSelection(Map<String, dynamic> student) {
    setState(() {
      if (_selectedStudents.any((s) => s['id'] == student['id'])) {
        _selectedStudents.removeWhere((s) => s['id'] == student['id']);
      } else {
        _selectedStudents.add(student);
      }
      _selectAll = _selectedStudents.length == _filteredStudents.length;
    });
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudents.isEmpty) {
      _showErrorSnackBar('Please select at least one student');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final senderName = authProvider.user?.fullName ?? 'Admin';
      
      final studentIds = _selectedStudents.map((s) => s['id'] as int).toList();
      
      final result = await NotificationService.sendBulkEmail(
        message: _messageController.text.trim(),
        studentIds: studentIds,
        senderName: senderName,
      );

      setState(() {
        _isSending = false;
      });

      if (result['success']) {
        _showSuccessDialog(result);
        _messageController.clear();
        _selectedStudents.clear();
        setState(() {
          _selectAll = false;
        });
      } else {
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      _showErrorSnackBar('Error sending message: $e');
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Message Sent'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Successfully sent: ${result['sent_count']} emails'),
            if (result['failed_count'] > 0)
              Text('Failed to send: ${result['failed_count']} emails'),
            const SizedBox(height: 8),
            Text(result['message']),
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Message'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showEmailLogs(),
            tooltip: 'Email Logs',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message Input
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Compose Message',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                labelText: 'Message',
                                hintText: 'Enter your message to students...',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 4,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a message';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Recipients Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Select Recipients',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_selectedStudents.length} selected',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Class Filter
                            DropdownButtonFormField<String>(
                              value: _selectedClass,
                              decoration: const InputDecoration(
                                labelText: 'Filter by Class',
                                border: OutlineInputBorder(),
                              ),
                              items: _classes.map((className) {
                                return DropdownMenuItem(
                                  value: className,
                                  child: Text(className),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedClass = value;
                                  _selectedStudents.clear();
                                  _selectAll = false;
                                });
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Select All Checkbox
                            CheckboxListTile(
                              title: Text('Select All (${_filteredStudents.length} students)'),
                              value: _selectAll,
                              onChanged: _toggleSelectAll,
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Students List
                    Expanded(
                      child: Card(
                        child: _filteredStudents.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.email_outlined, size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                      'No students with email addresses found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: _filteredStudents.length,
                                itemBuilder: (context, index) {
                                  final student = _filteredStudents[index];
                                  final isSelected = _selectedStudents.any((s) => s['id'] == student['id']);
                                  
                                  return CheckboxListTile(
                                    title: Text(student['full_name'] ?? 'Unknown'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Email: ${student['email'] ?? 'No email'}'),
                                        Text('Class: ${student['class'] ?? 'No class'}'),
                                      ],
                                    ),
                                    value: isSelected,
                                    onChanged: (value) => _toggleStudentSelection(student),
                                    controlAffinity: ListTileControlAffinity.leading,
                                    isThreeLine: true,
                                  );
                                },
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Send Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSending ? null : _sendMessage,
                        icon: _isSending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        label: Text(_isSending ? 'Sending...' : 'Send Message'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showEmailLogs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmailLogsScreen(),
      ),
    );
  }
}

class EmailLogsScreen extends StatefulWidget {
  const EmailLogsScreen({super.key});

  @override
  State<EmailLogsScreen> createState() => _EmailLogsScreenState();
}

class _EmailLogsScreenState extends State<EmailLogsScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEmailLogs();
  }

  Future<void> _loadEmailLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final logs = await NotificationService.getEmailLogs();
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading logs: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Logs'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No email logs found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadEmailLogs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      final isSuccess = log['status'] == 'success';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSuccess ? Colors.green : Colors.red,
                            child: Icon(
                              isSuccess ? Icons.check : Icons.error,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(log['type'] ?? 'Unknown'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('To: ${log['recipient'] ?? 'Unknown'}'),
                              Text('Sender: ${log['sender'] ?? 'System'}'),
                              Text('Time: ${log['timestamp'] ?? 'Unknown'}'),
                              if (log['message'] != null)
                                Text('Message: ${log['message']}'),
                            ],
                          ),
                          trailing: Icon(
                            isSuccess ? Icons.check_circle : Icons.error_outline,
                            color: isSuccess ? Colors.green : Colors.red,
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
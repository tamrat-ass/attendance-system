import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_colors.dart';
import '../models/student.dart';
import '../services/notification_service.dart';
import '../providers/auth_provider.dart';

class CustomEmailSendScreen extends StatefulWidget {
  const CustomEmailSendScreen({super.key});

  @override
  State<CustomEmailSendScreen> createState() => _CustomEmailSendScreenState();
}

class _CustomEmailSendScreenState extends State<CustomEmailSendScreen>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _subjectController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  
  late TabController _tabController;
  
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _selectedStudents = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _isLoading = false;
  bool _isSending = false;
  bool _selectAll = false;
  String? _selectedClass;
  List<String> _classes = [];
  String _searchQuery = '';
  
  // Email templates
  final List<Map<String, String>> _emailTemplates = [
    {
      'name': 'Welcome Message',
      'subject': 'Welcome to MK Attendance System',
      'body': 'Dear Student,\n\nWelcome to MK Attendance System! We are excited to have you as part of our educational community.\n\nBest regards,\nMK Attendance Team'
    },
    {
      'name': 'Attendance Reminder',
      'subject': 'Attendance Reminder - MK School',
      'body': 'Dear Student,\n\nThis is a friendly reminder about the importance of regular attendance. Please ensure you attend all your classes.\n\nThank you,\nMK School Administration'
    },
    {
      'name': 'Event Announcement',
      'subject': 'Important Event Announcement',
      'body': 'Dear Students,\n\nWe are pleased to announce an upcoming event. Please check the details and mark your calendars.\n\nBest regards,\nMK School Team'
    },
    {
      'name': 'Academic Notice',
      'subject': 'Academic Notice - Important Information',
      'body': 'Dear Student,\n\nPlease find important academic information below. Make sure to read this carefully.\n\nAcademic Office\nMK School'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStudentsAndClasses();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _subjectController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentsAndClasses() async {
    setState(() {
      _isLoading = true;
    });

    try {
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
          _filteredStudents = studentsWithEmail;
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

  void _filterStudents() {
    List<Map<String, dynamic>> filtered = _students;
    
    // Filter by class
    if (_selectedClass != null && _selectedClass != 'All Classes') {
      filtered = filtered.where((student) => 
        student['class']?.toString() == _selectedClass
      ).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((student) {
        final name = student['full_name']?.toString().toLowerCase() ?? '';
        final email = student['email']?.toString().toLowerCase() ?? '';
        final className = student['class']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        
        return name.contains(query) || 
               email.contains(query) || 
               className.contains(query);
      }).toList();
    }
    
    setState(() {
      _filteredStudents = filtered;
      _selectAll = false;
      _selectedStudents.clear();
    });
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

  void _applyTemplate(Map<String, String> template) {
    setState(() {
      _subjectController.text = template['subject'] ?? '';
      _messageController.text = template['body'] ?? '';
    });
    _showSuccessSnackBar('Template applied successfully');
  }

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudents.isEmpty) {
      _showErrorSnackBar('Please select at least one student');
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

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
        _clearForm();
      } else {
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      _showErrorSnackBar('Error sending email: $e');
    }
  }

  void _clearForm() {
    _messageController.clear();
    _subjectController.clear();
    _selectedStudents.clear();
    setState(() {
      _selectAll = false;
    });
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.send, color: Colors.blue),
            SizedBox(width: 8),
            Text('Confirm Send'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to send an email to ${_selectedStudents.length} students.'),
            const SizedBox(height: 8),
            Text('Subject: ${_subjectController.text}'),
            const SizedBox(height: 8),
            const Text('Are you sure you want to proceed?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Email Sent'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text('Successfully sent: ${result['sent_count']} emails'),
                    ],
                  ),
                  if (result['failed_count'] > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Text('Failed to send: ${result['failed_count']} emails'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(result['message']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEmailLogs();
            },
            child: const Text('View Logs'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Custom Email'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showEmailLogs,
            tooltip: 'Email History',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudentsAndClasses,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: 'Compose'),
            Tab(icon: Icon(Icons.people), text: 'Recipients'),
            Tab(icon: Icon(Icons.template_outlined), text: 'Templates'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildComposeTab(),
                _buildRecipientsTab(),
                _buildTemplatesTab(),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedStudents.length} recipients selected',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: _clearForm,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _sendEmail,
                icon: _isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isSending ? 'Sending...' : 'Send Email'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposeTab() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject Field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.subject, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Email Subject',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        hintText: 'Enter email subject...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter email subject';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Message Field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.message, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Email Message',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                      maxLines: 8,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a message';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Tip: Use templates from the Templates tab for quick composition',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Preview Card
            Card(
              color: Colors.blue.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.preview, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Email Preview',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subject: ${_subjectController.text.isEmpty ? 'No subject' : _subjectController.text}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _messageController.text.isEmpty 
                                ? 'No message content' 
                                : _messageController.text,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientsTab() {
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            children: [
              // Search Field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Students',
                  hintText: 'Search by name, email, or class...',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                            _filterStudents();
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _filterStudents();
                },
              ),
              const SizedBox(height: 16),
              
              // Class Filter
              DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Filter by Class',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
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
                  });
                  _filterStudents();
                },
              ),
              const SizedBox(height: 16),
              
              // Select All
              Row(
                children: [
                  Checkbox(
                    value: _selectAll,
                    onChanged: _toggleSelectAll,
                  ),
                  Expanded(
                    child: Text('Select All (${_filteredStudents.length} students)'),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selectedStudents.length} selected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Students List
        Expanded(
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
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = _filteredStudents[index];
                    final isSelected = _selectedStudents.any((s) => s['id'] == student['id']);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        title: Text(
                          student['full_name'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.email, size: 14, color: Colors.blue),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    student['email'] ?? 'No email',
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.class_, size: 14, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(student['class'] ?? 'No class'),
                              ],
                            ),
                          ],
                        ),
                        value: isSelected,
                        onChanged: (value) => _toggleStudentSelection(student),
                        controlAffinity: ListTileControlAffinity.leading,
                        isThreeLine: true,
                        secondary: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: Text(
                            (student['full_name'] ?? '?').substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTemplatesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _emailTemplates.length,
      itemBuilder: (context, index) {
        final template = _emailTemplates[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Icon(
                Icons.template_outlined,
                color: AppColors.primary,
              ),
            ),
            title: Text(
              template['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(template['subject']!),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subject: ${template['subject']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            template['body']!,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: template['body']!));
                            _showSuccessSnackBar('Template copied to clipboard');
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            _applyTemplate(template);
                            _tabController.animateTo(0); // Switch to compose tab
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Use Template'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEmailLogs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EnhancedEmailLogsScreen(),
      ),
    );
  }
}

class EnhancedEmailLogsScreen extends StatefulWidget {
  const EnhancedEmailLogsScreen({super.key});

  @override
  State<EnhancedEmailLogsScreen> createState() => _EnhancedEmailLogsScreenState();
}

class _EnhancedEmailLogsScreenState extends State<EnhancedEmailLogsScreen> {
  List<Map<String, dynamic>> _logs = [];
  List<Map<String, dynamic>> _filteredLogs = [];
  bool _isLoading = false;
  String? _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Success', 'Failed', 'Registration', 'Bulk'];

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
        _filteredLogs = logs;
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

  void _filterLogs(String? filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == null || filter == 'All') {
        _filteredLogs = _logs;
      } else if (filter == 'Success') {
        _filteredLogs = _logs.where((log) => log['status'] == 'success').toList();
      } else if (filter == 'Failed') {
        _filteredLogs = _logs.where((log) => log['status'] == 'failed').toList();
      } else if (filter == 'Registration') {
        _filteredLogs = _logs.where((log) => log['type'] == 'registration').toList();
      } else if (filter == 'Bulk') {
        _filteredLogs = _logs.where((log) => log['type'] == 'bulk').toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmailLogs,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filterOptions.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) => _filterLogs(filter),
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.primary.withOpacity(0.2),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Logs List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredLogs.isEmpty
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
                          itemCount: _filteredLogs.length,
                          itemBuilder: (context, index) {
                            final log = _filteredLogs[index];
                            final isSuccess = log['status'] == 'success';
                            final isRegistration = log['type'] == 'registration';
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isSuccess ? Colors.green : Colors.red,
                                  child: Icon(
                                    isRegistration ? Icons.person_add : Icons.email,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isRegistration ? Colors.blue : Colors.purple,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        log['type']?.toUpperCase() ?? 'UNKNOWN',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        log['recipient'] ?? 'Unknown',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('Sender: ${log['sender'] ?? 'System'}'),
                                    Text('Time: ${log['timestamp'] ?? 'Unknown'}'),
                                    if (log['content'] != null)
                                      Text(
                                        'Message: ${log['content']}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (!isSuccess && log['error_message'] != null)
                                      Text(
                                        'Error: ${log['error_message']}',
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSuccess ? Colors.green : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isSuccess ? 'SUCCESS' : 'FAILED',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  
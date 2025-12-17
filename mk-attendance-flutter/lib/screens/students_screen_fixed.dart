import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_colors.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class StudentsScreenFixed extends StatefulWidget {
  const StudentsScreenFixed({super.key});

  @override
  State<StudentsScreenFixed> createState() => _StudentsScreenFixedState();
}

class _StudentsScreenFixedState extends State<StudentsScreenFixed> {
  String _searchQuery = '';
  String? _selectedClass;
  final TextEditingController _searchController = TextEditingController();
  
  // DIRECT DATABASE VARIABLES - NO PROVIDERS!
  List<Map<String, dynamic>> _realStudents = [];
  List<String> _classes = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRealStudentsDirectly();
  }

  // LOAD STUDENTS DIRECTLY FROM YOUR DATABASE - NO CACHING!
  Future<void> _loadRealStudentsDirectly() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔥 STUDENTS SCREEN: Loading directly from your database...');
      
      // Call YOUR database directly
      final response = await http.get(
        Uri.parse('https://mk-attendance.vercel.app/api/students'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🔥 STUDENTS SCREEN: Response ${response.statusCode}');
      print('🔥 STUDENTS SCREEN: Found ${response.body.length} chars of data');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final students = List<Map<String, dynamic>>.from(data['data'] ?? []);
        
        // Extract unique classes
        final uniqueClasses = <String>{};
        for (final student in students) {
          if (student['class'] != null && student['class'].toString().isNotEmpty) {
            uniqueClasses.add(student['class'].toString());
          }
        }
        
        print('🔥 STUDENTS SCREEN: Loaded ${students.length} students, ${uniqueClasses.length} classes');
        
        setState(() {
          _realStudents = students;
          _classes = uniqueClasses.toList()..sort();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔥 STUDENTS SCREEN ERROR: $e');
      setState(() {
        _error = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddEditStudentDialog(),
    ).then((_) => _loadRealStudentsDirectly()); // Refresh after dialog closes
  }

  void _showEditStudentDialog(Map<String, dynamic> studentData) {
    final student = Student(
      id: studentData['id'],
      fullName: studentData['full_name'] ?? '',
      phone: studentData['phone'] ?? '',
      className: studentData['class'] ?? '',
      gender: studentData['gender'] ?? 'Male',
    );
    
    showDialog(
      context: context,
      builder: (context) => AddEditStudentDialog(student: student),
    ).then((_) => _loadRealStudentsDirectly()); // Refresh after dialog closes
  }

  void _showDeleteConfirmation(Map<String, dynamic> studentData) {
    final name = studentData['full_name'] ?? 'Unknown';
    final id = studentData['id'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteStudent(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStudent(int id) async {
    try {
      final apiService = ApiService();
      final success = await apiService.deleteStudent(id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadRealStudentsDirectly(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete student'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStudentsList() {
    List<Map<String, dynamic>> filteredStudents = _realStudents;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredStudents = _realStudents.where((student) {
        final name = student['full_name']?.toString().toLowerCase() ?? '';
        final phone = student['phone']?.toString() ?? '';
        final id = student['id']?.toString() ?? '';
        final query = _searchQuery.toLowerCase();
        
        return name.contains(query) || phone.contains(query) || id.contains(query);
      }).toList();
    }
    
    // Apply class filter
    if (_selectedClass != null) {
      filteredStudents = filteredStudents.where((student) => 
        student['class']?.toString() == _selectedClass
      ).toList();
    }
    
    if (filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedClass != null
                  ? 'No students found'
                  : 'No students added yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddStudentDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add First Student'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadRealStudentsDirectly,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: filteredStudents.length,
        itemBuilder: (context, index) {
          final student = filteredStudents[index];
          final name = student['full_name']?.toString() ?? 'Unknown';
          final phone = student['phone']?.toString() ?? 'No phone';
          final className = student['class']?.toString() ?? 'No class';
          final gender = student['gender']?.toString() ?? '';
          final id = student['id']?.toString() ?? '';
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryWithOpacity(0.2),
                child: Text(
                  name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: $id'),
                  Text('Phone: $phone'),
                  Text('Class: $className'),
                  if (gender.isNotEmpty) Text('Gender: $gender'),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditStudentDialog(student);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(student);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students '),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryWithOpacity(0.1),
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                children: [
                  // Search Field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Students',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Class Filter
                  DropdownButtonFormField<String>(
                    value: _selectedClass,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Class',
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
                ],
              ),
            ),
            
            // Students List
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
                                onPressed: _loadRealStudentsDirectly,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _buildStudentsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddEditStudentDialog extends StatefulWidget {
  final Student? student;
  
  const AddEditStudentDialog({super.key, this.student});

  @override
  State<AddEditStudentDialog> createState() => _AddEditStudentDialogState();
}

class _AddEditStudentDialogState extends State<AddEditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String? _selectedClass;
  String _selectedGender = 'Male';
  bool _isLoading = false;

  // Common Ethiopian classes
  final List<String> _commonClasses = [
    'ዋናው መአከል',
    'አዲስ አበባ ማእከል',
    'ምስራቅ ማስተባበሪያ',
    'ምዕራብ ማስተባበሪያ',
    'ደቡብ ማስተባበሪያ',
    'ሰሜን ማስተባበሪያ',
    'ልዩ ልዩ',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.fullName ?? '');
    _phoneController = TextEditingController(text: widget.student?.phone ?? '');
    _selectedClass = widget.student?.className;
    _selectedGender = widget.student?.gender ?? 'Male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final student = Student(
        id: widget.student?.id,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        className: _selectedClass ?? '',
        gender: _selectedGender,
      );

      bool success;
      if (widget.student == null) {
        await apiService.createStudent(student);
        success = true;
      } else {
        await apiService.updateStudent(student.id!, student);
        success = true;
      }

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.student == null 
                  ? 'Student added successfully' 
                  : 'Student updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  hintText: '09xxxxxxxx',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (!RegExp(r'^09\d{8}$').hasMatch(value.trim())) {
                    return 'Phone must be 10 digits starting with 09';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select Class'),
                items: _commonClasses.map((className) {
                  return DropdownMenuItem(
                    value: className,
                    child: Text(className),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClass = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a class';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                items: ['Male', 'Female'].map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveStudent,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.student == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
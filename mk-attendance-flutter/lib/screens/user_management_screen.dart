import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_colors.dart';
import '../models/user.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔥 USER MANAGEMENT: Loading users from database...');
      
      final response = await http.get(
        Uri.parse('https://mk-attendance.vercel.app/api/admin/users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🔥 USER MANAGEMENT: Response ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final users = List<Map<String, dynamic>>.from(data['data'] ?? []);
          
          print('🔥 USER MANAGEMENT: Loaded ${users.length} users');
          
          setState(() {
            _users = users;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'Failed to load users';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔥 USER MANAGEMENT ERROR: $e');
      setState(() {
        _error = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('https://mk-attendance.vercel.app/api/admin/users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _showSuccessMessage('User created successfully');
          _loadUsers(); // Refresh the list
        } else {
          _showErrorMessage(data['message'] ?? 'Failed to create user');
        }
      } else {
        _showErrorMessage('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorMessage('Connection error: $e');
    }
  }

  Future<void> _updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('https://mk-attendance.vercel.app/api/admin/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _showSuccessMessage('User updated successfully');
          _loadUsers(); // Refresh the list
        } else {
          _showErrorMessage(data['message'] ?? 'Failed to update user');
        }
      } else {
        _showErrorMessage('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorMessage('Connection error: $e');
    }
  }

  Future<void> _deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://mk-attendance.vercel.app/api/admin/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _showSuccessMessage('User deleted successfully');
        _loadUsers(); // Refresh the list
      } else {
        _showErrorMessage('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorMessage('Connection error: $e');
    }
  }

  Future<void> _resetUserPassword(int userId) async {
    try {
      // Generate a new password (you can make this more sophisticated)
      final newPassword = 'MK${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      
      final response = await http.post(
        Uri.parse('https://mk-attendance.vercel.app/api/admin/users/$userId/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _showSuccessMessage('Password reset successfully. New password: $newPassword');
        } else {
          _showErrorMessage(data['message'] ?? 'Failed to reset password');
        }
      } else {
        final data = jsonDecode(response.body);
        _showErrorMessage(data['message'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorMessage('Connection error: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditUserDialog(
        onSave: _createUser,
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AddEditUserDialog(
        user: user,
        onSave: (userData) => _updateUser(user['id'], userData),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['full_name'] ?? user['username']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user['id']);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordConfirmation(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text('Are you sure you want to reset the password for ${user['full_name'] ?? user['username']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetUserPassword(user['id']);
            },
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    
    return _users.where((user) {
      final name = user['full_name']?.toString().toLowerCase() ?? '';
      final username = user['username']?.toString().toLowerCase() ?? '';
      final email = user['email']?.toString().toLowerCase() ?? '';
      final role = user['role']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      
      return name.contains(query) || 
             username.contains(query) || 
             email.contains(query) || 
             role.contains(query);
    }).toList();
  }

  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryWithOpacity(0.1),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Users',
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
          ),

          // Users List
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
                              onPressed: _loadUsers,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty ? 'No users found' : 'No users available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _showAddUserDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add First User'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadUsers,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                final role = user['role']?.toString() ?? 'user';
                                final status = user['status']?.toString() ?? 'active';
                                
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getRoleColor(role).withOpacity(0.2),
                                      child: Text(
                                        (user['full_name']?.toString() ?? user['username']?.toString() ?? '?')
                                            .substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          color: _getRoleColor(role),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      user['full_name']?.toString() ?? 'No Name',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Username: ${user['username'] ?? 'N/A'}'),
                                        Text('Email: ${user['email'] ?? 'N/A'}'),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getRoleColor(role),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                role.toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: status == 'active' ? Colors.green : Colors.grey,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                status.toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'edit':
                                            _showEditUserDialog(user);
                                            break;
                                          case 'reset_password':
                                            _showResetPasswordConfirmation(user);
                                            break;
                                          case 'delete':
                                            _showDeleteConfirmation(user);
                                            break;
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
                                          value: 'reset_password',
                                          child: Row(
                                            children: [
                                              Icon(Icons.lock_reset, color: Colors.orange),
                                              SizedBox(width: 8),
                                              Text('Reset Password'),
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
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddEditUserDialog extends StatefulWidget {
  final Map<String, dynamic>? user;
  final Function(Map<String, dynamic>) onSave;

  const AddEditUserDialog({
    super.key,
    this.user,
    required this.onSave,
  });

  @override
  State<AddEditUserDialog> createState() => _AddEditUserDialogState();
}

class _AddEditUserDialogState extends State<AddEditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _fullNameController;
  late TextEditingController _passwordController;
  String _selectedRole = 'user';
  String _selectedStatus = 'active';
  bool _isLoading = false;

  // Permission controllers
  bool _canManageStudents = true;
  bool _canAddStudent = true;
  bool _canUploadStudents = false;
  bool _canDeleteStudent = false;
  bool _canMarkAttendance = true;
  bool _canViewReports = false;
  bool _canExportData = false;
  bool _canManageUsers = false;
  bool _canDeleteUser = false;
  bool _canManagePasswords = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?['username'] ?? '');
    _emailController = TextEditingController(text: widget.user?['email'] ?? '');
    _fullNameController = TextEditingController(text: widget.user?['full_name'] ?? '');
    _passwordController = TextEditingController();
    
    if (widget.user != null) {
      _selectedRole = widget.user!['role'] ?? 'user';
      _selectedStatus = widget.user!['status'] ?? 'active';
      
      // Load permissions
      _canManageStudents = widget.user!['can_manage_students'] ?? true;
      _canAddStudent = widget.user!['can_add_student'] ?? true;
      _canUploadStudents = widget.user!['can_upload_students'] ?? false;
      _canDeleteStudent = widget.user!['can_delete_student'] ?? false;
      _canMarkAttendance = widget.user!['can_mark_attendance'] ?? true;
      _canViewReports = widget.user!['can_view_reports'] ?? false;
      _canExportData = widget.user!['can_export_data'] ?? false;
      _canManageUsers = widget.user!['can_manage_users'] ?? false;
      _canDeleteUser = widget.user!['can_delete_user'] ?? false;
      _canManagePasswords = widget.user!['can_manage_passwords'] ?? false;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setRolePermissions(String role) {
    setState(() {
      switch (role) {
        case 'admin':
          _canManageStudents = true;
          _canAddStudent = true;
          _canUploadStudents = true;
          _canDeleteStudent = true;
          _canMarkAttendance = true;
          _canViewReports = true;
          _canExportData = true;
          _canManageUsers = true;
          _canDeleteUser = true;
          _canManagePasswords = true;
          break;
        case 'manager':
          _canManageStudents = true;
          _canAddStudent = true;
          _canUploadStudents = true;
          _canDeleteStudent = false;
          _canMarkAttendance = true;
          _canViewReports = true;
          _canExportData = true;
          _canManageUsers = false;
          _canDeleteUser = false;
          _canManagePasswords = false;
          break;
        default: // user
          _canManageStudents = false;
          _canAddStudent = true;
          _canUploadStudents = false;
          _canDeleteStudent = false;
          _canMarkAttendance = true;
          _canViewReports = false;
          _canExportData = false;
          _canManageUsers = false;
          _canDeleteUser = false;
          _canManagePasswords = false;
          break;
      }
    });
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final userData = {
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'full_name': _fullNameController.text.trim(),
      'role': _selectedRole,
      'status': _selectedStatus,
      'can_manage_students': _canManageStudents,
      'can_add_student': _canAddStudent,
      'can_upload_students': _canUploadStudents,
      'can_delete_student': _canDeleteStudent,
      'can_mark_attendance': _canMarkAttendance,
      'can_view_reports': _canViewReports,
      'can_export_data': _canExportData,
      'can_manage_users': _canManageUsers,
      'can_delete_user': _canDeleteUser,
      'can_manage_passwords': _canManagePasswords,
    };

    // Add password only for new users or if password is provided
    if (widget.user == null || _passwordController.text.isNotEmpty) {
      userData['password'] = _passwordController.text;
    }

    try {
      await widget.onSave(userData);
      Navigator.pop(context);
    } catch (e) {
      // Error handling is done in the parent widget
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Add User' : 'Edit User'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Basic Information
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: widget.user == null ? 'Password' : 'New Password (leave empty to keep current)',
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (widget.user == null && (value == null || value.trim().isEmpty)) {
                      return 'Please enter password';
                    }
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Role Selection
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(value: 'manager', child: Text('Manager')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                      _setRolePermissions(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Status Selection
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Permissions Section
                const Text(
                  'Permissions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                CheckboxListTile(
                  title: const Text('Can Manage Students'),
                  value: _canManageStudents,
                  onChanged: (value) => setState(() => _canManageStudents = value!),
                ),
                CheckboxListTile(
                  title: const Text('Can Add Student'),
                  value: _canAddStudent,
                  onChanged: (value) => setState(() => _canAddStudent = value!),
                ),
                CheckboxListTile(
                  title: const Text('Can Upload Students'),
                  value: _canUploadStudents,
                  onChanged: (value) => setState(() => _canUploadStudents = value!),
                ),
                CheckboxListTile(
                  title: const Text('Can Delete Student'),
                  value: _canDeleteStudent,
                  onChanged: (value) => setState(() => _canDeleteStudent = value!),
                ),
                CheckboxListTile(
                  title: const Text('Can Mark Attendance'),
                  value: _canMarkAttendance,
                  onChanged: (value) => setState(() => _canMarkAttendance = value!),
                ),
                CheckboxListTile(
                  title: const Text('Can View Reports'),
                  value: _canViewReports,
                  onChanged: (value) => setState(() => _canViewReports = value!),
                ),
                CheckboxListTile(
                  title: const Text('Can Export Data'),
                  value: _canExportData,
                  onChanged: (value) => setState(() => _canExportData = value!),
                ),
                CheckboxListTile(
                  title: const Text('Can Manage Users'),
                  value: _canManageUsers,
                  onChanged: (value) => setState(() => _canManageUsers = value!),
                ),
                CheckboxListTile(
                  title: const Text('Can Delete User'),
                  value: _canDeleteUser,
                  onChanged: (value) => setState(() => _canDeleteUser = value!),
                ),
                CheckboxListTile(
                  title: const Text('Can Manage Passwords'),
                  value: _canManagePasswords,
                  onChanged: (value) => setState(() => _canManagePasswords = value!),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveUser,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.user == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}
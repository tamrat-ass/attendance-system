import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/student_provider.dart';

import '../widgets/status_card.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    await studentProvider.loadStudents();
    await studentProvider.loadClasses(); // Load classes from database
    await _loadAdminStats();
  }

  Map<String, dynamic> _adminStats = {};

  Future<void> _loadAdminStats() async {
    try {
      final apiService = ApiService();
      final stats = await apiService.getAdminStats();
      setState(() {
        _adminStats = stats;
      });
    } catch (e) {
      // Handle error silently, use fallback data
    }
  }

  Future<void> _exportAllData() async {
    try {
      NotificationService.showInfo(context, 'Preparing export...');
      
      final apiService = ApiService();
      final result = await apiService.performAdminAction('export_all');
      
      if (result['success'] == true) {
        NotificationService.showSuccess(context, 'All data exported successfully');
      } else {
        NotificationService.showError(context, result['message'] ?? 'Export failed');
      }
    } catch (e) {
      NotificationService.showError(context, 'Export failed: $e');
    }
  }

  Future<void> _syncData() async {
    try {
      NotificationService.showInfo(context, 'Syncing with server...');
      
      final apiService = ApiService();
      final result = await apiService.performAdminAction('sync_data');
      
      if (result['success'] == true) {
        // Also refresh local data
        final studentProvider = Provider.of<StudentProvider>(context, listen: false);
        await studentProvider.loadStudents();
        await _loadAdminStats();
        
        NotificationService.showSuccess(context, 'Data synced successfully');
      } else {
        NotificationService.showError(context, result['message'] ?? 'Sync failed');
      }
    } catch (e) {
      NotificationService.showError(context, 'Sync failed: $e');
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await NotificationService.showConfirmDialog(
      context,
      title: 'Clear Cache',
      message: 'This will clear all cached data. Are you sure?',
      confirmText: 'Clear',
      confirmColor: Colors.orange,
    );

    if (confirmed == true) {
      try {
        final apiService = ApiService();
        final result = await apiService.performAdminAction('clear_cache');
        
        if (result['success'] == true) {
          NotificationService.showSuccess(context, 'Cache cleared successfully');
        } else {
          NotificationService.showError(context, result['message'] ?? 'Failed to clear cache');
        }
      } catch (e) {
        NotificationService.showError(context, 'Failed to clear cache: $e');
      }
    }
  }

  Future<void> _showClassManagement() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final classes = List<String>.from(studentProvider.classes);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Manage Classes'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                // Info message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Classes are automatically created from student records',
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Class list
                Expanded(
                  child: ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final className = classes[index];
                      final studentCount = studentProvider.students
                          .where((s) => s.className == className)
                          .length;
                      
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.class_),
                          title: Text(className),
                          subtitle: Text('$studentCount students'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  final controller = TextEditingController(text: className);
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Edit Class'),
                                      content: TextField(
                                        controller: controller,
                                        decoration: const InputDecoration(
                                          labelText: 'Class Name',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            final newName = controller.text.trim();
                                            if (newName.isNotEmpty && newName != className) {
                                              setState(() {
                                                classes[index] = newName;
                                              });
                                              studentProvider.updateClassName(className, newName);
                                              Navigator.pop(context);
                                              NotificationService.showSuccess(context, 'Class updated successfully');
                                            }
                                          },
                                          child: const Text('Update'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit),
                                tooltip: 'Edit Class',
                              ),
                              IconButton(
                                onPressed: studentCount > 0 ? null : () async {
                                  final confirmed = await NotificationService.showConfirmDialog(
                                    context,
                                    title: 'Delete Class',
                                    message: 'Are you sure you want to delete "$className"?',
                                    confirmText: 'Delete',
                                    confirmColor: Colors.red,
                                  );
                                  
                                  if (confirmed == true) {
                                    setState(() {
                                      classes.removeAt(index);
                                    });
                                    studentProvider.deleteClass(className);
                                    NotificationService.showSuccess(context, 'Class deleted successfully');
                                  }
                                },
                                icon: const Icon(Icons.delete),
                                tooltip: studentCount > 0 ? 'Cannot delete class with students' : 'Delete Class',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangePassword() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureCurrentPassword = !obscureCurrentPassword;
                        });
                      },
                      icon: Icon(
                        obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureNewPassword = !obscureNewPassword;
                        });
                      },
                      icon: Icon(
                        obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final currentPassword = currentPasswordController.text.trim();
                final newPassword = newPasswordController.text.trim();
                final confirmPassword = confirmPasswordController.text.trim();

                if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                  NotificationService.showError(context, 'Please fill all fields');
                  return;
                }

                if (newPassword != confirmPassword) {
                  NotificationService.showError(context, 'New passwords do not match');
                  return;
                }

                if (newPassword.length < 6) {
                  NotificationService.showError(context, 'Password must be at least 6 characters');
                  return;
                }

                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.changePassword(currentPassword, newPassword);
                  
                  Navigator.pop(context);
                  NotificationService.showSuccess(context, 'Password changed successfully');
                } catch (e) {
                  NotificationService.showError(context, 'Failed to change password: $e');
                }
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System Overview
            Text(
              'System Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Consumer<StudentProvider>(
              builder: (context, studentProvider, child) {
                final totalStudents = studentProvider.students.length;
                final totalClasses = studentProvider.classes.length;
                
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    StatusCard(
                      title: 'Total Students',
                      value: totalStudents.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    StatusCard(
                      title: 'Total Classes',
                      value: totalClasses.toString(),
                      icon: Icons.class_,
                      color: Colors.green,
                    ),
                    const StatusCard(
                      title: 'Active Users',
                      value: '1', // Current user
                      icon: Icons.person,
                      color: Colors.orange,
                    ),
                    const StatusCard(
                      title: 'System Status',
                      value: 'Online',
                      icon: Icons.cloud_done,
                      color: Colors.purple,
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Admin Actions
            Text(
              'Admin Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildActionCard(
              title: 'Export All Data',
              subtitle: 'Export complete system data to CSV',
              icon: Icons.download,
              color: Colors.blue,
              onTap: _exportAllData,
            ),
            
            _buildActionCard(
              title: 'Sync Data',
              subtitle: 'Synchronize with web application',
              icon: Icons.sync,
              color: Colors.green,
              onTap: _syncData,
            ),
            
            _buildActionCard(
              title: 'Clear Cache',
              subtitle: 'Clear all cached data',
              icon: Icons.clear_all,
              color: Colors.orange,
              onTap: _clearCache,
            ),
            
            _buildActionCard(
              title: 'Manage Classes',
              subtitle: 'Add, edit, or delete classes',
              icon: Icons.class_,
              color: Colors.indigo,
              onTap: () => _showClassManagement(),
            ),
            
            _buildActionCard(
              title: 'Change Password',
              subtitle: 'Update your account password',
              icon: Icons.lock,
              color: Colors.red,
              onTap: () => _showChangePassword(),
            ),
            
            _buildActionCard(
              title: 'System Settings',
              subtitle: 'Configure app settings',
              icon: Icons.settings,
              color: Colors.purple,
              onTap: () {
                NotificationService.showInfo(context, 'Settings coming soon');
              },
            ),
            
            const SizedBox(height: 32),
            
            // User Information
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current User',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        _buildInfoRow('Name', user?.fullName ?? 'Unknown'),
                        _buildInfoRow('Username', user?.username ?? 'Unknown'),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          'Permissions',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (user?.canMarkAttendance == true)
                              _buildPermissionChip('Mark Attendance', Colors.green),
                            if (user?.canManageStudents == true)
                              _buildPermissionChip('Manage Students', Colors.blue),
                            if (user?.canViewReports == true)
                              _buildPermissionChip('View Reports', Colors.orange),
                            if (user?.canExportData == true)
                              _buildPermissionChip('Export Data', Colors.purple),
                            if (user?.canManageUsers == true)
                              _buildPermissionChip('Manage Users', Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
    );
  }
}
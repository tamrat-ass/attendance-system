import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../widgets/loading_overlay.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  bool _autoSync = true;
  bool _offlineMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Processing...',
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // App Information
            _buildSectionHeader('App Information'),
            _buildInfoCard(),
            const SizedBox(height: 24),

            // General Settings
            _buildSectionHeader('General Settings'),
            _buildGeneralSettings(),
            const SizedBox(height: 24),
            // Data Management (Admin and Manager only)
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;
                if (user?.isAdmin == true || user?.role == 'manager') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Data Management'),
                      _buildDataManagement(),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const SizedBox.shrink(); // Hide for regular users
              },
            ),
            const SizedBox(height: 24),

            // Account Settings
            _buildSectionHeader('Account'),
            _buildAccountSettings(),
            const SizedBox(height: 24),

            // About
            _buildSectionHeader('About'),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppConstants.appDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Version',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Text(
                  AppConstants.appVersion,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      child: Column(
        children: [

          SwitchListTile(
            title: const Text('Auto Sync'),
            subtitle: const Text('Automatically sync data when online'),
            value: _autoSync,
            onChanged: (value) {
              setState(() {
                _autoSync = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Offline Mode'),
            subtitle: const Text('Work offline when no internet'),
            value: _offlineMode,
            onChanged: (value) {
              setState(() {
                _offlineMode = value;
              });
            },
          ),
          const Divider(height: 1),
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return ListTile(
                title: const Text('Theme'),
                subtitle: Text('Current: ${themeService.themeString}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showThemeSelector(themeService),
              );
            },
          ),

        ],
      ),
    );
  }

  Widget _buildDataManagement() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.backup, color: Colors.blue),
            title: const Text('Create Backup'),
            subtitle: const Text('Backup all app data'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _createBackup,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.green),
            title: const Text('Restore Data'),
            subtitle: const Text('Restore from backup file'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showRestoreOptions,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.sync, color: Colors.orange),
            title: const Text('Sync Now'),
            subtitle: const Text('Force sync with server'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _forceSyncData,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.clear_all, color: AppColors.primary),
            title: const Text('Clear Cache'),
            subtitle: const Text('Clear all cached data'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _clearCache,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(user?.fullName ?? 'Unknown User'),
                subtitle: Text(user?.username ?? 'No username'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock, color: Colors.blue),
                title: const Text('Change Password'),
                subtitle: const Text('Update your password'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showChangePassword,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.primary),
                title: const Text('Logout'),
                subtitle: const Text('Sign out of your account'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showLogoutConfirmation,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text('About MK Attendance'),
            subtitle: const Text('Learn more about this app'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showAboutDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.web, color: Colors.green),
            title: const Text('Web Version'),
            subtitle: const Text('Open web application'),
            trailing: const Icon(Icons.open_in_new),
            onTap: _openWebVersion,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.orange),
            title: const Text('Help & Support'),
            subtitle: const Text('Get help using the app'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showHelpDialog,
          ),
        ],
      ),
    );
  }

  void _showThemeSelector(ThemeService themeService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: themeService.themeMode,
              onChanged: (value) {
                themeService.setTheme(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: themeService.themeMode,
              onChanged: (value) {
                themeService.setTheme(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: themeService.themeMode,
              onChanged: (value) {
                themeService.setTheme(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await BackupService.shareBackup();
      if (success) {
        NotificationService.showSuccess(context, 'Backup created and shared successfully');
      } else {
        NotificationService.showError(context, 'Failed to create backup');
      }
    } catch (e) {
      NotificationService.showError(context, 'Backup failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showRestoreOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose how to restore your data:'),
            SizedBox(height: 16),
            Text('⚠️ Warning: This will replace all current data!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restoreFromFile();
            },
            child: const Text('Choose File'),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreFromFile() async {
    final confirmed = await NotificationService.showConfirmDialog(
      context,
      title: 'Confirm Restore',
      message: 'Place your backup file as "restore_backup.json" in Documents folder, then continue.',
      confirmText: 'Restore',
      confirmColor: Colors.orange,
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await BackupService.restoreFromFile();
        if (success) {
          NotificationService.showSuccess(context, 'Data restored successfully');
        } else {
          NotificationService.showError(context, 'No restore file found or restore failed');
        }
      } catch (e) {
        NotificationService.showError(context, 'Restore failed: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _forceSyncData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await BackupService.syncWithServer();
      if (success) {
        NotificationService.showSuccess(context, 'Data synchronized successfully');
      } else {
        NotificationService.showError(context, 'Failed to sync with server');
      }
    } catch (e) {
      NotificationService.showError(context, 'Sync failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await BackupService.clearCache();
        if (success) {
          NotificationService.showSuccess(context, 'Cache cleared successfully');
        } else {
          NotificationService.showError(context, 'Failed to clear cache');
        }
      } catch (e) {
        NotificationService.showError(context, 'Failed to clear cache: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showChangePassword() {
    showDialog(
      context: context,
      builder: (context) => _ChangePasswordDialog(),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About MK Attendance'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MK Attendance Management System'),
            SizedBox(height: 8),
            Text('A comprehensive attendance tracking solution for MK member management.'),
            SizedBox(height: 16),
            Text('Features:'),
            Text('• Mark attendance with Ethiopian calendar'),
            Text('• Manage students and classes'),
            Text('• Generate detailed reports'),
            Text('• Export data to CSV'),
            Text('• Offline capability'),
            Text('• Real-time sync with web app'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _openWebVersion() async {
    const webUrl = 'https://mk-attendance.vercel.app'; // Your web app URL
    try {
      final Uri url = Uri.parse(webUrl);
      await launchUrl(
        url, 
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
      NotificationService.showSuccess(context, 'Opening web version...');
    } catch (e) {
      NotificationService.showError(context, 'Error opening web version: $e');
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Getting Started:'),
            Text('1. Login with your credentials'),
            Text('2. Select a class and date'),
            Text('3. Mark attendance for students'),
            Text('4. Save your changes'),
            SizedBox(height: 16),
            Text('Features:'),
            Text('• Attendance: Mark student attendance'),
            Text('• Students: Manage student records'),
            Text('• Reports: View and export reports'),
            Text('• Admin: System administration'),
            SizedBox(height: 16),
            Text('Need more help?'),
            Text('Contact your system administrator.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (success) {
        Navigator.pop(context);
        NotificationService.showSuccess(context, 'Password changed successfully');
      } else {
        NotificationService.showError(
          context, 
          authProvider.errorMessage ?? 'Failed to change password'
        );
      }
    } catch (e) {
      NotificationService.showError(context, 'Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current Password
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showCurrentPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _showCurrentPassword = !_showCurrentPassword;
                      });
                    },
                  ),
                ),
                obscureText: !_showCurrentPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Current password is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // New Password
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showNewPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _showNewPassword = !_showNewPassword;
                      });
                    },
                  ),
                ),
                obscureText: !_showNewPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'New password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: !_showConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
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
          onPressed: _isLoading ? null : _changePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Change Password'),
        ),
      ],
    );
  }
}
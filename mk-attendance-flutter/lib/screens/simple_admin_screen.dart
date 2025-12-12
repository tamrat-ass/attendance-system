import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class SimpleAdminScreen extends StatefulWidget {
  const SimpleAdminScreen({super.key});

  @override
  State<SimpleAdminScreen> createState() => _SimpleAdminScreenState();
}

class _SimpleAdminScreenState extends State<SimpleAdminScreen> {
  Map<String, dynamic> _adminStats = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAdminStats();
  }

  Future<void> _loadAdminStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final stats = await apiService.getAdminStats();
      setState(() {
        _adminStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Use fallback data
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      setState(() {
        _adminStats = {
          'totals': {
            'students': studentProvider.students.length,
            'classes': studentProvider.classes.length,
            'users': 1,
            'attendance_records': 0,
          }
        };
      });
    }
  }

  Future<void> _performAction(String action, String actionName) async {
    try {
      NotificationService.showInfo(context, 'Performing $actionName...');
      
      final apiService = ApiService();
      final result = await apiService.performAdminAction(action);
      
      if (result['success'] == true) {
        NotificationService.showSuccess(context, '$actionName completed successfully');
      } else {
        NotificationService.showError(context, result['message'] ?? '$actionName failed');
      }
    } catch (e) {
      NotificationService.showError(context, '$actionName failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Panel',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B4513),
              ),
            ),
            const SizedBox(height: 20),
            
            // Statistics Cards
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildStatisticsCards(),
            
            const SizedBox(height: 30),
            
            // Admin Actions
            const Text(
              'Admin Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildActionButton(
              'Export All Data',
              'Export complete system data',
              Icons.download,
              AppColors.primary,
              () => _performAction('export_all', 'Export'),
            ),
            
            _buildActionButton(
              'Sync Data',
              'Synchronize with server',
              Icons.sync,
              Colors.green,
              () => _performAction('sync_data', 'Sync'),
            ),
            
            _buildActionButton(
              'Clear Cache',
              'Clear all cached data',
              Icons.clear_all,
              Colors.orange,
              () => _performAction('clear_cache', 'Clear Cache'),
            ),
            
            _buildActionButton(
              'Refresh Stats',
              'Reload admin statistics',
              Icons.refresh,
              Colors.purple,
              _loadAdminStats,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final totals = _adminStats['totals'] ?? {};
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('Students', '${totals['students'] ?? 0}', Icons.people, AppColors.primary),
        _buildStatCard('Classes', '${totals['classes'] ?? 0}', Icons.class_, Colors.green),
        _buildStatCard('Users', '${totals['users'] ?? 0}', Icons.person, Colors.orange),
        _buildStatCard('Records', '${totals['attendance_records'] ?? 0}', Icons.assignment, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
}
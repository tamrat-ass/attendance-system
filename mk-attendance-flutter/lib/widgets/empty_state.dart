import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_colors.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: iconColor ?? Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Predefined empty states for common scenarios
class EmptyStates {
  static Widget noStudents({VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.people_outline,
      title: 'No Students Found',
      message: 'No students have been added yet.\nAdd your first student to get started.',
      actionText: 'Add Student',
      onAction: onAdd,
      iconColor: AppColors.primary,
    );
  }

  static Widget noAttendance() {
    return const EmptyState(
      icon: Icons.event_busy,
      title: 'No Attendance Records',
      message: 'No attendance has been marked for this date and class.\nSelect a date and class to mark attendance.',
      iconColor: Colors.orange,
    );
  }

  static Widget noReports() {
    return const EmptyState(
      icon: Icons.bar_chart,
      title: 'No Report Data',
      message: 'No attendance data found for the selected period.\nTry selecting a different date range or class.',
      iconColor: Colors.purple,
    );
  }

  static Widget noSearchResults(String query) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: 'No results found for "$query".\nTry adjusting your search terms.',
      iconColor: Colors.grey,
    );
  }

  static Widget noInternetConnection({VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again.\nSome features may work offline.',
      actionText: 'Retry',
      onAction: onRetry,
      iconColor: AppColors.primary,
    );
  }

  static Widget serverError({VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Server Error',
      message: 'Unable to connect to the server.\nPlease try again later.',
      actionText: 'Retry',
      onAction: onRetry,
      iconColor: AppColors.primary,
    );
  }

  static Widget noPermission() {
    return const EmptyState(
      icon: Icons.lock_outline,
      title: 'Access Denied',
      message: 'You don\'t have permission to access this feature.\nContact your administrator for access.',
      iconColor: Colors.orange,
    );
  }
}
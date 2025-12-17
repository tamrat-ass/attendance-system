import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;
  final Color? iconColor;
  final IconData? icon;

  const ErrorDialog({
    Key? key,
    this.title = 'Error',
    required this.message,
    this.onClose,
    this.iconColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconColor ?? const Color(0xFFF44336), // Red color for errors
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onClose != null) onClose!();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // System primary color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Static method to show offline dialog (yellow warning)
  static void showOffline(BuildContext context, {VoidCallback? onClose}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        title: 'Sorry',
        message: 'Sorry please, turn on your mobile data associated with your MK attendance',
        iconColor: const Color(0xFFFFC107), // Yellow/Amber color
        icon: Icons.warning,
        onClose: onClose,
      ),
    );
  }

  // Static method to show wrong username dialog (red error)
  static void showWrongUsername(BuildContext context, {VoidCallback? onClose}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        title: 'Invalid Username',
        message: 'You entered wrong username',
        iconColor: const Color(0xFFF44336), // Red color
        icon: Icons.person_off,
        onClose: onClose,
      ),
    );
  }

  // Static method to show wrong password dialog (red error)
  static void showWrongPassword(BuildContext context, {VoidCallback? onClose}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        title: 'Invalid Password',
        message: 'You entered wrong password',
        iconColor: const Color(0xFFF44336), // Red color
        icon: Icons.lock_outline,
        onClose: onClose,
      ),
    );
  }

  // Static method to show generic error dialog
  static void showGeneric(BuildContext context, String message, {String? title, VoidCallback? onClose}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        title: title ?? 'Error',
        message: message,
        onClose: onClose,
      ),
    );
  }
}
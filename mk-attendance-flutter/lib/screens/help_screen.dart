import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Version Info Card
            _buildInfoCard(
              context,
              'App Information',
              [
                _buildInfoRow('Version', '4.1.0'),
                _buildInfoRow('Release Date', 'December 18, 2024'),
                _buildInfoRow('Build', 'Production Release'),
              ],
              Icons.info_outline,
              Colors.blue,
              isDark,
            ),
            
            const SizedBox(height: 16),
            
            // Quick Start Guide
            _buildInfoCard(
              context,
              'Quick Start Guide',
              [
                _buildGuideStep('1. Login', 'Enter your username and password to access the system'),
                _buildGuideStep('2. Select Class', 'Choose the class from the dropdown in Attendance tab'),
                _buildGuideStep('3. Mark Attendance', 'Tap Present/Absent/Permission for each student'),
                _buildGuideStep('4. Save', 'Tap "Save Attendance" to record the data'),
              ],
              Icons.play_circle_outline,
              Colors.green,
              isDark,
            ),
            
            const SizedBox(height: 16),
            
            // Features Overview
            _buildInfoCard(
              context,
              'Key Features',
              [
                _buildFeatureItem('✅ Mark Attendance', 'Record student attendance quickly'),
                _buildFeatureItem('📱 QR Scanner', 'Scan student QR codes for instant marking'),
                _buildFeatureItem('👥 Student Management', 'View and search student records'),
                _buildFeatureItem('📊 Reports', 'View attendance summaries and statistics'),
                _buildFeatureItem('🎨 Themes', 'Switch between light and dark modes'),
              ],
              Icons.star_outline,
              Colors.orange,
              isDark,
            ),
            
            const SizedBox(height: 16),
            
            // Troubleshooting
            _buildInfoCard(
              context,
              'Common Issues',
              [
                _buildTroubleshootItem('Login Problems', 'Check internet connection and verify credentials'),
                _buildTroubleshootItem('QR Scanner Not Working', 'Allow camera permissions and ensure good lighting'),
                _buildTroubleshootItem('Data Not Saving', 'Ensure stable internet connection'),
                _buildTroubleshootItem('App Running Slow', 'Close other apps and restart device'),
              ],
              Icons.help_outline,
              Colors.red,
              isDark,
            ),
            
            const SizedBox(height: 16),
            
            // Contact Support
            _buildInfoCard(
              context,
              'Contact Support',
              [
                _buildContactItem(
                  'Email Support',
                  'support@mkattendance.com',
                  Icons.email,
                  () => _launchEmail('support@mkattendance.com'),
                ),
                _buildContactItem(
                  'System Admin',
                  'admin@mkattendance.com',
                  Icons.admin_panel_settings,
                  () => _launchEmail('admin@mkattendance.com'),
                ),
                _buildContactItem(
                  'Web Version',
                  'https://mk-attendance.vercel.app',
                  Icons.web,
                  () => _launchUrl('https://mk-attendance.vercel.app'),
                ),
              ],
              Icons.contact_support,
              Colors.purple,
              isDark,
            ),
            
            const SizedBox(height: 16),
            
            // What's New
            _buildInfoCard(
              context,
              'What\'s New in v4.1',
              [
                _buildNewFeature('🎨 Enhanced UI', 'Dark blue text on light backgrounds for better readability'),
                _buildNewFeature('🧹 Streamlined Navigation', 'Simplified More options menu'),
                _buildNewFeature('🔧 Fixed Issues', 'Resolved navigation and theme consistency problems'),
                _buildNewFeature('📱 Better Performance', 'Improved app responsiveness and stability'),
              ],
              Icons.new_releases,
              Colors.indigo,
              isDark,
            ),
            
            const SizedBox(height: 24),
            
            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'MK Attendance System',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 4.1.0 - December 2024',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : AppColors.darkBlueMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard(
    BuildContext context,
    String title,
    List<Widget> children,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Card(
      elevation: 4,
      color: isDark ? Colors.grey[800] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGuideStep(String step, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                step.split('.')[0],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.split(' ')[0],
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.substring(title.indexOf(' ') + 1),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTroubleshootItem(String problem, String solution) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            problem,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            solution,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactItem(String title, String contact, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      contact,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNewFeature(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.split(' ')[0],
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.substring(title.indexOf(' ') + 1),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=MK Attendance Support Request',
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      }
    } catch (e) {
      print('Could not launch email: $e');
    }
  }
  
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Could not launch URL: $e');
    }
  }
}
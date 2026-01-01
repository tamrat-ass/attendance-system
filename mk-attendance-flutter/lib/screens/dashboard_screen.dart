import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../utils/app_colors.dart';
import '../utils/ethiopian_date.dart';
import '../utils/date_converter.dart';
import '../utils/correct_ethiopian_date.dart';
import 'attendance_screen.dart';
import 'students_screen.dart';
import 'class_management_screen.dart';
import 'help_screen.dart';
import 'change_password_screen.dart';
import 'user_management_screen.dart';
import 'settings_screen.dart';
import 'qr_attendance_screen.dart';
import 'student_qr_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Screens will be initialized dynamically based on user role
  }

  List<Widget> _getScreensForUser(User? user) {
    final screens = <Widget>[
      const _HomeScreen(),
      const AttendanceScreen(),
      const StudentsScreen(),
    ];

    // Reports screen is hidden from Flutter app
    // Only add User Management if user has permission to manage users
    if (user?.canManageUsers == true) {
      screens.add(const UserManagementScreen());
    }

    return screens;
  }

  List<BottomNavigationBarItem> _getNavigationItemsForUser(User? user) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.check_circle),
        label: 'Attendance',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: 'Students',
      ),
    ];

    // Reports navigation is hidden from Flutter app
    // Only add User Management if user has permission to manage users
    if (user?.canManageUsers == true) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.admin_panel_settings),
        label: 'Users',
      ));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Get screens and navigation items based on user permissions
    final screens = _getScreensForUser(user);
    final navigationItems = _getNavigationItemsForUser(user);

    // Ensure current index is within bounds
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MK Attendance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              } else if (value == 'change_password') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'change_password',
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text('Change Password'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: navigationItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }


  void _showLogoutDialog() {
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _openWebVersion(BuildContext context) async {
    final Uri url = Uri.parse('https://mk-attendance.vercel.app');
    
    try {
      // Try different launch modes
      bool launched = false;
      
      // Method 1: External application
      try {
        launched = await launchUrl(url, mode: LaunchMode.externalApplication);
        if (launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening web version...'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      } catch (e) {
        print('❌ externalApplication mode failed: $e');
      }
      
      // Method 2: Platform default
      try {
        launched = await launchUrl(url, mode: LaunchMode.platformDefault);
        if (launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening web version...'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      } catch (e) {
        print('❌ platformDefault mode failed: $e');
      }
      
      // Method 3: Simple launch (deprecated but might work)
      try {
        launched = await launchUrl(url);
        if (launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening web version...'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      } catch (e) {
        print('❌ simple mode failed: $e');
      }
      
      throw Exception('All launch methods failed');
      
    } catch (e) {
      print('💥 Failed to launch web version: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open browser. Please visit: https://mk-attendance.vercel.app manually'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _navigateToTab(BuildContext context, int index) {
    // Get the current user to determine available tabs
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final screens = _getScreensForUser(user);
    
    // Ensure the index is within bounds
    if (index >= 0 && index < screens.length) {
      setState(() {
        _currentIndex = index;
      });
      print('Successfully navigated to tab $index (${_getTabName(index)})');
    } else {
      print('Error: Tab index $index is out of bounds. Available tabs: 0-${screens.length - 1}');
    }
  }
  
  String _getTabName(int index) {
    switch (index) {
      case 0: return 'Home';
      case 1: return 'Attendance';
      case 2: return 'Students';
      case 3: return 'Users';
      default: return 'Unknown';
    }
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6A5ACD).withOpacity(0.15), // Slate blue
            const Color(0xFF9370DB).withOpacity(0.08), // Medium purple
            Colors.white,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          // Refresh data when user pulls down
          await Future.delayed(const Duration(milliseconds: 500));
          // You can add specific refresh logic here if needed
        },
        child: Padding(
          padding: const EdgeInsets.all(12), // Reduced from 16
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card - Made smaller
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12), // Reduced from 20
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: const AssetImage('assets/images/apple-icon.png'),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              user?.fullName ?? 'User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${user?.role?.toUpperCase() ?? 'USER'} ACCESS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16), // Reduced from 24
            
            // Quick Actions Header
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14, // Better spacing for management cards
              mainAxisSpacing: 14, // Better spacing for management cards
              childAspectRatio: 1.6, // Optimized for better card visibility
              children: _buildQuickActionCards(context, user?.role),
            ),
            
            const SizedBox(height: 16), // Reduced from 24
            
            // Recent Activity Section
            Text(
              'Today\'s Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12), // Reduced from 16
            
            // Make overview section more compact with horizontal layout
            Container(
              padding: const EdgeInsets.all(12), // Reduced from 16
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // Theme-aware background
                borderRadius: BorderRadius.circular(10), // Reduced from 12
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.08), // Theme-aware shadow
                    blurRadius: 6, // Reduced from 8
                    offset: const Offset(0, 1), // Reduced from (0, 2)
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCompactOverviewItem(
                    Icons.today,
                    CorrectEthiopianDateUtils.formatEthiopianDate(CorrectEthiopianDateUtils.getCurrentEthiopianDate()),
                    AppColors.primary,
                  ),
                  Container(
                    width: 1, 
                    height: 30, 
                    color: Theme.of(context).dividerColor.withOpacity(0.5)
                  ), // Theme-aware vertical divider
                  _buildCompactOverviewItem(
                    Icons.access_time,
                    TimeOfDay.now().format(context),
                    Colors.blue,
                  ),
                  Container(
                    width: 1, 
                    height: 30, 
                    color: Theme.of(context).dividerColor.withOpacity(0.5)
                  ), // Theme-aware vertical divider
                  _buildCompactOverviewItem(
                    Icons.school,
                    'Active',
                    Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  List<Widget> _buildQuickActionCards(BuildContext context, String? userRole) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    final actions = <Widget>[
      // Core Attendance Actions
      _buildQuickActionCard(
        context,
        'Mark Attendance',
        Icons.check_circle_outline,
        AppColors.primary,
        () {
          final dashboardState = context.findAncestorStateOfType<_DashboardScreenState>();
          dashboardState?._navigateToTab(context, 1);
        },
      ),
      _buildQuickActionCard(
        context,
        'QR Scanner',
        Icons.qr_code_scanner,
        Colors.indigo,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRAttendanceScreen()),
        ),
      ),
      _buildQuickActionCard(
        context,
        'Student QR Codes',
        Icons.qr_code_2,
        Colors.deepPurple,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudentQRScreen()),
        ),
      ),
      
      // More Options Card
      _buildQuickActionCard(
        context,
        'More',
        Icons.more_horiz,
        Colors.grey[700]!,
        () => _showMoreOptionsDialog(context),
      ),
    ];



    return actions;
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    // Check if this is a management card for special styling
    bool isManagementCard = title.contains('Manage');
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18), // Slightly larger radius
          border: isManagementCard 
              ? Border.all(color: color.withOpacity(0.3), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isManagementCard ? 0.2 : 0.15),
              blurRadius: isManagementCard ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: isManagementCard 
                    ? LinearGradient(
                        colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isManagementCard ? null : color.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: isManagementCard ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Icon(
                icon,
                size: isManagementCard ? 32 : 28,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isManagementCard ? 15 : 14,
                fontWeight: isManagementCard ? FontWeight.w700 : FontWeight.w600,
                // Use dark blue on white background
                color: AppColors.darkBlue,
                height: 1.2,
              ),
            ),
            if (isManagementCard) ...[
              const SizedBox(height: 4),
              Container(
                width: 30,
                height: 2,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSummaryCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAttendanceSummaryDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.12),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 18,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Attendance Summary',
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  // Use dark blue on white background
                  color: AppColors.darkBlue,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[600] : AppColors.darkBlueMedium,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? null : AppColors.darkBlue,
                      ),
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

  Widget _buildCompactOverviewItem(
    IconData icon,
    String value,
    Color color,
  ) {
    return Builder(
      builder: (context) {
        // Get theme-aware text color
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : AppColors.darkBlue;
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6), // Smaller padding
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: color,
                size: 16, // Smaller icon
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 10, // Smaller text
                fontWeight: FontWeight.w600,
                color: textColor, // Theme-aware text color
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }



  void _navigateToAttendanceWithPermission(BuildContext context) {
    // Navigate to attendance tab (index 1)
    final dashboardState = context.findAncestorStateOfType<_DashboardScreenState>();
    dashboardState?.setState(() {
      dashboardState._currentIndex = 1;
    });
    
    // Show a helpful message about the Mark All Permission feature
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.assignment_turned_in, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Navigate to Attendance → Select class → Use "Mark All Permission" button',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _navigateToAttendanceWithAbsent(BuildContext context) {
    // Navigate to attendance tab (index 1)
    final dashboardState = context.findAncestorStateOfType<_DashboardScreenState>();
    dashboardState?.setState(() {
      dashboardState._currentIndex = 1;
    });
    
    // Show a helpful message about the Mark All Absent feature
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.cancel, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Navigate to Attendance → Select class → Use "Mark All Absent" button',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showMoreOptionsDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[700]!, Colors.grey[800]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.more_horiz, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'More Options',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Options List
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Manage Classes
                    _buildMoreOptionItem(
                      context,
                      'Manage Classes',
                      Icons.class_outlined,
                      Colors.orange,
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ClassManagementScreen()),
                        );
                      },
                    ),
                    
                    // Attendance Summary (admin/manager only)
                    if (user?.role?.toLowerCase() == 'admin' || user?.role?.toLowerCase() == 'manager')
                      _buildMoreOptionItem(
                        context,
                        'Attendance Summary',
                        Icons.analytics_outlined,
                        Colors.indigo,
                        () {
                          Navigator.pop(context);
                          _showAttendanceSummaryDialog(context);
                        },
                      ),
                    

                    
                    // View Web Version (admin/manager only)
                    if (user?.role?.toLowerCase() == 'admin' || user?.role?.toLowerCase() == 'manager')
                      _buildMoreOptionItem(
                        context,
                        'View Web Version',
                        Icons.web,
                        Colors.blue,
                        () {
                          Navigator.pop(context);
                          _openWebVersion(context);
                        },
                      ),
                    
                    // Help & Support
                    _buildMoreOptionItem(
                      context,
                      'Help & Support',
                      Icons.help_outline,
                      Colors.teal,
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpScreen()),
                        );
                      },
                    ),

                  ],
                ),
              ),
              
              // Close Button
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreOptionItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            // Use dark blue on light background (Colors.grey[50])
            color: AppColors.darkBlue,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tileColor: Colors.grey[50],
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  Future<void> _launchWebUrl() async {
    final Uri url = Uri.parse('https://mk-attendance.vercel.app');
    
    try {
      // Try different launch modes
      bool launched = false;
      
      // Method 1: External application
      try {
        launched = await launchUrl(url, mode: LaunchMode.externalApplication);
        if (launched) {
          print('✅ Launched with externalApplication mode');
          return;
        }
      } catch (e) {
        print('❌ externalApplication mode failed: $e');
      }
      
      // Method 2: Platform default
      try {
        launched = await launchUrl(url, mode: LaunchMode.platformDefault);
        if (launched) {
          print('✅ Launched with platformDefault mode');
          return;
        }
      } catch (e) {
        print('❌ platformDefault mode failed: $e');
      }
      
      // Method 3: Simple launch (deprecated but might work)
      try {
        launched = await launchUrl(url);
        if (launched) {
          print('✅ Launched with simple mode');
          return;
        }
      } catch (e) {
        print('❌ simple mode failed: $e');
      }
      
      throw Exception('All launch methods failed');
      
    } catch (e) {
      print('💥 All URL launch methods failed: $e');
      rethrow;
    }
  }

  void _showAttendanceSummaryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AttendanceSummaryDialog(),
    );
  }

  void _openWebVersion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.web, color: Colors.green),
            SizedBox(width: 8),
            Text('Web Version'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Access the full web version at:'),
            SizedBox(height: 12),
            SelectableText(
              'https://mk-attendance.vercel.app',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            Text('Web version includes:'),
            Text('• Advanced Reports & Analytics'),
            Text('• Data Export & Import'),
            Text('• User Management'),
            Text('• System Administration'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(
                const ClipboardData(text: 'https://mk-attendance.vercel.app'),
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('URL copied to clipboard!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Copy URL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await _launchWebUrl();
                
                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening web version...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                print('💥 Failed to launch web version: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open browser. Please visit: https://mk-attendance.vercel.app manually'),
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
            child: const Text('Open Web'),
          ),
        ],
      ),
    );
  }

  void _navigateToChangePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('MK Attendance'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.1.0'),
            SizedBox(height: 8),
            Text('Ethiopian Attendance Management System'),
            SizedBox(height: 8),
            Text('Built with Flutter'),
            SizedBox(height: 8),
            Text('Features:'),
            Text('• Ethiopian Calendar Support'),
            Text('• Real-time Database Sync'),
            Text('• Interactive Reports'),
            Text('• Student Management'),
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
}

class AttendanceSummaryDialog extends StatefulWidget {
  @override
  _AttendanceSummaryDialogState createState() => _AttendanceSummaryDialogState();
}

class _AttendanceSummaryDialogState extends State<AttendanceSummaryDialog> {
  String? _selectedClass;
  String _selectedDate = '';
  List<String> _classes = [];
  Map<String, int> _attendanceCounts = {
    'present': 0,
    'absent': 0,
    'late': 0,
    'permission': 0,
  };
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = _getCurrentEthiopianDate();
    _loadClasses();
  }

  String _getCurrentEthiopianDate() {
    // Use proper Ethiopian date conversion
    return DateConverter.getCurrentEthiopianDb();
  }

  Future<void> _loadClasses() async {
    try {
      final response = await http.get(
        Uri.parse('https://mk-attendance.vercel.app/api/classes'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            _classes = ['All Classes']; // Add "All Classes" option first
            _classes.addAll((data['data'] as List)
                .map((cls) => cls['name'].toString())
                .toList());
            if (_classes.isNotEmpty) {
              _selectedClass = 'All Classes'; // Default to "All Classes"
              _loadAttendanceSummary();
            }
          });
        }
      }
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  Future<void> _loadAttendanceSummary() async {
    if (_selectedClass == null || _selectedDate.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String apiUrl;
      if (_selectedClass == 'All Classes') {
        // Get attendance for all classes on the selected date
        apiUrl = 'https://mk-attendance.vercel.app/api/attendance?date=$_selectedDate';
      } else {
        // Get attendance for specific class
        apiUrl = 'https://mk-attendance.vercel.app/api/attendance?date=$_selectedDate&class=$_selectedClass';
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          final attendanceRecords = data['data'] as List;
          
          // Count attendance by status
          final counts = {
            'present': 0,
            'absent': 0,
            'late': 0,
            'permission': 0,
          };

          for (var record in attendanceRecords) {
            final status = record['status']?.toString() ?? '';
            if (counts.containsKey(status)) {
              counts[status] = counts[status]! + 1;
            }
          }

          setState(() {
            _attendanceCounts = counts;
          });
        }
      }
    } catch (e) {
      print('Error loading attendance summary: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectEthiopianDate() async {
    // Parse current Ethiopian date from database format (YYYY-MM-DD)
    final dateParts = _selectedDate.split('-');
    final currentEthiopian = {
      'year': int.parse(dateParts[0]),
      'month': int.parse(dateParts[1]),
      'day': int.parse(dateParts[2]),
    };
    
    // Show Ethiopian date picker dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedYear = currentEthiopian['year']!;
        int selectedMonth = currentEthiopian['month']!;
        int selectedDay = currentEthiopian['day']!;
        
        return AlertDialog(
          title: const Text('Select Ethiopian Date'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Year picker
                  Row(
                    children: [
                      const Text('Year: '),
                      DropdownButton<int>(
                        value: selectedYear,
                        items: List.generate(10, (index) {
                          final year = currentEthiopian['year']! - 5 + index;
                          return DropdownMenuItem(value: year, child: Text(year.toString()));
                        }),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedYear = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  // Month picker
                  Row(
                    children: [
                      const Text('Month: '),
                      DropdownButton<int>(
                        value: selectedMonth,
                        items: List.generate(13, (index) {
                          final month = index + 1;
                          final monthName = CorrectEthiopianDateUtils.ethiopianMonths[index];
                          return DropdownMenuItem(value: month, child: Text('$month - $monthName'));
                        }),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedMonth = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  // Day picker
                  Row(
                    children: [
                      const Text('Day: '),
                      DropdownButton<int>(
                        value: selectedDay,
                        items: List.generate(30, (index) {
                          final day = index + 1;
                          return DropdownMenuItem(value: day, child: Text(day.toString()));
                        }),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedDay = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Store selected Ethiopian date in database format (YYYY-MM-DD)
                final year = selectedYear.toString().padLeft(4, '0');
                final month = selectedMonth.toString().padLeft(2, '0');
                final day = selectedDay.toString().padLeft(2, '0');
                final ethiopianDbDate = '$year-$month-$day';
                
                setState(() {
                  _selectedDate = ethiopianDbDate;
                });
                
                Navigator.of(context).pop();
                _loadAttendanceSummary();
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[400]!, Colors.deepOrange[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.analytics_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Attendance Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Class Selector with modern design
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedClass,
                      decoration: InputDecoration(
                        labelText: 'Select Class',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        prefixIcon: Icon(Icons.class_, color: Colors.orange[400]),
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
                        _loadAttendanceSummary();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Date Selector with modern design
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Ethiopian Date',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        prefixIcon: Icon(Icons.calendar_today, color: Colors.orange[400]),
                      ),
                      controller: TextEditingController(text: DateConverter.formatEthiopianDbDate(_selectedDate)),
                      readOnly: true,
                      onTap: _selectEthiopianDate,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Attendance Summary with beautiful design
                  if (_isLoading)
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[400]!),
                        strokeWidth: 3,
                      ),
                    )
                  else
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[50]!, Colors.purple[50]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _selectedClass == 'All Classes' 
                                    ? 'Total Attendance (All Classes)'
                                    : 'Attendance for $_selectedClass',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Date: ${DateConverter.formatEthiopianDbDate(_selectedDate)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Beautiful count cards in grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                          children: [
                            _buildModernCountCard('Present', _attendanceCounts['present']!, 
                                Colors.green[400]!, Icons.check_circle_rounded),
                            _buildModernCountCard('Absent', _attendanceCounts['absent']!, 
                                Colors.red[400]!, Icons.cancel_rounded),
                            _buildModernCountCard('Late', _attendanceCounts['late']!, 
                                Colors.orange[400]!, Icons.access_time_rounded),
                            _buildModernCountCard('Permission', _attendanceCounts['permission']!, 
                                Colors.blue[400]!, Icons.verified_user_rounded),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildCountCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCountCard(String label, int count, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
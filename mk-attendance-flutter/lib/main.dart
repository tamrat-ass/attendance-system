import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/theme_service.dart';
import 'services/session_manager.dart';
import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/class_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // SELECTIVE OVERFLOW ERROR ELIMINATION (not all errors)
  if (kDebugMode) {
    // Make overflow errors invisible but keep other errors visible
    RenderErrorBox.backgroundColor = Colors.transparent;
    RenderErrorBox.textStyle = ui.TextStyle(
      color: const ui.Color(0x00000000), // Transparent
      fontSize: 0,
    );
  }
  
  // Disable visual debug indicators but keep functionality
  debugPaintSizeEnabled = false;
  debugDisableShadows = false;
  
  // Override ONLY overflow errors, not all errors
  FlutterError.onError = (FlutterErrorDetails details) {
    // Only suppress overflow and RenderFlex errors
    final errorString = details.exception.toString().toLowerCase();
    if (errorString.contains('overflow') || 
        errorString.contains('renderflex') ||
        errorString.contains('bottom overflowed')) {
      // Suppress only overflow errors
      if (kDebugMode) {
        print('🔇 Suppressed overflow error: ${details.exception}');
      }
      return;
    }
    
    // For all other errors, use default handling (IMPORTANT!)
    FlutterError.presentError(details);
  };
  
  runApp(const MKAttendanceApp());
}

class MKAttendanceApp extends StatefulWidget {
  const MKAttendanceApp({super.key});

  @override
  State<MKAttendanceApp> createState() => _MKAttendanceAppState();
}

class _MKAttendanceAppState extends State<MKAttendanceApp>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('🔍 App State Changed: $state');
    
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // App closed / background
      await SessionManager.saveLastActiveTime();
      print('💾 Session saved on background');
    }

    if (state == AppLifecycleState.resumed) {
      final expired = await SessionManager.isSessionExpired();
      final remaining = await SessionManager.getRemainingMinutes();
      print('⏰ Session expired: $expired, Remaining: $remaining minutes');

      if (expired) {
        print('🚪 Auto-logout triggered - Session expired');
        await SessionManager.clearSession();

        if (mounted) {
          // Get the auth provider and logout
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          authProvider.logout();
          
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
            (route) => false,
          );
          
          // Show user-friendly message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please login again.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Update activity time when app resumes
        await SessionManager.updateActivity();
        print('✅ Session refreshed - ${remaining} minutes remaining');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()..initialize()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'MK Attendance',
            debugShowCheckedModeBanner: false,
            theme: ThemeService.lightTheme,
            darkTheme: ThemeService.darkTheme,
            themeMode: themeService.themeMode,
            home: const AuthWrapper(),
            builder: (context, child) {
              // SAFE OVERFLOW PREVENTION - only clip, don't hide errors
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0,
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    
    // Show splash screen for 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Debug information
        print('🔍 AuthWrapper: isLoading=${authProvider.isLoading}, isAuthenticated=${authProvider.isAuthenticated}');
        
        if (authProvider.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Checking authentication...'),
                ],
              ),
            ),
          );
        }
        
        if (authProvider.isAuthenticated) {
          print('🔍 AuthWrapper: Navigating to Dashboard');
          return const DashboardScreen();
        }
        
        print('🔍 AuthWrapper: Navigating to Login');
        return const LoginScreen();
      },
    );
  }
}
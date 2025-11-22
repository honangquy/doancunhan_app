import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/constants.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _controller.forward();
    
    // Check auth and navigate after 3 seconds
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    try {
      final authService = AuthService();
      await authService.init();
      
      if (authService.isAuthenticated && authService.token != null) {
        // User is authenticated
        
        if (authService.hasSelectedRole && authService.currentRole != null) {
          // User has selected a role - go to dashboard
          final route = _getDashboardRoute(authService.currentRole!.roleCode);
          print('✅ Has selected role: ${authService.currentRole!.roleCode} -> $route');
          Navigator.pushReplacementNamed(context, route);
        } else if (authService.hasRoles) {
          // User has roles but hasn't selected one - go to welcome screen
          print('✅ Has roles but not selected -> /welcome');
          Navigator.pushReplacementNamed(context, '/welcome');
        } else {
          // User has token but no roles - logout and go to login
          print('⚠️ Has token but no roles -> logout');
          await authService.logout();
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        // Not authenticated - go to login
        print('❌ Not authenticated -> /login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('⚠️ Error checking auth: $e');
      // On error, go to login screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
  
  String _getDashboardRoute(String roleCode) {
    switch (roleCode.toUpperCase()) {
      case 'ADMIN':
        return '/admin/dashboard';
      case 'CHAIR':
        return '/chair/dashboard';
      case 'REVIEWER':
        return '/reviewer/dashboard';
      case 'AUTHOR':
        return '/author/dashboard';
      case 'PC':
        return '/chair/dashboard';
      default:
        return '/author/dashboard';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.authorPrimary,
              AppColors.authorSecondary,
              Color(0xFF4A9F7C),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo trường HUIT
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/images/huit_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback nếu chưa có file logo
                      return const Center(
                        child: Text(
                          'H',
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: AppColors.authorPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                
                // App Name
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Slogan HUIT
                const Text(
                  'Nhân văn - Đoàn kết - Đổi mới - Tiên phong',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Subtitle
                const Text(
                  'Hệ thống quản lý hội thảo khoa học',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Loading Indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 16),
                
                // Version
                const Text(
                  'v${AppConstants.appVersion}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
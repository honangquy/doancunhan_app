import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import 'api_config.dart';

/// Utility để check authentication và redirect về login nếu cần
class AuthChecker {
  /// Check xem user có authenticated không
  /// Nếu không, redirect về login
  static Future<bool> checkAuthAndRedirectIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConfig.tokenKey);
    
    if (token == null || token.isEmpty) {
      print('⚠️  [AuthChecker] No token found - redirecting to login');
      
      if (context.mounted) {
        // Show dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Phiên đăng nhập đã hết hạn'),
            content: const Text(
              'Phiên đăng nhập của bạn đã hết hạn.\nVui lòng đăng nhập lại để tiếp tục.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                child: const Text('Đăng nhập lại'),
              ),
            ],
          ),
        );
        
        if (context.mounted) {
          // Navigate to login and remove all previous routes
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      }
      
      return false;
    }
    
    return true;
  }
  
  /// Check auth silently (không show dialog, chỉ return true/false)
  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConfig.tokenKey);
    return token != null && token.isNotEmpty;
  }
  
  /// Logout và redirect về login
  static Future<void> logoutAndRedirect(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();
    
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}

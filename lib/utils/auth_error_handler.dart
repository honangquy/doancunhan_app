import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthErrorHandler {
  static final AuthErrorHandler _instance = AuthErrorHandler._internal();
  factory AuthErrorHandler() => _instance;
  AuthErrorHandler._internal();

  final AuthService _authService = AuthService();
  BuildContext? _context;
  bool _isHandling = false;

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> handle401Unauthorized() async {
    if (_isHandling) return;
    _isHandling = true;

    try {
      print('🔐 Token expired - Auto logging out...');
      
      // Logout (clear token and user data)
      await _authService.logout();

      // Navigate to login if context is available
      if (_context != null && _context!.mounted) {
        Navigator.of(_context!).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } finally {
      _isHandling = false;
    }
  }
}

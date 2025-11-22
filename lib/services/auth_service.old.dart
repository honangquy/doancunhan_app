import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final StorageService _storage = StorageService();
  
  // Authentication state
  String? _token;
  Map<String, dynamic>? _currentUser;
  bool _isAuthenticated = false;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get userId => _currentUser?['id'];
  String? get userEmail => _currentUser?['email'];
  String? get userName => _currentUser?['name'];
  String? get userRole => _currentUser?['role'];

  /// Initialize auth service - load stored credentials
  Future<void> init() async {
    try {
      // Load stored token
      _token = await _storage.getToken();
      
      // Load stored user data
      final userData = await _storage.getUserData();
      if (userData != null) {
        _currentUser = jsonDecode(userData);
      }

      // Check if authenticated
      _isAuthenticated = _token != null && _currentUser != null;

      if (kDebugMode) {
        print('AuthService initialized: isAuthenticated=$_isAuthenticated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing AuthService: $e');
      }
      _isAuthenticated = false;
    }
  }

  /// Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock authentication logic
      if (password.length < 6) {
        return {
          'success': false,
          'message': 'Invalid credentials',
        };
      }

      // Determine role based on email
      String role = 'author'; // default
      if (email.contains('admin')) {
        role = 'admin';
      } else if (email.contains('reviewer')) {
        role = 'reviewer';
      }

      // Mock user data
      final userData = {
        'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'email': email,
        'name': _extractNameFromEmail(email),
        'role': role,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Mock token
      final token = _generateMockToken(email);

      // Store credentials
      await _storage.saveToken(token);
      await _storage.saveUserData(jsonEncode(userData));
      
      if (rememberMe) {
        await _storage.saveRememberMe(true);
        await _storage.saveEmail(email);
      }

      // Update state
      _token = token;
      _currentUser = userData;
      _isAuthenticated = true;

      if (kDebugMode) {
        print('Login successful: $email as $role');
      }

      return {
        'success': true,
        'message': 'Login successful',
        'user': userData,
        'token': token,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      return {
        'success': false,
        'message': 'Login failed: $e',
      };
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Validation
      if (email.isEmpty || password.length < 6) {
        return {
          'success': false,
          'message': 'Invalid input data',
        };
      }

      // Mock user creation
      final userData = {
        'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.toLowerCase(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      if (kDebugMode) {
        print('User registered: $email as $role');
      }

      return {
        'success': true,
        'message': 'Registration successful',
        'user': userData,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Registration error: $e');
      }
      return {
        'success': false,
        'message': 'Registration failed: $e',
      };
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // TODO: Call API to invalidate token if needed
      
      // Clear storage
      await _storage.clearToken();
      await _storage.clearUserData();
      
      // Clear state
      _token = null;
      _currentUser = null;
      _isAuthenticated = false;

      if (kDebugMode) {
        print('User logged out');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
      rethrow;
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? affiliation,
    String? department,
  }) async {
    try {
      if (_currentUser == null) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Update user data
      if (name != null) _currentUser!['name'] = name;
      if (phone != null) _currentUser!['phone'] = phone;
      if (affiliation != null) _currentUser!['affiliation'] = affiliation;
      if (department != null) _currentUser!['department'] = department;
      
      _currentUser!['updatedAt'] = DateTime.now().toIso8601String();

      // Save updated data
      await _storage.saveUserData(jsonEncode(_currentUser));

      if (kDebugMode) {
        print('Profile updated');
      }

      return {
        'success': true,
        'message': 'Profile updated successfully',
        'user': _currentUser,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Update profile error: $e');
      }
      return {
        'success': false,
        'message': 'Update failed: $e',
      };
    }
  }

  /// Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      if (newPassword.length < 6) {
        return {
          'success': false,
          'message': 'Password must be at least 6 characters',
        };
      }

      if (kDebugMode) {
        print('Password changed');
      }

      return {
        'success': true,
        'message': 'Password changed successfully',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Change password error: $e');
      }
      return {
        'success': false,
        'message': 'Password change failed: $e',
      };
    }
  }

  /// Request password reset
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      if (kDebugMode) {
        print('Password reset requested for: $email');
      }

      return {
        'success': true,
        'message': 'Password reset link sent to your email',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Forgot password error: $e');
      }
      return {
        'success': false,
        'message': 'Request failed: $e',
      };
    }
  }

  /// Verify token validity
  Future<bool> verifyToken() async {
    try {
      if (_token == null) return false;

      // TODO: Replace with actual API call to verify token
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock verification - check if token is expired
      // In real app, decode JWT and check expiration
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Token verification error: $e');
      }
      return false;
    }
  }

  /// Refresh authentication token
  Future<bool> refreshToken() async {
    try {
      if (_token == null) return false;

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock new token
      final newToken = _generateMockToken(_currentUser?['email'] ?? '');
      
      await _storage.saveToken(newToken);
      _token = newToken;

      if (kDebugMode) {
        print('Token refreshed');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh error: $e');
      }
      return false;
    }
  }

  /// Get stored email for auto-fill
  Future<String?> getStoredEmail() async {
    try {
      return await _storage.getEmail();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting stored email: $e');
      }
      return null;
    }
  }

  /// Check if "Remember Me" was enabled
  Future<bool> isRememberMeEnabled() async {
    try {
      return await _storage.isRememberMe();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking remember me: $e');
      }
      return false;
    }
  }

  // ========== Helper Methods ==========

  /// Extract name from email
  String _extractNameFromEmail(String email) {
    final username = email.split('@').first;
    final parts = username.split('.');
    return parts.map((e) => e[0].toUpperCase() + e.substring(1)).join(' ');
  }

  /// Generate mock JWT token
  String _generateMockToken(String email) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final payload = base64Encode(utf8.encode('$email:$timestamp'));
    return 'mock_token_$payload';
  }

  /// Check if user has specific role
  bool hasRole(String role) {
    return userRole?.toLowerCase() == role.toLowerCase();
  }

  /// Check if user is admin
  bool isAdmin() => hasRole('admin');

  /// Check if user is author
  bool isAuthor() => hasRole('author');

  /// Check if user is reviewer
  bool isReviewer() => hasRole('reviewer');
}
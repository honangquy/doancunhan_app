import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_config.dart';
import '../models/user.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();
  
  // Authentication state
  String? _token;
  User? _currentUser;
  bool _isAuthenticated = false;
  
  // Multi-role support
  AppUser? _appUser;
  List<UserRole> _roles = [];
  UserRole? _currentRole;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  User? get currentUser => _currentUser;
  String? get userId => _currentUser?.id;
  String? get userEmail => _currentUser?.email;
  String? get userName => _currentUser?.name;
  String? get userRole => _currentUser?.role;
  
  // Multi-role getters
  AppUser? get appUser => _appUser;
  List<UserRole> get roles => _roles;
  UserRole? get currentRole => _currentRole;
  bool get hasRoles => _roles.isNotEmpty;
  bool get hasSelectedRole => _currentRole != null;

  /// Initialize auth service - load stored credentials
  Future<void> init() async {
    try {
      await _api.init();
      
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(ApiConfig.tokenKey);
      
      final userData = prefs.getString(ApiConfig.userKey);
      if (userData != null) {
        _currentUser = User.fromJson(jsonDecode(userData));
      }
      
      // Load multi-role data
      final appUserData = prefs.getString('app_user');
      if (appUserData != null) {
        _appUser = AppUser.fromJson(jsonDecode(appUserData));
      }
      
      final rolesData = prefs.getString('user_roles');
      if (rolesData != null) {
        final rolesList = jsonDecode(rolesData) as List<dynamic>;
        _roles = rolesList.map((e) => UserRole.fromJson(e)).toList();
      }
      
      final currentRoleData = prefs.getString('current_role');
      if (currentRoleData != null) {
        _currentRole = UserRole.fromJson(jsonDecode(currentRoleData));
      }

      _isAuthenticated = _token != null && _currentUser != null;

      if (kDebugMode) {
        print('✅ AuthService initialized: isAuthenticated=$_isAuthenticated');
        print('   Roles count: ${_roles.length}');
        print('   Current role: ${_currentRole?.roleCode ?? "none"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing AuthService: $e');
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
      // Call API
      final response = await _api.login(email, password);
      
      if (kDebugMode) {
        print('🔍 AuthService received response: $response');
      }
      
      // Extract token and user from response
      final token = response['token'] as String?;
      final userData = response['user'] as Map<String, dynamic>?;
      final rolesJson = response['roles'] as List<dynamic>?;
      
      if (kDebugMode) {
        print('🔍 Token: ${token != null ? "exists" : "null"}');
        print('🔍 UserData: ${userData != null ? "exists" : "null"}');
        print('🔍 Roles: ${rolesJson?.length ?? 0} roles');
      }
      
      if (token == null || userData == null) {
        if (kDebugMode) {
          print('❌ Missing token or userData');
        }
        return {
          'success': false,
          'message': 'Invalid response from server',
        };
      }

      // Parse AppUser and roles
      final appUser = AppUser.fromJson(userData);
      
      // Parse roles from API or create from user.role
      List<UserRole> roles = [];
      if (rolesJson != null && rolesJson.isNotEmpty) {
        // Backend trả về roles array (multi-role)
        roles = rolesJson.map((e) => UserRole.fromJson(e as Map<String, dynamic>)).toList();
      } else if (userData['role'] != null) {
        // Backend chưa hỗ trợ multi-role, tạo role từ user.role
        final roleCode = userData['role'].toString().toUpperCase();
        roles = [
          UserRole(
            roleCode: roleCode,
            conferenceId: null,
            conferenceTitle: null,
          ),
        ];
        if (kDebugMode) {
          print('⚠️  Backend chưa trả roles array, tạo role từ user.role: $roleCode');
        }
      }

      // Save to storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConfig.tokenKey, token);
      await prefs.setString(ApiConfig.userKey, jsonEncode(userData));
      await prefs.setString('app_user', jsonEncode(appUser.toJson()));
      await prefs.setString('user_roles', jsonEncode(roles.map((e) => e.toJson()).toList()));
      
      if (rememberMe) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('saved_email', email);
      }

      // Update state
      _token = token;
      _currentUser = User.fromJson(userData);
      _appUser = appUser;
      _roles = roles;
      _currentRole = null; // Reset current role - user must select
      _isAuthenticated = true;

      if (kDebugMode) {
        print('✅ Login successful: $email');
        print('   AppUser: ${appUser.fullName}');
        print('   Roles: ${roles.map((r) => r.roleCode).join(", ")}');
      }

      return {
        'success': true,
        'message': 'Login successful',
        'user': userData,
        'token': token,
        'roles': roles.map((e) => e.toJson()).toList(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Login error: $e');
      }
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? affiliation,
  }) async {
    try {
      final response = await _api.register(
        fullName: fullName,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
        affiliation: affiliation,
      );

      if (kDebugMode) {
        print('✅ Registration successful: $email');
      }

      return {
        'success': true,
        'message': 'Registration successful',
        'data': response,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Registration error: $e');
      }
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      // Call API to invalidate token
      await _api.logout();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️  Logout API error (continuing anyway): $e');
      }
    }

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.tokenKey);
    await prefs.remove(ApiConfig.userKey);
    await prefs.remove('app_user');
    await prefs.remove('user_roles');
    await prefs.remove('current_role');

    // Clear state
    _token = null;
    _currentUser = null;
    _appUser = null;
    _roles = [];
    _currentRole = null;
    _isAuthenticated = false;

    if (kDebugMode) {
      print('✅ Logged out');
    }
  }
  
  /// Set current role (when user selects a role)
  Future<void> setCurrentRole(UserRole role) async {
    try {
      _currentRole = role;
      
      // Save to storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_role', jsonEncode(role.toJson()));
      
      if (kDebugMode) {
        print('✅ Current role set: ${role.roleCode}');
        print('   Conference: ${role.conferenceTitle ?? "All"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error setting current role: $e');
      }
      rethrow;
    }
  }
  
  /// Clear current role (for role switching)
  Future<void> clearCurrentRole() async {
    try {
      _currentRole = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_role');
      
      if (kDebugMode) {
        print('✅ Current role cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing current role: $e');
      }
    }
  }

  /// Refresh user profile from server
  Future<void> refreshProfile() async {
    try {
      final user = await _api.getProfile();
      
      // Update storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConfig.userKey, jsonEncode(user.toJson()));
      
      // Update state
      _currentUser = user;

      if (kDebugMode) {
        print('✅ Profile refreshed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing profile: $e');
      }
      throw Exception('Failed to refresh profile: $e');
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final updatedUser = await _api.updateProfile(data);
      
      // Update storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConfig.userKey, jsonEncode(updatedUser.toJson()));
      
      // Update state
      _currentUser = updatedUser;

      if (kDebugMode) {
        print('✅ Profile updated');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating profile: $e');
      }
      return false;
    }
  }

  /// Check if token is still valid
  Future<bool> validateToken() async {
    if (_token == null) return false;
    
    try {
      await _api.getProfile();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️  Token validation failed: $e');
      }
      return false;
    }
  }

  /// Get saved email (for remember me)
  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_email');
  }

  /// Check if remember me was enabled
  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('remember_me') ?? false;
  }

  /// Request password reset OTP
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _api.forgotPassword(email);
      
      if (kDebugMode) {
        print('✅ Password reset OTP sent to: $email');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error requesting password reset: $e');
      }
      rethrow;
    }
  }

  /// Verify reset token/OTP
  Future<bool> verifyResetToken(String email, String token) async {
    try {
      await _api.verifyResetToken(email, token);
      
      if (kDebugMode) {
        print('✅ Reset token verified');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verifying reset token: $e');
      }
      return false;
    }
  }

  /// Reset password with token
  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _api.resetPassword(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      
      if (kDebugMode) {
        print('✅ Password reset successful');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error resetting password: $e');
      }
      return false;
    }
  }

  /// Resend OTP
  Future<Map<String, dynamic>> resendOTP(String email) async {
    return await forgotPassword(email);
  }
}

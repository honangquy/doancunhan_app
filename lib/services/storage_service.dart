import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // Storage keys
  static const String _keyToken = 'auth_token';
  static const String _keyUserData = 'user_data';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyEmail = 'email';
  static const String _keyTheme = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyFirstLaunch = 'first_launch';

  /// Initialize storage service
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      if (kDebugMode) {
        print('StorageService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing StorageService: $e');
      }
      rethrow;
    }
  }

  /// Ensure preferences are initialized
  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ========== Authentication Storage ==========

  /// Save authentication token
  Future<bool> saveToken(String token) async {
    try {
      final p = await prefs;
      return await p.setString(_keyToken, token);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving token: $e');
      }
      return false;
    }
  }

  /// Get authentication token
  Future<String?> getToken() async {
    try {
      final p = await prefs;
      return p.getString(_keyToken);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting token: $e');
      }
      return null;
    }
  }

  /// Clear authentication token
  Future<bool> clearToken() async {
    try {
      final p = await prefs;
      return await p.remove(_keyToken);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing token: $e');
      }
      return false;
    }
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ========== User Data Storage ==========

  /// Save user data as JSON string
  Future<bool> saveUserData(String userData) async {
    try {
      final p = await prefs;
      return await p.setString(_keyUserData, userData);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
      return false;
    }
  }

  /// Get user data
  Future<String?> getUserData() async {
    try {
      final p = await prefs;
      return p.getString(_keyUserData);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user data: $e');
      }
      return null;
    }
  }

  /// Clear user data
  Future<bool> clearUserData() async {
    try {
      final p = await prefs;
      return await p.remove(_keyUserData);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing user data: $e');
      }
      return false;
    }
  }

  // ========== Remember Me Storage ==========

  /// Save remember me preference
  Future<bool> saveRememberMe(bool value) async {
    try {
      final p = await prefs;
      return await p.setBool(_keyRememberMe, value);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving remember me: $e');
      }
      return false;
    }
  }

  /// Get remember me preference
  Future<bool> isRememberMe() async {
    try {
      final p = await prefs;
      return p.getBool(_keyRememberMe) ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting remember me: $e');
      }
      return false;
    }
  }

  /// Save email for auto-fill
  Future<bool> saveEmail(String email) async {
    try {
      final p = await prefs;
      return await p.setString(_keyEmail, email);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving email: $e');
      }
      return false;
    }
  }

  /// Get saved email
  Future<String?> getEmail() async {
    try {
      final p = await prefs;
      return p.getString(_keyEmail);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting email: $e');
      }
      return null;
    }
  }

  /// Clear remember me data
  Future<bool> clearRememberMe() async {
    try {
      final p = await prefs;
      await p.remove(_keyRememberMe);
      await p.remove(_keyEmail);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing remember me: $e');
      }
      return false;
    }
  }

  // ========== App Settings Storage ==========

  /// Save theme mode (light/dark/system)
  Future<bool> saveThemeMode(String mode) async {
    try {
      final p = await prefs;
      return await p.setString(_keyTheme, mode);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving theme mode: $e');
      }
      return false;
    }
  }

  /// Get theme mode
  Future<String> getThemeMode() async {
    try {
      final p = await prefs;
      return p.getString(_keyTheme) ?? 'system';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting theme mode: $e');
      }
      return 'system';
    }
  }

  /// Save language preference
  Future<bool> saveLanguage(String languageCode) async {
    try {
      final p = await prefs;
      return await p.setString(_keyLanguage, languageCode);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving language: $e');
      }
      return false;
    }
  }

  /// Get language preference
  Future<String> getLanguage() async {
    try {
      final p = await prefs;
      return p.getString(_keyLanguage) ?? 'en';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting language: $e');
      }
      return 'en';
    }
  }

  /// Save notifications enabled state
  Future<bool> saveNotificationsEnabled(bool enabled) async {
    try {
      final p = await prefs;
      return await p.setBool(_keyNotifications, enabled);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving notifications setting: $e');
      }
      return false;
    }
  }

  /// Get notifications enabled state
  Future<bool> isNotificationsEnabled() async {
    try {
      final p = await prefs;
      return p.getBool(_keyNotifications) ?? true;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting notifications setting: $e');
      }
      return true;
    }
  }

  // ========== First Launch Detection ==========

  /// Check if this is the first app launch
  Future<bool> isFirstLaunch() async {
    try {
      final p = await prefs;
      return p.getBool(_keyFirstLaunch) ?? true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking first launch: $e');
      }
      return true;
    }
  }

  /// Mark first launch as complete
  Future<bool> setFirstLaunchComplete() async {
    try {
      final p = await prefs;
      return await p.setBool(_keyFirstLaunch, false);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting first launch complete: $e');
      }
      return false;
    }
  }

  // ========== Generic Storage Methods ==========

  /// Save string value
  Future<bool> setString(String key, String value) async {
    try {
      final p = await prefs;
      return await p.setString(key, value);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving string: $e');
      }
      return false;
    }
  }

  /// Get string value
  Future<String?> getString(String key) async {
    try {
      final p = await prefs;
      return p.getString(key);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting string: $e');
      }
      return null;
    }
  }

  /// Save int value
  Future<bool> setInt(String key, int value) async {
    try {
      final p = await prefs;
      return await p.setInt(key, value);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving int: $e');
      }
      return false;
    }
  }

  /// Get int value
  Future<int?> getInt(String key) async {
    try {
      final p = await prefs;
      return p.getInt(key);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting int: $e');
      }
      return null;
    }
  }

  /// Save bool value
  Future<bool> setBool(String key, bool value) async {
    try {
      final p = await prefs;
      return await p.setBool(key, value);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving bool: $e');
      }
      return false;
    }
  }

  /// Get bool value
  Future<bool?> getBool(String key) async {
    try {
      final p = await prefs;
      return p.getBool(key);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting bool: $e');
      }
      return null;
    }
  }

  /// Save double value
  Future<bool> setDouble(String key, double value) async {
    try {
      final p = await prefs;
      return await p.setDouble(key, value);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving double: $e');
      }
      return false;
    }
  }

  /// Get double value
  Future<double?> getDouble(String key) async {
    try {
      final p = await prefs;
      return p.getDouble(key);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting double: $e');
      }
      return null;
    }
  }

  /// Save list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      final p = await prefs;
      return await p.setStringList(key, value);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving string list: $e');
      }
      return false;
    }
  }

  /// Get list of strings
  Future<List<String>?> getStringList(String key) async {
    try {
      final p = await prefs;
      return p.getStringList(key);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting string list: $e');
      }
      return null;
    }
  }

  /// Remove a key
  Future<bool> remove(String key) async {
    try {
      final p = await prefs;
      return await p.remove(key);
    } catch (e) {
      if (kDebugMode) {
        print('Error removing key: $e');
      }
      return false;
    }
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      final p = await prefs;
      return p.containsKey(key);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking key: $e');
      }
      return false;
    }
  }

  /// Get all keys
  Future<Set<String>> getKeys() async {
    try {
      final p = await prefs;
      return p.getKeys();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting keys: $e');
      }
      return {};
    }
  }

  // ========== Clear Methods ==========

  /// Clear all authentication data
  Future<bool> clearAuthData() async {
    try {
      await clearToken();
      await clearUserData();
      await clearRememberMe();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing auth data: $e');
      }
      return false;
    }
  }

  /// Clear all app settings
  Future<bool> clearSettings() async {
    try {
      final p = await prefs;
      await p.remove(_keyTheme);
      await p.remove(_keyLanguage);
      await p.remove(_keyNotifications);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing settings: $e');
      }
      return false;
    }
  }

  /// Clear all stored data
  Future<bool> clearAll() async {
    try {
      final p = await prefs;
      return await p.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all data: $e');
      }
      return false;
    }
  }

  // ========== Debugging Methods ==========

  /// Print all stored keys and values (debug only)
  Future<void> debugPrintAll() async {
    if (!kDebugMode) return;
    
    try {
      final p = await prefs;
      final keys = p.getKeys();
      print('=== StorageService Debug ===');
      for (var key in keys) {
        final value = p.get(key);
        print('$key: $value');
      }
      print('===========================');
    } catch (e) {
      print('Error in debugPrintAll: $e');
    }
  }

  /// Get storage size estimation (debug only)
  Future<int> getStorageSize() async {
    if (!kDebugMode) return 0;
    
    try {
      final p = await prefs;
      final keys = p.getKeys();
      int totalSize = 0;
      
      for (var key in keys) {
        final value = p.get(key);
        if (value != null) {
          totalSize += key.length + value.toString().length;
        }
      }
      
      return totalSize;
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating storage size: $e');
      }
      return 0;
    }
  }
}
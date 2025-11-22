import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import '../utils/api_config.dart';
import 'auth_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final AuthService _authService = AuthService();

  /// Get notifications with pagination and filter
  /// 
  /// [perPage] - Number of items per page (1-100)
  /// [page] - Page number
  /// [filter] - Filter type: 'all', 'read', 'unread'
  Future<Map<String, dynamic>> getNotifications({
    int perPage = 20,
    int page = 1,
    String filter = 'all',
  }) async {
    try {
      final token = _authService.token;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/notifications').replace(
        queryParameters: {
          'per_page': perPage.toString(),
          'page': page.toString(),
          if (filter != 'all') 'filter': filter,
        },
      );

      if (kDebugMode) {
        print('🔍 Fetching notifications: $uri');
      }

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('📥 Response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        final paginatedData = PaginatedNotifications.fromJson(jsonData['data']);
        final unreadCount = jsonData['unread_count'] as int;

        if (kDebugMode) {
          print('✅ Loaded ${paginatedData.data.length} notifications');
          print('   Unread count: $unreadCount');
        }

        return {
          'success': true,
          'data': paginatedData,
          'unread_count': unreadCount,
        };
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token expired');
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching notifications: $e');
      }
      rethrow;
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final token = _authService.token;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/notifications/unread');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final count = jsonData['unread_count'] as int;
        
        if (kDebugMode) {
          print('📊 Unread count: $count');
        }
        
        return count;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to get unread count');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting unread count: $e');
      }
      return 0;
    }
  }

  /// Get notification detail
  /// 
  /// ⚠️ This automatically marks the notification as read
  Future<AppNotification> getNotificationDetail(int notificationId) async {
    try {
      final token = _authService.token;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/notifications/$notificationId');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final notification = AppNotification.fromJson(jsonData['data']);
        
        if (kDebugMode) {
          print('✅ Loaded notification detail: ${notification.title}');
        }
        
        return notification;
      } else if (response.statusCode == 404) {
        throw Exception('Notification not found');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to load notification detail');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching notification detail: $e');
      }
      rethrow;
    }
  }

  /// Mark a notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      final token = _authService.token;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/notifications/$notificationId/read');

      final response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Marked notification $notificationId as read');
        }
        return true;
      } else {
        throw Exception('Failed to mark as read');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error marking as read: $e');
      }
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final token = _authService.token;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/notifications/read-all');

      final response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Marked all notifications as read');
        }
        return true;
      } else {
        throw Exception('Failed to mark all as read');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error marking all as read: $e');
      }
      return false;
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final token = _authService.token;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/notifications/$notificationId');

      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Deleted notification $notificationId');
        }
        return true;
      } else if (response.statusCode == 404) {
        // Already deleted
        return true;
      } else {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting notification: $e');
      }
      return false;
    }
  }
}

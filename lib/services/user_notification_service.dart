import 'package:dio/dio.dart';
import '../models/user_notification.dart';
import 'http_client.dart';

/// Service để gọi API User Notifications (Broadcast system)
/// Base URL: /api/notifications
/// 
/// Tham khảo: MOBILE_API_INTEGRATION_GUIDE.md

class UserNotificationService {
  final Dio _dio = HttpClient().dio;
  static const String _baseUrl = '/api/notifications';

  // 1. GET List notifications với pagination và filters
  Future<UserNotificationListResponse> getNotifications({
    int page = 1,
    int perPage = 20,
    String? filter, // all | read | unread
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (filter != null && filter != 'all') {
        queryParams['filter'] = filter;
      }

      final response = await _dio.get(
        _baseUrl,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        return UserNotificationListResponse.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load notifications');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 2. GET Unread count
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('$_baseUrl/unread-count');

      if (response.data['success'] == true) {
        final data = UnreadCountResponse.fromJson(response.data['data']);
        return data.unreadCount;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get unread count');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 3. GET Notification detail (auto marks as read)
  Future<UserNotification> getNotificationDetail(int id) async {
    try {
      final response = await _dio.get('$_baseUrl/$id');

      if (response.data['success'] == true) {
        return UserNotification.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load notification detail');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 4. PATCH Mark as read
  Future<void> markAsRead(int id) async {
    try {
      final response = await _dio.patch('$_baseUrl/$id/read');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to mark as read');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 5. PATCH Mark all as read
  Future<void> markAllAsRead() async {
    try {
      final response = await _dio.patch('$_baseUrl/read-all');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to mark all as read');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 6. DELETE Notification
  Future<void> deleteNotification(int id) async {
    try {
      final response = await _dio.delete('$_baseUrl/$id');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete notification');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Helper: Handle Dio errors
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      
      // Return message if available
      if (data is Map && data['message'] != null) {
        return Exception(data['message'].toString());
      }
      
      // Status code specific messages
      switch (e.response!.statusCode) {
        case 401:
          return Exception('Unauthorized. Please login again.');
        case 403:
          return Exception('Access denied.');
        case 404:
          return Exception('Notification not found');
        case 500:
          return Exception('Server error. Please try again later.');
        default:
          return Exception('Error: ${e.response!.statusCode}');
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return Exception('Connection timeout. Please check your internet connection.');
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return Exception('Receive timeout. Please try again.');
    } else {
      return Exception('Network error. Please check your connection.');
    }
  }
}

import 'package:flutter/foundation.dart';
import '../models/user_notification.dart';
import '../services/user_notification_service.dart';

/// Provider cho User Notifications (Broadcast từ admin/chair)
/// State management với ChangeNotifier pattern
/// 
/// Tham khảo: MOBILE_API_INTEGRATION_GUIDE.md

class UserNotificationProvider with ChangeNotifier {
  final UserNotificationService _service = UserNotificationService();

  // ==================== State ====================
  
  List<UserNotification> _notifications = [];
  int _unreadCount = 0;
  PaginationData? _pagination;
  UserNotification? _currentDetail;

  // Loading states
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingDetail = false;
  bool _isMarkingRead = false;
  bool _isDeleting = false;

  // Filter state
  String _currentFilter = 'all'; // all | read | unread

  // Error state
  String? _error;

  // ==================== Getters ====================
  
  List<UserNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  PaginationData? get pagination => _pagination;
  UserNotification? get currentDetail => _currentDetail;
  
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isMarkingRead => _isMarkingRead;
  bool get isDeleting => _isDeleting;
  
  String get currentFilter => _currentFilter;
  String? get error => _error;

  bool get hasMore => _pagination?.hasMore ?? false;
  int get currentPage => _pagination?.currentPage ?? 1;
  int get totalNotifications => _pagination?.total ?? _notifications.length;

  // Filter getters
  List<UserNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  
  List<UserNotification> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();

  // ==================== 1. Load Notifications ====================
  
  /// Load danh sách notifications (với phân trang)
  /// 
  /// **Parameters:**
  /// - `filter`: "all" | "read" | "unread"
  /// - `perPage`: Số items mỗi trang (default: 20, max: 100)
  /// - `page`: Số trang (default: 1)
  /// - `refresh`: true = clear data cũ, false = append vào list
  Future<void> loadNotifications({
    String? filter,
    int perPage = 20,
    int page = 1,
    bool refresh = false,
  }) async {
    if (refresh) {
      _notifications.clear();
      _pagination = null;
      _currentFilter = filter ?? 'all';
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getNotifications(
        filter: filter ?? _currentFilter,
        perPage: perPage,
        page: page,
      );

      if (page == 1) {
        _notifications = response.notifications;
      } else {
        _notifications.addAll(response.notifications);
      }

      _unreadCount = response.unreadCount;
      _pagination = response.pagination;

      print('✅ [UserNotificationProvider] Loaded ${_notifications.length} notifications');
      print('   📊 Unread: $_unreadCount | Total: ${_pagination?.total}');
    } catch (e) {
      _error = e.toString();
      print('❌ [UserNotificationProvider] Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more (pagination) - gọi khi user scroll đến cuối list
  Future<void> loadMore() async {
    if (!hasMore || _isLoadingMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = currentPage + 1;
      
      final response = await _service.getNotifications(
        filter: _currentFilter,
        page: nextPage,
      );

      _notifications.addAll(response.notifications);
      _pagination = response.pagination;

      print('✅ [UserNotificationProvider] Loaded more: page $nextPage');
    } catch (e) {
      _error = e.toString();
      print('❌ [UserNotificationProvider] Error loading more: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Refresh (pull-to-refresh)
  Future<void> refresh() async {
    await loadNotifications(
      filter: _currentFilter,
      refresh: true,
    );
  }

  /// Change filter (all/read/unread) và reload
  Future<void> changeFilter(String filter) async {
    if (_currentFilter == filter) return;

    _currentFilter = filter;
    await loadNotifications(filter: filter, refresh: true);
  }

  // ==================== 2. Unread Count ====================
  
  /// Load unread count (cho badge)
  /// 
  /// **Use case:**
  /// - Poll mỗi 30s khi app active
  /// - Update khi app resume từ background
  Future<void> loadUnreadCount() async {
    try {
      final count = await _service.getUnreadCount();
      
      if (_unreadCount != count) {
        _unreadCount = count;
        print('📊 [UserNotificationProvider] Unread count updated: $_unreadCount');
        notifyListeners();
      }
    } catch (e) {
      print('❌ [UserNotificationProvider] Error loading unread count: $e');
      // Don't update error state for background polling
    }
  }

  // ==================== 3. Load Detail ====================
  
  /// Load chi tiết notification
  /// 
  /// **⚠️ IMPORTANT:** Endpoint tự động mark notification as read!
  Future<void> loadNotificationDetail(int notificationId) async {
    _isLoadingDetail = true;
    _error = null;
    notifyListeners();

    try {
      _currentDetail = await _service.getNotificationDetail(notificationId);
      
      // Update notification trong list (đã được mark as read)
      final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
      if (index != -1) {
        _notifications[index] = _currentDetail!;
        
        // Decrease unread count nếu notification vừa được đọc
        if (_currentDetail!.isRead && _unreadCount > 0) {
          _unreadCount--;
        }
      }

      print('✅ [UserNotificationProvider] Loaded detail #$notificationId');
      print('   📖 Auto marked as read: ${_currentDetail!.isRead}');
    } catch (e) {
      _error = e.toString();
      print('❌ [UserNotificationProvider] Error loading detail: $e');
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // ==================== 4. Mark as Read ====================
  
  /// Đánh dấu 1 notification đã đọc
  /// 
  /// **Use case:**
  /// - User swipe notification
  /// - User tap "Đánh dấu đã đọc" button
  Future<bool> markAsRead(int notificationId) async {
    _isMarkingRead = true;
    _error = null;
    notifyListeners();

    try {
      await _service.markAsRead(notificationId);
      
      // Update notification trong list
      final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
      if (index != -1) {
        final wasUnread = !_notifications[index].isRead;
        _notifications[index] = _notifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        
        // Decrease unread count
        if (wasUnread && _unreadCount > 0) {
          _unreadCount--;
        }
      }

      print('✅ [UserNotificationProvider] Marked #$notificationId as read');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ [UserNotificationProvider] Error marking as read: $e');
      notifyListeners();
      return false;
    } finally {
      _isMarkingRead = false;
    }
  }

  /// Đánh dấu TẤT CẢ đã đọc
  /// 
  /// **Use case:**
  /// - User tap "Đánh dấu tất cả đã đọc"
  /// - Clear badge về 0
  Future<bool> markAllAsRead() async {
    _isMarkingRead = true;
    _error = null;
    notifyListeners();

    try {
      await _service.markAllAsRead();
      
      // Update tất cả notifications trong list
      _notifications = _notifications.map((n) {
        return n.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }).toList();
      
      _unreadCount = 0;
      
      print('✅ [UserNotificationProvider] Marked all as read');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ [UserNotificationProvider] Error marking all as read: $e');
      notifyListeners();
      return false;
    } finally {
      _isMarkingRead = false;
    }
  }

  // ==================== 5. Delete Notification ====================
  
  /// Xóa 1 notification
  /// 
  /// **⚠️ WARNING:** Xóa vĩnh viễn, không thể khôi phục!
  Future<bool> deleteNotification(int notificationId) async {
    _isDeleting = true;
    _error = null;
    notifyListeners();

    try {
      // Optimistic update: xóa khỏi UI ngay
      final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
      UserNotification? deletedNotification;
      
      if (index != -1) {
        deletedNotification = _notifications[index];
        _notifications.removeAt(index);
        
        // Decrease unread count nếu notification chưa đọc
        if (!deletedNotification.isRead && _unreadCount > 0) {
          _unreadCount--;
        }
        
        notifyListeners(); // Update UI ngay
      }

      // Call API
      await _service.deleteNotification(notificationId);
      
      print('✅ [UserNotificationProvider] Deleted #$notificationId');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ [UserNotificationProvider] Error deleting: $e');
      notifyListeners();
      return false;
    } finally {
      _isDeleting = false;
    }
  }

  /// Xóa nhiều notifications (batch delete)
  Future<bool> deleteMultiple(List<int> notificationIds) async {
    _isDeleting = true;
    _error = null;
    notifyListeners();

    try {
      // Delete one by one since API doesn't have batch delete
      for (final id in notificationIds) {
        await _service.deleteNotification(id);
      }

      // Remove deleted notifications from list
      _notifications.removeWhere((n) => notificationIds.contains(n.notificationId));
      
      // Recalculate unread count
      await loadUnreadCount();

      print('✅ [UserNotificationProvider] Deleted ${notificationIds.length} notifications');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ [UserNotificationProvider] Error batch delete: $e');
      notifyListeners();
      return false;
    } finally {
      _isDeleting = false;
    }
  }

  // ==================== Helper Methods ====================

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _notifications.clear();
    _unreadCount = 0;
    _pagination = null;
    _currentDetail = null;
    _currentFilter = 'all';
    _error = null;
    _isLoading = false;
    _isLoadingMore = false;
    _isLoadingDetail = false;
    _isMarkingRead = false;
    _isDeleting = false;
    notifyListeners();
  }

  /// Get notification by ID from local list
  UserNotification? getNotificationById(int id) {
    try {
      return _notifications.firstWhere((n) => n.notificationId == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if notification exists in local list
  bool hasNotification(int id) {
    return _notifications.any((n) => n.notificationId == id);
  }

  /// Update notification in local list
  void updateNotificationInList(UserNotification notification) {
    final index = _notifications.indexWhere((n) => n.notificationId == notification.notificationId);
    if (index != -1) {
      _notifications[index] = notification;
      notifyListeners();
    }
  }
}

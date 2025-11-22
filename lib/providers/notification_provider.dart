import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _currentFilter = 'all'; // 'all', 'read', 'unread'
  String? _error;

  // Getters
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get currentFilter => _currentFilter;
  String? get error => _error;
  bool get hasNotifications => _notifications.isNotEmpty;

  /// Load initial notifications
  Future<void> loadNotifications({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _notifications = [];
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getNotifications(
        page: _currentPage,
        filter: _currentFilter,
        perPage: 20,
      );

      if (result['success'] == true) {
        final paginatedData = result['data'] as PaginatedNotifications;
        
        if (refresh) {
          _notifications = paginatedData.data;
        } else {
          _notifications.addAll(paginatedData.data);
        }
        
        _unreadCount = result['unread_count'] as int;
        _hasMore = paginatedData.hasMore;

        if (kDebugMode) {
          print('✅ Loaded ${paginatedData.data.length} notifications');
          print('   Total: ${_notifications.length}, Unread: $_unreadCount');
        }
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ Error loading notifications: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;

    _currentPage++;
    await loadNotifications();
  }

  /// Refresh notifications (pull to refresh)
  Future<void> refresh() async {
    await loadNotifications(refresh: true);
  }

  /// Change filter
  Future<void> setFilter(String filter) async {
    if (_currentFilter == filter) return;
    
    _currentFilter = filter;
    _currentPage = 1;
    _notifications = [];
    _hasMore = true;
    
    await loadNotifications();
  }

  /// Update unread count
  Future<void> updateUnreadCount() async {
    try {
      final count = await _service.getUnreadCount();
      _unreadCount = count;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating unread count: $e');
      }
    }
  }

  /// Mark notification as read (optimistic update)
  Future<void> markAsRead(int notificationId) async {
    // Optimistic update
    final index = _notifications.indexWhere(
      (n) => n.notificationId == notificationId,
    );
    
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
      _unreadCount = (_unreadCount - 1).clamp(0, 999);
      notifyListeners();

      // Call API
      try {
        await _service.markAsRead(notificationId);
      } catch (e) {
        // Rollback on failure
        _notifications[index] = _notifications[index].copyWith(
          isRead: false,
          readAt: null,
        );
        _unreadCount++;
        notifyListeners();
        
        if (kDebugMode) {
          print('❌ Failed to mark as read, rolled back');
        }
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    // Optimistic update
    final oldNotifications = List<AppNotification>.from(_notifications);
    final oldUnreadCount = _unreadCount;
    
    _notifications = _notifications.map((n) {
      return n.copyWith(isRead: true, readAt: DateTime.now());
    }).toList();
    _unreadCount = 0;
    notifyListeners();

    // Call API
    try {
      final success = await _service.markAllAsRead();
      if (!success) {
        throw Exception('Failed to mark all as read');
      }
    } catch (e) {
      // Rollback on failure
      _notifications = oldNotifications;
      _unreadCount = oldUnreadCount;
      notifyListeners();
      
      if (kDebugMode) {
        print('❌ Failed to mark all as read, rolled back');
      }
      rethrow;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(int notificationId) async {
    // Optimistic update
    final oldNotifications = List<AppNotification>.from(_notifications);
    final deletedNotification = _notifications.firstWhere(
      (n) => n.notificationId == notificationId,
    );
    
    _notifications.removeWhere((n) => n.notificationId == notificationId);
    
    if (!deletedNotification.isRead) {
      _unreadCount = (_unreadCount - 1).clamp(0, 999);
    }
    
    notifyListeners();

    // Call API
    try {
      final success = await _service.deleteNotification(notificationId);
      if (!success) {
        throw Exception('Failed to delete');
      }
      return true;
    } catch (e) {
      // Rollback on failure
      _notifications = oldNotifications;
      if (!deletedNotification.isRead) {
        _unreadCount++;
      }
      notifyListeners();
      
      if (kDebugMode) {
        print('❌ Failed to delete notification, rolled back');
      }
      return false;
    }
  }

  /// Get notification by ID from cache
  AppNotification? getNotificationById(int id) {
    try {
      return _notifications.firstWhere((n) => n.notificationId == id);
    } catch (e) {
      return null;
    }
  }

  /// Fetch notification by ID from API (for detail screen)
  Future<AppNotification?> fetchNotificationById(int id) async {
    try {
      // First check cache
      final cached = getNotificationById(id);
      if (cached != null) return cached;

      // If not in cache, fetch from API
      final notification = await _service.getNotificationDetail(id);
      
      // Update cache - notification is never null from API
      final index = _notifications.indexWhere((n) => n.notificationId == id);
      if (index != -1) {
        _notifications[index] = notification;
      } else {
        _notifications.insert(0, notification);
      }
      notifyListeners();
      
      return notification;
    } catch (e) {
      debugPrint('Error fetching notification $id: $e');
      return null;
    }
  }

  /// Clear all data
  void clear() {
    _notifications = [];
    _unreadCount = 0;
    _currentPage = 1;
    _hasMore = true;
    _currentFilter = 'all';
    _error = null;
    notifyListeners();
  }
}

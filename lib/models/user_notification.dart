import 'package:intl/intl.dart';

/// Model cho User Notifications (broadcast từ admin/chair)
/// Đồng bộ 100% với API backend: GET /api/notifications
/// 
/// Tham khảo: MOBILE_API_INTEGRATION_GUIDE.md

class UserNotification {
  final int notificationId;
  final int userId;
  final int? conferenceId; // null cho broadcast
  final int? announcementId; // ID của announcement gốc
  final String type; // BROADCAST | ANNOUNCEMENT | REMINDER
  final String title;
  final String message; // Có thể chứa HTML
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserNotification({
    required this.notificationId,
    required this.userId,
    this.conferenceId,
    this.announcementId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse từ JSON response của backend
  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      notificationId: json['notification_id'] as int,
      userId: json['user_id'] as int,
      conferenceId: json['conference_id'] as int?,
      announcementId: json['announcement_id'] as int?,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] == true || json['is_read'] == 1,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'conference_id': conferenceId,
      'announcement_id': announcementId,
      'type': type,
      'title': title,
      'message': message,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with modifications
  UserNotification copyWith({
    int? notificationId,
    int? userId,
    int? conferenceId,
    int? announcementId,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserNotification(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      conferenceId: conferenceId ?? this.conferenceId,
      announcementId: announcementId ?? this.announcementId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==================== Display Helpers ====================

  /// Icon theo loại notification
  String get typeIcon {
    switch (type.toUpperCase()) {
      case 'BROADCAST':
        return '📢';
      case 'ANNOUNCEMENT':
        return '📣';
      case 'REMINDER':
        return '⏰';
      default:
        return '🔔';
    }
  }

  /// Màu theo loại notification
  String get typeColor {
    switch (type.toUpperCase()) {
      case 'BROADCAST':
        return '#2196F3'; // Blue
      case 'ANNOUNCEMENT':
        return '#FF9800'; // Orange
      case 'REMINDER':
        return '#4CAF50'; // Green
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Text hiển thị loại
  String get typeText {
    switch (type.toUpperCase()) {
      case 'BROADCAST':
        return 'Thông báo hệ thống';
      case 'ANNOUNCEMENT':
        return 'Thông báo';
      case 'REMINDER':
        return 'Nhắc nhở';
      default:
        return type;
    }
  }

  /// Format thời gian tương đối (2 giờ trước, 1 ngày trước)
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    }
  }

  /// Format ngày giờ đầy đủ (dd/MM/yyyy HH:mm)
  String get formattedDateTime {
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  }

  /// Format ngày đọc (nếu đã đọc)
  String? get formattedReadAt {
    if (readAt == null) return null;
    return DateFormat('dd/MM/yyyy HH:mm').format(readAt!);
  }

  /// Message preview (50 ký tự đầu, bỏ HTML tags)
  String get messagePreview {
    // Remove HTML tags
    String cleaned = message.replaceAll(RegExp(r'<[^>]*>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    if (cleaned.length <= 50) return cleaned;
    return '${cleaned.substring(0, 50)}...';
  }

  /// Kiểm tra notification có chứa HTML không
  bool get hasHtmlContent {
    return message.contains('<') && message.contains('>');
  }

  @override
  String toString() {
    return 'UserNotification(id: $notificationId, title: $title, isRead: $isRead, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserNotification && other.notificationId == notificationId;
  }

  @override
  int get hashCode => notificationId.hashCode;
}

// ==================== Response Models ====================

/// Response cho GET /api/notifications (paginated)
class UserNotificationListResponse {
  final List<UserNotification> notifications;
  final int unreadCount;
  final PaginationData pagination;

  UserNotificationListResponse({
    required this.notifications,
    required this.unreadCount,
    required this.pagination,
  });

  factory UserNotificationListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final notificationsList = data['data'] as List<dynamic>;

    return UserNotificationListResponse(
      notifications: notificationsList
          .map((item) => UserNotification.fromJson(item as Map<String, dynamic>))
          .toList(),
      unreadCount: json['unread_count'] as int? ?? 0,
      pagination: PaginationData.fromJson(data),
    );
  }

  bool get hasMore => pagination.hasMore;
  int get currentPage => pagination.currentPage;
  int get totalPages => pagination.lastPage;
}

/// Pagination data từ Laravel
class PaginationData {
  final int currentPage;
  final int from;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final int perPage;
  final int to;
  final int total;

  PaginationData({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      currentPage: json['current_page'] as int,
      from: json['from'] as int? ?? 0,
      lastPage: json['last_page'] as int,
      nextPageUrl: json['next_page_url'] as String?,
      prevPageUrl: json['prev_page_url'] as String?,
      perPage: json['per_page'] as int,
      to: json['to'] as int? ?? 0,
      total: json['total'] as int,
    );
  }

  bool get hasMore => nextPageUrl != null;
  bool get hasPrev => prevPageUrl != null;
}

/// Response cho GET /api/notifications/unread
class UnreadCountResponse {
  final int unreadCount;

  UnreadCountResponse({required this.unreadCount});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      unreadCount: json['unread_count'] as int,
    );
  }
}

/// Response cho GET /api/notifications/{id}
class UserNotificationDetailResponse {
  final UserNotification notification;

  UserNotificationDetailResponse({required this.notification});

  factory UserNotificationDetailResponse.fromJson(Map<String, dynamic> json) {
    return UserNotificationDetailResponse(
      notification: UserNotification.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

/// Response cho PATCH /api/notifications/{id}/read
class MarkReadResponse {
  final String message;
  final UserNotification notification;

  MarkReadResponse({
    required this.message,
    required this.notification,
  });

  factory MarkReadResponse.fromJson(Map<String, dynamic> json) {
    return MarkReadResponse(
      message: json['message'] as String,
      notification: UserNotification.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

/// Response cho DELETE /api/notifications/{id}
class DeleteNotificationResponse {
  final bool success;
  final String message;

  DeleteNotificationResponse({
    required this.success,
    required this.message,
  });

  factory DeleteNotificationResponse.fromJson(Map<String, dynamic> json) {
    return DeleteNotificationResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String,
    );
  }
}

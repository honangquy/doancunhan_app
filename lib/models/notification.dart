class AppNotification {
  final int notificationId;
  final int userId;
  final int? conferenceId;
  final int? announcementId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppNotification({
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

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      notificationId: int.parse(json['notification_id']?.toString() ?? '0'),
      userId: int.parse(json['user_id']?.toString() ?? '0'),
      conferenceId: json['conference_id'] != null 
          ? int.tryParse(json['conference_id'].toString()) 
          : null,
      announcementId: json['announcement_id'] != null
          ? int.tryParse(json['announcement_id'].toString())
          : null,
      type: json['type']?.toString() ?? 'BROADCAST',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: json['is_read'] == true || json['is_read']?.toString() == '1',
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at'].toString()) 
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
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

  /// Get display type in Vietnamese
  String get displayType {
    switch (type.toUpperCase()) {
      case 'BROADCAST':
        return 'Thông báo chung';
      case 'ANNOUNCEMENT':
        return 'Thông báo';
      case 'REMINDER':
        return 'Nhắc nhở';
      default:
        return type;
    }
  }

  /// Get icon for notification type
  String get icon {
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

  /// Create a copy with updated fields
  AppNotification copyWith({
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
    return AppNotification(
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

  @override
  String toString() {
    return 'AppNotification(id: $notificationId, title: $title, isRead: $isRead)';
  }
}

/// Paginated response wrapper
class PaginatedNotifications {
  final int currentPage;
  final List<AppNotification> data;
  final String? firstPageUrl;
  final int from;
  final int lastPage;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  PaginatedNotifications({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    required this.from,
    required this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory PaginatedNotifications.fromJson(Map<String, dynamic> json) {
    return PaginatedNotifications(
      currentPage: json['current_page'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstPageUrl: json['first_page_url'] as String?,
      from: json['from'] as int,
      lastPage: json['last_page'] as int,
      lastPageUrl: json['last_page_url'] as String?,
      nextPageUrl: json['next_page_url'] as String?,
      path: json['path'] as String,
      perPage: json['per_page'] as int,
      prevPageUrl: json['prev_page_url'] as String?,
      to: json['to'] as int,
      total: json['total'] as int,
    );
  }

  bool get hasMore => nextPageUrl != null;
}

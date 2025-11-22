// Announcement Model - Complete version matching API
class Announcement {
  final int announcementId;
  final int conferenceId;
  final String conferenceName;
  final String title;
  final String content;
  final String audience; // ALL, AUTHORS, REVIEWERS, CHAIRS
  final List<String> channels; // SYSTEM, EMAIL, CHATBOT
  final String status; // SCHEDULED, SENT, FAILED
  final DateTime scheduledAt;
  final DateTime? sentAt;
  final int? createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final int? recipientCount; // For Chair
  final bool? isRead; // For User
  final DateTime? readAt; // For User
  final DateTime? receivedAt; // For User
  final AnnouncementStatistics? statistics; // For detail view

  Announcement({
    required this.announcementId,
    required this.conferenceId,
    required this.conferenceName,
    required this.title,
    required this.content,
    required this.audience,
    required this.channels,
    required this.status,
    required this.scheduledAt,
    this.sentAt,
    this.createdBy,
    this.createdByName,
    required this.createdAt,
    this.recipientCount,
    this.isRead,
    this.readAt,
    this.receivedAt,
    this.statistics,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      announcementId: json['announcement_id'] ?? 0,
      conferenceId: json['conference_id'] ?? 0,
      conferenceName: json['conference_name'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      audience: json['audience'] ?? 'ALL',
      channels: List<String>.from(json['channels'] ?? ['SYSTEM']),
      status: json['status'] ?? 'SCHEDULED',
      scheduledAt: DateTime.tryParse(json['scheduled_at'] ?? '') ?? DateTime.now(),
      sentAt: json['sent_at'] != null ? DateTime.tryParse(json['sent_at']) : null,
      createdBy: json['created_by'],
      createdByName: json['created_by_name'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      recipientCount: json['recipient_count'],
      isRead: json['is_read'] != null 
          ? (json['is_read'] is bool ? json['is_read'] : json['is_read'] == 1)
          : null,
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
      receivedAt: json['received_at'] != null ? DateTime.tryParse(json['received_at']) : null,
      statistics: json['statistics'] != null 
          ? AnnouncementStatistics.fromJson(json['statistics']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'announcement_id': announcementId,
      'conference_id': conferenceId,
      'conference_name': conferenceName,
      'title': title,
      'content': content,
      'audience': audience,
      'channels': channels,
      'status': status,
      'scheduled_at': scheduledAt.toIso8601String(),
      if (sentAt != null) 'sent_at': sentAt!.toIso8601String(),
      if (createdBy != null) 'created_by': createdBy,
      if (createdByName != null) 'created_by_name': createdByName,
      'created_at': createdAt.toIso8601String(),
      if (recipientCount != null) 'recipient_count': recipientCount,
      if (isRead != null) 'is_read': isRead,
      if (readAt != null) 'read_at': readAt!.toIso8601String(),
      if (receivedAt != null) 'received_at': receivedAt!.toIso8601String(),
      if (statistics != null) 'statistics': statistics!.toJson(),
    };
  }

  // Helper getters
  String get audienceText {
    switch (audience) {
      case 'ALL':
        return 'Tất cả';
      case 'AUTHORS':
        return 'Tác giả';
      case 'REVIEWERS':
        return 'Phản biện';
      case 'CHAIRS':
        return 'Chủ tịch';
      default:
        return audience;
    }
  }

  String get statusText {
    switch (status) {
      case 'SCHEDULED':
        return 'Đã lên lịch';
      case 'SENT':
        return 'Đã gửi';
      case 'FAILED':
        return 'Thất bại';
      default:
        return status;
    }
  }

  String get channelsText {
    return channels.map((c) {
      switch (c) {
        case 'SYSTEM':
          return 'Hệ thống';
        case 'EMAIL':
          return 'Email';
        case 'CHATBOT':
          return 'Chatbot';
        default:
          return c;
      }
    }).join(', ');
  }

  bool get isSent => status == 'SENT';
  bool get isScheduled => status == 'SCHEDULED';
  bool get isFailed => status == 'FAILED';
}

// Statistics Model
class Statistics {
  final int total;
  final int sent;
  final int scheduled;
  final int failed;

  Statistics({
    required this.total,
    required this.sent,
    required this.scheduled,
    required this.failed,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      total: json['total'] ?? 0,
      sent: json['sent'] ?? 0,
      scheduled: json['scheduled'] ?? 0,
      failed: json['failed'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'sent': sent,
      'scheduled': scheduled,
      'failed': failed,
    };
  }
}

// Announcement Statistics (for detail view)
class AnnouncementStatistics {
  final int totalRecipients;
  final int readCount;
  final int unreadCount;

  AnnouncementStatistics({
    required this.totalRecipients,
    required this.readCount,
    required this.unreadCount,
  });

  factory AnnouncementStatistics.fromJson(Map<String, dynamic> json) {
    return AnnouncementStatistics(
      totalRecipients: json['total_recipients'] ?? 0,
      readCount: json['read_count'] ?? 0,
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_recipients': totalRecipients,
      'read_count': readCount,
      'unread_count': unreadCount,
    };
  }

  double get readPercentage {
    if (totalRecipients == 0) return 0;
    return (readCount / totalRecipients) * 100;
  }
}

// Conference Model (for announcement creation)
class Conference {
  final int conferenceId;
  final String conferenceName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;

  Conference({
    required this.conferenceId,
    required this.conferenceName,
    this.startDate,
    this.endDate,
    this.status,
  });

  factory Conference.fromJson(Map<String, dynamic> json) {
    return Conference(
      conferenceId: json['conference_id'] ?? 0,
      conferenceName: json['conference_name'] ?? '',
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conference_id': conferenceId,
      'conference_name': conferenceName,
      if (startDate != null) 'start_date': startDate!.toIso8601String().split('T')[0],
      if (endDate != null) 'end_date': endDate!.toIso8601String().split('T')[0],
      if (status != null) 'status': status,
    };
  }
}

// Recipient Preview Model (matching API response)
class RecipientPreview {
  final int count;
  final String? audience;
  final int? conferenceId;
  final String? conferenceName;

  RecipientPreview({
    required this.count,
    this.audience,
    this.conferenceId,
    this.conferenceName,
  });

  factory RecipientPreview.fromJson(Map<String, dynamic> json) {
    return RecipientPreview(
      count: json['count'] ?? 0,
      audience: json['audience'],
      conferenceId: json['conference_id'],
      conferenceName: json['conference_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      if (audience != null) 'audience': audience,
      if (conferenceId != null) 'conference_id': conferenceId,
      if (conferenceName != null) 'conference_name': conferenceName,
    };
  }

  // Backwards compatibility getters
  int get totalRecipients => count;
  int get authors => 0; // Not provided by API
  int get reviewers => 0; // Not provided by API  
  int get chairs => 0; // Not provided by API
}

// Paginated Announcements Response
class PaginatedAnnouncements {
  final List<Announcement> announcements;
  final Statistics? statistics; // Only for Chair
  final int? unreadCount; // Only for User
  final Pagination? pagination;

  PaginatedAnnouncements({
    required this.announcements,
    this.statistics,
    this.unreadCount,
    this.pagination,
  });

  factory PaginatedAnnouncements.fromJson(Map<String, dynamic> json) {
    return PaginatedAnnouncements(
      announcements: (json['announcements'] as List?)
              ?.map((item) => Announcement.fromJson(item))
              .toList() ??
          [],
      statistics: json['statistics'] != null 
          ? Statistics.fromJson(json['statistics']) 
          : null,
      unreadCount: json['unread_count'],
      pagination: json['pagination'] != null 
          ? Pagination.fromJson(json['pagination']) 
          : null,
    );
  }
}

// Pagination Model
class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalItems: json['total_items'] ?? 0,
      perPage: json['per_page'] ?? 15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'per_page': perPage,
    };
  }

  bool get hasMore => currentPage < totalPages;
}

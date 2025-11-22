import 'package:flutter/material.dart';

/// Author Paper Model - theo FLUTTER_AUTHOR_API.md
/// Response từ GET /api/my-papers
class AuthorPaper {
  final int paperId;
  final String title;
  final String abstract;
  final String keywords;
  final String createdAt;
  final String statusCode;
  final String? filePath;
  final String conferenceTitle;
  final int conferenceId;
  final String? deadlineSubmission;
  final String? deadlineCameraReady;
  final String statusName;
  final bool canEdit;
  final String editReason;
  final bool canWithdraw;
  final String withdrawReason;
  final String formattedCreatedAt;
  final String? formattedDeadline;

  AuthorPaper({
    required this.paperId,
    required this.title,
    required this.abstract,
    required this.keywords,
    required this.createdAt,
    required this.statusCode,
    this.filePath,
    required this.conferenceTitle,
    required this.conferenceId,
    this.deadlineSubmission,
    this.deadlineCameraReady,
    required this.statusName,
    required this.canEdit,
    required this.editReason,
    required this.canWithdraw,
    required this.withdrawReason,
    required this.formattedCreatedAt,
    this.formattedDeadline,
  });

  factory AuthorPaper.fromJson(Map<String, dynamic> json) {
    return AuthorPaper(
      paperId: json['paper_id'] ?? 0,
      title: json['title'] ?? '',
      abstract: json['abstract'] ?? '',
      keywords: json['keywords'] ?? '',
      createdAt: json['created_at'] ?? '',
      statusCode: json['status_code'] ?? 'DRAFT',
      filePath: json['file_path'],
      conferenceTitle: json['conference_title'] ?? '',
      conferenceId: json['conference_id'] ?? 0,
      deadlineSubmission: json['deadline_submission'],
      deadlineCameraReady: json['deadline_camera_ready'],
      statusName: json['status_name'] ?? '',
      canEdit: json['can_edit'] ?? false,
      editReason: json['edit_reason'] ?? '',
      canWithdraw: json['can_withdraw'] ?? false,
      withdrawReason: json['withdraw_reason'] ?? '',
      formattedCreatedAt: json['formatted_created_at'] ?? '',
      formattedDeadline: json['formatted_deadline'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paper_id': paperId,
      'title': title,
      'abstract': abstract,
      'keywords': keywords,
      'created_at': createdAt,
      'status_code': statusCode,
      'file_path': filePath,
      'conference_title': conferenceTitle,
      'conference_id': conferenceId,
      'deadline_submission': deadlineSubmission,
      'deadline_camera_ready': deadlineCameraReady,
      'status_name': statusName,
      'can_edit': canEdit,
      'edit_reason': editReason,
      'can_withdraw': canWithdraw,
      'withdraw_reason': withdrawReason,
      'formatted_created_at': formattedCreatedAt,
      'formatted_deadline': formattedDeadline,
    };
  }

  // Status color helper
  Color get statusColor {
    switch (statusCode) {
      case 'DRAFT':
        return Colors.grey;
      case 'SUBMITTED':
        return Colors.blue;
      case 'UNDER_REVIEW':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'WITHDRAWN':
        return Colors.grey.shade600;
      default:
        return Colors.grey;
    }
  }
}

/// Paginated Papers Response
/// Response wrapper từ GET /api/my-papers
class PaginatedPapers {
  final int currentPage;
  final List<AuthorPaper> data;
  final String? firstPageUrl;
  final int? from;
  final int lastPage;
  final String? lastPageUrl;
  final List<PageLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  PaginatedPapers({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    this.from,
    required this.lastPage,
    this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    this.to,
    required this.total,
  });

  factory PaginatedPapers.fromJson(Map<String, dynamic> json) {
    return PaginatedPapers(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List?)
              ?.map((p) => AuthorPaper.fromJson(p))
              .toList() ??
          [],
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'],
      links: (json['links'] as List?)
              ?.map((l) => PageLink.fromJson(l))
              .toList() ??
          [],
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 15,
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }

  bool get hasNextPage => nextPageUrl != null;
  bool get hasPrevPage => prevPageUrl != null;
  bool get isEmpty => data.isEmpty;
}

/// Page Link for pagination UI
class PageLink {
  final String? url;
  final String label;
  final bool active;

  PageLink({
    this.url,
    required this.label,
    required this.active,
  });

  factory PageLink.fromJson(Map<String, dynamic> json) {
    return PageLink(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }
}

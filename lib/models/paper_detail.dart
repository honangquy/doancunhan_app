import 'package:flutter/material.dart';

/// Paper Detail Model - theo FLUTTER_AUTHOR_API.md spec
/// Response từ GET /api/papers/{id}
class PaperDetail {
  final int paperId;
  final int conferenceId;
  final int? trackId;
  final int submitterId;
  final String statusCode;
  final String title;
  final String abstract;
  final String keywords;
  final String? filePath;
  final String? withdrawalReason;
  final int? currentVersionId;
  final String createdAt;
  final String conferenceTitle;
  final String? deadlineSubmission;
  final String? deadlineCameraReady;
  final String statusName;
  
  // Related data
  final List<PaperAuthor> authors;
  final List<Assignment> assignments;
  final List<PaperReview> reviews;
  
  // Permissions
  final bool canEdit;
  final String editReason;
  final bool canWithdraw;
  final String withdrawReason;
  
  // Formatted dates
  final String formattedCreatedAt;
  final String? formattedDeadlineSubmission;
  final String? formattedDeadlineCameraReady;

  PaperDetail({
    required this.paperId,
    required this.conferenceId,
    this.trackId,
    required this.submitterId,
    required this.statusCode,
    required this.title,
    required this.abstract,
    required this.keywords,
    this.filePath,
    this.withdrawalReason,
    this.currentVersionId,
    required this.createdAt,
    required this.conferenceTitle,
    this.deadlineSubmission,
    this.deadlineCameraReady,
    required this.statusName,
    required this.authors,
    required this.assignments,
    required this.reviews,
    required this.canEdit,
    required this.editReason,
    required this.canWithdraw,
    required this.withdrawReason,
    required this.formattedCreatedAt,
    this.formattedDeadlineSubmission,
    this.formattedDeadlineCameraReady,
  });

  factory PaperDetail.fromJson(Map<String, dynamic> json) {
    // Response format: { paper: {...}, authors: [...], assignments: [...], reviews: [...], permissions: {...}, formatted_dates: {...} }
    final paper = json['paper'] as Map<String, dynamic>? ?? json;
    final permissions = json['permissions'] as Map<String, dynamic>? ?? {};
    final formattedDates = json['formatted_dates'] as Map<String, dynamic>? ?? {};
    
    return PaperDetail(
      paperId: paper['paper_id'] ?? 0,
      conferenceId: paper['conference_id'] ?? 0,
      trackId: paper['track_id'],
      submitterId: paper['submitter_id'] ?? 0,
      statusCode: paper['status_code'] ?? 'DRAFT',
      title: paper['title'] ?? '',
      abstract: paper['abstract'] ?? '',
      keywords: paper['keywords'] ?? '',
      filePath: paper['file_path'],
      withdrawalReason: paper['withdrawal_reason'],
      currentVersionId: paper['current_version_id'],
      createdAt: paper['created_at'] ?? '',
      conferenceTitle: paper['conference_title'] ?? '',
      deadlineSubmission: paper['deadline_submission'],
      deadlineCameraReady: paper['deadline_camera_ready'],
      statusName: paper['status_name'] ?? '',
      authors: (json['authors'] as List?)
              ?.map((a) => PaperAuthor.fromJson(a))
              .toList() ??
          [],
      assignments: (json['assignments'] as List?)
              ?.map((a) => Assignment.fromJson(a))
              .toList() ??
          [],
      reviews: (json['reviews'] as List?)
              ?.map((r) => PaperReview.fromJson(r))
              .toList() ??
          [],
      canEdit: permissions['can_edit'] ?? false,
      editReason: permissions['edit_reason'] ?? '',
      canWithdraw: permissions['can_withdraw'] ?? false,
      withdrawReason: permissions['withdraw_reason'] ?? '',
      formattedCreatedAt: formattedDates['created_at'] ?? '',
      formattedDeadlineSubmission: formattedDates['deadline_submission'],
      formattedDeadlineCameraReady: formattedDates['deadline_camera_ready'],
    );
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

/// Paper Author - theo API spec
class PaperAuthor {
  final int userId;
  final String fullName;
  final String email;
  final String? organization;
  final int authorOrder;
  final bool isContact;

  PaperAuthor({
    required this.userId,
    required this.fullName,
    required this.email,
    this.organization,
    required this.authorOrder,
    required this.isContact,
  });

  factory PaperAuthor.fromJson(Map<String, dynamic> json) {
    return PaperAuthor(
      userId: json['user_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      organization: json['organization'],
      authorOrder: json['author_order'] ?? 0,
      isContact: json['is_contact'] == 1 || json['is_contact'] == true,
    );
  }
}

/// Assignment (Reviewer Assignment) - theo API spec
class Assignment {
  final int assignmentId;
  final int userId;
  final String status;
  final String assignedAt;
  final String? reviewSubmittedAt;
  final String reviewerName;

  Assignment({
    required this.assignmentId,
    required this.userId,
    required this.status,
    required this.assignedAt,
    this.reviewSubmittedAt,
    required this.reviewerName,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      assignmentId: json['assignment_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      status: json['status'] ?? 'PENDING',
      assignedAt: json['assigned_at'] ?? '',
      reviewSubmittedAt: json['review_submitted_at'],
      reviewerName: json['reviewer_name'] ?? '',
    );
  }

  // Status helpers
  Color get statusColor {
    switch (status) {
      case 'PENDING':
        return Colors.grey;
      case 'ACCEPTED':
        return Colors.green;
      case 'DECLINED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case 'PENDING':
        return 'Đang chờ';
      case 'ACCEPTED':
        return 'Đã chấp nhận';
      case 'DECLINED':
        return 'Từ chối';
      case 'COMPLETED':
        return 'Hoàn thành';
      default:
        return status;
    }
  }
}

/// Paper Review - theo API spec
class PaperReview {
  final int reviewId;
  final int userId;
  final int paperId;
  final double? relevanceScore;
  final double? qualityScore;
  final double? originalityScore;
  final String? comments;
  final String? recommendation;
  final String submittedAt;
  final String reviewerName;

  PaperReview({
    required this.reviewId,
    required this.userId,
    required this.paperId,
    this.relevanceScore,
    this.qualityScore,
    this.originalityScore,
    this.comments,
    this.recommendation,
    required this.submittedAt,
    required this.reviewerName,
  });

  factory PaperReview.fromJson(Map<String, dynamic> json) {
    return PaperReview(
      reviewId: json['review_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      paperId: json['paper_id'] ?? 0,
      relevanceScore: json['relevance_score']?.toDouble(),
      qualityScore: json['quality_score']?.toDouble(),
      originalityScore: json['originality_score']?.toDouble(),
      comments: json['comments'],
      recommendation: json['recommendation'],
      submittedAt: json['submitted_at'] ?? '',
      reviewerName: json['reviewer_name'] ?? '',
    );
  }

  // Average score
  double? get averageScore {
    if (relevanceScore == null ||
        qualityScore == null ||
        originalityScore == null) {
      return null;
    }
    return (relevanceScore! + qualityScore! + originalityScore!) / 3;
  }
}

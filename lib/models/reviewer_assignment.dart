// Helper functions for safe parsing
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is double) return value.toInt();
  return 0;
}

int? _parseIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}

double? _parseDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return false;
}

class ReviewerAssignment {
  final int id;
  final int paperId;
  final String status;
  final DateTime assignedAt;
  final DateTime? responseAt;
  final DateTime? deadline;
  final String paperTitle;
  final String? paperAbstract;
  final String? keywords;
  final String? filePath;
  final String paperStatus;
  final int conferenceId;
  final String conferenceName;
  final String? assignedByName;
  final String? authorName;
  final String? authorEmail;
  final String? authorOrganization;

  ReviewerAssignment({
    required this.id,
    required this.paperId,
    required this.status,
    required this.assignedAt,
    this.responseAt,
    this.deadline,
    required this.paperTitle,
    this.paperAbstract,
    this.keywords,
    this.filePath,
    required this.paperStatus,
    required this.conferenceId,
    required this.conferenceName,
    this.assignedByName,
    this.authorName,
    this.authorEmail,
    this.authorOrganization,
  });

  factory ReviewerAssignment.fromJson(Map<String, dynamic> json) {
    return ReviewerAssignment(
      id: _parseInt(json['id']),
      paperId: _parseInt(json['paper_id']),
      status: json['status'] as String? ?? 'PENDING',
      assignedAt: json['assigned_at'] != null 
          ? DateTime.parse(json['assigned_at'] as String)
          : DateTime.now(),
      responseAt: json['response_at'] != null
          ? DateTime.parse(json['response_at'] as String)
          : null,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      paperTitle: json['paper_title'] as String? ?? 'Untitled',
      paperAbstract: json['paper_abstract'] as String?,
      keywords: json['keywords'] as String?,
      filePath: json['file_path'] as String? ?? json['paper_file'] as String?,
      paperStatus: json['paper_status'] as String? ?? 'SUBMITTED',
      conferenceId: _parseInt(json['conference_id']),
      conferenceName: json['conference_name'] as String? ?? 'Unknown Conference',
      assignedByName: json['assigned_by_name'] as String?,
      authorName: json['author_name'] as String?,
      authorEmail: json['author_email'] as String?,
      authorOrganization: json['author_organization'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paper_id': paperId,
      'status': status,
      'assigned_at': assignedAt.toIso8601String(),
      'response_at': responseAt?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'paper_title': paperTitle,
      'paper_abstract': paperAbstract,
      'keywords': keywords,
      'file_path': filePath,
      'paper_status': paperStatus,
      'conference_id': conferenceId,
      'conference_name': conferenceName,
      'assigned_by_name': assignedByName,
      'author_name': authorName,
      'author_email': authorEmail,
      'author_organization': authorOrganization,
    };
  }

  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isDeclined => status == 'DECLINED';
  bool get isCompleted => status == 'COMPLETED';
  bool get hasDeadline => deadline != null;
  bool get isOverdue => deadline != null && deadline!.isBefore(DateTime.now());
}

class PaperVersion {
  final int versionId;
  final int paperId;
  final int versionNo;
  final String filePath;
  final DateTime submittedAt;
  final String? note;

  PaperVersion({
    required this.versionId,
    required this.paperId,
    required this.versionNo,
    required this.filePath,
    required this.submittedAt,
    this.note,
  });

  factory PaperVersion.fromJson(Map<String, dynamic> json) {
    return PaperVersion(
      versionId: _parseInt(json['version_id']),
      paperId: _parseInt(json['paper_id']),
      versionNo: _parseInt(json['version_no']),
      filePath: json['file_path'] as String? ?? '',
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : DateTime.now(),
      note: json['note'] as String?,
    );
  }
}

class PaperAuthor {
  final int authorOrder;
  final bool isContact;
  final String? organization;
  final String fullName;
  final String email;

  PaperAuthor({
    required this.authorOrder,
    required this.isContact,
    this.organization,
    required this.fullName,
    required this.email,
  });

  factory PaperAuthor.fromJson(Map<String, dynamic> json) {
    return PaperAuthor(
      authorOrder: _parseInt(json['author_order']),
      isContact: _parseBool(json['is_contact']),
      organization: json['organization'] as String?,
      fullName: json['full_name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
    );
  }
}

class AssignmentDetail {
  final ReviewerAssignment assignment;
  final List<PaperVersion> versions;
  final List<PaperAuthor> authors;
  final Review? existingReview;

  AssignmentDetail({
    required this.assignment,
    required this.versions,
    required this.authors,
    this.existingReview,
  });

  factory AssignmentDetail.fromJson(Map<String, dynamic> json) {
    return AssignmentDetail(
      assignment: ReviewerAssignment.fromJson(json['assignment'] as Map<String, dynamic>),
      versions: (json['versions'] as List<dynamic>?)
              ?.map((v) => PaperVersion.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      authors: (json['authors'] as List<dynamic>?)
              ?.map((a) => PaperAuthor.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      existingReview: json['existing_review'] != null
          ? Review.fromJson(json['existing_review'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AssignmentStats {
  final int total;
  final int pending;
  final int accepted;
  final int completed;
  final int declined;

  AssignmentStats({
    required this.total,
    required this.pending,
    required this.accepted,
    required this.completed,
    required this.declined,
  });

  factory AssignmentStats.fromJson(Map<String, dynamic> json) {
    return AssignmentStats(
      total: _parseInt(json['total']),
      pending: _parseInt(json['pending']),
      accepted: _parseInt(json['accepted']),
      completed: _parseInt(json['completed']),
      declined: _parseInt(json['declined']),
    );
  }
}

class Review {
  final int reviewId;
  final int assignmentId;
  final int paperId;
  final int? scoreNovelty;
  final int? scoreRelevance;
  final int? scoreTechnicalQuality;
  final int? scorePresentation;
  final int? scoreReferences;
  final double? totalScore;
  final String? detailedComments;
  final String? recommendationCode;
  final bool isDraft;
  final DateTime? submittedAt;
  final String? reviewFilePath;
  final String? paperTitle;
  final String? paperAbstract;
  final String? conferenceName;
  final String? paperStatus;
  final DateTime? assignedAt;

  Review({
    required this.reviewId,
    required this.assignmentId,
    required this.paperId,
    this.scoreNovelty,
    this.scoreRelevance,
    this.scoreTechnicalQuality,
    this.scorePresentation,
    this.scoreReferences,
    this.totalScore,
    this.detailedComments,
    this.recommendationCode,
    required this.isDraft,
    this.submittedAt,
    this.reviewFilePath,
    this.paperTitle,
    this.paperAbstract,
    this.conferenceName,
    this.paperStatus,
    this.assignedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: _parseInt(json['review_id']),
      assignmentId: _parseInt(json['assignment_id']),
      paperId: _parseInt(json['paper_id']),
      scoreNovelty: _parseIntNullable(json['score_novelty']),
      scoreRelevance: _parseIntNullable(json['score_relevance']),
      scoreTechnicalQuality: _parseIntNullable(json['score_technical_quality']),
      scorePresentation: _parseIntNullable(json['score_presentation']),
      scoreReferences: _parseIntNullable(json['score_references']),
      totalScore: _parseDoubleNullable(json['total_score']),
      detailedComments: json['detailed_comments'] as String?,
      recommendationCode: json['recommendation_code'] as String?,
      isDraft: _parseBool(json['is_draft']),
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      reviewFilePath: json['review_file_path'] as String?,
      paperTitle: json['paper_title'] as String?,
      paperAbstract: json['paper_abstract'] as String?,
      conferenceName: json['conference_name'] as String?,
      paperStatus: json['paper_status'] as String?,
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'] as String)
          : null,
    );
  }

  bool get isComplete => !isDraft;
  bool get hasFile => reviewFilePath != null && reviewFilePath!.isNotEmpty;
}

class ReviewStats {
  final int total;
  final double averageScore;
  final int accept;
  final int reject;
  final int drafts;

  ReviewStats({
    required this.total,
    required this.averageScore,
    required this.accept,
    required this.reject,
    this.drafts = 0,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      total: _parseInt(json['total']),
      averageScore: _parseDoubleNullable(json['average_score']) ?? 0.0,
      accept: _parseInt(json['accept']),
      reject: _parseInt(json['reject']),
      drafts: _parseInt(json['drafts']),
    );
  }
}

class ReviewerDashboard {
  final AssignmentStats assignmentStats;
  final ReviewStats reviewStats;
  final List<ReviewerAssignment> recentAssignments;

  ReviewerDashboard({
    required this.assignmentStats,
    required this.reviewStats,
    required this.recentAssignments,
  });

  factory ReviewerDashboard.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    return ReviewerDashboard(
      assignmentStats: AssignmentStats.fromJson(
        stats['assignments'] as Map<String, dynamic>,
      ),
      reviewStats: ReviewStats.fromJson(
        stats['reviews'] as Map<String, dynamic>,
      ),
      recentAssignments: (json['recent_assignments'] as List<dynamic>?)
              ?.map((a) => ReviewerAssignment.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

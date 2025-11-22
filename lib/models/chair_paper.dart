class ChairPaper {
  final int paperId;
  final String title;
  final String abstract;
  final String keywords;
  final String statusCode;
  final String statusName;
  final String conferenceName;
  final String submittedAt;
  final ReviewerStats reviewers;

  ChairPaper({
    required this.paperId,
    required this.title,
    required this.abstract,
    required this.keywords,
    required this.statusCode,
    required this.statusName,
    required this.conferenceName,
    required this.submittedAt,
    required this.reviewers,
  });

  factory ChairPaper.fromJson(Map<String, dynamic> json) {
    return ChairPaper(
      paperId: _parseInt(json['paper_id']),
      title: json['title'] ?? '',
      abstract: json['abstract'] ?? '',
      keywords: json['keywords'] ?? '',
      statusCode: json['status_code'] ?? '',
      statusName: json['status_name'] ?? '',
      conferenceName: json['conference_name'] ?? '',
      submittedAt: json['submitted_at'] ?? '',
      reviewers: ReviewerStats.fromJson(json['reviewers'] ?? {}),
    );
  }
}

// Helper function to safely parse int from dynamic
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is double) return value.toInt();
  return 0;
}

class ReviewerStats {
  final int assigned;
  final int accepted;
  final int declined;
  final int pending;
  final int completed;
  final double? avgScore;
  final List<ReviewerInfo> list;

  ReviewerStats({
    required this.assigned,
    required this.accepted,
    required this.declined,
    required this.pending,
    required this.completed,
    this.avgScore,
    required this.list,
  });

  factory ReviewerStats.fromJson(Map<String, dynamic> json) {
    return ReviewerStats(
      assigned: _parseInt(json['assigned']),
      accepted: _parseInt(json['accepted']),
      declined: _parseInt(json['declined']),
      pending: _parseInt(json['pending']),
      completed: _parseInt(json['completed']),
      avgScore: json['avg_score']?.toDouble(),
      list: (json['list'] as List?)
          ?.map((e) => ReviewerInfo.fromJson(e))
          .toList() ?? [],
    );
  }
}

class ReviewerInfo {
  final String reviewerName;
  final String status;
  final bool reviewCompleted;

  ReviewerInfo({
    required this.reviewerName,
    required this.status,
    required this.reviewCompleted,
  });

  factory ReviewerInfo.fromJson(Map<String, dynamic> json) {
    return ReviewerInfo(
      reviewerName: json['reviewer_name'] ?? '',
      status: json['status'] ?? '',
      reviewCompleted: json['review_completed'] ?? false,
    );
  }
}

class PaginatedChairPapers {
  final List<ChairPaper> papers;
  final int currentPage;
  final int total;
  final int perPage;
  final int lastPage;

  PaginatedChairPapers({
    required this.papers,
    required this.currentPage,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory PaginatedChairPapers.fromJson(Map<String, dynamic> json) {
    return PaginatedChairPapers(
      papers: (json['papers'] as List?)
          ?.map((e) => ChairPaper.fromJson(e))
          .toList() ?? [],
      currentPage: _parseInt(json['pagination']?['current_page']),
      total: _parseInt(json['pagination']?['total']),
      perPage: _parseInt(json['pagination']?['per_page']),
      lastPage: _parseInt(json['pagination']?['last_page']),
    );
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPrevPage => currentPage > 1;
}

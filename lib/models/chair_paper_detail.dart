class ChairPaperDetail {
  final PaperInfo paper;
  final List<PaperAuthor> authors;
  final List<ReviewerAssignment> assignments;
  final List<PaperReview> reviews;

  ChairPaperDetail({
    required this.paper,
    required this.authors,
    required this.assignments,
    required this.reviews,
  });

  factory ChairPaperDetail.fromJson(Map<String, dynamic> json) {
    return ChairPaperDetail(
      paper: PaperInfo.fromJson(json['paper'] ?? {}),
      authors: (json['authors'] as List?)
          ?.map((e) => PaperAuthor.fromJson(e))
          .toList() ?? [],
      assignments: (json['assignments'] as List?)
          ?.map((e) => ReviewerAssignment.fromJson(e))
          .toList() ?? [],
      reviews: (json['reviews'] as List?)
          ?.map((e) => PaperReview.fromJson(e))
          .toList() ?? [],
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

// Helper function to safely parse bool from dynamic (handles 0/1 from API)
bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1';
  }
  return false;
}

class PaperInfo {
  final int paperId;
  final String title;
  final String abstract;
  final String keywords;
  final String statusCode;
  final String statusName;
  final String conferenceName;
  final String? trackName;
  final String submittedAt;

  PaperInfo({
    required this.paperId,
    required this.title,
    required this.abstract,
    required this.keywords,
    required this.statusCode,
    required this.statusName,
    required this.conferenceName,
    this.trackName,
    required this.submittedAt,
  });

  factory PaperInfo.fromJson(Map<String, dynamic> json) {
    return PaperInfo(
      paperId: _parseInt(json['paper_id']),
      title: json['title'] ?? '',
      abstract: json['abstract'] ?? '',
      keywords: json['keywords'] ?? '',
      statusCode: json['status_code'] ?? '',
      statusName: json['status_name'] ?? '',
      conferenceName: json['conference_name'] ?? '',
      trackName: json['track_name'],
      submittedAt: json['submitted_at'] ?? '',
    );
  }
}

class PaperAuthor {
  final String authorName;
  final String authorEmail;
  final String? authorOrganization;
  final int authorOrder;
  final bool isContact;

  PaperAuthor({
    required this.authorName,
    required this.authorEmail,
    this.authorOrganization,
    required this.authorOrder,
    required this.isContact,
  });

  factory PaperAuthor.fromJson(Map<String, dynamic> json) {
    return PaperAuthor(
      authorName: json['author_name'] ?? '',
      authorEmail: json['author_email'] ?? '',
      authorOrganization: json['author_organization'],
      authorOrder: _parseInt(json['author_order']),
      isContact: _parseBool(json['is_contact']),
    );
  }
}

class ReviewerAssignment {
  final int assignmentId;
  final String reviewerName;
  final String status;
  final int? reviewId;
  final int? totalScore;
  final String? recommendationCode;

  ReviewerAssignment({
    required this.assignmentId,
    required this.reviewerName,
    required this.status,
    this.reviewId,
    this.totalScore,
    this.recommendationCode,
  });

  factory ReviewerAssignment.fromJson(Map<String, dynamic> json) {
    return ReviewerAssignment(
      assignmentId: _parseInt(json['assignment_id']),
      reviewerName: json['reviewer_name'] ?? '',
      status: json['status'] ?? '',
      reviewId: _parseInt(json['review_id']),
      totalScore: _parseInt(json['total_score']),
      recommendationCode: json['recommendation_code'],
    );
  }
}

class PaperReview {
  final int reviewId;
  final String reviewerName;
  final int totalScore;
  final String recommendationCode;
  final String? detailedComments;
  final String? commentAuthor;
  final String? commentChair;
  final int? scoreNovelty;
  final int? scoreRelevance;
  final int? scoreTechnicalQuality;
  final int? scorePresentation;
  final int? scoreReferences;

  PaperReview({
    required this.reviewId,
    required this.reviewerName,
    required this.totalScore,
    required this.recommendationCode,
    this.detailedComments,
    this.commentAuthor,
    this.commentChair,
    this.scoreNovelty,
    this.scoreRelevance,
    this.scoreTechnicalQuality,
    this.scorePresentation,
    this.scoreReferences,
  });

  factory PaperReview.fromJson(Map<String, dynamic> json) {
    return PaperReview(
      reviewId: json['review_id'] ?? 0,
      reviewerName: json['reviewer_name'] ?? '',
      totalScore: json['total_score'] ?? 0,
      recommendationCode: json['recommendation_code'] ?? '',
      detailedComments: json['detailed_comments'],
      commentAuthor: json['comment_author'],
      commentChair: json['comment_chair'],
      scoreNovelty: json['score_novelty'],
      scoreRelevance: json['score_relevance'],
      scoreTechnicalQuality: json['score_technical_quality'],
      scorePresentation: json['score_presentation'],
      scoreReferences: json['score_references'],
    );
  }

  double? get averageScore {
    final scores = [
      scoreNovelty,
      scoreRelevance,
      scoreTechnicalQuality,
      scorePresentation,
      scoreReferences,
    ].whereType<int>();
    
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }
}

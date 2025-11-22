class ChairDashboard {
  final List<Conference> conferences;
  final ChairStatistics statistics;
  final List<RecentPaper> recentPapers;
  final List<PendingAction> pendingActions;

  ChairDashboard({
    required this.conferences,
    required this.statistics,
    required this.recentPapers,
    required this.pendingActions,
  });

  factory ChairDashboard.fromJson(Map<String, dynamic> json) {
    return ChairDashboard(
      conferences: (json['conferences'] as List?)
          ?.map((e) => Conference.fromJson(e))
          .toList() ?? [],
      statistics: ChairStatistics.fromJson(json['statistics'] ?? {}),
      recentPapers: (json['recent_papers'] as List?)
          ?.map((e) => RecentPaper.fromJson(e))
          .toList() ?? [],
      pendingActions: (json['pending_actions'] as List?)
          ?.map((e) => PendingAction.fromJson(e))
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

class Conference {
  final int conferenceId;
  final String conferenceName;
  final String? conferenceCode;

  Conference({
    required this.conferenceId,
    required this.conferenceName,
    this.conferenceCode,
  });

  factory Conference.fromJson(Map<String, dynamic> json) {
    return Conference(
      conferenceId: _parseInt(json['conference_id']),
      conferenceName: json['conference_name'] ?? '',
      conferenceCode: json['conference_code'],
    );
  }
}

class ChairStatistics {
  final int totalConferences;
  final int totalSubmissions;
  final int papersUnderReview;
  final int papersReviewed;
  final int acceptedAssignments;
  final int needsReviewers;
  final int pendingDecisions;
  final int decisionsMade;

  ChairStatistics({
    required this.totalConferences,
    required this.totalSubmissions,
    required this.papersUnderReview,
    required this.papersReviewed,
    required this.acceptedAssignments,
    required this.needsReviewers,
    required this.pendingDecisions,
    required this.decisionsMade,
  });

  factory ChairStatistics.fromJson(Map<String, dynamic> json) {
    return ChairStatistics(
      totalConferences: _parseInt(json['total_conferences']),
      totalSubmissions: _parseInt(json['total_submissions']),
      papersUnderReview: _parseInt(json['papers_under_review']),
      papersReviewed: _parseInt(json['papers_reviewed']),
      acceptedAssignments: _parseInt(json['accepted_assignments']),
      needsReviewers: _parseInt(json['needs_reviewers']),
      pendingDecisions: _parseInt(json['pending_decisions']),
      decisionsMade: _parseInt(json['decisions_made']),
    );
  }
}

class RecentPaper {
  final int paperId;
  final String title;
  final String statusCode;
  final String statusName;
  final String submittedAt;
  final int reviewersAssigned;
  final int reviewsCompleted;

  RecentPaper({
    required this.paperId,
    required this.title,
    required this.statusCode,
    required this.statusName,
    required this.submittedAt,
    required this.reviewersAssigned,
    required this.reviewsCompleted,
  });

  factory RecentPaper.fromJson(Map<String, dynamic> json) {
    return RecentPaper(
      paperId: _parseInt(json['paper_id']),
      title: json['title'] ?? '',
      statusCode: json['status_code'] ?? '',
      statusName: json['status_name'] ?? '',
      submittedAt: json['submitted_at'] ?? '',
      reviewersAssigned: _parseInt(json['reviewers_assigned']),
      reviewsCompleted: _parseInt(json['reviews_completed']),
    );
  }
}

class PendingAction {
  final String type;
  final int paperId;
  final String title;
  final String message;
  final String priority;

  PendingAction({
    required this.type,
    required this.paperId,
    required this.title,
    required this.message,
    required this.priority,
  });

  factory PendingAction.fromJson(Map<String, dynamic> json) {
    return PendingAction(
      type: json['type'] ?? '',
      paperId: _parseInt(json['paper_id']),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      priority: json['priority'] ?? 'low',
    );
  }
}

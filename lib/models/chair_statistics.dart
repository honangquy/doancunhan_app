class ReviewStatistics {
  final Map<String, int> papersByStatus;
  final List<ReviewerPerformance> reviewerPerformance;
  final Map<String, AvgScoreByRecommendation> avgScoresByRecommendation;

  ReviewStatistics({
    required this.papersByStatus,
    required this.reviewerPerformance,
    required this.avgScoresByRecommendation,
  });

  factory ReviewStatistics.fromJson(Map<String, dynamic> json) {
    return ReviewStatistics(
      papersByStatus: Map<String, int>.from(json['papers_by_status'] ?? {}),
      reviewerPerformance: (json['reviewer_performance'] as List?)
          ?.map((e) => ReviewerPerformance.fromJson(e))
          .toList() ?? [],
      avgScoresByRecommendation: (json['avg_scores_by_recommendation'] as Map?)
          ?.map((k, v) => MapEntry(k, AvgScoreByRecommendation.fromJson(v))) ?? {},
    );
  }
}

class ReviewerPerformance {
  final String reviewerName;
  final int totalAssigned;
  final int totalCompleted;
  final double? avgScore;
  final int acceptRecommendations;
  final int rejectRecommendations;

  ReviewerPerformance({
    required this.reviewerName,
    required this.totalAssigned,
    required this.totalCompleted,
    this.avgScore,
    required this.acceptRecommendations,
    required this.rejectRecommendations,
  });

  factory ReviewerPerformance.fromJson(Map<String, dynamic> json) {
    return ReviewerPerformance(
      reviewerName: json['reviewer_name'] ?? '',
      totalAssigned: json['total_assigned'] ?? 0,
      totalCompleted: json['total_completed'] ?? 0,
      avgScore: json['avg_score']?.toDouble(),
      acceptRecommendations: json['accept_recommendations'] ?? 0,
      rejectRecommendations: json['reject_recommendations'] ?? 0,
    );
  }

  double get completionRate {
    if (totalAssigned == 0) return 0;
    return (totalCompleted / totalAssigned) * 100;
  }
}

class AvgScoreByRecommendation {
  final String recommendation;
  final double avgScore;
  final int count;

  AvgScoreByRecommendation({
    required this.recommendation,
    required this.avgScore,
    required this.count,
  });

  factory AvgScoreByRecommendation.fromJson(Map<String, dynamic> json) {
    return AvgScoreByRecommendation(
      recommendation: json['recommendation'] ?? '',
      avgScore: (json['avg_score'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}

class ReviewerWithStats {
  final int userId;
  final String fullName;
  final String email;
  final String? organization;
  final int totalAssigned;
  final int totalCompleted;
  final int totalAccepted;
  final int totalDeclined;
  final int totalPending;
  final double? avgScore;

  ReviewerWithStats({
    required this.userId,
    required this.fullName,
    required this.email,
    this.organization,
    required this.totalAssigned,
    required this.totalCompleted,
    required this.totalAccepted,
    required this.totalDeclined,
    required this.totalPending,
    this.avgScore,
  });

  factory ReviewerWithStats.fromJson(Map<String, dynamic> json) {
    return ReviewerWithStats(
      userId: json['user_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      organization: json['organization'],
      totalAssigned: json['total_assigned'] ?? 0,
      totalCompleted: json['total_completed'] ?? 0,
      totalAccepted: json['total_accepted'] ?? 0,
      totalDeclined: json['total_declined'] ?? 0,
      totalPending: json['total_pending'] ?? 0,
      avgScore: json['avg_score']?.toDouble(),
    );
  }

  double get completionRate {
    if (totalAssigned == 0) return 0;
    return (totalCompleted / totalAssigned) * 100;
  }

  double get acceptanceRate {
    if (totalAssigned == 0) return 0;
    return (totalAccepted / totalAssigned) * 100;
  }
}

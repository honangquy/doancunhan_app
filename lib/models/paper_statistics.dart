class PaperStatistics {
  final int totalPapers;
  final Map<String, int> byStatus;
  final List<RecentPaper> recentPapers;

  PaperStatistics({
    required this.totalPapers,
    required this.byStatus,
    required this.recentPapers,
  });

  factory PaperStatistics.fromJson(Map<String, dynamic> json) {
    // Backend trả về: { total: 6, by_status: {...}, by_track: [...] }
    // Support cả 2 format: total và total_papers
    return PaperStatistics(
      totalPapers: json['total'] ?? json['total_papers'] ?? 0,
      byStatus: Map<String, int>.from(json['by_status'] ?? {}),
      recentPapers: (json['recent_papers'] as List?)
          ?.map((p) => RecentPaper.fromJson(p))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_papers': totalPapers,
      'by_status': byStatus,
      'recent_papers': recentPapers.map((p) => p.toJson()).toList(),
    };
  }
}

class RecentPaper {
  final int paperId;
  final String title;
  final String status;
  final DateTime createdAt;

  RecentPaper({
    required this.paperId,
    required this.title,
    required this.status,
    required this.createdAt,
  });

  factory RecentPaper.fromJson(Map<String, dynamic> json) {
    return RecentPaper(
      paperId: json['paper_id'] ?? json['id'] ?? 0,
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paper_id': paperId,
      'title': title,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

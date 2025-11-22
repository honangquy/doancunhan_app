class Paper {
  final String id;
  final String title;
  final String author;
  final String authorEmail;
  final String track; 
  final String abstract;
  final String keywords;
  final String status; // pending, reviewing, approved, rejected
  final DateTime submittedDate;
  final String? filePath;
  final double? score;
  final int reviewsCompleted;
  final int totalReviews;
  final List<Review>? reviews;
  final List<String>? authors; // Danh sách tác giả
  final double? reviewScore; // Điểm đánh giá
  final String? reviewStatus; // pending, completed, etc
  final String? reviewComments; // Comments from reviewers
  
  Paper({
    required this.track,
    required this.id,
    required this.title,
    required this.author,
    required this.authorEmail,
    required this.abstract,
    required this.keywords,
    required this.status,
    required this.submittedDate,
    this.filePath,
    this.score,
    this.reviewsCompleted = 0,
    this.totalReviews = 3,
    this.reviews,
    this.authors,
    this.reviewScore,
    this.reviewStatus,
    this.reviewComments,
  });
  
  // Convert from JSON (từ API)
  factory Paper.fromJson(Map<String, dynamic> json) {
    return Paper(
      track: json['track'] ?? '',
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      authorEmail: json['author_email'] ?? '',
      abstract: json['abstract'] ?? '',
      keywords: json['keywords'] ?? '',
      status: json['status'] ?? 'pending',
      submittedDate: json['submitted_date'] != null
          ? DateTime.parse(json['submitted_date'])
          : DateTime.now(),
      filePath: json['file_path'],
      score: json['score']?.toDouble(),
      reviewsCompleted: json['reviews_completed'] ?? 0,
      totalReviews: json['total_reviews'] ?? 3,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
              .map((r) => Review.fromJson(r))
              .toList()
          : null,
      authors: json['authors'] != null
          ? List<String>.from(json['authors'])
          : null,
      reviewScore: json['review_score']?.toDouble(),
      reviewStatus: json['review_status'],
      reviewComments: json['review_comments'],
    );
  }
  
  // Convert to JSON (gửi lên API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'author_email': authorEmail,
      'abstract': abstract,
      'keywords': keywords,
      'status': status,
      'submitted_date': submittedDate.toIso8601String(),
      'file_path': filePath,
      'score': score,
      'reviews_completed': reviewsCompleted,
      'total_reviews': totalReviews,
    };
  }
  
  // Getters tiện ích
  String get statusVietnamese {
    switch (status) {
      case 'pending':
        return 'Đang chờ';
      case 'reviewing':
        return 'Đang phản biện';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      default:
        return 'Không xác định';
    }
  }
  
  String get reviewProgress => '$reviewsCompleted/$totalReviews';
  
  bool get isCompleted => reviewsCompleted == totalReviews;
  
  // Mock data cho demo
  static List<Paper> getMockPapers() {
    return [
      Paper(
        track: 'AI',
        id: '1',
        title: 'Ứng dụng AI trong giáo dục',
        author: 'Nguyễn Văn A',
        authorEmail: 'author@huit.edu.vn',
        abstract: 'Nghiên cứu về ứng dụng AI trong giáo dục...',
        keywords: 'AI, Machine Learning, Education',
        status: 'reviewing',
        submittedDate: DateTime.now().subtract(const Duration(days: 5)),
        reviewsCompleted: 2,
        totalReviews: 3,
      ),
      Paper(
        track: 'Machine Learning',
        id: '2',
        title: 'Machine Learning cơ bản',
        author: 'Nguyễn Văn A',
        authorEmail: 'author@huit.edu.vn',
        abstract: 'Tổng quan về Machine Learning...',
        keywords: 'Machine Learning, Deep Learning',
        status: 'approved',
        submittedDate: DateTime.now().subtract(const Duration(days: 10)),
        score: 8.5,
        reviewsCompleted: 3,
        totalReviews: 3,
      ),
      Paper(
        track: 'Deep Learning',
        id: '3',
        title: 'Deep Learning và ứng dụng',
        author: 'Nguyễn Văn A',
        authorEmail: 'author@huit.edu.vn',
        abstract: 'Ứng dụng Deep Learning...',
        keywords: 'Deep Learning, Neural Networks',
        status: 'reviewing',
        submittedDate: DateTime.now().subtract(const Duration(days: 8)),
        reviewsCompleted: 1,
        totalReviews: 3,
      ),
    ];
  }
}

class Review {
  final String id;
  final String paperId;
  final String reviewerName;
  final String reviewerEmail;
  final double relevanceScore;
  final double qualityScore;
  final double originalityScore;
  final String comments;
  final DateTime submittedDate;
  final String status; // pending, in_progress, completed
  
  Review({
    required this.id,
    required this.paperId,
    required this.reviewerName,
    required this.reviewerEmail,
    required this.relevanceScore,
    required this.qualityScore,
    required this.originalityScore,
    required this.comments,
    required this.submittedDate,
    required this.status,
  });
  
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      paperId: json['paper_id'] ?? '',
      reviewerName: json['reviewer_name'] ?? '',
      reviewerEmail: json['reviewer_email'] ?? '',
      relevanceScore: json['relevance_score']?.toDouble() ?? 0.0,
      qualityScore: json['quality_score']?.toDouble() ?? 0.0,
      originalityScore: json['originality_score']?.toDouble() ?? 0.0,
      comments: json['comments'] ?? '',
      submittedDate: json['submitted_date'] != null
          ? DateTime.parse(json['submitted_date'])
          : DateTime.now(),
      status: json['status'] ?? 'pending',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paper_id': paperId,
      'reviewer_name': reviewerName,
      'reviewer_email': reviewerEmail,
      'relevance_score': relevanceScore,
      'quality_score': qualityScore,
      'originality_score': originalityScore,
      'comments': comments,
      'submitted_date': submittedDate.toIso8601String(),
      'status': status,
    };
  }
  
  double get averageScore =>
      (relevanceScore + qualityScore + originalityScore) / 3;
}
import 'package:flutter/foundation.dart';
import '../models/reviewer_assignment.dart';
import '../services/reviewer_service.dart';

class ReviewerProvider with ChangeNotifier {
  final ReviewerService _service = ReviewerService();

  // Dashboard
  ReviewerDashboard? _dashboard;
  bool _isDashboardLoading = false;
  String? _dashboardError;

  // Assignments
  List<ReviewerAssignment> _assignments = [];
  AssignmentStats? _assignmentStats;
  bool _isAssignmentsLoading = false;
  String? _assignmentsError;
  String? _currentAssignmentFilter;

  // Assignment Detail
  AssignmentDetail? _assignmentDetail;
  bool _isAssignmentDetailLoading = false;
  String? _assignmentDetailError;

  // Reviews
  List<Review> _reviews = [];
  ReviewStats? _reviewStats;
  bool _isReviewsLoading = false;
  String? _reviewsError;

  // Review Detail
  Review? _reviewDetail;
  bool _isReviewDetailLoading = false;
  String? _reviewDetailError;

  // Submit Review
  bool _isSubmittingReview = false;
  String? _submitReviewError;

  // Getters
  ReviewerDashboard? get dashboard => _dashboard;
  bool get isDashboardLoading => _isDashboardLoading;
  String? get dashboardError => _dashboardError;

  List<ReviewerAssignment> get assignments => _assignments;
  AssignmentStats? get assignmentStats => _assignmentStats;
  bool get isAssignmentsLoading => _isAssignmentsLoading;
  String? get assignmentsError => _assignmentsError;
  String? get currentAssignmentFilter => _currentAssignmentFilter;

  AssignmentDetail? get assignmentDetail => _assignmentDetail;
  bool get isAssignmentDetailLoading => _isAssignmentDetailLoading;
  String? get assignmentDetailError => _assignmentDetailError;

  List<Review> get reviews => _reviews;
  ReviewStats? get reviewStats => _reviewStats;
  bool get isReviewsLoading => _isReviewsLoading;
  String? get reviewsError => _reviewsError;

  Review? get reviewDetail => _reviewDetail;
  bool get isReviewDetailLoading => _isReviewDetailLoading;
  String? get reviewDetailError => _reviewDetailError;

  bool get isSubmittingReview => _isSubmittingReview;
  String? get submitReviewError => _submitReviewError;

  // Load Dashboard
  Future<void> loadDashboard() async {
    _isDashboardLoading = true;
    _dashboardError = null;
    notifyListeners();

    try {
      _dashboard = await _service.getDashboard();
      _dashboardError = null;
    } catch (e) {
      _dashboardError = e.toString();
      _dashboard = null;
    } finally {
      _isDashboardLoading = false;
      notifyListeners();
    }
  }

  // Load Assignments
  Future<void> loadAssignments({String? status}) async {
    _isAssignmentsLoading = true;
    _assignmentsError = null;
    _currentAssignmentFilter = status;
    notifyListeners();

    try {
      final result = await _service.getAssignments(status: status);
      _assignments = result['assignments'] as List<ReviewerAssignment>;
      _assignmentStats = result['stats'] as AssignmentStats;
      _assignmentsError = null;
    } catch (e) {
      _assignmentsError = e.toString();
      _assignments = [];
      _assignmentStats = null;
    } finally {
      _isAssignmentsLoading = false;
      notifyListeners();
    }
  }

  // Load Assignment Detail
  Future<void> loadAssignmentDetail(int id) async {
    _isAssignmentDetailLoading = true;
    _assignmentDetailError = null;
    notifyListeners();

    try {
      _assignmentDetail = await _service.getAssignmentDetail(id);
      _assignmentDetailError = null;
    } catch (e) {
      _assignmentDetailError = e.toString();
      _assignmentDetail = null;
    } finally {
      _isAssignmentDetailLoading = false;
      notifyListeners();
    }
  }

  // Accept Assignment
  Future<bool> acceptAssignment(int id) async {
    try {
      await _service.acceptAssignment(id);
      
      // Reload assignment detail to update status
      await loadAssignmentDetail(id);
      
      // Reload dashboard and assignments list
      loadDashboard();
      loadAssignments(status: _currentAssignmentFilter);
      
      return true;
    } catch (e) {
      _assignmentDetailError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Decline Assignment
  Future<bool> declineAssignment(int id, String reason) async {
    try {
      await _service.declineAssignment(id, reason);
      
      // Reload assignment detail to update status
      await loadAssignmentDetail(id);
      
      // Reload dashboard and assignments list
      loadDashboard();
      loadAssignments(status: _currentAssignmentFilter);
      
      return true;
    } catch (e) {
      _assignmentDetailError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Load Reviews
  Future<void> loadReviews() async {
    _isReviewsLoading = true;
    _reviewsError = null;
    notifyListeners();

    try {
      final result = await _service.getReviews();
      _reviews = result['reviews'] as List<Review>;
      _reviewStats = result['stats'] as ReviewStats;
      _reviewsError = null;
    } catch (e) {
      _reviewsError = e.toString();
      _reviews = [];
      _reviewStats = null;
    } finally {
      _isReviewsLoading = false;
      notifyListeners();
    }
  }

  // Load Review Detail
  Future<void> loadReviewDetail(int id) async {
    _isReviewDetailLoading = true;
    _reviewDetailError = null;
    notifyListeners();

    try {
      _reviewDetail = await _service.getReviewDetail(id);
      _reviewDetailError = null;
    } catch (e) {
      _reviewDetailError = e.toString();
      _reviewDetail = null;
    } finally {
      _isReviewDetailLoading = false;
      notifyListeners();
    }
  }

  // Submit Review
  Future<bool> submitReview({
    required int assignmentId,
    int? scoreNovelty,
    int? scoreRelevance,
    int? scoreTechnicalQuality,
    int? scorePresentation,
    int? scoreReferences,
    String? detailedComments,
    String? recommendationCode,
    required bool isDraft,
    String? reviewFilePath,
  }) async {
    _isSubmittingReview = true;
    _submitReviewError = null;
    notifyListeners();

    try {
      await _service.submitReview(
        assignmentId: assignmentId,
        scoreNovelty: scoreNovelty,
        scoreRelevance: scoreRelevance,
        scoreTechnicalQuality: scoreTechnicalQuality,
        scorePresentation: scorePresentation,
        scoreReferences: scoreReferences,
        detailedComments: detailedComments,
        recommendationCode: recommendationCode,
        isDraft: isDraft,
        reviewFilePath: reviewFilePath,
      );

      // Reload relevant data
      loadAssignmentDetail(assignmentId);
      loadReviews();
      loadDashboard();

      _submitReviewError = null;
      return true;
    } catch (e) {
      _submitReviewError = e.toString();
      return false;
    } finally {
      _isSubmittingReview = false;
      notifyListeners();
    }
  }

  // Clear errors
  void clearDashboardError() {
    _dashboardError = null;
    notifyListeners();
  }

  void clearAssignmentsError() {
    _assignmentsError = null;
    notifyListeners();
  }

  void clearAssignmentDetailError() {
    _assignmentDetailError = null;
    notifyListeners();
  }

  void clearReviewsError() {
    _reviewsError = null;
    notifyListeners();
  }

  void clearReviewDetailError() {
    _reviewDetailError = null;
    notifyListeners();
  }

  void clearSubmitReviewError() {
    _submitReviewError = null;
    notifyListeners();
  }
}

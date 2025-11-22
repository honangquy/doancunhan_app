import 'package:flutter/foundation.dart';
import '../models/chair_dashboard.dart';
import '../models/chair_paper.dart';
import '../models/chair_paper_detail.dart';
import '../models/chair_statistics.dart';
import '../services/chair_service.dart';
import '../services/auth_service.dart';

class ChairProvider with ChangeNotifier {
  final ChairService _service;
  final AuthService _authService = AuthService();

  ChairProvider(this._service) {
    _initializeToken();
  }

  // Initialize token from AuthService
  Future<void> _initializeToken() async {
    final token = _authService.token;
    print('🔑 [ChairProvider] Token from AuthService: ${token != null ? token.substring(0, 20) : "NULL"}...');
    if (token != null && token.isNotEmpty) {
      _service.setToken(token);
      print('✅ [ChairProvider] Token initialized');
    } else {
      print('⚠️ [ChairProvider] No token found - User: ${_authService.currentUser?.email}');
    }
  }

  // Dashboard state
  ChairDashboard? _dashboard;
  bool _isDashboardLoading = false;
  String? _dashboardError;

  ChairDashboard? get dashboard => _dashboard;
  bool get isDashboardLoading => _isDashboardLoading;
  String? get dashboardError => _dashboardError;

  // Papers state
  PaginatedChairPapers? _papers;
  bool _isPapersLoading = false;
  String? _papersError;

  PaginatedChairPapers? get papers => _papers;
  bool get isPapersLoading => _isPapersLoading;
  String? get papersError => _papersError;

  // Paper detail state
  ChairPaperDetail? _paperDetail;
  bool _isPaperDetailLoading = false;
  String? _paperDetailError;

  ChairPaperDetail? get paperDetail => _paperDetail;
  bool get isPaperDetailLoading => _isPaperDetailLoading;
  String? get paperDetailError => _paperDetailError;

  // Statistics state
  ReviewStatistics? _statistics;
  bool _isStatisticsLoading = false;
  String? _statisticsError;

  ReviewStatistics? get statistics => _statistics;
  bool get isStatisticsLoading => _isStatisticsLoading;
  String? get statisticsError => _statisticsError;

  // Reviewers state
  List<ReviewerWithStats> _reviewers = [];
  bool _isReviewersLoading = false;
  String? _reviewersError;

  List<ReviewerWithStats> get reviewers => _reviewers;
  bool get isReviewersLoading => _isReviewersLoading;
  String? get reviewersError => _reviewersError;

  // Load Dashboard
  Future<void> loadDashboard() async {
    print('📱 [ChairProvider] Loading dashboard...');
    
    // Ensure token is set before making request
    await _initializeToken();
    
    _isDashboardLoading = true;
    _dashboardError = null;
    notifyListeners();

    try {
      _dashboard = await _service.getDashboard();
      print('📱 [ChairProvider] Dashboard loaded successfully');
      _isDashboardLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ [ChairProvider] Error loading dashboard: $e');
      _dashboardError = e.toString();
      _isDashboardLoading = false;
      notifyListeners();
    }
  }

  // Load Papers
  Future<void> loadPapers({
    int? conferenceId,
    String? status,
    String? search,
    int page = 1,
  }) async {
    print('📱 [ChairProvider] Loading papers (page: $page)...');
    _isPapersLoading = true;
    _papersError = null;
    notifyListeners();

    try {
      _papers = await _service.getPapers(
        conferenceId: conferenceId,
        status: status,
        search: search,
        page: page,
      );
      print('📱 [ChairProvider] Papers loaded: ${_papers?.papers.length}');
      _isPapersLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ [ChairProvider] Error loading papers: $e');
      _papersError = e.toString();
      _isPapersLoading = false;
      notifyListeners();
    }
  }

  // Load Paper Detail
  Future<void> loadPaperDetail(int paperId) async {
    print('📱 [ChairProvider] Loading paper detail #$paperId...');
    _isPaperDetailLoading = true;
    _paperDetailError = null;
    notifyListeners();

    try {
      _paperDetail = await _service.getPaperDetail(paperId);
      print('📱 [ChairProvider] Paper detail loaded');
      _isPaperDetailLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ [ChairProvider] Error loading paper detail: $e');
      _paperDetailError = e.toString();
      _isPaperDetailLoading = false;
      notifyListeners();
    }
  }

  // Load Review Statistics
  Future<void> loadStatistics(int conferenceId) async {
    print('📱 [ChairProvider] Loading statistics for conference #$conferenceId...');
    _isStatisticsLoading = true;
    _statisticsError = null;
    notifyListeners();

    try {
      _statistics = await _service.getReviewStatistics(conferenceId);
      print('📱 [ChairProvider] Statistics loaded');
      _isStatisticsLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ [ChairProvider] Error loading statistics: $e');
      _statisticsError = e.toString();
      _isStatisticsLoading = false;
      notifyListeners();
    }
  }

  // Load Reviewers
  Future<void> loadReviewers() async {
    print('📱 [ChairProvider] Loading reviewers...');
    _isReviewersLoading = true;
    _reviewersError = null;
    notifyListeners();

    try {
      _reviewers = await _service.getReviewers();
      print('📱 [ChairProvider] Reviewers loaded: ${_reviewers.length}');
      _isReviewersLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ [ChairProvider] Error loading reviewers: $e');
      _reviewersError = e.toString();
      _isReviewersLoading = false;
      notifyListeners();
    }
  }

  // Assign Reviewer
  Future<bool> assignReviewer({
    required int paperId,
    required int reviewerId,
    required String deadline,
  }) async {
    try {
      await _service.assignReviewer(
        paperId: paperId,
        reviewerId: reviewerId,
        deadline: deadline,
      );
      // Reload paper detail
      await loadPaperDetail(paperId);
      return true;
    } catch (e) {
      print('❌ [ChairProvider] Error assigning reviewer: $e');
      return false;
    }
  }

  // Remove Assignment
  Future<bool> removeAssignment(int assignmentId, int paperId) async {
    try {
      await _service.removeAssignment(assignmentId);
      // Reload paper detail
      await loadPaperDetail(paperId);
      return true;
    } catch (e) {
      print('❌ [ChairProvider] Error removing assignment: $e');
      return false;
    }
  }

  // Make Decision
  Future<bool> makeDecision({
    required int paperId,
    required String decision,
    String? comments,
  }) async {
    try {
      await _service.makeDecision(
        paperId: paperId,
        decision: decision,
        comments: comments,
      );
      // Reload paper detail
      await loadPaperDetail(paperId);
      return true;
    } catch (e) {
      print('❌ [ChairProvider] Error making decision: $e');
      return false;
    }
  }

  // Clear state
  void clear() {
    _dashboard = null;
    _papers = null;
    _paperDetail = null;
    _statistics = null;
    _reviewers = [];
    _dashboardError = null;
    _papersError = null;
    _paperDetailError = null;
    _statisticsError = null;
    _reviewersError = null;
    notifyListeners();
  }
}

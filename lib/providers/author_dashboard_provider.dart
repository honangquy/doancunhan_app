import 'package:flutter/foundation.dart';
import '../models/paper_statistics.dart';
import '../models/paper.dart';
import '../models/author_paper.dart';
import '../services/api_service.dart';

class AuthorDashboardProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State variables
  PaperStatistics? _statistics;
  PaginatedPapers? _paginatedPapers;
  List<Paper> _papers = []; // Keep for backward compatibility
  bool _isLoading = false;
  String? _error;

  // Getters
  PaperStatistics? get statistics => _statistics;
  PaginatedPapers? get paginatedPapers => _paginatedPapers;
  List<Paper> get papers => _papers; // Backward compatibility
  List<AuthorPaper> get authorPapers => _paginatedPapers?.data ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNextPage => _paginatedPapers?.hasNextPage ?? false;
  bool get hasPrevPage => _paginatedPapers?.hasPrevPage ?? false;
  int get currentPage => _paginatedPapers?.currentPage ?? 1;
  int get totalPages => _paginatedPapers?.lastPage ?? 1;
  int get totalPapers => _paginatedPapers?.total ?? 0;

  // Load dashboard data
  Future<void> loadDashboard({int page = 1, String? status, int? conferenceId}) async {
    print('📱 [AuthorDashboardProvider] Starting loadDashboard (page: $page)...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load cả 2 API song song
      print('📱 [AuthorDashboardProvider] Fetching statistics and papers...');
      final results = await Future.wait([
        _apiService.getPaperStatistics(),
        _apiService.getMyPapersPaginated(
          page: page,
          status: status,
          conferenceId: conferenceId,
        ),
      ]);

      _statistics = results[0] as PaperStatistics;
      _paginatedPapers = results[1] as PaginatedPapers;
      
      print('📱 [AuthorDashboardProvider] Data loaded successfully!');
      print('   Total papers: ${_statistics?.totalPapers}');
      print('   Papers in page: ${_paginatedPapers?.data.length}');
      print('   Page: ${_paginatedPapers?.currentPage}/${_paginatedPapers?.lastPage}');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ [AuthorDashboardProvider] Error loading dashboard: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load next page
  Future<void> loadNextPage() async {
    if (!hasNextPage || _isLoading) return;
    await loadDashboard(page: currentPage + 1);
  }

  // Load previous page
  Future<void> loadPrevPage() async {
    if (!hasPrevPage || _isLoading) return;
    await loadDashboard(page: currentPage - 1);
  }

  // Load specific page
  Future<void> loadPage(int page) async {
    if (_isLoading) return;
    await loadDashboard(page: page);
  }

  // Refresh data (reload current page)
  Future<void> refresh() async {
    print('🔄 [AuthorDashboardProvider] Refreshing data...');
    await loadDashboard(page: currentPage);
  }

  // Filter papers by status
  List<Paper> getPapersByStatus(String status) {
    return _papers.where((p) => p.status.toUpperCase() == status.toUpperCase()).toList();
  }
  
  // Filter author papers by status (NEW)
  List<AuthorPaper> getAuthorPapersByStatus(String statusCode) {
    return authorPapers.where((p) => p.statusCode == statusCode).toList();
  }

  // Withdraw paper
  Future<bool> withdrawPaper(int paperId, {String? reason}) async {
    print('📱 [AuthorDashboardProvider] Withdrawing paper $paperId...');
    try {
      await _apiService.withdrawPaperNew(paperId, reason: reason);
      print('✅ [AuthorDashboardProvider] Paper withdrawn, refreshing list...');
      await refresh(); // Reload current page
      return true;
    } catch (e) {
      print('❌ [AuthorDashboardProvider] Error withdrawing paper: $e');
      return false;
    }
  }

  // Clear data
  void clear() {
    _statistics = null;
    _paginatedPapers = null;
    _papers = [];
    _error = null;
    notifyListeners();
  }
}

import 'package:dio/dio.dart';
import '../models/chair_dashboard.dart';
import '../models/chair_paper.dart';
import '../models/chair_paper_detail.dart';
import '../models/chair_statistics.dart';
import 'http_client.dart';

class ChairService {
  final Dio _dio = HttpClient().dio;
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  ChairService() {
    print('✅ [ChairService] Using shared HttpClient with token');
  }

  void setToken(String token) {
    print('🔑 [ChairService] Token set in HttpClient automatically');
    // Token is already set in HttpClient, no need to set again
  }

  // 1. Get Dashboard
  Future<ChairDashboard> getDashboard() async {
    try {
      print('� [ChairService] Getting dashboard...');
      final response = await _dio.get('/chair/dashboard');
      print('🔵 [ChairService] Response status: ${response.statusCode}');
      print('🔵 [ChairService] Response data type: ${response.data.runtimeType}');
      print('🔵 [ChairService] Response data: ${response.data}');
      
      // Handle both direct data and wrapped data
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      
      print('� [ChairService] Parsed data: $data');
      return ChairDashboard.fromJson(data);
    } catch (e) {
      print('❌ [ChairService] Error getting dashboard: $e');
      rethrow;
    }
  }

  // 2. Get Papers List
  Future<PaginatedChairPapers> getPapers({
    int? conferenceId,
    String? status,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      print('🔄 [ChairService] Fetching papers (page: $page)...');
      final response = await _dio.get('/chair/papers', queryParameters: {
        if (conferenceId != null) 'conference_id': conferenceId,
        if (status != null) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'per_page': perPage,
      });
      print('✅ [ChairService] Papers loaded');
      return PaginatedChairPapers.fromJson(response.data['data']);
    } catch (e) {
      print('❌ [ChairService] Error loading papers: $e');
      rethrow;
    }
  }

  // 3. Get Paper Detail
  Future<ChairPaperDetail> getPaperDetail(int paperId) async {
    try {
      print('🔄 [ChairService] Fetching paper detail #$paperId...');
      final response = await _dio.get('/chair/papers/$paperId');
      print('✅ [ChairService] Paper detail loaded');
      return ChairPaperDetail.fromJson(response.data['data']);
    } catch (e) {
      print('❌ [ChairService] Error loading paper detail: $e');
      rethrow;
    }
  }

  // 4. Get Review Statistics for Conference
  Future<ReviewStatistics> getReviewStatistics(int conferenceId) async {
    try {
      print('🔄 [ChairService] Fetching review statistics...');
      final response = await _dio.get('/chair/conferences/$conferenceId/review-statistics');
      print('✅ [ChairService] Review statistics loaded');
      return ReviewStatistics.fromJson(response.data['data']);
    } catch (e) {
      print('❌ [ChairService] Error loading review statistics: $e');
      rethrow;
    }
  }

  // 5. Get Reviewers List
  Future<List<ReviewerWithStats>> getReviewers() async {
    try {
      print('🔄 [ChairService] Fetching reviewers...');
      final response = await _dio.get('/chair/reviewers');
      print('✅ [ChairService] Reviewers loaded');
      final data = response.data['data'] as List;
      return data.map((e) => ReviewerWithStats.fromJson(e)).toList();
    } catch (e) {
      print('❌ [ChairService] Error loading reviewers: $e');
      rethrow;
    }
  }

  // 6. Get Available Reviewers for Paper
  Future<List<ReviewerWithStats>> getAvailableReviewers(int paperId) async {
    try {
      print('🔄 [ChairService] Fetching available reviewers for paper #$paperId...');
      final response = await _dio.get('/chair/papers/$paperId/available-reviewers');
      print('✅ [ChairService] Available reviewers loaded');
      final data = response.data['data'] as List;
      return data.map((e) => ReviewerWithStats.fromJson(e)).toList();
    } catch (e) {
      print('❌ [ChairService] Error loading available reviewers: $e');
      rethrow;
    }
  }

  // 7. Assign Reviewer
  Future<void> assignReviewer({
    required int paperId,
    required int reviewerId,
    required String deadline,
  }) async {
    try {
      print('🔄 [ChairService] Assigning reviewer #$reviewerId to paper #$paperId...');
      await _dio.post('/chair/papers/$paperId/assign-reviewer', data: {
        'reviewer_id': reviewerId,
        'deadline': deadline,
      });
      print('✅ [ChairService] Reviewer assigned');
    } catch (e) {
      print('❌ [ChairService] Error assigning reviewer: $e');
      rethrow;
    }
  }

  // 8. Remove Assignment
  Future<void> removeAssignment(int assignmentId) async {
    try {
      print('🔄 [ChairService] Removing assignment #$assignmentId...');
      await _dio.delete('/chair/assignments/$assignmentId');
      print('✅ [ChairService] Assignment removed');
    } catch (e) {
      print('❌ [ChairService] Error removing assignment: $e');
      rethrow;
    }
  }

  // 9. Make Decision
  Future<void> makeDecision({
    required int paperId,
    required String decision, // ACCEPTED or REJECTED
    String? comments,
  }) async {
    try {
      print('🔄 [ChairService] Making decision for paper #$paperId: $decision');
      await _dio.post('/chair/papers/$paperId/decision', data: {
        'decision': decision,
        if (comments != null && comments.isNotEmpty) 'comments': comments,
      });
      print('✅ [ChairService] Decision made');
    } catch (e) {
      print('❌ [ChairService] Error making decision: $e');
      rethrow;
    }
  }
}

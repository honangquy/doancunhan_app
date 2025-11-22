import 'package:dio/dio.dart';
import '../models/reviewer_assignment.dart';
import 'http_client.dart';

class ReviewerService {
  final Dio _dio = HttpClient().dio;
  static const String _baseUrl = '/mobile/reviewer'; // Bỏ /api vì HttpClient đã có baseUrl

  // 1. GET Dashboard
  Future<ReviewerDashboard> getDashboard() async {
    try {
      final response = await _dio.get('$_baseUrl/dashboard');
      
      if (response.data['success'] == true) {
        return ReviewerDashboard.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load dashboard');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 2. GET Assignments (with optional status filter)
  Future<Map<String, dynamic>> getAssignments({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '$_baseUrl/assignments',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return {
          'assignments': (data['assignments'] as List)
              .map((a) => ReviewerAssignment.fromJson(a))
              .toList(),
          'stats': AssignmentStats.fromJson(data['stats']),
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load assignments');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 3. GET Assignment Detail
  Future<AssignmentDetail> getAssignmentDetail(int id) async {
    try {
      final response = await _dio.get('$_baseUrl/assignments/$id');

      if (response.data['success'] == true) {
        return AssignmentDetail.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load assignment detail');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 4. POST Accept Assignment
  Future<Map<String, dynamic>> acceptAssignment(int id) async {
    try {
      final response = await _dio.post('$_baseUrl/assignments/$id/accept');

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to accept assignment');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 5. POST Decline Assignment
  Future<Map<String, dynamic>> declineAssignment(int id, String reason) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/assignments/$id/decline',
        data: {'reason': reason},
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to decline assignment');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 6. GET Reviews
  Future<Map<String, dynamic>> getReviews() async {
    try {
      final response = await _dio.get('$_baseUrl/reviews');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return {
          'reviews': (data['reviews'] as List)
              .map((r) => Review.fromJson(r))
              .toList(),
          'stats': ReviewStats.fromJson(data['stats']),
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load reviews');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 7. GET Review Detail
  Future<Review> getReviewDetail(int id) async {
    try {
      final response = await _dio.get('$_baseUrl/reviews/$id');

      if (response.data['success'] == true) {
        return Review.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load review detail');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 8. POST Submit Review
  Future<Map<String, dynamic>> submitReview({
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
    try {
      final formData = FormData.fromMap({
        'assignment_id': assignmentId,
        'is_draft': isDraft ? 'true' : 'false',
        if (scoreNovelty != null) 'score_novelty': scoreNovelty,
        if (scoreRelevance != null) 'score_relevance': scoreRelevance,
        if (scoreTechnicalQuality != null) 'score_technical_quality': scoreTechnicalQuality,
        if (scorePresentation != null) 'score_presentation': scorePresentation,
        if (scoreReferences != null) 'score_references': scoreReferences,
        if (detailedComments != null) 'detailed_comments': detailedComments,
        if (recommendationCode != null) 'recommendation_code': recommendationCode,
      });

      // Add file if provided
      if (reviewFilePath != null) {
        formData.files.add(MapEntry(
          'review_file',
          await MultipartFile.fromFile(reviewFilePath),
        ));
      }

      final response = await _dio.post(
        '$_baseUrl/reviews',
        data: formData,
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to submit review');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Helper: Handle Dio errors
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      
      // Check for validation errors
      if (data is Map && data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return Exception(firstError.first.toString());
        }
      }
      
      // Return message if available
      if (data is Map && data['message'] != null) {
        return Exception(data['message'].toString());
      }
      
      // Status code specific messages
      switch (e.response!.statusCode) {
        case 401:
          return Exception('Unauthorized. Please login again.');
        case 403:
          return Exception('You must accept the assignment before submitting review');
        case 404:
          return Exception('Assignment or review not found');
        case 422:
          return Exception('Validation error. Please check your input.');
        case 500:
          return Exception('Server error. Please try again later.');
        default:
          return Exception('Error: ${e.response!.statusCode}');
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return Exception('Connection timeout. Please check your internet connection.');
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return Exception('Receive timeout. Please try again.');
    } else {
      return Exception('Network error. Please check your connection.');
    }
  }
}

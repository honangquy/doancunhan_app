import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/paper.dart';
import '../models/user.dart';

// ============================================
// API SERVICE - Chuẩn bị cho backend
// ============================================

class ApiService {
  final String baseUrl = AppConstants.baseUrl + AppConstants.apiVersion;
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  // Headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Thêm token khi có
        // 'Authorization': 'Bearer $token',
      };
  
  // ============================================
  // AUTHENTICATION
  // ============================================
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.login}'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.logout}'),
        headers: _headers,
      );
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }
  
  // ============================================
  // PAPERS
  // ============================================
  
  Future<List<Paper>> fetchPapers({String? status}) async {
    try {
      String url = '$baseUrl${ApiEndpoints.papers}';
      if (status != null) {
        url += '?status=$status';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Paper.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch papers');
      }
    } catch (e) {
      // Trả về mock data khi chưa có backend
      return Paper.getMockPapers();
    }
  }
  
  Future<Paper> fetchPaperDetail(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.paperDetail}/$id'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return Paper.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch paper detail');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<Paper> submitPaper(Paper paper) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.submitPaper}'),
        headers: _headers,
        body: jsonEncode(paper.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Paper.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to submit paper');
      }
    } catch (e) {
      throw Exception('Submit error: $e');
    }
  }
  
  Future<void> withdrawPaper(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.withdrawPaper}/$id'),
        headers: _headers,
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to withdraw paper');
      }
    } catch (e) {
      throw Exception('Withdraw error: $e');
    }
  }
  
  // ============================================
  // REVIEWS
  // ============================================
  
  Future<List<Paper>> fetchReviewPapers({String? status}) async {
    try {
      String url = '$baseUrl${ApiEndpoints.reviews}';
      if (status != null) {
        url += '?status=$status';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Paper.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch review papers');
      }
    } catch (e) {
      // Mock data
      return Paper.getMockPapers();
    }
  }
  
  Future<void> submitReview(Review review) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.submitReview}'),
        headers: _headers,
        body: jsonEncode(review.toJson()),
      );
      
      if (response.statusCode != 201) {
        throw Exception('Failed to submit review');
      }
    } catch (e) {
      throw Exception('Submit review error: $e');
    }
  }
  
  Future<List<Paper>> getReviewHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/history'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Paper.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch review history');
      }
    } catch (e) {
      // Mock data
      return Paper.getMockPapers();
    }
  }
  
  Future<List<Paper>> getAssignedPapers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/assigned'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Paper.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch assigned papers');
      }
    } catch (e) {
      return Paper.getMockPapers();
    }
  }
  
  Future<Map<String, dynamic>> getReviewerStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/stats'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch reviewer stats');
      }
    } catch (e) {
      return {
        'pending': 5,
        'completed': 12,
        'total': 17,
      };
    }
  }
  
  // ============================================
  // USER
  // ============================================
  
  Future<User> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.userProfile}'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch user profile');
      }
    } catch (e) {
      // Mock data
      return User.getMockAuthor();
    }
  }
  
  Future<void> updateProfile(User user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${ApiEndpoints.updateProfile}'),
        headers: _headers,
        body: jsonEncode(user.toJson()),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      throw Exception('Update profile error: $e');
    }
  }
  
  // ============================================
  // ADMIN
  // ============================================
  
  Future<void> postAnnouncement({
    required String title,
    required String content,
    required String priority,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.announcements}'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'content': content,
          'priority': priority,
        }),
      );
      
      if (response.statusCode != 201) {
        throw Exception('Failed to post announcement');
      }
    } catch (e) {
      throw Exception('Post announcement error: $e');
    }
  }
  
  Future<void> assignReviewers({
    required String paperId,
    required List<String> reviewerIds,
    required DateTime deadline,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.assignReviewers}'),
        headers: _headers,
        body: jsonEncode({
          'paper_id': paperId,
          'reviewer_ids': reviewerIds,
          'deadline': deadline.toIso8601String(),
        }),
      );
      
      if (response.statusCode != 201) {
        throw Exception('Failed to assign reviewers');
      }
    } catch (e) {
      throw Exception('Assign reviewers error: $e');
    }
  }
  
  Future<Map<String, dynamic>> fetchReports() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.reports}'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch reports');
      }
    } catch (e) {
      // Mock data
      return {
        'total_papers': 156,
        'total_users': 89,
        'total_reviews': 42,
        'total_conferences': 12,
      };
    }
  }
}

// ============================================
// API RESPONSE MODEL
// ============================================

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final dynamic error;
  
  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });
  
  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
    );
  }
  
  factory ApiResponse.error(dynamic error, {String? message}) {
    return ApiResponse(
      success: false,
      message: message,
      error: error,
    );
  }
}

extension ApiServiceExtensions on ApiService {
  Future<List<Paper>> getPapers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/papers'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Paper.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch papers');
      }
    } catch (e) {
      return Paper.getMockPapers();
    }
  }

  Future<List<Paper>> getProceedings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/proceedings'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Paper.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch proceedings');
      }
    } catch (e) {
      return Paper.getMockPapers();
    }
  }

  Future<List<Paper>> getMyPapers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-papers'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Paper.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch my papers');
      }
    } catch (e) {
      return Paper.getMockPapers();
    }
  }
}
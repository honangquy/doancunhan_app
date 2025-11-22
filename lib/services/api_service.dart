import 'package:dio/dio.dart';
import '../models/paper.dart';
import '../models/user.dart';
import '../models/announcement.dart';
import '../models/paper_statistics.dart';
import '../models/paper_detail.dart';
import '../models/author_paper.dart';
import '../models/paper_detail_new.dart';
import '../utils/api_config.dart';
import 'http_client.dart';

/// API Service - Handles all HTTP requests to backend
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  bool _initialized = false;

  /// Initialize HTTP client
  Future<void> init() async {
    if (_initialized) return;
    
    final httpClient = HttpClient();
    await httpClient.init();
    _dio = httpClient.dio;
    _initialized = true;
  }

  /// Ensure client is initialized
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  // ============================================
  // AUTHENTICATION
  // ============================================

  /// Login with email and password (Laravel Sanctum - theo FLUTTER_API_GUIDE.md)
  /// POST /api/auth/login
  /// Returns: { "success": true, "token": "...", "user": {...} }
  Future<Map<String, dynamic>> login(String email, String password) async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.post(
        ApiConfig.authLogin,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      // Backend JWT response: { "success": true, "data": { "user": {...}, "token": "..." } }
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        
        // Debug logging
        print('🔍 Login response: $responseData');
        print('🔍 Has success field: ${responseData.containsKey('success')}');
        print('🔍 Success value: ${responseData['success']}');
        
        // Check if success is true
        if (responseData['success'] == true) {
          // Backend trả về: { "success": true, "data": { "user": {...}, "token": "..." } }
          if (responseData.containsKey('data') && responseData['data'] is Map) {
            final data = responseData['data'] as Map<String, dynamic>;
            print('🔍 Has data.token: ${data.containsKey('token')}');
            print('🔍 Has data.user: ${data.containsKey('user')}');
            
            if (data['token'] != null && data['user'] != null) {
              final user = data['user'] as Map<String, dynamic>;
              
              // Convert roles array to single role string for app
              String role = 'author'; // default
              if (user.containsKey('roles') && user['roles'] is List) {
                final roles = user['roles'] as List;
                if (roles.isNotEmpty && roles[0] is Map) {
                  final roleCode = roles[0]['role_code'] as String?;
                  
                  // Map role codes from backend to app roles
                  // CHAIR -> chair (admin), REVIEWER -> reviewer, AUTHOR -> author
                  if (roleCode != null) {
                    role = roleCode.toLowerCase();
                    print('🔍 Role code from backend: $roleCode -> $role');
                  }
                }
              }
              
              print('✅ Login successful, role: $role');
              return {
                'success': true,
                'token': data['token'].toString(),
                'user': {
                  'id': user['user_id']?.toString() ?? '',
                  'name': user['full_name']?.toString() ?? '',
                  'email': user['email']?.toString() ?? '',
                  'role': role,
                  'is_student': user['is_student'] ?? false,
                  'faculty_id': user['faculty_id']?.toString(),
                  'organization': user['organization']?.toString(),
                },
              };
            }
          }
          
          // Fallback: direct token in response (old format)
          if (responseData.containsKey('token')) {
            print('✅ Login: direct token path');
            return {
              'success': true,
              'token': responseData['token'],
              'user': responseData['user'] ?? {
                'email': email,
                'role': 'author',
              },
            };
          }
        }
        
        print('⚠️ Login failed or no token found');
        return responseData;
      }
      
      print('⚠️ Login: response is not a map');
      return response.data;
    } on DioException catch (e) {
      print('Login error: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        throw 'Invalid credentials';
      }
      if (e.response?.statusCode == 422) {
        // Validation error
        final errors = e.response?.data['errors'];
        if (errors != null) {
          throw errors.toString();
        }
        throw 'Validation failed';
      }
      throw _handleError(e);
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? affiliation,
  }) async {
    await _ensureInitialized();
    
    try {
      final data = {
        'full_name': fullName, // Backend expects 'full_name'
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
      
      // Add optional fields if provided
      if (phone != null && phone.isNotEmpty) {
        data['phone'] = phone;
      }
      if (affiliation != null && affiliation.isNotEmpty) {
        data['organization'] = affiliation; // Backend uses 'organization'
      }
      
      final response = await _dio.post(
        ApiConfig.authRegister,
        data: data,
      );
      
      // Backend returns: { "success": true, "data": { "user": {...}, "token": "..." } }
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        
        if (responseData['success'] == true && responseData.containsKey('data')) {
          final data = responseData['data'] as Map<String, dynamic>;
          return {
            'success': true,
            'token': data['token'],
            'user': data['user'],
            'message': responseData['message'],
          };
        }
      }
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _ensureInitialized();
    
    try {
      await _dio.post(ApiConfig.authLogout);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get current user profile
  Future<User> getProfile() async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.get(ApiConfig.authProfile);
      
      // Backend returns: {"success": true, "data": {...}}
      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData['data'] != null) {
        return User.fromJson(responseData['data']);
      }
      
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update user profile
  Future<User> updateProfile(Map<String, dynamic> data) async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.put(ApiConfig.authProfile, data: data);
      
      // Backend returns: {"success": true, "data": {...}}
      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData['data'] != null) {
        return User.fromJson(responseData['data']);
      }
      
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Forgot password - Request OTP
  /// POST /api/auth/forgot-password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      
      if (response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to send reset code');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify reset token/OTP
  /// POST /api/auth/verify-reset-token
  Future<void> verifyResetToken(String email, String token) async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.post(
        '/auth/verify-reset-token',
        data: {
          'email': email,
          'token': token,
        },
      );
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Invalid token');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reset password with token
  /// POST /api/auth/reset-password
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to reset password');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // CONFERENCES
  // ============================================

  /// Get all conferences
  Future<List<dynamic>> getConferences({int page = 1}) async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.get(
        ApiConfig.conferences,
        queryParameters: {'page': page},
      );
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get conference by ID
  Future<Map<String, dynamic>> getConference(int id) async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.get('${ApiConfig.conferences}/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get my conferences
  Future<List<dynamic>> getMyConferences() async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.get(ApiConfig.myConferences);
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // PAPERS
  // ============================================

  /// Get all papers
  Future<List<Paper>> getPapers({
    int? conferenceId,
    String? status,
    int page = 1,
  }) async {
    await _ensureInitialized();
    
    try {
      final queryParams = <String, dynamic>{
        'page': page,
      };
      
      if (conferenceId != null) queryParams['conference_id'] = conferenceId;
      if (status != null) queryParams['status'] = status;
      
      final response = await _dio.get(
        ApiConfig.papers,
        queryParameters: queryParams,
      );
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Paper.fromJson(json)).toList();
    } on DioException catch (e) {
      // Fallback to mock data if API fails
      print('⚠️  API error, using mock data: ${e.message}');
      return Paper.getMockPapers();
    }
  }

  /// Get paper by ID
  Future<Paper> getPaper(int id) async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.get('${ApiConfig.papers}/$id');
      return Paper.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get my papers
  Future<List<Paper>> getMyPapers() async {
    await _ensureInitialized();
    
    try {
      print('🔄 Fetching papers from ${ApiConfig.myPapers}');
      final response = await _dio.get(ApiConfig.myPapers);
      print('✅ Papers response: ${response.data}');
      
      final List<dynamic> data = response.data['data'] ?? [];
      print('📄 Found ${data.length} papers in response');
      
      final papers = data.map((json) => Paper.fromJson(json)).toList();
      print('📄 Successfully parsed ${papers.length} papers');
      return papers;
    } on DioException catch (e) {
      print('❌ API error fetching papers: ${e.message}');
      print('   Status code: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
      print('⚠️  Returning empty list instead of mock data');
      
      // Return empty list instead of mock data to show real state
      return [];
    }
  }

  /// Submit a new paper
  Future<Paper> submitPaper({
    required int conferenceId,
    required String title,
    required String abstract,
    required String keywords,
    String? filePath,
  }) async {
    await _ensureInitialized();
    
    try {
      FormData formData = FormData.fromMap({
        'conference_id': conferenceId,
        'title': title,
        'abstract': abstract,
        'keywords': keywords,
        if (filePath != null)
          'file': await MultipartFile.fromFile(filePath),
      });
      
      final response = await _dio.post(
        ApiConfig.papers,
        data: formData,
      );
      
      return Paper.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update paper
  Future<Paper> updatePaper(int id, Map<String, dynamic> data) async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.put('${ApiConfig.papers}/$id', data: data);
      return Paper.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download paper file
  Future<void> downloadPaper(int id, String savePath) async {
    await _ensureInitialized();
    
    try {
      await _dio.download(
        '${ApiConfig.papers}/$id/download',
        savePath,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // REVIEWS
  // ============================================

  /// Get my reviews
  Future<List<dynamic>> getMyReviews() async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.get(ApiConfig.myReviews);
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Submit a review
  Future<Map<String, dynamic>> submitReview({
    required int paperId,
    required int rating,
    required String comment,
    String? strengths,
    String? weaknesses,
    String? recommendation,
  }) async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.post(
        ApiConfig.reviews,
        data: {
          'paper_id': paperId,
          'rating': rating,
          'comment': comment,
          if (strengths != null) 'strengths': strengths,
          if (weaknesses != null) 'weaknesses': weaknesses,
          if (recommendation != null) 'recommendation': recommendation,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // ASSIGNMENTS
  // ============================================

  /// Get my assignments (papers assigned to review)
  Future<List<dynamic>> getMyAssignments() async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.get(ApiConfig.myAssignments);
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Assign reviewer to paper (Admin only)
  Future<Map<String, dynamic>> assignReviewer({
    required int paperId,
    required int reviewerId,
  }) async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.post(
        ApiConfig.assignments,
        data: {
          'paper_id': paperId,
          'reviewer_id': reviewerId,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // ANNOUNCEMENTS
  // ============================================

  /// Get all announcements
  Future<List<Announcement>> getAnnouncements({int? conferenceId}) async {
    await _ensureInitialized();
    
    try {
      final queryParams = <String, dynamic>{};
      if (conferenceId != null) queryParams['conference_id'] = conferenceId;
      
      final response = await _dio.get(
        ApiConfig.announcements,
        queryParameters: queryParams,
      );
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Announcement.fromJson(json)).toList();
    } on DioException catch (e) {
      print('⚠️  API error: ${e.message}');
      return [];
    }
  }

  /// Create announcement (Admin only)
  Future<Announcement> createAnnouncement({
    required String title,
    required String content,
    int? conferenceId,
  }) async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.post(
        ApiConfig.announcements,
        data: {
          'title': title,
          'content': content,
          if (conferenceId != null) 'conference_id': conferenceId,
        },
      );
      
      return Announcement.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // ADMIN
  // ============================================

  /// Get all users (Admin only)
  Future<List<User>> getUsers({int page = 1}) async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.get(
        ApiConfig.adminUsers,
        queryParameters: {'page': page},
      );
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => User.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get admin statistics
  Future<Map<String, dynamic>> getAdminStatistics() async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.get(ApiConfig.adminStatistics);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // NOTIFICATIONS
  // ============================================

  /// Get notifications
  Future<List<dynamic>> getNotifications() async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.get(ApiConfig.notifications);
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsRead() async {
    await _ensureInitialized();
    
    try {
      await _dio.patch('${ApiConfig.notifications}/read-all');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // UTILITY
  // ============================================

  /// Health check
  Future<bool> healthCheck() async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.get(ApiConfig.health);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // ADDITIONAL METHODS (for backward compatibility)
  // ============================================

  /// Fetch papers for author (alias for getMyPapers)
  Future<List<Paper>> fetchPapers() async {
    return getMyPapers();
  }

  /// Fetch review papers for reviewer (alias for getMyReviews)
  Future<List<Paper>> fetchReviewPapers() async {
    try {
      await _ensureInitialized();
      final reviews = await getMyReviews();
      // Convert reviews to papers
      return reviews.map((review) {
        return Paper(
          id: review['paper_id']?.toString() ?? '',
          title: review['paper_title'] ?? 'Untitled',
          author: review['paper_author'] ?? 'Unknown',
          authorEmail: review['paper_author_email'] ?? '',
          track: review['track'] ?? '',
          abstract: review['abstract'] ?? '',
          keywords: review['keywords'] ?? '',
          submittedDate: DateTime.tryParse(review['submitted_at'] ?? '') ?? DateTime.now(),
          status: review['paper_status'] ?? 'pending',
        );
      }).toList();
    } catch (e) {
      print('Error fetching review papers: $e');
      return Paper.getMockPapers();
    }
  }

  /// Get proceedings (mock for now)
  Future<List<dynamic>> getProceedings({int? conferenceId}) async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.get(
        '/api/proceedings',
        queryParameters: conferenceId != null ? {'conference_id': conferenceId} : null,
      );
      return response.data['data'] ?? [];
    } catch (e) {
      print('Error getting proceedings: $e');
      // Return mock data
      return [
        {
          'id': 1,
          'conference_id': 1,
          'title': 'Conference Proceedings 2024',
          'description': 'Full proceedings of the conference',
          'file_path': '/proceedings/2024.pdf',
          'published_date': DateTime.now().toIso8601String(),
        }
      ];
    }
  }

  /// Withdraw paper
  Future<bool> withdrawPaper(String paperId) async {
    await _ensureInitialized();
    
    try {
      await _dio.delete('/papers/$paperId/withdraw');
      return true;
    } catch (e) {
      print('Error withdrawing paper: $e');
      return false;
    }
  }

  /// Get review history for reviewer
  Future<List<Map<String, dynamic>>> getReviewHistory() async {
    final reviews = await getMyReviews();
    return reviews.cast<Map<String, dynamic>>();
  }

  /// Get assigned papers for reviewer (alias)
  Future<List<Paper>> getAssignedPapers() async {
    return fetchReviewPapers();
  }

  /// Get reviewer statistics
  Future<Map<String, dynamic>> getReviewerStats() async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.get('/review/statistics');
      return response.data['data'] ?? response.data;
    } catch (e) {
      print('⚠️ Error getting reviewer stats: $e');
      
      // Handle 403 Forbidden error (backend needs fixing)
      if (e is DioException && e.response?.statusCode == 403) {
        print('⚠️ 403 Forbidden - Backend requires admin role. Trying fallback...');
        
        // Fallback: Try to get data from my-reviews endpoint
        try {
          final reviewsResponse = await _dio.get('/my-reviews');
          final reviews = reviewsResponse.data['data'] as List? ?? [];
          
          final completed = reviews.where((r) => 
            ['completed', 'submitted'].contains(r['status']?.toString().toLowerCase())).length;
          final pending = reviews.where((r) => 
            ['pending', 'assigned', 'in_progress'].contains(r['status']?.toString().toLowerCase())).length;
          
          print('✅ Fallback successful - calculated from ${reviews.length} reviews');
          
          return {
            'total': reviews.length,
            'completed': completed,
            'pending': pending,
            'avg_score': 0, // Cannot calculate without overall_score field
          };
        } catch (fallbackError) {
          print('❌ Fallback also failed: $fallbackError');
        }
      }
      
      // Return empty data for any error
      print('📊 Returning empty stats data');
      return {
        'total': 0,
        'completed': 0,
        'pending': 0,
        'avg_score': 0,
      };
    }
  }

  /// Get author statistics
  Future<Map<String, dynamic>> getAuthorStats() async {
    await _ensureInitialized();
    
    try {
      print('🔄 Fetching author statistics from /papers/statistics');
      final response = await _dio.get('/papers/statistics');
      print('✅ Author stats response: ${response.data}');
      
      // Handle both nested and flat response formats
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('data')) {
          print('📊 Parsed stats from nested data: ${data['data']}');
          return data['data'] as Map<String, dynamic>;
        }
        print('📊 Using flat response data: $data');
        return data;
      }
      
      return {
        'total_papers': 0,
        'under_review': 0,
        'accepted': 0,
        'rejected': 0,
      };
    } catch (e) {
      print('❌ Error getting author stats: $e');
      if (e is DioException) {
        print('   Status code: ${e.response?.statusCode}');
        print('   Response data: ${e.response?.data}');
      }
      return {
        'total_papers': 0,
        'under_review': 0,
        'accepted': 0,
        'rejected': 0,
      };
    }
  }

  // ============================================
  // ERROR HANDLING
  // ============================================

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      
      if (data is Map<String, dynamic>) {
        return data['message'] ?? data['error'] ?? 'Unknown error';
      }
      
      return 'Server error: ${e.response!.statusCode}';
    }
    
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout';
    }
    
    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout';
    }
    
    return e.message ?? 'Network error';
  }

  // ============================================
  // PAPER STATISTICS & DETAILS (New)
  // ============================================

  /// Get author paper statistics
  /// GET /api/author/statistics
  /// Returns: { status, message, data: { total, draft, submitted, under_review, accepted, rejected, withdrawn } }
  /// Theo FLUTTER_AUTHOR_API.md
  Future<PaperStatistics> getPaperStatistics() async {
    await _ensureInitialized();
    
    try {
      print('🔄 Fetching author statistics from /author/statistics');
      final response = await _dio.get('/author/statistics');
      print('✅ Statistics response: ${response.data}');
      print('   Response type: ${response.data.runtimeType}');
      
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        print('📊 Response keys: ${responseMap.keys.toList()}');
        
        // Backend trả về: { status, message, data: { total, draft, submitted, under_review, accepted, rejected, withdrawn } }
        final data = responseMap['data'] as Map<String, dynamic>;
        print('📊 Data keys: ${data.keys.toList()}');
        print('📊 Total papers: ${data['total']}');
        
        // Convert flat format to by_status map
        final byStatus = <String, int>{
          'DRAFT': data['draft'] ?? 0,
          'SUBMITTED': data['submitted'] ?? 0,
          'UNDER_REVIEW': data['under_review'] ?? 0,
          'ACCEPTED': data['accepted'] ?? 0,
          'REJECTED': data['rejected'] ?? 0,
          'WITHDRAWN': data['withdrawn'] ?? 0,
        };
        
        print('📊 By status: $byStatus');
        
        return PaperStatistics(
          totalPapers: data['total'] ?? 0,
          byStatus: byStatus,
          recentPapers: [], // API không trả về recent_papers
        );
      }
      
      throw Exception('Unexpected response format: ${response.data.runtimeType}');
    } catch (e) {
      print('❌ Error getting paper statistics: $e');
      if (e is DioException) {
        print('   Status code: ${e.response?.statusCode}');
        print('   Response data: ${e.response?.data}');
      }
      
      // Return empty statistics on error
      return PaperStatistics(
        totalPapers: 0,
        byStatus: {
          'SUBMITTED': 0,
          'UNDER_REVIEW': 0,
          'ACCEPTED': 0,
          'REJECTED': 0,
        },
        recentPapers: [],
      );
    }
  }

  /// Get list of papers for author with pagination
  /// GET /api/my-papers
  /// Returns: { status, message, data: { current_page, data: [...], total, ... } }
  /// API Spec: FLUTTER_AUTHOR_API.md
  Future<PaginatedPapers> getMyPapersPaginated({
    String? status,
    int? conferenceId,
    int page = 1,
    int perPage = 15,
  }) async {
    await _ensureInitialized();
    
    try {
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (status != null) 'status': status,
        if (conferenceId != null) 'conference_id': conferenceId.toString(),
      };
      
      print('🔄 Fetching papers from /my-papers with params: $queryParams');
      final response = await _dio.get('/my-papers', queryParameters: queryParams);
      print('✅ Papers response received');
      
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        
        // Response format: { status, message, data: {pagination object} }
        if (responseMap.containsKey('data')) {
          final paginatedData = PaginatedPapers.fromJson(responseMap['data']);
          print('📄 Loaded ${paginatedData.data.length} papers (page ${paginatedData.currentPage}/${paginatedData.lastPage})');
          return paginatedData;
        }
      }
      
      // Return empty pagination if format unexpected
      return PaginatedPapers(
        currentPage: 1,
        data: [],
        lastPage: 1,
        links: [],
        path: '',
        perPage: perPage,
        total: 0,
      );
    } on DioException catch (e) {
      print('❌ API error fetching papers: ${e.message}');
      print('   Status code: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
      
      // Return empty pagination on error
      return PaginatedPapers(
        currentPage: 1,
        data: [],
        lastPage: 1,
        links: [],
        path: '',
        perPage: perPage,
        total: 0,
      );
    }
  }

  /// Get list of papers for author (OLD - keep for backward compatibility)
  /// GET /api/my-papers
  /// Returns: { papers: [...], pagination: {...} }
  /// API Spec: docs.json - Response has "papers" key
  Future<List<Paper>> getMyPapersNew() async {
    await _ensureInitialized();
    
    try {
      print('🔄 Fetching papers from /my-papers');
      final response = await _dio.get('/my-papers');
      print('✅ Papers response: ${response.data}');
      print('   Response type: ${response.data.runtimeType}');
      
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        print('📄 Response keys: ${data.keys.toList()}');
        
        // According to docs.json, response has "papers" key
        if (data.containsKey('papers') && data['papers'] is List) {
          final List<dynamic> papersList = data['papers'];
          print('📄 Found ${papersList.length} papers in response');
          
          final papers = papersList.map((json) => Paper.fromJson(json)).toList();
          print('📄 Successfully parsed ${papers.length} papers');
          return papers;
        }
        
        print('⚠️ No "papers" key found in response');
      }
      
      return [];
    } on DioException catch (e) {
      print('❌ API error fetching papers: ${e.message}');
      print('   Status code: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
      print('⚠️ Returning empty list');
      
      return [];
    }
  }

  /// Get paper detail by ID (OLD - backward compatibility)
  /// GET /api/papers/{paper_id}
  /// Returns: { paper_id, title, abstract, ... }
  Future<PaperDetail> getPaperDetail(int paperId) async {
    await _ensureInitialized();
    
    try {
      print('🔄 Fetching paper detail for ID: $paperId');
      final response = await _dio.get('/papers/$paperId');
      print('✅ Paper detail response: ${response.data}');
      
      // Handle response format
      final data = response.data is Map<String, dynamic>
          ? (response.data['data'] ?? response.data)
          : response.data;
      
      return PaperDetail.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Error getting paper detail: $e');
      if (e is DioException) {
        print('   Status code: ${e.response?.statusCode}');
        print('   Response data: ${e.response?.data}');
      }
      rethrow;
    }
  }

  /// Get paper detail with full info (authors, assignments, reviews, permissions)
  /// GET /api/papers/{id}
  /// Returns: { status, message, data: { paper: {...}, authors: [...], assignments: [...], reviews: [...], permissions: {...}, formatted_dates: {...} } }
  /// API Spec: FLUTTER_AUTHOR_API.md
  Future<PaperDetailFull> getPaperDetailFull(int paperId) async {
    await _ensureInitialized();
    
    try {
      print('🔄 Fetching full paper detail for ID: $paperId');
      final response = await _dio.get('/papers/$paperId');
      print('✅ Full paper detail response received');
      
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        
        // Response format: { status, message, data: {...} }
        if (responseMap.containsKey('data')) {
          return PaperDetailFull.fromJson(responseMap['data']);
        }
      }
      
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      print('❌ Error getting paper detail: ${e.message}');
      print('   Status code: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Paper not found');
      }
      rethrow;
    }
  }

  /// Update paper information
  /// PUT /api/papers/{id}
  /// Request: { title, abstract, keywords, conference_id, track_id? }
  /// Returns: { status, message, data: {...} }
  /// API Spec: FLUTTER_AUTHOR_API.md
  /// Update paper (new - với named parameters)
  /// PUT /api/papers/{id}
  Future<void> updatePaperNew(
    int paperId, {
    required String title,
    required String abstract,
    required String keywords,
    required int conferenceId,
    int? trackId,
  }) async {
    await _ensureInitialized();
    
    try {
      print('🔄 Updating paper $paperId');
      await _dio.put(
        '/papers/$paperId',
        data: {
          'title': title,
          'abstract': abstract,
          'keywords': keywords,
          'conference_id': conferenceId,
          if (trackId != null) 'track_id': trackId,
        },
      );
      print('✅ Paper updated successfully');
    } on DioException catch (e) {
      print('❌ Error updating paper: ${e.message}');
      print('   Status code: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
      
      if (e.response?.statusCode == 403) {
        final message = e.response?.data['message'] ?? 'Permission denied';
        throw Exception(message);
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        throw Exception('Validation error: $errors');
      }
      rethrow;
    }
  }

  /// Withdraw paper
  /// POST /api/papers/{id}/withdraw
  /// Request: { reason? }
  /// Returns: { status, message }
  /// API Spec: FLUTTER_AUTHOR_API.md
  Future<void> withdrawPaperNew(int paperId, {String? reason}) async {
    await _ensureInitialized();
    
    try {
      print('🔄 Withdrawing paper $paperId');
      await _dio.post(
        '/papers/$paperId/withdraw',
        data: {
          if (reason != null) 'reason': reason,
        },
      );
      print('✅ Paper withdrawn successfully');
    } on DioException catch (e) {
      print('❌ Error withdrawing paper: ${e.message}');
      print('   Status code: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
      
      if (e.response?.statusCode == 403) {
        final message = e.response?.data['message'] ?? 'Permission denied';
        throw Exception(message);
      }
      rethrow;
    }
  }

  /// Get download URL for paper
  String getPaperDownloadUrl(int paperId) {
    return '${ApiConfig.baseUrl}/papers/$paperId/download';
  }
}

import 'package:dio/dio.dart';
import '../models/announcement.dart';
import 'http_client.dart';

class AnnouncementService {
  final Dio _dio = HttpClient().dio;
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // 1. GET /api/announcements - List Announcements
  Future<PaginatedAnnouncements> getAnnouncements({
    String? status,
    int? conferenceId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      print('🔵 [AnnouncementService] Getting announcements (page: $page, status: $status, conference: $conferenceId)...');
      
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      
      if (conferenceId != null) {
        queryParams['conference_id'] = conferenceId;
      }
      
      final response = await _dio.get('/announcements', queryParameters: queryParams);
      
      print('✅ [AnnouncementService] Response status: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        return PaginatedAnnouncements.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load announcements');
      }
    } catch (e) {
      print('❌ [AnnouncementService] Error getting announcements: $e');
      rethrow;
    }
  }

  // 2. POST /api/announcements - Create Announcement
  Future<Announcement> createAnnouncement({
    required int conferenceId,
    required String title,
    required String content,
    required String audience,
    required List<String> channels,
    DateTime? scheduledAt,
  }) async {
    try {
      print('🔵 [AnnouncementService] Creating announcement...');
      print('   Conference: $conferenceId');
      print('   Title: $title');
      print('   Audience: $audience');
      print('   Channels: $channels');
      print('   Scheduled: $scheduledAt');
      
      final Map<String, dynamic> data = {
        'conference_id': conferenceId,
        'title': title,
        'content': content,
        'audience': audience,
        'channels': channels,
        // If scheduledAt is null (Send now), use current time + 1 minute to ensure it's in the future
        'scheduled_at': (scheduledAt ?? DateTime.now().add(const Duration(minutes: 1)))
            .toIso8601String()
            .replaceAll('T', ' ')
            .substring(0, 19),
      };
      
      print('📅 [AnnouncementService] Sending scheduled_at: ${data['scheduled_at']}');
      
      final response = await _dio.post('/announcements', data: data);

      print('✅ [AnnouncementService] Response: ${response.data}');

      if (response.data['success'] == true) {
        // Backend may return created announcement under different keys. Try common shapes.
        final respData = response.data['data'] ?? response.data;
        // If the API returns an object with announcement_id and other fields inside 'announcement', prefer that.
        final annJson = respData['announcement'] ?? respData;
        final announcement = Announcement.fromJson(annJson);
        print('✅ [AnnouncementService] Created announcement #${announcement.announcementId}');
        return announcement;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create announcement');
      }
    } catch (e) {
      print('❌ [AnnouncementService] Error creating announcement: $e');
      if (e is DioException && e.response != null) {
        print('❌ [AnnouncementService] Error response: ${e.response?.data}');
        final errorData = e.response?.data;
        if (errorData is Map && errorData['errors'] != null) {
          // Return validation errors
          throw Exception(errorData['errors'].toString());
        } else if (errorData is Map && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
      }
      rethrow;
    }
  }

  // 3. GET /api/announcements/{id} - Get Announcement Detail
  Future<Announcement> getAnnouncementDetail(int announcementId) async {
    try {
      print('🔵 [AnnouncementService] Getting announcement detail #$announcementId...');
      
      final response = await _dio.get('/announcements/$announcementId');
      
      print('✅ [AnnouncementService] Response status: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        return Announcement.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load announcement detail');
      }
    } catch (e) {
      print('❌ [AnnouncementService] Error getting announcement detail: $e');
      rethrow;
    }
  }

  // 4. PUT /api/announcements/{id} - Update Announcement
  Future<bool> updateAnnouncement({
    required int announcementId,
    String? title,
    String? content,
    DateTime? scheduledAt,
  }) async {
    try {
      print('🔵 [AnnouncementService] Updating announcement #$announcementId...');
      
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (scheduledAt != null) {
        data['scheduled_at'] = scheduledAt.toIso8601String().replaceAll('T', ' ').substring(0, 19);
      }
      
      final response = await _dio.put('/announcements/$announcementId', data: data);
      
      print('✅ [AnnouncementService] Response: ${response.data}');
      
      if (response.data['success'] == true) {
        print('✅ [AnnouncementService] Updated announcement #$announcementId');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update announcement');
      }
    } catch (e) {
      print('❌ [AnnouncementService] Error updating announcement: $e');
      if (e is DioException && e.response != null) {
        print('❌ [AnnouncementService] Error response: ${e.response?.data}');
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
      }
      rethrow;
    }
  }

  // 5. DELETE /api/announcements/{id} - Delete Announcement
  Future<bool> deleteAnnouncement(int announcementId) async {
    try {
      print('🔵 [AnnouncementService] Deleting announcement #$announcementId...');
      
      final response = await _dio.delete('/announcements/$announcementId');
      
      print('✅ [AnnouncementService] Response: ${response.data}');
      
      if (response.data['success'] == true) {
        print('✅ [AnnouncementService] Deleted announcement #$announcementId');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete announcement');
      }
    } catch (e) {
      print('❌ [AnnouncementService] Error deleting announcement: $e');
      if (e is DioException && e.response != null) {
        print('❌ [AnnouncementService] Error response: ${e.response?.data}');
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
      }
      rethrow;
    }
  }

  // 6. POST /api/announcements/{id}/mark-read - Mark as Read
  Future<bool> markAsRead(int announcementId) async {
    try {
      print('🔵 [AnnouncementService] Marking announcement #$announcementId as read...');
      
      final response = await _dio.post('/announcements/$announcementId/mark-read');
      
      print('✅ [AnnouncementService] Response: ${response.data}');
      
      if (response.data['success'] == true) {
        print('✅ [AnnouncementService] Marked announcement #$announcementId as read');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to mark as read');
      }
    } catch (e) {
      print('❌ [AnnouncementService] Error marking as read: $e');
      rethrow;
    }
  }

  // 7. GET /api/announcements/conferences/list - List Conferences
  Future<List<Conference>> getConferences() async {
    try {
      print('🔵 [AnnouncementService] Getting conferences list...');
      
      final response = await _dio.get('/announcements/conferences/list');
      
      print('✅ [AnnouncementService] Response status: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        final conferences = (response.data['data'] as List)
            .map((item) => Conference.fromJson(item))
            .toList();
        print('✅ [AnnouncementService] Loaded ${conferences.length} conferences');
        return conferences;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load conferences');
      }
    } catch (e) {
      print('❌ [AnnouncementService] Error getting conferences: $e');
      rethrow;
    }
  }

  // 8. POST /api/announcements/preview-recipients - Preview Recipients
  Future<RecipientPreview> previewRecipients({
    required int conferenceId,
    required String audience,
  }) async {
    try {
      print('🔵 [AnnouncementService] Preview recipients (conference: $conferenceId, audience: $audience)...');
      
      final response = await _dio.post('/announcements/preview-recipients', data: {
        'conference_id': conferenceId,
        'audience': audience,
      });
      
      print('✅ [AnnouncementService] Response: ${response.data}');
      
      if (response.data['success'] == true) {
        final preview = RecipientPreview.fromJson(response.data['data']);
        print('✅ [AnnouncementService] Recipients count: ${preview.totalRecipients}');
        return preview;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to preview recipients');
      }
    } catch (e) {
      print('❌ [AnnouncementService] Error previewing recipients: $e');
      rethrow;
    }
  }
}

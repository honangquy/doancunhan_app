import 'package:flutter/foundation.dart';
import '../models/announcement.dart';
import '../services/announcement_service.dart';

class AnnouncementProvider with ChangeNotifier {
  final AnnouncementService _service = AnnouncementService();

  // State
  List<Announcement> _announcements = [];
  Statistics? _statistics;
  int? _unreadCount;
  Pagination? _pagination;
  Announcement? _currentDetail;
  List<Conference> _conferences = [];
  RecipientPreview? _recipientPreview;

  // Loading states
  bool _isLoading = false;
  bool _isDetailLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  bool _isLoadingConferences = false;
  bool _isPreviewingRecipients = false;

  // Error state
  String? _error;

  // Getters
  List<Announcement> get announcements => _announcements;
  Statistics? get statistics => _statistics;
  int? get unreadCount => _unreadCount;
  Pagination? get pagination => _pagination;
  Announcement? get currentDetail => _currentDetail;
  List<Conference> get conferences => _conferences;
  RecipientPreview? get recipientPreview => _recipientPreview;
  
  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  bool get isLoadingConferences => _isLoadingConferences;
  bool get isPreviewingRecipients => _isPreviewingRecipients;
  
  String? get error => _error;

  // Filter getters
  List<Announcement> get sentAnnouncements =>
      _announcements.where((a) => a.status == 'SENT').toList();
  
  List<Announcement> get scheduledAnnouncements =>
      _announcements.where((a) => a.status == 'SCHEDULED').toList();
  
  List<Announcement> get failedAnnouncements =>
      _announcements.where((a) => a.status == 'FAILED').toList();

  bool get hasMore => _pagination?.hasMore ?? false;

  // Statistics getters
  int get totalCount => _statistics?.total ?? _announcements.length;
  int get sentCount => _statistics?.sent ?? sentAnnouncements.length;
  int get scheduledCount => _statistics?.scheduled ?? scheduledAnnouncements.length;
  int get failedCount => _statistics?.failed ?? failedAnnouncements.length;

  // 1. Load Announcements
  Future<void> loadAnnouncements({
    String? status,
    int? conferenceId,
    int page = 1,
    bool refresh = false,
  }) async {
    if (refresh) {
      _announcements.clear();
      _pagination = null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getAnnouncements(
        status: status,
        conferenceId: conferenceId,
        page: page,
      );

      if (page == 1) {
        _announcements = result.announcements;
      } else {
        _announcements.addAll(result.announcements);
      }

      _statistics = result.statistics;
      _unreadCount = result.unreadCount;
      _pagination = result.pagination;

      print('✅ [AnnouncementProvider] Loaded ${_announcements.length} announcements');
    } catch (e) {
      print('❌ [AnnouncementProvider] Error loading announcements: $e');
      
      // Check if it's a 401 error
      if (e.toString().contains('401')) {
        _error = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
      } else {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Load More (Pagination)
  Future<void> loadMore({String? status, int? conferenceId}) async {
    if (!hasMore || _isLoading) return;

    final nextPage = (_pagination?.currentPage ?? 0) + 1;
    await loadAnnouncements(
      status: status,
      conferenceId: conferenceId,
      page: nextPage,
    );
  }

  // 3. Load Announcement Detail
  Future<void> loadAnnouncementDetail(int announcementId) async {
    _isDetailLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentDetail = await _service.getAnnouncementDetail(announcementId);
      print('✅ [AnnouncementProvider] Loaded announcement detail #$announcementId');
    } catch (e) {
      _error = e.toString();
      print('❌ [AnnouncementProvider] Error loading detail: $e');
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  // 4. Create Announcement
  Future<bool> createAnnouncement({
    required int conferenceId,
    required String title,
    required String content,
    required String audience,
    required List<String> channels,
    DateTime? scheduledAt,
  }) async {
    _isCreating = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _service.createAnnouncement(
        conferenceId: conferenceId,
        title: title,
        content: content,
        audience: audience,
        channels: channels,
        scheduledAt: scheduledAt,
      );

      print('✅ [AnnouncementProvider] Created announcement #${created.announcementId}');

      // Insert created announcement at top of the list so UI updates immediately
      _announcements.insert(0, created);

      // Optionally update statistics if available
      if (_statistics != null) {
        _statistics = Statistics(
          total: (_statistics!.total) + 1,
          sent: _statistics!.sent,
          scheduled: _statistics!.scheduled,
          failed: _statistics!.failed,
        );
      }

      notifyListeners();

      // If backend triggers realtime events, other clients will update themselves. If not,
      // you can still refresh from server to ensure consistent state:
      // await loadAnnouncements(refresh: true);

      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ [AnnouncementProvider] Error creating announcement: $e');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  // 5. Update Announcement
  Future<bool> updateAnnouncement(
    int announcementId, {
    required String title,
    required String content,
    required DateTime scheduledAt,
  }) async {
    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.updateAnnouncement(
        announcementId: announcementId,
        title: title,
        content: content,
        scheduledAt: scheduledAt,
      );

      if (success) {
        print('✅ [AnnouncementProvider] Updated announcement #$announcementId');
        
        // Refresh detail if viewing
        if (_currentDetail?.announcementId == announcementId) {
          await loadAnnouncementDetail(announcementId);
        }
        
        // Refresh list
        await loadAnnouncements(refresh: true);
      }

      return success;
    } catch (e) {
      _error = e.toString();
      print('❌ [AnnouncementProvider] Error updating announcement: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // 6. Delete Announcement
  Future<bool> deleteAnnouncement(int announcementId) async {
    _isDeleting = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.deleteAnnouncement(announcementId);

      if (success) {
        print('✅ [AnnouncementProvider] Deleted announcement #$announcementId');
        
        // Remove from list
        _announcements.removeWhere((a) => a.announcementId == announcementId);
        
        // Clear detail if viewing
        if (_currentDetail?.announcementId == announcementId) {
          _currentDetail = null;
        }
        
        // Refresh list to update statistics
        await loadAnnouncements(refresh: true);
      }

      return success;
    } catch (e) {
      _error = e.toString();
      print('❌ [AnnouncementProvider] Error deleting announcement: $e');
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  // 7. Mark as Read
  Future<bool> markAsRead(int announcementId) async {
    try {
      final success = await _service.markAsRead(announcementId);

      if (success) {
        print('✅ [AnnouncementProvider] Marked announcement #$announcementId as read');
        
        // Update local state
        final index = _announcements.indexWhere((a) => a.announcementId == announcementId);
        if (index != -1) {
          // Note: Since Announcement is immutable, we'd need to create a new instance
          // For now, just refresh the list
          await loadAnnouncements(refresh: true);
        }
      }

      return success;
    } catch (e) {
      _error = e.toString();
      print('❌ [AnnouncementProvider] Error marking as read: $e');
      return false;
    }
  }

  // 8. Load Conferences
  Future<void> loadConferences() async {
    _isLoadingConferences = true;
    _error = null;
    notifyListeners();

    try {
      _conferences = await _service.getConferences();
      print('✅ [AnnouncementProvider] Loaded ${_conferences.length} conferences');
    } catch (e) {
      _error = e.toString();
      print('❌ [AnnouncementProvider] Error loading conferences: $e');
    } finally {
      _isLoadingConferences = false;
      notifyListeners();
    }
  }

  // 9. Preview Recipients
  Future<RecipientPreview?> previewRecipients(int conferenceId, String audience) async {
    _isPreviewingRecipients = true;
    _error = null;
    notifyListeners();

    try {
      _recipientPreview = await _service.previewRecipients(
        conferenceId: conferenceId,
        audience: audience,
      );
      print('✅ [AnnouncementProvider] Preview: ${_recipientPreview?.totalRecipients} recipients');
      return _recipientPreview;
    } catch (e) {
      _error = e.toString();
      print('❌ [AnnouncementProvider] Error previewing recipients: $e');
      return null;
    } finally {
      _isPreviewingRecipients = false;
      notifyListeners();
    }
  }

  // 10. Clear Detail
  void clearDetail() {
    _currentDetail = null;
    notifyListeners();
  }

  // 11. Clear Error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 12. Clear Recipient Preview
  void clearRecipientPreview() {
    _recipientPreview = null;
    notifyListeners();
  }
}

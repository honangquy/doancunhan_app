import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../utils/constants.dart';
import '../../services/announcement_service.dart';
import '../../models/announcement.dart';

class NotificationsPage extends StatefulWidget {
  final Color? primaryColor;
  
  const NotificationsPage({
    Key? key,
    this.primaryColor,
  }) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin {
  final AnnouncementService _announcementService = AnnouncementService();
  bool _isLoading = true;
  List<Announcement> _notifications = [];
  int _unreadCount = 0;
  late TabController _tabController;
  int _currentPage = 1;
  bool _hasMore = true;
  
  Color get _primaryColor => widget.primaryColor ?? AppColors.authorPrimary;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {}); // Just rebuild to filter
    }
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _notifications = [];
        _hasMore = true;
      });
    }
    
    if (!_hasMore && !refresh) return;
    
    setState(() => _isLoading = true);
    try {
      // User API doesn't filter by status, it returns received announcements
      final result = await _announcementService.getAnnouncements(
        page: _currentPage,
        perPage: 15,
      );
      
      setState(() {
        if (refresh || _currentPage == 1) {
          _notifications = result.announcements;
        } else {
          _notifications.addAll(result.announcements);
        }
        _unreadCount = result.unreadCount ?? 0;
        _hasMore = result.pagination?.hasMore ?? false;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải thông báo: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  int get _totalCount => _notifications.length;
  int get _readCount => _notifications.where((n) => n.isRead == true).length;

  List<Announcement> get _filteredNotifications {
    final currentTab = _tabController.index;
    switch (currentTab) {
      case 0:
        return _notifications; // All
      case 1:
        return _notifications.where((n) => n.isRead != true).toList(); // Unread
      default:
        return _notifications;
    }
  }

  Color _getStatusColor(String? status) {
    // For user, use the primary color
    return _primaryColor;
  }

  IconData _getStatusIcon(String? status) {
    // For user, we use notification bell icon
    return CupertinoIcons.bell_fill;
  }

  Future<void> _markAsRead(Announcement notification) async {
    if (notification.isRead == true) return;
    
    try {
      await _announcementService.markAsRead(notification.announcementId);
      setState(() {
        // Update local state
        final index = _notifications.indexWhere((n) => n.announcementId == notification.announcementId);
        if (index != -1) {
          _notifications[index] = Announcement(
            announcementId: notification.announcementId,
            title: notification.title,
            content: notification.content,
            audience: notification.audience,
            channels: notification.channels,
            status: notification.status,
            scheduledAt: notification.scheduledAt,
            conferenceId: notification.conferenceId,
            conferenceName: notification.conferenceName,
            sentAt: notification.sentAt,
            createdAt: notification.createdAt,
            createdBy: notification.createdBy,
            createdByName: notification.createdByName,
            recipientCount: notification.recipientCount,
            isRead: true,
            readAt: DateTime.now(),
            receivedAt: notification.receivedAt,
            statistics: notification.statistics,
          );
          if (_unreadCount > 0) _unreadCount--;
        }
      });
    } catch (e) {
      print('❌ Error marking as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primaryColor,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'Tải lại',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Statistics Cards
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildStatCard(
                      'Tổng số',
                      _totalCount.toString(),
                      CupertinoIcons.bell_fill,
                      Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Chưa đọc',
                      _unreadCount.toString(),
                      CupertinoIcons.bell_fill,
                      Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Đã đọc',
                      _readCount.toString(),
                      CupertinoIcons.checkmark_circle_fill,
                      Colors.white.withOpacity(0.9),
                    ),
                  ],
                ),
              ),
              // Tabs
              Container(
                color: _primaryColor,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  onTap: (_) => setState(() {}),
                  tabs: const [
                    Tab(text: 'Tất cả'),
                    Tab(text: 'Chưa đọc'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading && _notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _filteredNotifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => _loadNotifications(refresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredNotifications.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _filteredNotifications.length) {
                        // Load more indicator
                        if (!_isLoading) {
                          _loadNotifications();
                        }
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final notification = _filteredNotifications[index];
                      final isRead = notification.isRead ?? false;
                      return _buildNotificationCard(notification, isRead);
                    },
                  ),
                ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: _primaryColor),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.bell_slash,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có thông báo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Các thông báo sẽ hiển thị ở đây',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Announcement notification, bool isRead) {
    final statusColor = _getStatusColor(notification.status);
    final statusIcon = _getStatusIcon(notification.status);
    final sentTime = notification.sentAt ?? notification.receivedAt ?? notification.createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? Colors.grey[200]! : Colors.blue[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _markAsRead(notification);
            _showNotificationDetail(notification);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.time,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(sentTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          if (notification.conferenceName != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              CupertinoIcons.building_2_fill,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                notification.conferenceName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDetail(Announcement notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Conference info
                    if (notification.conferenceName != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.building_2_fill,
                              color: _primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                notification.conferenceName!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Time info
                    Row(
                      children: [
                        Icon(CupertinoIcons.time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          'Nhận lúc: ${_formatDate(notification.sentAt ?? notification.receivedAt ?? notification.createdAt)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Content
                    Text(
                      notification.content,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

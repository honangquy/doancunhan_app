import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/announcement_provider.dart';
import '../../models/announcement.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../chair/chair_announcement_detail_screen.dart';
import '../chair/chair_create_announcement_screen.dart';

/// Màn hình Thông báo - Dành cho TẤT CẢ user roles
/// - Chair: Có thể tạo thông báo mới
/// - Author/Reviewer: Chỉ xem danh sách thông báo nhận được

class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsCenterScreen> createState() => _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _scrollController.addListener(_handleScroll);

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnnouncementProvider>();
      provider.loadAnnouncements(refresh: true);
      if (_isChair) {
        provider.loadConferences();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isChair => _authService.userRole == 'CHAIR';

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) return;

    String? filter;
    switch (_tabController.index) {
      case 0:
        filter = null; // Tất cả
        break;
      case 1:
        filter = 'SENT'; // Đã gửi
        break;
      case 2:
        filter = 'SCHEDULED'; // Đã lên lịch
        break;
      case 3:
        filter = 'FAILED'; // Thất bại
        break;
    }

    context.read<AnnouncementProvider>().loadAnnouncements(
          status: filter,
          refresh: true,
        );
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<AnnouncementProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Thông báo'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Đã gửi'),
            Tab(text: 'Đã lên lịch'),
            Tab(text: 'Thất bại'),
          ],
        ),
      ),
      floatingActionButton: _isChair
          ? FloatingActionButton.extended(
              onPressed: _navigateToCreate,
              backgroundColor: AppColors.primary,
              icon: const Icon(CupertinoIcons.add),
              label: const Text('Tạo thông báo'),
            )
          : null,
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Statistics Cards
              _buildStatisticsCards(provider),

              // Notifications List
              Expanded(
                child: _buildContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatisticsCards(AnnouncementProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: CupertinoIcons.doc_text,
              label: 'Tổng',
              value: provider.totalCount.toString(),
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: CupertinoIcons.checkmark_circle,
              label: 'Đã gửi',
              value: provider.sentCount.toString(),
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: CupertinoIcons.clock,
              label: 'Đã lên lịch',
              value: provider.scheduledCount.toString(),
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: CupertinoIcons.xmark_circle,
              label: 'Thất bại',
              value: provider.failedCount.toString(),
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AnnouncementProvider provider) {
    if (provider.isLoading && provider.announcements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.announcements.isEmpty) {
      return _buildError(provider);
    }

    if (provider.announcements.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadAnnouncements(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.announcements.length + 1,
        itemBuilder: (context, index) {
          if (index == provider.announcements.length) {
            return provider.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink();
          }

          return _buildAnnouncementCard(provider.announcements[index]);
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(announcement.announcementId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      announcement.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(announcement.status),
                ],
              ),

              const SizedBox(height: 12),

              // Audience
              Row(
                children: [
                  Icon(
                    CupertinoIcons.person_3_fill,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    announcement.audienceText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    CupertinoIcons.layers_alt_fill,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    announcement.channelsText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Time
              Row(
                children: [
                  Icon(
                    CupertinoIcons.clock,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getTimeDisplay(announcement),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String text;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'SENT':
        backgroundColor = Colors.green;
        text = 'Đã gửi';
        icon = CupertinoIcons.checkmark_circle_fill;
        break;
      case 'SCHEDULED':
        backgroundColor = Colors.orange;
        text = 'Đã lên lịch';
        icon = CupertinoIcons.clock_fill;
        break;
      case 'FAILED':
        backgroundColor = Colors.red;
        text = 'Thất bại';
        icon = CupertinoIcons.xmark_circle_fill;
        break;
      default:
        backgroundColor = Colors.grey;
        text = status;
        icon = CupertinoIcons.circle_fill;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeDisplay(Announcement announcement) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    if (announcement.status == 'SENT' && announcement.sentAt != null) {
      return 'Đã gửi: ${dateFormat.format(announcement.sentAt!)}';
    } else if (announcement.status == 'SCHEDULED') {
      return 'Lên lịch: ${dateFormat.format(announcement.scheduledAt)}';
    } else {
      return 'Tạo: ${dateFormat.format(announcement.createdAt)}';
    }
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.bell_slash,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có thông báo nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Danh sách thông báo của bạn trống',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(AnnouncementProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Đã xảy ra lỗi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? 'Không thể tải danh sách thông báo',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.loadAnnouncements(refresh: true),
              icon: const Icon(CupertinoIcons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChairCreateAnnouncementScreen(),
      ),
    ).then((created) {
      if (created == true) {
        context.read<AnnouncementProvider>().loadAnnouncements(refresh: true);
      }
    });
  }

  void _navigateToDetail(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChairAnnouncementDetailScreen(announcementId: id),
      ),
    );
  }
}

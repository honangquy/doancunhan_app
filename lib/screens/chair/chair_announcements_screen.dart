import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/announcement_provider.dart';
import '../../models/announcement.dart';
import '../../utils/constants.dart';
import 'chair_announcement_detail_screen.dart';
import '../user_notifications/create_broadcast_notification_screen.dart'; // ✅ Broadcast screen mới

class ChairAnnouncementsScreen extends StatefulWidget {
  const ChairAnnouncementsScreen({super.key});

  @override
  State<ChairAnnouncementsScreen> createState() => _ChairAnnouncementsScreenState();
}

class _ChairAnnouncementsScreenState extends State<ChairAnnouncementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  String? _currentFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _scrollController.addListener(_handleScroll);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnnouncementProvider>();
      provider.loadAnnouncements(refresh: true);
      provider.loadConferences();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) return;
    
    String? filter;
    switch (_tabController.index) {
      case 1:
        filter = 'SENT';
        break;
      case 2:
        filter = 'SCHEDULED';
        break;
      case 3:
        filter = 'FAILED';
        break;
      default:
        filter = null;
    }
    
    if (_currentFilter != filter) {
      _currentFilter = filter;
      context.read<AnnouncementProvider>().loadAnnouncements(
        status: filter,
        refresh: true,
      );
    }
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<AnnouncementProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.loadMore(status: _currentFilter);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.add_circled_solid),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateBroadcastNotificationScreen(), // ✅ NEW
                ),
              );
            },
            tooltip: 'Tạo thông báo broadcast',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: Column(
            children: [
              // Statistics
              Consumer<AnnouncementProvider>(
                builder: (context, provider, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        _buildStatCard(
                          'Tổng',
                          provider.totalCount.toString(),
                          CupertinoIcons.doc_text_fill,
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          'Đã gửi',
                          provider.sentCount.toString(),
                          CupertinoIcons.check_mark_circled_solid,
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          'Đã lên lịch',
                          provider.scheduledCount.toString(),
                          CupertinoIcons.clock_fill,
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          'Thất bại',
                          provider.failedCount.toString(),
                          CupertinoIcons.xmark_circle_fill,
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Tabs
              Container(
                color: AppColors.primary,
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
                  tabs: const [
                    Tab(text: 'Tất cả'),
                    Tab(text: 'Đã gửi'),
                    Tab(text: 'Đã lên lịch'),
                    Tab(text: 'Thất bại'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnnouncementsList(),
          _buildAnnouncementsList(),
          _buildAnnouncementsList(),
          _buildAnnouncementsList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
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
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
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

  Widget _buildAnnouncementsList() {
    return Consumer<AnnouncementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.announcements.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.exclamationmark_circle, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Lỗi: ${provider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadAnnouncements(
                    status: _currentFilter,
                    refresh: true,
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final announcements = provider.announcements;

        if (announcements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.bell_slash, size: 100, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Chưa có thông báo',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadAnnouncements(
            status: _currentFilter,
            refresh: true,
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: announcements.length + (provider.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == announcements.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              final announcement = announcements[index];
              return _buildAnnouncementCard(announcement, provider);
            },
          ),
        );
      },
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement, AnnouncementProvider provider) {
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;
    
    switch (announcement.status) {
      case 'SENT':
        statusColor = Colors.green[700]!;
        statusBgColor = Colors.green[50]!;
        statusIcon = CupertinoIcons.checkmark_circle_fill;
        break;
      case 'SCHEDULED':
        statusColor = Colors.orange[700]!;
        statusBgColor = Colors.orange[50]!;
        statusIcon = CupertinoIcons.clock_fill;
        break;
      case 'FAILED':
        statusColor = Colors.red[700]!;
        statusBgColor = Colors.red[50]!;
        statusIcon = CupertinoIcons.xmark_circle_fill;
        break;
      default:
        statusColor = Colors.grey[700]!;
        statusBgColor = Colors.grey[50]!;
        statusIcon = CupertinoIcons.circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChairAnnouncementDetailScreen(
                announcementId: announcement.announcementId,
              ),
            ),
          );
          
          if (result == true && mounted) {
            provider.loadAnnouncements(status: _currentFilter, refresh: true);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status & Conference
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          announcement.statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      announcement.conferenceName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (announcement.isScheduled)
                    IconButton(
                      icon: const Icon(CupertinoIcons.ellipsis, size: 20),
                      onPressed: () => _showOptionsMenu(announcement, provider),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Title
              Text(
                announcement.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Content preview
              Text(
                announcement.content,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Channels (SYSTEM badge) - giống Web
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      announcement.channelsText.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Schedule date & Recipient count - giống Web
              Row(
                children: [
                  Icon(CupertinoIcons.calendar, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Lên lịch: ${_formatDateTime(announcement.scheduledAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  if (announcement.recipientCount != null) ...[
                    Icon(CupertinoIcons.person_3_fill, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${announcement.recipientCount} users',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showOptionsMenu(Announcement announcement, AnnouncementProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(CupertinoIcons.pencil),
              title: const Text('Chỉnh sửa'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit screen
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.delete, color: Colors.red),
              title: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xác nhận xóa'),
                    content: const Text('Bạn có chắc muốn xóa thông báo này?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true && mounted) {
                  final success = await provider.deleteAnnouncement(announcement.announcementId);
                  
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa thông báo'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

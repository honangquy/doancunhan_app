import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/announcement_provider.dart';
import '../../models/announcement.dart';
import '../../utils/constants.dart';
import 'chair_edit_announcement_screen.dart';

class ChairAnnouncementDetailScreen extends StatefulWidget {
  final int announcementId;

  const ChairAnnouncementDetailScreen({
    super.key,
    required this.announcementId,
  });

  @override
  State<ChairAnnouncementDetailScreen> createState() => _ChairAnnouncementDetailScreenState();
}

class _ChairAnnouncementDetailScreenState extends State<ChairAnnouncementDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().loadAnnouncementDetail(widget.announcementId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Chi tiết thông báo'),
        actions: [
          Consumer<AnnouncementProvider>(
            builder: (context, provider, child) {
              final announcement = provider.currentDetail;
              if (announcement == null || !announcement.isScheduled) {
                return const SizedBox();
              }

              return PopupMenuButton(
                icon: const Icon(CupertinoIcons.ellipsis_vertical),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.pencil, size: 20),
                        SizedBox(width: 12),
                        Text('Chỉnh sửa'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Xóa', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'edit') {
                    _navigateToEdit(announcement);
                  } else if (value == 'delete') {
                    _confirmDelete(provider, announcement);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) {
          if (provider.isDetailLoading) {
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
                    onPressed: () => provider.loadAnnouncementDetail(widget.announcementId),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final announcement = provider.currentDetail;
          if (announcement == null) {
            return const Center(child: Text('Không tìm thấy thông báo'));
          }

          final stats = announcement.statistics;

          return RefreshIndicator(
            onRefresh: () => provider.loadAnnouncementDetail(widget.announcementId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  _buildStatusBadge(announcement),
                  
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    announcement.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Meta Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            CupertinoIcons.building_2_fill,
                            'Hội nghị',
                            announcement.conferenceName,
                            Colors.blue,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            CupertinoIcons.person_2_fill,
                            'Đối tượng',
                            announcement.audienceText,
                            Colors.green,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            CupertinoIcons.antenna_radiowaves_left_right,
                            'Kênh gửi',
                            announcement.channelsText,
                            Colors.purple,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            CupertinoIcons.calendar,
                            'Lên lịch lúc',
                            _formatDateTime(announcement.scheduledAt),
                            Colors.orange,
                          ),
                          if (announcement.sentAt != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              CupertinoIcons.checkmark_alt_circle_fill,
                              'Đã gửi lúc',
                              _formatDateTime(announcement.sentAt!),
                              Colors.green,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Statistics Card (only for SENT announcements)
                  if (stats != null && announcement.isSent) ...[
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(CupertinoIcons.chart_bar_fill, color: AppColors.primary),
                                const SizedBox(width: 8),
                                const Text(
                                  'Thống kê',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Read percentage
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tỷ lệ đã đọc',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: stats.readPercentage / 100,
                                        backgroundColor: Colors.grey[200],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          stats.readPercentage >= 70
                                              ? Colors.green
                                              : stats.readPercentage >= 40
                                                  ? Colors.orange
                                                  : Colors.red,
                                        ),
                                        minHeight: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${stats.readPercentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Statistics Grid
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatBox(
                                    'Tổng người nhận',
                                    stats.totalRecipients.toString(),
                                    Colors.blue,
                                    CupertinoIcons.person_3_fill,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatBox(
                                    'Đã đọc',
                                    stats.readCount.toString(),
                                    Colors.green,
                                    CupertinoIcons.checkmark_circle_fill,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatBox(
                                    'Chưa đọc',
                                    stats.unreadCount.toString(),
                                    Colors.orange,
                                    CupertinoIcons.circle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Content Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(CupertinoIcons.doc_text_fill, color: AppColors.primary),
                              const SizedBox(width: 8),
                              const Text(
                                'Nội dung',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            announcement.content,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(Announcement announcement) {
    Color color;
    Color bgColor;
    IconData icon;
    
    switch (announcement.status) {
      case 'SENT':
        color = Colors.green[700]!;
        bgColor = Colors.green[50]!;
        icon = CupertinoIcons.checkmark_circle_fill;
        break;
      case 'SCHEDULED':
        color = Colors.orange[700]!;
        bgColor = Colors.orange[50]!;
        icon = CupertinoIcons.clock_fill;
        break;
      case 'FAILED':
        color = Colors.red[700]!;
        bgColor = Colors.red[50]!;
        icon = CupertinoIcons.xmark_circle_fill;
        break;
      default:
        color = Colors.grey[700]!;
        bgColor = Colors.grey[50]!;
        icon = CupertinoIcons.circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            announcement.statusText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} lúc ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToEdit(Announcement announcement) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChairEditAnnouncementScreen(
          announcement: announcement,
        ),
      ),
    );

    if (result == true && mounted) {
      context.read<AnnouncementProvider>().loadAnnouncementDetail(widget.announcementId);
    }
  }

  void _confirmDelete(AnnouncementProvider provider, Announcement announcement) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa thông báo "${announcement.title}"?\n\nHành động này không thể hoàn tác.',
        ),
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
        Navigator.pop(context, true); // Return to list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa thông báo'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

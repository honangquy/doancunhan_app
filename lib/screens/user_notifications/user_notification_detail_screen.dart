import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/user_notification_provider.dart';
import '../../models/user_notification.dart';
import '../../utils/constants.dart';

/// Màn hình chi tiết User Notification
/// 
/// **⚠️ IMPORTANT:** 
/// Khi mở màn hình này, notification TỰ ĐỘNG được đánh dấu là đã đọc
/// (do API GET /api/notifications/{id} tự động mark as read)
/// 
/// Features:
/// - Hiển thị full content (HTML text)
/// - Hiển thị metadata (ngày tạo, ngày đọc)
/// - Nút xóa notification
/// - Auto mark as read khi load
/// 
/// Tham khảo: MOBILE_API_INTEGRATION_GUIDE.md

class UserNotificationDetailScreen extends StatefulWidget {
  final int notificationId;

  const UserNotificationDetailScreen({
    Key? key,
    required this.notificationId,
  }) : super(key: key);

  @override
  State<UserNotificationDetailScreen> createState() => _UserNotificationDetailScreenState();
}

class _UserNotificationDetailScreenState extends State<UserNotificationDetailScreen> {
  @override
  void initState() {
    super.initState();
    
    // Load notification detail (auto mark as read)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserNotificationProvider>().loadNotificationDetail(widget.notificationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Chi tiết thông báo'),
        actions: [
          Consumer<UserNotificationProvider>(
            builder: (context, provider, child) {
              if (provider.currentDetail == null) return const SizedBox.shrink();
              
              return IconButton(
                onPressed: () => _handleDelete(provider.currentDetail!),
                icon: const Icon(CupertinoIcons.delete),
                tooltip: 'Xóa thông báo',
              );
            },
          ),
        ],
      ),
      body: Consumer<UserNotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDetail) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _buildError(provider);
          }

          if (provider.currentDetail == null) {
            return _buildNotFound();
          }

          return _buildContent(provider.currentDetail!);
        },
      ),
    );
  }

  Widget _buildContent(UserNotification notification) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
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
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getTypeColor(notification.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getTypeColor(notification.type).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          notification.typeIcon,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          notification.typeText,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _getTypeColor(notification.type),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Metadata
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Created time
                      _buildMetadataRow(
                        icon: CupertinoIcons.clock,
                        label: 'Tạo lúc:',
                        value: notification.formattedDateTime,
                        color: Colors.blue,
                      ),
                      
                      const SizedBox(height: 8),

                      // Read status
                      if (notification.isRead && notification.readAt != null)
                        _buildMetadataRow(
                          icon: CupertinoIcons.checkmark_circle_fill,
                          label: 'Đã đọc:',
                          value: notification.formattedReadAt!,
                          color: Colors.green,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Content card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content header
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.doc_text,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Nội dung',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Content body (remove HTML tags for now)
                  SelectableText(
                    _stripHtmlTags(notification.message),
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Delete button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _handleDelete(notification),
              icon: const Icon(CupertinoIcons.delete, size: 20),
              label: const Text('Xóa thông báo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMetadataRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(UserNotificationProvider provider) {
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
              provider.error ?? 'Không thể tải thông báo',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(CupertinoIcons.back),
                  label: const Text('Quay lại'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<UserNotificationProvider>().loadNotificationDetail(widget.notificationId);
                  },
                  icon: const Icon(CupertinoIcons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.search,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy thông báo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thông báo có thể đã bị xóa',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(CupertinoIcons.back),
              label: const Text('Quay lại'),
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

  // ==================== Helper Methods ====================

  String _stripHtmlTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'BROADCAST':
        return Colors.blue;
      case 'ANNOUNCEMENT':
        return Colors.orange;
      case 'REMINDER':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // ==================== Actions ====================

  Future<void> _handleDelete(UserNotification notification) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thông báo'),
        content: const Text('Bạn có chắc muốn xóa thông báo này?\nHành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<UserNotificationProvider>();
    final success = await provider.deleteNotification(notification.notificationId);

    if (!mounted) return;

    if (success) {
      // Close detail screen và quay về list
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa thông báo'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Không thể xóa thông báo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

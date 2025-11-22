import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../../providers/reviewer_provider.dart';
import '../../utils/constants.dart';
import 'reviewer_review_form_screen.dart';

class ReviewerAssignmentDetailScreen extends StatefulWidget {
  final int assignmentId;

  const ReviewerAssignmentDetailScreen({super.key, required this.assignmentId});

  @override
  State<ReviewerAssignmentDetailScreen> createState() => _ReviewerAssignmentDetailScreenState();
}

class _ReviewerAssignmentDetailScreenState extends State<ReviewerAssignmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewerProvider>().loadAssignmentDetail(widget.assignmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.reviewerPrimary,
        foregroundColor: Colors.white,
        title: const Text('Chi tiết phân công', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<ReviewerProvider>(
        builder: (context, provider, child) {
          if (provider.isAssignmentDetailLoading && provider.assignmentDetail == null) {
            return const Center(child: CupertinoActivityIndicator(radius: 20));
          }

          if (provider.assignmentDetailError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.exclamationmark_triangle, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Lỗi tải dữ liệu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800])),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(provider.assignmentDetailError!, style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadAssignmentDetail(widget.assignmentId),
                    icon: const Icon(CupertinoIcons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final detail = provider.assignmentDetail;
          if (detail == null) return const Center(child: Text('Không có dữ liệu'));

          final assignment = detail.assignment;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and Actions
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusBadge(assignment.status),
                      if (assignment.isPending) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showAcceptDialog(context, provider),
                                icon: const Icon(CupertinoIcons.checkmark_circle),
                                label: const Text('Chấp nhận'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showDeclineDialog(context, provider),
                                icon: const Icon(CupertinoIcons.xmark_circle),
                                label: const Text('Từ chối'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (assignment.isAccepted && detail.existingReview == null) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ReviewerReviewFormScreen(assignmentId: widget.assignmentId)),
                            ),
                            icon: const Icon(CupertinoIcons.pencil),
                            label: const Text('Bắt đầu phản biện'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.reviewerPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Paper Information
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Thông tin bài báo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      const SizedBox(height: 16),
                      Text(assignment.paperTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      if (assignment.paperAbstract != null) ...[
                        Text('Tóm tắt:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                        const SizedBox(height: 4),
                        Text(assignment.paperAbstract!, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        const SizedBox(height: 12),
                      ],
                      if (assignment.keywords != null) ...[
                        Text('Từ khóa:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: assignment.keywords!.split(',').map((keyword) {
                            return Chip(
                              label: Text(keyword.trim(), style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppColors.reviewerPrimary.withOpacity(0.1),
                              padding: EdgeInsets.zero,
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                // Conference Information
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hội thảo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      const SizedBox(height: 12),
                      _buildInfoRow('Tên hội thảo', assignment.conferenceName),
                      if (assignment.assignedByName != null) _buildInfoRow('Phân công bởi', assignment.assignedByName!),
                      _buildInfoRow('Ngày phân công', '${assignment.assignedAt.day}/${assignment.assignedAt.month}/${assignment.assignedAt.year}'),
                      if (assignment.deadline != null)
                        _buildInfoRow('Hạn chót', '${assignment.deadline!.day}/${assignment.deadline!.month}/${assignment.deadline!.year}', isDeadline: assignment.isOverdue),
                    ],
                  ),
                ),

                // Authors
                if (detail.authors.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tác giả', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                        const SizedBox(height: 12),
                        ...detail.authors.map((author) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.reviewerPrimary.withOpacity(0.1),
                                    child: Text('${author.authorOrder}', style: TextStyle(color: AppColors.reviewerPrimary, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(author.fullName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                            if (author.isContact) ...[
                                              const SizedBox(width: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                                child: const Text('Liên hệ', style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.w600)),
                                              ),
                                            ],
                                          ],
                                        ),
                                        Text(author.email, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                        if (author.organization != null) Text(author.organization!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],

                // Paper Versions
                if (detail.versions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phiên bản bài báo (${detail.versions.length})', 
                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                        const SizedBox(height: 12),
                        ...detail.versions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final version = entry.value;
                          final isLatest = index == 0; // First version in list is latest
                          final isRevision = version.note?.toLowerCase().contains('revision') ?? false;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                              color: isLatest ? AppColors.reviewerPrimary.withOpacity(0.05) : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('V${version.versionNo}', 
                                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    if (isLatest) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('MỚI NHẤT', 
                                             style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    if (isRevision)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('REVISION', 
                                             style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(CupertinoIcons.calendar, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${version.submittedAt.day}/${version.submittedAt.month}/${version.submittedAt.year} ${version.submittedAt.hour}:${version.submittedAt.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                if (version.note != null && version.note!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(CupertinoIcons.info_circle, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(version.note!, 
                                             style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _downloadPaper(version.filePath),
                                    icon: const Icon(CupertinoIcons.cloud_download, size: 18),
                                    label: const Text('Tải xuống'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.reviewerPrimary,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],

                // Existing Review (if any)
                if (detail.existingReview != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Phản biện của bạn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                            const Spacer(),
                            if (detail.existingReview!.isDraft)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                child: const Text('Nháp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (detail.existingReview!.totalScore != null)
                          Text('Điểm trung bình: ${detail.existingReview!.totalScore!.toStringAsFixed(1)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        if (detail.existingReview!.recommendationCode != null)
                          Text('Khuyến nghị: ${detail.existingReview!.recommendationCode}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ReviewerReviewFormScreen(assignmentId: widget.assignmentId, existingReview: detail.existingReview)),
                            ),
                            icon: const Icon(CupertinoIcons.pencil),
                            label: Text(detail.existingReview!.isDraft ? 'Tiếp tục chỉnh sửa' : 'Xem chi tiết'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'PENDING': color = Colors.orange; label = 'Chờ xử lý'; break;
      case 'ACCEPTED': color = Colors.green; label = 'Đã nhận'; break;
      case 'COMPLETED': color = Colors.blue; label = 'Hoàn thành'; break;
      case 'DECLINED': color = Colors.red; label = 'Từ chối'; break;
      default: color = Colors.grey; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isDeadline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600]))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDeadline ? Colors.red : Colors.grey[800]))),
        ],
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, ReviewerProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chấp nhận phân công'),
        content: const Text('Bạn có chắc chắn muốn chấp nhận phân công phản biện này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.acceptAssignment(widget.assignmentId);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã chấp nhận phân công thành công'), backgroundColor: Colors.green),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.assignmentDetailError ?? 'Có lỗi xảy ra'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Chấp nhận'),
          ),
        ],
      ),
    );
  }

  void _showDeclineDialog(BuildContext context, ReviewerProvider provider) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối phân công'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Vui lòng cho biết lý do từ chối:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nhập lý do...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập lý do'), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(ctx);
              final success = await provider.declineAssignment(widget.assignmentId, reason);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã từ chối phân công'), backgroundColor: Colors.orange),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.assignmentDetailError ?? 'Có lỗi xảy ra'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }

  void _downloadPaper(String filePath) async {
    if (!mounted) return;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(radius: 20),
            const SizedBox(height: 16),
            const Text('Đang tải xuống...'),
          ],
        ),
      ),
    );

    try {
      // Get storage directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Không thể truy cập thư mục lưu trữ');
      }

      // Create Downloads folder
      final downloadsPath = '${directory.path}/Downloads';
      final downloadsDir = Directory(downloadsPath);
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Extract filename from path
      final fileName = filePath.split('/').last;
      final savePath = '$downloadsPath/$fileName';

      // Download file
      final dio = Dio();
      // Access files via Laravel's storage symlink
      final downloadUrl = 'http://127.0.0.1:8000/storage/$filePath';
      
      print('📥 Downloading from: $downloadUrl');
      print('💾 Saving to: $savePath');
      
      await dio.download(
        downloadUrl,
        savePath,
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print('📊 Download progress: $progress%');
          }
        },
      );

      if (!mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);

      // Show success dialog with options
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              const Text('Tải xuống thành công'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('File đã được lưu vào:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  savePath,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                final result = await OpenFile.open(savePath);
                if (result.type != ResultType.done && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Không thể mở file: ${result.message}'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              icon: const Icon(CupertinoIcons.doc_text, size: 18),
              label: const Text('Mở file'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.reviewerPrimary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );

    } catch (e) {
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              const Text('Lỗi tải xuống'),
            ],
          ),
          content: Text('Không thể tải file: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _downloadPaper(filePath); // Retry
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
  }
}

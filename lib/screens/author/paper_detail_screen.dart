import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/paper_detail_provider.dart';
import '../../models/paper_detail_new.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PaperDetailScreen extends StatefulWidget {
  final int paperId;

  const PaperDetailScreen({
    Key? key,
    required this.paperId,
  }) : super(key: key);

  @override
  State<PaperDetailScreen> createState() => _PaperDetailScreenState();
}

class _PaperDetailScreenState extends State<PaperDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaperDetailProvider>().loadPaperDetailFull(widget.paperId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết bài báo'),
        backgroundColor: AppColors.authorPrimary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PaperDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
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
                    onPressed: () => provider.loadPaperDetailFull(widget.paperId),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final paper = provider.paperDetailFull;
          if (paper == null) {
            return const Center(child: Text('Không tìm thấy bài báo'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Paper ID & Status
                _buildHeaderSection(paper),
                const SizedBox(height: 24),
                
                // Basic Info
                _buildBasicInfoSection(paper),
                const SizedBox(height: 24),
                
                // Authors
                _buildAuthorsSection(paper),
                const SizedBox(height: 24),
                
                // Reviewers/Assignments (always show)
                _buildAssignmentsSection(paper),
                const SizedBox(height: 24),
                
                // Reviews (always show)
                _buildReviewsSection(paper),
                const SizedBox(height: 24),
                
                // Actions
                _buildActionsSection(paper, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(PaperDetailFull paper) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mã bài báo: #${paper.paperId}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ngày nộp: ${paper.formattedCreatedAt}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: paper.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: paper.statusColor.withOpacity(0.3)),
              ),
              child: Text(
                paper.statusName,
                style: TextStyle(
                  color: paper.statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(PaperDetailFull paper) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Thông tin cơ bản'),
            const SizedBox(height: 12),
            
            // Title
            _buildInfoRow('Tiêu đề', paper.title),
            const Divider(height: 24),
            
            // Conference
            _buildInfoRow('Hội thảo', paper.conferenceTitle),
            const Divider(height: 24),
            
            // Keywords
            _buildInfoRow('Từ khóa', paper.keywords),
            const Divider(height: 24),
            
            // Abstract
            const Text(
              'Tóm tắt',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              paper.abstract,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            
            // Deadline info
            if (paper.deadlineSubmission != null || paper.deadlineCameraReady != null)
              ...[
                const Divider(height: 24),
                if (paper.formattedDeadlineSubmission != null)
                  _buildInfoRow('Hạn nộp bài', paper.formattedDeadlineSubmission!),
                if (paper.formattedDeadlineCameraReady != null)
                  ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Hạn nộp bản chính thức', paper.formattedDeadlineCameraReady!),
                  ],
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorsSection(PaperDetailFull paper) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Tác giả (${paper.authors.length})'),
            const SizedBox(height: 12),
            ...paper.authors.asMap().entries.map((entry) {
              final author = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.authorPrimary.withOpacity(0.1),
                      child: Text(
                        '${author.authorOrder}',
                        style: TextStyle(
                          color: AppColors.authorPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                author.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              if (author.isContact)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Liên hệ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            author.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (author.organization != null)
                            Text(
                              author.organization!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsSection(PaperDetailFull paper) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Phản biện viên (${paper.assignments.length})'),
            const SizedBox(height: 12),
            
            // Debug log
            Builder(builder: (context) {
              print('📱 [DEBUG] Assignments length: ${paper.assignments.length}');
              return const SizedBox.shrink();
            }),
            
            // Hiển thị message nếu chưa có phân công
            if (paper.assignments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.person_2,
                      size: 48,
                      color: Colors.blue.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chưa có phân công phản biện',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bài báo đang chờ được phân công cho phản biện viên',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...paper.assignments.map((assignment) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: assignment.statusColor,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment.reviewerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Phân công: ${assignment.assignedAt}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (assignment.reviewSubmittedAt != null)
                            Text(
                              'Đã nộp: ${assignment.reviewSubmittedAt}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: assignment.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        assignment.statusText,
                        style: TextStyle(
                          fontSize: 11,
                          color: assignment.statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection(PaperDetailFull paper) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Đánh giá (${paper.reviews.length})'),
            const SizedBox(height: 12),
            
            // Debug log
            Builder(builder: (context) {
              print('📱 [DEBUG] Reviews length: ${paper.reviews.length}');
              return const SizedBox.shrink();
            }),
            
            // Hiển thị message nếu chưa có đánh giá
            if (paper.reviews.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.star,
                      size: 48,
                      color: Colors.amber.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chưa có đánh giá',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paper.assignments.isEmpty
                          ? 'Bài báo chưa được phân công phản biện'
                          : 'Phản biện viên đang đánh giá bài báo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber.shade600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...paper.reviews.map((review) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            review.reviewerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (review.averageScore != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getScoreColor(review.averageScore!)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${review.averageScore!.toStringAsFixed(1)}/10',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getScoreColor(review.averageScore!),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (review.relevanceScore != null)
                        _buildScoreRow('Liên quan', review.relevanceScore!),
                      if (review.qualityScore != null)
                        _buildScoreRow('Chất lượng', review.qualityScore!),
                      if (review.originalityScore != null)
                        _buildScoreRow('Độc đáo', review.originalityScore!),
                      if (review.recommendation != null)
                        ...[
                          const SizedBox(height: 8),
                          _buildInfoRow('Khuyến nghị', review.recommendation!),
                        ],
                      if (review.comments != null && review.comments!.isNotEmpty)
                        ...[
                          const Divider(height: 16),
                          const Text(
                            'Nhận xét:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            review.comments!,
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(PaperDetailFull paper, PaperDetailProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Hành động'),
            const SizedBox(height: 12),
            
            // Edit Paper button (only for submitted/under_review status)
            if (paper.canEdit)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showEditPaperDialog(paper, provider),
                  icon: const Icon(CupertinoIcons.pencil),
                  label: const Text('Chỉnh sửa bài báo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            
            if (paper.canEdit)
              const SizedBox(height: 8),
            
            // Download PDF
            if (paper.filePath != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _downloadPaper(paper.paperId),
                  icon: const Icon(CupertinoIcons.cloud_download),
                  label: const Text('Tải file PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.authorPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            
            const SizedBox(height: 8),
            
            // Withdraw button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: paper.canWithdraw
                    ? () => _showWithdrawDialog(paper, provider)
                    : null,
                icon: const Icon(CupertinoIcons.delete),
                label: Text(paper.canWithdraw ? 'Rút bài báo' : 'Không thể rút bài'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            if (!paper.canWithdraw && paper.withdrawReason.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '⚠️ ${paper.withdrawReason}',
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper widgets
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.authorPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildScoreRow(String label, double score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getScoreColor(score).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${score.toStringAsFixed(1)}/10',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(score),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }

  void _downloadPaper(int paperId) async {
    try {
      final apiService = ApiService();
      final url = apiService.getPaperDownloadUrl(paperId);
      
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể mở link tải file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditPaperDialog(PaperDetailFull paper, PaperDetailProvider provider) {
    final titleController = TextEditingController(text: paper.title);
    final abstractController = TextEditingController(text: paper.abstract);
    final keywordsController = TextEditingController(text: paper.keywords);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Chỉnh sửa bài báo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(CupertinoIcons.doc_text),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: abstractController,
                decoration: const InputDecoration(
                  labelText: 'Tóm tắt',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(CupertinoIcons.text_alignleft),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: keywordsController,
                decoration: const InputDecoration(
                  labelText: 'Từ khóa (phân cách bằng dấu phẩy)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(CupertinoIcons.tag),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Text(
                'Lưu ý: Bạn chỉ có thể chỉnh sửa thông tin cơ bản. Để cập nhật file PDF, vui lòng truy cập vào trang web chính thức.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final abstract = abstractController.text.trim();
              final keywords = keywordsController.text.trim();
              
              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập tiêu đề'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              
              try {
                await provider.updatePaper(
                  paperId: paper.paperId,
                  title: title,
                  abstract: abstract,
                  keywords: keywords,
                  conferenceId: paper.conferenceId,
                  trackId: paper.trackId,
                );
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã cập nhật bài báo thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Reload detail
                  provider.loadPaperDetailFull(widget.paperId);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(PaperDetailFull paper, PaperDetailProvider provider) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rút bài báo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn có chắc muốn rút bài này?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Lý do (không bắt buộc)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await provider.withdrawPaper(
                  paper.paperId,
                  reason: reasonController.text.trim().isEmpty
                      ? null
                      : reasonController.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã rút bài thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Reload detail
                  provider.loadPaperDetail(widget.paperId);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rút bài'),
          ),
        ],
      ),
    );
  }
}

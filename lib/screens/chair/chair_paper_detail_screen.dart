import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/chair_provider.dart';
import '../../models/chair_paper_detail.dart';

class ChairPaperDetailScreen extends StatefulWidget {
  final int paperId;

  const ChairPaperDetailScreen({
    super.key,
    required this.paperId,
  });

  @override
  State<ChairPaperDetailScreen> createState() => _ChairPaperDetailScreenState();
}

class _ChairPaperDetailScreenState extends State<ChairPaperDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChairProvider>().loadPaperDetail(widget.paperId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Chi tiết bài báo'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.ellipsis),
            onPressed: () => _showActions(context),
          ),
        ],
      ),
      body: Consumer<ChairProvider>(
        builder: (context, provider, child) {
          if (provider.isPaperDetailLoading && provider.paperDetail == null) {
            return const Center(
              child: CupertinoActivityIndicator(radius: 20),
            );
          }

          if (provider.paperDetailError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 60,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi tải dữ liệu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.paperDetailError!,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadPaperDetail(widget.paperId),
                    icon: const Icon(CupertinoIcons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final detail = provider.paperDetail;
          if (detail == null) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadPaperDetail(widget.paperId),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Paper Info
                  _buildPaperInfo(detail.paper),
                  const SizedBox(height: 16),

                  // Authors
                  _buildAuthorsSection(detail.authors),
                  const SizedBox(height: 16),

                  // Reviewer Assignments
                  _buildAssignmentsSection(context, detail.assignments),
                  const SizedBox(height: 16),

                  // Reviews
                  _buildReviewsSection(detail.reviews),
                  const SizedBox(height: 16),

                  // Decision Button
                  _buildDecisionButton(context, detail.paper.statusCode),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaperInfo(PaperInfo paper) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    paper.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(paper.statusCode),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(CupertinoIcons.doc_text, 'Mã bài báo', '#${paper.paperId}'),
            _buildInfoRow(CupertinoIcons.calendar, 'Ngày nộp', _formatDate(paper.submittedAt)),
            if (paper.abstract != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tóm tắt',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      paper.abstract!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorsSection(List<PaperAuthor> authors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.person_2, size: 18, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Tác giả',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...authors.map((author) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  author.authorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                if (author.isContact) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Liên hệ',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              author.authorEmail,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (author.authorOrganization != null)
                              Text(
                                author.authorOrganization!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsSection(
    BuildContext context,
    List<ReviewerAssignment> assignments,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.person_2_square_stack, size: 18, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Phân công phản biện',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.add_circled, size: 22),
                  onPressed: () => _showAssignReviewer(context),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (assignments.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.info_circle, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Chưa có phân công phản biện',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...assignments.map((assignment) => _buildAssignmentCard(context, assignment)),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, ReviewerAssignment assignment) {
    Color statusColor;
    IconData statusIcon;

    switch (assignment.status) {
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = CupertinoIcons.check_mark_circled;
        break;
      case 'declined':
        statusColor = Colors.red;
        statusIcon = CupertinoIcons.xmark_circle;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = CupertinoIcons.time;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.reviewerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  assignment.status == 'accepted'
                      ? 'Đã chấp nhận'
                      : assignment.status == 'declined'
                          ? 'Đã từ chối'
                          : 'Chờ xác nhận',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (assignment.totalScore != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(CupertinoIcons.star_fill, size: 12, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Điểm: ${assignment.totalScore}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.delete, size: 18),
            onPressed: () => _confirmRemoveAssignment(context, assignment),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(List<PaperReview> reviews) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.star_fill, size: 18, color: Colors.purple[700]),
                const SizedBox(width: 8),
                const Text(
                  'Đánh giá',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (reviews.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.info_circle, color: Colors.amber[800]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Chưa có đánh giá',
                        style: TextStyle(color: Colors.amber[800]),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...reviews.map((review) => _buildReviewCard(review)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(PaperReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.reviewerName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.star_fill, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      review.averageScore?.toStringAsFixed(1) ?? '0.0',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Scores
          if (review.scoreNovelty != null)
            _buildScoreRow('Tính mới', review.scoreNovelty!),
          if (review.scoreRelevance != null)
            _buildScoreRow('Liên quan', review.scoreRelevance!),
          if (review.scoreTechnicalQuality != null)
            _buildScoreRow('Chất lượng kỹ thuật', review.scoreTechnicalQuality!),
          if (review.scorePresentation != null)
            _buildScoreRow('Trình bày', review.scorePresentation!),
          if (review.scoreReferences != null)
            _buildScoreRow('Tài liệu tham khảo', review.scoreReferences!),
          const SizedBox(height: 8),
          // Recommendation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getRecommendationColor(review.recommendationCode).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Đề xuất: ${_getRecommendationText(review.recommendationCode)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _getRecommendationColor(review.recommendationCode),
              ),
            ),
          ),
          // Comments
          if (review.detailedComments != null) ...[
            const SizedBox(height: 12),
            Text(
              'Nhận xét chi tiết:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              review.detailedComments!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
          if (review.commentAuthor != null) ...[
            const SizedBox(height: 8),
            Text(
              'Gửi tác giả:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              review.commentAuthor!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
          if (review.commentChair != null) ...[
            const SizedBox(height: 8),
            Text(
              'Gửi chủ tịch:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              review.commentChair!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, int score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < score ? CupertinoIcons.star_fill : CupertinoIcons.star,
                size: 14,
                color: index < score ? Colors.amber[700] : Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionButton(BuildContext context, String currentStatus) {
    if (currentStatus == 'accepted' || currentStatus == 'rejected') {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showDecisionDialog(context),
        icon: const Icon(CupertinoIcons.checkmark_alt),
        label: const Text('Ra quyết định'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'submitted':
        color = Colors.blue;
        text = 'Đã nộp';
        break;
      case 'under_review':
        color = Colors.orange;
        text = 'Đang xét';
        break;
      case 'accepted':
        color = Colors.green;
        text = 'Duyệt';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Từ chối';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getRecommendationColor(String recommendation) {
    switch (recommendation) {
      case 'accept':
        return Colors.green;
      case 'reject':
        return Colors.red;
      case 'minor_revision':
        return Colors.blue;
      case 'major_revision':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getRecommendationText(String recommendation) {
    switch (recommendation) {
      case 'accept':
        return 'Chấp nhận';
      case 'reject':
        return 'Từ chối';
      case 'minor_revision':
        return 'Sửa nhỏ';
      case 'major_revision':
        return 'Sửa lớn';
      default:
        return recommendation;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _showActions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showAssignReviewer(context);
            },
            child: const Text('Phân công phản biện'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showDecisionDialog(context);
            },
            child: const Text('Ra quyết định'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
      ),
    );
  }

  void _showAssignReviewer(BuildContext context) {
    // TODO: Implement assign reviewer dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng đang phát triển')),
    );
  }

  void _confirmRemoveAssignment(BuildContext context, ReviewerAssignment assignment) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có chắc muốn hủy phân công cho ${assignment.reviewerName}?'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<ChairProvider>().removeAssignment(
                    assignment.assignmentId,
                    widget.paperId,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Đã hủy phân công' : 'Lỗi hủy phân công'),
                  ),
                );
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showDecisionDialog(BuildContext context) {
    // TODO: Implement decision dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng đang phát triển')),
    );
  }
}

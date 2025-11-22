import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class TrackProcessPage extends StatefulWidget {
  const TrackProcessPage({super.key});

  @override
  State<TrackProcessPage> createState() => _TrackProcessPageState();
}

class _TrackProcessPageState extends State<TrackProcessPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  List<Map<String, dynamic>> _inReviewPapers = [];
  List<Map<String, dynamic>> _completedPapers = [];
  List<Map<String, dynamic>> _delayedPapers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _inReviewPapers = [
        {
          'id': '1',
          'title': 'Machine Learning in Healthcare',
          'author': 'Nguyễn Văn A',
          'reviewer': 'PGS.TS. Hoàng Thị E',
          'assignedDate': DateTime.now().subtract(const Duration(days: 10)),
          'deadline': DateTime.now().add(const Duration(days: 4)),
          'progress': 65,
          'status': 'in_progress',
        },
        {
          'id': '2',
          'title': 'Blockchain for Supply Chain',
          'author': 'Trần Thị B',
          'reviewer': 'TS. Phạm Văn D',
          'assignedDate': DateTime.now().subtract(const Duration(days: 7)),
          'deadline': DateTime.now().add(const Duration(days: 7)),
          'progress': 40,
          'status': 'in_progress',
        },
        {
          'id': '3',
          'title': 'IoT Security Analysis',
          'author': 'Lê Văn C',
          'reviewer': 'TS. Đỗ Văn F',
          'assignedDate': DateTime.now().subtract(const Duration(days: 5)),
          'deadline': DateTime.now().add(const Duration(days: 9)),
          'progress': 20,
          'status': 'started',
        },
      ];
      
      _completedPapers = [
        {
          'id': '4',
          'title': 'AI in Education Systems',
          'author': 'Phạm Văn G',
          'reviewer': 'PGS.TS. Hoàng Thị E',
          'completedDate': DateTime.now().subtract(const Duration(days: 2)),
          'score': 8.5,
          'decision': 'approved',
        },
        {
          'id': '5',
          'title': 'Cloud Computing Security',
          'author': 'Hoàng Thị H',
          'reviewer': 'TS. Vũ Thị I',
          'completedDate': DateTime.now().subtract(const Duration(days: 5)),
          'score': 7.8,
          'decision': 'needs_revision',
        },
      ];
      
      _delayedPapers = [
        {
          'id': '6',
          'title': 'Network Security Protocols',
          'author': 'Đỗ Văn J',
          'reviewer': 'TS. Lê Thị K',
          'assignedDate': DateTime.now().subtract(const Duration(days: 20)),
          'deadline': DateTime.now().subtract(const Duration(days: 2)),
          'daysOverdue': 2,
        },
      ];
      
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        backgroundColor: AppColors.adminPrimary,
        elevation: 0,
        title: const Text(
          'Theo dõi tiến trình',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đang phản biện'),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_inReviewPapers.length}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Hoàn thành'),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_completedPapers.length}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Trễ hạn'),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_delayedPapers.length}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInReviewList(),
                _buildCompletedList(),
                _buildDelayedList(),
              ],
            ),
    );
  }

  Widget _buildInReviewList() {
    if (_inReviewPapers.isEmpty) {
      return _buildEmptyState('Không có bài đang phản biện', Icons.rate_review_outlined);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _inReviewPapers.length,
        itemBuilder: (context, index) {
          final paper = _inReviewPapers[index];
          return _buildInReviewCard(paper);
        },
      ),
    );
  }

  Widget _buildInReviewCard(Map<String, dynamic> paper) {
    final daysLeft = paper['deadline'].difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 3;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isUrgent ? Border.all(color: AppColors.warning, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    paper['title'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber, size: 12, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text(
                          'Gấp',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('Tác giả: ${paper['author']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.rate_review, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('Phản biện: ${paper['reviewer']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiến độ: ${paper['progress']}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Còn $daysLeft ngày',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isUrgent ? AppColors.warning : AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: paper['progress'] / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      paper['progress'] < 30
                          ? AppColors.error
                          : paper['progress'] < 70
                              ? AppColors.warning
                              : AppColors.success,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 20),
                      SizedBox(width: 8),
                      Text('Xem chi tiết'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remind',
                  child: Row(
                    children: [
                      Icon(Icons.notifications, size: 20),
                      SizedBox(width: 8),
                      Text('Nhắc nhở'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reassign',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, size: 20),
                      SizedBox(width: 8),
                      Text('Phân công lại'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) => _handleAction(value.toString(), paper),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedList() {
    if (_completedPapers.isEmpty) {
      return _buildEmptyState('Chưa có bài hoàn thành', Icons.check_circle_outline);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _completedPapers.length,
        itemBuilder: (context, index) {
          final paper = _completedPapers[index];
          return _buildCompletedCard(paper);
        },
      ),
    );
  }

  Widget _buildCompletedCard(Map<String, dynamic> paper) {
    final decision = paper['decision'];
    Color decisionColor;
    String decisionText;
    IconData decisionIcon;
    
    switch (decision) {
      case 'approved':
        decisionColor = AppColors.success;
        decisionText = 'Đã duyệt';
        decisionIcon = Icons.check_circle;
        break;
      case 'needs_revision':
        decisionColor = AppColors.warning;
        decisionText = 'Cần chỉnh sửa';
        decisionIcon = Icons.edit;
        break;
      case 'rejected':
        decisionColor = AppColors.error;
        decisionText = 'Từ chối';
        decisionIcon = Icons.cancel;
        break;
      default:
        decisionColor = Colors.grey;
        decisionText = 'Chưa quyết định';
        decisionIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: decisionColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(decisionIcon, color: decisionColor, size: 24),
        ),
        title: Text(
          paper['title'],
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Tác giả: ${paper['author']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text('Phản biện: ${paper['reviewer']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: decisionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    decisionText,
                    style: TextStyle(
                      fontSize: 11,
                      color: decisionColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      '${paper['score']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  _getTimeAgo(paper['completedDate']),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        onTap: () => _viewCompletedPaper(paper),
      ),
    );
  }

  Widget _buildDelayedList() {
    if (_delayedPapers.isEmpty) {
      return _buildEmptyState('Không có bài trễ hạn', Icons.check_circle, isPositive: true);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _delayedPapers.length,
        itemBuilder: (context, index) {
          final paper = _delayedPapers[index];
          return _buildDelayedCard(paper);
        },
      ),
    );
  }

  Widget _buildDelayedCard(Map<String, dynamic> paper) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.warning, color: AppColors.error, size: 24),
        ),
        title: Text(
          paper['title'],
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Tác giả: ${paper['author']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text('Phản biện: ${paper['reviewer']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Trễ ${paper['daysOverdue']} ngày',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.send, color: AppColors.adminPrimary),
              onPressed: () => _sendReminder(paper),
              tooltip: 'Gửi nhắc nhở',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, {bool isPositive = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: isPositive ? AppColors.success : Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isPositive ? AppColors.success : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(String action, Map<String, dynamic> paper) {
    switch (action) {
      case 'view':
        _viewPaperDetails(paper);
        break;
      case 'remind':
        _sendReminder(paper);
        break;
      case 'reassign':
        _reassignPaper(paper);
        break;
    }
  }

  void _viewPaperDetails(Map<String, dynamic> paper) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Chi tiết tiến trình',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              paper['title'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Tác giả', paper['author']),
            _buildDetailRow('Phản biện viên', paper['reviewer']),
            _buildDetailRow('Ngày phân công', _formatDate(paper['assignedDate'])),
            _buildDetailRow('Hạn chót', _formatDate(paper['deadline'])),
            _buildDetailRow('Tiến độ', '${paper['progress']}%'),
          ],
        ),
      ),
    );
  }

  void _viewCompletedPaper(Map<String, dynamic> paper) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Xem chi tiết bài "${paper['title']}"')),
    );
  }

  void _sendReminder(Map<String, dynamic> paper) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gửi nhắc nhở'),
        content: Text('Gửi email nhắc nhở cho ${paper['reviewer']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã gửi email nhắc nhở')),
              );
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  void _reassignPaper(Map<String, dynamic> paper) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Phân công lại bài "${paper['title']}"')),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inMinutes} phút trước';
    }
  }
} 
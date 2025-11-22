import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/paper.dart';

class AssignReviewerPage extends StatefulWidget {
  const AssignReviewerPage({super.key});

  @override
  State<AssignReviewerPage> createState() => _AssignReviewerPageState();
}

class _AssignReviewerPageState extends State<AssignReviewerPage> {
  bool _isLoading = false;
  List<Paper> _pendingPapers = [];
  Paper? _selectedPaper;
  List<Map<String, dynamic>> _availableReviewers = [];
  List<String> _selectedReviewers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _pendingPapers = [
        Paper(
          track: 'AI & Machine Learning',
          id: '1',
          title: 'Machine Learning Applications in Healthcare',
          author: 'Nguyễn Văn A',
          authorEmail: 'nguyenvana@example.com',
          authors: ['Nguyễn Văn A', 'Trần Thị B'],
          abstract: 'A comprehensive study on ML applications in healthcare systems...',
          keywords: 'machine learning, healthcare, AI',
          status: 'pending',
          submittedDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Paper(
          track: 'Blockchain',
          id: '2',
          title: 'Blockchain Technology for Supply Chain',
          author: 'Lê Văn C',
          authorEmail: 'levanc@example.com',
          authors: ['Lê Văn C'],
          abstract: 'Exploring blockchain implementation in supply chain management...',
          keywords: 'blockchain, supply chain, technology',
          status: 'pending',
          submittedDate: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Paper(
          track: 'IoT & Security',
          id: '3',
          title: 'IoT Security Challenges',
          author: 'Phạm Thị D',
          authorEmail: 'phamthid@example.com',
          authors: ['Phạm Thị D', 'Hoàng Văn E'],
          abstract: 'Analysis of security challenges in IoT systems...',
          keywords: 'IoT, security, challenges',
          status: 'pending',
          submittedDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
      
      _availableReviewers = [
        {
          'id': '1',
          'name': 'PGS.TS. Hoàng Thị E',
          'affiliation': 'ĐH Khoa học Tự nhiên',
          'expertise': ['Machine Learning', 'AI', 'Data Science'],
          'workload': 3,
          'rating': 4.8,
          'completed': 15,
          'status': 'available',
        },
        {
          'id': '2',
          'name': 'TS. Phạm Văn D',
          'affiliation': 'ĐH Bách Khoa TP.HCM',
          'expertise': ['Blockchain', 'Security', 'Cryptography'],
          'workload': 2,
          'rating': 4.5,
          'completed': 12,
          'status': 'available',
        },
        {
          'id': '3',
          'name': 'TS. Đỗ Văn F',
          'affiliation': 'ĐH Công nghệ',
          'expertise': ['IoT', 'Embedded Systems', 'Networks'],
          'workload': 5,
          'rating': 4.2,
          'completed': 10,
          'status': 'busy',
        },
        {
          'id': '4',
          'name': 'TS. Vũ Thị G',
          'affiliation': 'ĐH Công nghiệp TP.HCM',
          'expertise': ['Cloud Computing', 'Distributed Systems'],
          'workload': 1,
          'rating': 4.6,
          'completed': 8,
          'status': 'available',
        },
      ];
      
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.adminPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Phân công phản biện',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Left panel - Papers list
                Expanded(
                  flex: 2,
                  child: _buildPapersList(),
                ),
                // Right panel - Reviewers list
                Expanded(
                  flex: 3,
                  child: _buildReviewersPanel(),
                ),
              ],
            ),
    );
  }

  Widget _buildPapersList() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bài chờ phân công',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_pendingPapers.length} bài báo',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          Expanded(
            child: ListView.builder(
              itemCount: _pendingPapers.length,
              itemBuilder: (context, index) {
                final paper = _pendingPapers[index];
                final isSelected = _selectedPaper?.id == paper.id;
                
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.adminPrimary.withOpacity(0.1) : Colors.white,
                    border: Border(
                      left: BorderSide(
                        color: isSelected ? AppColors.adminPrimary : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: Text(
                      paper.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          paper.authors?.join(', ') ?? 'Unknown',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTimeAgo(paper.submittedDate),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _selectedPaper = paper;
                        _selectedReviewers.clear();
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewersPanel() {
    if (_selectedPaper == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Chọn bài báo để phân công',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Selected paper info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.adminPrimary.withOpacity(0.05),
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedPaper!.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showPaperDetails(_selectedPaper!),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedPaper!.keywords.split(',').take(3).map((keyword) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.adminPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      keyword,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.adminPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        // Reviewers list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _availableReviewers.length,
            itemBuilder: (context, index) {
              final reviewer = _availableReviewers[index];
              return _buildReviewerCard(reviewer);
            },
          ),
        ),
        // Action buttons
        if (_selectedReviewers.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Đã chọn ${_selectedReviewers.length} phản biện viên',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedReviewers.map((id) {
                          final reviewer = _availableReviewers.firstWhere((r) => r['id'] == id);
                          return reviewer['name'];
                        }).join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _assignReviewers,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    'Phân công',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.adminPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildReviewerCard(Map<String, dynamic> reviewer) {
    final isSelected = _selectedReviewers.contains(reviewer['id']);
    final isBusy = reviewer['status'] == 'busy';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.adminPrimary : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Checkbox(
            value: isSelected,
            onChanged: isBusy ? null : (value) {
              setState(() {
                if (value == true) {
                  _selectedReviewers.add(reviewer['id']);
                } else {
                  _selectedReviewers.remove(reviewer['id']);
                }
              });
            },
            activeColor: AppColors.adminPrimary,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  reviewer['name'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isBusy ? Colors.grey : AppColors.textPrimary,
                  ),
                ),
              ),
              if (isBusy)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Bận',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                reviewer['affiliation'],
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMetric(Icons.assignment, '${reviewer['workload']}', AppColors.info),
                  const SizedBox(width: 12),
                  _buildMetric(Icons.star, '${reviewer['rating']}', AppColors.warning),
                  const SizedBox(width: 12),
                  _buildMetric(Icons.check_circle, '${reviewer['completed']}', AppColors.success),
                ],
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Lĩnh vực chuyên môn',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (reviewer['expertise'] as List<String>).map((exp) {
                      final paperKeywords = _selectedPaper?.keywords.split(',').map((k) => k.trim().toLowerCase()).toList() ?? [];
                      final isMatch = paperKeywords.any(
                        (keyword) => exp.toLowerCase().contains(keyword),
                      );
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isMatch
                              ? AppColors.success.withOpacity(0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: isMatch
                              ? Border.all(color: AppColors.success, width: 1)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isMatch)
                              Icon(Icons.check_circle, size: 12, color: AppColors.success),
                            if (isMatch) const SizedBox(width: 4),
                            Text(
                              exp,
                              style: TextStyle(
                                fontSize: 11,
                                color: isMatch ? AppColors.success : Colors.grey[700],
                                fontWeight: isMatch ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showPaperDetails(Paper paper) {
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
              paper.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tác giả: ${paper.authors?.join(', ') ?? 'Unknown'}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Text(
              'Tóm tắt',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  paper.abstract,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _assignReviewers() {
    final reviewerNames = _selectedReviewers.map((id) {
      final reviewer = _availableReviewers.firstWhere((r) => r['id'] == id);
      return reviewer['name'];
    }).join(', ');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận phân công'),
        content: Text(
          'Phân công bài "${_selectedPaper!.title}" cho:\n\n$reviewerNames',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _pendingPapers.remove(_selectedPaper);
                _selectedPaper = null;
                _selectedReviewers.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã phân công thành công'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Phân công'),
          ),
        ],
      ),
    );
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
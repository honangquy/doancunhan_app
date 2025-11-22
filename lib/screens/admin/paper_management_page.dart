import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/paper.dart';
import '../../services/api_service.dart';

class PaperManagementPage extends StatefulWidget {
  const PaperManagementPage({super.key});

  @override
  State<PaperManagementPage> createState() => _PaperManagementPageState();
}

class _PaperManagementPageState extends State<PaperManagementPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedStatus = 'all';
  
  List<Paper> _allPapers = [];
  List<Paper> _filteredPapers = [];

  final List<Map<String, dynamic>> _statusFilters = [
    {'value': 'all', 'label': 'Tất cả trạng thái', 'color': Colors.grey},
    {'value': 'pending', 'label': 'Đang phân biện', 'color': Color(0xFF6EC6FF)},
    {'value': 'approved', 'label': 'Chấp nhận', 'color': Color(0xFF7BC9A6)},
    {'value': 'revision', 'label': 'Yêu cầu sửa', 'color': Color(0xFFFFB84D)},
    {'value': 'rejected', 'label': 'Từ chối', 'color': Color(0xFFFF6B6B)},
  ];

  @override
  void initState() {
    super.initState();
    _loadPapers();
  }

  Future<void> _loadPapers() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate loading papers
      await Future.delayed(const Duration(seconds: 1));
      
      _allPapers = [
        Paper(
          track: 'AI & Machine Learning',
          id: 'P001',
          title: 'Machine Learning in Healthcare',
          author: 'Nguyễn Văn E',
          authorEmail: 'nguyenvane@email.com',
          authors: ['Nguyễn Văn E', 'Trần Thị F'],
          abstract: 'A comprehensive study on ML applications...',
          keywords: 'machine learning, healthcare, AI',
          status: 'pending',
          submittedDate: DateTime(2025, 10, 1),
          reviewScore: null,
        ),
        Paper(
          track: 'Ethics & Society',
          id: 'P002',
          title: 'AI Ethics and Society',
          author: 'Trần Thị F',
          authorEmail: 'tranthif@email.com',
          authors: ['Trần Thị F'],
          abstract: 'Exploring ethical implications of AI...',
          keywords: 'AI, ethics, society',
          status: 'approved',
          submittedDate: DateTime(2025, 9, 28),
          reviewScore: 8.5,
        ),
        Paper(
          track: 'Deep Learning',
          id: 'P003',
          title: 'Deep Learning Applications',
          author: 'Lê Văn G',
          authorEmail: 'levang@email.com',
          authors: ['Lê Văn G', 'Phạm Thị H'],
          abstract: 'Applications of deep learning in various domains...',
          keywords: 'deep learning, neural networks, AI',
          status: 'revision',
          submittedDate: DateTime(2025, 10, 5),
          reviewScore: 7.2,
        ),
        Paper(
          track: 'Computer Vision',
          id: 'P004',
          title: 'Image Recognition Systems',
          author: 'Hoàng Văn I',
          authorEmail: 'hoangvani@email.com',
          authors: ['Hoàng Văn I'],
          abstract: 'Advanced image recognition techniques...',
          keywords: 'computer vision, image processing',
          status: 'pending',
          submittedDate: DateTime(2025, 10, 10),
          reviewScore: null,
        ),
        Paper(
          track: 'NLP',
          id: 'P005',
          title: 'Natural Language Processing',
          author: 'Đỗ Thị J',
          authorEmail: 'dothij@email.com',
          authors: ['Đỗ Thị J', 'Vũ Văn K'],
          abstract: 'NLP techniques for Vietnamese language...',
          keywords: 'NLP, Vietnamese, language processing',
          status: 'rejected',
          submittedDate: DateTime(2025, 9, 15),
          reviewScore: 5.5,
        ),
      ];
      
      _filteredPapers = List.from(_allPapers);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterPapers() {
    setState(() {
      _filteredPapers = _allPapers.where((paper) {
        // Filter by status
        if (_selectedStatus != 'all' && paper.status != _selectedStatus) {
          return false;
        }
        
        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          return paper.title.toLowerCase().contains(query) ||
                 paper.id.toLowerCase().contains(query) ||
                 paper.author.toLowerCase().contains(query) ||
                 (paper.authors?.any((a) => a.toLowerCase().contains(query)) ?? false);
        }
        
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.adminPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.article, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Quản Lý Bài Báo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          // Export Excel button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _exportToExcel,
              icon: const Icon(Icons.download, size: 18, color: Colors.white),
              label: const Text(
                'Xuất Excel',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                          _filterPapers();
                        },
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm bài báo, tác giả...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    setState(() => _searchQuery = '');
                                    _filterPapers();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status filter dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        onChanged: (value) {
                          setState(() => _selectedStatus = value!);
                          _filterPapers();
                        },
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down),
                        items: _statusFilters.map((filter) {
                          return DropdownMenuItem<String>(
                            value: filter['value'],
                            child: Text(
                              filter['label'],
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Papers list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPapers.isEmpty
                    ? _buildEmptyState()
                    : _buildPapersTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Chưa có bài báo' : 'Không tìm thấy bài báo',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPapersTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
          columns: const [
            DataColumn(label: Text('Mã bài', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Tiêu đề', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Tác giả', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Ngày nộp', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Phiên bản', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _filteredPapers.map((paper) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    paper.id,
                    style: const TextStyle(
                      color: Color(0xFF6EC6FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 250,
                    child: Text(
                      paper.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text(paper.author)),
                DataCell(Text(_formatDate(paper.submittedDate))),
                DataCell(Text('v${paper.reviewsCompleted + 1}')),
                DataCell(_buildStatusBadge(paper.status)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Color(0xFF6EC6FF), size: 20),
                        onPressed: () => _viewPaper(paper),
                        tooltip: 'Xem chi tiết',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF7BC9A6), size: 20),
                        onPressed: () => _editPaper(paper),
                        tooltip: 'Chỉnh sửa',
                      ),
                      IconButton(
                        icon: const Icon(Icons.download, color: Color(0xFFFFB84D), size: 20),
                        onPressed: () => _downloadPaper(paper),
                        tooltip: 'Tải xuống',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    String label;
    
    switch (status) {
      case 'pending':
        backgroundColor = const Color(0xFF6EC6FF);
        label = 'Đang phân biện';
        break;
      case 'approved':
        backgroundColor = const Color(0xFF7BC9A6);
        label = 'Chấp nhận';
        break;
      case 'revision':
        backgroundColor = const Color(0xFFFFB84D);
        label = 'Yêu cầu sửa';
        break;
      case 'rejected':
        backgroundColor = const Color(0xFFFF6B6B);
        label = 'Từ chối';
        break;
      default:
        backgroundColor = Colors.grey;
        label = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: backgroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _viewPaper(Paper paper) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.article, color: Color(0xFF6EC6FF)),
            const SizedBox(width: 8),
            Expanded(child: Text(paper.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Mã bài:', paper.id),
              _buildInfoRow('Tác giả:', paper.authors?.join(', ') ?? paper.author),
              _buildInfoRow('Email:', paper.authorEmail),
              _buildInfoRow('Track:', paper.track),
              _buildInfoRow('Ngày nộp:', _formatDate(paper.submittedDate)),
              _buildInfoRow('Trạng thái:', paper.status),
              if (paper.reviewScore != null)
                _buildInfoRow('Điểm:', paper.reviewScore!.toStringAsFixed(1)),
              const SizedBox(height: 12),
              const Text('Tóm tắt:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(paper.abstract),
              const SizedBox(height: 12),
              const Text('Từ khóa:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: paper.keywords.split(',').map((keyword) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      keyword.trim(),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _editPaper(Paper paper) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chỉnh sửa bài báo: ${paper.id}')),
    );
  }

  void _downloadPaper(Paper paper) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tải xuống bài báo: ${paper.id}')),
    );
  }

  void _exportToExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang xuất file Excel...'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

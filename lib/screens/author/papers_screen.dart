import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/author_dashboard_provider.dart';
import '../../models/author_paper.dart';
import '../../utils/constants.dart';
import 'paper_detail_screen.dart';

class PapersScreen extends StatefulWidget {
  const PapersScreen({Key? key}) : super(key: key);

  @override
  State<PapersScreen> createState() => _PapersScreenState();
}

class _PapersScreenState extends State<PapersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  final List<Map<String, dynamic>> _tabs = [
    {'status': null, 'label': 'Tất cả', 'icon': Icons.list_alt},
    {'status': 'SUBMITTED', 'label': 'Đã nộp', 'icon': Icons.send},
    {'status': 'UNDER_REVIEW', 'label': 'Đang xét', 'icon': Icons.rate_review},
    {'status': 'ACCEPTED', 'label': 'Đã duyệt', 'icon': Icons.check_circle},
    {'status': 'REJECTED', 'label': 'Từ chối', 'icon': Icons.cancel},
    {'status': 'WITHDRAWN', 'label': 'Đã rút', 'icon': Icons.undo},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Load papers immediately without waiting for frame callback
    Future.microtask(() {
      print('📱 [PapersScreen] initState - Loading papers...');
      _loadPapers();
    });
  }
  
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _loadPapers();
    }
  }
  
  void _loadPapers() {
    final status = _tabs[_tabController.index]['status'];
    print('📱 [PapersScreen] Loading papers with status: $status');
    context.read<AuthorDashboardProvider>().loadDashboard(
      page: 1,
      status: status,
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String statusCode) {
    switch (statusCode.toUpperCase()) {
      case 'SUBMITTED':
        return AppColors.authorPrimary;
      case 'UNDER_REVIEW':
        return AppColors.warning;
      case 'ACCEPTED':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.error;
      case 'WITHDRAWN':
        return Colors.grey;
      case 'DRAFT':
        return Colors.blueGrey;
      default:
        return AppColors.textMedium;
    }
  }

  IconData _getStatusIcon(String statusCode) {
    switch (statusCode.toUpperCase()) {
      case 'SUBMITTED':
        return Icons.send;
      case 'UNDER_REVIEW':
        return Icons.rate_review;
      case 'ACCEPTED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      case 'WITHDRAWN':
        return Icons.undo;
      case 'DRAFT':
        return Icons.drafts;
      default:
        return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.authorPrimary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Bài báo của tôi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.authorPrimary,
                      AppColors.authorPrimary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Icon(
                        Icons.article,
                        size: 200,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm bài báo...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    // Tabs
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: AppColors.authorPrimary,
                      unselectedLabelColor: AppColors.textMedium,
                      indicatorColor: AppColors.authorPrimary,
                      indicatorWeight: 3,
                      tabs: _tabs.map((tab) {
                        return Tab(
                          child: Row(
                            children: [
                              Icon(tab['icon'], size: 18),
                              const SizedBox(width: 8),
                              Text(tab['label']),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Consumer<AuthorDashboardProvider>(
          builder: (context, provider, child) {
            print('📱 [PapersScreen] Building... isLoading: ${provider.isLoading}, papers: ${provider.authorPapers.length}');
            
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi: ${provider.error}',
                      style: TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadPapers,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.authorPrimary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            var papers = provider.authorPapers;
            print('📱 [PapersScreen] Author papers count: ${papers.length}');
            
            // Filter by search query
            if (_searchQuery.isNotEmpty) {
              papers = papers.where((paper) {
                return paper.title.toLowerCase().contains(_searchQuery) ||
                    paper.conferenceTitle.toLowerCase().contains(_searchQuery) ||
                    paper.paperId.toString().contains(_searchQuery);
              }).toList();
            }

            if (papers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 100,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Không tìm thấy bài báo phù hợp'
                          : 'Chưa có bài báo nào',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Thử tìm kiếm với từ khóa khác'
                          : 'Bài báo của bạn sẽ hiển thị ở đây',
                      style: TextStyle(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 500));
                _loadPapers();
              },
              child: Column(
                children: [
                  // Papers count & stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Icon(
                          Icons.article,
                          color: AppColors.authorPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${papers.length} bài báo',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (provider.totalPages > 1)
                          Text(
                            'Trang ${provider.currentPage}/${provider.totalPages}',
                            style: TextStyle(
                              color: AppColors.textMedium,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  
                  // Papers list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: papers.length,
                      itemBuilder: (context, index) {
                        return _buildPaperCard(papers[index], provider);
                      },
                    ),
                  ),
                  
                  // Pagination
                  if (provider.totalPages > 1)
                    _buildPaginationControls(provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaperCard(AuthorPaper paper, AuthorDashboardProvider provider) {
    final statusColor = _getStatusColor(paper.statusCode);
    final statusIcon = _getStatusIcon(paper.statusCode);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaperDetailScreen(paperId: paper.paperId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ID & Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${paper.paperId}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              paper.statusName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.textMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Title
              Text(
                paper.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Conference
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 16,
                    color: AppColors.textMedium,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      paper.conferenceTitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMedium,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              
              // Date & Deadline
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textMedium,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Nộp: ${paper.formattedCreatedAt}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.flag,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Hạn: ${paper.formattedDeadline}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Actions
              Row(
                children: [
                  // View button (always available)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaperDetailScreen(
                              paperId: paper.paperId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Xem'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.authorPrimary,
                        side: BorderSide(color: AppColors.authorPrimary),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  
                  // Withdraw button (if can withdraw)
                  if (paper.canWithdraw) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showWithdrawDialog(paper, provider),
                        icon: const Icon(Icons.undo, size: 16),
                        label: const Text('Rút'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              // Permission reasons (if any)
              if (!paper.canWithdraw && paper.withdrawReason.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Không thể rút: ${paper.withdrawReason}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(AuthorDashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          ElevatedButton.icon(
            onPressed: provider.hasPrevPage && !provider.isLoading
                ? () => provider.loadPrevPage()
                : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Trước'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.authorPrimary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
            ),
          ),
          
          // Page indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.authorPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Trang ${provider.currentPage}/${provider.totalPages}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.authorPrimary,
              ),
            ),
          ),
          
          // Next button
          ElevatedButton.icon(
            onPressed: provider.hasNextPage && !provider.isLoading
                ? () => provider.loadNextPage()
                : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Sau'),
            iconAlignment: IconAlignment.end,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.authorPrimary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(AuthorPaper paper, AuthorDashboardProvider provider) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Rút bài báo'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc muốn rút bài báo "${paper.title}"?',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Lý do rút (tùy chọn)',
                border: OutlineInputBorder(),
                hintText: 'Nhập lý do rút bài...',
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
              
              final success = await provider.withdrawPaper(
                paper.paperId,
                reason: reasonController.text.trim().isEmpty
                    ? null
                    : reasonController.text.trim(),
              );
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Đã rút bài báo thành công'
                          : 'Không thể rút bài báo',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rút bài'),
          ),
        ],
      ),
    );
  }
}

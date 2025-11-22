import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/chair_provider.dart';
import '../../models/chair_paper.dart';
import 'chair_paper_detail_screen.dart';

class ChairPapersScreen extends StatefulWidget {
  const ChairPapersScreen({super.key});

  @override
  State<ChairPapersScreen> createState() => _ChairPapersScreenState();
}

class _ChairPapersScreenState extends State<ChairPapersScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedConferenceId;
  String? _selectedStatus;
  int _currentPage = 1;

  final List<Map<String, dynamic>> _statusFilters = [
    {'value': null, 'label': 'Tất cả'},
    {'value': 'submitted', 'label': 'Đã nộp'},
    {'value': 'under_review', 'label': 'Đang xét'},
    {'value': 'accepted', 'label': 'Đã duyệt'},
    {'value': 'rejected', 'label': 'Từ chối'},
    {'value': 'withdrawn', 'label': 'Đã rút'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPapers();
    });
  }

  void _loadPapers() {
    context.read<ChairProvider>().loadPapers(
          conferenceId: _selectedConferenceId,
          status: _selectedStatus,
          search: _searchController.text.isNotEmpty ? _searchController.text : null,
          page: _currentPage,
        );
  }

  void _onSearch(String value) {
    _currentPage = 1;
    _loadPapers();
  }

  void _onStatusChanged(String? status) {
    setState(() {
      _selectedStatus = status;
      _currentPage = 1;
    });
    _loadPapers();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadPapers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<ChairProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            slivers: [
              // App Bar with Search
              SliverAppBar(
                floating: true,
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                title: const Text(
                  'Quản lý bài báo',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(110),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearch,
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm bài báo...',
                              prefixIcon: const Icon(CupertinoIcons.search, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 20),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearch('');
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Theme.of(context).primaryColor),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                        // Status Filters
                        SizedBox(
                          height: 46,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _statusFilters.length,
                            itemBuilder: (context, index) {
                              final filter = _statusFilters[index];
                              final isSelected = _selectedStatus == filter['value'];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(filter['label']),
                                  selected: isSelected,
                                  onSelected: (_) => _onStatusChanged(filter['value']),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  ),
                                  backgroundColor: Colors.white,
                                  selectedColor: Theme.of(context).primaryColor,
                                  side: BorderSide(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey[300]!,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),

              // Loading State
              if (provider.isPapersLoading && provider.papers == null)
                const SliverFillRemaining(
                  child: Center(
                    child: CupertinoActivityIndicator(radius: 20),
                  ),
                ),

              // Error State
              if (provider.papersError != null && provider.papers == null)
                SliverFillRemaining(
                  child: Center(
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
                          provider.papersError!,
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadPapers,
                          icon: const Icon(CupertinoIcons.refresh),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                ),

              // Papers List
              if (provider.papers != null) ...[
                if (provider.papers!.papers.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.doc_text,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có bài báo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final paper = provider.papers!.papers[index];
                          return _buildPaperCard(context, paper);
                        },
                        childCount: provider.papers!.papers.length,
                      ),
                    ),
                  ),

                // Pagination
                if (provider.papers!.papers.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: provider.papers!.hasPrevPage
                                ? () => _onPageChanged(_currentPage - 1)
                                : null,
                            icon: const Icon(CupertinoIcons.chevron_left),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Trang $_currentPage',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: provider.papers!.hasNextPage
                                ? () => _onPageChanged(_currentPage + 1)
                                : null,
                            icon: const Icon(CupertinoIcons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaperCard(BuildContext context, ChairPaper paper) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChairPaperDetailScreen(paperId: paper.paperId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paper.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.person,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Hội nghị: ${paper.conferenceName}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusBadge(paper.statusCode),
                ],
              ),

              const SizedBox(height: 12),

              // Reviewer Stats
              if (paper.reviewers.assigned > 0) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.person_2,
                            size: 16,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Phân công phản biện',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildReviewerStatItem(
                            'Phân công',
                            paper.reviewers.assigned.toString(),
                            Colors.blue,
                          ),
                          _buildReviewerStatItem(
                            'Chấp nhận',
                            paper.reviewers.accepted.toString(),
                            Colors.green,
                          ),
                          _buildReviewerStatItem(
                            'Từ chối',
                            paper.reviewers.declined.toString(),
                            Colors.red,
                          ),
                          _buildReviewerStatItem(
                            'Hoàn thành',
                            paper.reviewers.completed.toString(),
                            Colors.teal,
                          ),
                        ],
                      ),
                      if (paper.reviewers.avgScore != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.star_fill,
                              size: 14,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Điểm trung bình: ${paper.reviewers.avgScore!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Metadata
              Row(
                children: [
                  Icon(CupertinoIcons.calendar, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Nộp: ${_formatDate(paper.submittedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewerStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
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
      case 'withdrawn':
        color = Colors.grey;
        text = 'Đã rút';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

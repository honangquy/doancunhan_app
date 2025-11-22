import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/author_dashboard_provider.dart';
import '../../models/author_paper.dart';
import '../../utils/constants.dart';
import 'paper_detail_screen.dart';

class PaperListScreen extends StatefulWidget {
  const PaperListScreen({Key? key}) : super(key: key);

  @override
  State<PaperListScreen> createState() => _PaperListScreenState();
}

class _PaperListScreenState extends State<PaperListScreen> {
  String? _selectedStatus;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthorDashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài báo của tôi'),
        backgroundColor: AppColors.authorPrimary,
        foregroundColor: Colors.white,
        actions: [
          // Filter by status
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedStatus = value == 'ALL' ? null : value;
              });
              context.read<AuthorDashboardProvider>().loadDashboard(
                status: _selectedStatus,
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'ALL', child: Text('Tất cả')),
              const PopupMenuItem(value: 'SUBMITTED', child: Text('Đã nộp')),
              const PopupMenuItem(value: 'UNDER_REVIEW', child: Text('Đang xét')),
              const PopupMenuItem(value: 'ACCEPTED', child: Text('Đã duyệt')),
              const PopupMenuItem(value: 'REJECTED', child: Text('Từ chối')),
              const PopupMenuItem(value: 'WITHDRAWN', child: Text('Đã rút')),
            ],
          ),
        ],
      ),
      body: Consumer<AuthorDashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final paginatedPapers = provider.paginatedPapers;
          if (paginatedPapers == null || paginatedPapers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có bài báo nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Papers count & pagination info
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng số: ${paginatedPapers.total} bài báo',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Trang ${paginatedPapers.currentPage}/${paginatedPapers.lastPage}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              
              // Papers list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: paginatedPapers.data.length,
                    itemBuilder: (context, index) {
                      final paper = paginatedPapers.data[index];
                      return _buildPaperCard(paper, provider);
                    },
                  ),
                ),
              ),
              
              // Pagination controls
              if (paginatedPapers.lastPage > 1)
                _buildPaginationControls(provider, paginatedPapers),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaperCard(AuthorPaper paper, AuthorDashboardProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              // Paper ID & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${paper.paperId}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: paper.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: paper.statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      paper.statusName,
                      style: TextStyle(
                        color: paper.statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
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
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Conference & Date
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      paper.conferenceTitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Ngày nộp: ${paper.formattedCreatedAt}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
              
              // Actions
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // View button (always available)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaperDetailScreen(paperId: paper.paperId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Xem'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.authorPrimary,
                    ),
                  ),
                  
                  // Edit button (conditional)
                  if (paper.canEdit)
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Navigate to edit screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chức năng đang phát triển')),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Sửa'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                    ),
                  
                  // Withdraw button (conditional)
                  if (paper.canWithdraw)
                    TextButton.icon(
                      onPressed: () => _showWithdrawDialog(paper, provider),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Rút bài'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                ],
              ),
              
              // Show reasons if cannot edit/withdraw
              if (!paper.canEdit && paper.editReason.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Không thể sửa: ${paper.editReason}',
                          style: const TextStyle(fontSize: 11, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              if (!paper.canWithdraw && paper.withdrawReason.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Không thể rút: ${paper.withdrawReason}',
                          style: const TextStyle(fontSize: 11, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(
    AuthorDashboardProvider provider,
    PaginatedPapers paginatedPapers,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: paginatedPapers.hasPrevPage
                ? () => provider.loadDashboard(
                      page: paginatedPapers.currentPage - 1,
                      status: _selectedStatus,
                    )
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 16),
          Text(
            '${paginatedPapers.currentPage} / ${paginatedPapers.lastPage}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: paginatedPapers.hasNextPage
                ? () => provider.loadDashboard(
                      page: paginatedPapers.currentPage + 1,
                      status: _selectedStatus,
                    )
                : null,
            icon: const Icon(Icons.chevron_right),
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
        title: const Text('Rút bài báo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc muốn rút bài "${paper.title}"?'),
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

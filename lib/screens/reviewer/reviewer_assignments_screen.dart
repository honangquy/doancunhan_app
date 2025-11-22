import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/reviewer_provider.dart';
import '../../utils/constants.dart';
import 'reviewer_assignment_detail_screen.dart';

class ReviewerAssignmentsScreen extends StatefulWidget {
  const ReviewerAssignmentsScreen({super.key});

  @override
  State<ReviewerAssignmentsScreen> createState() => _ReviewerAssignmentsScreenState();
}

class _ReviewerAssignmentsScreenState extends State<ReviewerAssignmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String?> _filters = [null, 'PENDING', 'ACCEPTED', 'COMPLETED', 'DECLINED'];
  final List<String> _tabLabels = ['Tất cả', 'Chờ xử lý', 'Đã nhận', 'Hoàn thành', 'Từ chối'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewerProvider>().loadAssignments();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final filter = _filters[_tabController.index];
      context.read<ReviewerProvider>().loadAssignments(status: filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.reviewerPrimary,
        foregroundColor: Colors.white,
        title: const Text('Phân công phản biện', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
        ),
      ),
      body: Consumer<ReviewerProvider>(
        builder: (context, provider, child) {
          if (provider.isAssignmentsLoading && provider.assignments.isEmpty) {
            return const Center(child: CupertinoActivityIndicator(radius: 20));
          }

          if (provider.assignmentsError != null) {
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
                    child: Text(provider.assignmentsError!, style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadAssignments(status: _filters[_tabController.index]),
                    icon: const Icon(CupertinoIcons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (provider.assignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.doc_text, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Chưa có phân công nào', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAssignments(status: _filters[_tabController.index]),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.assignments.length,
              itemBuilder: (context, index) {
                final assignment = provider.assignments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ReviewerAssignmentDetailScreen(assignmentId: assignment.id)),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildStatusBadge(assignment.status),
                              const Spacer(),
                              if (assignment.deadline != null) ...[
                                Icon(CupertinoIcons.time, size: 14, color: assignment.isOverdue ? Colors.red : Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '${assignment.deadline!.day}/${assignment.deadline!.month}/${assignment.deadline!.year}',
                                  style: TextStyle(fontSize: 12, color: assignment.isOverdue ? Colors.red : Colors.grey[600]),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(assignment.paperTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(CupertinoIcons.building_2_fill, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(child: Text(assignment.conferenceName, style: TextStyle(fontSize: 13, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

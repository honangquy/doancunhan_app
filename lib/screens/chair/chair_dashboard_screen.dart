import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/chair_provider.dart';
import '../../models/chair_dashboard.dart';
import 'chair_papers_screen.dart';
import 'chair_paper_detail_screen.dart';

class ChairDashboardScreen extends StatefulWidget {
  const ChairDashboardScreen({super.key});

  @override
  State<ChairDashboardScreen> createState() => _ChairDashboardScreenState();
}

class _ChairDashboardScreenState extends State<ChairDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChairProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<ChairProvider>(
        builder: (context, provider, child) {
          if (provider.isDashboardLoading && provider.dashboard == null) {
            return const Center(
              child: CupertinoActivityIndicator(radius: 20),
            );
          }

          if (provider.dashboardError != null) {
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
                    provider.dashboardError!,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadDashboard(),
                    icon: const Icon(CupertinoIcons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final dashboard = provider.dashboard;
          if (dashboard == null) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadDashboard(),
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar.large(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  title: const Text(
                    'Quản lý Hội nghị',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(CupertinoIcons.bell),
                      onPressed: () {
                        // TODO: Show notifications
                      },
                    ),
                  ],
                ),

                // Statistics Grid
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                    ),
                    delegate: SliverChildListDelegate([
                      _buildStatCard(
                        'Tổng hội nghị',
                        dashboard.statistics.totalConferences.toString(),
                        CupertinoIcons.calendar,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Tổng bài báo',
                        dashboard.statistics.totalSubmissions.toString(),
                        CupertinoIcons.doc_text,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Đang xét duyệt',
                        dashboard.statistics.papersUnderReview.toString(),
                        CupertinoIcons.time,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Đã xét duyệt',
                        dashboard.statistics.papersReviewed.toString(),
                        CupertinoIcons.checkmark_seal,
                        Colors.teal,
                      ),
                      _buildStatCard(
                        'Quyết định chờ',
                        dashboard.statistics.pendingDecisions.toString(),
                        CupertinoIcons.hourglass,
                        Colors.amber,
                      ),
                      _buildStatCard(
                        'Cần phản biện',
                        dashboard.statistics.needsReviewers.toString(),
                        CupertinoIcons.person_2,
                        Colors.purple,
                      ),
                      _buildStatCard(
                        'Quyết định đã ra',
                        dashboard.statistics.decisionsMade.toString(),
                        CupertinoIcons.checkmark_alt,
                        Colors.indigo,
                      ),
                    ]),
                  ),
                ),

                // Pending Actions
                if (dashboard.pendingActions.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Hành động cần xử lý',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final action = dashboard.pendingActions[index];
                          return _buildPendingActionCard(context, action);
                        },
                        childCount: dashboard.pendingActions.length,
                      ),
                    ),
                  ),
                ],

                // Recent Papers
                if (dashboard.recentPapers.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bài báo gần đây',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ChairPapersScreen(),
                                ),
                              );
                            },
                            child: const Text('Xem tất cả'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final paper = dashboard.recentPapers[index];
                          return _buildRecentPaperCard(context, paper);
                        },
                        childCount: dashboard.recentPapers.length,
                      ),
                    ),
                  ),
                ],

                const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingActionCard(BuildContext context, PendingAction action) {
    Color priorityColor;
    switch (action.priority) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        onTap: () {
          if (action.paperId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChairPaperDetailScreen(paperId: action.paperId!),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPaperCard(BuildContext context, RecentPaper paper) {
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      paper.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(paper.statusCode),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(CupertinoIcons.person, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Phân công: ${paper.reviewersAssigned} phản biện',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(CupertinoIcons.checkmark_circle, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Hoàn thành: ${paper.reviewsCompleted}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
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
}

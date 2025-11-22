import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../models/paper.dart';
import '../../models/author_paper.dart';
import '../../services/auth_service.dart';
import '../../providers/author_dashboard_provider.dart';
import '../../widgets/animated_stat_card.dart';
import 'papers_screen.dart';
import 'paper_detail_screen.dart';

class AuthorHomePage extends StatefulWidget {
  const AuthorHomePage({Key? key}) : super(key: key);

  @override
  State<AuthorHomePage> createState() => _AuthorHomePageState();
}

class _AuthorHomePageState extends State<AuthorHomePage> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Load data using Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthorDashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthorDashboardProvider>(
      builder: (context, provider, child) {
        // Show loading
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${provider.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.refresh(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        // Show data
        final stats = provider.statistics;
        final recentPapers = provider.authorPapers.take(5).toList(); // Get first 5 papers from paginatedPapers

        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          color: AppColors.authorPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // Welcome Card
          _buildWelcomeCard(),
          const SizedBox(height: AppSizes.paddingL),
          
          // Stats Grid
          _buildStatsGrid(),
          const SizedBox(height: AppSizes.paddingXL),
          
          // Recent Papers Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bài báo gần đây',
                style: AppStyles.heading3,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PapersScreen(),
                    ),
                  );
                },
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          
          // Recent Papers List
          if (recentPapers.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingXL),
                child: Column(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 64,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    Text(
                      'Chưa có bài báo nào',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...recentPapers.map((paper) => _buildRecentPaperCard(paper)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.authorGradient,
        ),
        borderRadius: AppStyles.extraLargeRadius,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, ${_authService.currentUser?.name ?? "Tác giả"}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chào mừng bạn quay trở lại',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.person,
              size: 32,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final provider = context.read<AuthorDashboardProvider>();
    final stats = provider.statistics;
    final byStatus = stats?.byStatus ?? {};
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedStatCard(
                icon: Icons.article,
                title: 'Tổng bài',
                value: stats?.totalPapers ?? 0,
                color: AppColors.authorPrimary,
                delay: Duration.zero,
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: AnimatedStatCard(
                icon: Icons.pending_actions,
                title: 'Đang xét',
                value: byStatus['UNDER_REVIEW'] ?? byStatus['under_review'] ?? 0,
                color: AppColors.warning,
                delay: const Duration(milliseconds: 50),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: AnimatedStatCard(
                icon: Icons.check_circle,
                title: 'Đã duyệt',
                value: byStatus['ACCEPTED'] ?? byStatus['accepted'] ?? 0,
                color: AppColors.success,
                delay: const Duration(milliseconds: 100),
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: AnimatedStatCard(
                icon: Icons.cancel,
                title: 'Từ chối',
                value: byStatus['REJECTED'] ?? byStatus['rejected'] ?? 0,
                color: AppColors.error,
                delay: const Duration(milliseconds: 150),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.mediumRadius,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: AppSizes.iconL, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaperCard(Paper paper) {
    Color statusColor;
    if (paper.status == 'approved') {
      statusColor = AppColors.success;
    } else if (paper.status == 'rejected') {
      statusColor = AppColors.error;
    } else {
      statusColor = AppColors.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.mediumRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: AppStyles.mediumRadius,
            ),
            child: Icon(
              Icons.description,
              color: statusColor,
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paper.title,
                  style: AppStyles.subtitle2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        paper.statusVietnamese,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(paper.submittedDate),
                      style: AppStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textMedium,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // New method for RecentPaper from PaperStatistics
  Widget _buildRecentPaperCard(dynamic paper) {
    // Support both RecentPaper and AuthorPaper
    final int paperId = paper is AuthorPaper ? paper.paperId : paper.paperId;
    final String title = paper is AuthorPaper ? paper.title : paper.title;
    final String status = paper is AuthorPaper ? paper.statusCode : paper.status;
    final String createdAtStr = paper is AuthorPaper 
        ? paper.formattedCreatedAt 
        : _formatDate(paper.createdAt);
    
    Color statusColor = AppColors.authorPrimary;
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
        statusColor = AppColors.authorPrimary;
        break;
      case 'UNDER_REVIEW':
        statusColor = AppColors.warning;
        break;
      case 'ACCEPTED':
        statusColor = AppColors.success;
        break;
      case 'REJECTED':
        statusColor = AppColors.error;
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaperDetailScreen(paperId: paperId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppStyles.mediumRadius,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.description,
                color: statusColor,
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.subtitle2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      child: Text(
                        _getStatusVietnamese(status),
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      createdAtStr,
                      style: AppStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textMedium,
          ),
        ],
      ),
    ),
    );
  }

  String _getStatusVietnamese(String status) {
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
        return 'Đã nộp';
      case 'UNDER_REVIEW':
        return 'Đang xét';
      case 'ACCEPTED':
        return 'Đã duyệt';
      case 'REJECTED':
        return 'Từ chối';
      case 'REVISION_REQUIRED':
        return 'Cần sửa';
      default:
        return status;
    }
  }
}
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/animated_stat_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _recentActivities = [];
  List<Map<String, dynamic>> _urgentTasks = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load real statistics from API
      final stats = await _apiService.getAdminStatistics();
      
      setState(() {
        _stats = stats['data'] ?? stats;
        _recentActivities = [
        {
          'type': 'paper_submitted',
          'author': 'Nguyễn Văn A',
          'title': 'Machine Learning in Healthcare',
          'time': DateTime.now().subtract(const Duration(minutes: 15)),
          'icon': Icons.file_upload,
          'color': AppColors.info,
        },
        {
          'type': 'review_completed',
          'reviewer': 'TS. Trần Thị B',
          'paper': 'Blockchain Technology',
          'score': 8.5,
          'time': DateTime.now().subtract(const Duration(hours: 2)),
          'icon': Icons.rate_review,
          'color': AppColors.success,
        },
        {
          'type': 'paper_approved',
          'title': 'AI in Education',
          'time': DateTime.now().subtract(const Duration(hours: 4)),
          'icon': Icons.check_circle,
          'color': AppColors.success,
        },
        {
          'type': 'reviewer_assigned',
          'reviewer': 'PGS. Lê Văn C',
          'paper': 'Cloud Computing Security',
          'time': DateTime.now().subtract(const Duration(hours: 6)),
          'icon': Icons.person_add,
          'color': AppColors.adminPrimary,
        },
        {
          'type': 'paper_rejected',
          'title': 'IoT Applications',
          'reason': 'Out of scope',
          'time': DateTime.now().subtract(const Duration(days: 1)),
          'icon': Icons.cancel,
          'color': AppColors.error,
        },
      ];
      
        _urgentTasks = [
          {
            'title': 'Assign reviewers for 5 pending papers',
            'priority': 'high',
            'deadline': DateTime.now().add(const Duration(days: 2)),
            'count': 5,
          },
          {
            'title': 'Review deadline approaching',
            'priority': 'high',
            'deadline': DateTime.now().add(const Duration(days: 3)),
            'count': 8,
          },
          {
            'title': 'Authors awaiting feedback',
            'priority': 'medium',
            'deadline': DateTime.now().add(const Duration(days: 5)),
            'count': 12,
          },
        ];
        
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to mock data if API fails
      setState(() {
        _stats = {
          'total_papers': 156,
          'pending_review': 23,
          'in_review': 45,
          'approved': 78,
          'rejected': 10,
          'total_authors': 124,
          'total_reviewers': 28,
          'active_reviewers': 22,
        };
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      body: _isLoading
          ? const LoadingIndicator()
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.adminPrimary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 20),
                    _buildOverviewStats(),
                    const SizedBox(height: 20),
                    _buildUrgentTasks(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildRecentActivities(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeCard() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? 'Chào buổi sáng'
        : hour < 18
            ? 'Chào buổi chiều'
            : 'Chào buổi tối';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.adminPrimary,
            AppColors.adminPrimary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.adminPrimary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      _authService.currentUser?.name ?? 'Chair HUIT',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Tổng quan hệ thống quản lý hội nghị khoa học',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tổng quan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        // Papers stats
        Row(
          children: [
            Expanded(
              child: AnimatedStatCard(
                title: 'Tổng bài báo',
                value: _stats['total_papers'] ?? 0,
                icon: Icons.description,
                color: AppColors.adminPrimary,
                delay: Duration.zero,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedStatCard(
                title: 'Chờ phân công',
                value: _stats['pending_review'] ?? 0,
                icon: Icons.pending_actions,
                color: AppColors.warning,
                delay: const Duration(milliseconds: 50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnimatedStatCard(
                title: 'Đang phản biện',
                value: _stats['in_review'] ?? 0,
                icon: Icons.rate_review,
                color: AppColors.info,
                delay: const Duration(milliseconds: 100),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedStatCard(
                title: 'Đã duyệt',
                value: _stats['approved'] ?? 0,
                icon: Icons.check_circle,
                color: AppColors.success,
                delay: const Duration(milliseconds: 150),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Users stats
        Row(
          children: [
            Expanded(
              child: AnimatedStatCard(
                title: 'Tác giả',
                value: _stats['total_authors'] ?? 0,
                icon: Icons.people,
                color: Colors.teal,
                delay: Duration.zero,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedStatCard(
                title: 'Phản biện viên',
                value: _stats['active_reviewers'] ?? 0,
                icon: Icons.people_outline,
                color: Colors.blue,
                delay: const Duration(milliseconds: 50),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUrgentTasks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Công việc cần xử lý',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_urgentTasks.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._urgentTasks.map((task) => _buildUrgentTaskCard(task)),
      ],
    );
  }

  Widget _buildUrgentTaskCard(Map<String, dynamic> task) {
    final daysLeft = task['deadline'].difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 2;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent ? AppColors.error.withOpacity(0.3) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isUrgent ? Icons.priority_high : Icons.access_time,
              color: isUrgent ? AppColors.error : AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Còn $daysLeft ngày',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.adminPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${task['count']} mục',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.adminPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.article,
        'label': 'Quản lý bài báo',
        'color': AppColors.adminPrimary,
        'route': '/chair/paper-management',
      },
      {
        'icon': Icons.post_add,
        'label': 'Đăng thông báo',
        'color': AppColors.adminPrimary,
        'route': '/chair/post-announcement',
      },
      {
        'icon': Icons.person_add_alt,
        'label': 'Phân công phản biện',
        'color': AppColors.info,
        'route': '/chair/assign-reviewer',
      },
      {
        'icon': Icons.track_changes,
        'label': 'Theo dõi tiến trình',
        'color': AppColors.warning,
        'route': '/chair/track-process',
      },
      {
        'icon': Icons.assessment,
        'label': 'Xem báo cáo',
        'color': AppColors.success,
        'route': '/chair/reports',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thao tác nhanh',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: () {
                // Navigate to action route
                Navigator.pushNamed(context, action['route'] as String);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (action['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: action['color'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hoạt động gần đây',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // View all activities
              },
              child: Text(
                'Xem tất cả',
                style: TextStyle(
                  color: AppColors.adminPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentActivities.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final activity = _recentActivities[index];
              return _buildActivityItem(activity);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final timeAgo = _getTimeAgo(activity['time'] as DateTime);
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (activity['color'] as Color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          activity['icon'] as IconData,
          color: activity['color'] as Color,
          size: 24,
        ),
      ),
      title: Text(
        _getActivityTitle(activity),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        _getActivitySubtitle(activity),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Text(
        timeAgo,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  String _getActivityTitle(Map<String, dynamic> activity) {
    switch (activity['type']) {
      case 'paper_submitted':
        return 'Bài báo mới được nộp';
      case 'review_completed':
        return 'Đánh giá hoàn thành';
      case 'paper_approved':
        return 'Bài báo được duyệt';
      case 'reviewer_assigned':
        return 'Phân công phản biện viên';
      case 'paper_rejected':
        return 'Bài báo bị từ chối';
      default:
        return 'Hoạt động';
    }
  }

  String _getActivitySubtitle(Map<String, dynamic> activity) {
    switch (activity['type']) {
      case 'paper_submitted':
        return '${activity['author']} - ${activity['title']}';
      case 'review_completed':
        return '${activity['reviewer']} - Điểm: ${activity['score']}';
      case 'paper_approved':
        return activity['title'];
      case 'reviewer_assigned':
        return '${activity['reviewer']} - ${activity['paper']}';
      case 'paper_rejected':
        return '${activity['title']} - ${activity['reason']}';
      default:
        return '';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
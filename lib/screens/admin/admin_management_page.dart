import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_indicator.dart';

class AdminManagementPage extends StatefulWidget {
  const AdminManagementPage({super.key});

  @override
  State<AdminManagementPage> createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _searchQuery = '';

  List<Map<String, dynamic>> _authors = [];
  List<Map<String, dynamic>> _reviewers = [];
  List<Map<String, dynamic>> _filteredAuthors = [];
  List<Map<String, dynamic>> _filteredReviewers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      _authors = [
        {
          'id': '1',
          'name': 'Nguyễn Văn A',
          'email': 'nguyenvana@email.com',
          'affiliation': 'ĐH Bách Khoa TP.HCM',
          'papers': 5,
          'status': 'active',
          'joined': DateTime(2024, 1, 15),
        },
        {
          'id': '2',
          'name': 'Trần Thị B',
          'email': 'tranthib@email.com',
          'affiliation': 'ĐH Khoa học Tự nhiên',
          'papers': 3,
          'status': 'active',
          'joined': DateTime(2024, 2, 20),
        },
        {
          'id': '3',
          'name': 'Lê Văn C',
          'email': 'levanc@email.com',
          'affiliation': 'ĐH Công nghiệp TP.HCM',
          'papers': 2,
          'status': 'inactive',
          'joined': DateTime(2024, 3, 10),
        },
      ];
      
      _reviewers = [
        {
          'id': '1',
          'name': 'TS. Phạm Văn D',
          'email': 'phamvand@email.com',
          'affiliation': 'ĐH Bách Khoa TP.HCM',
          'expertise': ['Machine Learning', 'AI', 'Data Science'],
          'assigned': 8,
          'completed': 6,
          'status': 'active',
          'rating': 4.5,
        },
        {
          'id': '2',
          'name': 'PGS.TS. Hoàng Thị E',
          'email': 'hoangthie@email.com',
          'affiliation': 'ĐH Khoa học Tự nhiên',
          'expertise': ['Blockchain', 'Security', 'Cryptography'],
          'assigned': 12,
          'completed': 10,
          'status': 'active',
          'rating': 4.8,
        },
        {
          'id': '3',
          'name': 'TS. Đỗ Văn F',
          'email': 'dovanf@email.com',
          'affiliation': 'ĐH Công nghệ',
          'expertise': ['IoT', 'Embedded Systems', 'Networks'],
          'assigned': 5,
          'completed': 5,
          'status': 'busy',
          'rating': 4.2,
        },
      ];
      
      _filteredAuthors = List.from(_authors);
      _filteredReviewers = List.from(_reviewers);
      _isLoading = false;
    });
  }

  void _filterData() {
    setState(() {
      _filteredAuthors = _authors.where((author) {
        final name = author['name'].toString().toLowerCase();
        final email = author['email'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
      
      _filteredReviewers = _reviewers.where((reviewer) {
        final name = reviewer['name'].toString().toLowerCase();
        final email = reviewer['email'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _filterData();
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm người dùng...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                          _filterData();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.adminPrimary,
              labelColor: AppColors.adminPrimary,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Tác giả'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.adminPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_filteredAuthors.length}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Phản biện viên'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.adminPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_filteredReviewers.length}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const LoadingIndicator()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAuthorsList(),
                      _buildReviewersList(),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        backgroundColor: AppColors.adminPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Thêm người dùng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildAuthorsList() {
    if (_filteredAuthors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'Chưa có tác giả' : 'Không tìm thấy tác giả',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredAuthors.length,
        itemBuilder: (context, index) {
          final author = _filteredAuthors[index];
          return _buildAuthorCard(author);
        },
      ),
    );
  }

  Widget _buildAuthorCard(Map<String, dynamic> author) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.adminPrimary.withOpacity(0.1),
          child: Text(
            author['name'].toString().substring(0, 1).toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.adminPrimary,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                author['name'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: author['status'] == 'active'
                    ? AppColors.success.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                author['status'] == 'active' ? 'Hoạt động' : 'Không hoạt động',
                style: TextStyle(
                  fontSize: 11,
                  color: author['status'] == 'active' ? AppColors.success : Colors.grey,
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
            Row(
              children: [
                Icon(Icons.email, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    author['email'],
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.business, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    author['affiliation'],
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(Icons.description, '${author['papers']} bài báo'),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.calendar_today, _formatDate(author['joined'])),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
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
            PopupMenuItem(
              value: 'status',
              child: Row(
                children: [
                  Icon(
                    author['status'] == 'active' ? Icons.block : Icons.check_circle,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(author['status'] == 'active' ? 'Vô hiệu hóa' : 'Kích hoạt'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleAuthorAction(value.toString(), author),
        ),
      ),
    );
  }

  Widget _buildReviewersList() {
    if (_filteredReviewers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'Chưa có phản biện viên' : 'Không tìm thấy phản biện viên',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredReviewers.length,
        itemBuilder: (context, index) {
          final reviewer = _filteredReviewers[index];
          return _buildReviewerCard(reviewer);
        },
      ),
    );
  }

  Widget _buildReviewerCard(Map<String, dynamic> reviewer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.info.withOpacity(0.1),
              child: Text(
                reviewer['name'].toString().substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: reviewer['status'] == 'active'
                      ? AppColors.success
                      : reviewer['status'] == 'busy'
                          ? AppColors.warning
                          : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                reviewer['name'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: AppColors.warning),
                const SizedBox(width: 2),
                Text(
                  '${reviewer['rating']}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              reviewer['affiliation'],
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(Icons.assignment, '${reviewer['assigned']} được giao'),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.check_circle, '${reviewer['completed']} hoàn thành'),
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
                const SizedBox(height: 12),
                Text(
                  'Lĩnh vực chuyên môn',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (reviewer['expertise'] as List<String>).map((exp) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        exp,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleReviewerAction('edit', reviewer),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Chỉnh sửa'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.adminPrimary,
                          side: BorderSide(color: AppColors.adminPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleReviewerAction('assign', reviewer),
                        icon: const Icon(Icons.person_add_alt, size: 18),
                        label: const Text('Phân công'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.adminPrimary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAuthorAction(String action, Map<String, dynamic> author) {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chỉnh sửa ${author['name']}')),
        );
        break;
      case 'view':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xem chi tiết ${author['name']}')),
        );
        break;
      case 'status':
        setState(() {
          author['status'] = author['status'] == 'active' ? 'inactive' : 'active';
          _filterData();
        });
        break;
      case 'delete':
        _confirmDelete(author['name'], () {
          setState(() {
            _authors.remove(author);
            _filterData();
          });
        });
        break;
    }
  }

  void _handleReviewerAction(String action, Map<String, dynamic> reviewer) {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chỉnh sửa ${reviewer['name']}')),
        );
        break;
      case 'assign':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phân công cho ${reviewer['name']}')),
        );
        break;
    }
  }

  void _confirmDelete(String name, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa thành công')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm người dùng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person, color: AppColors.adminPrimary),
              title: const Text('Thêm tác giả'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mở form thêm tác giả')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.rate_review, color: AppColors.info),
              title: const Text('Thêm phản biện viên'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mở form thêm phản biện viên')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
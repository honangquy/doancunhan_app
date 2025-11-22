import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';
import '../../models/paper.dart';
import '../../widgets/paper_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';

class MyPapersPage extends StatefulWidget {
  const MyPapersPage({Key? key}) : super(key: key);

  @override
  State<MyPapersPage> createState() => _MyPapersPageState();
}

class _MyPapersPageState extends State<MyPapersPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  
  bool _isLoading = true;
  List<Paper> _allPapers = [];
  List<Paper> _filteredPapers = [];
  String _selectedFilter = 'all';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _filterTabs = [
    {'label': 'All', 'value': 'all', 'icon': Icons.all_inbox},
    {'label': 'Under Review', 'value': 'under_review', 'icon': Icons.pending},
    {'label': 'Accepted', 'value': 'accepted', 'icon': Icons.check_circle},
    {'label': 'Rejected', 'value': 'rejected', 'icon': Icons.cancel},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filterTabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadPapers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedFilter = _filterTabs[_tabController.index]['value'];
        _applyFilters();
      });
    }
  }

  Future<void> _loadPapers() async {
    setState(() => _isLoading = true);
    try {
      final papers = await _apiService.getMyPapers();
      setState(() {
        _allPapers = papers;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error loading papers: $e', isError: true);
    }
  }

  void _applyFilters() {
    List<Paper> filtered = _allPapers;

    // Apply status filter
    if (_selectedFilter != 'all') {
      filtered = filtered.where((paper) => paper.status == _selectedFilter).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((paper) {
        final authorsStr = paper.authors?.join(" ").toLowerCase() ?? "";
        return paper.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               paper.abstract.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               authorsStr.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      _filteredPapers = filtered;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My Papers'),
        backgroundColor: AppColors.authorPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              _buildSearchBar(),
              _buildTabBar(),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPapers,
              color: AppColors.authorPrimary,
              child: _filteredPapers.isEmpty
                  ? _buildEmptyState()
                  : _buildPapersList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/author/submit');
          if (result == true) {
            _loadPapers();
          }
        },
        backgroundColor: AppColors.authorPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Submit Paper'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _applyFilters();
          });
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search papers...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _applyFilters();
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.authorPrimary,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: _filterTabs.map((filter) {
          return Tab(
            child: Row(
              children: [
                Icon(filter['icon'], size: 18),
                const SizedBox(width: 6),
                Text(filter['label']),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPapersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPapers.length,
      itemBuilder: (context, index) {
        final paper = _filteredPapers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onLongPress: () => _showPaperOptions(paper),
            child: PaperCard(
              paper: paper,
              onTap: () => _showPaperDetails(paper),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String message = 'No papers found';
    String description = 'Submit your first paper to get started';
    IconData icon = Icons.article_outlined;

    if (_selectedFilter != 'all') {
      message = 'No ${_selectedFilter.replaceAll('_', ' ')} papers';
      description = 'Papers with this status will appear here';
    } else if (_searchQuery.isNotEmpty) {
      message = 'No results found';
      description = 'Try different keywords';
      icon = Icons.search_off;
    }

    return EmptyState(
      icon: icon,
      title: message,
      subtitle: description,
      actionLabel: _selectedFilter == 'all' && _searchQuery.isEmpty ? 'Submit Paper' : null,
      onAction: _selectedFilter == 'all' && _searchQuery.isEmpty
          ? () => Navigator.pushNamed(context, '/author/submit')
          : null,
    );
  }

  void _showPaperDetails(Paper paper) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildStatusBadge(paper.status),
                      const SizedBox(height: 16),
                      Text(
                        paper.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow('Authors', paper.authors?.join(', ') ?? 'Unknown'),
                      _buildDetailRow('Track', paper.track),
                      _buildDetailRow('Submitted', '${paper.submittedDate.day}/${paper.submittedDate.month}/${paper.submittedDate.year}'),
                      if (paper.reviewScore != null)
                        _buildDetailRow('Score', '${paper.reviewScore}/10'),
                      if (paper.reviewComments != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Review Comments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            paper.reviewComments!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        'Abstract',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        paper.abstract,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildActionButtons(paper),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    
    switch (status) {
      case 'accepted':
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = AppColors.error;
        icon = Icons.cancel;
        break;
      case 'under_review':
        color = AppColors.warning;
        icon = Icons.pending;
        break;
      default:
        color = AppColors.textSecondary;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase().replaceAll('_', ' '),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Paper paper) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Download paper
              _showSnackBar('Download feature coming soon');
            },
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.authorPrimary,
              side: BorderSide(color: AppColors.authorPrimary),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Edit paper if status allows
              if (paper.status == 'under_review' || paper.status == 'rejected') {
                _showSnackBar('Edit feature coming soon');
              } else {
                _showSnackBar('Cannot edit accepted papers');
              }
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.authorPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPaperOptions(Paper paper) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.visibility, color: AppColors.authorPrimary),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _showPaperDetails(paper);
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: AppColors.authorPrimary),
              title: const Text('Download Paper'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Download feature coming soon');
              },
            ),
            if (paper.status != 'accepted')
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.authorPrimary),
                title: const Text('Edit Paper'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('Edit feature coming soon');
                },
              ),
            if (paper.status == 'under_review')
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.error),
                title: const Text('Withdraw Paper'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmWithdraw(paper);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmWithdraw(Paper paper) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Paper'),
        content: Text('Are you sure you want to withdraw "${paper.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _withdrawPaper(paper);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  Future<void> _withdrawPaper(Paper paper) async {
    try {
      await _apiService.withdrawPaper(paper.id);
      _showSnackBar('Paper withdrawn successfully');
      _loadPapers();
    } catch (e) {
      _showSnackBar('Error withdrawing paper: $e', isError: true);
    }
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/author_dashboard_provider.dart';
import '../../models/author_paper.dart';
import '../../utils/constants.dart';
import 'paper_detail_screen.dart';

class SimplePapersScreen extends StatefulWidget {
  const SimplePapersScreen({Key? key}) : super(key: key);

  @override
  State<SimplePapersScreen> createState() => _SimplePapersScreenState();
}

class _SimplePapersScreenState extends State<SimplePapersScreen> {
  @override
  void initState() {
    super.initState();
    print('📱 [SimplePapersScreen] initState called');
    
    // Load papers
    Future.microtask(() {
      print('📱 [SimplePapersScreen] Loading papers...');
      context.read<AuthorDashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('📱 [SimplePapersScreen] build called');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài báo của tôi'),
        backgroundColor: AppColors.authorPrimary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthorDashboardProvider>(
        builder: (context, provider, child) {
          print('📱 [SimplePapersScreen] Consumer building...');
          print('   isLoading: ${provider.isLoading}');
          print('   error: ${provider.error}');
          print('   papers count: ${provider.authorPapers.length}');
          print('   paginatedPapers: ${provider.paginatedPapers}');
          
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải...'),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthorDashboardProvider>().loadDashboard();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final papers = provider.authorPapers;
          print('📱 [SimplePapersScreen] Displaying ${papers.length} papers');

          if (papers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.article, size: 100, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có bài báo',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total from provider: ${provider.paginatedPapers?.total ?? 0}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Data length: ${provider.paginatedPapers?.data.length ?? 0}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: papers.length,
            itemBuilder: (context, index) {
              final paper = papers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('#${paper.paperId}'),
                  ),
                  title: Text(
                    paper.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(paper.conferenceTitle),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.authorPrimary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              paper.statusName,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            paper.formattedCreatedAt,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaperDetailScreen(
                          paperId: paper.paperId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Reload
          context.read<AuthorDashboardProvider>().loadDashboard();
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Tải lại'),
        backgroundColor: AppColors.authorPrimary,
      ),
    );
  }
}

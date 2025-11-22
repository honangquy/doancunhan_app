import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/paper.dart';
import '../../services/api_service.dart';

class AuthorPapersPage extends StatefulWidget {
  const AuthorPapersPage({Key? key}) : super(key: key);

  @override
  State<AuthorPapersPage> createState() => _AuthorPapersPageState();
}

class _AuthorPapersPageState extends State<AuthorPapersPage> {
  final ApiService _apiService = ApiService();
  List<Paper> _papers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPapers();
  }

  Future<void> _loadPapers() async {
    try {
      final papers = await _apiService.fetchPapers();
      if (mounted) {
        setState(() {
          _papers = papers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _papers.isEmpty
              ? const Center(child: Text('Chưa có bài báo'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _papers.length,
                  itemBuilder: (context, index) {
                    final paper = _papers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(paper.title),
                        subtitle: Text(paper.author),
                        trailing: Chip(
                          label: Text(paper.statusVietnamese),
                          backgroundColor: _getStatusColor(paper.status),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'reviewing':
        return AppColors.info;
      default:
        return AppColors.warning;
    }
  }
}

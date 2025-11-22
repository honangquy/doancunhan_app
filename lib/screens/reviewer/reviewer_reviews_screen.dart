import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/reviewer_provider.dart';
import '../../utils/constants.dart';
import 'reviewer_review_form_screen.dart';

class ReviewerReviewsScreen extends StatefulWidget {
  const ReviewerReviewsScreen({super.key});

  @override
  State<ReviewerReviewsScreen> createState() => _ReviewerReviewsScreenState();
}

class _ReviewerReviewsScreenState extends State<ReviewerReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewerProvider>().loadReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.reviewerPrimary,
        foregroundColor: Colors.white,
        title: const Text('Phản biện của tôi', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<ReviewerProvider>(
        builder: (context, provider, child) {
          if (provider.isReviewsLoading && provider.reviews.isEmpty) {
            return const Center(child: CupertinoActivityIndicator(radius: 20));
          }

          if (provider.reviewsError != null) {
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
                    child: Text(provider.reviewsError!, style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadReviews(),
                    icon: const Icon(CupertinoIcons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadReviews(),
            child: CustomScrollView(
              slivers: [
                // Statistics
                if (provider.reviewStats != null)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildStatItem('Tổng số', provider.reviewStats!.total.toString(), Colors.blue)),
                              Expanded(child: _buildStatItem('Điểm TB', provider.reviewStats!.averageScore.toStringAsFixed(1), Colors.amber)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildStatItem('Chấp nhận', provider.reviewStats!.accept.toString(), Colors.green)),
                              Expanded(child: _buildStatItem('Từ chối', provider.reviewStats!.reject.toString(), Colors.red)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Reviews List
                provider.reviews.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.doc_plaintext, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('Chưa có phản biện nào', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final review = provider.reviews[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReviewerReviewFormScreen(
                                        assignmentId: review.assignmentId,
                                        existingReview: review,
                                      ),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            if (review.isDraft)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text('Nháp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange)),
                                              )
                                            else if (review.recommendationCode != null)
                                              _buildRecommendationBadge(review.recommendationCode!),
                                            const Spacer(),
                                            if (review.totalScore != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: AppColors.reviewerPrimary.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  review.totalScore!.toStringAsFixed(1),
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.reviewerPrimary),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(review.paperTitle ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 8),
                                        if (review.conferenceName != null)
                                          Row(
                                            children: [
                                              Icon(CupertinoIcons.building_2_fill, size: 14, color: Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(review.conferenceName!, style: TextStyle(fontSize: 13, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              ),
                                            ],
                                          ),
                                        if (review.submittedAt != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Gửi: ${review.submittedAt!.day}/${review.submittedAt!.month}/${review.submittedAt!.year}',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: provider.reviews.length,
                          ),
                        ),
                      ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildRecommendationBadge(String code) {
    Color color;
    String label;
    if (code.contains('ACCEPT')) {
      color = Colors.green;
      label = 'Chấp nhận';
    } else if (code.contains('REJECT')) {
      color = Colors.red;
      label = 'Từ chối';
    } else {
      color = Colors.orange;
      label = 'Biên giới';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

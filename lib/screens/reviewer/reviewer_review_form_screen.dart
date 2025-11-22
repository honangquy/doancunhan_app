import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/reviewer_provider.dart';
import '../../models/reviewer_assignment.dart';
import '../../utils/constants.dart';

class ReviewerReviewFormScreen extends StatefulWidget {
  final int assignmentId;
  final Review? existingReview;

  const ReviewerReviewFormScreen({super.key, required this.assignmentId, this.existingReview});

  @override
  State<ReviewerReviewFormScreen> createState() => _ReviewerReviewFormScreenState();
}

class _ReviewerReviewFormScreenState extends State<ReviewerReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _commentsController;
  
  int? _scoreNovelty;
  int? _scoreRelevance;
  int? _scoreTechnicalQuality;
  int? _scorePresentation;
  int? _scoreReferences;
  String? _recommendationCode;
  
  final List<Map<String, String>> _recommendations = [
    {'code': 'STRONG_ACCEPT', 'label': 'Chấp nhận mạnh'},
    {'code': 'ACCEPT', 'label': 'Chấp nhận'},
    {'code': 'WEAK_ACCEPT', 'label': 'Chấp nhận yếu'},
    {'code': 'BORDERLINE', 'label': 'Biên giới'},
    {'code': 'WEAK_REJECT', 'label': 'Từ chối yếu'},
    {'code': 'REJECT', 'label': 'Từ chối'},
    {'code': 'STRONG_REJECT', 'label': 'Từ chối mạnh'},
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingReview;
    _scoreNovelty = existing?.scoreNovelty;
    _scoreRelevance = existing?.scoreRelevance;
    _scoreTechnicalQuality = existing?.scoreTechnicalQuality;
    _scorePresentation = existing?.scorePresentation;
    _scoreReferences = existing?.scoreReferences;
    _recommendationCode = existing?.recommendationCode;
    _commentsController = TextEditingController(text: existing?.detailedComments ?? '');
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  double? get _averageScore {
    if (_scoreNovelty == null || _scoreRelevance == null || _scoreTechnicalQuality == null ||
        _scorePresentation == null || _scoreReferences == null) return null;
    return (_scoreNovelty! + _scoreRelevance! + _scoreTechnicalQuality! + _scorePresentation! + _scoreReferences!) / 5.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.reviewerPrimary,
        foregroundColor: Colors.white,
        title: Text(widget.existingReview?.isDraft == true ? 'Chỉnh sửa phản biện' : 'Phản biện bài báo', 
          style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Scores Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Điểm đánh giá (1-10)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const SizedBox(height: 16),
                  _buildScoreSlider('Tính mới', _scoreNovelty, (val) => setState(() => _scoreNovelty = val)),
                  _buildScoreSlider('Liên quan', _scoreRelevance, (val) => setState(() => _scoreRelevance = val)),
                  _buildScoreSlider('Chất lượng kỹ thuật', _scoreTechnicalQuality, (val) => setState(() => _scoreTechnicalQuality = val)),
                  _buildScoreSlider('Trình bày', _scorePresentation, (val) => setState(() => _scorePresentation = val)),
                  _buildScoreSlider('Tài liệu tham khảo', _scoreReferences, (val) => setState(() => _scoreReferences = val)),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Điểm trung bình:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                      Text(_averageScore != null ? _averageScore!.toStringAsFixed(1) : 'N/A',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.reviewerPrimary)),
                    ],
                  ),
                ],
              ),
            ),

            // Recommendation
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Khuyến nghị', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _recommendationCode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Chọn khuyến nghị',
                    ),
                    items: _recommendations.map((rec) {
                      return DropdownMenuItem(value: rec['code'], child: Text(rec['label']!));
                    }).toList(),
                    onChanged: (val) => setState(() => _recommendationCode = val),
                    validator: (val) => val == null ? 'Vui lòng chọn khuyến nghị' : null,
                  ),
                ],
              ),
            ),

            // Comments
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nhận xét chi tiết', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _commentsController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Nhập nhận xét chi tiết...',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Vui lòng nhập nhận xét';
                      if (val.trim().length < 50) return 'Nhận xét phải có ít nhất 50 ký tự';
                      return null;
                    },
                  ),
                ],
              ),
            ),

            // Action Buttons
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _submitReview(context, isDraft: true),
                    icon: const Icon(CupertinoIcons.floppy_disk),
                    label: const Text('Lưu nháp'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _submitReview(context, isDraft: false),
                    icon: const Icon(CupertinoIcons.checkmark_circle),
                    label: const Text('Gửi phản biện'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.reviewerPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSlider(String label, int? value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.reviewerPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(value?.toString() ?? 'N/A',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.reviewerPrimary)),
              ),
            ],
          ),
          Slider(
            value: (value ?? 5).toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: (value ?? 5).toString(),
            onChanged: (val) => onChanged(val.toInt()),
            activeColor: AppColors.reviewerPrimary,
          ),
        ],
      ),
    );
  }

  Future<void> _submitReview(BuildContext context, {required bool isDraft}) async {
    if (!isDraft && !_formKey.currentState!.validate()) return;
    if (!isDraft && _averageScore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ điểm đánh giá'), backgroundColor: Colors.red),
      );
      return;
    }

    final provider = context.read<ReviewerProvider>();
    final success = await provider.submitReview(
      assignmentId: widget.assignmentId,
      scoreNovelty: _scoreNovelty,
      scoreRelevance: _scoreRelevance,
      scoreTechnicalQuality: _scoreTechnicalQuality,
      scorePresentation: _scorePresentation,
      scoreReferences: _scoreReferences,
      detailedComments: _commentsController.text.trim(),
      recommendationCode: _recommendationCode,
      isDraft: isDraft,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isDraft ? 'Đã lưu nháp thành công' : 'Đã gửi phản biện thành công'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.submitReviewError ?? 'Có lỗi xảy ra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

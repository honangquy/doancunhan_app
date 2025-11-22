import 'package:flutter/material.dart';
import 'reviewer_main_screen.dart';

/// Wrapper class cho tương thích với routing cũ
/// Chuyển hướng sang ReviewerMainScreen mới (dùng Reviewer Mobile API)
class ReviewerDashboard extends StatelessWidget {
  const ReviewerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ReviewerMainScreen();
  }
}

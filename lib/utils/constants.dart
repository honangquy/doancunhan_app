import 'package:flutter/material.dart';

// ============================================
// APP CONSTANTS
// ============================================

class AppConstants {
  // App Info
  static const String appName = 'HUIT Conference';
  static const String appVersion = '1.0.0';
  
  // API Configuration (Chuẩn bị cho backend)
  static const String baseUrl = 'https://api.huit.edu.vn'; // Thay bằng API thật
  static const String apiVersion = '/api/v1';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

// ============================================
// APP COLORS
// ============================================

class AppColors {
  // Primary Colors - Màu pastel chủ đạo
  static const Color primary = Color(0xFF7BC9A6);            // Màu chính mặc định
  static const Color authorPrimary = Color(0xFF7BC9A6);      // Xanh lá pastel
  static const Color authorSecondary = Color(0xFF5FB491);    // Xanh lá đậm
  
  static const Color reviewerPrimary = Color(0xFF6EC6FF);    // Xanh dương pastel
  static const Color reviewerSecondary = Color(0xFF5AB5EE);  // Xanh dương đậm
  
  static const Color adminPrimary = Color(0xFFFFB84D);       // Cam vàng pastel
  static const Color adminSecondary = Color(0xFFFFA73D);     // Cam vàng đậm
  
  // Status Colors
  static const Color success = Color(0xFF7BC9A6);
  static const Color warning = Color(0xFFFFB84D);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF6EC6FF);
  
  // Neutral Colors
  static const Color background = Color(0xFFF8FAFB);
  static const Color adminBackground = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  
  // Text Colors
  static const Color textDark = Color(0xFF2D3748);
  static const Color textMedium = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  
  // Additional Background Colors
  static const Color backgroundLight = Color(0xFFF8FAFB);
  
  // Gradient Colors
  static List<Color> authorGradient = [authorPrimary, authorSecondary];
  static List<Color> reviewerGradient = [reviewerPrimary, reviewerSecondary];
  static List<Color> adminGradient = [adminPrimary, adminSecondary];
}

// ============================================
// APP STRINGS
// ============================================

class AppStrings {
  // Common
  static const String loading = 'Đang tải...';
  static const String error = 'Đã có lỗi xảy ra';
  static const String success = 'Thành công';
  static const String cancel = 'Hủy';
  static const String confirm = 'Xác nhận';
  static const String save = 'Lưu';
  static const String delete = 'Xóa';
  static const String edit = 'Chỉnh sửa';
  
  // Authentication
  static const String login = 'Đăng nhập';
  static const String logout = 'Đăng xuất';
  static const String email = 'Email';
  static const String password = 'Mật khẩu';
  
  // Roles
  static const String author = 'Tác giả';
  static const String reviewer = 'Phản biện';
  static const String admin = 'Quản trị viên';
  
  // Author
  static const String submitPaper = 'Nộp bài';
  static const String myPapers = 'Bài báo của tôi';
  static const String proceedings = 'Kỷ yếu';
  
  // Reviewer
  static const String reviews = 'Phản biện';
  static const String reviewPaper = 'Phản biện bài báo';
  static const String history = 'Lịch sử';
  
  // Admin
  static const String dashboard = 'Tổng quan';
  static const String management = 'Quản lý';
  static const String reports = 'Báo cáo';
  static const String postAnnouncement = 'Đăng thông báo';
  static const String assignReviewer = 'Phân công phản biện';
  static const String trackProcess = 'Theo dõi quy trình';
}

// ============================================
// APP STYLES
// ============================================

class AppStyles {
  // Border Radius
  static BorderRadius smallRadius = BorderRadius.circular(8);
  static BorderRadius mediumRadius = BorderRadius.circular(12);
  static BorderRadius largeRadius = BorderRadius.circular(16);
  static BorderRadius extraLargeRadius = BorderRadius.circular(20);
  
  // Shadows
  static List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
  
  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textMedium,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
  );
}

// ============================================
// APP SIZES
// ============================================

class AppSizes {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Button Heights
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;
  
  // Avatar Sizes
  static const double avatarS = 40.0;
  static const double avatarM = 60.0;
  static const double avatarL = 100.0;
}

// ============================================
// API ENDPOINTS (Chuẩn bị cho backend)
// ============================================

class ApiEndpoints {
  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // Papers
  static const String papers = '/papers';
  static const String submitPaper = '/papers/submit';
  static const String paperDetail = '/papers'; // + /{id}
  static const String withdrawPaper = '/papers'; // + /{id}/withdraw
  
  // Reviews
  static const String reviews = '/reviews';
  static const String submitReview = '/reviews/submit';
  static const String reviewDetail = '/reviews'; // + /{id}
  
  // Users
  static const String users = '/users';
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile';
  
  // Admin
  static const String announcements = '/admin/announcements';
  static const String assignReviewers = '/admin/assign-reviewers';
  static const String reports = '/admin/reports';
  
  // Proceedings
  static const String proceedings = '/proceedings';
  static const String downloadProceeding = '/proceedings'; // + /{id}/download
}
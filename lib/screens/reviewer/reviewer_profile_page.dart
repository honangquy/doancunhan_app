import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

/// Màn hình Profile cho Reviewer
class ReviewerProfilePage extends StatelessWidget {
  const ReviewerProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: true);
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy thông tin người dùng')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        backgroundColor: AppColors.reviewerPrimary,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.reviewerPrimary,
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 36, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tên
          Center(
            child: Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Email
          Center(
            child: Text(
              user.email,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textMedium,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Vai trò
          Card(
            child: ListTile(
              leading: Icon(Icons.person, color: AppColors.reviewerPrimary),
              title: const Text('Vai trò'),
              subtitle: const Text('Phản biện viên'),
            ),
          ),

          // ID
          Card(
            child: ListTile(
              leading: Icon(Icons.account_circle, color: AppColors.reviewerPrimary),
              title: const Text('ID'),
              subtitle: Text(user.id),
            ),
          ),

          const SizedBox(height: 32),

          // Chỉnh sửa thông tin
          Card(
            child: ListTile(
              leading: Icon(CupertinoIcons.person_crop_circle, color: AppColors.reviewerPrimary),
              title: const Text('Chỉnh sửa thông tin'),
              trailing: Icon(CupertinoIcons.chevron_right, color: Colors.grey[400], size: 20),
              onTap: () => _showEditProfileDialog(context, authService),
            ),
          ),

          // Đổi mật khẩu
          Card(
            child: ListTile(
              leading: Icon(CupertinoIcons.lock, color: AppColors.reviewerPrimary),
              title: const Text('Đổi mật khẩu'),
              trailing: Icon(CupertinoIcons.chevron_right, color: Colors.grey[400], size: 20),
              onTap: () => _showChangePasswordDialog(context),
            ),
          ),

          // Cài đặt thông báo
          Card(
            child: ListTile(
              leading: Icon(CupertinoIcons.bell, color: AppColors.reviewerPrimary),
              title: const Text('Cài đặt thông báo'),
              trailing: Icon(CupertinoIcons.chevron_right, color: Colors.grey[400], size: 20),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
          ),

          // Trợ giúp & Hỗ trợ
          Card(
            child: ListTile(
              leading: Icon(CupertinoIcons.question_circle, color: AppColors.reviewerPrimary),
              title: const Text('Trợ giúp & Hỗ trợ'),
              trailing: Icon(CupertinoIcons.chevron_right, color: Colors.grey[400], size: 20),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // Đăng xuất
          ElevatedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xác nhận'),
                  content: const Text('Bạn có chắc muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await authService.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  static void _showEditProfileDialog(BuildContext context, AuthService authService) {
    final nameController = TextEditingController(text: authService.currentUser?.name);
    final emailController = TextEditingController(text: authService.currentUser?.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
                prefixIcon: Icon(CupertinoIcons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(CupertinoIcons.mail),
              ),
              enabled: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Update profile API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật thông tin')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.reviewerPrimary,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  static void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Đổi mật khẩu',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu cũ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(CupertinoIcons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                border: OutlineInputBorder(),
                prefixIcon: Icon(CupertinoIcons.lock_fill),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                border: OutlineInputBorder(),
                prefixIcon: Icon(CupertinoIcons.lock_fill),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mật khẩu xác nhận không khớp'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              // TODO: Change password API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã đổi mật khẩu')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.reviewerPrimary,
            ),
            child: const Text('Đổi'),
          ),
        ],
      ),
    );
  }
}

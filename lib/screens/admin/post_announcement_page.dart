import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class PostAnnouncementPage extends StatefulWidget {
  const PostAnnouncementPage({super.key});

  @override
  State<PostAnnouncementPage> createState() => _PostAnnouncementPageState();
}

class _PostAnnouncementPageState extends State<PostAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String _priority = 'normal';
  final List<String> _selectedAudiences = ['authors'];
  bool _sendEmail = true;
  bool _sendPush = true;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        backgroundColor: AppColors.adminPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đăng thông báo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _previewAnnouncement,
            icon: const Icon(Icons.visibility, color: Colors.white, size: 20),
            label: const Text(
              'Xem trước',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPrioritySelector(),
              const SizedBox(height: 20),
              _buildTitleField(),
              const SizedBox(height: 20),
              _buildContentField(),
              const SizedBox(height: 20),
              _buildAudienceSelector(),
              const SizedBox(height: 20),
              _buildNotificationOptions(),
              const SizedBox(height: 20),
              _buildScheduleSection(),
              const SizedBox(height: 30),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mức độ ưu tiên',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPriorityChip('low', 'Thấp', AppColors.info),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPriorityChip('normal', 'Bình thường', AppColors.success),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPriorityChip('high', 'Cao', AppColors.warning),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPriorityChip('urgent', 'Khẩn cấp', AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String value, String label, Color color) {
    final isSelected = _priority == value;
    
    return InkWell(
      onTap: () => setState(() => _priority = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? color : Colors.grey,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiêu đề',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Nhập tiêu đề thông báo...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập tiêu đề';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContentField() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nội dung',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contentController,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: 'Nhập nội dung thông báo...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập nội dung';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  // Add attachment
                },
                icon: const Icon(Icons.attach_file, size: 18),
                label: const Text('Đính kèm'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đối tượng nhận',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text('Tác giả'),
            subtitle: Text('124 người', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            value: _selectedAudiences.contains('authors'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedAudiences.add('authors');
                } else {
                  _selectedAudiences.remove('authors');
                }
              });
            },
            activeColor: AppColors.adminPrimary,
          ),
          CheckboxListTile(
            title: const Text('Phản biện viên'),
            subtitle: Text('28 người', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            value: _selectedAudiences.contains('reviewers'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedAudiences.add('reviewers');
                } else {
                  _selectedAudiences.remove('reviewers');
                }
              });
            },
            activeColor: AppColors.adminPrimary,
          ),
          CheckboxListTile(
            title: const Text('Tất cả'),
            subtitle: Text('152 người', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            value: _selectedAudiences.contains('all'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedAudiences.clear();
                  _selectedAudiences.add('all');
                } else {
                  _selectedAudiences.remove('all');
                }
              });
            },
            activeColor: AppColors.adminPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gửi thông báo qua',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Email'),
            subtitle: const Text('Gửi email đến người nhận'),
            value: _sendEmail,
            onChanged: (value) => setState(() => _sendEmail = value),
            activeColor: AppColors.adminPrimary,
          ),
          SwitchListTile(
            title: const Text('Push notification'),
            subtitle: const Text('Gửi thông báo đẩy'),
            value: _sendPush,
            onChanged: (value) => setState(() => _sendPush = value),
            activeColor: AppColors.adminPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: AppColors.adminPrimary),
              const SizedBox(width: 8),
              Text(
                'Lên lịch đăng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Đăng ngay'),
            leading: Radio<String>(
              value: 'now',
              groupValue: 'now',
              onChanged: (value) {},
              activeColor: AppColors.adminPrimary,
            ),
          ),
          ListTile(
            title: const Text('Lên lịch'),
            subtitle: const Text('Chọn ngày và giờ đăng'),
            leading: Radio<String>(
              value: 'schedule',
              groupValue: 'now',
              onChanged: (value) {},
              activeColor: AppColors.adminPrimary,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Show date time picker
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _postAnnouncement,
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text(
              'Đăng thông báo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Save as draft
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã lưu nháp')),
              );
            },
            icon: Icon(Icons.drafts, color: AppColors.textSecondary),
            label: Text(
              'Lưu nháp',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }

  void _previewAnnouncement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Xem trước thông báo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getPriorityColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getPriorityLabel(),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getPriorityColor(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _titleController.text.isEmpty ? 'Tiêu đề thông báo' : _titleController.text,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _contentController.text.isEmpty ? 'Nội dung thông báo' : _contentController.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _postAnnouncement() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAudiences.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn đối tượng nhận')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận đăng'),
          content: Text(
            'Đăng thông báo đến ${_selectedAudiences.contains('all') ? 'tất cả' : _selectedAudiences.join(', ')}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã đăng thông báo thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Đăng'),
            ),
          ],
        ),
      );
    }
  }

  Color _getPriorityColor() {
    switch (_priority) {
      case 'low':
        return AppColors.info;
      case 'high':
        return AppColors.warning;
      case 'urgent':
        return AppColors.error;
      default:
        return AppColors.success;
    }
  }

  String _getPriorityLabel() {
    switch (_priority) {
      case 'low':
        return 'Thấp';
      case 'high':
        return 'Cao';
      case 'urgent':
        return 'Khẩn cấp';
      default:
        return 'Bình thường';
    }
  }
}
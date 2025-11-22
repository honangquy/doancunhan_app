import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/announcement_provider.dart';
import '../../models/announcement.dart';
import '../../utils/constants.dart';

class ChairCreateAnnouncementScreen extends StatefulWidget {
  const ChairCreateAnnouncementScreen({super.key});

  @override
  State<ChairCreateAnnouncementScreen> createState() => _ChairCreateAnnouncementScreenState();
}

class _ChairCreateAnnouncementScreenState extends State<ChairCreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  int? _selectedConferenceId;
  String _selectedAudience = 'ALL';
  final Set<String> _selectedChannels = {'SYSTEM'};
  DateTime? _scheduledDateTime;
  
  RecipientPreview? _recipientPreview;
  bool _isPreviewLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().loadConferences();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Tạo thông báo mới'),
      ),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingConferences && provider.conferences.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Conference Selector
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(CupertinoIcons.building_2_fill, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Hội thảo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(' *', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: _selectedConferenceId,
                          decoration: InputDecoration(
                            hintText: 'Chọn hội thảo',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: provider.conferences.map((conf) {
                            return DropdownMenuItem(
                              value: conf.conferenceId,
                              child: Text(conf.conferenceName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedConferenceId = value;
                              _recipientPreview = null; // Reset preview
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Vui lòng chọn hội thảo';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Title
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(CupertinoIcons.text_cursor, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Tiêu đề',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(' *', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Nhập tiêu đề thông báo',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLength: 200,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tiêu đề';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Content
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(CupertinoIcons.doc_text_fill, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Nội dung',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(' *', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _contentController,
                          decoration: InputDecoration(
                            hintText: 'Nhập nội dung thông báo',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: 6,
                          maxLength: 1000,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập nội dung';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Audience
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(CupertinoIcons.person_2_fill, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Đối tượng nhận',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildAudienceChip('ALL', 'Tất cả', CupertinoIcons.person_3_fill),
                            _buildAudienceChip('AUTHORS', 'Tác giả', CupertinoIcons.pencil),
                            _buildAudienceChip('REVIEWERS', 'Phản biện', CupertinoIcons.doc_text_search),
                            _buildAudienceChip('CHAIRS', 'Chủ tịch', CupertinoIcons.person_crop_square),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Channels
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(CupertinoIcons.antenna_radiowaves_left_right, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Kênh gửi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          title: const Text('Thông báo hệ thống (trong ứng dụng)'),
                          secondary: const Icon(CupertinoIcons.bell_fill),
                          value: _selectedChannels.contains('SYSTEM'),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedChannels.add('SYSTEM');
                              } else if (_selectedChannels.length > 1) {
                                _selectedChannels.remove('SYSTEM');
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('Email'),
                          secondary: const Icon(CupertinoIcons.mail_solid),
                          value: _selectedChannels.contains('EMAIL'),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedChannels.add('EMAIL');
                              } else if (_selectedChannels.length > 1) {
                                _selectedChannels.remove('EMAIL');
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('Chatbot'),
                          secondary: const Icon(CupertinoIcons.chat_bubble_2_fill),
                          value: _selectedChannels.contains('CHATBOT'),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedChannels.add('CHATBOT');
                              } else if (_selectedChannels.length > 1) {
                                _selectedChannels.remove('CHATBOT');
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Scheduled Date/Time
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(CupertinoIcons.clock_fill, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Thời gian gửi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Send Now Button
                        InkWell(
                          onTap: () {
                            setState(() {
                              _scheduledDateTime = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _scheduledDateTime == null 
                                    ? AppColors.primary 
                                    : Colors.grey[300]!,
                                width: _scheduledDateTime == null ? 2 : 1,
                              ),
                              color: _scheduledDateTime == null 
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.paperplane_fill,
                                  color: _scheduledDateTime == null 
                                      ? AppColors.primary 
                                      : Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Gửi ngay',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: _scheduledDateTime == null 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                    color: _scheduledDateTime == null 
                                        ? AppColors.primary 
                                        : Colors.grey[700],
                                  ),
                                ),
                                const Spacer(),
                                if (_scheduledDateTime == null)
                                  Icon(
                                    CupertinoIcons.check_mark_circled_solid,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Schedule Send Button
                        InkWell(
                          onTap: _selectDateTime,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _scheduledDateTime != null 
                                    ? AppColors.primary 
                                    : Colors.grey[300]!,
                                width: _scheduledDateTime != null ? 2 : 1,
                              ),
                              color: _scheduledDateTime != null 
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.calendar,
                                  color: _scheduledDateTime != null 
                                      ? AppColors.primary 
                                      : Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Lên lịch gửi',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: _scheduledDateTime != null 
                                              ? FontWeight.bold 
                                              : FontWeight.normal,
                                          color: _scheduledDateTime != null 
                                              ? AppColors.primary 
                                              : Colors.grey[700],
                                        ),
                                      ),
                                      if (_scheduledDateTime != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDateTime(_scheduledDateTime!),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (_scheduledDateTime != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.check_mark_circled_solid,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          CupertinoIcons.xmark_circle_fill,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _scheduledDateTime = null;
                                          });
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Preview Recipients Button
                if (_selectedConferenceId != null)
                  ElevatedButton.icon(
                    onPressed: _isPreviewLoading ? null : _previewRecipients,
                    icon: _isPreviewLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(CupertinoIcons.eye_fill),
                    label: const Text('Xem trước người nhận'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                
                // Recipient Preview Result
                if (_recipientPreview != null) ...[
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    color: Colors.blue[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(CupertinoIcons.person_3_fill, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Text(
                                '${_recipientPreview!.count} người nhận',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isCreating ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: provider.isCreating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Tạo thông báo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAudienceChip(String value, String label, IconData icon) {
    final isSelected = _selectedAudience == value;
    
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _selectedAudience = value;
          _recipientPreview = null; // Reset preview
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} lúc ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDateTime ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _scheduledDateTime ?? now.add(const Duration(hours: 1)),
        ),
      );

      if (time != null && mounted) {
        setState(() {
          _scheduledDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _previewRecipients() async {
    if (_selectedConferenceId == null) return;

    setState(() {
      _isPreviewLoading = true;
    });

    try {
      final preview = await context.read<AnnouncementProvider>().previewRecipients(
        _selectedConferenceId!,
        _selectedAudience,
      );

      if (mounted) {
        setState(() {
          _recipientPreview = preview;
          _isPreviewLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPreviewLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedChannels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một kênh gửi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final provider = context.read<AnnouncementProvider>();
    
    final success = await provider.createAnnouncement(
      conferenceId: _selectedConferenceId!,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      audience: _selectedAudience,
      channels: _selectedChannels.toList(),
      scheduledAt: _scheduledDateTime,
    );

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tạo thông báo thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

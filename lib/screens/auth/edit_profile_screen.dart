import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  
  // Controllers
  final _fullNameController = TextEditingController();
  final _organizationController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  User? _currentUser;
  int? _selectedFacultyId;
  List<Map<String, dynamic>> _faculties = [];
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadFaculties();
  }
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _organizationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    try {
      await _authService.refreshProfile();
      _currentUser = _authService.currentUser;
      
      if (_currentUser != null) {
        _fullNameController.text = _currentUser!.name;
        _organizationController.text = _currentUser!.organization ?? '';
        _selectedFacultyId = _currentUser!.facultyId;
      }
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải thông tin: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _loadFaculties() async {
    // TODO: Load faculties from API
    // Tạm thời dùng danh sách mẫu
    setState(() {
      _faculties = [
        {'id': 1, 'name': 'Khoa Công nghệ Thông tin'},
        {'id': 2, 'name': 'Khoa Điện tử Viễn thông'},
        {'id': 3, 'name': 'Khoa Cơ khí'},
        {'id': 4, 'name': 'Khoa Điện - Điện tử'},
        {'id': 5, 'name': 'Khoa Quản trị Kinh doanh'},
      ];
    });
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isSaving = true);
    
    try {
      final updateData = <String, dynamic>{
        'full_name': _fullNameController.text.trim(),
      };
      
      if (_organizationController.text.trim().isNotEmpty) {
        updateData['organization'] = _organizationController.text.trim();
      }
      
      if (_selectedFacultyId != null) {
        updateData['faculty_id'] = _selectedFacultyId;
      }
      
      final success = await _authService.updateProfile(updateData);
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        throw Exception('Cập nhật thất bại');
      }
      
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chỉnh sửa thông tin'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar (optional)
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey[600],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // TODO: Implement image picker
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tính năng đang phát triển'),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Email (read-only)
                TextFormField(
                  initialValue: _currentUser?.email ?? '',
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Full name
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Họ và tên',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    if (value.trim().length < 3) {
                      return 'Họ và tên phải có ít nhất 3 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Student type (read-only)
                TextFormField(
                  initialValue: _currentUser?.accountType ?? 'Không xác định',
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Loại tài khoản',
                    prefixIcon: const Icon(Icons.school),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Faculty dropdown
                DropdownButtonFormField<int>(
                  value: _selectedFacultyId,
                  decoration: InputDecoration(
                    labelText: 'Khoa',
                    prefixIcon: const Icon(Icons.business),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _faculties.map((faculty) {
                    return DropdownMenuItem<int>(
                      value: faculty['id'],
                      child: Text(faculty['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFacultyId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Organization
                TextFormField(
                  controller: _organizationController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Cơ quan/Đơn vị',
                    hintText: 'Trường Đại học Công nghiệp TP.HCM',
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Save button
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                
                // Cancel button
                OutlinedButton(
                  onPressed: _isSaving ? null : () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String role; // author, reviewer, admin
  final String? phone;
  final String? organization;
  final String? avatar;
  final DateTime createdAt;
  final bool isStudent; // Sinh viên hay giảng viên
  final int? facultyId; // ID khoa
  final String? facultyName; // Tên khoa (nếu backend trả về)
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.organization,
    this.avatar,
    required this.createdAt,
    this.isStudent = false,
    this.facultyId,
    this.facultyName,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    // Parse faculty info nếu có
    String? facultyName;
    if (json['khoa'] != null) {
      facultyName = json['khoa']['faculty_name']?.toString();
    }
    
    // Parse role từ roles array nếu có
    String role = 'author'; // default
    if (json['roles'] != null && json['roles'] is List && (json['roles'] as List).isNotEmpty) {
      final firstRole = (json['roles'] as List)[0];
      final roleCode = firstRole['role_code']?.toString().toLowerCase() ?? '';
      role = roleCode.toLowerCase(); // Luôn lowercase: chair, reviewer, author
    } else if (json['role'] != null) {
      role = json['role'].toString().toLowerCase();
    }
    
    return User(
      id: (json['user_id'] ?? json['id'])?.toString() ?? '',
      name: (json['full_name'] ?? json['name'])?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: role,
      phone: json['phone']?.toString(),
      organization: json['organization']?.toString(),
      avatar: json['avatar']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      isStudent: json['is_student'] == true || json['is_student']?.toString() == '1',
      facultyId: json['faculty_id'] != null ? int.tryParse(json['faculty_id'].toString()) : null,
      facultyName: facultyName,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'organization': organization,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'is_student': isStudent,
      'faculty_id': facultyId,
    };
  }
  
  String get roleVietnamese {
    switch (role.toLowerCase()) {
      case 'author':
        return 'Tác giả';
      case 'reviewer':
        return 'Phản biện viên';
      case 'chair':
        return 'Chủ tịch';
      case 'admin':
        return 'Quản trị viên';
      default:
        return 'Không xác định';
    }
  }
  
  String get initials {
    print('🔤 Calculating initials for: "$name"');
    
    if (name.isEmpty) {
      print('   ❌ Name is empty, returning NA');
      return 'NA';
    }
    
    final names = name.trim().split(' ').where((n) => n.isNotEmpty).toList();
    print('   📝 Split names: $names');
    
    if (names.isEmpty) {
      print('   ❌ No valid names, returning NA');
      return 'NA';
    }
    
    if (names.length >= 2) {
      // Lấy chữ cái đầu của từ đầu và từ cuối
      final result = '${names.first[0]}${names.last[0]}'.toUpperCase();
      print('   ✅ Result (first+last): $result');
      return result;
    }
    
    // Nếu chỉ có 1 từ, lấy 1-2 ký tự đầu
    if (names[0].length >= 2) {
      final result = names[0].substring(0, 2).toUpperCase();
      print('   ✅ Result (2 chars): $result');
      return result;
    }
    
    final result = names[0][0].toUpperCase();
    print('   ✅ Result (1 char): $result');
    return result;
  }
  
  // Getters tiện ích
  String get accountType => isStudent ? 'Sinh viên' : 'Giảng viên';
  
  // Mock users
  static User getMockAuthor() {
    return User(
      id: '1',
      name: 'Nguyễn Văn A',
      email: 'author@huit.edu.vn',
      role: 'author',
      organization: 'HUIT',
      createdAt: DateTime.now(),
      isStudent: true,
      facultyId: 1,
      facultyName: 'Khoa Công nghệ Thông tin',
    );
  }
  
  static User getMockReviewer() {
    return User(
      id: '2',
      name: 'TS. Nguyễn Văn B',
      email: 'reviewer@huit.edu.vn',
      role: 'reviewer',
      organization: 'HUIT',
      createdAt: DateTime.now(),
      isStudent: false,
      facultyId: 1,
      facultyName: 'Khoa Công nghệ Thông tin',
    );
  }
  
  static User getMockAdmin() {
    return User(
      id: '3',
      name: 'Admin',
      email: 'admin@huit.edu.vn',
      role: 'admin',
      organization: 'HUIT',
      createdAt: DateTime.now(),
      isStudent: false,
    );
  }
}
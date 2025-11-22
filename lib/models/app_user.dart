class AppUser {
  final int userId;
  final String email;
  final String fullName;
  final String? phone;
  final String? organization;
  final String? avatar;

  AppUser({
    required this.userId,
    required this.email,
    required this.fullName,
    this.phone,
    this.organization,
    this.avatar,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      userId: int.tryParse(json['user_id']?.toString() ?? json['id']?.toString() ?? '0') ?? 
              (json['user_id'] is int ? json['user_id'] : 0),
      email: json['email'] as String,
      fullName: json['full_name'] as String? ?? json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      organization: json['organization'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'organization': organization,
      'avatar': avatar,
    };
  }

  /// Get initials for avatar
  String get initials {
    if (fullName.isEmpty) return 'NA';
    
    final names = fullName.trim().split(' ').where((n) => n.isNotEmpty).toList();
    
    if (names.isEmpty) return 'NA';
    
    if (names.length >= 2) {
      return '${names.first[0]}${names.last[0]}'.toUpperCase();
    }
    
    if (names[0].length >= 2) {
      return names[0].substring(0, 2).toUpperCase();
    }
    
    return names[0][0].toUpperCase();
  }

  @override
  String toString() {
    return 'AppUser(userId: $userId, email: $email, fullName: $fullName)';
  }
}

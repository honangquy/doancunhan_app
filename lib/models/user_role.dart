class UserRole {
  final String roleCode;        // role_code: ADMIN, CHAIR, REVIEWER, AUTHOR
  final int? conferenceId;      // conference_id (nullable)
  final String? conferenceTitle; // conference_title

  UserRole({
    required this.roleCode,
    this.conferenceId,
    this.conferenceTitle,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      roleCode: json['role_code'] as String,
      conferenceId: json['conference_id'] != null 
          ? (json['conference_id'] is int 
              ? json['conference_id'] 
              : int.tryParse(json['conference_id'].toString()))
          : null,
      conferenceTitle: json['conference_title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_code': roleCode,
      'conference_id': conferenceId,
      'conference_title': conferenceTitle,
    };
  }

  /// Mapping role code to Vietnamese display name
  String get displayName {
    switch (roleCode.toUpperCase()) {
      case 'ADMIN':
        return 'Quản trị viên';
      case 'CHAIR':
        return 'Chủ tịch hội thảo';
      case 'REVIEWER':
        return 'Phản biện viên';
      case 'AUTHOR':
        return 'Tác giả';
      case 'PC':
        return 'Ban chương trình';
      default:
        return roleCode;
    }
  }

  /// Get scope description
  String get scopeDescription {
    if (conferenceId != null && conferenceTitle != null) {
      return 'Hội thảo: $conferenceTitle';
    }
    return 'Phạm vi: Toàn hệ thống';
  }

  /// Get icon for role
  String get icon {
    switch (roleCode.toUpperCase()) {
      case 'ADMIN':
        return '👨‍💼';
      case 'CHAIR':
        return '🎯';
      case 'REVIEWER':
        return '📝';
      case 'AUTHOR':
        return '✍️';
      case 'PC':
        return '👥';
      default:
        return '👤';
    }
  }

  @override
  String toString() {
    return 'UserRole(roleCode: $roleCode, conferenceId: $conferenceId, conferenceTitle: $conferenceTitle)';
  }
}

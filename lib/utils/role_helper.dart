/// Helper functions for role management and routing

/// Get dashboard route based on user role
String getDashboardRouteByRole(String? role) {
  if (role == null || role.isEmpty) {
    return '/author/dashboard'; // Default route
  }
  
  final lowerRole = role.toLowerCase();
  
  // CHAIR role -> Chair Dashboard
  if (lowerRole == 'chair') {
    return '/chair/dashboard';
  }
  
  // REVIEWER role -> Reviewer Dashboard
  if (lowerRole == 'reviewer') {
    return '/reviewer/dashboard';
  }
  
  // AUTHOR role or any other -> Author Dashboard
  return '/author/dashboard';
}

/// Check if user has chair privileges
bool isChair(String? role) {
  if (role == null || role.isEmpty) return false;
  final lowerRole = role.toLowerCase();
  return lowerRole == 'chair';
}

/// Check if user is a reviewer
bool isReviewer(String? role) {
  if (role == null || role.isEmpty) return false;
  return role.toLowerCase() == 'reviewer';
}

/// Check if user is an author
bool isAuthor(String? role) {
  if (role == null || role.isEmpty) return true; // Default
  return role.toLowerCase() == 'author';
}

/// Get role display name in Vietnamese
String getRoleDisplayName(String? role) {
  if (role == null || role.isEmpty) return 'Tác giả';
  
  final lowerRole = role.toLowerCase();
  
  switch (lowerRole) {
    case 'chair':
    case 'admin':
      return 'Chủ tọa';
    case 'reviewer':
      return 'Phản biện';
    case 'author':
      return 'Tác giả';
    default:
      return 'Tác giả';
  }
}

/// Get role color
String getRoleColor(String? role) {
  if (role == null || role.isEmpty) return '#4CAF50'; // Green for author
  
  final lowerRole = role.toLowerCase();
  
  switch (lowerRole) {
    case 'chair':
    case 'admin':
      return '#F44336'; // Red for admin
    case 'reviewer':
      return '#2196F3'; // Blue for reviewer
    case 'author':
      return '#4CAF50'; // Green for author
    default:
      return '#4CAF50';
  }
}

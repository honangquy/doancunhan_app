import 'lib/utils/role_helper.dart';

void main() {
  print('🧪 Testing Role Helper Functions\n');
  
  // Test roles
  final testRoles = ['CHAIR', 'chair', 'ADMIN', 'admin', 'REVIEWER', 'reviewer', 'AUTHOR', 'author', null, ''];
  
  print('📍 Testing getDashboardRouteByRole:');
  for (var role in testRoles) {
    final route = getDashboardRouteByRole(role);
    print('  Role: ${role ?? "null"} -> Route: $route');
  }
  
  print('\n👨‍💼 Testing isAdmin:');
  for (var role in testRoles) {
    final result = isAdmin(role);
    print('  Role: ${role ?? "null"} -> isAdmin: $result');
  }
  
  print('\n📝 Testing isReviewer:');
  for (var role in testRoles) {
    final result = isReviewer(role);
    print('  Role: ${role ?? "null"} -> isReviewer: $result');
  }
  
  print('\n✍️ Testing isAuthor:');
  for (var role in testRoles) {
    final result = isAuthor(role);
    print('  Role: ${role ?? "null"} -> isAuthor: $result');
  }
  
  print('\n🏷️ Testing getRoleDisplayName:');
  for (var role in testRoles) {
    final displayName = getRoleDisplayName(role);
    print('  Role: ${role ?? "null"} -> Display: $displayName');
  }
  
  print('\n🎨 Testing getRoleColor:');
  for (var role in testRoles) {
    final color = getRoleColor(role);
    print('  Role: ${role ?? "null"} -> Color: $color');
  }
  
  print('\n✅ All tests completed!');
}

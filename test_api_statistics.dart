import 'package:dio/dio.dart';
import 'lib/services/storage_service.dart';

void main() async {
  print('🧪 Testing API Statistics Endpoints...\n');
  
  // Initialize storage to get token
  final storage = StorageService();
  await storage.init();
  
  final token = await storage.getString('auth_token');
  if (token == null) {
    print('❌ No auth token found! Please login first.');
    return;
  }
  
  print('✅ Token found: ${token.substring(0, 20)}...\n');
  
  // Create Dio instance
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  ));
  
  try {
    // Test 1: Papers Statistics
    print('📊 Testing GET /api/papers/statistics...');
    final statsResponse = await dio.get('/api/papers/statistics');
    print('Status: ${statsResponse.statusCode}');
    print('Response Data: ${statsResponse.data}');
    print('');
    
    // Test 2: My Papers
    print('📄 Testing GET /api/my-papers...');
    final papersResponse = await dio.get('/api/my-papers');
    print('Status: ${papersResponse.statusCode}');
    print('Response Data: ${papersResponse.data}');
    print('');
    
    // Analyze the structure
    print('🔍 Analyzing response structure...');
    
    if (statsResponse.data is Map) {
      final statsData = statsResponse.data as Map;
      print('\nStats Response Keys: ${statsData.keys.toList()}');
      
      if (statsData.containsKey('data')) {
        print('Has "data" key: ${statsData['data']}');
      }
      if (statsData.containsKey('total_papers')) {
        print('Has "total_papers" key: ${statsData['total_papers']}');
      }
      if (statsData.containsKey('by_status')) {
        print('Has "by_status" key: ${statsData['by_status']}');
      }
    }
    
    if (papersResponse.data is Map) {
      final papersData = papersResponse.data as Map;
      print('\nPapers Response Keys: ${papersData.keys.toList()}');
      
      if (papersData.containsKey('data')) {
        print('Has "data" key, type: ${papersData['data'].runtimeType}');
        if (papersData['data'] is List) {
          print('Data is a List with ${(papersData['data'] as List).length} items');
        }
      }
      if (papersData.containsKey('papers')) {
        print('Has "papers" key, type: ${papersData['papers'].runtimeType}');
        if (papersData['papers'] is List) {
          print('Papers is a List with ${(papersData['papers'] as List).length} items');
        }
      }
    }
    
  } catch (e) {
    print('❌ Error: $e');
    if (e is DioException) {
      print('Status Code: ${e.response?.statusCode}');
      print('Response: ${e.response?.data}');
    }
  }
}

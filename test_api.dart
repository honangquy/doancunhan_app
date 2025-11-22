import 'dart:convert';
import 'dart:io';

void main() async {
  print('Testing login API...');
  
  final url = 'http://127.0.0.1:8000/api/auth/login';
  final client = HttpClient();
  
  try {
    final request = await client.postUrl(Uri.parse(url));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    
    final body = jsonEncode({
      'email': 'honangquy1@gmail.com',
      'password': 'Concac123!@#',
    });
    
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('\n📡 Status Code: ${response.statusCode}');
    print('📦 Response Body:');
    print(responseBody);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      print('\n✅ Parsed JSON:');
      print(JsonEncoder.withIndent('  ').convert(data));
      
      print('\n🔍 Analysis:');
      print('Has "success" field: ${data.containsKey('success')}');
      if (data.containsKey('success')) {
        print('  Value: ${data['success']}');
      }
      print('Has "token" field: ${data.containsKey('token')}');
      if (data.containsKey('token')) {
        print('  Token: ${data['token'].toString().substring(0, 20)}...');
      }
      print('Has "user" field: ${data.containsKey('user')}');
      if (data.containsKey('user')) {
        print('  User: ${data['user']}');
      }
    }
    
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}

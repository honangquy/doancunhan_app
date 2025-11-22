import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_config.dart';
import '../utils/auth_error_handler.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  late Dio _dio;
  late CookieJar _cookieJar;
  Dio get dio => _dio;

  Future<void> init() async {
    // Initialize cookie jar for Laravel session
    _cookieJar = CookieJar();
    
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: ApiConfig.defaultHeaders,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(CookieManager(_cookieJar)); // Handle Laravel session cookies
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: true,
      responseHeader: false,
    ));
  }
}

/// Interceptor to add Bearer token to requests
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from storage
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConfig.tokenKey);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      print('🔑 [AuthInterceptor] Token added to request: ${token.substring(0, 20)}...');
    } else {
      print('⚠️  [AuthInterceptor] No token found in storage');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      print('❌ [AuthInterceptor] 401 Unauthorized detected');
      print('   URL: ${err.requestOptions.uri}');
      print('   Method: ${err.requestOptions.method}');
      
      // Clear ALL auth-related data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConfig.tokenKey);
      await prefs.remove(ApiConfig.userKey);
      await prefs.remove('app_user');
      await prefs.remove('user_roles');
      await prefs.remove('current_role');
      
      print('🔐 [AuthInterceptor] Auth data cleared - User needs to login again');
    }

    handler.next(err);
  }
}

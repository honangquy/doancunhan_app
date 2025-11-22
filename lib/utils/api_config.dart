class ApiConfig {
  // Environment configuration
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',  // Simulator dùng localhost
  );

  // Base URLs for different environments (theo FLUTTER_API_GUIDE.md)
  static const Map<String, String> _baseUrls = {
    // Local development - Laravel API backend
    // ⚠️ Khi test trên iPhone thật, thay 127.0.0.1 bằng IP máy Mac (ví dụ: 192.168.1.100)
    // Để lấy IP: chạy 'ipconfig getifaddr en0' trong terminal
    'development': 'http://127.0.0.1:8000/api',  // Simulator - dùng 127.0.0.1 thay vì localhost
    'device': 'http://192.168.1.2:8000/api',     // iPhone thật - THAY 192.168.1.100
    
    // Staging/Production (update when deploying)
    'staging': 'https://staging-api.huit-conference.com/api',
    'production': 'https://api.huit-conference.com/api',
  };

  // Get current base URL
  static String get baseUrl => _baseUrls[environment] ?? _baseUrls['development']!;

  // API Endpoints - Laravel Sanctum (theo FLUTTER_API_GUIDE.md)
  // Auth endpoints (Bearer Token authentication)
  static const String authLogin = '/auth/login';           // POST /api/auth/login
  static const String authLogout = '/auth/logout';         // POST /api/auth/logout
  static const String authRegister = '/auth/register';     // POST /api/auth/register
  static const String authProfile = '/auth/profile';       // GET /api/auth/profile
  static const String authRefresh = '/auth/refresh';       // POST /api/auth/refresh
  static const String authChangePassword = '/auth/change-password'; // POST

  // Conference endpoints (relative paths, baseUrl đã có /api)
  static const String conferences = '/conferences';
  static const String myConferences = '/my-conferences';

  // Paper endpoints
  static const String papers = '/papers';
  static const String myPapers = '/my-papers';

  // Review endpoints
  static const String reviews = '/reviews';
  static const String myReviews = '/my-reviews';

  // Assignment endpoints
  static const String assignments = '/assignments';
  static const String myAssignments = '/my-assignments';

  // Announcement endpoints (chưa có trong API routes, sẽ dùng notifications)
  static const String announcements = '/notifications';

  // Admin endpoints
  static const String adminUsers = '/admin/users';
  static const String adminStatistics = '/admin/reports/overview';

  // Notifications
  static const String notifications = '/notifications';

  // Health check
  static const String health = '/health';

  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';
}

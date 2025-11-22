# 🔌 API Integration Guide

## 📋 Tổng Quan

App đã được tích hợp với **HUIT Conferences API** (backend Laravel). File Postman collection đầy đủ: `HUIT-Conferences-API-Complete.postman_collection.json`

---

## 🌐 Cấu Hình API

### **Base URLs**

File: `lib/utils/api_config.dart`

```dart
- Development: http://localhost:8000
- Staging: https://staging-api.huit-conference.com
- Production: https://api.huit-conference.com
```

### **Đổi Environment**

Chạy app với environment khác nhau:

```bash
# Development (default)
flutter run

# Staging
flutter run --dart-define=ENVIRONMENT=staging

# Production
flutter run --dart-define=ENVIRONMENT=production
```

---

## 🔐 Authentication

### **Login Flow**

1. User nhập email/password trong `LoginScreen`
2. Call `AuthService().login(email, password)`
3. API trả về `{ "token": "...", "user": {...} }`
4. Token được lưu vào `SharedPreferences`
5. HTTP interceptor tự động thêm `Bearer {token}` vào mọi request

### **Token Storage**

- **Key:** `auth_token`
- **Location:** SharedPreferences
- **Auto-inject:** `AuthInterceptor` trong `http_client.dart`

### **Test Credentials**

```
Admin:
- Email: admin@huit.edu.vn
- Password: password

Reviewer:
- Email: reviewer@huit.edu.vn  
- Password: password

Author:
- Email: author@huit.edu.vn
- Password: password
```

---

## 📡 API Endpoints

### **Authentication**
```
POST   /api/auth/register       - Đăng ký
POST   /api/auth/login          - Đăng nhập
POST   /api/auth/logout         - Đăng xuất
GET    /api/auth/profile        - Lấy profile
PUT    /api/auth/profile        - Cập nhật profile
```

### **Conferences**
```
GET    /api/conferences         - Danh sách hội thảo
GET    /api/conferences/{id}    - Chi tiết hội thảo
GET    /api/my-conferences      - Hội thảo của tôi
POST   /api/conferences         - Tạo hội thảo (admin)
PUT    /api/conferences/{id}    - Cập nhật (admin)
DELETE /api/conferences/{id}    - Xóa (admin)
```

### **Papers**
```
GET    /api/papers              - Danh sách bài báo
GET    /api/papers/{id}         - Chi tiết bài báo
GET    /api/my-papers           - Bài báo của tôi
POST   /api/papers              - Nộp bài (multipart/form-data)
PUT    /api/papers/{id}         - Cập nhật bài
GET    /api/papers/{id}/download - Tải file PDF
```

### **Reviews**
```
GET    /api/reviews             - Danh sách review
GET    /api/my-reviews          - Review của tôi
POST   /api/reviews             - Submit review
PUT    /api/reviews/{id}        - Cập nhật review
```

### **Assignments** (Reviewer)
```
GET    /api/assignments         - Danh sách assignments
GET    /api/my-assignments      - Assignments của tôi
POST   /api/assignments         - Assign reviewer (admin)
PUT    /api/assignments/{id}/accept - Chấp nhận assignment
DELETE /api/assignments/{id}    - Xóa assignment (admin)
```

### **Announcements**
```
GET    /api/announcements       - Danh sách thông báo
POST   /api/announcements       - Đăng thông báo (admin)
PUT    /api/announcements/{id}  - Cập nhật (admin)
DELETE /api/announcements/{id}  - Xóa (admin)
```

### **Admin**
```
GET    /api/admin/users         - Danh sách users
PUT    /api/admin/users/{id}    - Cập nhật user
POST   /api/admin/users/{id}/roles - Quản lý roles
GET    /api/admin/statistics    - Thống kê tổng quan
```

### **Notifications**
```
GET    /api/notifications       - Danh sách thông báo
PATCH  /api/notifications/read-all - Đánh dấu đã đọc
```

---

## 🛠️ Sử Dụng API Service

### **Import**
```dart
import 'package:huit_conference_app/services/api_service.dart';
import 'package:huit_conference_app/services/auth_service.dart';
```

### **Authentication**
```dart
final auth = AuthService();

// Login
final result = await auth.login(
  email: 'user@example.com',
  password: 'password123',
);

if (result['success']) {
  print('Logged in as: ${auth.userName}');
}

// Logout
await auth.logout();
```

### **Fetch Data**
```dart
final api = ApiService();
await api.init();

// Get papers
List<Paper> papers = await api.getPapers(
  conferenceId: 1,
  status: 'approved',
);

// Get my papers
List<Paper> myPapers = await api.getMyPapers();

// Submit paper
Paper newPaper = await api.submitPaper(
  conferenceId: 1,
  title: 'My Research',
  abstract: 'Abstract here...',
  keywords: 'AI, ML, DL',
  filePath: '/path/to/paper.pdf',
);
```

### **Error Handling**
```dart
try {
  final papers = await api.getPapers();
} catch (e) {
  print('Error: $e');
  // API service automatically falls back to mock data
}
```

---

## 🔄 Migration từ Mock Data

### **Cũ (Mock)**
```dart
// Old way - returns mock data
final papers = Paper.getMockPapers();
```

### **Mới (Real API)**
```dart
// New way - fetches from backend
final api = ApiService();
await api.init();
final papers = await api.getPapers();
```

### **Fallback Strategy**

API Service tự động fallback về mock data khi:
- Backend không khả dụng
- Network error
- Timeout

```dart
Future<List<Paper>> getPapers() async {
  try {
    // Try to fetch from API
    return await _fetchFromBackend();
  } catch (e) {
    // Fallback to mock data
    return Paper.getMockPapers();
  }
}
```

---

## 📦 Files Structure

```
lib/
├── services/
│   ├── api_service.dart        # ✅ NEW - Real API calls
│   ├── auth_service.dart       # ✅ NEW - Real auth with token
│   ├── http_client.dart        # ✅ NEW - Dio client + interceptor
│   ├── api_service.old.dart    # 📦 Backup - Old mock version
│   └── auth_service.old.dart   # 📦 Backup - Old mock version
├── utils/
│   └── api_config.dart         # ✅ NEW - API constants & config
└── models/
    ├── user.dart
    ├── paper.dart
    └── announcement.dart       # ✅ UPDATED
```

---

## 🧪 Testing

### **1. Health Check**
```dart
final api = ApiService();
bool isHealthy = await api.healthCheck();
print('API is ${isHealthy ? "UP" : "DOWN"}');
```

### **2. Test Login**
```dart
final auth = AuthService();
await auth.init();

final result = await auth.login(
  email: 'admin@huit.edu.vn',
  password: 'password',
);

print('Login: ${result['success']}');
print('Token: ${auth.token}');
```

### **3. Run Backend Locally**

Nếu chưa có backend running:

```bash
# Clone backend repo (nếu có)
git clone <backend-repo-url>
cd huit-conferences-backend

# Install dependencies
composer install

# Setup database
php artisan migrate --seed

# Run server
php artisan serve
# Backend sẽ chạy ở http://localhost:8000
```

### **4. Import Postman Collection**

1. Mở Postman
2. Import file: `HUIT-Conferences-API-Complete.postman_collection.json`
3. Set variable `base_url` = `http://localhost:8000`
4. Test các endpoints

---

## ⚙️ Configuration

### **Timeout Settings**

File: `lib/utils/api_config.dart`

```dart
static const Duration connectTimeout = Duration(seconds: 30);
static const Duration receiveTimeout = Duration(seconds: 30);
static const Duration sendTimeout = Duration(seconds: 30);
```

### **Enable/Disable Logging**

File: `lib/services/http_client.dart`

```dart
_dio.interceptors.add(LogInterceptor(
  requestBody: true,      // Log request body
  responseBody: true,     // Log response body
  error: true,           // Log errors
  requestHeader: true,   // Log headers
  responseHeader: false, // Don't log response headers
));
```

---

## 🐛 Troubleshooting

### **"Connection refused" Error**

```
✅ Giải pháp:
1. Kiểm tra backend có đang chạy không
2. Kiểm tra base URL đúng không
3. Thử health check endpoint
```

### **"401 Unauthorized" Error**

```
✅ Giải pháp:
1. Token hết hạn → Login lại
2. Token không hợp lệ → Xóa app data và login lại
3. Kiểm tra Bearer token trong request header
```

### **Mock Data Still Showing**

```
✅ Giải pháp:
1. API service có fallback về mock khi lỗi
2. Check console logs xem API call có thành công không
3. Verify backend response format khớp với model
```

---

## 📝 TODO

- [ ] Implement token refresh mechanism
- [ ] Add retry logic for failed requests
- [ ] Implement offline mode with local cache
- [ ] Add request queue for offline submissions
- [ ] Implement push notifications
- [ ] Add file upload progress indicator

---

**Last Updated:** 3/11/2025  
**API Version:** 1.0  
**Backend:** Laravel + MySQL

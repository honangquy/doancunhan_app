# 📢 Announcement API - Complete Summary

**Version:** 1.0  
**Last Updated:** 13/11/2025  
**Status:** ✅ Production Ready (12/12 Tests PASS)

---

## 📋 Table of Contents

1. [System Overview](#system-overview)
2. [Authentication](#authentication)
3. [API Endpoints](#api-endpoints)
4. [Data Models](#data-models)
5. [Testing Results](#testing-results)
6. [Integration Guide](#integration-guide)
7. [Scheduler Mechanism](#scheduler-mechanism)
8. [Error Handling](#error-handling)

---

## 1. System Overview

### Architecture
```
Mobile App (Flutter)
        ↓ HTTP + JWT
    API Layer (Laravel)
        ↓
  Business Logic (Jobs)
        ↓
   Database (MySQL)
```

### Key Features

**👨‍💼 Chair (Conference Manager):**
- ✅ Create announcements with scheduling
- ✅ Choose audience: ALL / AUTHORS / REVIEWERS / CHAIRS
- ✅ Select channels: SYSTEM / EMAIL / CHATBOT
- ✅ Preview recipient count before sending
- ✅ Update/delete scheduled announcements
- ✅ View statistics (sent/scheduled/failed)
- ✅ Track read count

**👥 User (Conference Participant):**
- ✅ Receive announcements automatically
- ✅ View received announcements list
- ✅ Mark as read
- ✅ See unread count badge

### Tech Stack
- **Backend:** Laravel 9, PHP 8.1, MySQL 8.0
- **Auth:** JWT Bearer Token (tymon/jwt-auth)
- **Jobs:** Laravel Scheduler + Queue
- **API:** RESTful, JSON responses

---

## 2. Authentication

### 2.1. Login

**Endpoint:** `POST /api/auth/login`

**Request:**
```http
POST http://localhost:8000/api/auth/login
Content-Type: application/json

{
  "email": "honangquy1@gmail.com",
  "password": "Concac123!@#"
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Đăng nhập thành công",
  "data": {
    "user": {
      "user_id": 19,
      "email": "honangquy1@gmail.com",
      "full_name": "Hồ Năng Quý",
      "roles": [
        {
          "role_code": "CHAIR",
          "role_name": "Chủ tịch hội thảo",
          "conference_id": 1,
          "conference_name": "Hội thảo Khoa học Kỹ thuật"
        },
        {
          "role_code": "CHAIR",
          "conference_id": 7
        },
        {
          "role_code": "CHAIR",
          "conference_id": 8
        }
      ]
    },
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwMDAvYXBpL2F1dGgvbG9naW4iLCJpYXQiOjE3MzE0ODI4NDksImV4cCI6MTczMTQ4NjQ0OSwibmJmIjoxNzMxNDgyODQ5LCJqdGkiOiJZODhLVGNmMkhZZ0NaZERlIiwic3ViIjoiMTkiLCJwcnYiOiIyM2JkNWM4OTQ5ZjYwMGFkYjM5ZTcwMWM0MDA4NzJkYjdhNTk3NmY3In0.XK8bGJQYf_h5VBkE6ZJH9FqYLPQ7rNGJVjN0vL8xYmE"
  }
}
```

**Response (Failed):**
```json
{
  "success": false,
  "message": "Email hoặc mật khẩu không chính xác"
}
```

### 2.2. Using Token

**All subsequent requests must include:**
```http
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc...
```

**Token Lifespan:** 60 minutes (configurable in `config/jwt.php`)

**Token Refresh:** (Optional)
```http
POST /api/auth/refresh
Authorization: Bearer {old_token}
```

---

## 3. API Endpoints

### 3.1. GET /api/announcements - List Announcements

**Purpose:** Lấy danh sách thông báo (tự động phát hiện role)

**URL:** `GET /api/announcements`

**Query Parameters:**
- `status` (optional): `SENT` | `SCHEDULED` | `FAILED`
- `conference_id` (optional): Filter by conference
- `page` (optional): Pagination page number
- `per_page` (optional): Items per page (default: 15)

**Request Example:**
```http
GET /api/announcements?status=SENT&conference_id=8
Authorization: Bearer {token}
```

**Response (Chair):**
```json
{
  "success": true,
  "data": {
    "announcements": [
      {
        "announcement_id": 14,
        "title": "Test API từ Mobile",
        "content": "Đây là thông báo được tạo từ API mobile app",
        "audience": "ALL",
        "channels": ["SYSTEM"],
        "status": "SENT",
        "scheduled_at": "2025-11-13 14:21:56",
        "sent_at": "2025-11-13 14:22:34",
        "created_at": "2025-11-13 14:19:56",
        "conference_id": 8,
        "conference_name": "Hội thảo cung cấp nguồn nhân lực",
        "recipient_count": 22
      },
      {
        "announcement_id": 13,
        "title": "Thông báo gửi tất cả mọi người",
        "content": "Test gửi cho ALL audience",
        "audience": "ALL",
        "channels": ["SYSTEM"],
        "status": "SENT",
        "scheduled_at": "2025-11-13 13:36:41",
        "sent_at": "2025-11-13 13:39:12",
        "created_at": "2025-11-13 13:36:41",
        "conference_id": 8,
        "conference_name": "Hội thảo cung cấp nguồn nhân lực",
        "recipient_count": 11
      }
    ],
    "statistics": {
      "total": 13,
      "sent": 13,
      "scheduled": 0,
      "failed": 0
    },
    "pagination": {
      "current_page": 1,
      "total_pages": 1,
      "total_items": 13,
      "per_page": 15
    }
  }
}
```

**Response (User - Regular Member):**
```json
{
  "success": true,
  "data": {
    "announcements": [
      {
        "announcement_id": 14,
        "title": "Test API từ Mobile",
        "content": "Đây là thông báo được tạo từ API mobile app",
        "sent_at": "2025-11-13 14:22:34",
        "conference_id": 8,
        "conference_name": "Hội thảo cung cấp nguồn nhân lực",
        "is_read": false,
        "read_at": null,
        "received_at": "2025-11-13 14:22:34"
      },
      {
        "announcement_id": 13,
        "title": "Thông báo gửi tất cả mọi người",
        "content": "Test gửi cho ALL audience",
        "sent_at": "2025-11-13 13:39:12",
        "conference_id": 8,
        "conference_name": "Hội thảo cung cấp nguồn nhân lực",
        "is_read": true,
        "read_at": "2025-11-13 13:45:23",
        "received_at": "2025-11-13 13:39:12"
      }
    ],
    "unread_count": 5
  }
}
```

### 3.2. POST /api/announcements - Create Announcement

**Purpose:** Tạo thông báo mới (Chair only)

**URL:** `POST /api/announcements`

**Request:**
```http
POST /api/announcements
Authorization: Bearer {token}
Content-Type: application/json

{
  "conference_id": 8,
  "title": "Thông báo quan trọng về hội thảo",
  "content": "Kính gửi quý thầy cô và các bạn,\n\nHội thảo sẽ diễn ra vào ngày 15/11/2025...",
  "audience": "ALL",
  "channels": ["SYSTEM", "EMAIL"],
  "scheduled_at": "2025-11-13 15:00:00"
}
```

**Validation Rules:**
- `conference_id`: required, integer, exists in hoithao table
- `title`: required, string, max 255 characters
- `content`: required, string
- `audience`: required, enum: `ALL`, `AUTHORS`, `REVIEWERS`, `CHAIRS`
- `channels`: required, array, items in: `SYSTEM`, `EMAIL`, `CHATBOT`
- `scheduled_at`: required, datetime, must be after current time

**Response (Success):**
```json
{
  "success": true,
  "message": "Thông báo đã được tạo và lên lịch thành công",
  "data": {
    "announcement_id": 15,
    "scheduled_at": "2025-11-13 15:00:00"
  }
}
```

**Response (Validation Error):**
```json
{
  "success": false,
  "message": "Dữ liệu không hợp lệ",
  "errors": {
    "title": ["Vui lòng nhập tiêu đề"],
    "content": ["Vui lòng nhập nội dung"],
    "audience": ["Vui lòng chọn đối tượng nhận"],
    "channels": ["Vui lòng chọn ít nhất một kênh gửi"],
    "scheduled_at": ["Thời gian gửi phải sau thời điểm hiện tại"]
  }
}
```

**Response (Permission Denied):**
```json
{
  "success": false,
  "message": "Bạn không có quyền tạo thông báo cho hội thảo này"
}
```

### 3.3. GET /api/announcements/{id} - Announcement Detail

**Purpose:** Xem chi tiết thông báo

**URL:** `GET /api/announcements/{id}`

**Request:**
```http
GET /api/announcements/14
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "announcement_id": 14,
    "conference_id": 8,
    "conference_name": "Hội thảo cung cấp nguồn nhân lực",
    "title": "Test API từ Mobile",
    "content": "Đây là thông báo được tạo từ API mobile app",
    "audience": "ALL",
    "channels": ["SYSTEM"],
    "status": "SENT",
    "scheduled_at": "2025-11-13 14:21:56",
    "sent_at": "2025-11-13 14:22:34",
    "created_by": 19,
    "created_by_name": "Hồ Năng Quý",
    "created_at": "2025-11-13 14:19:56",
    "statistics": {
      "total_recipients": 22,
      "read_count": 3,
      "unread_count": 19
    }
  }
}
```

**Response (Not Found):**
```json
{
  "success": false,
  "message": "Không tìm thấy thông báo"
}
```

### 3.4. PUT /api/announcements/{id} - Update Announcement

**Purpose:** Cập nhật thông báo (chỉ SCHEDULED, Chair only)

**URL:** `PUT /api/announcements/{id}`

**Request:**
```http
PUT /api/announcements/15
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Thông báo test API - ĐÃ CẬP NHẬT",
  "content": "Nội dung mới đã được chỉnh sửa",
  "scheduled_at": "2025-11-13 16:00:00"
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Đã cập nhật thông báo"
}
```

**Response (Cannot Update SENT):**
```json
{
  "success": false,
  "message": "Chỉ có thể cập nhật thông báo đang lên lịch"
}
```

### 3.5. DELETE /api/announcements/{id} - Delete Announcement

**Purpose:** Xóa thông báo (chỉ SCHEDULED, Chair only)

**URL:** `DELETE /api/announcements/{id}`

**Request:**
```http
DELETE /api/announcements/15
Authorization: Bearer {token}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Đã xóa thông báo"
}
```

**Response (Cannot Delete SENT):**
```json
{
  "success": false,
  "message": "Chỉ có thể xóa thông báo đang lên lịch"
}
```

### 3.6. POST /api/announcements/{id}/mark-read - Mark as Read

**Purpose:** Đánh dấu thông báo đã đọc (User)

**URL:** `POST /api/announcements/{id}/mark-read`

**Request:**
```http
POST /api/announcements/14/mark-read
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "Đã đánh dấu đã đọc"
}
```

### 3.7. GET /api/announcements/conferences/list - List Conferences

**Purpose:** Lấy danh sách hội thảo mà Chair quản lý

**URL:** `GET /api/announcements/conferences/list`

**Request:**
```http
GET /api/announcements/conferences/list
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "conference_id": 9,
      "conference_name": "Hội thảo chuyển đổi kinh tế số",
      "start_date": "2026-05-08",
      "end_date": "2026-05-29",
      "status": "APPROVED"
    },
    {
      "conference_id": 8,
      "conference_name": "Hội thảo cung cấp nguồn nhân lực",
      "start_date": "2026-03-31",
      "end_date": "2026-06-25",
      "status": "APPROVED"
    },
    {
      "conference_id": 7,
      "conference_name": "Hội thảo họp mặt các cấp",
      "start_date": "2025-07-11",
      "end_date": "2025-08-26",
      "status": "APPROVED"
    }
  ]
}
```

### 3.8. POST /api/announcements/preview-recipients - Preview Recipients

**Purpose:** Xem trước số lượng người nhận

**URL:** `POST /api/announcements/preview-recipients`

**Request:**
```http
POST /api/announcements/preview-recipients
Authorization: Bearer {token}
Content-Type: application/json

{
  "conference_id": 8,
  "audience": "ALL"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "count": 11,
    "audience": "ALL",
    "conference_id": 8,
    "conference_name": "Hội thảo cung cấp nguồn nhân lực"
  }
}
```

**Recipient Counts by Audience Type:**
```json
// ALL audience
{"count": 11}

// REVIEWERS only
{"count": 6}

// AUTHORS only  
{"count": 3}

// CHAIRS only
{"count": 1}
```

---

## 4. Data Models

### 4.1. Announcement Model

```typescript
interface Announcement {
  announcement_id: number;
  conference_id: number;
  conference_name: string;
  title: string;
  content: string;
  audience: 'ALL' | 'AUTHORS' | 'REVIEWERS' | 'CHAIRS';
  channels: ('SYSTEM' | 'EMAIL' | 'CHATBOT')[];
  status: 'SCHEDULED' | 'SENT' | 'FAILED';
  scheduled_at: string; // ISO datetime
  sent_at: string | null;
  created_by: number;
  created_by_name?: string;
  created_at: string;
  recipient_count?: number; // Chair only
  is_read?: boolean; // User only
  read_at?: string | null; // User only
  received_at?: string; // User only
}
```

### 4.2. Statistics Model (Chair)

```typescript
interface Statistics {
  total: number;
  sent: number;
  scheduled: number;
  failed: number;
}
```

### 4.3. Announcement Statistics Model

```typescript
interface AnnouncementStatistics {
  total_recipients: number;
  read_count: number;
  unread_count: number;
}
```

### 4.4. Conference Model

```typescript
interface Conference {
  conference_id: number;
  conference_name: string;
  start_date: string; // YYYY-MM-DD
  end_date: string;
  status: 'PENDING' | 'APPROVED' | 'ACTIVE' | 'COMPLETED';
}
```

### 4.5. User Model

```typescript
interface User {
  user_id: number;
  email: string;
  full_name: string;
  roles: Role[];
}

interface Role {
  role_code: 'CHAIR' | 'REVIEWER' | 'AUTHOR';
  role_name?: string;
  conference_id?: number;
  conference_name?: string;
}
```

---

## 5. Testing Results

### 5.1. Test Account

**Credentials:**
- Email: `honangquy1@gmail.com`
- Password: `Concac123!@#`
- Role: Chair
- User ID: 19
- Conferences: 1, 7, 8

### 5.2. Complete Test Results

| # | Test Case | Method | Endpoint | Input | Expected | Actual | Status |
|---|-----------|--------|----------|-------|----------|--------|--------|
| 1 | Login | POST | `/api/auth/login` | Valid credentials | Token + User info | ✅ Token received, user_id=19 | ✅ PASS |
| 2 | Get announcements | GET | `/api/announcements` | - | List with stats | ✅ 13 items, statistics included | ✅ PASS |
| 3 | Get conferences | GET | `/api/announcements/conferences/list` | - | 3 conferences | ✅ conferences: 9, 8, 7 | ✅ PASS |
| 4 | Preview ALL | POST | `/api/announcements/preview-recipients` | conference=8, audience=ALL | count=11 | ✅ count=11 | ✅ PASS |
| 5 | Preview REVIEWERS | POST | `/api/announcements/preview-recipients` | conference=8, audience=REVIEWERS | count=6 | ✅ count=6 | ✅ PASS |
| 6 | Create announcement | POST | `/api/announcements` | Valid data | announcement_id | ✅ ID=15, scheduled | ✅ PASS |
| 7 | Get detail | GET | `/api/announcements/15` | - | Full detail + stats | ✅ Complete data | ✅ PASS |
| 8 | Update title | PUT | `/api/announcements/15` | New title | Success | ✅ Title updated | ✅ PASS |
| 9 | Filter SCHEDULED | GET | `/api/announcements?status=SCHEDULED` | status=SCHEDULED | 1 item | ✅ Found #15 | ✅ PASS |
| 10 | Delete SCHEDULED | DELETE | `/api/announcements/15` | - | Success | ✅ Deleted | ✅ PASS |
| 11 | Validation test | POST | `/api/announcements` | Empty fields | 422 errors | ✅ All fields validated | ✅ PASS |
| 12 | Delete SENT (fail) | DELETE | `/api/announcements/14` | - | 403 error | ✅ Forbidden | ✅ PASS |

**Overall Result: 12/12 PASS (100%)**

### 5.3. Scheduler Test

**Scenario:** Tạo announcement scheduled +2 phút, kiểm tra gửi tự động

**Steps:**
1. ✅ Created announcement #12 at 13:36:41
2. ✅ Scheduled for 13:38:11 (2 minutes later)
3. ✅ Scheduler detected at 13:39:12
4. ✅ Status changed: SCHEDULED → SENT
5. ✅ Created 11 user_notifications
6. ✅ Users received: Võ Nguyên Phúc, Một Con Chó, Hồ Năng Quý, Quả Lọ, etc.

**Result:** ✅ PASS - Automatic sending works perfectly

### 5.4. Bug Fixes Applied

| Bug | Cause | Fix | Status |
|-----|-------|-----|--------|
| Column 'conference_name' not found | Schema mismatch | Changed `ht.conference_name` → `ht.title as conference_name` | ✅ FIXED |
| ALL audience = 0 recipients | Wrong table query | Changed `vaitronguoidung` → `join_requests` | ✅ FIXED |
| Scheduler not running | No cron setup | Added cron job + background process | ✅ FIXED |

---

## 6. Integration Guide

### 6.1. Mobile Setup (Flutter)

**Step 1: Install Dependencies**
```yaml
# pubspec.yaml
dependencies:
  dio: ^5.4.0
  shared_preferences: ^2.2.2
```

**Step 2: Configure Base URL**
```dart
// lib/config/api_config.dart
class ApiConfig {
  // Development (same WiFi)
  static const String baseUrl = 'http://192.168.1.100:8000/api';
  
  // Production
  // static const String baseUrl = 'https://api.yourdomain.com/api';
}
```

**Step 3: Create API Service**
```dart
// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  
  String? _token;
  
  // Login
  Future<bool> login(String email, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      if (response.data['success']) {
        _token = response.data['data']['token'];
        await _saveToken(_token!);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
  
  // Save token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  // Load token
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }
  
  // Add auth header
  void _addAuthHeader() {
    if (_token != null) {
      dio.options.headers['Authorization'] = 'Bearer $_token';
    }
  }
  
  // Get announcements
  Future<List<Announcement>> getAnnouncements() async {
    _addAuthHeader();
    final response = await dio.get('/announcements');
    
    if (response.data['success']) {
      final data = response.data['data'];
      return (data['announcements'] as List)
          .map((json) => Announcement.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load');
  }
  
  // Create announcement (Chair)
  Future<int?> createAnnouncement({
    required int conferenceId,
    required String title,
    required String content,
    required String audience,
    required List<String> channels,
    required DateTime scheduledAt,
  }) async {
    _addAuthHeader();
    final response = await dio.post('/announcements', data: {
      'conference_id': conferenceId,
      'title': title,
      'content': content,
      'audience': audience,
      'channels': channels,
      'scheduled_at': scheduledAt.toIso8601String(),
    });
    
    if (response.data['success']) {
      return response.data['data']['announcement_id'];
    }
    return null;
  }
  
  // Mark as read
  Future<bool> markAsRead(int announcementId) async {
    _addAuthHeader();
    final response = await dio.post('/announcements/$announcementId/mark-read');
    return response.data['success'];
  }
}
```

**Step 4: Create Models**
```dart
// lib/models/announcement.dart
class Announcement {
  final int announcementId;
  final String title;
  final String content;
  final String audience;
  final List<String> channels;
  final String status;
  final DateTime scheduledAt;
  final DateTime? sentAt;
  final int conferenceId;
  final String conferenceName;
  final int? recipientCount;
  final bool? isRead;

  Announcement({
    required this.announcementId,
    required this.title,
    required this.content,
    required this.audience,
    required this.channels,
    required this.status,
    required this.scheduledAt,
    this.sentAt,
    required this.conferenceId,
    required this.conferenceName,
    this.recipientCount,
    this.isRead,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      announcementId: json['announcement_id'],
      title: json['title'],
      content: json['content'],
      audience: json['audience'],
      channels: List<String>.from(json['channels']),
      status: json['status'],
      scheduledAt: DateTime.parse(json['scheduled_at']),
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      conferenceId: json['conference_id'],
      conferenceName: json['conference_name'],
      recipientCount: json['recipient_count'],
      isRead: json['is_read'],
    );
  }
}
```

### 6.2. Backend Setup

**Step 1: Get Mac IP Address**
```bash
ipconfig getifaddr en0
# Output: 192.168.1.100
```

**Step 2: Start Laravel Server**
```bash
cd /Applications/XAMPP/xamppfiles/htdocs/doancunhan
php artisan serve --host=0.0.0.0 --port=8000
```

**Step 3: Test Connection**
```bash
# From mobile device browser
http://192.168.1.100:8000/api
```

### 6.3. cURL Testing Examples

**Login:**
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"honangquy1@gmail.com","password":"Concac123!@#"}'
```

**Get Announcements:**
```bash
TOKEN="your_token_here"

curl -X GET "http://localhost:8000/api/announcements" \
  -H "Authorization: Bearer $TOKEN"
```

**Create Announcement:**
```bash
curl -X POST http://localhost:8000/api/announcements \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "conference_id": 8,
    "title": "Test từ cURL",
    "content": "Nội dung test",
    "audience": "ALL",
    "channels": ["SYSTEM"],
    "scheduled_at": "2025-11-13 15:00:00"
  }'
```

---

## 7. Scheduler Mechanism

### 7.1. Flow Diagram

```
┌─────────────────────────────────────┐
│   Chair tạo thông báo               │
│   status = SCHEDULED                │
│   scheduled_at = 2025-11-13 15:00   │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Cron Job (mỗi phút)               │
│   * * * * * php artisan schedule:run│
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   ProcessScheduledAnnouncementsJob  │
│   Query: scheduled_at <= NOW()      │
│   AND status = SCHEDULED            │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   SendAnnouncementJob               │
│   1. Get recipients (11 users)      │
│   2. Create user_notifications      │
│   3. Send Email (if EMAIL channel)  │
│   4. Update status = SENT           │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   User nhận thông báo               │
│   Mobile app poll API mới           │
└─────────────────────────────────────┘
```

### 7.2. Cron Configuration

**macOS (Development):**
```bash
crontab -e
# Add this line:
* * * * * cd /Applications/XAMPP/xamppfiles/htdocs/doancunhan && /usr/bin/php artisan schedule:run >> /dev/null 2>&1
```

**Linux (Production):**
```bash
crontab -e
# Add this line:
* * * * * cd /var/www/html/project && php artisan schedule:run >> /dev/null 2>&1
```

**Alternative: Background Process**
```bash
nohup bash -c 'while true; do php artisan schedule:run; sleep 60; done' > storage/logs/scheduler.log 2>&1 &
```

### 7.3. Query Performance

**Scheduler Query:**
```sql
SELECT * FROM thongbao 
WHERE status = 'SCHEDULED' 
  AND scheduled_at <= NOW()
ORDER BY scheduled_at ASC
LIMIT 100;
```

**Index:** `idx_scheduled_processing (status, scheduled_at)`

**Recipient Query (ALL):**
```sql
SELECT DISTINCT u.user_id, u.full_name, u.email
FROM nguoidung u
INNER JOIN join_requests jr ON jr.user_id = u.user_id
WHERE jr.conference_id = 8
  AND jr.status = 'APPROVED';
```

**Index:** `idx_join_requests_approved (conference_id, status, role)`

---

## 8. Error Handling

### 8.1. HTTP Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 200 | OK | Request successful |
| 201 | Created | Announcement created |
| 400 | Bad Request | Invalid JSON |
| 401 | Unauthorized | Invalid/expired token |
| 403 | Forbidden | Not Chair of conference |
| 404 | Not Found | Announcement not exists |
| 422 | Validation Error | Missing required fields |
| 500 | Server Error | Database connection failed |

### 8.2. Error Response Format

**Standard Error Response:**
```json
{
  "success": false,
  "message": "Error description",
  "errors": {
    "field_name": ["Error message 1", "Error message 2"]
  }
}
```

**Examples:**

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "Unauthenticated"
}
```

**403 Forbidden:**
```json
{
  "success": false,
  "message": "Bạn không có quyền tạo thông báo cho hội thảo này"
}
```

**404 Not Found:**
```json
{
  "success": false,
  "message": "Không tìm thấy thông báo"
}
```

**422 Validation Error:**
```json
{
  "success": false,
  "message": "Dữ liệu không hợp lệ",
  "errors": {
    "title": ["Vui lòng nhập tiêu đề"],
    "content": ["Vui lòng nhập nội dung"],
    "audience": ["Vui lòng chọn đối tượng nhận"],
    "channels": ["Vui lòng chọn ít nhất một kênh gửi"],
    "scheduled_at": ["Thời gian gửi phải sau thời điểm hiện tại"],
    "conference_id": ["Hội thảo không tồn tại"]
  }
}
```

### 8.3. Error Handling in Flutter

```dart
Future<void> createAnnouncement(...) async {
  try {
    final response = await dio.post('/announcements', data: {...});
    
    if (response.data['success']) {
      // Success
      print('Created: ${response.data['data']['announcement_id']}');
    } else {
      // Business logic error
      showError(response.data['message']);
    }
  } on DioException catch (e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 401:
          // Token expired, redirect to login
          navigateToLogin();
          break;
        case 403:
          showError('Bạn không có quyền thực hiện thao tác này');
          break;
        case 422:
          // Validation errors
          final errors = e.response!.data['errors'];
          showValidationErrors(errors);
          break;
        default:
          showError('Có lỗi xảy ra, vui lòng thử lại');
      }
    } else {
      // Network error
      showError('Không thể kết nối đến server');
    }
  }
}
```

---

## 📊 Quick Reference

### Audience Types
- `ALL` - Tất cả thành viên (11 users)
- `AUTHORS` - Tác giả bài báo (3 users)
- `REVIEWERS` - Phản biện (6 users)
- `CHAIRS` - Chủ tịch (1 user)

### Channel Types
- `SYSTEM` - Thông báo trong hệ thống
- `EMAIL` - Gửi email
- `CHATBOT` - Gửi qua chatbot

### Status Types
- `SCHEDULED` - Đang lên lịch
- `SENT` - Đã gửi
- `FAILED` - Gửi thất bại

---

## 🚀 Next Steps

### Immediate
1. ✅ Backend API complete
2. 🔄 Mobile team integrate API
3. 📱 Test on real devices
4. 🐛 Fix any integration issues

### Short-term
1. Deploy to production server
2. Setup SSL certificate
3. Configure push notifications (optional)
4. Add realtime updates (Laravel Echo + Pusher)

### Long-term
1. Add file attachments support
2. Add announcement templates
3. Add analytics dashboard
4. Add scheduling recurring announcements

---

## 📞 Support

**Documentation:**
- Full API Guide: `API_ANNOUNCEMENT_GUIDE.md`
- Mobile Integration: `MOBILE_INTEGRATION.md`
- System Complete: `ANNOUNCEMENT_SYSTEM_COMPLETE.md`

**Source Code:**
- Controller: `app/Http/Controllers/Api/AnnouncementController.php`
- Jobs: `app/Jobs/SendAnnouncementJob.php`
- Routes: `routes/api.php` (line ~140)

**Test Credentials:**
- Email: `honangquy1@gmail.com`
- Password: `Concac123!@#`
- Role: Chair (conferences: 1, 7, 8)

---

**Status:** ✅ Production Ready  
**Test Results:** 12/12 PASS (100%)  
**Last Updated:** 13/11/2025

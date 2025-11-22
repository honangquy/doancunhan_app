# 📱 Reviewer Mobile API - Complete Documentation

**Date:** 22/11/2025  
**Version:** 1.1  
**Status:** ✅ Tested & Ready for Integration  
**Base URL:** `http://127.0.0.1:8000/api`

**Total Endpoints:** 9 APIs (1 Auth + 8 Reviewer features)

---

## 🔐 Authentication

### Login
```
POST /api/auth/login
```

**Request Body:**
```json
{
  "email": "reviewer@example.com",
  "password": "your_password"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Đăng nhập thành công",
  "data": {
    "user": {
      "user_id": 46,
      "email": "janon68721@bipochub.com",
      "full_name": "Nguyễn Quốc Tú",
      "is_student": false,
      "faculty_id": null,
      "organization": null,
      "roles": [
        {
          "role_code": "REVIEWER",
          "role_name": "Phản biện viên",
          "conference_id": 24
        }
      ]
    },
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
  }
}
```

**Important:** 
- Token expires in **1 hour**
- Use token in all subsequent requests: `Authorization: Bearer {token}`

---

## 📊 API Endpoints

### 1. Dashboard

Get overview statistics and recent assignments.

```
GET /api/mobile/reviewer/dashboard
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "stats": {
      "assignments": {
        "total": 1,
        "pending": 0,
        "accepted": 0,
        "completed": 1,
        "declined": 0
      },
      "reviews": {
        "total": 1,
        "drafts": 0,
        "average_score": "5.40000"
      }
    },
    "recent_assignments": [
      {
        "id": 20,
        "status": "COMPLETED",
        "assigned_at": "2025-11-21T14:52:29.000000Z",
        "paper_title": "Tối Ưu Hóa Thuật Toán Học Sâu...",
        "conference_name": "Hội thảo trí tuệ nhân tạo HUIT"
      }
    ]
  }
}
```

---

### 2. Get All Assignments

List all paper assignments for the reviewer.

```
GET /api/mobile/reviewer/assignments
GET /api/mobile/reviewer/assignments?status=PENDING
GET /api/mobile/reviewer/assignments?status=ACCEPTED
GET /api/mobile/reviewer/assignments?status=COMPLETED
GET /api/mobile/reviewer/assignments?status=DECLINED

Authorization: Bearer {token}
```

**Query Parameters:**
- `status` (optional): Filter by status (PENDING, ACCEPTED, COMPLETED, DECLINED)

**Response:**
```json
{
  "success": true,
  "data": {
    "assignments": [
      {
        "id": 20,
        "paper_id": 16,
        "status": "COMPLETED",
        "assigned_at": "2025-11-21T14:52:29.000000Z",
        "responded_at": null,
        "paper_title": "Tối Ưu Hóa Thuật Toán Học Sâu cho Phân Tích Hình Ảnh Y Khoa với Dữ Liệu Thiếu",
        "paper_abstract": "Nghiên cứu này đề xuất một kiến trúc mạng nơ-ron tích chập (CNN)...",
        "keywords": "Deep Learning, Computer Vision, Medical Imaging, Attention Mechanism, Data Augmentation, CNN",
        "file_path": "papers/24/16_1763737608.pdf",
        "paper_status": "ACCEPTED",
        "conference_id": 24,
        "conference_name": "Hội thảo trí tuệ nhân tạo HUIT",
        "assigned_by_name": "Linh Lê",
        "author_name": "Quý Hồ",
        "author_email": "hoquy@gmail.com"
      }
    ],
    "stats": {
      "total": 1,
      "pending": 0,
      "accepted": 0,
      "completed": 1,
      "declined": 0
    }
  }
}
```

---

### 3. Get Assignment Detail

Get full details of a specific assignment including paper versions, authors, and existing review.

```
GET /api/mobile/reviewer/assignments/{assignment_id}
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "assignment": {
      "id": 20,
      "user_id": 46,
      "paper_id": 16,
      "conference_id": 24,
      "assigned_by": 37,
      "assignment_method": "MANUAL",
      "status": "COMPLETED",
      "assigned_at": "2025-11-21T14:52:29.000000Z",
      "responded_at": null,
      "review_submitted_at": "2025-11-21T14:54:48.000000Z",
      "decline_reason": null,
      "assignment_metadata": {
        "bid_value": 3,
        "coi_status": false,
        "assigned_timestamp": "2025-11-21T14:52:29.893133Z"
      },
      "paper_title": "Tối Ưu Hóa Thuật Toán Học Sâu cho Phân Tích Hình Ảnh Y Khoa với Dữ Liệu Thiếu",
      "paper_abstract": "Nghiên cứu này đề xuất...",
      "keywords": "Deep Learning, Computer Vision, Medical Imaging...",
      "paper_file": "papers/24/16_1763737608.pdf",
      "paper_status": "ACCEPTED",
      "conference_name": "Hội thảo trí tuệ nhân tạo HUIT",
      "assigned_by_name": "Linh Lê",
      "author_name": "Quý Hồ",
      "author_email": "hoquy@gmail.com",
      "author_organization": "Khoa CNTT, HUIT"
    },
    "versions": [
      {
        "version_id": 6,
        "paper_id": 16,
        "version_no": 2,
        "file_path": "papers/24/16_1763737608.pdf",
        "submitted_at": "2025-11-21 22:06:48",
        "note": "Revision submitted"
      },
      {
        "version_id": 1,
        "paper_id": 16,
        "version_no": 1,
        "file_path": "papers/24/16_1763736312.pdf",
        "submitted_at": "2025-11-21 21:45:12",
        "note": "Initial submission"
      }
    ],
    "authors": [
      {
        "author_order": 1,
        "is_contact": 1,
        "organization": null,
        "full_name": "Quý Hồ",
        "email": "hoquy@gmail.com"
      },
      {
        "author_order": 2,
        "is_contact": 0,
        "organization": null,
        "full_name": "Đặng Trúc Quỳnh",
        "email": "dangtrucquynh04@gmail.com"
      }
    ],
    "existing_review": {
      "review_id": 10,
      "assignment_id": 20,
      "recommendation_code": "WEAK_ACCEPT",
      "score": null,
      "comment_author": null,
      "comment_chair": null,
      "submitted_at": "2025-11-21 21:54:48",
      "score_novelty": 6,
      "score_relevance": 6,
      "score_technical_quality": 5,
      "score_presentation": 5,
      "score_references": 5,
      "total_score": "5.4",
      "detailed_comments": "quỳnh test chức năng Version bài báo của quý làm nè",
      "review_file_path": null,
      "is_draft": 0
    }
  }
}
```

**Notes:**
- `versions`: Array of all paper versions (sorted newest first)
- `authors`: All authors with contact person marked (`is_contact: 1`)
- `existing_review`: Returns review if already submitted, otherwise `null`

---

### 4. Accept Assignment

Accept a paper review assignment.

```
POST /api/mobile/reviewer/assignments/{assignment_id}/accept
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "Đã chấp nhận phân công phản biện",
  "data": {
    "assignment_id": 20,
    "status": "ACCEPTED",
    "responded_at": "2025-11-21T15:30:00.000000Z"
  }
}
```

**Error Response (404):**
```json
{
  "success": false,
  "message": "Không tìm thấy phân công phản biện"
}
```

---

### 5. Decline Assignment

Decline a paper review assignment with a reason.

```
POST /api/mobile/reviewer/assignments/{assignment_id}/decline
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "reason": "Tôi không có đủ chuyên môn về lĩnh vực này"
}
```

**Validation:**
- `reason`: Required, max 500 characters

**Response:**
```json
{
  "success": true,
  "message": "Đã từ chối phân công phản biện",
  "data": {
    "assignment_id": 20,
    "status": "DECLINED",
    "decline_reason": "Tôi không có đủ chuyên môn về lĩnh vực này",
    "responded_at": "2025-11-21T15:30:00.000000Z"
  }
}
```

**Validation Error (422):**
```json
{
  "success": false,
  "message": "The reason field is required.",
  "errors": {
    "reason": ["The reason field is required."]
  }
}
```

---

### 6. Get Paper Versions

Get all versions of a specific paper that reviewer is assigned to review.

```
GET /api/mobile/reviewer/papers/{paper_id}/versions
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "paper": {
      "paper_id": 16,
      "title": "Tối Ưu Hóa Thuật Toán Học Sâu cho Phân Tích Hình Ảnh Y Khoa với Dữ Liệu Thiếu",
      "abstract": "Nghiên cứu này đề xuất một kiến trúc mạng nơ-ron tích chập (CNN)...",
      "keywords": "Deep Learning, Computer Vision, Medical Imaging, Attention Mechanism, Data Augmentation, CNN",
      "current_file": "papers/24/16_1763737608.pdf",
      "status_code": "ACCEPTED",
      "conference_name": "Hội thảo trí tuệ nhân tạo HUIT"
    },
    "versions": [
      {
        "version_id": 6,
        "paper_id": 16,
        "version_no": 2,
        "file_path": "papers/24/16_1763737608.pdf",
        "submitted_at": "2025-11-21 22:06:48",
        "note": "Revision submitted"
      },
      {
        "version_id": 1,
        "paper_id": 16,
        "version_no": 1,
        "file_path": "papers/24/16_1763736312.pdf",
        "submitted_at": "2025-11-21 21:45:12",
        "note": "Initial submission"
      }
    ],
    "authors": [
      {
        "author_order": 1,
        "is_contact": 1,
        "organization": null,
        "full_name": "Quý Hồ",
        "email": "hoquy@gmail.com"
      },
      {
        "author_order": 2,
        "is_contact": 0,
        "organization": null,
        "full_name": "Đặng Trúc Quỳnh",
        "email": "dangtrucquynh04@gmail.com"
      }
    ]
  }
}
```

**Error Response (403):**
```json
{
  "success": false,
  "message": "Bạn không có quyền xem các phiên bản của bài báo này"
}
```

**Error Response (404):**
```json
{
  "success": false,
  "message": "Không tìm thấy bài báo"
}
```

**Notes:**
- Reviewer must be assigned to the paper to access versions
- Versions are sorted by version_no descending (newest first)
- `current_file` in paper object shows the active version
- Use file_path to download specific versions

---

### 7. Get All Reviews

List all submitted reviews with statistics.

```
GET /api/mobile/reviewer/reviews
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "reviews": [
      {
        "review_id": 10,
        "assignment_id": 20,
        "paper_id": 16,
        "recommendation_code": "WEAK_ACCEPT",
        "total_score": "5.4",
        "score_novelty": 6,
        "score_relevance": 6,
        "score_technical_quality": 5,
        "score_presentation": 5,
        "score_references": 5,
        "submitted_at": "2025-11-21 21:54:48",
        "is_draft": 0,
        "paper_title": "Tối Ưu Hóa Thuật Toán Học Sâu cho Phân Tích Hình Ảnh Y Khoa với Dữ Liệu Thiếu",
        "paper_status": "ACCEPTED",
        "conference_name": "Hội thảo trí tuệ nhân tạo HUIT",
        "assigned_at": "2025-11-21 21:52:29"
      }
    ],
    "stats": {
      "total": 1,
      "average_score": 5.4,
      "accept": 1,
      "reject": 0
    }
  }
}
```

---

### 8. Get Review Detail

Get full details of a specific review.

```
GET /api/mobile/reviewer/reviews/{review_id}
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "review_id": 10,
    "assignment_id": 20,
    "recommendation_code": "WEAK_ACCEPT",
    "score": null,
    "comment_author": null,
    "comment_chair": null,
    "submitted_at": "2025-11-21 21:54:48",
    "score_novelty": 6,
    "score_relevance": 6,
    "score_technical_quality": 5,
    "score_presentation": 5,
    "score_references": 5,
    "total_score": "5.4",
    "detailed_comments": "quỳnh test chức năng Version bài báo của quý làm nè",
    "review_file_path": null,
    "is_draft": 0,
    "paper_id": 16,
    "paper_title": "Tối Ưu Hóa Thuật Toán Học Sâu cho Phân Tích Hình Ảnh Y Khoa với Dữ Liệu Thiếu",
    "paper_abstract": "Nghiên cứu này đề xuất một kiến trúc mạng nơ-ron...",
    "conference_name": "Hội thảo trí tuệ nhân tạo HUIT"
  }
}
```

**Error Response (404):**
```json
{
  "success": false,
  "message": "Không tìm thấy đánh giá"
}
```

---

### 9. Submit/Update Review

Submit a new review or update existing draft.

```
POST /api/mobile/reviewer/reviews
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request Body (multipart/form-data):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `assignment_id` | integer | ✅ Yes | Assignment ID |
| `recommendation_code` | string | ✅ Yes | ACCEPT, WEAK_ACCEPT, BORDERLINE, WEAK_REJECT, REJECT |
| `score_novelty` | integer | ✅ Yes | 1-10 |
| `score_relevance` | integer | ✅ Yes | 1-10 |
| `score_technical_quality` | integer | ✅ Yes | 1-10 |
| `score_presentation` | integer | ✅ Yes | 1-10 |
| `score_references` | integer | ✅ Yes | 1-10 |
| `detailed_comments` | text | ✅ Yes | Detailed review comments |
| `is_draft` | boolean | No | 0 = Final, 1 = Draft (default: 0) |
| `review_file` | file | No | PDF file (max 10MB) |

**Example Request:**
```bash
curl -X POST "http://127.0.0.1:8000/api/mobile/reviewer/reviews" \
  -H "Authorization: Bearer {token}" \
  -F "assignment_id=20" \
  -F "recommendation_code=WEAK_ACCEPT" \
  -F "score_novelty=7" \
  -F "score_relevance=8" \
  -F "score_technical_quality=6" \
  -F "score_presentation=7" \
  -F "score_references=6" \
  -F "detailed_comments=Bài báo có ý tưởng hay nhưng cần cải thiện phần thực nghiệm" \
  -F "is_draft=0" \
  -F "review_file=@/path/to/review.pdf"
```

**Success Response (200 - New Review):**
```json
{
  "success": true,
  "message": "Đã nộp đánh giá thành công",
  "data": {
    "review_id": 11,
    "assignment_id": 20,
    "recommendation_code": "WEAK_ACCEPT",
    "total_score": 6.8,
    "is_draft": 0,
    "submitted_at": "2025-11-22T10:30:00.000000Z"
  }
}
```

**Success Response (200 - Update Draft):**
```json
{
  "success": true,
  "message": "Đã cập nhật đánh giá thành công",
  "data": {
    "review_id": 10,
    "assignment_id": 20,
    "recommendation_code": "WEAK_ACCEPT",
    "total_score": 6.8,
    "is_draft": 0,
    "submitted_at": "2025-11-22T10:30:00.000000Z"
  }
}
```

**Validation Error (422):**
```json
{
  "success": false,
  "message": "The assignment id field is required.",
  "errors": {
    "assignment_id": ["The assignment id field is required."],
    "score_novelty": ["The score novelty must be between 1 and 10."]
  }
}
```

**Business Logic Error (400):**
```json
{
  "success": false,
  "message": "Bạn chưa được phân công phản biện bài báo này"
}
```

---

## 📋 Reference Data

### Assignment Status Codes

| Code | Description | Color Suggestion |
|------|-------------|------------------|
| `PENDING` | Waiting for reviewer response | 🟡 Yellow |
| `ACCEPTED` | Reviewer accepted | 🔵 Blue |
| `COMPLETED` | Review submitted | 🟢 Green |
| `DECLINED` | Reviewer declined | 🔴 Red |

### Recommendation Codes

| Code | Display Text | Score Range |
|------|--------------|-------------|
| `ACCEPT` | Chấp nhận | 8-10 |
| `WEAK_ACCEPT` | Chấp nhận có điều kiện | 6-7.9 |
| `BORDERLINE` | Cân nhắc | 5-5.9 |
| `WEAK_REJECT` | Từ chối có điều kiện | 3-4.9 |
| `REJECT` | Từ chối | 1-2.9 |

### Score Criteria (1-10 scale)

1. **Novelty** (Tính mới): Originality and innovation
2. **Relevance** (Tính liên quan): Relevance to conference topic
3. **Technical Quality** (Chất lượng kỹ thuật): Methodology and rigor
4. **Presentation** (Trình bày): Clarity and organization
5. **References** (Tài liệu tham khảo): Bibliography quality

**Total Score Calculation:**
```
total_score = (score_novelty + score_relevance + score_technical_quality + 
               score_presentation + score_references) / 5
```

---

## 🔒 Error Handling

### Standard Error Response Format

```json
{
  "success": false,
  "message": "Error description",
  "errors": {
    "field_name": ["Validation error message"]
  }
}
```

### HTTP Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 200 | Success | Request processed successfully |
| 400 | Bad Request | Business logic error |
| 401 | Unauthorized | Invalid or expired token |
| 404 | Not Found | Resource doesn't exist |
| 422 | Validation Error | Invalid input data |
| 500 | Server Error | Internal server error |

---

## 🧪 Testing Credentials

**Test Account:**
- Email: `janon68721@bipochub.com`
- Password: `123123`
- Role: REVIEWER
- Conference: "Hội thảo trí tuệ nhân tạo HUIT"

**Test Data Available:**
- 1 COMPLETED assignment (ID: 20)
- 1 submitted review (ID: 10)
- Paper with 2 versions
- 2 authors on paper

---

## 📱 Flutter Integration Examples

### 1. Setup HTTP Client

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  String? _token;
  
  void setToken(String token) {
    _token = token;
  }
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };
}
```

### 2. Login

```dart
Future<Map<String, dynamic>> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: _headers,
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    setToken(data['data']['token']);
    return data;
  } else {
    throw Exception('Login failed');
  }
}
```

### 3. Get Dashboard

```dart
Future<Map<String, dynamic>> getDashboard() async {
  final response = await http.get(
    Uri.parse('$baseUrl/mobile/reviewer/dashboard'),
    headers: _headers,
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load dashboard');
  }
}
```

### 4. Get Assignments with Filter

```dart
Future<Map<String, dynamic>> getAssignments({String? status}) async {
  var url = '$baseUrl/mobile/reviewer/assignments';
  if (status != null) {
    url += '?status=$status';
  }
  
  final response = await http.get(
    Uri.parse(url),
    headers: _headers,
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load assignments');
  }
}
```

### 5. Submit Review with File

```dart
Future<Map<String, dynamic>> submitReview({
  required int assignmentId,
  required String recommendationCode,
  required int scoreNovelty,
  required int scoreRelevance,
  required int scoreTechnicalQuality,
  required int scorePresentation,
  required int scoreReferences,
  required String detailedComments,
  bool isDraft = false,
  File? reviewFile,
}) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/mobile/reviewer/reviews'),
  );
  
  request.headers.addAll({
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  });
  
  request.fields['assignment_id'] = assignmentId.toString();
  request.fields['recommendation_code'] = recommendationCode;
  request.fields['score_novelty'] = scoreNovelty.toString();
  request.fields['score_relevance'] = scoreRelevance.toString();
  request.fields['score_technical_quality'] = scoreTechnicalQuality.toString();
  request.fields['score_presentation'] = scorePresentation.toString();
  request.fields['score_references'] = scoreReferences.toString();
  request.fields['detailed_comments'] = detailedComments;
  request.fields['is_draft'] = isDraft ? '1' : '0';
  
  if (reviewFile != null) {
    request.files.add(
      await http.MultipartFile.fromPath('review_file', reviewFile.path),
    );
  }
  
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to submit review');
  }
}
```

---

## 📝 Implementation Checklist

### Phase 1: Authentication & Dashboard ✅
- [ ] Login screen UI
- [ ] Token storage (secure storage)
- [ ] Auto-refresh token handling
- [ ] Dashboard stats cards
- [ ] Recent assignments list

### Phase 2: Assignments ✅
- [ ] Assignment list with filters (PENDING, ACCEPTED, COMPLETED, DECLINED)
- [ ] Assignment detail screen
- [ ] Paper PDF viewer
- [ ] Accept/Decline actions
- [ ] Authors list display
- [ ] Version history viewer

### Phase 3: Reviews ✅
- [ ] Review list screen
- [ ] Review detail viewer
- [ ] Submit review form
  - [ ] Score sliders (1-10)
  - [ ] Recommendation dropdown
  - [ ] Comments textarea
  - [ ] File upload (PDF)
  - [ ] Draft/Final toggle
- [ ] Form validation
- [ ] Review submission confirmation

### Phase 4: Polish 🎨
- [ ] Error handling & user feedback
- [ ] Loading states
- [ ] Empty states
- [ ] Pull-to-refresh
- [ ] Offline mode handling
- [ ] Push notifications (optional)

---

## 🚀 API Test Results

**Test Date:** 22/11/2025  
**Tester:** Backend Team  
**Environment:** Development (localhost:8000)

### ✅ All APIs Tested Successfully

| Endpoint | Status | Response Time | Notes |
|----------|--------|---------------|-------|
| POST /auth/login | ✅ Pass | ~150ms | Token valid 1h |
| GET /dashboard | ✅ Pass | ~80ms | Stats accurate |
| GET /assignments | ✅ Pass | ~120ms | With joins working |
| GET /assignments?status=X | ✅ Pass | ~100ms | Filters working |
| GET /assignments/{id} | ✅ Pass | ~150ms | Full details + versions |
| GET /papers/{id}/versions | ✅ Pass | ~110ms | All versions + authors |
| GET /reviews | ✅ Pass | ~90ms | Stats calculated |
| GET /reviews/{id} | ✅ Pass | ~70ms | Full review data |

**Write APIs (Not tested to preserve data):**
- POST /assignments/{id}/accept
- POST /assignments/{id}/decline  
- POST /reviews

**Recommendation:** Use Postman collection for write API testing.

---

## 🐛 Known Issues & Fixes

### Fixed During Testing ✅
1. **Column Name Mismatch**
   - ❌ Used: `response_at`
   - ✅ Fixed: `responded_at`
   
2. **Non-existent Column**
   - ❌ Used: `deadline`
   - ✅ Fixed: Removed from queries

3. **Wrong Table Name**
   - ❌ Used: `paperversions`
   - ✅ Fixed: `phienbanbaibao`
   - ✅ Fixed: Removed from queries

### Current Limitations
- File download URL needs to be constructed: `{base_url}/storage/{file_path}`
- Token refresh not implemented (must re-login after 1 hour)
- No pagination on lists (will add if needed)

---

## 📞 Support

**Backend API Questions:**
- Contact: Backend Development Team
- Documentation: This file + `REVIEWER_MOBILE_API.postman_collection.json`

**Testing:**
- Postman Collection: Import `REVIEWER_MOBILE_API.postman_collection.json`
- Test Server: `http://127.0.0.1:8000`
- Test Credentials: See "Testing Credentials" section above

---

## 📎 Additional Resources

1. **Postman Collection:** `REVIEWER_MOBILE_API.postman_collection.json`
2. **Backend Controller:** `app/Http/Controllers/Api/ReviewerMobileController.php`
3. **API Routes:** `routes/api.php` (search for `/mobile/reviewer`)
4. **Test Script:** `test_reviewer_api.sh`

---

**Last Updated:** 22/11/2025  
**API Version:** 1.0  
**Backend Framework:** Laravel 9.x  
**Authentication:** JWT (tymon/jwt-auth)

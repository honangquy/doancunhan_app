# 📱 REVIEWER MOBILE APP API DOCUMENTATION

## 🔐 Authentication
Tất cả API endpoints yêu cầu JWT token trong header:
```
Authorization: Bearer {your_jwt_token}
```

**Base URL:** `http://127.0.0.1:8000/api/mobile/reviewer`

---

## 📊 1. Dashboard - Thống kê tổng quan

### `GET /dashboard`

**Response:**
```json
{
  "success": true,
  "data": {
    "stats": {
      "assignments": {
        "total": 15,
        "pending": 3,
        "accepted": 8,
        "completed": 3,
        "declined": 1
      },
      "reviews": {
        "total": 10,
        "drafts": 2,
        "average_score": 7.5
      }
    },
    "recent_assignments": [
      {
        "id": 20,
        "status": "ACCEPTED",
        "assigned_at": "2025-11-15T10:30:00Z",
        "paper_title": "AI-Powered Mobile App Development",
        "conference_name": "ICSE 2025"
      }
    ]
  }
}
```

---

## 📋 2. Assignments - Danh sách phân công

### `GET /assignments`

**Query Parameters:**
- `status` (optional): PENDING | ACCEPTED | COMPLETED | DECLINED

**Response:**
```json
{
  "success": true,
  "data": {
    "assignments": [
      {
        "id": 20,
        "paper_id": 16,
        "status": "ACCEPTED",
        "assigned_at": "2025-11-15T10:30:00Z",
        "response_at": "2025-11-16T08:20:00Z",
        "deadline": "2025-12-01T23:59:59Z",
        "paper_title": "AI-Powered Mobile App Development",
        "paper_abstract": "This paper presents...",
        "keywords": "AI, Mobile, Flutter",
        "file_path": "papers/paper_16.pdf",
        "paper_status": "UNDER_REVIEW",
        "conference_id": 22,
        "conference_name": "ICSE 2025",
        "assigned_by_name": "Prof. Nguyen Van A",
        "author_name": "Tran Thi B",
        "author_email": "tranb@example.com"
      }
    ],
    "stats": {
      "total": 15,
      "pending": 3,
      "accepted": 8,
      "completed": 3,
      "declined": 1
    }
  }
}
```

---

## 📄 3. Assignment Details - Chi tiết phân công

### `GET /assignments/{id}`

**Example:** `GET /assignments/20`

**Response:**
```json
{
  "success": true,
  "data": {
    "assignment": {
      "id": 20,
      "paper_id": 16,
      "status": "ACCEPTED",
      "assigned_at": "2025-11-15T10:30:00Z",
      "response_at": "2025-11-16T08:20:00Z",
      "deadline": "2025-12-01T23:59:59Z",
      "paper_title": "AI-Powered Mobile App Development",
      "paper_abstract": "Full abstract text...",
      "keywords": "AI, Mobile, Flutter, Deep Learning",
      "paper_file": "papers/paper_16.pdf",
      "paper_status": "UNDER_REVIEW",
      "conference_id": 22,
      "conference_name": "ICSE 2025",
      "assigned_by_name": "Prof. Nguyen Van A",
      "author_name": "Tran Thi B",
      "author_email": "tranb@example.com",
      "author_organization": "HCMUT"
    },
    "versions": [
      {
        "version_id": 25,
        "paper_id": 16,
        "version_no": 1,
        "file_path": "papers/versions/paper_16_v1.pdf",
        "submitted_at": "2025-11-10T14:00:00Z",
        "note": "Initial submission"
      }
    ],
    "authors": [
      {
        "author_order": 1,
        "is_contact": true,
        "organization": "HCMUT",
        "full_name": "Tran Thi B",
        "email": "tranb@example.com"
      },
      {
        "author_order": 2,
        "is_contact": false,
        "organization": "UIT",
        "full_name": "Le Van C",
        "email": "lec@example.com"
      }
    ],
    "existing_review": {
      "review_id": 15,
      "assignment_id": 20,
      "score_novelty": 8,
      "score_relevance": 7,
      "score_technical_quality": 8,
      "score_presentation": 7,
      "score_references": 8,
      "total_score": 7.6,
      "detailed_comments": "This is a well-written paper...",
      "recommendation_code": "ACCEPT",
      "is_draft": false,
      "submitted_at": "2025-11-18T16:45:00Z"
    }
  }
}
```

---

## ✅ 4. Accept Assignment - Chấp nhận phân công

### `POST /assignments/{id}/accept`

**Example:** `POST /assignments/20/accept`

**Response:**
```json
{
  "success": true,
  "message": "Assignment accepted successfully",
  "data": {
    "assignment_id": 20,
    "status": "ACCEPTED"
  }
}
```

**Error Response (Already Processed):**
```json
{
  "success": false,
  "message": "Assignment not found or already processed"
}
```

---

## ❌ 5. Decline Assignment - Từ chối phân công

### `POST /assignments/{id}/decline`

**Request Body:**
```json
{
  "reason": "I have a conflict of interest with the author"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Assignment declined successfully",
  "data": {
    "assignment_id": 20,
    "status": "DECLINED"
  }
}
```

**Validation Error:**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "reason": ["The reason field is required."]
  }
}
```

---

## 📝 6. Get Reviews - Danh sách phản biện đã nộp

### `GET /reviews`

**Response:**
```json
{
  "success": true,
  "data": {
    "reviews": [
      {
        "review_id": 15,
        "assignment_id": 20,
        "paper_id": 16,
        "recommendation_code": "ACCEPT",
        "total_score": 7.6,
        "score_novelty": 8,
        "score_relevance": 7,
        "score_technical_quality": 8,
        "score_presentation": 7,
        "score_references": 8,
        "submitted_at": "2025-11-18T16:45:00Z",
        "is_draft": false,
        "paper_title": "AI-Powered Mobile App Development",
        "paper_status": "UNDER_REVIEW",
        "conference_name": "ICSE 2025",
        "assigned_at": "2025-11-15T10:30:00Z"
      }
    ],
    "stats": {
      "total": 10,
      "average_score": 7.5,
      "accept": 7,
      "reject": 3
    }
  }
}
```

---

## 📋 7. Get Review Detail - Chi tiết phản biện

### `GET /reviews/{id}`

**Example:** `GET /reviews/15`

**Response:**
```json
{
  "success": true,
  "data": {
    "review_id": 15,
    "assignment_id": 20,
    "paper_id": 16,
    "score_novelty": 8,
    "score_relevance": 7,
    "score_technical_quality": 8,
    "score_presentation": 7,
    "score_references": 8,
    "total_score": 7.6,
    "detailed_comments": "Detailed review comments here...",
    "recommendation_code": "ACCEPT",
    "is_draft": false,
    "submitted_at": "2025-11-18T16:45:00Z",
    "review_file_path": "reviews/review_15.pdf",
    "paper_title": "AI-Powered Mobile App Development",
    "paper_abstract": "Full abstract...",
    "conference_name": "ICSE 2025"
  }
}
```

---

## 📤 8. Submit Review - Gửi phản biện

### `POST /reviews`

**Request Body (multipart/form-data):**
```json
{
  "assignment_id": 20,
  "score_novelty": 8,
  "score_relevance": 7,
  "score_technical_quality": 8,
  "score_presentation": 7,
  "score_references": 8,
  "detailed_comments": "This paper presents a novel approach to...",
  "recommendation_code": "ACCEPT",
  "is_draft": false,
  "review_file": "<file upload - optional>"
}
```

**Parameters:**
- `assignment_id` (required, integer)
- `score_novelty` (required if not draft, integer 1-10)
- `score_relevance` (required if not draft, integer 1-10)
- `score_technical_quality` (required if not draft, integer 1-10)
- `score_presentation` (required if not draft, integer 1-10)
- `score_references` (required if not draft, integer 1-10)
- `detailed_comments` (required if not draft, string, min 50 chars)
- `recommendation_code` (required if not draft): ACCEPT | REJECT | STRONG_ACCEPT | WEAK_ACCEPT | STRONG_REJECT | WEAK_REJECT | BORDERLINE
- `is_draft` (required, boolean): true = save draft, false = final submission
- `review_file` (optional, file): PDF/DOC/DOCX, max 10MB

**Response (Success):**
```json
{
  "success": true,
  "message": "Review submitted successfully",
  "data": {
    "review_id": 15,
    "is_draft": false,
    "total_score": 7.6
  }
}
```

**Response (Draft Saved):**
```json
{
  "success": true,
  "message": "Draft saved successfully",
  "data": {
    "review_id": 15,
    "is_draft": true,
    "total_score": 7.6
  }
}
```

**Error Response (Not Accepted):**
```json
{
  "success": false,
  "message": "You must accept the assignment before submitting review"
}
```

**Validation Error:**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "score_novelty": ["The score novelty field is required."],
    "detailed_comments": ["The detailed comments must be at least 50 characters."]
  }
}
```

---

## 📊 Status Codes Summary

### Assignment Status:
- `PENDING` - Chờ reviewer phản hồi
- `ACCEPTED` - Đã chấp nhận
- `DECLINED` - Đã từ chối
- `COMPLETED` - Đã hoàn thành phản biện

### Paper Status:
- `SUBMITTED` - Đã nộp
- `UNDER_REVIEW` - Đang phản biện
- `REVISION_REQUIRED` - Yêu cầu sửa
- `PENDING_CHAIR_REVIEW` - Chờ Chair duyệt lại
- `ACCEPTED` - Chấp nhận
- `REJECTED` - Từ chối
- `WITHDRAWN` - Đã rút

### Recommendation Codes:
- `STRONG_ACCEPT` - Chấp nhận mạnh
- `ACCEPT` - Chấp nhận
- `WEAK_ACCEPT` - Chấp nhận yếu
- `BORDERLINE` - Biên giới
- `WEAK_REJECT` - Từ chối yếu
- `REJECT` - Từ chối
- `STRONG_REJECT` - Từ chối mạnh

---

## 🔧 Error Handling

### Common HTTP Status Codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized (Invalid token)
- `403` - Forbidden (Not accepted assignment yet)
- `404` - Not Found
- `422` - Validation Error
- `500` - Server Error

### Error Response Format:
```json
{
  "success": false,
  "message": "Error description here",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

---

## 🧪 Testing Examples (Flutter/Dart)

### 1. Get Assignments:
```dart
final response = await http.get(
  Uri.parse('$baseUrl/mobile/reviewer/assignments'),
  headers: {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  },
);

if (response.statusCode == 200) {
  final data = json.decode(response.body);
  List assignments = data['data']['assignments'];
  // Process assignments
}
```

### 2. Submit Review:
```dart
var request = http.MultipartRequest(
  'POST',
  Uri.parse('$baseUrl/mobile/reviewer/reviews'),
);

request.headers['Authorization'] = 'Bearer $token';
request.fields['assignment_id'] = '20';
request.fields['score_novelty'] = '8';
request.fields['score_relevance'] = '7';
request.fields['score_technical_quality'] = '8';
request.fields['score_presentation'] = '7';
request.fields['score_references'] = '8';
request.fields['detailed_comments'] = 'Your review comments here...';
request.fields['recommendation_code'] = 'ACCEPT';
request.fields['is_draft'] = 'false';

// Add file if needed
if (file != null) {
  request.files.add(await http.MultipartFile.fromPath(
    'review_file',
    file.path,
  ));
}

var streamedResponse = await request.send();
var response = await http.Response.fromStream(streamedResponse);

if (response.statusCode == 200) {
  final data = json.decode(response.body);
  // Review submitted successfully
}
```

---

## 📞 Support

Nếu có vấn đề về API, liên hệ:
- Backend Team: backend@example.com
- Documentation: [GitHub Wiki](#)

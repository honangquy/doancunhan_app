# 🚀 HƯỚNG DẪN CÀI ĐẶT REVIEWER MOBILE API

## ✅ Đã hoàn thành

### Flutter App
- ✅ Xóa toàn bộ Reviewer API cũ (PhanCongPhanBien)
- ✅ Tạo Reviewer Mobile mới với 6 screens
- ✅ Sửa tất cả lỗi type casting trong models
- ✅ Sửa URL API (bỏ double /api)

### Backend Files Tạo
- ✅ `BACKEND_REVIEWER_MOBILE_CONTROLLER.php` - Controller với 8 endpoints
- ✅ `BACKEND_REVIEWER_MOBILE_ROUTES.php` - Routes definition

---

## 📋 BƯỚC CÀI ĐẶT BACKEND

### Bước 1: Copy Controller vào Laravel

```bash
# Copy file controller vào đúng vị trí
cp BACKEND_REVIEWER_MOBILE_CONTROLLER.php /Applications/XAMPP/xamppfiles/htdocs/doancunhan/app/Http/Controllers/Api/Mobile/ReviewerMobileController.php
```

**Hoặc thủ công:**
1. Tạo folder `app/Http/Controllers/Api/Mobile/` (nếu chưa có)
2. Copy nội dung file `BACKEND_REVIEWER_MOBILE_CONTROLLER.php` 
3. Paste vào file mới: `app/Http/Controllers/Api/Mobile/ReviewerMobileController.php`

### Bước 2: Thêm Routes vào api.php

Mở file `/Applications/XAMPP/xamppfiles/htdocs/doancunhan/routes/api.php`

**Thêm import ở đầu file:**
```php
use App\Http\Controllers\Api\Mobile\ReviewerMobileController;
```

**Thêm routes vào trong middleware auth:api:**
```php
Route::middleware(['auth:api'])->group(function () {
    
    // ... existing routes ...
    
    // REVIEWER MOBILE ROUTES
    Route::prefix('mobile/reviewer')->group(function () {
        Route::get('/dashboard', [ReviewerMobileController::class, 'dashboard']);
        Route::get('/assignments', [ReviewerMobileController::class, 'getAssignments']);
        Route::get('/assignments/{id}', [ReviewerMobileController::class, 'getAssignmentDetail']);
        Route::post('/assignments/{id}/accept', [ReviewerMobileController::class, 'acceptAssignment']);
        Route::post('/assignments/{id}/decline', [ReviewerMobileController::class, 'declineAssignment']);
        Route::get('/reviews', [ReviewerMobileController::class, 'getReviews']);
        Route::get('/reviews/{id}', [ReviewerMobileController::class, 'getReviewDetail']);
        Route::post('/reviews', [ReviewerMobileController::class, 'submitReview']);
    });
});
```

### Bước 3: Kiểm tra Database Tables

Controller cần các bảng sau (kiểm tra xem đã có chưa):

```sql
-- Table phân công phản biện
phancongphanbien (
    assignment_id,
    paper_id,
    reviewer_id,
    status,  -- PENDING, ACCEPTED, DECLINED, COMPLETED
    assigned_at,
    response_at,
    deadline,
    assigned_by,
    decline_reason
)

-- Table phản biện (reviews)
phanbien (
    review_id,
    assignment_id,
    reviewer_id,
    score_novelty,
    score_relevance,
    score_technical_quality,
    score_presentation,
    score_references,
    detailed_comments,
    recommendation_code,
    is_draft,
    submitted_at,
    review_file_path
)

-- Table bài báo
baibao (
    paper_id,
    title,
    abstract,
    keywords,
    file_path,
    status,
    conference_id,
    user_id
)

-- Table hội thảo
hoithao (
    conference_id,
    name
)

-- Table người dùng
nguoidung (
    user_id,
    full_name,
    email,
    organization
)

-- Table tác giả
tacgia (
    paper_id,
    user_id,
    author_order,
    is_contact
)

-- Table paper versions (optional)
paper_versions (
    version_id,
    paper_id,
    version_no,
    file_path,
    submitted_at,
    note
)
```

**Nếu thiếu field `decline_reason` trong table `phancongphanbien`:**
```sql
ALTER TABLE phancongphanbien ADD COLUMN decline_reason TEXT NULL;
```

### Bước 4: Test Backend API

Dùng Postman hoặc Thunder Client để test:

**1. Dashboard:**
```
GET http://127.0.0.1:8000/api/mobile/reviewer/dashboard
Headers: Authorization: Bearer {your_jwt_token}
```

**2. Get Assignments:**
```
GET http://127.0.0.1:8000/api/mobile/reviewer/assignments
GET http://127.0.0.1:8000/api/mobile/reviewer/assignments?status=PENDING
```

**3. Accept Assignment:**
```
POST http://127.0.0.1:8000/api/mobile/reviewer/assignments/20/accept
```

---

## 🔥 CHẠY FLUTTER APP

Sau khi backend đã cài xong:

```bash
cd /Users/trucquynhdang/Documents/KHOALUAN/huit_conference_app/huit_conference_app
flutter run
```

**Hoặc hot reload nếu app đang chạy:**
Nhấn `r` trong terminal Flutter

---

## ✅ CHECKLIST

- [ ] Copy `ReviewerMobileController.php` vào `app/Http/Controllers/Api/Mobile/`
- [ ] Thêm import controller vào `routes/api.php`
- [ ] Thêm 8 routes vào `routes/api.php`
- [ ] Kiểm tra database tables có đủ fields
- [ ] Test API bằng Postman
- [ ] Chạy Flutter app và test

---

## 🐛 TROUBLESHOOTING

### Lỗi "Class not found"
- Đảm bảo namespace đúng: `App\Http\Controllers\Api\Mobile`
- Chạy: `composer dump-autoload` trong thư mục Laravel

### Lỗi 404 Route not found
- Kiểm tra routes đã thêm đúng vị trí trong `auth:api` middleware
- Chạy: `php artisan route:list | grep reviewer` để xem routes

### Lỗi Database
- Kiểm tra table names chính xác
- Kiểm tra tất cả fields tồn tại
- Thêm field `decline_reason` nếu thiếu

### App Flutter vẫn lỗi
- Hot reload: nhấn `r` trong terminal
- Hoặc restart: nhấn `R` (shift + r)
- Hoặc stop và `flutter run` lại

---

## 📞 API ENDPOINTS SUMMARY

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/mobile/reviewer/dashboard` | Dashboard stats |
| GET | `/mobile/reviewer/assignments` | List assignments |
| GET | `/mobile/reviewer/assignments/{id}` | Assignment detail |
| POST | `/mobile/reviewer/assignments/{id}/accept` | Accept assignment |
| POST | `/mobile/reviewer/assignments/{id}/decline` | Decline assignment |
| GET | `/mobile/reviewer/reviews` | List reviews |
| GET | `/mobile/reviewer/reviews/{id}` | Review detail |
| POST | `/mobile/reviewer/reviews` | Submit review |

---

**Đã tạo xong! Giờ bạn cần:**
1. Copy controller vào Laravel backend
2. Thêm routes vào api.php
3. Test API
4. Reload Flutter app

Bạn có cần tôi giúp gì thêm không?

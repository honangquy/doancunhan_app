# 🧪 Test User Credentials

## Tạo User Test Trong Database

Chạy SQL này trong phpMyAdmin hoặc MySQL:

```sql
-- Tạo user test với password: "password"
INSERT INTO users (name, email, password, role, created_at, updated_at) 
VALUES (
  'Test Author', 
  'test@huit.edu.vn', 
  '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
  'author',
  NOW(),
  NOW()
);

-- Tạo reviewer test
INSERT INTO users (name, email, password, role, created_at, updated_at) 
VALUES (
  'Test Reviewer', 
  'reviewer@huit.edu.vn', 
  '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
  'reviewer',
  NOW(),
  NOW()
);

-- Tạo admin test
INSERT INTO users (name, email, password, role, created_at, updated_at) 
VALUES (
  'Test Admin', 
  'admin@huit.edu.vn', 
  '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
  'admin',
  NOW(),
  NOW()
);
```

## Test Credentials

**Author:**
- Email: `test@huit.edu.vn`
- Password: `password`

**Reviewer:**
- Email: `reviewer@huit.edu.vn`
- Password: `password`

**Admin:**
- Email: `admin@huit.edu.vn`
- Password: `password`

## Test với cURL

```bash
# Test login API
curl -X POST http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "test@huit.edu.vn",
    "password": "password"
  }' | python3 -m json.tool

# Expected response:
# {
#   "success": true,
#   "token": "1|abcdefghijk...",
#   "user": {
#     "id": 1,
#     "name": "Test Author",
#     "email": "test@huit.edu.vn",
#     "role": "author"
#   }
# }
```

## Hoặc Check Users Hiện Có

```sql
-- Xem tất cả users
SELECT id, name, email, role FROM users;

-- Reset password của user cụ thể (nếu quên)
UPDATE users 
SET password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'
WHERE email = 'admin@huit.edu.vn';
-- Password mới là: "password"
```

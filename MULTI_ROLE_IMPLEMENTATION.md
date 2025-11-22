# MULTI-ROLE IMPLEMENTATION GUIDE

## Tổng Quan

Hệ thống đã được cấu hình để hỗ trợ **MULTI-ROLE** - một user có thể có nhiều vai trò khác nhau (ADMIN, CHAIR, REVIEWER, AUTHOR, PC) và mỗi vai trò có thể gắn với một hội thảo cụ thể.

## Các File Đã Tạo/Cập Nhật

### 1. Models

#### `lib/models/user_role.dart` ✅
Model đại diện cho một vai trò của user:
- `roleCode`: Mã vai trò (ADMIN, CHAIR, REVIEWER, AUTHOR, PC)
- `conferenceId`: ID hội thảo (nullable)
- `conferenceTitle`: Tên hội thảo (nullable)
- `displayName`: Tên hiển thị tiếng Việt
- `scopeDescription`: Mô tả phạm vi (hội thảo hoặc toàn hệ thống)
- `icon`: Icon emoji cho từng vai trò

#### `lib/models/app_user.dart` ✅
Model đại diện cho thông tin user từ API:
- `userId`: ID người dùng
- `email`: Email
- `fullName`: Họ tên đầy đủ
- `phone`, `organization`, `avatar`: Thông tin bổ sung
- `initials`: Chữ cái viết tắt tên (dùng cho avatar)

### 2. Services

#### `lib/services/auth_service.dart` ✅
Đã được cập nhật để hỗ trợ multi-role:

**State mới:**
```dart
AppUser? _appUser;              // Thông tin user
List<UserRole> _roles = [];     // Danh sách vai trò
UserRole? _currentRole;         // Vai trò đang chọn
```

**Getters mới:**
- `appUser`: Thông tin AppUser
- `roles`: Danh sách vai trò
- `currentRole`: Vai trò hiện tại
- `hasRoles`: Kiểm tra có vai trò không
- `hasSelectedRole`: Kiểm tra đã chọn vai trò chưa

**Methods mới:**
- `setCurrentRole(UserRole role)`: Lưu vai trò được chọn
- `clearCurrentRole()`: Xóa vai trò hiện tại

**Login Flow:**
1. Parse `roles` array từ API response
2. Lưu AppUser + roles vào SharedPreferences
3. Reset `currentRole = null` (user phải chọn lại)
4. Return kết quả với danh sách roles

**Init Flow:**
1. Load token, user data, app_user, user_roles, current_role từ storage
2. Khôi phục state đầy đủ

**Logout Flow:**
1. Clear tất cả: token, user, app_user, user_roles, current_role
2. Reset state về null/empty

### 3. Screens

#### `lib/screens/auth/welcome_role_selection_screen.dart` ✅
Màn hình chọn vai trò với UI đẹp:

**Features:**
- Hiển thị avatar với initials
- Chào mừng với tên + email
- Danh sách vai trò dạng card với gradient
- Animation fade in + slide
- Staggered animation cho từng role card
- Màu sắc riêng cho từng role
- Icon emoji đặc trưng
- Hiển thị hội thảo hoặc "Toàn hệ thống"
- Nút đăng xuất

**Logic:**
1. Load user + roles từ AuthService
2. Nếu `roles.isEmpty` → hiện dialog "Chưa được gán vai trò"
3. User chọn role → `setCurrentRole()` → điều hướng đến dashboard tương ứng

**Dashboard Mapping:**
- ADMIN → `/admin/dashboard`
- CHAIR → `/chair/dashboard`
- REVIEWER → `/reviewer/dashboard`
- AUTHOR → `/author/dashboard`
- PC → `/chair/dashboard`

#### `lib/screens/auth/login_screen.dart` ✅
Đã cập nhật login flow:

**Old Flow:**
```
Login → Navigate directly to dashboard based on single role
```

**New Flow:**
```
Login → Check roles
  ├─ roles.isEmpty → Show error snackbar "Chưa được gán vai trò"
  └─ roles.length >= 1 → Navigate to /welcome
```

**Init Check:**
```
isAuthenticated + hasSelectedRole → Dashboard
isAuthenticated + hasRoles (no selected) → Welcome
Not authenticated → Stay on login
```

#### `lib/screens/splash_screen.dart` ✅
Cập nhật logic khởi động:

**Flow:**
```
Init AuthService
  ├─ Not authenticated → /login
  ├─ Has token + selected role → Dashboard
  ├─ Has token + roles (no selected) → /welcome
  └─ Has token + no roles → Logout → /login
```

### 4. Router

#### `lib/main.dart` ✅
Đã thêm route mới:
```dart
case '/welcome':
  return _buildRoute(const WelcomeRoleSelectionScreen());
```

## API Response Format

Backend API `/api/login` phải trả về format sau:

```json
{
  "status": true,
  "message": "Đăng nhập thành công",
  "token": "jwt_or_sanctum_token",
  "user": {
    "user_id": 11,
    "email": "abc@huit.edu.vn",
    "full_name": "Nguyễn Văn A"
  },
  "roles": [
    {
      "role_code": "ADMIN",
      "conference_id": null,
      "conference_title": null
    },
    {
      "role_code": "CHAIR",
      "conference_id": 8,
      "conference_title": "Hội thảo CNTT 2025"
    },
    {
      "role_code": "REVIEWER",
      "conference_id": 8,
      "conference_title": "Hội thảo CNTT 2025"
    }
  ]
}
```

## Storage Keys

Dữ liệu được lưu trong SharedPreferences:

| Key | Value | Type |
|-----|-------|------|
| `auth_token` | JWT token | String |
| `user_data` | Old User model (legacy) | JSON String |
| `app_user` | AppUser model | JSON String |
| `user_roles` | List<UserRole> | JSON String |
| `current_role` | UserRole đang chọn | JSON String |

## User Flow Diagram

```
┌─────────────┐
│ Splash      │
└──────┬──────┘
       │
       ▼
  Has token?
       ├─ No ──────────────────┐
       │                       │
       ▼                       ▼
  Has selected role?     ┌──────────┐
       ├─ No ────────┐   │  Login   │
       │             │   └─────┬────┘
       ▼             │         │
  Has roles?         │    Login OK?
       ├─ No ────┐   │         ├─ roles.isEmpty ─→ Show error
       │         │   │         │
       ▼         ▼   ▼         ▼
   Logout    ┌──────────┐  ┌──────────────┐
       │     │ Welcome  │  │   Welcome    │
       │     │  Role    │  │     Role     │
       │     │Selection │  │  Selection   │
       │     └─────┬────┘  └──────┬───────┘
       │           │               │
       │           └───────┬───────┘
       │                   │
       │              Select role
       │                   │
       │                   ▼
       │           ┌──────────────┐
       │           │  Dashboard   │
       │           │  (by role)   │
       │           └──────────────┘
       │
       └─────────────→ Login Screen
```

## Testing

### Test Credentials
Sử dụng account có nhiều roles để test:
```
Email: honangquy1@gmail.com
Password: Concac123!@#
```

### Test Cases

1. **Login với user có nhiều roles:**
   - ✅ Login thành công
   - ✅ Chuyển đến Welcome Screen
   - ✅ Hiển thị đầy đủ danh sách roles
   - ✅ Chọn role → Chuyển đến dashboard tương ứng

2. **Login với user không có role:**
   - ✅ Login thành công
   - ✅ Hiển thị message "Tài khoản chưa được gán vai trò"
   - ✅ Không điều hướng đi đâu

3. **Mở lại app (đã đăng nhập + đã chọn role):**
   - ✅ SplashScreen → Dashboard tương ứng (bỏ qua Welcome)

4. **Mở lại app (đã đăng nhập + chưa chọn role):**
   - ✅ SplashScreen → Welcome Screen

5. **Logout:**
   - ✅ Clear tất cả state
   - ✅ Quay về Login Screen

## Best Practices

1. **Luôn check `hasRoles` trước khi điều hướng**
2. **Luôn check `hasSelectedRole` để biết user đã chọn role chưa**
3. **Không auto-select role đầu tiên** - user phải tự chọn
4. **Khi switch role** - clear current role và quay về Welcome Screen
5. **Backend phải trả đúng format** - đặc biệt là mảng `roles`

## Future Enhancements

- [ ] Implement role switching (chuyển vai trò không cần logout)
- [ ] Call API `/api/switch-role` khi chọn role
- [ ] Cache selected role theo conference_id
- [ ] Remember last selected role
- [ ] Add role management screen
- [ ] Implement role-based permissions

## Troubleshooting

### Issue: "Tài khoản chưa được gán vai trò"
**Nguyên nhân:** Backend không trả mảng `roles` hoặc mảng rỗng
**Giải pháp:** Kiểm tra database table `vaitronguoidung` và đảm bảo user có ít nhất 1 role

### Issue: Không điều hướng sau khi chọn role
**Nguyên nhân:** Route không tồn tại hoặc roleCode không khớp
**Giải pháp:** Kiểm tra mapping trong `_getDashboardRoute()` và đảm bảo routes được define trong `main.dart`

### Issue: Mở lại app vẫn về login screen
**Nguyên nhân:** Token hoặc current_role bị clear
**Giải pháp:** Check SharedPreferences và log trong `SplashScreen._checkAuthAndNavigate()`

## Author
Implementation completed on: 15/11/2025

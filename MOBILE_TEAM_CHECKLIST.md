# 📱 REVIEWER MOBILE APP - IMPLEMENTATION CHECKLIST

## ✅ BACKEND (COMPLETED)

### API Endpoints Created:
- [x] `GET /api/mobile/reviewer/dashboard` - Dashboard statistics
- [x] `GET /api/mobile/reviewer/assignments` - List assignments (with filter)
- [x] `GET /api/mobile/reviewer/assignments/{id}` - Assignment details
- [x] `POST /api/mobile/reviewer/assignments/{id}/accept` - Accept assignment
- [x] `POST /api/mobile/reviewer/assignments/{id}/decline` - Decline assignment
- [x] `GET /api/mobile/reviewer/reviews` - List submitted reviews
- [x] `GET /api/mobile/reviewer/reviews/{id}` - Review details
- [x] `POST /api/mobile/reviewer/reviews` - Submit/update review

### Files Created:
- [x] `app/Http/Controllers/Api/ReviewerMobileController.php` - API Controller
- [x] `REVIEWER_MOBILE_API.md` - Full API documentation
- [x] `REVIEWER_MOBILE_API.postman_collection.json` - Postman test collection

### Database Status:
- [x] Fixed `PENDING_CHAIR_REVIEW` status code issue
- [x] Migration created: `2025_11_21_220359_add_pending_chair_review_status_to_trangthaibaibao.php`
- [x] Seeder updated: `LookupTablesSeeder.php` includes all status codes

---

## 🔧 MOBILE APP TEAM - TODO

### 1. Authentication Setup
- [ ] Implement JWT login
- [ ] Store token securely (Flutter Secure Storage)
- [ ] Handle token refresh
- [ ] Handle logout

### 2. Dashboard Screen
**API:** `GET /api/mobile/reviewer/dashboard`

**UI Elements:**
- [ ] Statistics cards:
  - Total assignments
  - Pending assignments
  - Accepted assignments
  - Completed reviews
  - Declined assignments
- [ ] Average review score display
- [ ] Recent assignments list (max 5)

### 3. Assignments List Screen
**API:** `GET /api/mobile/reviewer/assignments`

**Features:**
- [ ] Tab filters: All / Pending / Accepted / Completed / Declined
- [ ] Assignment card showing:
  - Paper title
  - Conference name
  - Assigned date
  - Deadline (if exists)
  - Status badge
  - Author name
- [ ] Pull to refresh
- [ ] Empty state when no assignments
- [ ] Navigation to assignment detail

### 4. Assignment Detail Screen
**API:** `GET /api/mobile/reviewer/assignments/{id}`

**Sections:**
- [ ] Paper information:
  - Title
  - Abstract (expandable)
  - Keywords
  - Authors list
- [ ] Conference information:
  - Conference name
  - Assigned by (Chair name)
  - Deadline
- [ ] Actions (if status = PENDING):
  - Accept button → Call accept API
  - Decline button → Show reason dialog → Call decline API
- [ ] Actions (if status = ACCEPTED):
  - Start Review button → Navigate to review form
- [ ] Paper download button
- [ ] Versions list (if multiple versions exist)
- [ ] Show existing review (if already submitted)

### 5. Accept Assignment Flow
**API:** `POST /api/mobile/reviewer/assignments/{id}/accept`

**Steps:**
- [ ] Show confirmation dialog
- [ ] Call API
- [ ] Show success message
- [ ] Update assignment status locally
- [ ] Enable "Start Review" button

### 6. Decline Assignment Flow
**API:** `POST /api/mobile/reviewer/assignments/{id}/decline`

**Steps:**
- [ ] Show dialog with reason input (required, max 500 chars)
- [ ] Validate reason not empty
- [ ] Call API with reason
- [ ] Show success message
- [ ] Update assignment status locally

### 7. Review Form Screen
**API:** `POST /api/mobile/reviewer/reviews`

**Form Fields:**
- [ ] Score inputs (1-10 scale):
  - Novelty score
  - Relevance score
  - Technical Quality score
  - Presentation score
  - References score
- [ ] Total score display (auto-calculated average)
- [ ] Detailed comments (required, min 50 chars, multiline)
- [ ] Recommendation dropdown:
  - Strong Accept
  - Accept
  - Weak Accept
  - Borderline
  - Weak Reject
  - Reject
  - Strong Reject
- [ ] File upload (optional, PDF/DOC/DOCX, max 10MB)
- [ ] Save Draft button
- [ ] Submit Final button

**Validation:**
- [ ] All scores required for final submission
- [ ] Comments min 50 chars for final submission
- [ ] Recommendation required for final submission
- [ ] File size validation

**Draft Mode:**
- [ ] Allow saving incomplete review
- [ ] Auto-save every 2 minutes
- [ ] Show draft indicator
- [ ] Can resume editing later

### 8. Reviews List Screen
**API:** `GET /api/mobile/reviewer/reviews`

**Features:**
- [ ] Statistics section:
  - Total reviews
  - Average score
  - Accept count
  - Reject count
- [ ] Review cards showing:
  - Paper title
  - Conference name
  - Recommendation badge
  - Total score
  - Submitted date
- [ ] Filter by recommendation
- [ ] Sort by date
- [ ] Navigation to review detail

### 9. Review Detail Screen (Read-only)
**API:** `GET /api/mobile/reviewer/reviews/{id}`

**Display:**
- [ ] Paper information
- [ ] All scores
- [ ] Total score
- [ ] Detailed comments
- [ ] Recommendation
- [ ] Submitted date
- [ ] Review file download (if exists)

### 10. Error Handling
- [ ] Network errors (show retry option)
- [ ] 401 Unauthorized (redirect to login)
- [ ] 403 Forbidden (show error message)
- [ ] 404 Not Found (show not found screen)
- [ ] 422 Validation errors (show field-specific errors)
- [ ] 500 Server errors (show generic error)

### 11. Offline Support (Optional)
- [ ] Cache assignments list
- [ ] Cache assignment details
- [ ] Save draft reviews locally
- [ ] Sync when back online

### 12. Notifications (Optional)
- [ ] New assignment notification
- [ ] Deadline reminder (3 days, 1 day before)
- [ ] Assignment accepted/declined confirmation

---

## 📋 TESTING CHECKLIST

### Backend API Testing (Using Postman):
- [ ] Import `REVIEWER_MOBILE_API.postman_collection.json`
- [ ] Set `base_url` variable to `http://127.0.0.1:8000`
- [ ] Set `token` variable to valid JWT token
- [ ] Test all 10 API endpoints
- [ ] Verify response formats match documentation
- [ ] Test error scenarios (invalid token, missing fields, etc.)

### Mobile App Testing:
- [ ] Login as reviewer user
- [ ] View dashboard with correct statistics
- [ ] View assignments list
- [ ] Filter assignments by status
- [ ] View assignment detail
- [ ] Accept assignment
- [ ] Decline assignment with reason
- [ ] Download paper PDF
- [ ] Submit review as draft
- [ ] Complete and submit final review
- [ ] View submitted reviews list
- [ ] View review detail

---

## 🔑 SAMPLE TEST DATA

### Test Reviewer Account:
```
Email: reviewer@example.com
Password: (check with backend team)
User ID: (check database)
```

### Sample Assignment IDs:
```
Check database: SELECT id FROM reviewer_assignments WHERE user_id = {reviewer_user_id}
Example: Assignment ID = 20
```

### Sample JWT Token Generation:
```bash
# Login API (check existing auth endpoints)
POST /api/login
{
  "email": "reviewer@example.com",
  "password": "your_password"
}

# Response will contain token
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGci..."
}
```

---

## 📚 DOCUMENTATION REFERENCE

1. **API Documentation:** `REVIEWER_MOBILE_API.md`
2. **Postman Collection:** `REVIEWER_MOBILE_API.postman_collection.json`
3. **Web Version Reference:**
   - Assignments: `http://127.0.0.1:8000/reviewer/assignments`
   - Reviews: `http://127.0.0.1:8000/reviewer/reviews`

---

## 🚀 NEXT STEPS

1. **Backend Team:**
   - ✅ API endpoints created
   - ✅ Documentation written
   - ✅ Postman collection ready
   - [ ] Test all endpoints with real data
   - [ ] Provide sample JWT token for testing

2. **Mobile Team:**
   - [ ] Review API documentation
   - [ ] Import Postman collection and test APIs
   - [ ] Implement UI screens following checklist
   - [ ] Integrate API calls
   - [ ] Test end-to-end flows
   - [ ] Report any issues to backend team

---

## 💡 TIPS FOR MOBILE TEAM

1. **API Response Handling:**
   - Always check `success` field first
   - Handle `message` for user feedback
   - Parse `data` object for actual content

2. **Status Management:**
   - Store assignment/review status locally
   - Update after API calls
   - Use status to control UI visibility

3. **File Upload:**
   - Use multipart/form-data
   - Show upload progress
   - Validate file type and size before upload

4. **Performance:**
   - Implement pagination if needed (can add to API later)
   - Cache images and PDFs
   - Use lazy loading for lists

5. **UX Considerations:**
   - Show loading indicators during API calls
   - Implement pull-to-refresh
   - Add confirmation dialogs for critical actions
   - Provide helpful error messages

---

## 📞 SUPPORT

**Backend Team Contact:**
- Developer: (Your Name)
- Email: (Your Email)
- Slack: (Your Channel)

**Questions?**
- Check `REVIEWER_MOBILE_API.md` first
- Test with Postman collection
- Report issues with API request/response examples

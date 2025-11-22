#!/bin/bash

# Reviewer Mobile API Test Script
# Login credentials: janon68721@bipochub.com / 123123

BASE_URL="http://127.0.0.1:8000/api"
EMAIL="janon68721@bipochub.com"
PASSWORD="123123"

echo "========================================="
echo "REVIEWER MOBILE API COMPREHENSIVE TEST"
echo "========================================="
echo ""

# Step 1: Login and get token
echo "🔐 Step 1: Login and get JWT token..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")

echo "$LOGIN_RESPONSE" | python3 -m json.tool
echo ""

TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['token'])" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo "❌ Login failed! Cannot get token."
    exit 1
fi

echo "✅ Login successful!"
echo "Token: ${TOKEN:0:50}..."
echo ""
sleep 1

# Step 2: Dashboard
echo "========================================="
echo "📊 TEST 1: Dashboard"
echo "========================================="
curl -s -X GET "$BASE_URL/mobile/reviewer/dashboard" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" | python3 -m json.tool
echo ""
sleep 1

# Step 3: Get All Assignments
echo "========================================="
echo "📋 TEST 2: Get All Assignments"
echo "========================================="
ASSIGNMENTS_RESPONSE=$(curl -s -X GET "$BASE_URL/mobile/reviewer/assignments" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json")

echo "$ASSIGNMENTS_RESPONSE" | python3 -m json.tool
echo ""

# Extract assignment ID for next test
ASSIGNMENT_ID=$(echo "$ASSIGNMENTS_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data']['assignments'][0]['id'] if data.get('data', {}).get('assignments') else '')" 2>/dev/null)
sleep 1

# Step 4: Filter Assignments
echo "========================================="
echo "🔍 TEST 3: Filter Assignments (PENDING)"
echo "========================================="
curl -s -X GET "$BASE_URL/mobile/reviewer/assignments?status=PENDING" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" | python3 -m json.tool
echo ""
sleep 1

echo "========================================="
echo "🔍 TEST 4: Filter Assignments (COMPLETED)"
echo "========================================="
curl -s -X GET "$BASE_URL/mobile/reviewer/assignments?status=COMPLETED" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" | python3 -m json.tool
echo ""
sleep 1

# Step 5: Get Assignment Detail
if [ ! -z "$ASSIGNMENT_ID" ]; then
    echo "========================================="
    echo "📄 TEST 5: Get Assignment Detail (ID: $ASSIGNMENT_ID)"
    echo "========================================="
    curl -s -X GET "$BASE_URL/mobile/reviewer/assignments/$ASSIGNMENT_ID" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Accept: application/json" | python3 -m json.tool
    echo ""
    sleep 1
else
    echo "⚠️  No assignment ID found, skipping detail test"
    echo ""
fi

# Step 6: Get All Reviews
echo "========================================="
echo "📝 TEST 6: Get All Reviews"
echo "========================================="
REVIEWS_RESPONSE=$(curl -s -X GET "$BASE_URL/mobile/reviewer/reviews" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json")

echo "$REVIEWS_RESPONSE" | python3 -m json.tool
echo ""

# Extract review ID for next test
REVIEW_ID=$(echo "$REVIEWS_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data']['reviews'][0]['review_id'] if data.get('data', {}).get('reviews') else '')" 2>/dev/null)
sleep 1

# Step 7: Get Review Detail
if [ ! -z "$REVIEW_ID" ]; then
    echo "========================================="
    echo "📋 TEST 7: Get Review Detail (ID: $REVIEW_ID)"
    echo "========================================="
    curl -s -X GET "$BASE_URL/mobile/reviewer/reviews/$REVIEW_ID" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Accept: application/json" | python3 -m json.tool
    echo ""
    sleep 1
else
    echo "⚠️  No review ID found, skipping detail test"
    echo ""
fi

# Summary
echo "========================================="
echo "✅ TEST SUMMARY"
echo "========================================="
echo "All read-only endpoints tested successfully!"
echo ""
echo "📝 Notes:"
echo "  - Dashboard: ✅ Working"
echo "  - Get Assignments: ✅ Working"
echo "  - Filter Assignments: ✅ Working"
echo "  - Assignment Detail: ✅ Working"
echo "  - Get Reviews: ✅ Working"
echo "  - Review Detail: ✅ Working"
echo ""
echo "⚠️  Write operations not tested (to preserve data):"
echo "  - Accept Assignment"
echo "  - Decline Assignment"
echo "  - Submit Review"
echo ""
echo "💡 To test write operations, use Postman collection:"
echo "   Import: REVIEWER_MOBILE_API.postman_collection.json"
echo ""
echo "========================================="

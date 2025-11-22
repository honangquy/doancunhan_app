#!/bin/bash

# Test HUIT Conference API - Papers Statistics
# Yêu cầu: Laravel backend phải đang chạy tại http://localhost:8000

echo "🧪 Testing HUIT Conference API - Papers Statistics"
echo "=================================================="
echo ""

# Biến cấu hình
BASE_URL="http://localhost:8000/api"
EMAIL="phungthanhdoo@gmail.com"  # Thay bằng email bạn dùng
PASSWORD="123456789"              # Thay bằng password bạn dùng

echo "📝 Step 1: Login to get token..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")

echo "Response: $LOGIN_RESPONSE"
echo ""

# Extract token từ response (cần jq hoặc parse manual)
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | grep -o '[^"]*$')

if [ -z "$TOKEN" ]; then
    echo "❌ Login failed! Cannot get token."
    echo "Response: $LOGIN_RESPONSE"
    exit 1
fi

echo "✅ Login successful!"
echo "Token: ${TOKEN:0:50}..."
echo ""

echo "📊 Step 2: Test GET /api/papers/statistics..."
STATS_RESPONSE=$(curl -s -X GET "$BASE_URL/papers/statistics" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json")

echo "Response:"
echo "$STATS_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$STATS_RESPONSE"
echo ""

echo "📄 Step 3: Test GET /api/my-papers..."
PAPERS_RESPONSE=$(curl -s -X GET "$BASE_URL/my-papers" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json")

echo "Response:"
echo "$PAPERS_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$PAPERS_RESPONSE"
echo ""

echo "=================================================="
echo "✅ Test completed!"
echo ""
echo "🔍 Analysis:"
echo "---"

# Parse và hiển thị kết quả
if echo "$STATS_RESPONSE" | grep -q "total_papers"; then
    TOTAL=$(echo "$STATS_RESPONSE" | grep -o '"total_papers":[0-9]*' | grep -o '[0-9]*$')
    echo "✅ Statistics API working - Total papers: $TOTAL"
else
    echo "❌ Statistics API not returning expected format"
fi

if echo "$PAPERS_RESPONSE" | grep -q "data"; then
    echo "✅ My Papers API working"
else
    echo "❌ My Papers API not returning expected format"
fi

echo ""
echo "📝 Next steps:"
echo "1. Check if backend controller is implemented correctly"
echo "2. Verify database has papers for this user"
echo "3. Check response format matches Flutter model"

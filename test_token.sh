#!/bin/bash

# Test JWT Token Validity
# This script tests if the current JWT token is still valid

echo "======================================"
echo "🔐 TESTING JWT TOKEN VALIDITY"
echo "======================================"
echo ""

BACKEND_URL="http://127.0.0.1:8000"

# Extract token from the error log (you provided)
TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvYXBpL2F1dGgvbG9naW4iLCJpYXQiOjE3NjMwNTA0MzksImV4cCI6MTc2MzA1NDAzOSwibmJmIjoxNzYzMDUwNDM5LCJqdGkiOiJ4RWZnUEF4U29JODlPWmhKIiwic3ViIjoiMTkiLCJwcnYiOiI3ZTliNWE0ZTYyNzJkY2QwMGY4NWQzYTZlNDhmYWUzN2U5MzBiZDUxIn0.T00RxkUDU1LufrTVNQG1xTi0e5jg_J0Y1qu8q8f86JE"

echo "📝 Token (first 50 chars): ${TOKEN:0:50}..."
echo ""

# Decode JWT payload (base64)
PAYLOAD=$(echo $TOKEN | cut -d'.' -f2)
# Add padding if needed
PADDING=$((4 - ${#PAYLOAD} % 4))
if [ $PADDING -ne 4 ]; then
    PAYLOAD="${PAYLOAD}$(printf '=%.0s' $(seq 1 $PADDING))"
fi

echo "📋 JWT Payload:"
echo $PAYLOAD | base64 -d 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "Could not decode"
echo ""

# Get current timestamp
CURRENT_TIME=$(date +%s)
echo "🕐 Current Time: $CURRENT_TIME ($(date))"

# Extract exp from payload
EXP=$(echo $PAYLOAD | base64 -d 2>/dev/null | python3 -c "import sys, json; print(json.load(sys.stdin).get('exp', 0))" 2>/dev/null)
echo "⏰ Token Expires: $EXP ($(date -r $EXP 2>/dev/null || echo 'invalid'))"
echo ""

if [ $CURRENT_TIME -gt $EXP ]; then
    echo "❌ TOKEN EXPIRED!"
    echo "   Expired $(( ($CURRENT_TIME - $EXP) / 60 )) minutes ago"
    echo ""
    echo "💡 Solution: User needs to login again to get a new token"
else
    echo "✅ Token is still valid"
    echo "   Expires in $(( ($EXP - $CURRENT_TIME) / 60 )) minutes"
fi

echo ""
echo "======================================"
echo "🧪 TESTING API WITH TOKEN"
echo "======================================"
echo ""

echo "Testing /api/announcements..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Accept: application/json" \
    "$BACKEND_URL/api/announcements")

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Status: $HTTP_CODE - Token works!"
elif [ "$HTTP_CODE" = "401" ]; then
    echo "❌ Status: $HTTP_CODE - Unauthorized (token invalid/expired)"
else
    echo "⚠️  Status: $HTTP_CODE"
fi

echo ""
echo "Testing /api/auth/profile..."
PROFILE_RESPONSE=$(curl -s \
    -H "Authorization: Bearer $TOKEN" \
    -H "Accept: application/json" \
    "$BACKEND_URL/api/auth/profile")

echo "$PROFILE_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$PROFILE_RESPONSE"

echo ""
echo "======================================"
echo "📋 RECOMMENDATIONS"
echo "======================================"
echo ""
echo "If token is expired:"
echo "  1. User should logout and login again"
echo "  2. Or implement auto token refresh"
echo ""
echo "If token is valid but still 401:"
echo "  1. Check backend JWT secret key"
echo "  2. Check backend middleware"
echo "  3. Check token format in Authorization header"
echo ""

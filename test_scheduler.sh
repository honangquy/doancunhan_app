#!/bin/bash

# Test Scheduler Status
# This script checks if the Laravel scheduler is running properly

echo "======================================"
echo "🔍 CHECKING LARAVEL SCHEDULER STATUS"
echo "======================================"
echo ""

# Get backend URL from user or use default
BACKEND_URL=${1:-"http://127.0.0.1:8000"}
echo "📡 Backend URL: $BACKEND_URL"
echo ""

# Check if backend is running
echo "1️⃣ Checking if backend is running..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL/api/health" 2>/dev/null)
if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "404" ]; then
    echo "   ✅ Backend is running"
else
    echo "   ❌ Backend is NOT running (HTTP $HTTP_STATUS)"
    echo ""
    echo "💡 Start backend first:"
    echo "   cd /path/to/backend"
    echo "   php artisan serve"
    exit 1
fi
echo ""

# Test creating a scheduled announcement
echo "2️⃣ Testing announcement creation..."
echo "   This will create a test announcement scheduled for now + 2 minutes"
echo ""

# Get current time + 2 minutes in the correct format
SCHEDULED_TIME=$(date -u -v+2M "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -u -d "+2 minutes" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)

echo "   📅 Scheduled time: $SCHEDULED_TIME"
echo ""

# Check for scheduled announcements in database
echo "3️⃣ Checking for pending SCHEDULED announcements..."
echo ""
echo "   ⚠️  You need to manually check the database:"
echo "   SELECT announcement_id, title, status, scheduled_at, sent_at"
echo "   FROM thongbao"
echo "   WHERE status = 'SCHEDULED'"
echo "   ORDER BY scheduled_at DESC"
echo "   LIMIT 5;"
echo ""

# Check if scheduler process is running
echo "4️⃣ Checking if scheduler process is running..."
echo ""
echo "   On macOS:"
ps aux | grep -E "schedule:run|artisan.*schedule" | grep -v grep
if [ $? -eq 0 ]; then
    echo "   ✅ Scheduler process found"
else
    echo "   ❌ No scheduler process found"
    echo ""
    echo "   💡 To start scheduler manually:"
    echo "   cd /path/to/backend"
    echo "   nohup bash -c 'while true; do php artisan schedule:run; sleep 60; done' > storage/logs/scheduler.log 2>&1 &"
fi
echo ""

# Check cron jobs
echo "5️⃣ Checking crontab..."
crontab -l 2>/dev/null | grep -E "schedule:run|artisan.*schedule"
if [ $? -eq 0 ]; then
    echo "   ✅ Cron job found"
else
    echo "   ❌ No cron job found"
    echo ""
    echo "   💡 To add cron job:"
    echo "   crontab -e"
    echo "   Add this line:"
    echo "   * * * * * cd /Applications/XAMPP/xamppfiles/htdocs/doancunhan && /usr/bin/php artisan schedule:run >> /dev/null 2>&1"
fi
echo ""

echo "======================================"
echo "📋 SUMMARY"
echo "======================================"
echo ""
echo "✅ Things to verify:"
echo "   1. Backend is running"
echo "   2. Scheduler process is running (check process above)"
echo "   3. Crontab is configured (check cron above)"
echo "   4. Database has SCHEDULED announcements waiting"
echo ""
echo "🔧 Quick fixes if announcements are not being sent:"
echo ""
echo "   A. Start scheduler manually (temporary):"
echo "      cd /path/to/backend"
echo "      while true; do php artisan schedule:run; sleep 60; done"
echo ""
echo "   B. Start scheduler as background process:"
echo "      cd /path/to/backend"
echo "      nohup bash -c 'while true; do php artisan schedule:run; sleep 60; done' > storage/logs/scheduler.log 2>&1 &"
echo ""
echo "   C. Setup crontab (permanent):"
echo "      crontab -e"
echo "      * * * * * cd /path/to/backend && php artisan schedule:run >> /dev/null 2>&1"
echo ""
echo "   D. Test scheduler immediately:"
echo "      cd /path/to/backend"
echo "      php artisan schedule:run"
echo ""
echo "======================================"

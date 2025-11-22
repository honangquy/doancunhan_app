#!/bin/bash

# Check Pending Announcements
# This script helps diagnose announcement delivery issues

echo "======================================"
echo "📊 CHECKING ANNOUNCEMENT STATUS"
echo "======================================"
echo ""

BACKEND_PATH="/Applications/XAMPP/xamppfiles/htdocs/doancunhan"

if [ ! -d "$BACKEND_PATH" ]; then
    echo "❌ Backend path not found: $BACKEND_PATH"
    echo "Please update BACKEND_PATH in this script."
    exit 1
fi

cd "$BACKEND_PATH"

echo "1️⃣ Checking for SCHEDULED announcements..."
echo ""
echo "Running query:"
echo "SELECT announcement_id, title, status, scheduled_at, sent_at, created_at"
echo "FROM thongbao WHERE status = 'SCHEDULED' ORDER BY scheduled_at DESC LIMIT 10;"
echo ""

php artisan tinker --execute="
\$announcements = DB::table('thongbao')
    ->where('status', 'SCHEDULED')
    ->orderBy('scheduled_at', 'desc')
    ->limit(10)
    ->get(['announcement_id', 'title', 'status', 'scheduled_at', 'sent_at', 'created_at']);

if (\$announcements->isEmpty()) {
    echo '✅ No SCHEDULED announcements found (all have been sent or none created yet)\n';
} else {
    echo '⚠️  Found ' . \$announcements->count() . ' SCHEDULED announcements:\n\n';
    foreach (\$announcements as \$ann) {
        echo '  ID: ' . \$ann->announcement_id . '\n';
        echo '  Title: ' . \$ann->title . '\n';
        echo '  Status: ' . \$ann->status . '\n';
        echo '  Scheduled: ' . \$ann->scheduled_at . '\n';
        echo '  Created: ' . \$ann->created_at . '\n';
        echo '  ---\n';
    }
    
    echo '\n💡 These announcements are waiting to be sent!\n';
    echo 'The scheduler should process them when scheduled_at <= NOW()\n';
}
"

echo ""
echo "2️⃣ Checking for recently SENT announcements..."
echo ""

php artisan tinker --execute="
\$announcements = DB::table('thongbao')
    ->where('status', 'SENT')
    ->orderBy('sent_at', 'desc')
    ->limit(5)
    ->get(['announcement_id', 'title', 'status', 'scheduled_at', 'sent_at']);

if (\$announcements->isEmpty()) {
    echo '❌ No SENT announcements found\n';
} else {
    echo '✅ Found ' . \$announcements->count() . ' recently sent announcements:\n\n';
    foreach (\$announcements as \$ann) {
        echo '  ID: ' . \$ann->announcement_id . '\n';
        echo '  Title: ' . \$ann->title . '\n';
        echo '  Scheduled: ' . \$ann->scheduled_at . '\n';
        echo '  Sent: ' . \$ann->sent_at . '\n';
        echo '  ---\n';
    }
}
"

echo ""
echo "3️⃣ Checking current time vs scheduled times..."
echo ""

php artisan tinker --execute="
echo 'Current server time: ' . now() . '\n\n';

\$pending = DB::table('thongbao')
    ->where('status', 'SCHEDULED')
    ->where('scheduled_at', '<=', now())
    ->count();

if (\$pending > 0) {
    echo '🔴 Found ' . \$pending . ' announcements that SHOULD be sent now!\n';
    echo '   These announcements have scheduled_at <= current time\n';
    echo '   If scheduler is running, they should be processed within 1 minute\n';
} else {
    echo '✅ No overdue announcements\n';
}
"

echo ""
echo "======================================"
echo "📋 DIAGNOSIS"
echo "======================================"
echo ""
echo "If you see SCHEDULED announcements above:"
echo "  → Scheduler is NOT processing them"
echo "  → Run: ./start_scheduler.sh"
echo ""
echo "If no SCHEDULED but you just created one:"
echo "  → Check if scheduled_at is in the future (+1-2 mins)"
echo "  → Wait for scheduler to run (every 1 minute)"
echo ""
echo "If you see SENT announcements:"
echo "  → Scheduler IS working!"
echo "  → Check if users received the notifications"
echo ""

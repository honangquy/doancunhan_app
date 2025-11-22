#!/bin/bash

# Start Laravel Scheduler
# This script will start the Laravel scheduler to process announcements

echo "======================================"
echo "🚀 STARTING LARAVEL SCHEDULER"
echo "======================================"
echo ""

# Find the backend path
BACKEND_PATH="/Applications/XAMPP/xamppfiles/htdocs/doancunhan"

if [ ! -d "$BACKEND_PATH" ]; then
    echo "❌ Backend path not found: $BACKEND_PATH"
    echo ""
    echo "Please update BACKEND_PATH in this script to point to your backend directory."
    exit 1
fi

echo "📁 Backend path: $BACKEND_PATH"
cd "$BACKEND_PATH"
echo ""

# Check if already running
EXISTING_PROCESS=$(ps aux | grep -E "schedule:run|artisan.*schedule" | grep -v grep)
if [ ! -z "$EXISTING_PROCESS" ]; then
    echo "⚠️  Scheduler is already running:"
    echo "$EXISTING_PROCESS"
    echo ""
    read -p "Do you want to restart it? (y/n): " RESTART
    if [ "$RESTART" = "y" ] || [ "$RESTART" = "Y" ]; then
        echo "Stopping existing scheduler..."
        pkill -f "schedule:run"
        pkill -f "artisan.*schedule"
        sleep 2
    else
        echo "Keeping existing scheduler running."
        exit 0
    fi
fi

# Create logs directory if not exists
mkdir -p storage/logs

echo "🔄 Starting scheduler in background..."
echo ""

# Start scheduler
nohup bash -c 'while true; do php artisan schedule:run; sleep 60; done' > storage/logs/scheduler.log 2>&1 &

SCHEDULER_PID=$!

echo "✅ Scheduler started with PID: $SCHEDULER_PID"
echo ""

# Wait a moment and verify it's running
sleep 2

PROCESS_CHECK=$(ps -p $SCHEDULER_PID)
if [ $? -eq 0 ]; then
    echo "✅ Scheduler is running successfully!"
    echo ""
    echo "📋 Process info:"
    ps aux | grep -E "schedule:run|artisan.*schedule" | grep -v grep
    echo ""
    echo "📝 Logs location: $BACKEND_PATH/storage/logs/scheduler.log"
    echo ""
    echo "💡 To view logs in real-time:"
    echo "   tail -f $BACKEND_PATH/storage/logs/scheduler.log"
    echo ""
    echo "💡 To stop scheduler:"
    echo "   pkill -f 'schedule:run'"
else
    echo "❌ Failed to start scheduler"
    echo ""
    echo "Check logs at: $BACKEND_PATH/storage/logs/scheduler.log"
fi

echo ""
echo "======================================"
echo "🧪 TESTING SCHEDULER"
echo "======================================"
echo ""
echo "Running scheduler once to test..."
php artisan schedule:run

echo ""
echo "✅ Done! Scheduler is now running every minute."
echo ""
echo "📊 Next steps:"
echo "   1. Create a test announcement in the app"
echo "   2. Wait 1-2 minutes"
echo "   3. Check if the announcement is sent (status changes to SENT)"
echo ""

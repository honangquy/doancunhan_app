#!/bin/bash

# Script để chạy Flutter app trên iOS Simulator
# Sử dụng: ./run_ios.sh

cd /Users/trucquynhdang/Documents/KHOALUAN/huit_conference_app/huit_conference_app

echo "🚀 Starting iOS Simulator..."
open -a Simulator

echo "⏳ Waiting for simulator to boot..."
sleep 5

echo "📱 Booting iPhone 16 Pro Max..."
xcrun simctl boot C7190D6D-FFAF-42BA-9C82-13DDDC9ACC9E 2>/dev/null || echo "Simulator already booted"

echo "🔨 Building and running Flutter app..."
flutter run -d C7190D6D-FFAF-42BA-9C82-13DDDC9ACC9E

echo "✅ Done!"

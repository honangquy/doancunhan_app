#!/bin/bash

# Fix iOS Build - Framework 'Flutter' not found
# Run this script to fix common iOS build issues

set -e

echo "🔧 Fixing iOS build issues..."

# Navigate to project root
cd /Users/trucquynhdang/Documents/KHOALUAN/huit_conference_app/huit_conference_app

echo ""
echo "📦 Step 1: Deintegrating CocoaPods..."
cd ios
pod deintegrate || true

echo ""
echo "🧹 Step 2: Cleaning Flutter build..."
cd ..
flutter clean

echo ""
echo "📥 Step 3: Getting Flutter dependencies..."
flutter pub get

echo ""
echo "📦 Step 4: Installing CocoaPods..."
cd ios
pod install --repo-update

echo ""
echo "🔨 Step 5: Building iOS app..."
cd ..
flutter build ios --debug --no-codesign

echo ""
echo "✅ iOS build fixed!"
echo ""
echo "🚀 Now you can run: flutter run"

#!/bin/bash

echo "🔨 Building iOS app to generate Flutter.framework..."

cd /Users/trucquynhdang/Documents/KHOALUAN/huit_conference_app/huit_conference_app

# Build iOS app (this will create Flutter.framework)
flutter build ios --debug --no-codesign

echo ""
echo "✅ Build complete! Check if Flutter.framework was created:"
ls -la ios/Flutter/Flutter.framework 2>/dev/null && echo "✅ Flutter.framework exists!" || echo "❌ Flutter.framework NOT found"

echo ""
echo "Now try running: flutter run"

#!/bin/bash

echo "🔍 Detecting Mac IP address..."

# Get WiFi IP
WIFI_IP=$(ipconfig getifaddr en0 2>/dev/null)

# Get Ethernet IP if WiFi not available
if [ -z "$WIFI_IP" ]; then
  WIFI_IP=$(ipconfig getifaddr en1 2>/dev/null)
fi

if [ -z "$WIFI_IP" ]; then
  echo "❌ Could not detect IP address"
  echo "Please check your network connection"
  exit 1
fi

echo "✅ Your Mac IP: $WIFI_IP"
echo ""
echo "📝 Update lib/utils/api_config.dart:"
echo "   Change 'YOUR_MAC_IP' to '$WIFI_IP'"
echo ""
echo "🔧 Or run this command:"
echo "   sed -i '' 's/YOUR_MAC_IP/$WIFI_IP/g' lib/utils/api_config.dart"
echo ""
echo "⚠️  Make sure your iPhone and Mac are on the SAME WiFi network!"
echo ""
echo "🚀 Then run:"
echo "   flutter run"

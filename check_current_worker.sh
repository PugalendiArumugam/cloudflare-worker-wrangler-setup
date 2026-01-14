#!/bin/bash
echo "🔍 CHECKING CURRENT WORKER"

# Test what we actually get
TEST_URL="https://www.theindiamirror.com/homescrtopnews/current-check-$(date +%s)"
echo "URL: $TEST_URL"

echo -e "\nResponse (first 100 chars):"
RESPONSE=$(curl -s "$TEST_URL")
echo "$RESPONSE" | head -c 100

echo -e "\n\nHeaders:"
curl -sI "$TEST_URL" | head -15

echo -e "\n🎯 Analysis:"
if echo "$RESPONSE" | grep -q "<!DOCTYPE\|<html"; then
    echo "❌ FAIL: Getting HTML - Worker NOT running"
    echo "   This means the caching worker is not deployed"
elif [ -z "$RESPONSE" ]; then
    echo "⚠️ WARNING: Empty response"
else
    echo "✅ SUCCESS: Not HTML - Worker might be running"
    echo "   Actual response start:"
    echo "$RESPONSE" | head -3
fi

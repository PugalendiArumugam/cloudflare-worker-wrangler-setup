#!/bin/bash
echo "🔍 CHECKING CURRENT WORKER"

# Test what response we get
TEST_URL="https://www.theindiamirror.com/homescrtopnews/check-$(date +%s)"
echo "Test URL: $TEST_URL"

echo -e "\nResponse (first 200 chars):"
curl -s "$TEST_URL" | head -c 200

echo -e "\n\nFull headers:"
curl -sI "$TEST_URL" | head -20

echo -e "\n🎯 Analysis:"
RESPONSE=$(curl -s "$TEST_URL")
if echo "$RESPONSE" | grep -q "WORKER IS WORKING"; then
    echo "✅ Original test worker is still running"
    echo "❌ Caching worker was NOT deployed"
elif echo "$RESPONSE" | grep -q "DOCTYPE\|html"; then
    echo "❌ NO worker running (getting normal HTML)"
else
    echo "⚠️ Unknown response - worker may have different code"
fi

#!/bin/bash
echo "🔍 CHECKING IF WORKER EXISTS"

echo "1. Checking deployments..."
echo "=========================="
wrangler deployments list 2>&1 | head -10

echo -e "\n2. Testing worker response..."
echo "==============================="
TEST_URL="https://www.theindiamirror.com/homescrtopnews/exist-check-$(date +%s)"
echo "Test URL: $TEST_URL"

echo -e "\nMaking request..."
RESPONSE=$(curl -s "$TEST_URL" 2>/dev/null)

echo "First 50 characters of response:"
echo "$RESPONSE" | head -c 50

echo -e "\n\n3. Checking response type..."
echo "=============================="
if echo "$RESPONSE" | grep -q "<!DOCTYPE\|<html"; then
    echo "❌ RESULT: Getting HTML page"
    echo "   This means: NO worker is intercepting the request"
    echo "   The request goes directly to your origin server (Wix)"
elif [ -z "$RESPONSE" ]; then
    echo "⚠️ RESULT: Empty response"
    echo "   Could be 404 or other error"
else
    echo "✅ RESULT: Not HTML - might be worker response"
    echo "   Full response start:"
    echo "$RESPONSE" | head -3
fi

echo -e "\n4. Checking headers..."
echo "======================="
curl -sI "$TEST_URL" 2>/dev/null | grep -E "X-|CF-Worker|Via:" | head -5

echo -e "\n5. Summary:"
echo "============"
if echo "$RESPONSE" | grep -q "<!DOCTYPE"; then
    echo "❌ WORKER DOES NOT EXIST or NOT INTERCEPTING"
    echo "   Solution: Deploy worker with correct routes"
else
    echo "⚠️ UNKNOWN - Check Cloudflare Dashboard manually:"
    echo "   https://dash.cloudflare.com/8f0cd6b783d20fe2ea5f2808f5d2eeaf/workers/services"
fi

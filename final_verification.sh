#!/bin/bash
echo "✅ FINAL VERIFICATION"

# Test a brand new URL
TEST_URL="https://www.theindiamirror.com/homescrtopnews/final-verify-$(date +%s)"

echo "1. Testing cache behavior:"
echo "First request to $TEST_URL"
echo -n "Cache status: "
curl -sI "$TEST_URL" | grep "X-Cache-Status" | head -1 || echo "No header"

sleep 2

echo -e "\nSecond request (should be cached):"
echo -n "Cache status: "
curl -sI "$TEST_URL" | grep "X-Cache-Status" | head -1 || echo "No header"

echo -e "\n2. Testing your fresh articles:"

ARTICLES=(
  "2020e88d-2478-4923-b4d1-2025f8381319"
  "99678c0b-b99e-40b3-a5da-9c14ebf9d560"
)

for article in "${ARTICLES[@]}"; do
  URL="https://www.theindiamirror.com/homescrtopnews/$article"
  echo -e "\nArticle: $(echo $article | cut -c1-8)..."
  echo -n "Cache status: "
  curl -sI "$URL" | grep "X-Cache-Status" | head -1 || echo "Not cached yet"
done

echo -e "\n3. Check Cloudflare Dashboard:"
echo "   - Workers & Pages → working-cache → Logs"
echo "   - Should see 'Cache MISS' and 'Cache HIT' messages"
echo "   - Request count should be increasing"

echo -e "\n🎉 If you see X-Cache-Status: HIT, CACHING IS WORKING!"

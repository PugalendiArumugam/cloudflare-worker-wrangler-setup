#!/bin/bash
echo "🎯 TESTING FRESH ARTICLES WITH CACHE"

ART1="https://www.theindiamirror.com/homescrtopnews/2020e88d-2478-4923-b4d1-2025f8381319"
ART2="https://www.theindiamirror.com/homescrtopnews/99678c0b-b99e-40b3-a5da-9c14ebf9d560"

echo "=== Article 1 ==="
echo "URL: $(echo $ART1 | cut -c1-60)..."
echo ""
echo "1. First request (should be MISS):"
echo -n "   Cache status: "
curl -sI "$ART1" | grep "X-Cache-Status" | head -1 || echo "   (checking...)"
echo "   Time:"
time curl -s -o /dev/null "$ART1" 2>&1 | grep real

echo -e "\n2. Waiting 3 seconds..."
sleep 3

echo "3. Second request (should be HIT):"
echo -n "   Cache status: "
curl -sI "$ART1" | grep "X-Cache-Status" | head -1 || echo "   (checking...)"
echo "   Time:"
time curl -s -o /dev/null "$ART1" 2>&1 | grep real

echo -e "\n4. All cache headers:"
curl -sI "$ART1" | grep -E "Cache-Control|X-Worker" | head -3

echo -e "\n=== Article 2 ==="
echo "URL: $(echo $ART2 | cut -c1-60)..."
echo ""
echo "1. First request (should be MISS):"
echo -n "   Cache status: "
curl -sI "$ART2" | grep "X-Cache-Status" | head -1 || echo "   (checking...)"
echo "   Time:"
time curl -s -o /dev/null "$ART2" 2>&1 | grep real

echo -e "\n2. Waiting 3 seconds..."
sleep 3

echo "3. Second request (should be HIT):"
echo -n "   Cache status: "
curl -sI "$ART2" | grep "X-Cache-Status" | head -1 || echo "   (checking...)"
echo "   Time:"
time curl -s -o /dev/null "$ART2" 2>&1 | grep real

echo -e "\n4. All cache headers:"
curl -sI "$ART2" | grep -E "Cache-Control|X-Worker" | head -3

echo -e "\n=== EXPECTED RESULTS ==="
echo "✅ X-Cache-Status: MISS (first request)"
echo "✅ X-Cache-Status: HIT (second request)"
echo "✅ Second request faster than first"
echo "✅ Cache-Control: public, max-age=3600"
echo "✅ X-Worker: Cache-Active"

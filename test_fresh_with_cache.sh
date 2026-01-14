#!/bin/bash
echo "🎯 TEST FRESH ARTICLES WITH CACHING"

ART1="https://www.theindiamirror.com/homescrtopnews/2020e88d-2478-4923-b4d1-2025f8381319"
ART2="https://www.theindiamirror.com/homescrtopnews/99678c0b-b99e-40b3-a5da-9c14ebf9d560"

test_article() {
  local url=$1
  local name=$2
  
  echo -e "\n=== $name ==="
  echo "URL: $(echo $url | cut -c1-60)..."
  
  # Clear local DNS
  sudo dscacheutil -flushcache 2>/dev/null || true
  
  # First request
  echo -e "\n1. First request:"
  echo -n "   Status: "
  curl -sI "$url" | grep "X-Cache-Status" | head -1 || echo "   X-Cache-Status: (checking...)"
  
  # Time it
  start=$(date +%s%N)
  curl -s -o /dev/null "$url"
  end=$(date +%s%N)
  duration=$(( (end - start) / 1000000 ))
  echo "   Time: ${duration}ms"
  
  # Wait
  sleep 3
  
  # Second request
  echo -e "\n2. Second request:"
  echo -n "   Status: "
  curl -sI "$url" | grep "X-Cache-Status" | head -1 || echo "   X-Cache-Status: (checking...)"
  
  # Time it
  start=$(date +%s%N)
  curl -s -o /dev/null "$url"
  end=$(date +%s%N)
  duration=$(( (end - start) / 1000000 ))
  echo "   Time: ${duration}ms"
  
  # Show all cache headers
  echo -e "\n3. All cache headers:"
  curl -sI "$url" | grep -E "Cache-Control|X-Cache|X-Worker|Age" | head -6
}

# Test both articles
test_article "$ART1" "Fresh Article 1"
test_article "$ART2" "Fresh Article 2"

echo -e "\n=== EXPECTED RESULTS ==="
echo "✅ First: X-Cache-Status: MISS, ~2000-4000ms"
echo "✅ Second: X-Cache-Status: HIT, ~100-500ms (much faster!)"
echo "✅ Cache-Control: public, max-age=600"
echo "✅ X-Worker: Active-v2"

#!/bin/bash
echo "🎯 FINAL TEST - FRESH ARTICLES"

# Your fresh articles
ART1="https://www.theindiamirror.com/homescrtopnews/2020e88d-2478-4923-b4d1-2025f8381319"
ART2="https://www.theindiamirror.com/homescrtopnews/99678c0b-b99e-40b3-a5da-9c14ebf9d560"

test_article() {
  local url=$1
  local name=$2
  
  echo -e "\n📰 $name"
  echo "URL: $(echo $url | cut -c1-60)..."
  
  # First request
  echo "  1. First request:"
  echo -n "     Cache status: "
  STATUS1=$(curl -sI "$url" | grep "X-Cache-Status" | head -1)
  echo "${STATUS1:-X-Cache-Status: (checking...)}"
  
  # Time it
  start=$(date +%s%N)
  curl -s -o /dev/null "$url"
  end=$(date +%s%N)
  duration=$(( (end - start) / 1000000 ))
  echo "     Time: ${duration}ms"
  
  # Wait
  sleep 3
  
  # Second request
  echo "  2. Second request:"
  echo -n "     Cache status: "
  STATUS2=$(curl -sI "$url" | grep "X-Cache-Status" | head -1)
  echo "${STATUS2:-X-Cache-Status: (checking...)}"
  
  # Time it
  start=$(date +%s%N)
  curl -s -o /dev/null "$url"
  end=$(date +%s%N)
  duration=$(( (end - start) / 1000000 ))
  echo "     Time: ${duration}ms"
  
  # Check cache headers
  echo "  3. Cache headers:"
  curl -sI "$url" | grep -E "Cache-Control|X-Worker" | head -3 | while read line; do echo "     $line"; done
}

# Test both articles
test_article "$ART1" "Fresh Article 1"
test_article "$ART2" "Fresh Article 2"

echo -e "\n=== EXPECTED RESULTS ==="
echo "✅ First: X-Cache-Status: MISS, ~2000-4000ms"
echo "✅ Second: X-Cache-Status: HIT, ~100-500ms (much faster!)"
echo "✅ Cache-Control: public, max-age=3600"
echo "✅ X-Worker: Caching-Active"

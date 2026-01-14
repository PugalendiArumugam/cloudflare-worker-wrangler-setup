#!/bin/bash
echo "📊 VERIFYING PERFORMANCE IMPROVEMENT"

ART1="https://www.theindiamirror.com/homescrtopnews/2020e88d-2478-4923-b4d1-2025f8381319"

echo "Testing Article 1 - 4 sequential requests:"
echo "=========================================="

for i in {1..4}; do
  echo -n "Request $i: "
  
  # Get cache status
  status=$(curl -sI "$ART1" | grep "X-Cache-Status" | cut -d: -f2 | tr -d ' ' | head -1)
  
  # Time request
  start=$(date +%s)
  curl -s -o /dev/null "$ART1"
  end=$(date +%s)
  duration=$((end - start))
  
  echo "${duration}s (${status:-?})"
  
  if [ $i -lt 4 ]; then
    sleep 1
  fi
done

echo -e "\n🎯 Performance analysis:"
echo "Request 1: Should be slowest (MISS - fetches from origin)"
echo "Request 2-4: Should be faster (HIT - served from cache)"
echo ""
echo "If Request 2 is significantly faster than Request 1, CACHING IS WORKING!"

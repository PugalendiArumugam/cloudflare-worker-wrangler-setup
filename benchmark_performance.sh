#!/bin/bash
echo "📊 PERFORMANCE BENCHMARK"

ART1="https://www.theindiamirror.com/homescrtopnews/2020e88d-2478-4923-b4d1-2025f8381319"

echo "Testing Article 1 with 5 sequential requests:"
echo "---------------------------------------------"

total_time=0
declare -a times

for i in {1..5}; do
  echo -n "Request $i: "
  
  # Time request
  start=$(date +%s%N)
  curl -s -o /dev/null "$ART1"
  end=$(date +%s%N)
  duration=$(( (end - start) / 1000000 ))
  
  # Get cache status
  status=$(curl -sI "$ART1" | grep "X-Cache-Status" | cut -d: -f2 | tr -d ' ' | head -1)
  
  echo "${duration}ms (${status:-?})"
  times[$i]=$duration
  total_time=$((total_time + duration))
  
  # Wait between requests
  if [ $i -lt 5 ]; then
    sleep 1
  fi
done

echo -e "\n📈 Results:"
echo "Total time: ${total_time}ms"
echo "Average: $((total_time / 5))ms"

if [ ${#times[@]} -ge 2 ]; then
  improvement=$(( (times[1] - times[2]) * 100 / times[1] ))
  echo "Improvement (req1 to req2): ${improvement}% faster"
fi

echo -e "\n🎯 Expected pattern:"
echo "Request 1: ~2000ms (MISS)"
echo "Request 2-5: ~100-500ms (HIT)"

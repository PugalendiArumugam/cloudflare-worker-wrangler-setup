#!/bin/bash
echo "=== TEST FRESH ARTICLES ==="

# Use your fresh articles
FRESH_1="https://www.theindiamirror.com/homescrtopnews/2020e88d-2478-4923-b4d1-2025f8381319"
FRESH_2="https://www.theindiamirror.com/homescrtopnews/99678c0b-b99e-40b3-a5da-9c14ebf9d560"

echo -e "\n--- Testing Fresh Article 1 ---"
echo "URL: $FRESH_1"

echo -e "\n1. First request (should show X-Cache: MISS):"
curl -sI "$FRESH_1" | grep -E "X-Cache|X-Worker|HTTP/" | head -5

echo -e "\nWaiting 2 seconds..."
sleep 2

echo -e "\n2. Second request (should show X-Cache: HIT):"
curl -sI "$FRESH_1" | grep -E "X-Cache|X-Worker" | head -5

echo -e "\n3. Content type:"
curl -sI "$FRESH_1" | grep -i "content-type" | head -1

echo -e "\n--- Testing Fresh Article 2 ---"
echo "URL: $FRESH_2"

echo -e "\n1. First request (should show X-Cache: MISS):"
curl -sI "$FRESH_2" | grep -E "X-Cache|X-Worker|HTTP/" | head -5

echo -e "\nWaiting 2 seconds..."
sleep 2

echo -e "\n2. Second request (should show X-Cache: HIT):"
curl -sI "$FRESH_2" | grep -E "X-Cache|X-Worker" | head -5

echo -e "\n3. Content type:"
curl -sI "$FRESH_2" | grep -i "content-type" | head -1

echo -e "\n=== TEST COMPLETE ==="

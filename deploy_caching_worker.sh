#!/bin/bash
echo "🚀 DEPLOYING CACHING WORKER"

# Create caching worker
cat > worker.js << 'WORKER'
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event));
});

async function handleRequest(event) {
  const request = event.request;
  const url = new URL(request.url);
  const path = url.pathname;
  
  console.log("Processing:", path);
  
  // Only cache articles
  if (path.includes('/homescrtopnews/')) {
    const cache = caches.default;
    
    // Try cache first
    const cached = await cache.match(request);
    
    if (cached) {
      console.log("✅ Cache HIT:", path);
      const newResp = new Response(cached.body, cached);
      newResp.headers.set('X-Cache-Status', 'HIT');
      newResp.headers.set('X-Worker', 'Caching-Active');
      newResp.headers.set('X-Path', path);
      return newResp;
    }
    
    console.log("❌ Cache MISS:", path);
    const response = await fetch(request);
    
    // Only cache successful responses
    if (response.status === 200) {
      const newResponse = new Response(response.body, response);
      
      // Add cache headers
      newResponse.headers.set('Cache-Control', 'public, max-age=3600, s-maxage=3600');
      newResponse.headers.set('CDN-Cache-Control', 'public, max-age=3600');
      newResponse.headers.set('X-Cache-Status', 'MISS');
      newResponse.headers.set('X-Worker', 'Caching-Active');
      newResponse.headers.set('X-Path', path);
      
      // Store in cache
      console.log("💾 Caching:", path);
      event.waitUntil(cache.put(request, newResponse.clone()));
      return newResponse;
    }
    
    // For non-200, don't cache
    const errorResponse = new Response(response.body, response);
    errorResponse.headers.set('X-Cache-Status', 'BYPASS');
    return errorResponse;
  }
  
  // Pass through non-articles
  console.log("➡️ Pass-through:", path);
  return fetch(request);
}
WORKER

# Deploy
echo "Deploying caching worker..."
wrangler deploy

echo -e "\n⏳ Waiting 20 seconds..."
sleep 20

echo -e "\n🧪 Quick test..."
TEST_URL="https://www.theindiamirror.com/homescrtopnews/cache-ready-$(date +%s)"
echo "URL: $TEST_URL"

echo -e "\nFirst request (should be MISS):"
curl -sI "$TEST_URL" | grep -E "X-Cache-Status|X-Worker|Cache-Control" | head -5

echo -e "\nWaiting 3 seconds..."
sleep 3

echo -e "\nSecond request (should be HIT):"
curl -sI "$TEST_URL" | grep -E "X-Cache-Status" | head -2

echo -e "\n✅ If X-Cache-Status shows MISS then HIT, CACHING IS WORKING!"

#!/bin/bash
echo "🚀 ADDING CACHING - FINAL"

# Create caching worker
cat > worker.js << 'WORKER'
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event));
});

async function handleRequest(event) {
  const request = event.request;
  const url = new URL(request.url);
  const path = url.pathname;
  
  console.log('Processing:', path);
  
  // Only cache articles
  if (path.includes('/homescrtopnews/')) {
    const cache = caches.default;
    
    // Try cache first
    const cached = await cache.match(request);
    
    if (cached) {
      console.log('✅ Cache HIT:', path);
      const newResp = new Response(cached.body, cached);
      newResp.headers.set('X-Cache-Status', 'HIT');
      newResp.headers.set('X-Worker', 'Cache-Active');
      newResp.headers.set('Cache-Control', 'public, max-age=3600');
      return newResp;
    }
    
    console.log('❌ Cache MISS:', path);
    const response = await fetch(request);
    const newResponse = new Response(response.body, response);
    
    // Add ALL cache headers
    newResponse.headers.set('X-Cache-Status', 'MISS');
    newResponse.headers.set('X-Worker', 'Cache-Active');
    newResponse.headers.set('Cache-Control', 'public, max-age=3600, s-maxage=3600');
    newResponse.headers.set('CDN-Cache-Control', 'public, max-age=3600');
    
    // Store in cache
    event.waitUntil(cache.put(request, newResponse.clone()));
    return newResponse;
  }
  
  // Pass through non-articles
  return fetch(request);
}
WORKER

# Deploy
echo "Deploying caching worker..."
wrangler deploy

echo -e "\n⏳ Waiting 30 seconds..."
sleep 30

echo -e "\n🧪 Quick cache test..."
TEST_URL="https://www.theindiamirror.com/homescrtopnews/cache-final-$(date +%s)"
echo "URL: $TEST_URL"

echo -e "\nFirst request (should be MISS):"
curl -sI "$TEST_URL" | grep -E "X-Cache-Status|X-Worker|Cache-Control" | head -5

echo -e "\nWaiting 3 seconds..."
sleep 3

echo -e "\nSecond request (should be HIT):"
curl -sI "$TEST_URL" | grep -E "X-Cache-Status" | head -2

echo -e "\n✅ If X-Cache-Status shows, caching is WORKING!"

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
    
    // Create a cache key with only the path to avoid query string issues
    const cacheKey = new Request(url.origin + path, request);
    
    // Try cache first
    const cached = await cache.match(cacheKey);
    
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
    
    // Clone response for caching
    const responseToCache = response.clone();
    const newResponse = new Response(response.body, response);
    
    // Add ALL cache headers
    newResponse.headers.set('X-Cache-Status', 'MISS');
    newResponse.headers.set('X-Worker', 'Cache-Active');
    newResponse.headers.set('Cache-Control', 'public, max-age=3600, s-maxage=3600');
    newResponse.headers.set('CDN-Cache-Control', 'public, max-age=3600');
    
    // Store in cache with simplified key
    event.waitUntil(cache.put(cacheKey, responseToCache));
    return newResponse;
  }
  
  // Pass through non-articles
  return fetch(request);
}

// Cron/Scheduled handler - runs every 30 minutes
addEventListener('scheduled', event => {
  event.waitUntil(handleScheduled(event));
});

async function handleScheduled(event) {
  console.log('🕒 Scheduled task running at:', new Date().toISOString());
  console.log('✅ Scheduled task completed');
  return new Response('Scheduled task completed successfully');
}

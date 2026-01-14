addEventListener("fetch", (event) => {
  console.log("🚀 Worker triggered:", event.request.url);
  event.respondWith(handleRequest(event));
});

async function handleRequest(event) {
  const request = event.request;
  const url = new URL(request.url);
  const path = url.pathname;
  
  console.log("📝 Processing:", { host: url.hostname, path: path });
  
  // Only cache GET requests for homescrtopnews
  if (request.method === "GET" && path.includes("/homescrtopnews/")) {
    console.log("✅ Cacheable article detected");
    const cache = caches.default;
    
    // Try to get from cache
    const cached = await cache.match(request);
    
    if (cached) {
      console.log("🎯 CACHE HIT");
      const response = new Response(cached.body, cached);
      response.headers.set("X-Cache-Status", "HIT");
      response.headers.set("X-Worker", "Cache-Active");
      response.headers.set("Cache-Control", "public, max-age=3600");
      return response;
    }
    
    console.log("❌ CACHE MISS");
    const response = await fetch(request);
    
    // Clone for caching
    const responseToCache = response.clone();
    const newResponse = new Response(response.body, response);
    
    // Add cache headers
    newResponse.headers.set("X-Cache-Status", "MISS");
    newResponse.headers.set("X-Worker", "Cache-Active");
    newResponse.headers.set("Cache-Control", "public, max-age=3600, s-maxage=3600");
    newResponse.headers.set("CDN-Cache-Control", "public, max-age=3600");
    
    // Store in cache
    event.waitUntil(cache.put(request, responseToCache));
    
    return newResponse;
  }
  
  // Pass through non-cacheable requests
  console.log("➡️ Passing through non-cacheable request");
  return fetch(request);
}

// Cron handler
addEventListener("scheduled", (event) => {
  console.log("⏰ Cron job executed:", new Date().toISOString());
  event.waitUntil(Promise.resolve());
});

#!/bin/bash
echo "🚀 DEPLOYING WORKING WORKER"

# Clean up any existing
echo "1. Cleaning up..."
wrangler delete article-cache-final 2>/dev/null || true
wrangler delete theindiamirror-cache 2>/dev/null || true

# Create fresh config
echo "2. Creating config..."
cat > wrangler.toml << 'TOML'
name = "working-cache"
main = "worker.js"
compatibility_date = "2024-01-01"
account_id = "8f0cd6b783d20fe2ea5f2808f5d2eeaf"

routes = [
  "www.theindiamirror.com/homescrtopnews/*"
]
TOML

# Create SIMPLE worker that MUST work
echo "3. Creating worker..."
cat > worker.js << 'WORKER'
addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  const path = url.pathname;
  
  console.log("Worker executing for:", path);
  
  // Check if it's an article
  if (path.includes('/homescrtopnews/')) {
    // Create immediate response - NO async, NO fetch
    const response = new Response(
      `✅ WORKER IS WORKING!\n` +
      `Path: ${path}\n` +
      `Time: ${new Date().toISOString()}\n` +
      `Next: Caching will be added after this works.`,
      {
        headers: {
          'Content-Type': 'text/plain',
          'X-Worker-Status': 'ACTIVE',
          'X-Test-Result': 'SUCCESS',
          'X-Path': path
        }
      }
    );
    
    event.respondWith(response);
    return;
  }
  
  // For non-article paths (shouldn't happen with our route)
  event.respondWith(fetch(event.request));
});
WORKER

# Deploy
echo "4. Deploying..."
wrangler deploy

echo -e "\n⏳ Waiting 20 seconds for Cloudflare..."
sleep 20

echo -e "\n🧪 Testing deployment..."
TEST_URL="https://www.theindiamirror.com/homescrtopnews/test-$(date +%s)"
echo "Test URL: $TEST_URL"
echo -e "\nResponse:"
curl -s "$TEST_URL"
echo -e "\n\nHeaders:"
curl -sI "$TEST_URL" | grep -E "X-Worker|X-Test|Content-Type" | head -5

echo -e "\n✅ If you see 'WORKER IS WORKING!' above, deployment SUCCESS!"
echo "✅ If you see normal HTML, something is wrong."

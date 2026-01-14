#!/bin/bash
echo "🔧 FIXING WORKER ROUTES"

echo "1. Checking current configuration..."
echo "==================================="
cat wrangler.toml

echo -e "\n2. Current worker.js (first 10 lines):"
echo "=========================================="
head -10 worker.js

echo -e "\n3. Re-deploying with force..."
echo "================================"
# Delete and recreate
wrangler delete working-cache 2>/dev/null || echo "No worker to delete"

# Create fresh worker
cat > worker.js << 'WORKER'
addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  
  // FORCE response to prove it works
  event.respondWith(new Response(
    `WORKER FIX - SUCCESS!\n` +
    `Path: ${url.pathname}\n` +
    `Time: ${new Date().toISOString()}\n` +
    `If you see this, routes are fixed!`,
    {
      headers: {
        'Content-Type': 'text/plain',
        'X-Worker-Fix': 'Active',
        'X-Routes': 'Fixed'
      }
    }
  ));
});
WORKER

echo "4. Deploying..."
DEPLOY_OUTPUT=$(wrangler deploy 2>&1)
echo "$DEPLOY_OUTPUT"

# Check if routes were mentioned
if echo "$DEPLOY_OUTPUT" | grep -q "Deployed.*triggers"; then
  echo "✅ Routes mentioned in deploy output"
  ROUTES=$(echo "$DEPLOY_OUTPUT" | grep -A5 "Deployed.*triggers")
  echo "Routes:"
  echo "$ROUTES"
else
  echo "⚠️ No routes mentioned in output"
fi

echo -e "\n5. Waiting 30 seconds..."
sleep 30

echo -e "\n6. Testing..."
TEST_URL="https://www.theindiamirror.com/homescrtopnews/fix-test-$(date +%s)"
echo "URL: $TEST_URL"
echo -e "\nResponse:"
curl -s "$TEST_URL"
echo -e "\n\nHeaders:"
curl -sI "$TEST_URL" | grep -E "X-Worker-Fix|Content-Type" | head -3

echo -e "\n✅ If you see 'WORKER FIX - SUCCESS!', ROUTES ARE FIXED"
echo "❌ If you see HTML, routes are STILL not attached"

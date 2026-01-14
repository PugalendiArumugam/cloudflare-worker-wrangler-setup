#!/bin/bash
echo "🚨 DEPLOYING WORKER THAT MUST WORK"

# 1. Clean up everything
echo "1. Cleaning up..."
wrangler delete working-cache 2>/dev/null || echo "No worker to delete"

# 2. Create fresh config
echo "2. Creating fresh config..."
cat > wrangler.toml << 'TOML'
name = "must-work-cache"
main = "worker.js"
compatibility_date = "2024-01-01"
account_id = "8f0cd6b783d20fe2ea5f2808f5d2eeaf"

# ONLY ONE route - simplest possible
routes = ["www.theindiamirror.com/homescrtopnews/*"]
TOML

# 3. Create SIMPLE worker that CANNOT fail
echo "3. Creating simple worker..."
cat > worker.js << 'WORKER'
// ULTRA SIMPLE - NO async, NO fetch, immediate response
addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  
  // ALWAYS respond with this text
  const response = new Response(
    `MUST-WORK WORKER SUCCESS!\n` +
    `Path: ${url.pathname}\n` +
    `Time: ${Date.now()}\n` +
    `If you see this, the worker is working.`,
    {
      headers: {
        'Content-Type': 'text/plain',
        'X-Worker-Must-Work': 'YES',
        'X-Test': 'Simple-Immediate'
      }
    }
  );
  
  event.respondWith(response);
  console.log('Worker responded to:', url.pathname);
});
WORKER

# 4. Deploy
echo "4. Deploying..."
DEPLOY_OUTPUT=$(wrangler deploy 2>&1)
echo "$DEPLOY_OUTPUT"

# Check for success
if echo "$DEPLOY_OUTPUT" | grep -q "Uploaded\|Deployed"; then
  echo "✅ Deployment successful"
else
  echo "❌ Deployment failed"
  exit 1
fi

# 5. Wait LONGER (Cloudflare needs time)
echo -e "\n5. Waiting 45 seconds (IMPORTANT!)..."
for i in {45..1}; do
  echo -ne "Waiting: $i seconds\r"
  sleep 1
done
echo ""

# 6. Test
echo -e "\n6. Testing..."
TEST_URL="https://www.theindiamirror.com/homescrtopnews/must-work-test-$(date +%s)"
echo "URL: $TEST_URL"

echo -e "\nResponse body (first 5 lines):"
curl -s "$TEST_URL" | head -5

echo -e "\nHeaders:"
curl -sI "$TEST_URL" | grep -E "X-Worker-Must-Work|Content-Type" | head -3

echo -e "\n🎯 FINAL CHECK:"
RESPONSE=$(curl -s "$TEST_URL")
if echo "$RESPONSE" | grep -q "MUST-WORK WORKER SUCCESS"; then
  echo "✅ SUCCESS! Worker is RUNNING!"
  echo "   The worker is now intercepting requests"
  echo "   Next: We'll add caching to it"
else
  echo "❌ FAILED! Worker is NOT running"
  echo "   You're getting: $(echo "$RESPONSE" | head -c 30)..."
  echo "   This is a critical issue - check Cloudflare Dashboard"
fi

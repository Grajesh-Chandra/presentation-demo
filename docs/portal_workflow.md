# Kong Dev Portal - Complete Workflow

> **Quick Guide**: How to publish APIs to Kong Dev Portal and test them

## 📋 Overview

This guide walks you through:
1. Publishing the Demo API to Kong Dev Portal
2. Registering as a developer
3. Creating an application
4. Getting Portal-generated API keys
5. Testing the published API

---

## 🚀 Quick Start

### Step 1: Publish API to Dev Portal

Run the publishing script:

```bash
cd scripts
./18-publish-to-portal.sh
```

**What it does:**
- ✅ Registers "Demo API" in Konnect catalog
- ✅ Creates comprehensive OpenAPI specification
- ✅ Links API to Gateway Service (demo-api-service)
- ✅ Publishes API to Dev Portal with public visibility
- ✅ Applies key-auth authentication strategy
- ✅ Saves API ID for reference

**Expected output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Publishing Demo API to Kong Dev Portal
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Step 1: Registering API in catalog...
✅ API registered with ID: abc123...

📤 Step 2: Creating OpenAPI specification...
✅ Specification uploaded with ID: def456...

🔍 Step 3: Finding Gateway Service...
✅ Control Plane ID: xyz789...
✅ Service ID: service123...

🔗 Step 4: Linking API to Gateway Service...
✅ API linked to Gateway Service

🌐 Step 5: Finding Dev Portal...
✅ Portal ID: portal456...

🚀 Step 6: Publishing to Dev Portal...
✅ API published to Dev Portal

🔐 Step 7: Applying authentication strategy...
✅ Authentication strategy applied (key-auth)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ API Publishing Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Summary:
  • API Name: Demo API
  • API ID: abc123...
  • Specification ID: def456...
  • Portal ID: portal456...
  • Status: Published

🌐 Next Steps:
  1. Visit Dev Portal to verify publication
  2. Sign up as a developer (if not already)
  3. Create an application in the Portal
  4. Register your app with 'Demo API'
  5. Copy the Portal-generated API key (starts with 'kpat_')
  6. Run test script: ./19-test-portal-api.sh
```

---

### Step 2: Access Dev Portal

1. **Find Your Portal URL:**
   - Log in to Kong Konnect: https://cloud.konghq.com
   - Navigate to **Dev Portal** section
   - Copy your Portal URL (e.g., `https://kong-demo.portal.konghq.com`)

2. **Verify API Publication:**
   - Visit your Portal URL
   - You should see "Demo API" in the catalog
   - Click on it to view documentation

---

### Step 3: Register as Developer

If you're not already registered:

1. Click **"Sign Up"** on the Portal
2. Fill in registration form:
   - Email: your-email@example.com
   - Password: (strong password)
   - Name: Your Name
   - Organization: Your Company
3. Verify email (if required)
4. Log in to Portal

---

### Step 4: Create Application

1. Navigate to **"My Apps"** or **"Applications"**
2. Click **"Create Application"** or **"New App"**
3. Fill in details:
   ```
   Name: My Test App
   Description: Testing Demo API from Portal
   Type: Web Application
   ```
4. Click **"Create"**
5. Note your Application ID

---

### Step 5: Register App with Demo API

1. Browse to **"APIs"** or **"Catalog"**
2. Find **"Demo API"**
3. Click **"Register"** or **"Subscribe"**
4. Select your application: **"My Test App"**
5. Review permissions
6. Click **"Register"** or **"Subscribe"**
7. Wait for approval (usually instant if auto-approve is enabled)

---

### Step 6: Get Portal API Key

1. Go to **"My Apps"** → **"My Test App"**
2. Navigate to **"Credentials"** or **"Keys"** tab
3. Find API key for **"Demo API"**:
   ```
   Key: kpat_abc123xyz789...
   Status: Active
   Created: 2025-11-11
   ```
4. Click **"Copy"** to copy the key
5. **Save it securely!**

**Important:** Portal keys always start with `kpat_` prefix

---

### Step 7: Add Key to Environment

**Option A: Add to .env file (recommended)**
```bash
cd /path/to/presentation-demo
echo 'PORTAL_API_KEY=kpat_your_actual_key_here' >> .env
```

**Option B: Export temporarily**
```bash
export PORTAL_API_KEY='kpat_your_actual_key_here'
```

---

### Step 8: Test Portal API

Run the test script:

```bash
cd scripts
./19-test-portal-api.sh
```

**What it tests:**
1. ✅ Health check (no auth required)
2. ✅ List users (with Portal key)
3. ✅ Get user by ID (with Portal key)
4. ✅ List products (with Portal key)
5. ✅ Get API stats (with Portal key)
6. ✅ Missing API key (401 expected)
7. ✅ Invalid API key (401 expected)
8. ✅ Create new user POST (with Portal key)
9. ✅ Verify Kong headers in response

**Expected output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Testing Portal-Published API
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Portal API Key found
   Key prefix: kpat_abc12...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TEST: Health Check (No Auth)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📤 REQUEST:
  Method: GET
  URL: http://localhost:8000/api/demo/api/v1/health
  Headers:
    Content-Type: application/json

📥 RESPONSE:
{
  "status": "healthy",
  "service": "Demo API",
  "timestamp": "2025-11-11T10:30:00Z"
}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TEST: List Users (With Portal Key)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📤 REQUEST:
  Method: GET
  URL: http://localhost:8000/api/demo/api/v1/users
  Headers:
    apikey: kpat_abc12...
    Content-Type: application/json

📥 RESPONSE:
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  {
    "id": 2,
    "name": "Jane Smith",
    "email": "jane@example.com"
  }
]

... (more tests) ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Test Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ All Portal API tests completed!

📊 Tests Executed:
  1. ✅ Health check (no auth)
  2. ✅ List users (with portal key)
  3. ✅ Get user by ID (with portal key)
  4. ✅ List products (with portal key)
  5. ✅ Get API stats (with portal key)
  6. ✅ Missing API key (401 expected)
  7. ✅ Invalid API key (401 expected)
  8. ✅ Create new user (POST with portal key)
  9. ✅ Verify Kong headers
```

---

## 🎯 Key Concepts

### Portal Keys vs Consumer Keys

| Aspect | Portal App Keys | Consumer Keys |
|--------|----------------|---------------|
| **Generated By** | Dev Portal (automatic) | Manual configuration |
| **Prefix** | `kpat_*` | Custom (e.g., `demo-api-key-*`) |
| **Use Case** | External developers via Portal | Internal/backend services |
| **Management** | Self-service via Portal | Admin-managed in Gateway |
| **Visibility** | Visible in "My Apps" | Configured in Gateway config |
| **Revocation** | Developer or Admin | Admin only |

**Critical:** Portal app keys and consumer keys are **different**. You **cannot** use consumer keys when testing from Dev Portal.

---

## 🔍 Troubleshooting

### Issue: 401 Unauthorized

**Symptoms:**
```json
{
  "message": "No API key found in request"
}
```

**Solutions:**

1. **Verify you're using Portal key:**
   ```bash
   echo $PORTAL_API_KEY
   # Should start with: kpat_
   ```

2. **Check app registration:**
   - Portal → My Apps → [Your App]
   - Verify app is registered with "Demo API"
   - Check credential status is "Active"

3. **Test key manually:**
   ```bash
   curl -H "apikey: $PORTAL_API_KEY" \
     http://localhost:8000/api/demo/api/v1/users
   ```

### Issue: API Not Visible in Portal

**Solutions:**

1. **Check publication status:**
   - Konnect → APIs → Demo API → Portals
   - Verify status is "Published"
   - Check visibility is "Public"

2. **Re-run publishing script:**
   ```bash
   ./18-publish-to-portal.sh
   ```

### Issue: OpenAPI Spec Not Loading

**Solutions:**

1. **Verify spec upload:**
   - Portal → Demo API → Documentation
   - Should see all endpoints listed

2. **Check script output:**
   ```bash
   cat /tmp/demo-api-openapi.yaml
   ```

---

## 📚 Additional Resources

- **Comprehensive Guide**: [kong_dev_portal_guide.md](./kong_dev_portal_guide.md)
- **Kong Dev Portal Docs**: https://docs.konghq.com/konnect/dev-portal/
- **API Products Guide**: https://docs.konghq.com/konnect/api-products/
- **Script README**: [../scripts/README.md](../scripts/README.md)

---

## 🎬 Demo Flow

Perfect for presentations:

```bash
# 1. Publish API (1 minute)
./18-publish-to-portal.sh

# 2. Show Portal (2 minutes)
# - Navigate to Portal URL
# - Show API catalog
# - Show API documentation
# - Show interactive "Try it" feature

# 3. Developer Journey (3 minutes)
# - Sign up as developer
# - Create application
# - Register app with API
# - Get API key

# 4. Test API (2 minutes)
export PORTAL_API_KEY='kpat_...'
./19-test-portal-api.sh

# 5. Show Analytics (2 minutes)
# - Konnect → Analytics
# - Portal → My Apps → Analytics
```


## ✅ Checklist

Before demo:
- [ ] Kong Gateway running
- [ ] Demo API deployed
- [ ] Konnect account ready
- [ ] .env file configured
- [ ] Scripts executable

After publishing:
- [ ] API visible in Portal
- [ ] Documentation rendered
- [ ] Authentication required
- [ ] Portal account created
- [ ] Application registered
- [ ] API key obtained
- [ ] Tests passing

---

**Ready to publish? Run `./18-publish-to-portal.sh` to start! 🚀**

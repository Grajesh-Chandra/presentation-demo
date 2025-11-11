# Kong Dev Portal - Complete Guide

> **Professional portal pages for Kong Konnect Dev Portal**
> Create beautiful, responsive developer experiences in minutes

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Portal Structure](#portal-structure)
3. [Landing Page Template](#landing-page-template)
4. [Authentication Guide Template](#authentication-guide-template)
5. [API Catalog Template](#api-catalog-template)
6. [Design System](#design-system)
7. [Best Practices](#best-practices)

---

## Quick Start

### 1. Upload Page to Kong Konnect

```bash
# Step 1: Log in to Kong Konnect
https://cloud.konghq.com

# Step 2: Navigate to Dev Portal
Dev Portal → Content → Pages

# Step 3: Create New Page
Click "+ New Page"
Name: getting-started
Paste content from template below
Save & Publish

# Step 4: Set as Homepage (optional)
Dev Portal → Settings → Homepage → Select: getting-started
```

### 2. Customize Your Portal

- Replace "Demo API Platform" with your platform name
- Update descriptions and features
- Add your company logo
- Customize colors to match your brand
- Link to your actual APIs

---

## Portal Structure

### Recommended Pages

| Page | Purpose | Template |
|------|---------|----------|
| **getting-started.md** | Homepage with hero, features, APIs | Landing Page Template |
| **authentication.md** | Auth guide with code examples | Authentication Guide |
| **api-catalog.md** | Browse all APIs | API Catalog Template |
| **support.md** | Contact and help | Custom |

### Navigation Setup

```yaml
# In Portal Settings → Navigation
- Home (getting-started)
- APIs (api-catalog)
- Documentation (authentication)
- Support (support)
```

---

## Landing Page Template

**File:** `getting-started.md`
**Purpose:** Homepage with hero section, quick start guides, and featured APIs

```yaml
---
title: Welcome to Demo API Platform
description: Everything you need to integrate powerful APIs into your applications
---

::page-section
---
full-width: true
styles: |
  background: linear-gradient(135deg, #003F6C 0%, #00588A 100%);
  padding: clamp(60px, 8vw, 100px) 0;
  margin-top: -20px;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(32px, 6vw, 56px)"
  title-tag: "h1"
  text-align: "center"
  title-line-height: "clamp(40px, 7vw, 64px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(18px, 3vw, 24px)"
  description-line-height: "clamp(28px, 4vw, 36px)"
  styles: |
    h1 {
      color: #FFFFFF;
      margin-bottom: 20px;
    }
    p {
      color: rgba(255, 255, 255, 0.9);
      max-width: 800px;
      margin: 0 auto 40px;
    }
  ---
  #title
  Welcome to Demo API Platform

  #description
  Everything you need to integrate powerful APIs into your applications. Get started in minutes with our comprehensive documentation and examples.

  #actions
    ::button
    ---
    appearance: "primary"
    size: "large"
    styles: |
      background-color: #00C9B7;
      color: #003F6C;
      font-weight: 600;
      padding: 16px 32px;
      border-radius: 8px;
      font-size: 18px;
      border: none;
      box-shadow: 0 4px 12px rgba(0, 201, 183, 0.3);
      transition: all 0.3s ease;
      cursor: pointer;
      &:hover {
        background-color: #00E5CD;
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0, 201, 183, 0.4);
      }
    ---
    Get Started
    ::

    ::button
    ---
    appearance: "secondary"
    size: "large"
    styles: |
      background-color: transparent;
      color: #FFFFFF;
      font-weight: 600;
      padding: 16px 32px;
      border: 2px solid #FFFFFF;
      border-radius: 8px;
      font-size: 18px;
      transition: all 0.3s ease;
      cursor: pointer;
      margin-left: 16px;
      &:hover {
        background-color: rgba(255, 255, 255, 0.1);
        transform: translateY(-2px);
      }
    ---
    View Documentation
    ::
  ::
::

::page-section
---
full-width: true
styles: |
  background: #F9FAFB;
  padding: clamp(60px, 8vw, 80px) 0;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(28px, 5vw, 40px)"
  title-tag: "h2"
  text-align: "center"
  title-line-height: "clamp(36px, 6vw, 48px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(16px, 3vw, 20px)"
  description-line-height: "clamp(24px, 4vw, 30px)"
  styles: |
    h2 {
      color: #1F2937;
      margin-bottom: 16px;
    }
    p {
      color: #6B7280;
      max-width: 700px;
      margin: 0 auto 60px;
    }
  ---
  #title
  Quick Start Guides

  #description
  Get up and running quickly with our step-by-step guides
  ::

  ::grid-layout
  ---
  columns: 2
  gap: 48px
  columns-breakpoints:
    mobile: 1
    desktop: 2
    laptop: 2
    phablet: 1
    tablet: 2
  styles: |
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
  ---
    ::page-hero
    ---
    full-width: true
    title-font-size: "clamp(22px, 4vw, 28px)"
    title-tag: "h3"
    text-align: "left"
    title-line-height: "clamp(30px, 5vw, 36px)"
    title-font-weight: "700"
    description-font-weight: "400"
    description-font-size: "clamp(15px, 3vw, 16px)"
    description-line-height: "clamp(24px, 4vw, 26px)"
    styles: |
      background: #FFFFFF;
      border-radius: 12px;
      padding: 32px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
      transition: all 0.3s ease;
      height: 100%;
      &:hover {
        transform: translateY(-4px);
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
      }
      h3 {
        color: #1F2937;
        margin-bottom: 12px;
      }
      p {
        color: #6B7280;
        margin: 0;
      }
    ---
    #title
    🚀 Authentication

    #description
    Learn how to authenticate your API requests using API keys, OAuth 2.0, or OpenID Connect. Step-by-step guides with code examples.

    #actions
      ::button
      ---
      appearance: "link"
      styles: |
        color: #00C9B7;
        font-weight: 600;
        margin-top: 16px;
        padding: 0;
        background: none;
        border: none;
        cursor: pointer;
        &:hover {
          color: #00588A;
          text-decoration: underline;
        }
      ---
      View Guide →
      ::
    ::

    ::page-hero
    ---
    full-width: true
    title-font-size: "clamp(22px, 4vw, 28px)"
    title-tag: "h3"
    text-align: "left"
    title-line-height: "clamp(30px, 5vw, 36px)"
    title-font-weight: "700"
    description-font-weight: "400"
    description-font-size: "clamp(15px, 3vw, 16px)"
    description-line-height: "clamp(24px, 4vw, 26px)"
    styles: |
      background: #FFFFFF;
      border-radius: 12px;
      padding: 32px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
      transition: all 0.3s ease;
      height: 100%;
      &:hover {
        transform: translateY(-4px);
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
      }
      h3 {
        color: #1F2937;
        margin-bottom: 12px;
      }
      p {
        color: #6B7280;
        margin: 0;
      }
    ---
    #title
    📚 API Reference

    #description
    Explore our complete API reference with interactive examples. Test endpoints directly in your browser with live API calls.

    #actions
      ::button
      ---
      appearance: "link"
      styles: |
        color: #00C9B7;
        font-weight: 600;
        margin-top: 16px;
        padding: 0;
        background: none;
        border: none;
        cursor: pointer;
        &:hover {
          color: #00588A;
          text-decoration: underline;
        }
      ---
      Browse APIs →
      ::
    ::
  ::
::

::page-section
---
full-width: true
styles: |
  background: #FFFFFF;
  padding: clamp(60px, 8vw, 80px) 0;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(28px, 5vw, 40px)"
  title-tag: "h2"
  text-align: "center"
  title-line-height: "clamp(36px, 6vw, 48px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(16px, 3vw, 20px)"
  description-line-height: "clamp(24px, 4vw, 30px)"
  styles: |
    h2 {
      color: #1F2937;
      margin-bottom: 16px;
    }
    p {
      color: #6B7280;
      max-width: 700px;
      margin: 0 auto 60px;
    }
  ---
  #title
  Featured APIs

  #description
  Start building with our most popular APIs
  ::

  ::grid-layout
  ---
  columns: 3
  gap: 32px
  columns-breakpoints:
    mobile: 1
    desktop: 3
    laptop: 3
    phablet: 1
    tablet: 2
  styles: |
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
  ---
    ::page-hero
    ---
    full-width: true
    title-font-size: "clamp(20px, 4vw, 24px)"
    title-tag: "h4"
    text-align: "left"
    title-line-height: "clamp(28px, 5vw, 32px)"
    title-font-weight: "600"
    description-font-weight: "400"
    description-font-size: "clamp(14px, 3vw, 15px)"
    description-line-height: "clamp(22px, 4vw, 24px)"
    styles: |
      background: #FFFFFF;
      border: 1px solid #E5E7EB;
      border-radius: 10px;
      padding: 28px;
      transition: all 0.3s ease;
      height: 100%;
      &:hover {
        border-color: #00C9B7;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 201, 183, 0.15);
      }
      h4 {
        color: #1F2937;
        margin-bottom: 8px;
      }
      p {
        color: #6B7280;
        margin-bottom: 16px;
      }
    ---
    #title
    📊 Demo API

    #description
    REST API for user and product management with full CRUD operations.

    #actions
      ::badge
      ---
      styles: |
        background: #DBEAFE;
        color: #1E40AF;
        padding: 4px 12px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: 600;
        display: inline-block;
      ---
      REST
      ::

      ::button
      ---
      appearance: "link"
      styles: |
        color: #00C9B7;
        font-weight: 600;
        margin-top: 12px;
        padding: 0;
        background: none;
        border: none;
        cursor: pointer;
        display: block;
        &:hover {
          color: #00588A;
          text-decoration: underline;
        }
      ---
      View Docs →
      ::
    ::

    ::page-hero
    ---
    full-width: true
    title-font-size: "clamp(20px, 4vw, 24px)"
    title-tag: "h4"
    text-align: "left"
    title-line-height: "clamp(28px, 5vw, 32px)"
    title-font-weight: "600"
    description-font-weight: "400"
    description-font-size: "clamp(14px, 3vw, 15px)"
    description-line-height: "clamp(22px, 4vw, 24px)"
    styles: |
      background: #FFFFFF;
      border: 1px solid #E5E7EB;
      border-radius: 10px;
      padding: 28px;
      transition: all 0.3s ease;
      height: 100%;
      &:hover {
        border-color: #00C9B7;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 201, 183, 0.15);
      }
      h4 {
        color: #1F2937;
        margin-bottom: 8px;
      }
      p {
        color: #6B7280;
        margin-bottom: 16px;
      }
    ---
    #title
    🤖 AI Router

    #description
    AI gateway for routing requests to multiple LLM providers with unified API.

    #actions
      ::badge
      ---
      styles: |
        background: #FEF3C7;
        color: #92400E;
        padding: 4px 12px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: 600;
        display: inline-block;
      ---
      AI/ML
      ::

      ::button
      ---
      appearance: "link"
      styles: |
        color: #00C9B7;
        font-weight: 600;
        margin-top: 12px;
        padding: 0;
        background: none;
        border: none;
        cursor: pointer;
        display: block;
        &:hover {
          color: #00588A;
          text-decoration: underline;
        }
      ---
      View Docs →
      ::
    ::

    ::page-hero
    ---
    full-width: true
    title-font-size: "clamp(20px, 4vw, 24px)"
    title-tag: "h4"
    text-align: "left"
    title-line-height: "clamp(28px, 5vw, 32px)"
    title-font-weight: "600"
    description-font-weight: "400"
    description-font-size: "clamp(14px, 3vw, 15px)"
    description-line-height: "clamp(22px, 4vw, 24px)"
    styles: |
      background: #FFFFFF;
      border: 1px solid #E5E7EB;
      border-radius: 10px;
      padding: 28px;
      transition: all 0.3s ease;
      height: 100%;
      &:hover {
        border-color: #00C9B7;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 201, 183, 0.15);
      }
      h4 {
        color: #1F2937;
        margin-bottom: 8px;
      }
      p {
        color: #6B7280;
        margin-bottom: 16px;
      }
    ---
    #title
    📈 Analytics API

    #description
    Real-time analytics and metrics for monitoring API usage and performance.

    #actions
      ::badge
      ---
      styles: |
        background: #D1FAE5;
        color: #065F46;
        padding: 4px 12px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: 600;
        display: inline-block;
      ---
      GraphQL
      ::

      ::button
      ---
      appearance: "link"
      styles: |
        color: #00C9B7;
        font-weight: 600;
        margin-top: 12px;
        padding: 0;
        background: none;
        border: none;
        cursor: pointer;
        display: block;
        &:hover {
          color: #00588A;
          text-decoration: underline;
        }
      ---
      View Docs →
      ::
    ::
  ::
::

::page-section
---
full-width: true
styles: |
  background: linear-gradient(135deg, #F9FAFB 0%, #E5E7EB 100%);
  padding: clamp(50px, 7vw, 70px) 0;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(28px, 5vw, 36px)"
  title-tag: "h2"
  text-align: "center"
  title-line-height: "clamp(36px, 6vw, 44px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(16px, 3vw, 20px)"
  description-line-height: "clamp(24px, 4vw, 30px)"
  styles: |
    h2 {
      color: #1F2937;
      margin-bottom: 16px;
    }
    p {
      color: #6B7280;
      max-width: 700px;
      margin: 0 auto 40px;
    }
  ---
  #title
  Ready to Get Started?

  #description
  Join thousands of developers building amazing applications

  #actions
    ::button
    ---
    appearance: "primary"
    size: "large"
    styles: |
      background-color: #00C9B7;
      color: #003F6C;
      font-weight: 600;
      padding: 16px 32px;
      border-radius: 8px;
      font-size: 18px;
      border: none;
      box-shadow: 0 4px 12px rgba(0, 201, 183, 0.3);
      transition: all 0.3s ease;
      cursor: pointer;
      &:hover {
        background-color: #00E5CD;
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0, 201, 183, 0.4);
      }
    ---
    Create Account
    ::

    ::button
    ---
    appearance: "secondary"
    size: "large"
    styles: |
      background-color: #FFFFFF;
      color: #003F6C;
      font-weight: 600;
      padding: 16px 32px;
      border: 2px solid #003F6C;
      border-radius: 8px;
      font-size: 18px;
      transition: all 0.3s ease;
      cursor: pointer;
      margin-left: 16px;
      &:hover {
        background-color: #003F6C;
        color: #FFFFFF;
        transform: translateY(-2px);
      }
    ---
    Contact Sales
    ::
  ::
::
```

**Customization:**
- Replace "Demo API Platform" with your brand name
- Update API cards with your actual APIs
- Change colors to match your brand
- Add/remove sections as needed

---

## Authentication Guide Template

**File:** `authentication.md`
**Purpose:** Complete authentication guide with code examples

```yaml
---
title: Authentication Guide
description: Learn how to authenticate your API requests
---

::page-section
---
full-width: true
styles: |
  background: linear-gradient(135deg, #003F6C 0%, #00588A 100%);
  padding: clamp(50px, 7vw, 80px) 0;
  margin-top: -20px;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(28px, 5vw, 44px)"
  title-tag: "h1"
  text-align: "center"
  title-line-height: "clamp(36px, 6vw, 52px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(16px, 3vw, 20px)"
  description-line-height: "clamp(24px, 4vw, 30px)"
  styles: |
    h1 {
      color: #FFFFFF;
      margin-bottom: 16px;
    }
    p {
      color: rgba(255, 255, 255, 0.9);
      max-width: 700px;
      margin: 0 auto;
    }
  ---
  #title
  🔐 Authentication Guide

  #description
  Learn how to authenticate your API requests using API keys, OAuth 2.0, or OpenID Connect
  ::
::

::page-section
---
full-width: true
styles: |
  background: #FFFFFF;
  padding: clamp(50px, 7vw, 70px) 0;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(24px, 4vw, 32px)"
  title-tag: "h2"
  text-align: "left"
  title-line-height: "clamp(32px, 5vw, 40px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(15px, 3vw, 16px)"
  description-line-height: "clamp(24px, 4vw, 26px)"
  styles: |
    max-width: 900px;
    margin: 0 auto;
    padding: 0 20px;
    h2 {
      color: #1F2937;
      margin-bottom: 20px;
    }
    p {
      color: #6B7280;
      margin-bottom: 24px;
    }
    pre {
      background: #1F2937;
      color: #F9FAFB;
      padding: 24px;
      border-radius: 8px;
      overflow-x: auto;
      margin: 24px 0;
      font-family: 'Monaco', 'Menlo', monospace;
      font-size: 14px;
      line-height: 1.6;
    }
    code {
      background: #E5E7EB;
      color: #1F2937;
      padding: 2px 6px;
      border-radius: 4px;
      font-family: 'Monaco', 'Menlo', monospace;
      font-size: 14px;
    }
  ---
  #title
  API Key Authentication

  #description
  The simplest way to authenticate is using an API key. Include your API key in the `apikey` header of each request.

  ### Step 1: Get Your API Key

  1. Log in to the Developer Portal
  2. Navigate to **"My Apps"**
  3. Create a new application or select an existing one
  4. Register your application with the API
  5. Copy your API key (starts with `kpat_`)

  ### Step 2: Make Authenticated Requests

  **cURL Example:**
  ```bash
  curl -X GET "https://api.example.com/v1/users" \
    -H "apikey: kpat_your_api_key_here" \
    -H "Content-Type: application/json"
  ```

  **JavaScript Example:**
  ```javascript
  const API_KEY = 'kpat_your_api_key_here';
  const API_URL = 'https://api.example.com';

  fetch(`${API_URL}/v1/users`, {
    headers: {
      'apikey': API_KEY,
      'Content-Type': 'application/json'
    }
  })
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error('Error:', error));
  ```

  **Python Example:**
  ```python
  import requests

  API_KEY = 'kpat_your_api_key_here'
  API_URL = 'https://api.example.com'

  headers = {
      'apikey': API_KEY,
      'Content-Type': 'application/json'
  }

  response = requests.get(f'{API_URL}/v1/users', headers=headers)
  data = response.json()
  print(data)
  ```

  ### Step 3: Handle Errors

  **401 Unauthorized:**
  ```json
  {
    "message": "No API key found in request"
  }
  ```

  **Solution:** Ensure you're including the `apikey` header in your request.

  **403 Forbidden:**
  ```json
  {
    "message": "Invalid authentication credentials"
  }
  ```

  **Solution:** Verify your API key is correct and active.
  ::
::

::page-section
---
full-width: true
styles: |
  background: #F9FAFB;
  padding: clamp(50px, 7vw, 70px) 0;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(24px, 4vw, 32px)"
  title-tag: "h2"
  text-align: "left"
  title-line-height: "clamp(32px, 5vw, 40px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(15px, 3vw, 16px)"
  description-line-height: "clamp(24px, 4vw, 26px)"
  styles: |
    max-width: 900px;
    margin: 0 auto;
    padding: 0 20px;
    h2 {
      color: #1F2937;
      margin-bottom: 20px;
    }
    p {
      color: #6B7280;
      margin-bottom: 16px;
    }
    ul {
      color: #6B7280;
      margin: 16px 0;
      padding-left: 24px;
    }
    li {
      margin-bottom: 8px;
    }
  ---
  #title
  Best Practices

  #description
  Follow these best practices to keep your API keys secure and your integrations running smoothly:

  ### Security

  - ✅ **Never commit API keys to version control** - Use environment variables
  - ✅ **Rotate keys regularly** - Update keys every 90 days
  - ✅ **Use HTTPS only** - Always use secure connections
  - ✅ **Limit key permissions** - Grant minimum required access
  - ✅ **Monitor key usage** - Track requests in Portal analytics

  ### Performance

  - ✅ **Cache responses** - Reduce API calls when possible
  - ✅ **Handle rate limits** - Respect rate limit headers
  - ✅ **Use pagination** - Request data in chunks
  - ✅ **Implement retries** - Handle transient failures gracefully

  ### Error Handling

  - ✅ **Check status codes** - Handle 4xx and 5xx errors appropriately
  - ✅ **Parse error messages** - Use error details for debugging
  - ✅ **Log failures** - Keep records for troubleshooting
  - ✅ **Implement fallbacks** - Have backup strategies
  ::
::

::page-section
---
full-width: true
styles: |
  background: linear-gradient(135deg, #F9FAFB 0%, #E5E7EB 100%);
  padding: clamp(40px, 6vw, 60px) 0;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(24px, 4vw, 32px)"
  title-tag: "h2"
  text-align: "center"
  title-line-height: "clamp(32px, 5vw, 40px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(15px, 3vw, 18px)"
  description-line-height: "clamp(24px, 4vw, 28px)"
  styles: |
    h2 {
      color: #1F2937;
      margin-bottom: 16px;
    }
    p {
      color: #6B7280;
      max-width: 600px;
      margin: 0 auto 32px;
    }
  ---
  #title
  Need Help?

  #description
  Our support team is here to help you succeed

  #actions
    ::button
    ---
    appearance: "primary"
    size: "large"
    styles: |
      background-color: #00C9B7;
      color: #003F6C;
      font-weight: 600;
      padding: 14px 28px;
      border-radius: 8px;
      font-size: 16px;
      border: none;
      box-shadow: 0 4px 12px rgba(0, 201, 183, 0.3);
      transition: all 0.3s ease;
      cursor: pointer;
      &:hover {
        background-color: #00E5CD;
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0, 201, 183, 0.4);
      }
    ---
    Contact Support
    ::

    ::button
    ---
    appearance: "secondary"
    size: "large"
    styles: |
      background-color: #FFFFFF;
      color: #003F6C;
      font-weight: 600;
      padding: 14px 28px;
      border: 2px solid #003F6C;
      border-radius: 8px;
      font-size: 16px;
      transition: all 0.3s ease;
      cursor: pointer;
      margin-left: 16px;
      &:hover {
        background-color: #003F6C;
        color: #FFFFFF;
        transform: translateY(-2px);
      }
    ---
    View Documentation
    ::
  ::
::
```

---

## API Catalog Template

**File:** `api-catalog.md`
**Purpose:** Browse all available APIs

```yaml
---
title: API Catalog
description: Browse all available APIs
---

::page-section
---
full-width: true
styles: |
  background: linear-gradient(135deg, #003F6C 0%, #00588A 100%);
  padding: clamp(50px, 7vw, 80px) 0;
  margin-top: -20px;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(28px, 5vw, 44px)"
  title-tag: "h1"
  text-align: "center"
  title-line-height: "clamp(36px, 6vw, 52px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(16px, 3vw, 20px)"
  description-line-height: "clamp(24px, 4vw, 30px)"
  styles: |
    h1 {
      color: #FFFFFF;
      margin-bottom: 16px;
    }
    p {
      color: rgba(255, 255, 255, 0.9);
      max-width: 700px;
      margin: 0 auto;
    }
  ---
  #title
  📚 API Catalog

  #description
  Explore our complete collection of APIs
  ::
::

::page-section
---
full-width: true
styles: |
  background: #FFFFFF;
  padding: clamp(60px, 8vw, 80px) 0;
---
  ::grid-layout
  ---
  columns: 3
  gap: 32px
  columns-breakpoints:
    mobile: 1
    desktop: 3
    laptop: 3
    phablet: 1
    tablet: 2
  styles: |
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
  ---
    <!-- Copy API card snippet here for each API -->
    <!-- See snippets.md for the API card template -->
  ::
::
```

---

## Design System

### Colors

```css
/* Primary Colors */
--kong-blue: #003F6C;
--kong-teal: #00C9B7;

/* Neutral Colors */
--gray-50: #F9FAFB;
--gray-100: #F3F4F6;
--gray-600: #4B5563;
--gray-900: #1F2937;

/* Semantic Colors */
--success: #10B981;
--warning: #F59E0B;
--error: #EF4444;
```

### Typography

```css
/* Responsive Font Sizes */
H1: clamp(32px, 6vw, 56px)
H2: clamp(28px, 5vw, 40px)
H3: clamp(22px, 4vw, 28px)
Body: clamp(15px, 3vw, 16px)
```

### Spacing

```css
/* Section Padding */
padding: clamp(60px, 8vw, 80px) 0;

/* Card Padding */
padding: 28px - 32px;

/* Grid Gaps */
gap: 32px - 48px;
```

---

## Best Practices

### Performance

- ✅ Use `clamp()` for responsive sizing
- ✅ Optimize images (WebP, max 200KB)
- ✅ Minimize custom CSS
- ✅ Lazy load images

### Accessibility

- ✅ Maintain 4.5:1 contrast ratio
- ✅ Use semantic HTML
- ✅ Add alt text to images
- ✅ Ensure keyboard navigation

### SEO

- ✅ Use descriptive titles
- ✅ Write clear descriptions
- ✅ Use proper heading hierarchy
- ✅ Add meta descriptions

### Mobile

- ✅ Test on multiple devices
- ✅ Use responsive breakpoints
- ✅ Ensure touch targets are 44px+
- ✅ Test in portrait and landscape

---

**Ready to build your portal? Start with the Landing Page Template above! 🚀**

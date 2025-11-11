# Kong Dev Portal - Customization Guide

> **Copy-paste examples to build a full-fledged portal**
> Mix and match components to create your perfect developer experience

---

## 📋 Table of Contents

1. [Quick Customization](#quick-customization)
2. [Component Library](#component-library)
3. [Page Layouts](#page-layouts)
4. [Brand Customization](#brand-customization)
5. [Advanced Features](#advanced-features)

---

## Quick Customization

### Change Brand Colors

Find and replace throughout your portal pages:

```yaml
# From (Kong Blue)
#003F6C → #YOUR_PRIMARY_COLOR

# From (Kong Teal)
#00C9B7 → #YOUR_SECONDARY_COLOR
```

**Example:**
```yaml
# Before
background-color: #00C9B7;
color: #003F6C;

# After (for Stripe branding)
background-color: #635BFF;
color: #0A2540;
```

### Add Your Logo

**Option 1: Portal Settings (Recommended)**
```
1. Kong Konnect → Dev Portal → Settings → Appearance
2. Upload logo image
3. Automatic display across all pages
```

**Option 2: Custom Header**
```yaml
::page-section
---
styles: |
  padding: 20px 0;
  text-align: center;
---
  #description
  <img src="https://your-domain.com/logo.png" alt="Company Logo" style="height: 40px;">
::
```

### Change Button Text

```yaml
# Find buttons in your template
::button
---
appearance: "primary"
---
Get Started  ← Change this text
::

# Example customizations:
# "Get Started" → "Start Building"
# "View Documentation" → "Read Docs"
# "Contact Sales" → "Talk to Sales"
```

---

## Component Library

### Hero Section (Gradient Background)

**Use for:** Landing page, major sections

```yaml
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
  styles: |
    h1 { color: #FFFFFF; }
    p { color: rgba(255, 255, 255, 0.9); }
  ---
  #title
  Your Hero Title

  #description
  Your compelling description goes here

  #actions
    ::button
    ---
    appearance: "primary"
    styles: |
      background-color: #00C9B7;
      color: #003F6C;
      padding: 16px 32px;
      border-radius: 8px;
      cursor: pointer;
      &:hover { background-color: #00E5CD; }
    ---
    Primary Action
    ::
  ::
::
```

**Customization Options:**

```yaml
# Dark hero (black background)
background: linear-gradient(135deg, #000000 0%, #1F2937 100%);

# Light hero (white background)
background: linear-gradient(135deg, #FFFFFF 0%, #F9FAFB 100%);
styles: |
  h1 { color: #1F2937; }
  p { color: #6B7280; }

# Brand colors
background: linear-gradient(135deg, #YOUR_COLOR_1 0%, #YOUR_COLOR_2 100%);
```

---

### Feature Card (Hover Effect)

**Use for:** Features, guides, benefits

```yaml
::page-hero
---
title-font-size: "clamp(22px, 4vw, 28px)"
title-tag: "h3"
styles: |
  background: #FFFFFF;
  border-radius: 12px;
  padding: 32px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  }
  h3 { color: #1F2937; }
  p { color: #6B7280; }
---
#title
🚀 Feature Name

#description
Description of the feature with clear benefits

#actions
  ::button
  ---
  appearance: "link"
  styles: |
    color: #00C9B7;
    &:hover { color: #00588A; }
  ---
  Learn More →
  ::
::
```

**Customization Options:**

```yaml
# Colored background
background: #DBEAFE;  # Light blue
background: #FEF3C7;  # Light yellow
background: #D1FAE5;  # Light green

# Icon changes
#title
🎯 Your Icon + Title  # Change emoji icon

# Remove hover effect
transition: none;
&:hover { }  # Remove hover styles
```

---

### API Card (Compact)

**Use for:** API listings, product catalog

```yaml
::page-hero
---
title-font-size: "clamp(20px, 4vw, 24px)"
title-tag: "h4"
styles: |
  background: #FFFFFF;
  border: 1px solid #E5E7EB;
  border-radius: 10px;
  padding: 28px;
  transition: all 0.3s ease;
  &:hover {
    border-color: #00C9B7;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 201, 183, 0.15);
  }
  h4 { color: #1F2937; margin-bottom: 8px; }
  p { color: #6B7280; margin-bottom: 16px; }
---
#title
📊 API Name

#description
Short description of what this API does

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
  ---
  REST
  ::

  ::button
  ---
  appearance: "link"
  styles: |
    color: #00C9B7;
    margin-top: 12px;
    &:hover { color: #00588A; }
  ---
  View Docs →
  ::
::
```

**Badge Color Options:**

```yaml
# REST (Blue)
background: #DBEAFE; color: #1E40AF;

# GraphQL (Green)
background: #D1FAE5; color: #065F46;

# WebSocket (Purple)
background: #EDE9FE; color: #5B21B6;

# AI/ML (Yellow)
background: #FEF3C7; color: #92400E;

# Beta (Gray)
background: #F3F4F6; color: #374151;
```

---

### Code Block (Syntax Highlighting)

**Use for:** Code examples, API responses

```yaml
::page-hero
---
styles: |
  pre {
    background: #1F2937;
    color: #F9FAFB;
    padding: 24px;
    border-radius: 8px;
    overflow-x: auto;
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
  }
---
#description
```bash
curl -X GET "https://api.example.com/v1/users" \
  -H "apikey: your_api_key"
```
::
```

**Language-Specific Highlighting:**

```yaml
# JavaScript/JSON
background: #282C34;  # VS Code dark theme
color: #ABB2BF;

# Python
background: #263238;  # Material theme
color: #EEFFFF;

# Terminal/Bash
background: #000000;  # Black terminal
color: #00FF00;      # Green text
```

---

### Info Box (Callouts)

**Use for:** Tips, warnings, important notes

```yaml
::page-hero
---
styles: |
  background: #DBEAFE;
  border-left: 4px solid #3B82F6;
  padding: 20px;
  border-radius: 8px;
  margin: 24px 0;
  p { color: #1E40AF; margin: 0; }
---
#description
💡 **Tip:** This is an important piece of information
::
```

**Callout Styles:**

```yaml
# Info (Blue)
background: #DBEAFE; border-left: 4px solid #3B82F6; color: #1E40AF;

# Success (Green)
background: #D1FAE5; border-left: 4px solid #10B981; color: #065F46;

# Warning (Yellow)
background: #FEF3C7; border-left: 4px solid #F59E0B; color: #92400E;

# Error (Red)
background: #FEE2E2; border-left: 4px solid #EF4444; color: #991B1B;
```

---

### Button Variations

**Primary Button:**
```yaml
::button
---
appearance: "primary"
styles: |
  background-color: #00C9B7;
  color: #003F6C;
  padding: 16px 32px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  &:hover { background-color: #00E5CD; }
---
Button Text
::
```

**Secondary Button:**
```yaml
::button
---
appearance: "secondary"
styles: |
  background-color: transparent;
  color: #003F6C;
  padding: 16px 32px;
  border: 2px solid #003F6C;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  &:hover { background-color: #003F6C; color: #FFFFFF; }
---
Button Text
::
```

**Link Button:**
```yaml
::button
---
appearance: "link"
styles: |
  color: #00C9B7;
  padding: 0;
  background: none;
  border: none;
  font-weight: 600;
  cursor: pointer;
  &:hover { color: #00588A; text-decoration: underline; }
---
Link Text →
::
```

---

## Page Layouts

### Two-Column Layout

**Use for:** Features, comparisons, split content

```yaml
::grid-layout
---
columns: 2
gap: 48px
columns-breakpoints:
  mobile: 1
  tablet: 2
  desktop: 2
styles: |
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
---
  <!-- Column 1 -->
  ::page-hero
  ---
  ---
  #title
  Left Column Content
  ::

  <!-- Column 2 -->
  ::page-hero
  ---
  ---
  #title
  Right Column Content
  ::
::
```

### Three-Column Layout (API Grid)

**Use for:** API cards, feature lists, pricing tiers

```yaml
::grid-layout
---
columns: 3
gap: 32px
columns-breakpoints:
  mobile: 1
  tablet: 2
  desktop: 3
styles: |
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
---
  <!-- API Card 1 -->
  <!-- API Card 2 -->
  <!-- API Card 3 -->
::
```

### Full-Width Section

**Use for:** Hero sections, CTAs, major divisions

```yaml
::page-section
---
full-width: true
styles: |
  background: #F9FAFB;
  padding: clamp(60px, 8vw, 80px) 0;
---
  <!-- Content goes here -->
::
```

---

## Brand Customization

### Custom Color Scheme

**1. Define your colors:**
```yaml
# Your brand colors
Primary: #5B21B6    # Purple
Secondary: #EC4899  # Pink
Accent: #F59E0B     # Amber
```

**2. Apply globally in each page:**
```yaml
::page-section
---
styles: |
  /* Global color variables */
  :root {
    --color-primary: #5B21B6;
    --color-secondary: #EC4899;
    --color-accent: #F59E0B;
  }

  /* Apply to buttons */
  button {
    background-color: var(--color-primary);
  }

  /* Apply to links */
  a {
    color: var(--color-secondary);
  }
---
```

### Custom Fonts

**Google Fonts:**
```yaml
::page-section
---
styles: |
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap');

  * {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  }

  h1, h2, h3, h4 {
    font-family: 'Inter', sans-serif;
    font-weight: 700;
  }
---
```

**System Fonts:**
```yaml
styles: |
  * {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica', 'Arial', sans-serif;
  }
```

### Custom Logo Header

```yaml
::page-section
---
full-width: true
styles: |
  background: #FFFFFF;
  padding: 20px 0;
  border-bottom: 1px solid #E5E7EB;
  text-align: center;
---
  #description
  <div style="max-width: 1200px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; padding: 0 20px;">
    <img src="https://your-domain.com/logo.png" alt="Logo" style="height: 40px;">
    <nav style="display: flex; gap: 32px;">
      <a href="/apis" style="color: #1F2937; text-decoration: none; font-weight: 600;">APIs</a>
      <a href="/docs" style="color: #1F2937; text-decoration: none; font-weight: 600;">Docs</a>
      <a href="/support" style="color: #1F2937; text-decoration: none; font-weight: 600;">Support</a>
    </nav>
  </div>
::
```

---

## Advanced Features

### Tabbed Content

```yaml
::page-hero
---
styles: |
  .tabs {
    display: flex;
    gap: 16px;
    border-bottom: 2px solid #E5E7EB;
    margin-bottom: 24px;
  }
  .tab {
    padding: 12px 24px;
    cursor: pointer;
    border-bottom: 2px solid transparent;
    transition: all 0.3s;
  }
  .tab.active {
    border-bottom-color: #00C9B7;
    color: #00C9B7;
  }
  .tab-content {
    display: none;
  }
  .tab-content.active {
    display: block;
  }
---
#description
<div class="tabs">
  <div class="tab active" onclick="showTab('tab1')">cURL</div>
  <div class="tab" onclick="showTab('tab2')">JavaScript</div>
  <div class="tab" onclick="showTab('tab3')">Python</div>
</div>

<div id="tab1" class="tab-content active">
```bash
curl -X GET "https://api.example.com/users"
```
</div>

<div id="tab2" class="tab-content">
```javascript
fetch('https://api.example.com/users')
```
</div>

<div id="tab3" class="tab-content">
```python
requests.get('https://api.example.com/users')
```
</div>

<script>
function showTab(tabId) {
  document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
  document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
  event.target.classList.add('active');
  document.getElementById(tabId).classList.add('active');
}
</script>
::
```

### Accordion/FAQ

```yaml
::page-hero
---
styles: |
  .accordion-item {
    border: 1px solid #E5E7EB;
    border-radius: 8px;
    margin-bottom: 12px;
    overflow: hidden;
  }
  .accordion-header {
    padding: 20px;
    cursor: pointer;
    background: #FFFFFF;
    font-weight: 600;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  .accordion-header:hover {
    background: #F9FAFB;
  }
  .accordion-content {
    display: none;
    padding: 0 20px 20px;
    color: #6B7280;
  }
  .accordion-content.active {
    display: block;
  }
---
#description
<div class="accordion-item">
  <div class="accordion-header" onclick="toggleAccordion(this)">
    How do I get started?
    <span>+</span>
  </div>
  <div class="accordion-content">
    Sign up for an account, create an application, and get your API key.
  </div>
</div>

<div class="accordion-item">
  <div class="accordion-header" onclick="toggleAccordion(this)">
    What are the rate limits?
    <span>+</span>
  </div>
  <div class="accordion-content">
    Standard tier: 1000 requests/hour. Premium tier: 10000 requests/hour.
  </div>
</div>

<script>
function toggleAccordion(header) {
  const content = header.nextElementSibling;
  content.classList.toggle('active');
  header.querySelector('span').textContent = content.classList.contains('active') ? '−' : '+';
}
</script>
::
```

### Video Embed

```yaml
::page-hero
---
styles: |
  .video-container {
    position: relative;
    padding-bottom: 56.25%;
    height: 0;
    overflow: hidden;
    border-radius: 12px;
  }
  .video-container iframe {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
  }
---
#description
<div class="video-container">
  <iframe
    src="https://www.youtube.com/embed/YOUR_VIDEO_ID"
    frameborder="0"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
    allowfullscreen>
  </iframe>
</div>
::
```

### Stats Counter

```yaml
::grid-layout
---
columns: 4
gap: 32px
columns-breakpoints:
  mobile: 2
  tablet: 2
  desktop: 4
---
  ::page-hero
  ---
  text-align: "center"
  styles: |
    h3 { font-size: 48px; color: #00C9B7; font-weight: 700; margin-bottom: 8px; }
    p { color: #6B7280; font-size: 16px; }
  ---
  #title
  10M+

  #description
  API Calls
  ::

  ::page-hero
  ---
  text-align: "center"
  styles: |
    h3 { font-size: 48px; color: #00C9B7; font-weight: 700; margin-bottom: 8px; }
    p { color: #6B7280; font-size: 16px; }
  ---
  #title
  50K+

  #description
  Developers
  ::

  ::page-hero
  ---
  text-align: "center"
  styles: |
    h3 { font-size: 48px; color: #00C9B7; font-weight: 700; margin-bottom: 8px; }
    p { color: #6B7280; font-size: 16px; }
  ---
  #title
  99.9%

  #description
  Uptime
  ::

  ::page-hero
  ---
  text-align: "center"
  styles: |
    h3 { font-size: 48px; color: #00C9B7; font-weight: 700; margin-bottom: 8px; }
    p { color: #6B7280; font-size: 16px; }
  ---
  #title
  <50ms

  #description
  Response Time
  ::
::
```

---

## Complete Page Example

**Copy this entire template for a production-ready landing page:**

```yaml
---
title: Welcome to Your API Platform
description: Build amazing applications with our APIs
---

<!-- Hero Section -->
::page-section
---
full-width: true
styles: |
  background: linear-gradient(135deg, #5B21B6 0%, #7C3AED 100%);
  padding: clamp(60px, 8vw, 100px) 0;
  margin-top: -20px;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(32px, 6vw, 56px)"
  text-align: "center"
  styles: |
    h1 { color: #FFFFFF; }
    p { color: rgba(255, 255, 255, 0.9); max-width: 800px; margin: 0 auto 40px; }
  ---
  #title
  Build Something Amazing

  #description
  Powerful APIs to accelerate your development. Get started in minutes.

  #actions
    ::button
    ---
    styles: |
      background: #FFFFFF;
      color: #5B21B6;
      padding: 16px 32px;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      &:hover { transform: translateY(-2px); box-shadow: 0 10px 25px rgba(0,0,0,0.2); }
    ---
    Start Free Trial
    ::
  ::
::

<!-- Features Section -->
::page-section
---
full-width: true
styles: |
  background: #F9FAFB;
  padding: clamp(60px, 8vw, 80px) 0;
---
  ::page-hero
  ---
  title-font-size: "clamp(28px, 5vw, 40px)"
  text-align: "center"
  styles: |
    h2 { color: #1F2937; margin-bottom: 60px; }
  ---
  #title
  Why Developers Love Our Platform
  ::

  ::grid-layout
  ---
  columns: 3
  gap: 32px
  columns-breakpoints:
    mobile: 1
    tablet: 2
    desktop: 3
  styles: |
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
  ---
    ::page-hero
    ---
    styles: |
      background: #FFFFFF;
      padding: 32px;
      border-radius: 12px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);
      &:hover { transform: translateY(-4px); box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
    ---
    #title
    ⚡ Lightning Fast

    #description
    Sub-50ms response times with global CDN
    ::

    ::page-hero
    ---
    styles: |
      background: #FFFFFF;
      padding: 32px;
      border-radius: 12px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);
      &:hover { transform: translateY(-4px); box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
    ---
    #title
    🔒 Secure by Default

    #description
    Enterprise-grade security with SOC 2 compliance
    ::

    ::page-hero
    ---
    styles: |
      background: #FFFFFF;
      padding: 32px;
      border-radius: 12px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);
      &:hover { transform: translateY(-4px); box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
    ---
    #title
    📚 Great Docs

    #description
    Comprehensive guides with code examples
    ::
  ::
::

<!-- CTA Section -->
::page-section
---
full-width: true
styles: |
  background: linear-gradient(135deg, #F9FAFB 0%, #E5E7EB 100%);
  padding: clamp(50px, 7vw, 70px) 0;
---
  ::page-hero
  ---
  title-font-size: "clamp(28px, 5vw, 36px)"
  text-align: "center"
  styles: |
    h2 { color: #1F2937; margin-bottom: 16px; }
    p { color: #6B7280; margin-bottom: 40px; }
  ---
  #title
  Ready to Get Started?

  #description
  Join thousands of developers building with our APIs

  #actions
    ::button
    ---
    styles: |
      background: #5B21B6;
      color: #FFFFFF;
      padding: 16px 32px;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      &:hover { background: #7C3AED; transform: translateY(-2px); }
    ---
    Create Free Account
    ::
  ::
::
```

---

**Mix and match these components to build your perfect portal! 🎨**

**For more components, see:** [snippets.md](./snippets.md)
**For complete templates, see:** [portal-guide.md](./portal-guide.md)

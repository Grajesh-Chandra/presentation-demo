# Kong Dev Portal - Reusable Snippets Library

This file contains reusable snippets for consistent styling across the Kong Dev Portal.

## 🎨 Design System

**Colors:**
- Primary: `#003F6C` (Kong Blue)
- Secondary: `#00C9B7` (Kong Teal)
- Success: `#10B981`
- Warning: `#F59E0B`
- Error: `#EF4444`
- Background: `#F9FAFB`
- Card Background: `#FFFFFF`
- Text Primary: `#1F2937`
- Text Secondary: `#6B7280`

---

## 1. Hero Section (Full-Width with Gradient)

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
  Your Title Here

  #description
  Your description text here

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
      &:hover {
        background-color: #00E5CD;
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0, 201, 183, 0.4);
      }
    ---
    Primary Action
    ::
  ::
::
```

**Use case:** Landing page hero, major section headers

---

## 2. Feature Card (Hover Effect)

```yaml
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
description-line-height: "clamp(22px, 4vw, 24px)"
styles: |
  background: #FFFFFF;
  border-radius: 12px;
  padding: 32px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  border: 1px solid #E5E7EB;
  &:hover {
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
    transform: translateY(-4px);
    border-color: #00C9B7;
  }
  h3 {
    color: #003F6C;
    margin-bottom: 12px;
  }
  p {
    color: #4B5563;
    margin-bottom: 24px;
  }
---
#title
🔐 Your Feature Title

#description
Feature description text here

#actions
  ::button
  ---
  appearance: "secondary"
  size: "medium"
  styles: |
    background-color: #003F6C;
    color: #FFFFFF;
    font-weight: 600;
    padding: 12px 24px;
    border-radius: 6px;
    border: none;
    transition: all 0.3s ease;
    &:hover {
      background-color: #00588A;
    }
  ---
  Learn More →
  ::
::
```

**Use case:** Feature highlights, guide cards, tutorial sections

---

## 3. API Card (Compact)

```yaml
::page-hero
---
full-width: true
title-font-size: "clamp(20px, 4vw, 24px)"
title-tag: "h4"
text-align: "left"
title-line-height: "clamp(28px, 5vw, 32px)"
title-font-weight: "700"
description-font-weight: "400"
description-font-size: "clamp(14px, 3vw, 15px)"
description-line-height: "clamp(20px, 4vw, 22px)"
styles: |
  background: #FFFFFF;
  border-radius: 10px;
  padding: 28px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  border: 1px solid #E5E7EB;
  height: 100%;
  &:hover {
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
    transform: translateY(-3px);
  }
  h4 {
    color: #003F6C;
    margin-bottom: 10px;
  }
  p {
    color: #6B7280;
    margin-bottom: 20px;
    font-size: 14px;
  }
---
#title
📊 API Name

#description
API description text

#actions
  ::button
  ---
  appearance: "secondary"
  size: "small"
  styles: |
    background-color: transparent;
    color: #003F6C;
    font-weight: 600;
    padding: 8px 20px;
    border-radius: 6px;
    border: 2px solid #003F6C;
    font-size: 14px;
    transition: all 0.3s ease;
    &:hover {
      background-color: #003F6C;
      color: #FFFFFF;
    }
  ---
  View API →
  ::
::
```

**Use case:** API catalog, service listings

---

## 4. Section Header (Centered)

```yaml
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
description-line-height: "clamp(24px, 4vw, 32px)"
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
Section Title

#description
Section description
::
```

**Use case:** Major section dividers

---

## 5. Call-to-Action Section

```yaml
::page-section
---
full-width: true
styles: |
  padding: clamp(50px, 7vw, 70px) 0;
  background: linear-gradient(135deg, #F3F4F6 0%, #E5E7EB 100%);
  border-top: 1px solid #D1D5DB;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(24px, 5vw, 36px)"
  title-tag: "h2"
  text-align: "center"
  title-line-height: "clamp(32px, 6vw, 44px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(16px, 3vw, 18px)"
  description-line-height: "clamp(24px, 4vw, 28px)"
  styles: |
    h2 {
      color: #1F2937;
      margin-bottom: 16px;
    }
    p {
      color: #6B7280;
      max-width: 600px;
      margin: 0 auto 40px;
    }
  ---
  #title
  Ready to Get Started?

  #description
  Your CTA description

  #actions
    ::button
    ---
    appearance: "primary"
    size: "large"
    styles: |
      background-color: #003F6C;
      color: #FFFFFF;
      font-weight: 600;
      padding: 16px 40px;
      border-radius: 8px;
      font-size: 18px;
      border: none;
      box-shadow: 0 4px 12px rgba(0, 63, 108, 0.3);
      transition: all 0.3s ease;
      &:hover {
        background-color: #00588A;
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0, 63, 108, 0.4);
      }
    ---
    Primary Action →
    ::
  ::
::
```

**Use case:** End-of-page CTAs, conversion sections

---

## 6. Two-Column Layout

```yaml
::page-section
---
full-width: true
styles: |
  padding: clamp(60px, 8vw, 80px) 0;
  background-color: #FFFFFF;
---
  ::multi-column
  ---
  gap: "32px"
  columns-breakpoints:
    mobile: 1
    desktop: 2
    laptop: 2
    phablet: 1
    tablet: 2
  styles: |
    max-width: 1200px;
    margin: 0 auto;
  ---
    <!-- Place your cards here -->
  ::
::
```

**Use case:** Feature comparisons, guide listings

---

## 7. Three-Column Layout (API Grid)

```yaml
::page-section
---
full-width: true
styles: |
  padding: clamp(60px, 8vw, 80px) 0;
  background-color: #FFFFFF;
---
  ::multi-column
  ---
  gap: "24px"
  columns-breakpoints:
    mobile: 1
    desktop: 3
    laptop: 3
    phablet: 2
    tablet: 2
  styles: |
    max-width: 1200px;
    margin: 0 auto;
  ---
    <!-- Place your API cards here -->
  ::
::
```

**Use case:** API catalogs, product grids

---

## 8. Primary Button (Teal)

```yaml
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
  &:hover {
    background-color: #00E5CD;
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0, 201, 183, 0.4);
  }
---
Button Text
::
```

---

## 9. Secondary Button (Blue)

```yaml
::button
---
appearance: "secondary"
size: "medium"
styles: |
  background-color: #003F6C;
  color: #FFFFFF;
  font-weight: 600;
  padding: 12px 24px;
  border-radius: 6px;
  border: none;
  transition: all 0.3s ease;
  &:hover {
    background-color: #00588A;
  }
---
Button Text
::
```

---

## 10. Outline Button

```yaml
::button
---
appearance: "secondary"
size: "medium"
styles: |
  background-color: transparent;
  color: #003F6C;
  font-weight: 600;
  padding: 12px 24px;
  border-radius: 6px;
  border: 2px solid #003F6C;
  transition: all 0.3s ease;
  &:hover {
    background-color: #003F6C;
    color: #FFFFFF;
  }
---
Button Text
::
```

---

## 11. Status Badge

```yaml
styles: |
  .badge {
    display: inline-block;
    background-color: #DBEAFE;
    color: #003F6C;
    padding: 4px 12px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
    margin-bottom: 12px;
  }
  .badge.success {
    background-color: #D1FAE5;
    color: #065F46;
  }
  .badge.warning {
    background-color: #FEF3C7;
    color: #92400E;
  }
  .badge.error {
    background-color: #FEE2E2;
    color: #991B1B;
  }
```

**HTML usage:**
```html
<span class="badge">REST API</span>
<span class="badge success">Active</span>
<span class="badge warning">Beta</span>
<span class="badge error">Deprecated</span>
```

---

## 12. Divider

```yaml
::page-section
---
margin: "clamp(0, 3vw, 25px) 0"
styles: |
  hr {
    border: none;
    border-top: 1px solid #E5E7EB;
    margin: 40px 0;
  }
---
<hr>
::
```

---

## 13. Icon Set (Emojis)

Use these consistent emojis across the portal:

- 🔐 Authentication
- ⚡ Rate Limiting
- 📊 Analytics
- 🤖 AI Services
- 📈 Monitoring
- 🚀 Getting Started
- 📚 Documentation
- 🔑 API Keys
- ⚙️ Configuration
- 🌐 Global
- 💡 Tips
- ⚠️ Warning
- ✅ Success
- ❌ Error

---

## Quick Usage Tips

1. **Always use clamp()** for responsive font sizes
2. **Maintain consistent spacing**: 60-80px for sections, 24-32px for gaps
3. **Use transitions** on hover for smooth effects
4. **Keep max-width** at 1200px for content sections
5. **Use border-radius**: 12px for cards, 8px for buttons, 6px for smaller elements
6. **Shadow hierarchy**:
   - Rest: `0 1px 3px rgba(0, 0, 0, 0.1)`
   - Hover: `0 10px 25px rgba(0, 0, 0, 0.1)`
   - Elevated: `0 4px 12px rgba(0, 201, 183, 0.3)`

---

## File Organization

```
portal/
├── getting-started.md          # Main landing page
├── authentication-guide.md     # Auth documentation
├── rate-limiting-guide.md      # Rate limit documentation
├── api-catalog.md              # API listings
└── snippets.md                 # This file
```

---

**Last Updated:** November 2, 2025

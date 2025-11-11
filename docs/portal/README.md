# Kong Dev Portal Documentation

> **3 simple files to build a professional developer portal**

---

## 📚 Documentation Files

| File | Purpose | When to Use |
|------|---------|-------------|
| **[portal-guide.md](./portal-guide.md)** | Complete page templates ready to use | Copy full pages: landing, auth guide, API catalog |
| **[customization.md](./customization.md)** | Copy-paste components and examples | Build custom pages by mixing components |
| **[snippets.md](./snippets.md)** | Reusable component library | Quick reference for individual components |

---

## 🚀 Quick Start

### 1. Start with a Template

**Option A: Use Complete Page (Fastest)**
```
1. Open portal-guide.md
2. Copy "Landing Page Template"
3. Paste into Kong Konnect → Dev Portal → Pages
4. Customize text and colors
5. Publish!
```

**Option B: Build Custom Page**
```
1. Open customization.md
2. Copy components you need (hero, cards, etc.)
3. Paste into new page
4. Arrange as needed
5. Publish!
```

### 2. Customize Your Brand

```
1. Replace colors:
   #003F6C → Your Primary Color
   #00C9B7 → Your Secondary Color

2. Add your logo:
   Portal Settings → Appearance → Upload Logo

3. Update text:
   - Change "Demo API Platform" to your name
   - Update descriptions
   - Customize button labels
```

### 3. Build Complete Portal

**Recommended Pages:**

| Page | Template | File |
|------|----------|------|
| Homepage | Landing Page Template | portal-guide.md |
| Authentication | Auth Guide Template | portal-guide.md |
| API Catalog | API Catalog Template | portal-guide.md |
| Custom Pages | Mix Components | customization.md |

---

## 📖 What's in Each File?

### portal-guide.md (Complete Templates)

- ✅ Landing page with hero, features, APIs (copy-paste ready)
- ✅ Authentication guide with code examples
- ✅ API catalog template
- ✅ Design system reference
- ✅ Best practices

**Use when:** You want a complete page fast

---

### customization.md (Build Your Own)

- ✅ Component library (hero, cards, buttons, etc.)
- ✅ Layout patterns (2-column, 3-column, full-width)
- ✅ Brand customization (colors, fonts, logo)
- ✅ Advanced features (tabs, accordion, video)
- ✅ Complete page example

**Use when:** You want to build custom layouts

---

### snippets.md (Component Reference)

- ✅ All reusable components with YAML
- ✅ Detailed styling options
- ✅ Variations for each component
- ✅ Technical reference

**Use when:** You need a specific component

---

## 🎨 Design System

### Colors

```css
Primary: #003F6C (Kong Blue)
Secondary: #00C9B7 (Kong Teal)
Background: #F9FAFB (Light Gray)
Text: #1F2937 (Dark Gray)
```

### Typography

```css
H1: clamp(32px, 6vw, 56px)
H2: clamp(28px, 5vw, 40px)
H3: clamp(22px, 4vw, 28px)
Body: clamp(15px, 3vw, 16px)
```

### Spacing

```css
Section Padding: clamp(60px, 8vw, 80px)
Card Padding: 28px - 32px
Grid Gap: 32px - 48px
```

---

## 🛠️ Common Tasks

### Add New API to Catalog

```yaml
# Copy this API card snippet:
::page-hero
---
title-font-size: "clamp(20px, 4vw, 24px)"
styles: |
  background: #FFFFFF;
  border: 1px solid #E5E7EB;
  border-radius: 10px;
  padding: 28px;
  &:hover { border-color: #00C9B7; }
---
#title
📊 Your API Name

#description
Short description of your API

#actions
  ::badge
  ---
  styles: |
    background: #DBEAFE;
    color: #1E40AF;
    padding: 4px 12px;
    border-radius: 12px;
  ---
  REST
  ::
::
```

### Add Feature Card

```yaml
::page-hero
---
styles: |
  background: #FFFFFF;
  border-radius: 12px;
  padding: 32px;
  &:hover { transform: translateY(-4px); }
---
#title
🚀 Feature Name

#description
Feature description goes here
::
```

### Change Hero Section

```yaml
# Find this in your page:
#title
Current Title

# Change to:
#title
Your New Title
```

---

## 📱 Responsive Design

All components are mobile-responsive using:

```yaml
# Responsive font sizes
clamp(min, preferred, max)

# Responsive columns
columns-breakpoints:
  mobile: 1
  tablet: 2
  desktop: 3
```

**Test on:**
- ✅ Mobile (< 768px)
- ✅ Tablet (768px - 1023px)
- ✅ Desktop (> 1024px)

---

## ✅ Best Practices

### Content

- ✅ Write clear, concise descriptions
- ✅ Use emojis sparingly for visual interest
- ✅ Include code examples in auth guides
- ✅ Link to actual API documentation

### Design

- ✅ Maintain consistent spacing
- ✅ Use brand colors throughout
- ✅ Ensure 4.5:1 contrast ratio
- ✅ Test on multiple devices

### Performance

- ✅ Optimize images (WebP, < 200KB)
- ✅ Minimize custom CSS
- ✅ Use system fonts when possible
- ✅ Test page load times

---

## 🔧 Troubleshooting

### Styles Not Applying

**Problem:** Custom styles don't work

**Solution:**
1. Check YAML indentation
2. Ensure `styles: |` has pipe character
3. Clear browser cache
4. Test in incognito mode

### Layout Breaking on Mobile

**Problem:** Content overlaps on small screens

**Solution:**
1. Use `clamp()` for all font sizes
2. Check `columns-breakpoints` settings
3. Test with browser dev tools (responsive mode)
4. Adjust padding with `clamp()`

### Colors Not Matching

**Problem:** Colors look different than expected

**Solution:**
1. Use hex codes, not color names
2. Check for transparent backgrounds
3. Test in different browsers
4. Verify contrast ratios

---

## 🎯 Next Steps

1. **Start Simple**
   - Copy landing page template
   - Customize text and colors
   - Publish first page

2. **Add More Pages**
   - Authentication guide
   - API catalog
   - Support/contact page

3. **Customize**
   - Add your logo
   - Apply brand colors
   - Add custom components

4. **Test & Iterate**
   - Test on mobile devices
   - Get user feedback
   - Refine and improve

---

## 📞 Support

**Questions?**
- 📚 Kong Docs: https://docs.konghq.com/konnect/dev-portal
- 💬 Community: https://discuss.konghq.com
- 📧 Support: support@konghq.com

---

**Ready to build? Start with [portal-guide.md](./portal-guide.md)! 🚀**

---

**Last Updated:** November 11, 2025

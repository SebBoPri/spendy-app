# Spendy App - Theme Configuration

**Version:** 2.0.0 - "Spendy Design System"
**Last Updated:** 2026-01-18
**Design Philosophy:** Vibrant, Modern, Floating Interface

---

## Overview

This theme provides a clean, spacious, and functional design system for the Spendy budgeting application. All values are defined as CSS custom properties (variables) in `:root` for easy customization and consistency.

---

## Color Palette

### Primary Colors
```css
--primary: #2D9CDB              /* Vibrant Blue - Main brand color */
--primary-dark: #1F7BAD         /* Darker blue for hover states */
--primary-light: #E3F2FD        /* Light blue for backgrounds */
--primary-alpha-10: rgba(45, 156, 219, 0.1)
--primary-alpha-20: rgba(45, 156, 219, 0.2)
```

**Usage:**
- `--primary`: Buttons, links, interactive elements, branding (#2D9CDB Vibrant Blue)
- `--primary-dark`: Hover states for buttons
- `--primary-light`: Subtle backgrounds, selected states
- `--primary-alpha-*`: Overlays, subtle accents

---

### Semantic Colors
```css
--expense-red: #E63946          /* Red for expenses */
--income-green: #27AE60         /* Green for income */
--warning-yellow: #F4A261       /* Yellow for warnings */
--info-blue: #2D9CDB            /* Blue for info */
--success-green: #27AE60        /* Success states */
--error-red: #E63946            /* Error states */
```

**Usage:**
- `--expense-red`: Expense amounts, negative values, delete actions
- `--income-green`: Income amounts, positive values, success messages
- `--warning-yellow`: Warnings, budget alerts
- `--info-blue`: Info messages, tooltips
- `--success-green`: Success notifications, completion states
- `--error-red`: Error messages, validation failures

---

### Neutral Colors
```css
--background: #F8F9FA           /* Off-white background */
--card: #FFFFFF                 /* Pure white for cards */
--white: #FFFFFF                /* Pure white */
--border: #E5E7EB               /* Light grey borders */
--divider: #F3F4F6              /* Subtle dividers */
```

**Usage:**
- `--background`: App background, page background
- `--card`: Card backgrounds, modal backgrounds
- `--white`: Pure white for contrast
- `--border`: Card borders, input borders, dividers
- `--divider`: Horizontal rules, section separators

---

### Text Colors
```css
--text-primary: #333333         /* Dark grey - Main text */
--text-secondary: #6B7280       /* Medium grey - Secondary text */
--text-tertiary: #9CA3AF        /* Light grey - Tertiary text */
--text-disabled: #D1D5DB        /* Very light grey - Disabled */
--text-on-primary: #FFFFFF      /* White text on primary color */
```

**Usage:**
- `--text-primary`: Headings, primary content, important labels
- `--text-secondary`: Descriptions, helper text, metadata
- `--text-tertiary`: Placeholders, disabled text, timestamps
- `--text-disabled`: Disabled buttons, unavailable options
- `--text-on-primary`: Text on primary colored backgrounds

---

## Spacing System

Based on an 8px grid for consistency:

```css
--spacing-xs: 4px               /* Minimal spacing */
--spacing-sm: 8px               /* Small spacing */
--spacing-md: 16px              /* Medium spacing (base) */
--spacing-lg: 24px              /* Large spacing */
--spacing-xl: 32px              /* Extra large spacing */
--spacing-2xl: 48px             /* 2X large spacing */
--spacing-3xl: 64px             /* 3X large spacing */
```

**Usage Guide:**
- `xs`: Icon margins, tight spacing
- `sm`: Between inline elements
- `md`: Standard padding, margins (most common)
- `lg`: Section spacing, card padding
- `xl`: Component separation
- `2xl`: Major section breaks
- `3xl`: Page sections, hero spacing

---

## Border Radius

**SPENDY STANDARD** - Updated for modern, floating aesthetic:

```css
--radius-small: 8px             /* Small elements (tags, badges) */
--radius-medium: 12px           /* Buttons & small elements */
--radius-large: 24px            /* Large cards (UPDATED: 24px) */
--radius-xlarge: 24px           /* Large containers (UPDATED: 24px) */
--radius-round: 50%             /* Circular elements (avatars, icons) */
```

**Standard Applications:**
- **Buttons:** `--radius-medium` (12px) - Clean, modern
- **Large Cards:** `--radius-large` (24px) - Soft, floating appearance
- **Large Containers:** `--radius-xlarge` (24px) - Consistent with cards
- **Input fields:** `--radius-medium` (12px)
- **Badges/Tags:** `--radius-small` (8px)

**Key Change:** Large cards now use 24px radius for a more modern, spacious feel

---

## Shadows

**SOFT FLOATING SHADOWS** - Enhanced depth and modern elevation:

```css
--shadow-soft: 0px 10px 30px rgba(0, 0, 0, 0.05)     /* Soft Floating Shadow (UPDATED) */
--shadow-low: 0 2px 8px rgba(0, 0, 0, 0.04)          /* Very subtle */
--shadow-medium: 0 6px 20px rgba(0, 0, 0, 0.06)      /* Standard elevation */
--shadow-high: 0 12px 40px rgba(0, 0, 0, 0.08)       /* High elevation */
--shadow-primary: 0 8px 25px rgba(45, 156, 219, 0.15) /* Primary glow */
```

**Usage:**
- `--shadow-soft`: **Primary "Soft Floating Shadow"** (0px 10px 30px) - Use for all cards and containers
- `--shadow-low`: Subtle hover states, input focus
- `--shadow-medium`: Dropdowns, tooltips
- `--shadow-high`: Modals, popovers, floating elements
- `--shadow-primary`: Primary buttons, accent elements with blue glow

**Key Change:** Main shadow now has enhanced depth (10px 30px) for floating appearance

**Example:**
```css
.card {
    box-shadow: var(--shadow-soft);  /* 0px 10px 30px rgba(0, 0, 0, 0.05) */
    border-radius: var(--radius-large);  /* 24px */
}

.card:hover {
    box-shadow: var(--shadow-medium);
    transform: translateY(-2px);
}
```

---

## Typography

**CLEAN SANS-SERIF STACK** - Using **Inter** with system fallbacks:

```css
--font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', sans-serif;
```

### Font Sizes
```css
--font-size-xs: 12px            /* Small labels, captions */
--font-size-sm: 14px            /* Body text, descriptions */
--font-size-base: 16px          /* Standard body text */
--font-size-lg: 18px            /* Subheadings */
--font-size-xl: 20px            /* Section titles */
--font-size-2xl: 24px           /* Page titles */
--font-size-3xl: 32px           /* Hero headings */
```

### Font Weights (SPENDY Standard)
```css
--font-weight-normal: 400       /* Regular text */
--font-weight-medium: 500       /* Slightly emphasized */
--font-weight-semibold: 600     /* Subheaders (STANDARD) */
--font-weight-bold: 700         /* Headings (STANDARD) */
```

**Typography Hierarchy (Spendy):**
- **H1 (Page Title/Headings):** `--font-size-2xl` + `--font-weight-bold` (700)
- **H2 (Section/Subheaders):** `--font-size-xl` + `--font-weight-semibold` (600)
- **H3 (Subsection):** `--font-size-lg` + `--font-weight-semibold` (600)
- **Body:** `--font-size-sm` + `--font-weight-normal`
- **Small text:** `--font-size-xs` + `--font-weight-normal`

**Spendy Guidelines:**
- **All Headings:** Use `font-weight-bold` (700)
- **All Subheaders:** Use `font-weight-semibold` (600)
- Clean, readable hierarchy with clear distinction

---

## Transitions

Smooth, consistent animations:

```css
--transition-fast: 0.15s ease           /* Quick hover states */
--transition-base: 0.2s ease            /* Standard transitions */
--transition-slow: 0.3s ease            /* Smooth, noticeable */
--transition-bounce: 0.3s cubic-bezier(0.4, 0, 0.2, 1)
```

**Usage:**
```css
button {
    transition: all var(--transition-base);
}

.modal {
    transition: opacity var(--transition-slow);
}
```

---

## Z-Index Scale

Layering system for overlays and modals:

```css
--z-base: 1                     /* Base layer */
--z-dropdown: 100               /* Dropdown menus */
--z-sticky: 200                 /* Sticky headers */
--z-overlay: 500                /* Overlay backgrounds */
--z-modal: 1000                 /* Modal dialogs */
--z-toast: 2000                 /* Toast notifications */
--z-tooltip: 3000               /* Tooltips (highest) */
```

---

## Component Examples

### Card
```css
.card {
    background: var(--card);
    border-radius: var(--radius-large);
    box-shadow: var(--shadow-soft);
    padding: var(--spacing-lg);
}
```

### Button
```css
.btn {
    background: var(--primary);
    color: var(--text-on-primary);
    border-radius: var(--radius-medium);
    padding: var(--spacing-md) var(--spacing-lg);
    box-shadow: var(--shadow-primary);
    transition: all var(--transition-base);
}

.btn:hover {
    background: var(--primary-dark);
    transform: translateY(-2px);
}
```

### Input Field
```css
.input {
    border: 1px solid var(--border);
    border-radius: var(--radius-medium);
    padding: var(--spacing-md);
    font-size: var(--font-size-base);
    transition: all var(--transition-fast);
}

.input:focus {
    border-color: var(--primary);
    box-shadow: 0 0 0 3px var(--primary-alpha-10);
}
```

---

## Design Principles

1. **Minimalism:** Use white space generously
2. **Consistency:** Stick to defined values, don't create one-offs
3. **Hierarchy:** Use size, weight, and color to create clear hierarchy
4. **Accessibility:** Maintain 4.5:1 contrast ratio for text
5. **Responsiveness:** Scale spacing and typography for mobile

---

## Migration Guide

When applying this theme to existing components:

1. Replace hardcoded colors with CSS variables
2. Update `border-radius` to `--radius-large` (16px) for containers
3. Update button `border-radius` to `--radius-medium` (12px)
4. Replace all shadows with `--shadow-soft` (0px 4px 20px rgba(0, 0, 0, 0.05))
5. Use spacing variables instead of pixel values

**Example:**
```css
/* Before */
.card {
    background: #fff;
    border-radius: 20px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    padding: 24px;
}

/* After */
.card {
    background: var(--card);
    border-radius: var(--radius-large);
    box-shadow: var(--shadow-soft);
    padding: var(--spacing-lg);
}
```

---

## Dark Mode (Future)

For dark mode support, override these variables:

```css
@media (prefers-color-scheme: dark) {
    :root {
        --background: #1A1A1A;
        --card: #2D2D2D;
        --text-primary: #FFFFFF;
        --text-secondary: #B0B0B0;
        --border: #404040;
    }
}
```

---

## Quick Reference

**Most Common Usage (SPENDY Design System v2.0):**
- Primary color: `var(--primary)` → #2D9CDB (Vibrant Blue)
- Card background: `var(--card)` → #FFFFFF (White)
- Background: `var(--background)` → #F8F9FA (Off-White)
- Border radius for large cards: `var(--radius-large)` → **24px** ⭐ NEW
- Border radius for buttons: `var(--radius-medium)` → 12px
- Soft Floating Shadow: `var(--shadow-soft)` → **0px 10px 30px rgba(0, 0, 0, 0.05)** ⭐ NEW
- Standard spacing: `var(--spacing-lg)` → 24px
- Text color: `var(--text-primary)` → #333333
- Heading weight: `var(--font-weight-bold)` → 700
- Subheader weight: `var(--font-weight-semibold)` → 600

---

**Need Help?**
Refer to this documentation when styling new components or refactoring existing ones. All values are already defined in `index.html` under `:root`.

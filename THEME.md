# Spendy App - Theme Configuration

**Version:** 1.0.0
**Last Updated:** 2026-01-18
**Design Philosophy:** Modern, Minimalist Budgeting Interface

---

## Overview

This theme provides a clean, spacious, and functional design system for the Spendy budgeting application. All values are defined as CSS custom properties (variables) in `:root` for easy customization and consistency.

---

## Color Palette

### Primary Colors
```css
--primary: #2D9CDB              /* Teal - Main brand color */
--primary-dark: #1F7BAD         /* Darker teal for hover states */
--primary-light: #E3F2FD        /* Light teal for backgrounds */
--primary-alpha-10: rgba(45, 156, 219, 0.1)
--primary-alpha-20: rgba(45, 156, 219, 0.2)
```

**Usage:**
- `--primary`: Buttons, links, interactive elements, branding
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

Standardized rounded corners for consistency:

```css
--radius-small: 8px             /* Small elements (tags, badges) */
--radius-medium: 12px           /* Buttons, inputs */
--radius-large: 16px            /* Cards, containers */
--radius-xlarge: 20px           /* Large containers, modals */
--radius-round: 50%             /* Circular elements (avatars, icons) */
```

**Standard Applications:**
- **Buttons:** `--radius-medium` (12px)
- **Cards:** `--radius-large` (16px)
- **Containers:** `--radius-large` (16px)
- **Input fields:** `--radius-medium` (12px)
- **Badges/Tags:** `--radius-small` (8px)

---

## Shadows

Soft, minimal shadows for depth without harshness:

```css
--shadow-soft: 0px 4px 20px rgba(0, 0, 0, 0.05)      /* Main soft shadow */
--shadow-low: 0 1px 3px rgba(0, 0, 0, 0.06)          /* Very subtle */
--shadow-medium: 0 4px 12px rgba(0, 0, 0, 0.08)      /* Standard elevation */
--shadow-high: 0 8px 24px rgba(0, 0, 0, 0.12)        /* High elevation */
--shadow-primary: 0 4px 20px rgba(45, 156, 219, 0.2) /* Primary glow */
```

**Usage:**
- `--shadow-soft`: **Primary shadow** - Use for all cards and containers
- `--shadow-low`: Subtle hover states, input focus
- `--shadow-medium`: Dropdowns, tooltips
- `--shadow-high`: Modals, popovers, floating elements
- `--shadow-primary`: Primary buttons, accent elements

**Example:**
```css
.card {
    box-shadow: var(--shadow-soft);
}

.card:hover {
    box-shadow: var(--shadow-medium);
}
```

---

## Typography

Using **Inter** font family with fallbacks:

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

### Font Weights
```css
--font-weight-normal: 400       /* Regular text */
--font-weight-medium: 500       /* Slightly emphasized */
--font-weight-semibold: 600     /* Subheadings, important labels */
--font-weight-bold: 700         /* Headings, primary emphasis */
```

**Typography Hierarchy:**
- **H1 (Page Title):** `--font-size-2xl` + `--font-weight-bold`
- **H2 (Section):** `--font-size-xl` + `--font-weight-semibold`
- **H3 (Subsection):** `--font-size-lg` + `--font-weight-semibold`
- **Body:** `--font-size-sm` + `--font-weight-normal`
- **Small text:** `--font-size-xs` + `--font-weight-normal`

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

**Most Common Usage:**
- Primary color: `var(--primary)` → #2D9CDB
- Card background: `var(--card)` → #FFFFFF
- Border radius for cards: `var(--radius-large)` → 16px
- Border radius for buttons: `var(--radius-medium)` → 12px
- Standard shadow: `var(--shadow-soft)` → 0px 4px 20px rgba(0, 0, 0, 0.05)
- Standard spacing: `var(--spacing-lg)` → 24px
- Text color: `var(--text-primary)` → #333333

---

**Need Help?**
Refer to this documentation when styling new components or refactoring existing ones. All values are already defined in `index.html` under `:root`.

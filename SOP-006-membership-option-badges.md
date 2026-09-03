# SOP-006: Managing Membership Option Badges on Echelon Product Pages
**Author:** Nicolas Cartin Reyes<br>
**Audience:** Internal Echelon developers, Shopify administrators and technical operators<br>

**Store:** echelonfit.com (Shopify)
**Applies to:** Individual product pages using the membership selector (e.g., Stride 6S, and any product with 30-Days / 1-Year / 2-Year membership options)
**Last updated:** August 2026

---

## Overview

The membership options section on individual product pages displays up to three membership plans (30-Days, 1-Year Access, 2-Year Access). Each plan can display:

- A blue badge (e.g., "Free Shipping") controlled by the `discount` field
- A yellow badge (e.g., "Most Popular") controlled by the `best_price` field
- A price on the right (e.g., + $399.99) pulled automatically from the product price
- A subtext below the title (e.g., "Start or cancel anytime.") controlled by the `include_text` field

All of these are managed through a product metafield. No code changes are required for routine badge updates.

---

## Files Involved (Reference Only)

| File | Location | Purpose |
|------|----------|---------|
| `individual-product-selection.liquid` | `snippets/` | Loops through membership products and reads metafields |
| `product-radio-option.liquid` | `snippets/` | Renders each individual membership option row |
| `pdp-2025.css` | `assets/` | Controls visual styling of the membership selector |

> Do not edit these files for routine badge changes. Only edit them if structural or visual changes are needed.

---

## How to Update Badges (Routine Task)

### Step 1: Identify the membership product to update

Each membership plan is a separate Shopify product:

| Plan | Product Admin URL |
|------|------------------|
| 30-Days (Monthly) | `https://admin.shopify.com/store/echelon-store/products/4129967505490` |
| 1-Year Access | `https://admin.shopify.com/store/echelon-store/products/4129967505490` |
| 2-Year Access | `https://admin.shopify.com/store/echelon-store/products/4815463809106` |

> Confirm the correct product IDs in Shopify admin if they differ from the above.

### Step 2: Navigate to the product metafields

1. Go to Shopify Admin → Products
2. Open the membership product you want to update
3. Scroll to the bottom of the product page to the Metafields section
4. Find the field labeled **"PDP badges individual product json"**

### Step 3: Edit the JSON value

The field contains a JSON object with the following structure:

```json
{
  "discount": "",
  "best_price": "",
  "bonus": "+ Free",
  "include_text": "Start or cancel anytime.",
  "show_price": "false"
}
```

| Field | Badge Type | Color | Example Value | Leave Blank to Hide |
|-------|-----------|-------|---------------|-------------------|
| `discount` | Left badge | Blue | `"Free Shipping"` | `""` |
| `best_price` | Right badge | Yellow | `"Most Popular"` | `""` |
| `bonus` | Internal use | n/a | `"+ Free"` | Do not change |
| `include_text` | Subtext below title | n/a | `"Start or cancel anytime."` | `""` |
| `show_price` | Internal use | n/a | `"false"` | Do not change |

### Step 4: Save

Click **Save** in the top right corner of the product page. Changes are live immediately — no theme publish required.

---

## Common Badge Configurations

### Current live configuration (as of August 2026)

| Plan | `discount` | `best_price` | Result |
|------|-----------|-------------|--------|
| 30-Days | `""` | `""` | No badges |
| 1-Year Access | `"Free Shipping"` | `"Most Popular"` | Blue + Yellow badges |
| 2-Year Access | `"Free Shipping"` | `""` | Blue badge only |

### Example: Add "Best Value" yellow badge to 2-Year Access

```json
{
  "discount": "Free Shipping",
  "best_price": "Best Value",
  "bonus": "+ Free",
  "include_text": "Start or cancel anytime.",
  "show_price": "false"
}
```

### Example: Remove all badges from 1-Year Access

```json
{
  "discount": "",
  "best_price": "",
  "bonus": "+ Free",
  "include_text": "Start or cancel anytime.",
  "show_price": "false"
}
```

---

## CSS Fix Reference (Already Applied)

The following CSS rule was added to `assets/pdp-2025.css` to hide the radio button inputs that were rendering as visible grey circles:

```css
.individual-product-container .individual-product-selector .individual-items-container input[type="radio"] {
  display: none;
}
```

> This rule must not be removed. The radio buttons remain functional for cart logic even when visually hidden.

---

## Troubleshooting

| Issue | Likely Cause | Fix |
|-------|-------------|-----|
| Badge not showing | Metafield field is empty or not saved | Check and re-save the metafield JSON |
| Badge showing on wrong plan | `badge_best_price` bleeding from previous product | Verify `individual-product-selection.liquid` has the `{% assign badge_best_price = blank %}` reset on line ~82 |
| Grey circle visible next to badge | `display: none` CSS rule missing or overridden | Re-check `pdp-2025.css` for the `.individual-radio { display: none; }` rule |
| Empty grey dot appearing | `best_price` field is `""` but still rendering | Verify `product-radio-option.liquid` line 60 reads `{%- if badge_best_price != blank and badge_best_price != "" -%}` |
| Syntax errors on save | Liquid capture tags using single quotes | Use `{%- capture variable_name -%}` without quotes around the variable name |

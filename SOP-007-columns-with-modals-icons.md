# SOP-007: Adding or Updating Optional Icons in the Columns with Modals Section
**Author:** Nicolas Cartin Reyes<br>
**Audience:** Internal Echelon developers, Shopify administrators and technical operators<br>

**Store:** echelonfit.com (Shopify)
**Applies to:** Any page using the `image-icon-text-modal.liquid` section (e.g., `/pages/membership`, product pages with the 3-column feature section)
**Last updated:** August 2026

---

## Overview

The "Columns with Modals" section (`sections/image-icon-text-modal.liquid`) supports an Optional Icon dropdown in the theme editor. Each icon option must be:

1. Defined as an option in the schema (bottom of the file, inside `{% schema %}`)
2. Handled as a `{% when %}` case in the Liquid template (around line 198-225)

If an icon option exists in the schema but has no matching `{% when %}` case in the template, the icon area will render as an empty div and nothing will appear on the page.

---

## Current Icon Options

| Schema Value | Label | Type | Source |
|-------------|-------|------|--------|
| `Builder` | Builder | `<img>` tag | CDN URL |
| `fitos` | FitOS | Inline SVG | Hardcoded SVG path |
| `worlds` | Worlds | Inline SVG | Hardcoded SVG path |

---

## How to Add a New Icon

### Step 1: Upload the icon image to Shopify

1. Go to **Shopify Admin → Content → Files**
2. Upload your icon file (PNG or SVG recommended, transparent background)
3. Copy the CDN URL of the uploaded file (e.g., `https://cdn.shopify.com/s/files/1/2422/9487/files/your-icon.png?v=...`)

> For best visual consistency, use a dark-colored logo on a transparent background, similar to the FitOS and Worlds SVG icons. The icon area has a fixed height of 100px via the `.membershipIcon` CSS class.

### Step 2: Add the option to the schema

In `sections/image-icon-text-modal.liquid`, scroll to the `{% schema %}` block at the bottom of the file. Find the `"id": "icon"` select field and add a new option:

```json
{
  "value": "YourIconValue",
  "label": "Your Icon Label",
  "group": "Icons"
}
```

> The `value` is case-sensitive and must exactly match what you use in Step 3.

### Step 3: Add the `{% when %}` case in the Liquid template

In the same file, find the `{% case block.settings.icon %}` block (around line 198). Add a new `{% when %}` case before `{% endcase %}`.

**For an image file (PNG/JPG):**

```liquid
{% when 'YourIconValue' %}
  <img src="https://cdn.shopify.com/s/files/1/2422/9487/files/your-icon.png?v=XXXX" width="200" height="100" alt="Your Icon Label" style="object-fit: contain; max-width: 200px;" class="membershipIcon" />
```

**For an inline SVG:**

```liquid
{% when 'YourIconValue' %}
  <svg aria-hidden="true" focusable="false" role="presentation" class="membershipIcon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 100">
    <!-- SVG path data here -->
  </svg>
```

### Step 4: Save and verify

1. Save the file in the Shopify code editor
2. Open the page in the theme editor or preview
3. Select the column block and choose your new icon from the Optional Icon dropdown
4. Verify the icon appears at the correct size

---

## How to Update an Existing Icon Image

If the icon image URL changes (e.g., a new logo was uploaded):

1. Upload the new image to **Shopify Admin → Content → Files** and copy the new CDN URL
2. In `sections/image-icon-text-modal.liquid`, find the `{% when 'YourIconValue' %}` case
3. Replace the `src="..."` URL with the new CDN URL
4. Save the file

**Current Builder icon URL (as of August 2026):**
```
https://cdn.shopify.com/s/files/1/2422/9487/files/workout-builder-ai-logo-dark_4.png
```

---

## File Reference

| File | Location | What to Edit |
|------|----------|-------------|
| `image-icon-text-modal.liquid` | `sections/` | Both the Liquid template (`{% when %}` cases) and the `{% schema %}` (dropdown options) |

> All icon changes are made in a single file. No metafield or CSS changes are needed for adding new icons.

---

## Troubleshooting

| Issue | Likely Cause | Fix |
|-------|-------------|-----|
| Icon area is empty (blank div) | `{% when %}` case is missing for that icon value | Add the `{% when %}` case in the Liquid template (Step 3) |
| Icon is very small | Image natural size is smaller than 100px height | Add `width`, `height`, and `style="object-fit: contain; max-width: 200px;"` attributes to the `<img>` tag |
| Icon does not appear after selecting it in the editor | Schema value and `{% when %}` value do not match (case-sensitive) | Ensure both use the exact same string, e.g., both `'Builder'` not one `'Builder'` and one `'builder'` |
| Syntax error on save | `<img>` tag split across multiple lines | Keep the entire `<img>` tag on a single line |
| Shopify warning about missing width/height | `<img>` tag missing `width` and `height` attributes | Add `width="200" height="100"` to the `<img>` tag |

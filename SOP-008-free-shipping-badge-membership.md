# SOP-008: Managing the "Free Shipping" Badge on Membership Product Cards
**Author:** Nicolas Cartin Reyes<br>
**Audience:** Internal Echelon developers, Shopify administrators and technical operators<br>

**Store:** echelonfit.com (Shopify)  
**Applies to:** Individual product pages with the membership selector (e.g., Stride 6S and any product using `snippets/product-radio-option.liquid`)  
**Last updated:** August 2026

## Overview
The membership selector on product pages supports a **"Free Shipping" badge** that can appear in two places:

| Location | How it's controlled | File |
|---|---|---|
| **Blue badge next to the title** (correct) | `badge_discount` metafield on the membership product | Metafield only — no code change needed |
| **Text overlay on the product card image** (removed) | Hardcoded block in `snippets/product-radio-option.liquid` | Code change required to add/remove |

> **Current state (August 2026):** The image overlay has been **removed**. Only the blue badge next to the title is active.

## How the Blue Badge Works (Title Area)
The blue "Free Shipping" badge that appears next to the membership title (alongside "Most Popular") is controlled entirely by the `badge_discount` field in the product metafield `pdp_badges_individual_product_json`.

### To show the badge on a membership plan:
1. Go to **Shopify Admin → Products** and open the membership product
2. Scroll to **Metafields** and find **"PDP badges individual product json"**
3. Set `"discount"` to `"Free Shipping"` (or any text you want in the badge):

```json
{"discount":"Free Shipping","best_price":"Most Popular","bonus":"+ Free","include_text":"..."}
```
4. Save — the badge appears immediately, no code change needed

### To hide the badge on a membership plan:
Set `"discount"` to an empty string `""`:

```json
{"discount":"","best_price":"","bonus":"+ Free","include_text":"Start or cancel..."}
```

## How the Image Overlay Works (and How to Re-enable It)
The image overlay was a dark banner at the bottom of the membership card image displaying the `badge_discount` text. It was **removed** because it duplicated the blue badge already shown next to the title.

### Current code in `snippets/product-radio-option.liquid` (overlay removed):
```liquid
{% unless outlet %}
  <div class="individual-image-container">
    <img
      src="{{ related_product.featured_image | img_url: '360x' }}"
      width="110"
      height="68"
      alt="{{ title }}"
      class="individual-image"
    >
  </div>
{% endunless %}
```

### To re-enable the image overlay (if needed in the future):
Replace the block above with:
```liquid
{% unless outlet %}
  <div class="individual-image-container" style="position:relative;">
    <img
      src="{{ related_product.featured_image | img_url: '360x' }}"
      width="110"
      height="68"
      alt="{{ title }}"
      class="individual-image"
    >
    {% if badge_discount %}
      <div style="position:absolute;bottom:0;left:0;right:0;background:rgba(0,0,0,0.8);color:#fff;text-align:center;padding:2px 0;font-size:10px;font-weight:bold;">
        {{ badge_discount }}
      </div>
    {% endif %}
  </div>
{% endunless %}
```
> **Note:** The overlay text is pulled from the same `badge_discount` metafield. If you re-enable the overlay, it will show on any membership product that has a non-empty `discount` value in its metafield.

## Current Badge Configuration (August 2026)

| Plan | Blue Badge (title area) | Image Overlay |
|---|---|---|
| 30-Days | None | Disabled |
| 1-Year Access | **Free Shipping** | Disabled |
| 2-Year Access | **Free Shipping** | Disabled |

## Troubleshooting

| Issue | Likely Cause | Fix |
|---|---|---|
| "Free Shipping" showing on image card | Image overlay block re-added to `product-radio-option.liquid` | Remove the `{% if badge_discount %}` block and `style="position:relative;"` from the image container |
| Blue badge not showing | `discount` field is empty or metafield not saved | Update the metafield JSON and save |
| Badge showing on wrong plan | `badge_best_price` bleeding from previous loop iteration | Verify `individual-product-selection.liquid` has `{% assign badge_best_price = blank %}` reset on each loop iteration |

## Files Reference

| File | Location | Purpose |
|---|---|---|
| `product-radio-option.liquid` | `snippets/` | Controls image overlay (removed) and blue badge rendering |
| `individual-product-selection.liquid` | `snippets/` | Reads metafields and passes `badge_discount` to `product-radio-option` |
| Product metafield | Shopify Admin → Products → Metafields | Controls what text appears in the blue badge |

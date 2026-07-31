# SOP-002: Bazaarvoice Coding Setup and Troubleshooting

**Store:** Echelon Fit Shopify Stores (US, UK, CA)  
**Category:** Theme Development & Integrations  
**Last updated:** July 2026

## 1. Purpose

Bazaarvoice is used to display product ratings and reviews on the Shopify storefront. Its main role is to strengthen customer trust, improve product credibility, and support conversion by surfacing social proof throughout the shopping experience.

This document covers two main areas:
1. Replacing previous Klaviyo star-rating widgets with Bazaarvoice inline rating markup.
2. Debugging and fixing star-click behavior in custom sections (e.g., Featured Products).

## 2. Replacing Klaviyo Rating Markup with Bazaarvoice

### Context
In the product grid card markup, the store previously used a Klaviyo star rating widget. This was replaced with Bazaarvoice inline rating markup so product cards could display Bazaarvoice-powered rating summaries.

**File Updated:** `snippets/product-grid-item.liquid`

### Code Changes

**Removed (Klaviyo):**
```html
<div class="klaviyo-star-rating-widget" data-id="{{product.id}}" data-product-title="{{product.title}}" data-product-type="{{product.type}}"></div>
```

**Added (Bazaarvoice):**
```html
<div data-bv-show="inline_rating" data-bv-product-id="{{ product.id }}" data-bv-redirect-url="{{ product.url }}" data-bv-seo="false"></div>
```

### Attribute Breakdown
- `data-bv-show="inline_rating"`: Tells Bazaarvoice to render the inline rating summary widget.
- `data-bv-product-id="{{ product.id }}"`: Passes the Shopify product ID used for the rating widget.
- `data-bv-redirect-url="{{ product.url }}"`: Provides the product URL used when users interact with the inline rating.
- `data-bv-seo="false"`: Disables SEO rendering behavior for this inline widget instance.

## 3. Custom Ratings in Featured Products (Troubleshooting)

### Issue Summary
A separate issue occurred in the Featured Products section (`sections/featured-products-grid.liquid`), where visible stars were not taking users to the correct product detail page when clicked. 

**Important Finding:** The stars in this section were **not** rendered using Bazaarvoice widget markup. They were rendered using custom Liquid, inline SVG stars, and manually output review count text.

### The Fix
Because the rating block was custom theme markup, it did not automatically inherit Bazaarvoice click behavior. The solution was to use JavaScript to trigger the existing, functional "Shop Now" CTA button within the same card.

**1. Cursor Styling Added:**
```css
#fp-grid-{{ section.id }} .fp-card__rating {
    margin: 8px 0 0;
    display: inline-flex;
    align-items: center;
    gap: 4px;
    cursor: pointer;
}
```

**2. JavaScript Intercept Added:**
```html
<script>
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('#fp-grid-{{ section.id }} .fp-card').forEach(function(card) {
        var rating = card.querySelector('.fp-card__rating');
        var cta = card.querySelector('.fp-card__cta');

        if (rating && cta) {
            rating.addEventListener('click', function(e) {
                e.preventDefault();
                cta.click();
            });
        }
    });
});
</script>
```

## 4. Troubleshooting Guidance

### If ratings are missing on product grid cards:
- Verify the Bazaarvoice inline rating markup is still present in `snippets/product-grid-item.liquid`.
- Verify Bazaarvoice scripts are loading on the page.
- Confirm `data-bv-product-id="{{ product.id }}"` is correctly mapped.

### If ratings appear but are not clickable in a custom section:
- Check if the stars are true Bazaarvoice widgets or custom Liquid markup.
- Inspect the rendered HTML in DevTools.
- If custom, ensure there is a working CTA that can be reused via JavaScript click interception.

> **Key Lesson:** Not every visible star-rating element on the site is a Bazaarvoice widget. Always inspect the markup first before treating a ratings issue as a Bazaarvoice issue.

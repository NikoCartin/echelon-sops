# SOP-020: Tub Template Chiller Add-ons

**Author:** Nícolas Cartín Reyes, Lead Developer

## Purpose

Maintain the reusable Shopify product template used by plunge-tub products when the page offers optional chiller add-ons. This procedure covers product-reference settings, add-on images, template preview, live pullback and the boundary between template configuration and product-specific JavaScript.

## Scope

This SOP applies to the `pdp2025-tubs-simple` product template and its configured chiller add-on slots. It covers add-on variant references, display labels, image picker and fallback URL behavior, preview validation and live smoke testing.

It does not create products, change inventory, change shipping rates or publish a product without separate approval.

## Prerequisites

1. Confirm the target Shopify store and live theme before editing.
2. Pull the current template into a complete Shopify theme workspace.
3. Identify chiller variants from current Shopify product data, not from a stale screenshot or copied URL.
4. Use an unpublished duplicate theme for validation.
5. Preserve a pullback copy of the live template before deployment.

## Configuration procedure

1. Open `templates/product.pdp2025-tubs-simple.json` in the isolated theme workspace.
2. Confirm that the individual product block enables the intended add-on slots.
3. Set each add-on variant ID from the current chiller product record.
4. Set the add-on title, badge, price display and short description from approved catalog data.
5. Set a valid product image reference or a valid CDN fallback URL for each slot. Do not assume that an old Shopify file URL still exists.
6. If the template has both an image picker and a fallback URL, verify which value Liquid actually renders. Clear an invalid picker value when the fallback must be authoritative.
7. Review any JavaScript condition that changes the add-on heading or behavior for a limited set of product IDs. A new tub product must be included through a controlled code change before it is assigned the template.
8. Keep the product's current template assignment unchanged until the preview passes.

## Validation

Use the unpublished preview and confirm:

- Both configured chiller cards render an image with no broken-image icon.
- The displayed title, variant and price match the selected chiller records.
- Selecting and clearing an add-on updates the cart payload without changing the base tub variant.
- The add-on cards remain usable on narrow screens.
- The product heading and optional modules are correct for the product being previewed.
- No Liquid errors appear in the storefront response or browser console.
- The template does not introduce unrelated product, cart or checkout changes.

After deployment, pull the live template back and compare the approved file. Repeat the public smoke test on the base tub and one product using the same template.

## Troubleshooting

| Symptom | Likely cause | Action |
|---|---|---|
| Broken add-on image | Deleted or stale Shopify file URL | Replace it with current product media and verify the HTTP response |
| Correct image in QA but not live | Wrong theme or incomplete push | Confirm the theme ID, push only the approved file and pull back the result |
| Heading does not match the new tub | Product-specific condition excludes the new product | Extend the condition in a separate reviewed code change |
| Add-on does not reach cart | Invalid variant ID or disabled slot | Re-read the variant record and inspect the rendered data attributes |
| Product page renders the old layout | Product still uses its previous template | Assign the template only after preview and product-level approval are complete |

## Rollback

Restore the previous `templates/product.pdp2025-tubs-simple.json` from the live pullback and push only that file to the same theme. If a product-specific JavaScript condition was changed, revert that scoped file separately. Do not replace the full theme or delete product media as a rollback shortcut.

## Change record

Record the product template, add-on variant IDs, image sources, preview URL, live theme, pullback result and public smoke-test outcome in the release notes.

# Standard Operating Procedure: UK Product2026 Responsive Product Template

**Document owner:** UK Ecommerce Development
**Author:** Nícolas Cartín Reyes, Lead Developer
**Audience:** Echelon developers, Shopify administrators and technical operators
**Version:** 1.0
**Status:** Final and validated for the UK live theme
**Template:** `product.Dynamic2026-UK.liquid`
**Wrapper:** `product.product2024-uk.liquid`

## 1. Purpose

This SOP explains how to maintain and release the responsive UK product template used by products that are explicitly assigned to the Product2026 presentation. The implementation keeps product identity, prices, compare-at values, media, variants and membership references in Shopify product data while providing a shared responsive presentation layer.

The release adds four shared behaviors:

1. A responsive sale-price row with a visible savings badge when the selected variant has a compare-at price.
2. Centered current-price presentation when no compare-at price exists, while keeping financing in its own column.
3. A conditional free-shipping message when eligible one-year or two-year membership references are available.
4. A native image lightbox opened through the product-gallery magnifying-glass control.

## 2. Scope and exclusions

This SOP applies only to products assigned to `product.Dynamic2026-UK` or to the existing Product2024 wrapper that has been intentionally updated to load the Product2026 assets.

It does not assign products to a template, change product data, change pricing, change inventory, alter membership products or modify checkout behavior. SKU-specific templates, including other legacy product templates, remain outside this release. Do not edit an unrelated product template to make it look like Product2026.

The free-shipping message is presentation-only. Actual shipping eligibility remains controlled by the approved storefront and shipping configuration. The monthly membership remains separate from the one-year and two-year free-delivery presentation.

## 3. Versioned files

The controlled release uses these files:

| Path | Responsibility |
|---|---|
| `assets/uk-product2026.css` | Responsive price layout, sale badge, membership presentation, delivery strip and lightbox styling. |
| `assets/uk-product2026-zoom.js` | Accessible image lightbox, image navigation, keyboard controls and close behavior. |
| `snippets/uk-product2024-membership-selection.liquid` | Membership option presentation, including the monthly trial copy. |
| `snippets/uk-product2024-template-individual.liquid` | Product gallery, price state, membership references and conditional delivery strip. |
| `templates/product.Dynamic2026-UK.liquid` | Product2026 asset loading and shared section order. |
| `templates/product.product2024-uk.liquid` | Existing wrapper updated to load the Product2026 CSS and zoom script. |

Preserve the older Product2024 stylesheet when other theme paths still depend on it. Do not delete shared theme assets as part of this procedure.

## 4. Rendering rules

### 4.1 Sale and regular prices

The price wrapper exposes `data-on-sale="true"` only when the selected variant has a compare-at price greater than its current price. The sale state displays the `Was` price, the current `Now Only` price and the savings badge.

When `data-on-sale="false"`, the compare-at row is hidden and the current price is centered across the price area. The financing widget remains separated by the existing divider and keeps its own alignment.

Variant changes must update the current price, compare-at price, savings amount, sale state and financing amount together. Do not hardcode a product price or savings amount in the template.

### 4.2 Membership and delivery message

Membership options are read from the product's configured membership references. The delivery strip appears only when the product has at least one eligible one-year or two-year membership reference and a non-empty delivery message, including the shared fallback message when appropriate. The monthly option does not qualify the product for the delivery strip.

The monthly card may display the approved introductory trial copy. This does not change the membership product price or recurring-billing configuration.

### 4.3 Image zoom

The gallery renders the existing accessible zoom button. `uk-product2026-zoom.js` listens to the scoped product-gallery button, collects the current product media, opens a modal with the selected image, and provides previous, next and close controls. Escape, left-arrow and right-arrow keyboard controls must remain available.

The zoom script must remain scoped to the Product2024 shell so it does not replace unrelated gallery behavior elsewhere in the theme.

## 5. Development and deployment procedure

1. Confirm the target store and the current published theme before editing.
2. Pull the current live versions of every file in the release list. Keep the pullback as the rollback source.
3. Apply the smallest change in an unpublished duplicate or development theme.
4. Validate the Liquid references, JavaScript syntax and CSS formatting. Run `node --check` for the Product2026 zoom script and the shared Product2024 JavaScript.
5. Test at least one product with a compare-at price and one product without a compare-at price.
6. Test one product with one-year or two-year membership references and confirm the delivery strip. Confirm the monthly membership still renders its approved trial copy without qualifying for free delivery.
7. Test the magnifying-glass control, image loading, previous and next controls, Escape and responsive layout.
8. Push only the intended files with `--nodelete`. Never full-push the theme for this change.
9. Pull the same files from the live theme and compare them byte for byte with the approved source.
10. Run a cache-busted public storefront smoke test on representative products. Confirm there are no Liquid errors, broken gallery images or missing membership cards.

## 6. Validation checklist

A release is complete only when all of these conditions pass:

- A discounted product shows `Was`, `Now Only` and its savings badge on desktop and mobile.
- A product without a compare-at price shows a centered current price and keeps financing separated.
- The one-year and two-year membership choices display their configured delivery benefit.
- The monthly membership displays the approved trial copy and does not trigger the delivery strip.
- The delivery strip appears only when eligible membership references are available.
- The magnifying-glass control is visible, keyboard reachable and opens the selected product image.
- Previous, next, Escape and close controls work in the lightbox.
- Product media, title, native price and membership references remain product-driven.
- At least two products render correctly without SKU-specific hardcoding.
- The live pullback matches every pushed file.

## 7. Troubleshooting

| Symptom | Likely cause | Corrective action |
|---|---|---|
| Sale badge is missing | The product is using another template, the Product2026 stylesheet is not loaded, or the selected variant has no valid compare-at price. | Confirm the product assignment, inspect the loaded stylesheet and verify the selected variant values. |
| A regular price is left-aligned | The Product2026 responsive rules are missing or the product is using a legacy template. | Confirm the wrapper loads `uk-product2026.css` and that the no-sale rule is present. |
| Delivery strip is missing | No eligible one-year or two-year membership reference is available, or the message is blank. | Check the product's configured references and the conditional Liquid branch. Do not add a product-specific hardcoded message. |
| Monthly membership shows free delivery | The eligibility condition is too broad or the membership source text is misclassified. | Restore the annual and two-year-only eligibility checks and retest all membership options. |
| Lupa is visible but does not open | The zoom script is missing, the gallery selector changed, or the script loaded before the product shell. | Confirm the script tag, the `.product__photo-zoom` control and the product-gallery shell selector. Run the browser console smoke test. |
| Lightbox opens without an image | Gallery slides do not expose a usable high-resolution image source. | Inspect the product media markup and preserve the existing `data-photoswipe-src` or current image source. |
| Unrelated product pages change | A global selector or unrelated template was edited. | Stop the release, compare the diff and restore the unrelated file from the live pullback. |

## 8. Rollback

If the release causes a rendering, gallery or membership regression, restore only the affected files from the dated live pullback or the last approved Git commit. Push the reverted files with `--nodelete`, pull them back again, and repeat the representative product smoke test.

Do not delete Product2026 files, reassign products automatically or replace the entire theme during rollback. If a product must temporarily return to its previous presentation, change its template assignment deliberately in Shopify Admin after the code rollback is verified.

## 9. Change-control boundary

Product assignment remains an explicit Shopify Admin decision. This procedure updates the shared Product2026 implementation for products that already use the template. It does not migrate legacy product templates, change product pricing or implement recurring membership billing.

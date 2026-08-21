# Additive UK Dynamic Product Template

## Purpose

This package adds one optional UK bike Shopify product template named `product.dynamic-bike`. It follows the approved shared bike product-page structure, but it does not replace or modify any existing product template. Existing products continue using their current templates unless `product.dynamic-bike` is assigned explicitly. The older `product.dynamic` file remains as a compatibility alias until existing assignments are migrated.

The template reads each product's native Shopify data first. The core PDP values remain product-driven. Product Specifications are extracted from the current product's native description by locating the `Key Features:` heading and parsing the following HTML list. A UK `custom.template_profile` specification list, `custom.product_specifications` list or `custom.pdp_product_specs` list is used only when the description does not contain a Key Features list.

Recurring billing and Shopify selling plans are intentionally outside this implementation. The membership selector uses the existing UK membership products for presentation and variant selection only. Billing can be connected later without rebuilding the template.

## Files to install

Upload the following files to the existing UK theme:

| File | Folder | Action |
|---|---|---|
| `product.dynamic-bike.liquid` | `templates` | Add this new bike template. Do not replace `product.liquid` or any existing SKU template. |
| `dynamic-product-description.liquid` | `sections` | Add the dynamic product and membership section. |
| `dynamic-membership-upgrade.liquid` | `sections` | Add the membership upgrade section. |
| `dynamic-product-specifications.liquid` | `sections` | Add the specifications section. |
| `dynamic-experience.liquid` | `sections` | Add the experience section. |
| `dynamic-product-experience.liquid` | `sections` | Add the product experience CTA. |
| `dynamic-feature-slider.liquid` | `sections` | Add the feature slider. |
| `dynamic-full-width-video.liquid` | `sections` | Add the full-width video section. |
| `dynamic-memberships.liquid` | `sections` | Add the membership content section. |
| `dynamic-derisk-section.liquid` | `sections` | Add the reassurance section. |
| `dynamic-financing-cta.liquid` | `sections` | Add the finance CTA. |
| `dynamic-more-than-membership.liquid` | `sections` | Add the membership benefits section. |
| `dynamic-featured-collection.liquid` | `sections` | Add the related collection section. |
| `dynamic-community.liquid` | `sections` | Add the community section. |
| `dynamic-safety.liquid` | `sections` | Add the safety section. |
| `dynamic-cart-helper.liquid` | `snippets` | Add the dynamic cart helper used by the membership selector. |
| `dynamic-product-description-v3.liquid` | `snippets` | Add the preserved reference-style product and membership markup. |
| `dynamic-membership-plans.liquid` | `snippets` | Add the membership comparison popup. |
| `dynamic-upgrade-stripped.liquid` | `snippets` | Add the membership upgrade popup. |
| `dynamic-bike-experience.liquid` | `snippets` | Add the fixed EX-7s bike Experience slides and UK assets. |
| `dynamic-bike-feature-slider.liquid` | `snippets` | Add the fixed EX-7s bike feature slider and UK assets. |
| `dynamic-bike-featured-collection.liquid` | `snippets` | Add the fixed bike collection renderer using `cart-accessories`. |
| `dynamic-bike-community.liquid` | `snippets` | Add the fixed seven-image UK bike community wall. |
| `cargo-cta-section.liquid` | `snippets` | Preserve the shared CTA renderer and support the fixed bike image URL. |
| `cargo-financing-output.liquid` | `snippets` | Preserve the shared financing renderer and support the fixed bike image URL. |
| `cargo-full-width-banner-output.liquid` | `snippets` | Preserve the shared full-width renderer and support the fixed bike image URL. |
| `cargo-safety-output.liquid` | `snippets` | Preserve the shared safety renderer and support the fixed bike image URL. |

The bike template keeps the EX-7s bike presentation fixed where it is shared across the bike collection. This includes the Experience slides, Product Experience CTA, Feature Slider, Full-Width Video, Memberships, Financing CTA, Featured Collection, Community image wall and Safety asset. The PDP description, title, price, gallery, variants and Product Specifications remain product-driven. The template keeps the Klaviyo review anchor keyed to `{{ product.id }}`, so the review provider supplies real reviews for the current product. Do not delete the shared snippets.

## Product data behavior

The following values come directly from the current product: title, featured image, product gallery, selected variant, native price, compare-at price, product URL and product description. No Stride, Summit or other SKU handle is used by the template.

For membership cards, assign a list product-reference metafield named `custom.membership_products` in this order: Monthly, 1-Year and 2-Year. The template reads the referenced products' titles, featured images, prices and first available variants. If this metafield is not present, the existing UK membership fallback is used. Free delivery is enforced only for the 1-Year and 2-Year plans.

## Product Specifications from the PDP description

The description should contain a heading named `Key Features:` followed by a standard HTML unordered list. Each list item should contain the feature label in bold, followed by a hyphen or en dash and the supporting value. For example: `<li><strong>Power Ports</strong> - Keep devices charged and ready to go</li>`. The bike template preserves the EX-7s two-column specifications layout and converts each list item into one specification row. The parser preserves the bold label and the text after the separator. If no Key Features list exists, the template falls back to the UK product profile or specification metafield list.

## UK membership products

The existing active UK membership products are:

| Plan | Product handle | Price |
|---|---|---:|
| Monthly | `uk-premier-monthly` | £29.99 |
| 1-Year | `uk-premier-yearly` | £299.90 |
| 2-Year | `uk-premier-2-year` | £479.76 |

These are existing products. The package does not create duplicates, delete products or change subscription billing.

## Assignment

After the files are uploaded, open a UK bike product in Shopify Admin and select `product.dynamic-bike` under the Theme template field. Save the product and preview it. Existing product assignments remain unchanged.

## Validation

Test the bike template on at least two different UK bike products. Confirm that the title, images, price and description change with the product. Confirm that the Product Specifications section matches the Key Features list in each product description, the Klaviyo review widget is keyed to the current product, the membership cards read the existing UK membership products, and the fixed bike sections show their shared EX-7s assets rather than placeholders.

This package has been statically checked for Liquid block balance, section and snippet references, schema JSON validity and SKU-specific identifiers. Billing and selling-plan integration remain intentionally pending.

## References

[1]: https://help.shopify.com/en/manual/online-store/themes/theme-structure/templates "Shopify Help Center: Templates"

[2]: https://help.shopify.com/en/manual/custom-data/metafields "Shopify Help Center: Metafields"

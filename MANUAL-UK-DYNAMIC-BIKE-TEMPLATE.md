# Manual Installation Guide: UK Dynamic Bike Product Template

## What this package does

This package creates one additive UK bike product template named `product.dynamic-bike`. It preserves the shared bike product-page structure and defaults while reading the core PDP data from the product assigned to it. It is not a SKU-specific template. The older `product.dynamic` file remains as a compatibility alias until existing assignments are migrated.

The template includes these neutral sections in one fixed sequence:

```text
Dynamic Product Description
Dynamic Membership Upgrade
Dynamic Product Specifications
Dynamic Experience
Dynamic Product Experience
Dynamic Feature Slider
Dynamic Full Width Video
Dynamic Memberships
Dynamic Derisk Section
Dynamic Financing CTA
Dynamic More Than Membership
Dynamic Featured Collection
Dynamic Community
Dynamic Safety
Dynamic Membership Plans popup
```

Nav Bar, Mega Menu 2, Cart Drawer and Footer are global theme elements and are not part of the product template upload.

## Files to upload

| Folder | File |
|---|---|
| `sections` | `dynamic-product-description.liquid` |
| `sections` | `dynamic-membership-upgrade.liquid` |
| `sections` | `dynamic-product-specifications.liquid` |
| `sections` | `dynamic-experience.liquid` |
| `sections` | `dynamic-product-experience.liquid` |
| `sections` | `dynamic-feature-slider.liquid` |
| `sections` | `dynamic-full-width-video.liquid` |
| `sections` | `dynamic-memberships.liquid` |
| `sections` | `dynamic-derisk-section.liquid` |
| `sections` | `dynamic-financing-cta.liquid` |
| `sections` | `dynamic-more-than-membership.liquid` |
| `sections` | `dynamic-featured-collection.liquid` |
| `sections` | `dynamic-community.liquid` |
| `sections` | `dynamic-safety.liquid` |
| `snippets` | `dynamic-product-description-v3.liquid` |
| `snippets` | `dynamic-upgrade-stripped.liquid` |
| `snippets` | `dynamic-membership-plans.liquid` |
| `snippets` | `dynamic-cart-helper.liquid` |
| `snippets` | `dynamic-bike-experience.liquid` |
| `snippets` | `dynamic-bike-feature-slider.liquid` |
| `snippets` | `dynamic-bike-featured-collection.liquid` |
| `snippets` | `dynamic-bike-community.liquid` |
| `snippets` | `cargo-cta-section.liquid` |
| `snippets` | `cargo-financing-output.liquid` |
| `snippets` | `cargo-full-width-banner-output.liquid` |
| `snippets` | `cargo-safety-output.liquid` |
| `templates` | `product.dynamic-bike.liquid` |

The public template name is `product.dynamic-bike`. Do not add `product.dynamic.json` or `product.dynamic-bike.json`.

## Installation

In Shopify Admin, open **Online Store > Themes > Edit code** for the target theme. Add every file in the table above, keeping each file in the listed folder. Save the sections and snippets first, then save `templates/product.dynamic-bike.liquid`.

Open a UK bike product and select `product.dynamic-bike` under **Theme template**. Save the product and preview it in the Theme Editor. Do not replace `templates/product.liquid`; this package is strictly additive.

## Product data

Native Shopify product data supplies the bike product title, URL, images, gallery, description, selected variant and price. Product metafields supply only bike PDP values that differ by product. Shipping details, financing values, related products, warranty defaults and promotion presentation remain shared bike-template defaults unless explicitly overridden. The most important optional keys are:

```text
custom.product_description_override
custom.membership_products
custom.header_price
custom.banner_heading
custom.banner_price
custom.monthly_price
custom.klarna_price
custom.shipping_status
custom.shipping_date
custom.membership_program
custom.membership_monthly_variant_id
custom.membership_annual_variant_id
custom.membership_two_year_variant_id
custom.warranty_variant_id
custom.monthly_extra_variant_ids
custom.annual_extra_variant_ids
custom.two_year_extra_variant_ids
custom.free_postage_variant_id
custom.heart_rate_monitor_variant_id
custom.gift_voucher_variant_id
```

The fixed bike sections use the shared EX-7s presentation and UK assets. The product title, URL, images, gallery, description, selected variant, price and Product Specifications remain product-driven. The Product Specifications section reads the native product description: add a `Key Features:` heading followed by an HTML unordered list, with each item formatted as a bold label, then a hyphen or en dash, then its value. For example: `<li><strong>Power Ports</strong> - Keep devices charged and ready to go</li>`. If no Key Features list exists, the section falls back to `custom.template_profile.specifications`, `custom.product_specifications` or `custom.pdp_product_specs`. The review anchor remains keyed to the current `product.id` so the existing Klaviyo integration supplies real reviews for that bike. The fixed Featured Collection uses the real `cart-accessories` collection and does not use placeholder onboarding tiles.

Use Shopify variant IDs, not product IDs. Extra-item fields accept comma-separated variant IDs.

## Membership cards and delivery

The membership-card layout preserves the reference card format, images, radio controls, savings badges, pricing hierarchy, benefits and purchase CTA. The card data is supplied by the existing UK membership products and the product’s `custom.membership_products` references. The shared bike sections, financing, featured collection, community wall and video assets are fixed for the bike collection.

| Plan | Free-delivery badge | Free-delivery banner |
|---|---|---|
| Monthly | Hidden | Hidden |
| 1-Year | Visible | Visible |
| 2-Year | Visible | Visible |

The cart helper removes an existing membership variant before adding the selected equipment variant, membership variant, optional warranty variant and configured extras.

## Testing

Use the same `product.dynamic-bike` template on two different UK bike products. Verify that title, images, price, description and Key Features-derived specifications change from each product’s PDP data without creating another template. Verify that the Klaviyo review widget is keyed to the current product, while the EX-7s Experience, Product Experience, Feature Slider, Full-Width Video, Featured Collection and Community images remain the shared bike defaults. Shipping, financing, related products, warranty and promotion presentation should remain the shared bike defaults.

Test desktop and mobile rendering, all product variants, the comparison popup, the payment row and cart behavior. Confirm that monthly does not show free delivery, while the 1-year and 2-year plans do.

## Using it for new SKUs

For each new UK bike product, select `product.dynamic-bike` under **Theme template** and complete the product's native content and optional PDP metafields. Existing products assigned to other templates remain unchanged. This package does not modify `templates/product.liquid`.

## Rollback

If Shopify reports a syntax or schema error, restore the previous version of the affected file. Do not delete the original SKU templates until the new default has been tested on representative products.

## References

[1]: https://help.shopify.com/en/manual/online-store/themes/customizing-themes/edit-code/edit-theme-code "Shopify Help Center: Editing theme code"

[2]: https://help.shopify.com/en/manual/online-store/themes/theme-structure/templates "Shopify Help Center: Templates"

[3]: https://help.shopify.com/en/manual/custom-data/metafields "Shopify Help Center: Metafields"

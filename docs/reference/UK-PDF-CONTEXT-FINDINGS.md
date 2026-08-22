# UK PDF context findings

Source file: `/home/ubuntu/upload/Correct_Solution_One_100%_Dynamic_Product_Template.pdf`
Title: Correct Solution: One 100% Dynamic Product Template
Pages: 9

## Executive architecture

The current Stride 8S product page is a wrapper template that assembles multiple sections. The main product-description section delegates most markup to a large snippet. The existing implementation became SKU-specific because wrapper, sections, and snippets contain product handles, product IDs, membership IDs, prices, images, promotions, and product copy.

The recommended solution is one neutral public template called `product.dynamic`, with `templates/product.liquid` optionally pointing to the same entry point for products that use Shopify's default product template. The wrapper must contain only neutral section references and universal layout logic. It must not contain a Stride name, SKU handle, product ID, membership variant ID, CDN product image, product price, promotion branch, or product-specific URL.

## Existing public product-page sequence

The live wrapper sequence is: Product description, Membership upgrade, Product specifications, Reviews, Experience, Product experience CTA, Feature slider, Full-width video, Memberships, Derisk section, Financing CTA, More than a membership, Featured collection, Community, Safety, Upgrade snippet, and Membership comparison popup. Navigation, mega menu, cart drawer, and footer remain global theme components outside the product template.

## Presentation layer to preserve

Preserve desktop/mobile gallery markup, thumbnails, zoom, sizing, classes, heading and price hierarchy, membership card geometry, radio controls, savings/free-delivery badge placement, benefit area, CTA styling, payment row, comparison modal frame/table/controls, lower-page section order, reusable CSS classes and snippets that are visual-only, and native Shopify product values.

## Hard-coded dependencies to remove

Replace hard-coded warranty variant IDs with a product profile warranty variant reference. Replace hard-coded selected variant IDs with `product.selected_or_first_available_variant.id`. Remove product ID branches, handle comparisons, Stride-specific filenames, hard-coded membership card image URLs, membership prices/savings/benefits, promotion assets and gift IDs, product-specific sold-out copy and URLs, fixed comparison rows, and fixed shipping exception IDs. Commenting out a hard-coded block is not sufficient; it must be removed or rewritten so it cannot reactivate accidentally.

## Recommended data model

Create a `product_template_profile` metaobject and attach one reference to each product through a product metafield such as `custom.template_profile`.

Product profile fields:
- `subtitle`: single-line text
- `shipping_status`: text or enum such as `ships_now`, `delayed`, `preorder`
- `shipping_date`: single-line text
- `price_label`: single-line text
- `sale_price`: money
- `monthly_finance_price`: money
- `finance_label`: single-line text
- `hero_banner_image`: file reference
- `hero_video`: URL or file reference
- `hero_copy`: rich text
- `specifications`: list of specification metaobjects
- `experience_sections`: list of content-section metaobjects
- `comparison_rows`: list of comparison-row metaobjects
- `related_collection`: collection reference
- `safety_content`: rich text or content reference
- `membership_offers`: list of membership-offer metaobjects
- `membership_enabled`: boolean
- `warranty_variant`: product variant reference
- `promotion_items`: list of product-variant references

Membership-offer metaobject fields:
- `plan_key`: monthly, annual, twoyear
- `program`: premier or choice
- `variant`: product variant reference
- `image`: file reference
- `title`: single-line text
- `price_text`: text or money
- `savings_text`: single-line text
- `detail_text`: single-line text
- `benefits`: list of single-line text
- `free_delivery`: boolean
- `extra_variants`: list of product variant references
- `default_selected`: boolean

The business rule should be enforced in both data and template: only annual and two-year offers may show free delivery. A misconfigured monthly offer should not display the free-delivery badge.

Repeating data should use specification rows and product content-section records. A specification row should contain `label`, `value`, `column`, and `sort_order`. A product content section should contain `type`, `eyebrow`, `heading`, `copy`, `image`, `video`, `button_label`, `button_link`, and `sort_order`.

## Neutral wrapper example

```liquid
{% assign profile = product.metafields.custom.template_profile.value %}
{% section 'product-header' %}
{% section 'product-banner' %}
{% section 'product-description' %}
{% section 'membership-upgrade' %}
{% section 'product-specifications' %}
{% section 'product-experience' %}
{% section 'feature-slider' %}
{% section 'full-width-video' %}
{% section 'memberships' %}
{% section 'derisk-section' %}
{% section 'financing-cta' %}
{% section 'more-than-membership' %}
{% section 'featured-collection' %}
{% section 'community' %}
{% section 'safety' %}
{% render 'membership-plans', profile: profile %}
{% render 'dynamic-cart-helper', product: product, profile: profile %}
```

If a product has no profile/content record, a section should use native product data or render nothing. It must not show another SKU's content.

## Cart architecture

The cart helper should receive the current product variant, the selected membership offer from the profile, optional warranty variant, and selected extra variants. It should add them through one `/cart/add.js` request. No numeric product or membership variant IDs should be present in Liquid, JavaScript, or section settings.

## Implementation decisions

Recommended default: keep `product.dynamic` as the public template name; point `templates/product.liquid` to the neutral wrapper for automatic use on new SKUs; use one `custom.template_profile` reference per product; use membership-offer metaobjects with product variant references; create separate product profiles for distinct equipment families or promotions; migrate old SKU-specific templates after the neutral structure is validated; keep visual CSS and approved layout markup where possible.

## Relation to the US model

The US investigation found a live product-level list reference `custom.pdp_individual_product` of type `list.product_reference`, with the three standard Premier products Monthly, Yearly, and 2-Year on multiple equipment PDPs. The UK PDF recommends a more extensible profile/metaobject data layer that can hold membership offers together with specifications, content, warranty, promotions, and related collections. The UK implementation should therefore preserve the proven dynamic reference pattern while moving from a narrow membership-only list to the broader `custom.template_profile` and `membership_offers` model described in the PDF.

## Final implementation decisions from PDF pages 8-9

- Keep the public template name `product.dynamic`.
- Point `templates/product.liquid` to the neutral wrapper for automatic use on new SKUs.
- Use one `custom.template_profile` metaobject reference per product.
- Use `membership_offer` metaobjects with product variant references.
- Enforce free delivery only for annual and two-year offers.
- If content data is missing, hide the section or use a neutral universal fallback; never show another SKU's content.
- Validate at least two different products with the same template and compare cart line items.
- Next implementation step: create metaobject definitions and neutral section wrappers, then migrate the approved reference markup one section at a time. Push to the theme only after the schema and two-product test pass.

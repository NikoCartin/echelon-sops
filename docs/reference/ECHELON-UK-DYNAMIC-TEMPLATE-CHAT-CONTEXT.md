# Echelon UK Dynamic Product Template
# Master Context and Replication Instructions

**Purpose:** Give the UK implementation chat enough verified context to reproduce the dynamic product and membership experience from echelonfit.com without copying SKU-specific logic.

**Source store:** Echelon Fit US, `echelonfit.com`
**Target store:** Echelon Fit UK, `echelonfit.uk`
**Document status:** Read-only investigation and implementation guidance. No Shopify store was modified while preparing this document.

---

## Instruction to the UK implementation chat

Treat this document as the working source of truth for the US behavior and the UK target architecture. Do not copy the current Stride-specific template and replace a few values. Build one neutral, reusable product template and move product-specific values into Shopify product data, product profiles, membership-offer records, and related content records.

Use the current US Liquid files as the behavioral reference for the membership selector. Use the UK PDF context as the architectural authority for the final UK implementation. Keep the visual presentation, card geometry, radio controls, comparison modal, and approved CSS where they are reusable. Remove hard-coded product IDs, variant IDs, URLs, prices, images, promotion branches, and SKU-specific template names from the final UK implementation.

Do not publish changes until at least two different UK products use the same template and pass the cart and visual acceptance tests in this document. If a product has no profile or content data, render native product data or render nothing. Never display content belonging to another SKU.

---

## 1. Executive summary

The US membership experience is dynamic at the Product metafield and Liquid-snippet level. An equipment PDP stores an ordered list of Product references in `custom.pdp_individual_product`. The shared Liquid code resolves those references, reads each membership Product's title, image, price, tags, variant, and merchandising metafields, and renders a radio-card selector.

The confirmed US relationship is:

```text
Equipment PDP
  -> product.metafields.custom.pdp_individual_product.value
  -> referenced membership Products in list order
  -> related_product.metafields.custom.pdp_badges_individual_product_json.value
  -> individual-product-selection
  -> product-radio-option
  -> radio data attributes
  -> surrounding theme JavaScript
  -> cart request
```

The US implementation is a proven reference for how membership cards behave, but it is not the final UK architecture. The UK context document calls for a neutral `product.dynamic` template backed by a `product_template_profile` metaobject and `membership_offer` records.

The recommended UK relationship is:

```text
Current UK product
  -> product.metafields.custom.template_profile.value
  -> product_template_profile.membership_offers
  -> membership_offer.variant
  -> reusable membership card
  -> dynamic cart helper
```

The UK target must be broader than the current US membership-only field. The profile should also control product specifications, product experience content, media, financing, shipping status, warranty, promotions, comparison rows, related collections, community, safety, and other product-specific sections.

---

## 2. Verified US membership products

The following products were inspected in the US Shopify Admin. All are Shopify products with `productType: Subscription`.

| Role | Product | Product ID | Handle | Variant ID | Observed price | Relevant tags or notes |
|---|---|---:|---|---:|---:|---|
| Standard monthly Premier used by sampled equipment PDPs | Echelon Premier Monthly | `7696193355975` | `echelon-monthly-premier` | `43246953267399` | `$39.99` | `PremierSub`, `Monthly`, `1monthSub`, `bundleDiscount` |
| Standard yearly Premier | Echelon Premier Yearly Plan | `4129967505490` | `reflect-1-year-plan` | `30135749771346` | `$399.99` | `premier`, `PremierSub`, `Subscription`, `Yearly`, `year` |
| Standard two-year Premier | Echelon Premier 2-Year Plan | `4815463809106` | `copy-of-echelon-united-2-year-plan` | `32930539503698` | `$699.99` | `premier`, `PremierSub`, `Subscription`, `TwoYear`, `year` |
| Promotional or free membership product supplied by the user | Echelon Premier Monthly With 30 Days Free | `8081808261319` | `echelon-premier-monthly-with-30-days-free` | `44236514427079` | `$0.00` | `PremierSub`, `1monthSub`, `3monthSub`; description says `$39.99 value` |

### Important discrepancy to preserve

The user identified Products `4129967505490`, `8081808261319`, and `4815463809106` as the products of interest. However, the sampled standard equipment PDPs currently reference Product `7696193355975` for the standard monthly plan, not Product `8081808261319`.

The confirmed standard Stride 6S reference list is:

```json
[
  "gid://shopify/Product/7696193355975",
  "gid://shopify/Product/4129967505490",
  "gid://shopify/Product/4815463809106"
]
```

Do not replace the standard monthly reference with Product `8081808261319` until the target business rule is confirmed. Product `8081808261319` is a `$0.00` promotional product with different tags and should be treated as a special-offer source unless a specific PDP is verified to reference it.

The standard US membership page exposes direct cart-add links for the standard monthly and yearly offers and separately exposes FitPass. Membership product presentation data is stored on the membership Product and is not the same as the underlying subscription entitlement or renewal configuration. [1] [2] [3] [4]

---

## 3. US PDP metafield definition

The confirmed Product metafield definition is:

| Setting | Value |
|---|---|
| Display name | `PDP individual product` |
| Namespace and key | `custom.pdp_individual_product` |
| Type | `list.product_reference` |
| Definition ID | `gid://shopify/MetafieldDefinition/56523587783` |
| Description | `Choose a fit pass for your product` |

The PDP stores Product references, not copied titles, prices, images, or variant IDs. Shopify resolves the references into Product objects at render time.

### Confirmed PDP examples

The same three standard Product references, in Monthly, Yearly, and 2-Year order, were confirmed on these active equipment products:

| PDP | Product ID | Handle | Membership reference result |
|---|---:|---|---|
| Stride-6 | `7828411777223` | `stride-6` | Monthly, Yearly, 2-Year |
| Echelon Stride 6S | `7828423442631` | `stride-6s` | Monthly, Yearly, 2-Year |
| Echelon Stride-8s | `7828425474247` | `stride-8s` | Monthly, Yearly, 2-Year |
| EX-5s Connect Bike | `7712959922375` | product title supplied by Shopify | Monthly, Yearly, 2-Year |
| EX-8s Smart Connect Bike | `7712960020679` | product title supplied by Shopify | Monthly, Yearly, 2-Year |

Other active treadmill records, including partner and runDISNEY products in the sampled query, returned a null value for this metafield. Therefore the relationship is explicitly assigned per PDP and is not automatically inherited by every equipment product.

### Exact Stride 6S value

Admin product: [Stride 6S Shopify Admin page][7]
Public PDP: [Stride 6S public PDP][6]

```json
{
  "namespace": "custom",
  "key": "pdp_individual_product",
  "type": "list.product_reference",
  "value": [
    "gid://shopify/Product/7696193355975",
    "gid://shopify/Product/4129967505490",
    "gid://shopify/Product/4815463809106"
  ]
}
```

List position controls display order:

| Position | Product | PDP behavior |
|---:|---|---|
| 0 | Echelon Premier Monthly | First membership option and normal default |
| 1 | Echelon Premier Yearly Plan | Second membership option |
| 2 | Echelon Premier 2-Year Plan | Third membership option |

---

## 4. Confirmed US template chain

The supplied US product section renders the reusable `product-template-individual` snippet:

```liquid
{%- render 'product-template-individual',
  product: product,
  section_id: section.id,
  blocks: section.blocks,
  image_container_width: section.settings.image_size,
  product_zoom_enable: section.settings.product_zoom_enable,
  sku_enable: section.settings.sku_enable,
  isModal: isModal,
  thumbnail_position: section.settings.thumbnail_position,
  thumbnail_height: section.settings.thumbnail_height,
  thumbnail_arrows: section.settings.thumbnail_arrows,
  video_looping: section.settings.enable_video_looping,
  video_style: section.settings.product_video_style,
  context: 'main-individual-product',
-%}
```

The section schema includes a single block of type `individual_product`. The block calls `individual-product-selection`:

```liquid
{%- when 'individual_product' -%}
  {% render 'individual-product-selection',
    subInCart: subInCart,
    yearlyInCart: yearlyInCart,
    enable_addon_1: section.settings.enable_addon_1,
    enable_addon_2: section.settings.enable_addon_2
  %}
```

The resulting US chain is:

```text
Product template
  -> product-template-individual
  -> individual_product block
  -> individual-product-selection
  -> product-radio-option
  -> theme JavaScript
  -> cart request
```

The section also contains adjacent blocks for `bundle_popup`, `no_sub_atc`, `financing_widget`, `subscription_popup`, `three_month_offer`, and `product_features`. Those are related PDP components, but the membership list itself is controlled by `custom.pdp_individual_product` and the membership Product's merchandising metafields.

---

## 5. US `individual-product-selection` logic

The membership selector checks whether the current equipment Product has the PDP membership list:

```liquid
if product.metafields.custom.pdp_individual_product != blank
  assign membership = true
endif
```

If the field is blank, the snippet uses ordinary variant behavior or renders no selectable option for a product without options. If the field is populated, it resolves the Product references:

```liquid
assign product_list = product.metafields.custom.pdp_individual_product.value
```

It then loops through the referenced Products:

```liquid
{% for related_product in product_list %}
  {% assign product_badges_json = related_product.metafields.custom.pdp_badges_individual_product_json.value %}
  ...
  {% render 'product-radio-option',
    related_product: related_product,
    product_list: product_list,
    badge_bonus: badge_bonus,
    badge_discount: badge_discount,
    badge_discount_2: badge_discount_2,
    badge_best_price: badge_best_price,
    show_price: show_price,
    include_text: include_text,
    index: index_to_pass,
    variant_options: false
  %}
{% endfor %}
```

For each membership Product, the snippet reads the following JSON properties from `custom.pdp_badges_individual_product_json`:

| JSON property | US purpose |
|---|---|
| `discount` | Primary savings badge |
| `discount_2` | Secondary savings copy |
| `best_price` | Best-price badge |
| `bonus` | Bonus or extra value shown on the card |
| `include_text` | Supporting line under the card |
| `show_price` | Controls whether the price is displayed |

The snippet also reads `related_product.metafields.custom.alternate_title` when rendering the title. If that field is blank, it uses the membership Product title.

### Cart-state flags in the US selector

The snippet inspects `cart.items` and sets flags based on Product tags:

| Product tag | Result |
|---|---|
| `Monthly` | Sets `subInCart = true` |
| `Yearly` or `TwoYear` | Sets `yearly_in_cart = true` and stores `variant_yearly` |
| `choice` | Sets `choice_in_cart = true` |
| `october_promo_bundle` | Sets `equipment_in_cart = true` |

The current equipment Product can also have these control tags:

| Product tag or condition | Result |
|---|---|
| `choiceEquipment` | Heading changes from `Premier Membership` to `Choice Monthly` |
| `outlet` | Equipment-only option is rendered before the membership options |
| `core-bundle` | Existing-member login link is shown |
| `product.available` | Membership selector is rendered only when available |
| `custom.free_gift_eligible == false` | Supporting membership text is suppressed |

When a monthly or yearly membership is already in the cart, the add-to-cart button uses the `add-product-only` ID rather than the normal `individual-add-to-cart` ID. The surrounding JavaScript uses these hooks to prevent incompatible duplicate membership additions.

---

## 6. US `product-radio-option` behavior

The supplied `product-radio-option.liquid` file renders one visible card and one radio input for each `related_product`.

The wrapper is:

```liquid
<div
  class="individual-product-selector ..."
  data-index="option1"
  data-value="{{ related_product.title }}"
>
```

The radio input is:

```liquid
<input
  type="radio"
  name="options"
  class="individual-radio"
  value="{{ title }}"
  data-index="option1"
  data-variant-input
  data-product-id="{{ related_product.variants[0].id }}"
  data-title="{{ title }}"
  data-price="{{ related_product.price }}"
  id="ProductSelect-..."
  {% if index == 0 or outlet %}checked{% endif %}
>
```

The Liquid snippet does not submit the cart request. It exposes data attributes consumed by the theme JavaScript. The exact JavaScript handler was not supplied in the research materials.

### Default selection behavior

The first membership in the PDP list is checked by default. If the cart already contains a yearly or two-year membership, the radio matching `variant_yearly` is checked instead. The wrapper may receive a `selected` class when the list contains one item, when the first plan has a `FREE` bonus and a monthly membership is already in the cart, or when the related variant matches the yearly membership already in the cart.

### Dynamic card presentation

The membership card is not hard-coded to a specific plan:

| Card element | Data source |
|---|---|
| Product image | `related_product.featured_image` |
| Card title | `related_product.metafields.custom.alternate_title` or `related_product.title` |
| Price | `related_product.price`, displayed when `show_price == 'true'` |
| Savings badge | `badge_discount` and `badge_discount_2` |
| Best-price badge | `badge_best_price` |
| Supporting line | `include_text` |
| Bonus or extra amount | `badge_bonus` |
| Existing membership state | `subInCart`, `yearly_in_cart`, `choice_in_cart` |

When the relevant membership is already in the cart, the bonus area displays `Already in cart` instead of another membership charge.

For outlet products, the card title is changed to `Equipment Only`, the membership image is hidden, and the option index is shifted because the equipment-only option is rendered before membership options.

For ordinary Product variant selection, the same snippet can use a parent Product and write the option Product Variant ID directly. For membership Product references, it uses `related_product.variants[0].id`. The UK target should avoid this first-variant assumption by storing the exact membership variant in `membership_offer.variant`.

---

## 7. What the current US implementation proves

The US implementation is dynamic in four important ways. The equipment PDP stores references rather than copied membership values. Shopify resolves those references into Products. Each membership Product owns its own image, title, price, alternate title, badge JSON, and tags. The shared snippets render the cards and expose data attributes to the cart JavaScript.

The US implementation is not fully dynamic in the stronger UK sense. Some business behavior still relies on Product tags, the first available Product Variant, legacy client-side JavaScript, and historical branches. These dependencies should be preserved only where the UK business process explicitly needs them.

The underlying subscription entitlement, renewal, customer account access, and subscription-app synchronization are separate from the PDP display layer. A card rendering correctly does not prove that the UK subscription product is configured correctly for billing or account entitlement.

---

## 8. UK target architecture from the supplied PDF

The UK context document identifies the current Stride 8S page as a wrapper that assembles multiple sections. The correct solution is not to duplicate that wrapper and replace a few values. The final architecture must contain one neutral public template named `product.dynamic`, with a neutral section sequence and a product-driven data layer.

The public wrapper should be conceptually similar to:

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

If all new UK SKUs should use the neutral entry point, `templates/product.liquid` may call the same wrapper. Products assigned to old SKU-specific templates should be migrated after the neutral template passes the two-product test.

The following elements remain global theme components outside the product template: navigation bar, mega menu, cart drawer, and footer.

### Presentation assets to preserve

Preserve the approved desktop and mobile gallery markup, thumbnail behavior, image sizing, zoom behavior, CSS classes, product heading and price hierarchy, membership card geometry, radio controls, savings badges, free-delivery badge placement, benefit area, CTA styling, payment row, comparison modal frame and controls, lower-page section order, and reusable visual-only snippets.

Use native Shopify product values for `product.title`, `product.images`, `product.description`, selected variant, and product URL.

### Dependencies that must not remain hard-coded

The reusable UK template must not contain a Stride name, SKU handle, Product ID, membership variant ID, CDN product image URL, product price, promotion branch, product-specific URL, fixed warranty variant, fixed comparison rows, or fixed shipping exception IDs.

Commenting out a hard-coded block is not enough. Remove it or rewrite it so the old SKU logic cannot be activated accidentally.

If a product uses a quote-style template or quote workflow, do not show a customer-facing price unless the UK business rules explicitly authorize it. Use the profile's price display settings and the native product template rules rather than leaking a price from another SKU.

---

## 9. UK product profile metaobject

Create a `product_template_profile` metaobject and attach one reference to each UK equipment Product through a Product metafield such as `custom.template_profile`.

| Field | Type | Purpose |
|---|---|---|
| `subtitle` | Single-line text | Product subtitle or category line |
| `shipping_status` | Text or enum | `ships_now`, `delayed`, or `preorder` |
| `shipping_date` | Single-line text | Displayed when shipping is delayed |
| `price_label` | Single-line text | `From`, `Now`, or another UK-approved label |
| `sale_price` | Money | Optional product-specific sale price |
| `monthly_finance_price` | Money | Monthly finance display |
| `finance_label` | Single-line text | Finance copy |
| `hero_banner_image` | File reference | Product hero or banner image |
| `hero_video` | URL or file reference | Optional product video |
| `hero_copy` | Rich text | Product-specific hero content |
| `specifications` | List of specification-row records | Technical data |
| `experience_sections` | List of product-content-section records | Lifestyle, feature, and media content |
| `comparison_rows` | List of comparison-row records | Membership comparison modal |
| `related_collection` | Collection reference | Related products |
| `safety_content` | Rich text or content reference | Safety and warranty copy |
| `membership_offers` | List of membership-offer records | Plans displayed on this PDP |
| `membership_enabled` | Boolean | Enables membership selection |
| `warranty_variant` | Product variant reference | Optional warranty line item |
| `promotion_items` | List of Product Variant references | Extras, gifts, or add-ons |

A missing profile or missing content record must cause the section to render native data, render nothing, or use a neutral fallback. It must never show another product's content.

---

## 10. UK membership-offer metaobject

Each UK Product profile should reference `membership_offer` records. The same standard membership-offer record may be reused by several equipment Products, or a product-specific offer record may be created for a special promotion.

| Field | Type | Purpose |
|---|---|---|
| `plan_key` | Single-line text | `monthly`, `annual`, or `twoyear` |
| `program` | Single-line text | `premier` or `choice` |
| `variant` | Product Variant reference | Exact membership item added to cart |
| `image` | File reference | Membership card image |
| `title` | Single-line text | Card title |
| `price_text` | Single-line text or money | Display price in GBP |
| `savings_text` | Single-line text | Savings badge |
| `detail_text` | Single-line text | Detail line under price |
| `benefits` | List of single-line text | Card benefit list |
| `free_delivery` | Boolean | Free-delivery badge and banner control |
| `extra_variants` | List of Product Variant references | Optional monitor, voucher, postage, or extras |
| `default_selected` | Boolean | Default radio selection |

The template must enforce the business rule that only annual and two-year offers may show free delivery. A monthly offer with an incorrect `free_delivery` value must not display the free-delivery badge.

The UK membership card renderer should consume `offer.variant`, not `related_product.variants[0].id`. This removes the US first-variant assumption and makes the exact cart item explicit.

A conceptual UK Liquid renderer is:

```liquid
{% assign profile = product.metafields.custom.template_profile.value %}
{% if profile.membership_enabled %}
  {% for offer in profile.membership_offers.value %}
    <input
      type="radio"
      name="membership_offer"
      class="membership-radio"
      data-product-id="{{ offer.variant.value.id }}"
      data-title="{{ offer.title.value | escape }}"
      data-price="{{ offer.price_text.value | escape }}"
      {% if offer.default_selected.value %}checked{% endif %}
    >
    {% render 'membership-card', offer: offer %}
  {% endfor %}
{% endif %}
```

The exact syntax depends on the UK metaobject definition, but the architecture must remain reference-driven and must not contain numeric IDs in Liquid, JavaScript, or section settings.

---

## 11. UK product content records

Repeating product information should use lists of metaobjects rather than one section or one template per SKU.

A `specification_row` record should contain `label`, `value`, `column`, and `sort_order`.

A `product_content_section` record should contain `type`, `eyebrow`, `heading`, `copy`, `image`, `video`, `button_label`, `button_link`, and `sort_order`.

The dynamic renderer should loop through these records and reuse the approved reference markup for each content type. Product-specific media, copy, specifications, comparison rows, safety information, and related collections must be data records, not Liquid branches that compare Product IDs or handles.

---

## 12. UK cart architecture

The dynamic cart helper should receive the current equipment Product and the selected membership offer from the profile. It should add the following through one `/cart/add.js` request or the UK theme's equivalent cart API:

| Cart item | Data source |
|---|---|
| Equipment variant | `product.selected_or_first_available_variant.id` |
| Selected membership | `offer.variant` |
| Warranty | `profile.warranty_variant`, when configured |
| Optional extras | `offer.extra_variants` or `profile.promotion_items` |

Do not place numeric product or variant IDs in Liquid, JavaScript, or section settings. Do not use a fixed warranty variant. Do not assume that the first available membership variant is always the correct cart item.

The existing US `product-radio-option` snippet creates radio inputs and data attributes, but it does not itself submit the cart request. The UK implementation therefore needs a deliberate cart helper that consumes the selected offer reference, validates the current product variant, and adds the intended line items.

---

## 13. Recommended UK migration sequence

### Phase 1: Confirm UK products

Create or identify the UK Monthly Premier, UK Yearly Premier, and UK 2-Year Premier Products and exact Product Variants. Confirm titles, handles, status, `productType`, GBP prices, SKUs, selling plans, subscription configuration, tags, and customer entitlement behavior. Do not use US Product GIDs in the UK store.

If UK has a promotional free-membership Product, model it separately. Do not substitute the US `$0.00` promotional Product into the standard three-plan list without an explicit business decision.

### Phase 2: Create the schema

Create the `product_template_profile`, `membership_offer`, `specification_row`, `product_content_section`, and `comparison_row` metaobject definitions. Create the Product reference metafield `custom.template_profile`. Decide whether the current UK store already has compatible definitions before creating duplicates.

### Phase 3: Build the neutral wrapper

Create or refactor the public `product.dynamic` wrapper. Move approved presentation markup from the reference implementation into neutral reusable sections. Remove product handles, IDs, prices, URLs, fixed membership variants, fixed images, fixed promotions, and SKU-specific branches.

### Phase 4: Implement the membership renderer

The renderer should read `profile.membership_offers`, use `offer.variant`, render the offer image and content fields, preserve the intended order, apply the default selection, show free delivery only for eligible plan keys, and output data attributes for the cart helper.

The renderer may temporarily support the US compatibility path by reading `custom.pdp_individual_product` while UK products are being migrated. The final target should use the profile-based path.

### Phase 5: Configure two products first

Attach profiles to at least two different UK equipment Products. Populate their membership-offer lists, product-specific content records, shipping status, price labels, specifications, media, and comparison rows. The two Products must use the same neutral template.

### Phase 6: Validate before publish

Run the acceptance tests in the next section. Compare actual cart line items, variant IDs, selling plans, prices, shipping behavior, and customer entitlement behavior. Only after the schema and two-product test pass should the changes be pushed to the UK theme.

---

## 14. Acceptance tests

| Test | Expected result |
|---|---|
| Standard UK equipment PDP with three membership offers | Premier heading and Monthly, Yearly, 2-Year cards render in the intended order |
| Same template used by two different equipment products | Each product displays its own title, media, specifications, price labels, content, and membership data |
| Blank profile | Sections use native values or render nothing; no other SKU's content appears |
| Blank membership-offer list | No membership selector appears and the normal product flow remains usable |
| `membership_enabled` false | Membership selection and membership CTA are hidden |
| Membership badge data present | Savings, bonus, detail copy, benefits, and price display match the offer record |
| Monthly offer with accidental `free_delivery: true` | Template still hides free delivery because only annual and two-year plans qualify |
| Annual and two-year offers | Correct free-delivery badge and shipping behavior appear when configured |
| Product with quote-style template | Customer-facing price is hidden unless explicitly authorized by UK business rules |
| Existing monthly membership in cart | Duplicate monthly membership behavior matches the intended business rule |
| Existing annual or two-year membership in cart | Duplicate long-term membership behavior is prevented or handled explicitly |
| Outlet or special-offer product | Special behavior appears only when its profile or tags intentionally enable it |
| Product variant selection | Equipment variant added is the current selected variant, not a hard-coded ID |
| Membership selection | Exact `offer.variant` is added, not the first available variant by assumption |
| Warranty and extras | Only configured profile or offer references are added |
| GBP currency | All actual and display prices are UK-localized and no accidental USD text remains |
| Missing media or copy | Section hides or uses neutral fallback, never another product's content |
| Mobile and desktop | Card geometry, radio controls, gallery, and CTA work at both breakpoints |
| Checkout | Correct UK Product Variant, selling plan, price, and expected membership entitlement are present |
| Regression | Navigation, mega menu, cart drawer, footer, reviews, financing, and global theme components remain functional |

---

## 15. Implementation rules for the UK chat

The UK implementation chat should follow these rules throughout the build:

1. Use one neutral template and data-driven sections. Do not create a new public template for every SKU.
2. Treat the US `custom.pdp_individual_product` list as a verified behavior reference, not as the complete UK architecture.
3. Use UK Product and Product Variant references. Never reuse US Product GIDs or numeric variant IDs in the UK store.
4. Use `custom.template_profile` and `membership_offer` records for the final UK data model.
5. Keep the same approved presentation layer, but remove product-specific data from Liquid and JavaScript.
6. Store membership image, title, price, savings, benefits, details, free delivery, and extras on membership-offer records.
7. Enforce annual and two-year-only free delivery in both data validation and template logic.
8. Keep cart logic explicit. Add the current equipment variant and selected membership offer through the intended UK cart request.
9. Hide or neutrally fall back when data is missing. Never display another SKU's content.
10. Test two different UK Products with the same template before publishing.
11. Do not modify live store configuration while only documenting or investigating.
12. When the UK business requires a quote template, hide the price according to the quote workflow instead of falling back to a normal product price.

---

## 16. Known gaps and required follow-up

The Liquid membership data model and radio-card rendering are now documented. The remaining optional evidence is the theme JavaScript handler that consumes `.individual-radio`, `data-product-id`, `data-price`, and `data-title` and submits the cart request. It is not required to reproduce the metafield and template architecture, but it should be inspected before duplicating exact US cart behavior.

The UK Product GIDs, UK membership Product Variants, selling-plan IDs, subscription app configuration, entitlement rules, and final UK merchandising copy still need to be confirmed in the UK Shopify Admin. They must not be inferred from the US IDs.

The US and UK public pages can be used for visual comparison, but the Shopify Admin configuration and theme source should remain the authoritative implementation sources.

---

## 17. Source references

### Public storefront references

[1]: https://echelonfit.com/pages/membership "Echelon Fit US membership page"
[2]: https://echelonfit.com/products/stride-6s "Echelon Fit US Stride 6S public PDP"
[3]: https://echelonfit.uk/pages/echelon-membership "Echelon Fit UK membership page"

### US Shopify Admin references

[4]: https://admin.shopify.com/store/echelon-store/products/4129967505490 "US Admin: Echelon Premier Yearly Plan"
[5]: https://admin.shopify.com/store/echelon-store/products/8081808261319 "US Admin: Echelon Premier Monthly With 30 Days Free"
[6]: https://admin.shopify.com/store/echelon-store/products/4815463809106 "US Admin: Echelon Premier 2-Year Plan"
[7]: https://admin.shopify.com/store/echelon-store/products/7828423442631 "US Admin: Echelon Stride 6S PDP"
[8]: https://admin.shopify.com/store/echelon-store/products/7712959922375 "US Admin: Echelon EX-5s Connect Bike PDP"
[9]: https://admin.shopify.com/store/echelon-store/settings/custom_data/product/metafields/56523587783 "US Admin: PDP individual product metafield definition"

### User-provided UK context

[10]: file:///home/ubuntu/upload/Correct_Solution_One_100%_Dynamic_Product_Template.pdf "UK PDF: Correct Solution One 100% Dynamic Product Template"

### User-provided US theme source files embedded in this document

[11]: file:///home/ubuntu/upload/pasted_content.txt "US product section and schema source"
[12]: file:///home/ubuntu/upload/pasted_content_2.txt "US product-template-individual Liquid source"
[13]: file:///home/ubuntu/upload/pasted_content_3.txt "US individual-product-selection Liquid source"
[14]: file:///home/ubuntu/upload/pasted_content_4.txt "US product-radio-option Liquid source"

### Verified Shopify identifiers

| Entity | Identifier |
|---|---:|
| PDP metafield definition | `gid://shopify/MetafieldDefinition/56523587783` |
| Standard US monthly Premier Product | `gid://shopify/Product/7696193355975` |
| User-supplied US free 30-day Product | `gid://shopify/Product/8081808261319` |
| Standard US yearly Premier Product | `gid://shopify/Product/4129967505490` |
| Standard US two-year Premier Product | `gid://shopify/Product/4815463809106` |
| Stride 6S PDP | `gid://shopify/Product/7828423442631` |
| EX-5s PDP | `gid://shopify/Product/7712959922375` |
| EX-8s PDP | `gid://shopify/Product/7712960020679` |

---

## Final handoff statement

The UK chat should use the US implementation to reproduce membership behavior and use the PDF architecture to build the final dynamic product system. The US implementation demonstrates how ordered Product references, Product metafields, Liquid snippets, radio inputs, cart flags, and theme JavaScript work together. The UK architecture should preserve that behavior while replacing SKU-specific assumptions with a neutral `product.dynamic` template, `custom.template_profile`, `membership_offer` metaobjects, explicit Product Variant references, and validated dynamic cart logic.


---

## 18. Stride 8S template editor reference

### Editor URL and scope

The supplied Shopify Theme Editor reference is:

[Stride 8S template editor reference][15]

The reference opens theme ID `139674484935`, the published `echelon-US/live-published-theme`, with the public preview path `/products/stride-8s`. The selected section parameter is:

```text
section=template--17570151301319__main-individual-product
```

The selected section is the product-page section named **Individual product**. Its section class is `main-cart-pdp-2025`. The section delegates the main product markup to `product-template-individual` and passes the current Product, section ID, section blocks, image settings, zoom settings, thumbnail settings, video settings, and the context name `main-individual-product`.

This editor URL is a configuration reference for the US theme. Do not copy the theme ID or section ID into the UK implementation. The UK implementation must use the same reusable presentation concepts in a neutral UK template.

### Section-level settings

The `Individual product` section schema exposes the following settings. These are reusable presentation controls, not product identity data.

| Setting | Type | Default or options | Dynamic UK treatment |
|---|---|---|---|
| `image_size` | Select | `small`, `medium`, `large`; default `medium` | Keep as section presentation setting |
| `product_zoom_enable` | Checkbox | Default `true` | Keep; operates on the current Product media |
| `thumbnail_position` | Select | `beside`, `below`; default `beside` | Keep as gallery setting |
| `thumbnail_height` | Select | `fixed`, `flexible`; default `flexible` | Keep as gallery setting |
| `thumbnail_arrows` | Checkbox | Optional | Keep as gallery setting |
| `enable_video_looping` | Checkbox | Default `true` | Keep for current Product video |
| `product_video_style` | Select | `muted`, `unmuted`; default `muted` | Keep as media setting |

### Add-on promotion settings

The section schema contains two optional add-on promotion configurations. In the current US source schema, these settings include default variant IDs, titles, image picker or fallback image URL, badge text, original price, sale price, and description. Those defaults are a legacy US implementation detail and must not be copied into UK Liquid or JavaScript as fixed product data.

| Add-on | Current schema settings | Correct UK treatment |
|---|---|---|
| Add-on 1 | `enable_addon_1`, `addon_1_variant_id`, `addon_1_title`, `addon_1_image`, `addon_1_image_url`, `addon_1_badge_text`, `addon_1_original_price`, `addon_1_sale_price`, `addon_1_description` | Replace with `profile.promotion_items` or offer-level Product Variant references and localized UK content |
| Add-on 2 | `enable_addon_2`, `addon_2_variant_id`, `addon_2_title`, `addon_2_image`, `addon_2_image_url`, `addon_2_badge_text`, `addon_2_original_price`, `addon_2_sale_price`, `addon_2_description` | Replace with `profile.promotion_items` or offer-level Product Variant references and localized UK content |

The current US schema contains image URLs and numeric variant defaults for the add-ons. These are exactly the type of SKU or promotion-specific dependencies that the UK dynamic architecture must remove.

### Available product blocks in the section schema

The section schema exposes the following block types. The schema defines what can be added; the exact saved block order and enabled settings belong to the specific template JSON or Theme Editor state. The UK chat should use this catalog as a migration checklist, not assume that every block is active on every Product.

| Block type | Current purpose | UK dynamic treatment |
|---|---|---|
| `@app` | App block slot | Preserve app extensibility |
| `price` | Product price | Read current Product or profile price settings |
| `quantity_selector` | Quantity control | Preserve reusable control |
| `complementary_products` | Pairs well with or complementary products | Use Shopify complementary products or profile references |
| `size_chart` | Size chart page | Preserve for applicable products |
| `variant_picker` | Product variant picker | Use current Product variants and selected variant |
| `individual_product` | Membership or individual-product selector | Keep as a reusable block, but feed UK profile membership offers |
| `description` | Product description or tab | Read current Product description and profile content |
| `bundle_popup` | Bundle popup | Enable only when profile or promotion data enables it |
| `no_sub_atc` | Add-to-cart behavior when subscription is absent or restricted | Replace hard-coded rules with profile and subscription state |
| `financing_widget` | Financing widget | Read UK finance profile fields and current Product |
| `subscription_popup` | Subscription popup | Use UK membership and subscription configuration |
| `three_month_offer` | Three-month special offer | Enable only for a UK promotion record or offer profile |
| `product_features` | Product feature dropdown content | Read feature data from profile content records |
| `bundleDropdown` | Bundle dropdown | Read bundle or promotion records |
| `apparel-buy-button` | Apparel quantity and buy button | Keep only for apparel products or applicable product profiles |
| `buy_buttons` | Native buy buttons and pickup settings | Use current Product variant and UK selling/fulfillment rules |
| `preorder-buttons` | Preorder CTA | Drive from `profile.shipping_status` or a preorder profile flag |
| `inventory_status` | Inventory messaging and transfers | Use current inventory and UK fulfillment rules |
| `sales_point` | Icon and sales-point text | Store copy in profile or section settings, not SKU branches |
| `text` | Generic text block | Use only for reusable content or profile-driven copy |
| `trust_badge` | Trust image | Store image in profile or global settings |
| `tab` | Shipping, returns, or policy tab | Use UK policy content and profile references |
| `share` | Social sharing | Preserve global product sharing behavior |
| `separator` | Visual separator | Preserve presentation-only behavior |
| `contact` | Contact form | Use generic UK contact workflow and product context |
| `custom` | Custom HTML, Liquid, or app scripts | Restrict to approved reusable code; remove SKU-specific logic |

### Block settings that require attention

The `variant_picker` block exposes labels, button or dropdown picker type, dynamic variant behavior, and optional color swatches. In UK, this block must remain connected to the current Product variants and must not be replaced with fixed variant IDs.

The `buy_buttons` block exposes dynamic checkout and surface pickup settings. UK checkout, payment, and fulfillment behavior must be validated separately from the visual block setting.

The `inventory_status` block exposes an inventory threshold, with a default threshold of 10, a range from 0 to 20, and an inventory-transfer toggle. UK inventory messaging must be tested against the actual UK fulfillment model.

The `sales_point` block exposes an icon selector with values such as `checkmark`, `gift`, `globe`, `heart`, `leaf`, `lock`, `package`, `phone`, `ribbon`, `shield`, `tag`, and `truck`, plus a text field. The current source default is `Free worldwide shipping`, but this copy must be UK-localized and must not be assumed to apply to every product.

The `tab` block exposes a title, rich-text content, or a Shopify Page reference. UK shipping, returns, warranty, and financing content should use UK policy sources.

The `custom` block exposes a Liquid code field and a `class_specific` checkbox. The UK chat must treat this block as a controlled escape hatch. Any custom code containing a Product ID, handle comparison, fixed URL, fixed price, fixed variant ID, or SKU-specific branch must be converted to profile-driven logic or removed.

### Product feature block

The `product_features` block includes a feature-content field and a `usa_designed` text field in the current US schema. The default text is `Designed and Engineered in the USA`. This copy is not appropriate as a universal UK default. In UK, store the equivalent localized claim in the Product profile or content record and render it only for Products for which it is approved.

### Relationship to the selected `main-individual-product` section

The section editor parameter identifies the product-page section that owns the main product media, heading, price, product blocks, membership selector, financing, and add-to-cart flow. The membership block is not a separate standalone Product object. It is a block inside the main product section, and its Liquid implementation calls the membership selector snippet.

The final UK architecture can retain the same conceptual block placement while changing its data source:

```text
main product section
  -> individual_product block
  -> membership renderer
  -> profile.membership_offers
  -> membership card
  -> dynamic cart helper
```

### Verified versus unavailable template-editor details

The supplied editor link and the user-provided section source verify the theme ID, preview path, selected section ID, section name, section class, section schema settings, available block types, and the Liquid render chain. The editor's saved instance JSON, including the exact enabled block order and every per-instance setting, was not exposed in the browser capture. The supplied UK PDF does provide the live page sequence for the Stride 8S wrapper: Product description, Membership upgrade, Product specifications, Reviews, Experience, Product experience CTA, Feature slider, Full-width video, Memberships, Derisk section, Financing CTA, More than a membership, Featured collection, Community, Safety, Upgrade snippet, and Membership comparison popup. [10]

If the UK chat needs an exact one-to-one copy of the saved Theme Editor state, it should export or provide the relevant template JSON from the theme code editor. The UK implementation should not depend on that exact US instance state; it should use the neutral schema and profile-driven data model described above.

## Additional reference

[15]: https://admin.shopify.com/store/echelon-store/themes/139674484935/editor?previewPath=%2Fproducts%2Fstride-8s&section=template--17570151301319__main-individual-product "Shopify Theme Editor: Stride 8S main-individual-product section"

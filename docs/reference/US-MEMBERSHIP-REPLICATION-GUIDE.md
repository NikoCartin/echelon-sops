# Echelon Membership PDP Replication Guide

**Source store:** echelonfit.com / Echelon Fit US
**Target store:** echelonfit.uk
**Prepared by:** Manus AI
**Status:** Investigation and documentation only. No store changes were made.

## 1. Executive conclusion

The membership experience is not driven by a single hard-coded membership component inside each equipment PDP. The storefront uses a reusable product template and a Product metafield that stores an ordered list of references to Shopify membership products.

The central relationship is:

> **Equipment PDP → `custom.pdp_individual_product` → referenced membership products → referenced product badge metafields → radio-option selector → cart logic.**

The exact PDP metafield definition is named **PDP individual product**, uses namespace/key `custom.pdp_individual_product`, and has type `list.product_reference`. Its description is `Choose a fit pass for your product`. [5]

On the confirmed Stride 6S, Stride 6, Stride 8S, EX-5s, and EX-8s PDPs, the metafield resolves to three standard Premier products in this order: Monthly, Yearly, and 2-Year. [6] [7] [8]

A critical distinction is that the product `Echelon Premier Monthly With 30 Days Free` with ID `8081808261319` exists and is active, but the sampled standard equipment PDPs do **not** reference it. They reference the standard monthly product `7696193355975`. The 8081808261319 product is a `$0.00` promotional product tagged `1monthSub` and `3monthSub`, so it should be treated as a special-offer source unless another specific PDP is verified to reference it. [3] [7]

## 2. Source membership products

The source products are ordinary Shopify products with `productType: Subscription`. Their titles, handles, variants, prices, tags, and merchandising metafields are the data that the PDP resolves dynamically.

| Purpose | Product | Shopify product ID | Handle | Variant ID | Observed price | Relevant tags or notes |
|---|---|---:|---|---:|---:|---|
| Standard monthly Premier used by sampled equipment PDPs | Echelon Premier Monthly | `7696193355975` | `echelon-monthly-premier` | `43246953267399` | `$39.99` | `PremierSub`, `Monthly`, `1monthSub`, `bundleDiscount` |
| Standard yearly Premier | Echelon Premier Yearly Plan | `4129967505490` | `reflect-1-year-plan` | `30135749771346` | `$399.99` | `premier`, `PremierSub`, `Subscription`, `Yearly`, `year` |
| Standard two-year Premier | Echelon Premier 2-Year Plan | `4815463809106` | `copy-of-echelon-united-2-year-plan` | `32930539503698` | `$699.99` | `premier`, `PremierSub`, `Subscription`, `TwoYear`, `year` |
| Promotional/free membership source supplied by the user | Echelon Premier Monthly With 30 Days Free | `8081808261319` | `echelon-premier-monthly-with-30-days-free` | `44236514427079` | `$0.00` | `PremierSub`, `1monthSub`, `3monthSub`; description says `$39.99 value` |

The public US membership page exposes the standard Premier monthly and yearly CTAs through direct cart-add links to variant IDs `43246953267399` and `30135749771346`. It also exposes FitPass as a separate membership family. [1]

The standard monthly Premier product has `custom.compare_table` values describing the plan and `custom.pdp_badges_individual_product_json` values including the bonus, supporting copy, and price-display flag. The standard two-year product has `custom.alternate_title = 2-Year Access` and a JSON badge object. The monthly product has `custom.alternate_title = 30-Days`. These fields are presentation data, not the underlying entitlement itself.

## 3. The PDP metafield relationship

The equipment PDP does not copy the membership title, price, or variant ID into separate hard-coded fields. Instead, it stores Product references in a list.

### Confirmed definition

| Setting | Value |
|---|---|
| Display name | `PDP individual product` |
| Namespace and key | `custom.pdp_individual_product` |
| Type | `list.product_reference` |
| Definition ID | `gid://shopify/MetafieldDefinition/56523587783` |
| Description | `Choose a fit pass for your product` |

### Confirmed Stride 6S value

For the Stride 6S product `gid://shopify/Product/7828423442631`, the stored value is:

```json
[
  "gid://shopify/Product/7696193355975",
  "gid://shopify/Product/4129967505490",
  "gid://shopify/Product/4815463809106"
]
```

Shopify resolves those references to the following products:

| List position | Product resolved by Shopify | Result in the PDP |
|---:|---|---|
| 0 | Echelon Premier Monthly | First membership option |
| 1 | Echelon Premier Yearly Plan | Second membership option |
| 2 | Echelon Premier 2-Year Plan | Third membership option |

The exact same ordered list was confirmed on `Stride-6`, `Stride-8s`, the EX-5s Connect Bike, and the EX-8s Smart Connect Bike. Other active treadmill products such as partner and runDISNEY offers returned the metafield as null in the sampled query, proving that the relationship is assigned per PDP and is not automatically inherited by every treadmill product. [7] [8]

## 4. Template and Liquid flow

The section file supplied for the product page renders the reusable `product-template-individual` snippet and passes the current product, section blocks, and settings:

```liquid
{%- render 'product-template-individual',
  product: product,
  section_id: section.id,
  blocks: section.blocks,
  ...
  context: 'main-individual-product',
-%}
```

The section schema contains one block of type `individual_product`. During rendering, that block calls the membership selector snippet:

```liquid
{%- when 'individual_product' -%}
  {% render 'individual-product-selection',
    subInCart: subInCart,
    yearlyInCart: yearlyInCart,
    ...
  %}
```

The membership selector then executes the following sequence.

### Step 1: Detect whether the PDP has membership offers

```liquid
if product.metafields.custom.pdp_individual_product != blank
  assign membership = true
endif
```

If the list is blank, the PDP is treated as an ordinary product or variant selector. If the list is populated, the membership heading and membership choices are enabled.

### Step 2: Resolve the referenced product list

```liquid
assign product_list = product.metafields.custom.pdp_individual_product.value
```

This is the key dynamic operation. Shopify returns the referenced Product objects, so the snippet can read their titles, handles, variants, prices, tags, and product metafields without hard-coding the membership data in the equipment product.

### Step 3: Read merchandising data from each membership product

For every `related_product`, the snippet reads:

```liquid
assign product_badges_json = related_product.metafields.custom.pdp_badges_individual_product_json.value
```

It then extracts these properties when present:

| Property | Function in the PDP |
|---|---|
| `discount` | Primary savings or promotion badge |
| `discount_2` | Secondary promotion badge |
| `best_price` | Best-price callout |
| `bonus` | Bonus text such as `+ Free` or `FREE` |
| `include_text` | Supporting copy under the option |
| `show_price` | Controls whether the price is displayed in the option |

Those values are passed to `product-radio-option`, which is responsible for the option markup and the selected related product or variant.

### Step 4: Preserve list order

The snippet uses `forloop.index0` as the option index. Consequently, the order of the PDP metafield matters. For the standard list, index 0 is Monthly, index 1 is Yearly, and index 2 is 2-Year. A UK implementation must preserve the intended display order when assigning references.

### Step 5: Apply cart-state rules

The selector checks cart items and sets flags based on product tags:

| Cart tag | Flag or behavior |
|---|---|
| `Monthly` | Sets `subInCart = true` |
| `Yearly` or `TwoYear` | Sets `yearly_in_cart = true` and captures the existing yearly variant ID |
| `choice` | Sets `choice_in_cart = true` |
| `october_promo_bundle` | Sets `equipment_in_cart = true` |

These flags prevent incompatible duplicate membership selections and change the add-to-cart button behavior. When a monthly or yearly membership is already in the cart, the button ID changes to `add-product-only`; otherwise it uses `individual-add-to-cart`.

The snippet also uses product tags for presentation and eligibility:

| Product tag or condition | Effect |
|---|---|
| `choiceEquipment` | Changes the heading from `Premier Membership` to `Choice Monthly` |
| `outlet` | Uses alternate selector and index behavior |
| `core-bundle` | Shows an existing-member login link |
| `product.available` | Prevents the membership selector from rendering for unavailable products |
| `custom.free_gift_eligible = false` | Suppresses the membership option's supporting copy |

The exact radio markup and client-side cart behavior are delegated to `product-radio-option` and the theme JavaScript. The supplied files prove the Liquid data flow into that snippet; they do not include the full implementation of `product-radio-option`.

## 5. What must be replicated in echelonfit.uk

Replication should be done in this order. The process should be performed in a duplicate or unpublished UK theme first, with no live publish until the acceptance tests pass.

### 5.1 Create or identify the UK membership products

The UK store needs one Product record for every membership option that should appear on equipment PDPs. Do not reuse US product GIDs in the UK store. Shopify Product IDs are store-specific.

For each UK membership product, confirm the product title, handle, status, `productType: Subscription`, variant price in GBP, SKU, selling-plan or subscription configuration, and any tags required by the UK theme or subscription integration. The three membership Product references placed on a UK equipment PDP must point to UK products, not to the US products listed above.

If the UK offer includes a free or promotional plan, create or identify that product separately. Do not replace the standard monthly reference with the `$0.00` US promotional product unless the UK promotion is intentionally meant to use the same behavior.

### 5.2 Create the PDP reference metafield

In Shopify UK, create or verify the Product metafield definition with the following exact structure:

```text
Name: PDP individual product
Namespace and key: custom.pdp_individual_product
Type: list.product_reference
Description: Choose a fit pass for your product
```

If the definition already exists in UK with a different namespace, key, or type, do not silently create a second competing field. Decide whether the UK theme should be updated to use the existing field or whether the field should be standardized before migration.

### 5.3 Migrate the theme structure

The UK theme must contain the equivalent of the following chain:

```text
Product template
  → product-template-individual
  → individual_product block
  → individual-product-selection
  → product-radio-option
```

The `individual_product` block must be present in the product section. The `individual-product-selection` snippet must read `product.metafields.custom.pdp_individual_product.value`, loop through the referenced products, read `related_product.metafields.custom.pdp_badges_individual_product_json.value`, and pass the resolved values into `product-radio-option`.

The theme must also contain the JavaScript and cart selectors expected by the Liquid snippet, including the `individual-radio`, `individual-product-selector`, `individual-add-to-cart`, and `add-product-only` hooks. If the UK theme uses different class names or cart endpoints, the Liquid and JavaScript must be ported together.

### 5.4 Configure membership product merchandising metafields

For each UK membership product, create or verify the fields consumed by the selector:

| Namespace/key | Expected type or content | Purpose |
|---|---|---|
| `custom.pdp_badges_individual_product_json` | JSON object | `discount`, `discount_2`, `best_price`, `bonus`, `include_text`, and `show_price` |
| `custom.compare_table` | List of single-line text | Comparison table values, if the UK PDP displays them |
| `custom.alternate_title` | Single-line text | Short plan label such as `2-Year Access` or `30-Days` |
| `subscriptions.*` | Subscription integration fields | Renewal, billing interval, subscription ID, and synchronization data, where used by the subscription app |

The badge JSON should contain UK-localized text and GBP values. Prices that are part of display copy must not be left in dollars. The actual checkout price should come from the UK membership product variant or selling plan.

Example UK badge object:

```json
{
  "discount": "Save £60",
  "best_price": "Best value",
  "bonus": "+ Free",
  "include_text": "Unlimited live and on-demand classes",
  "show_price": "true"
}
```

The exact values should be approved by the UK merchandising owner before entry.

### 5.5 Populate the metafield on UK equipment PDPs

For every UK equipment product that should offer Premier, assign the UK membership products to `custom.pdp_individual_product` in the desired order. A standard three-plan list should be:

```text
[UK Monthly Premier, UK Yearly Premier, UK 2-Year Premier]
```

The list should contain Product references, not text titles, variant IDs, URLs, or copied prices. The PDP will resolve the current product data at render time.

Do not populate the metafield on partner, outlet, charity, or special-offer PDPs until their specific business rules are understood. The US store demonstrates that some active equipment records have the field populated while other active treadmill records have it null.

## 6. Acceptance tests for the UK implementation

The implementation is ready only when the following tests pass in a preview or unpublished theme.

| Test | Expected result |
|---|---|
| Standard equipment PDP with three references | Premier heading appears and three options render in Monthly, Yearly, 2-Year order |
| PDP with blank `custom.pdp_individual_product` | No membership selector appears; normal product or variant flow remains intact |
| PDP with an unavailable product | Membership selector is not shown and the add button is disabled or sold out according to the theme |
| Membership product badge JSON present | Badge, supporting text, price visibility, and bonus copy match the JSON values |
| Existing monthly membership in cart | Duplicate monthly selection is suppressed or the button switches to product-only behavior |
| Existing yearly or two-year membership in cart | Duplicate long-term membership behavior matches the US logic |
| UK currency | All actual prices are GBP and no US dollar copy remains in badges, compare tables, or plan labels |
| Mobile and desktop PDP | Selector layout, radio controls, and add-to-cart behavior work at both breakpoints |
| Checkout | The selected UK membership product or selling plan is added with the correct variant and price |
| Special-offer PDP | Promotional products appear only where their metafield and tags intentionally enable them |

## 7. Operational guidance and risks

The metafield is a reference list, so changing the referenced product, its status, variant price, tags, or badge JSON can change multiple PDPs at once. Before editing a source membership product, identify every PDP that references it and record the current order of references.

The `$0.00` product `8081808261319` should not be treated as interchangeable with the standard monthly product `7696193355975`. The current standard equipment PDPs inspected in the US store reference `7696193355975`; the free product has different tags and promotional semantics. [3] [7]

The subscription integration is separate from the PDP display layer. The `subscriptions` namespace contains synchronization and billing metadata on subscription products, while `custom.pdp_individual_product` determines which membership products are displayed on an equipment PDP. A visually correct selector does not by itself prove that the UK subscription entitlement, renewal, customer account access, or app activation flow is correctly configured.

No changes were made to the US or UK stores during this investigation. The guide is based on read-only Shopify Admin queries, public storefront pages, and the Liquid files supplied by the user.

## References

[1]: https://echelonfit.com/pages/membership "Echelon Fit US membership page"
[2]: https://admin.shopify.com/store/echelon-store/products/4129967505490 "Shopify Admin: Echelon Premier Yearly Plan"
[3]: https://admin.shopify.com/store/echelon-store/products/8081808261319 "Shopify Admin: Echelon Premier Monthly With 30 Days Free"
[4]: https://admin.shopify.com/store/echelon-store/products/4815463809106 "Shopify Admin: Echelon Premier 2-Year Plan"
[5]: https://admin.shopify.com/store/echelon-store/settings/custom_data/product/metafields/56523587783 "Shopify Admin: PDP individual product metafield definition"
[6]: https://echelonfit.com/products/stride-6s "Echelon Fit US: Stride 6S PDP"
[7]: https://admin.shopify.com/store/echelon-store/products/7828423442631 "Shopify Admin: Echelon Stride 6S PDP"
[8]: https://admin.shopify.com/store/echelon-store/products/7712959922375 "Shopify Admin: Echelon EX-5s Connect Bike PDP"
[9]: https://echelonfit.uk/pages/echelon-membership "Echelon Fit UK membership page"
[10]: file:///home/ubuntu/upload/pasted_content.txt "User-provided product section template"
[11]: file:///home/ubuntu/upload/pasted_content_2.txt "User-provided product-template-individual Liquid file"
[12]: file:///home/ubuntu/upload/pasted_content_3.txt "User-provided individual-product-selection Liquid file"


## 8. UK context update: the final target is broader than the US membership field

The UK context document changes the recommended end state. The US implementation of `custom.pdp_individual_product` is a validated pattern for dynamically attaching membership products to an equipment PDP, but it should not be copied as the complete UK architecture. The UK target is a neutral, reusable product template with a broader product profile that controls all product-specific PDP data, including memberships, specifications, media, shipping, financing, warranty, promotions, and related content. [13]

The important implementation decision is therefore:

> Use the US `custom.pdp_individual_product` relationship as the proven reference for membership behavior, but build the UK end state around `custom.template_profile` and `membership_offer` records.

The recommended UK data flow is:

```text
Current Shopify product
  → product.metafields.custom.template_profile.value
  → product_template_profile.membership_offers
  → membership_offer.variant
  → reusable membership card and cart helper
```

The US compatibility flow is:

```text
Current Shopify product
  → product.metafields.custom.pdp_individual_product.value
  → referenced membership Product
  → related_product.metafields.custom.pdp_badges_individual_product_json.value
  → product-radio-option
```

The UK implementation may temporarily support both flows while products are migrated. The final UK code should use the profile-based flow so that membership cards do not depend on numeric IDs, copied prices, or scattered product-specific branches.

## 9. Neutral UK template architecture

The PDF describes the current Stride 8S page as a wrapper that assembles multiple sections. The correct UK solution is not to duplicate that SKU-specific wrapper and replace values. Instead, preserve the approved visual markup and move it into neutral reusable sections. [13]

A neutral wrapper should follow this pattern:

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

Keep the public template name `product.dynamic`. If all new UK SKUs should use the neutral entry point, point `templates/product.liquid` to the same wrapper and migrate products away from old SKU-specific templates after the two-product test passes.

The wrapper and sections must not contain a Stride name, SKU handle, product ID, membership variant ID, CDN image URL, product price, promotion branch, or product-specific URL. When a profile or content record is missing, the section should use native Shopify data or render nothing. It must never display content from another SKU.

## 10. UK profile and membership-offer data model

Create one `product_template_profile` metaobject definition and attach it to each UK equipment product using a Product metafield such as `custom.template_profile`.

| Profile field | Type | Purpose |
|---|---|---|
| `subtitle` | Single-line text | Product subtitle or category line |
| `shipping_status` | Text or enum | `ships_now`, `delayed`, or `preorder` |
| `shipping_date` | Single-line text | Displayed when shipment is delayed |
| `price_label` | Single-line text | `From`, `Now`, or another UK-approved label |
| `sale_price` | Money | Optional product-specific sale price |
| `monthly_finance_price` | Money | Monthly finance display |
| `finance_label` | Single-line text | Finance copy |
| `hero_banner_image` | File reference | Product hero or banner image |
| `hero_video` | URL or file reference | Optional product video |
| `hero_copy` | Rich text | Product-specific hero content |
| `specifications` | List of specification rows | Technical product data |
| `experience_sections` | List of content sections | Feature and lifestyle content |
| `comparison_rows` | List of comparison rows | Dynamic membership comparison modal |
| `related_collection` | Collection reference | Related products |
| `safety_content` | Rich text or content reference | Safety and warranty copy |
| `membership_offers` | List of membership-offer records | Plans displayed on this PDP |
| `membership_enabled` | Boolean | Enables the membership purchase flow |
| `warranty_variant` | Product variant reference | Optional warranty line item |
| `promotion_items` | List of product-variant references | Optional extras or gifts |

Each `membership_offer` record should contain the following fields:

| Membership-offer field | Type | Purpose |
|---|---|---|
| `plan_key` | Single-line text | `monthly`, `annual`, or `twoyear` |
| `program` | Single-line text | `premier` or `choice` |
| `variant` | Product variant reference | Variant added to cart |
| `image` | File reference | Membership card image |
| `title` | Single-line text | Card title |
| `price_text` | Text or money | Display price in GBP |
| `savings_text` | Single-line text | Savings badge |
| `detail_text` | Single-line text | Supporting line under price |
| `benefits` | List of single-line text | Membership benefits |
| `free_delivery` | Boolean | Controls free-delivery presentation |
| `extra_variants` | List of product-variant references | Optional monitor, voucher, postage, or extras |
| `default_selected` | Boolean | Default selected offer |

The template must enforce the business rule that only annual and two-year plans may show free delivery, even if an offer record is accidentally configured with `free_delivery: true` for a monthly plan.

## 11. What must be removed from the UK port

The PDF identifies the following as unsafe for the reusable UK template: hard-coded warranty variant IDs, hard-coded selected variant IDs, product ID branches, handle comparisons, Stride-specific section filenames, hard-coded membership images, hard-coded membership prices and savings, hard-coded membership benefits, fixed gift IDs, fixed sold-out copy and URLs, fixed comparison rows, and fixed shipping exception IDs. [13]

Do not solve this by commenting out the old blocks. Remove or rewrite them so the old SKU logic cannot become active again. Use `product.selected_or_first_available_variant.id` for the current equipment variant and profile or membership-offer references for related variants.

The cart helper should add the current equipment variant, selected membership variant, optional warranty variant, and selected extras through one `/cart/add.js` request. No numeric product or membership variant IDs should appear in Liquid, JavaScript, or section settings.

## 12. Revised implementation sequence for UK

First, create the `product_template_profile`, `membership_offer`, specification-row, content-section, and comparison-row definitions. Next, create or identify the UK Premier products and their UK variants, prices, subscription configuration, tags, and merchandising data. Then attach a profile to at least two different UK equipment products and populate their membership-offer lists.

After that, create the neutral `product.dynamic` wrapper and the reusable section shells. Move the approved reference markup into those sections one section at a time. Implement the membership card renderer and cart helper from the profile data, while retaining the existing US `individual-product-selection` behavior only as a temporary compatibility reference if needed.

Finally, run the two-product test before publishing. Both products must use the same template, show the correct UK product-specific data, display the intended membership plans in the intended order, and produce the correct cart line items. Only after the schema and two-product test pass should the code be pushed live. [13]

## 13. Updated decision for the replication project

The earlier guide described how to reproduce the US membership list on UK PDPs. The UK PDF now establishes the more complete target: **do not create a collection of one-off UK templates**. Build one neutral product template and a profile-driven data layer. The US three-product Premier list remains the reference for the standard offer order and merchandising behavior, but UK product references, prices, subscriptions, shipping rules, content, and cart variants must be UK-specific.

No Shopify store was modified while integrating this PDF. This update is documentation and architecture guidance only.

## Additional reference

[13]: file:///home/ubuntu/upload/Correct_Solution_One_100%_Dynamic_Product_Template.pdf "User-provided UK context: Correct Solution One 100% Dynamic Product Template"


## 14. Complete US membership-card and selection behavior

The supplied `product-radio-option.liquid` file completes the US membership flow that was previously only described at the data-resolution level. `individual-product-selection` passes each referenced membership Product into this snippet as `related_product`. The snippet then renders the visible membership card and radio input.

The radio input uses `name="options"` and `class="individual-radio"`. For a membership Product reference, the selected cart item is identified through `related_product.variants[0].id`, which is written to `data-product-id`. The card also exposes `data-title`, `data-price`, `data-index`, and `data-value`. These attributes are consumed by the surrounding theme JavaScript. The Liquid file itself does not submit the cart request.

The default selection rules are dynamic. The first membership in the PDP reference list is checked by default, except when the cart already contains a yearly or two-year membership, in which case the radio matching the existing yearly variant is checked. A card may also receive a `selected` CSS class when the list contains one item, when the first plan has a `FREE` bonus while a monthly subscription is already in the cart, or when its variant matches the yearly item already in the cart.

The card presentation is also product-driven. The image comes from `related_product.featured_image`. The title uses `related_product.metafields.custom.alternate_title` when available, otherwise it falls back to `related_product.title`. The price is rendered from `related_product.price` when `show_price` is true. Savings badges use `badge_discount`, `badge_discount_2`, and `badge_best_price`. Supporting copy comes from `include_text`, and the right-side bonus amount comes from `badge_bonus`. When the relevant membership is already in the cart, the bonus area changes to `Already in cart` instead of showing another charge.

The option snippet also supports non-standard cases. For an outlet product, the displayed title becomes `Equipment Only`, the membership image is hidden, and the option index is shifted because the equipment-only choice is rendered before the membership choices. For a parent product with ordinary variant options, `data-product-id` can refer to the option Product Variant directly rather than to the first variant of a related Product.

The complete US membership flow is therefore:

```text
PDP custom.pdp_individual_product
  → referenced membership Products in list order
  → related_product.custom.pdp_badges_individual_product_json
  → individual-product-selection
  → product-radio-option
  → radio input and data-product-id/data-price/data-title attributes
  → surrounding theme JavaScript
  → cart request and membership/equipment line items
```

This proves that the US PDP is dynamic in the following sense: the equipment PDP stores references, the membership Product stores its own image/title/price and badge data, and the shared snippets render the cards. It is not fully dynamic in the stronger UK sense yet, because some cart and business logic still relies on Product tags, first-variant assumptions, and legacy client-side behavior.

## 15. How to translate this selector into the UK architecture

The UK renderer should preserve the proven US presentation and selection behavior while changing the data source. Instead of iterating directly over `product.metafields.custom.pdp_individual_product.value`, it should iterate over `profile.membership_offers`. Each offer should expose a direct Product variant reference through `offer.variant`, together with its title, image, price text, savings text, detail text, benefits, free-delivery flag, and default-selected state.

The equivalent UK radio data should use the offer's variant reference rather than `related_product.variants[0].id`. This removes the US assumption that the first available variant is always the correct membership item. The UK implementation should still expose equivalent data attributes, but it should derive them from the offer record and use the current product variant from Shopify for the equipment line item.

A UK-compatible renderer can follow this conceptual pattern:

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

The exact syntax may vary according to the UK metaobject definitions, but the architectural rule is fixed: the template must consume references and content records, not hard-coded numeric IDs. The cart helper should add the current equipment variant and the selected `offer.variant` through one cart operation, optionally adding `profile.warranty_variant` and `offer.extra_variants`.

The supplied US snippet therefore closes the documentation gap for the current US site, while the UK PDF defines the safer target implementation. The US flow should be preserved as a behavioral reference, not copied as a permanent collection of SKU-specific assumptions.

## 16. Updated scope and remaining optional evidence

The US membership presentation, metafield resolution, option rendering, default selection, cart-state labeling, and data attributes are now documented. The only remaining implementation file that could add further detail is the theme JavaScript handler that consumes `.individual-radio` and submits the cart request. It is not required to understand the Liquid data model, but it would be useful if the UK implementation needs a line-by-line reproduction of the exact current cart request and duplicate-membership rules.

No store changes were made while reviewing this file.

## Additional reference

[14]: file:///home/ubuntu/upload/pasted_content_4.txt "User-provided US product-radio-option Liquid snippet"

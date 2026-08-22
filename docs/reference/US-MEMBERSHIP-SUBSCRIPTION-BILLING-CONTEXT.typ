// US Membership Subscription Billing Context
// Professional report generated for Echelon Fit US and UK replication work.

#import "report-theme.typ": report-accent, report-theme

#show: report-theme.with(
  title: "US Membership Subscription Billing Context",
  author: "Manus AI",
  rhythm: "report",
  running-header: true,
)

// ---------- Title page ----------
#page(margin: (top: 30%, x: 2.2cm), numbering: none, header: none)[
  #set par(first-line-indent: 0em)
  #align(center)[
    #text(size: 26pt, weight: "bold", fill: report-accent)[US Membership Subscription Billing Context]
    #v(0.5em)
    #text(size: 14pt, fill: luma(80))[Echelon Fit dynamic PDP, subscription, and UK replication reference]
    #v(2em)
    #line(length: 40%, stroke: 0.5pt + luma(160))
    #v(2em)
    #text(size: 12pt)[
      Prepared by: Manus AI \
      Date: #datetime.today().display("[year]-[month]-[day]") \
      Scope: Read-only investigation and implementation context
    ]
  ]
]

// ---------- Table of contents ----------
#page(numbering: none, header: none)[
  #outline(title: [Contents], indent: 1.5em)
]

// ---------- Main body ----------
#counter(page).update(1)

= Executive summary

This document explains how membership presentation and recurring subscription billing are separated in the Echelon Fit US storefront. It is intended to give the UK implementation team enough context to reproduce the behavior without copying SKU-specific code.

The central fact is that the equipment product page does not own the membership prices, images, or plan titles. Instead, an equipment Product stores an ordered list of references to membership Products in the Product metafield `custom.pdp_individual_product`. Shared Liquid snippets resolve those Products and render membership cards. The subscription product configuration and its selling plan determine recurring billing. The PDP metafield determines which offers are shown, but it does not create a subscription contract by itself. [1] [2] [3]

The verified US flow is:

```text
Equipment PDP
  -> custom.pdp_individual_product
  -> referenced membership Product
  -> membership Product variant and merchandising metafields
  -> individual-product-selection
  -> product-radio-option
  -> radio data attributes
  -> theme JavaScript and cart request
  -> subscription selling plan
  -> checkout and recurring billing
```

#block(fill: luma(245), inset: 10pt)[
  *Key distinction.* The Product reference controls offer selection and presentation. The subscription integration and selling plan control recurring billing, renewal frequency, and subscription entitlement.
]

= Scope and evidence status

The US Product records, PDP metafield definition, equipment PDP references, Liquid snippets, tags, and membership card behavior were inspected in read-only mode. The UK context document was also reviewed as the target architecture for a neutral dynamic template. No Shopify store was modified during this work.

The exact JavaScript handler that consumes the radio data attributes was not provided. The exact subscription selling-plan IDs and the final cart payload used by the live US theme were therefore not confirmed line by line. This document distinguishes verified behavior from implementation details that still require direct inspection of the subscription app and theme JavaScript.

#table(
  columns: (1.5fr, 3.2fr, 1.5fr),
  inset: 6pt,
  stroke: 0.4pt + luma(205),
  fill: (col, row) => if row == 0 { luma(230) } else { none },
  [*Evidence area*], [*Confirmed finding*], [*Status*],
  [US Products], [Membership products, Product IDs, variants, prices, tags, and product type were inspected in Shopify Admin.], [Verified],
  [PDP metafield], [`custom.pdp_individual_product` is a `list.product_reference` definition.], [Verified],
  [Liquid selector], [`individual-product-selection` resolves referenced Products and passes merchandising data to `product-radio-option`.], [Verified],
  [Radio card], [`product-radio-option` renders radio inputs and exposes Product variant data attributes.], [Verified],
  [Recurring billing], [The subscription integration and selling plan are separate from PDP rendering.], [Verified at architecture level],
  [Exact cart JavaScript], [The handler that consumes the radio attributes was not supplied.], [Needs source inspection],
  [Exact selling-plan IDs], [The subscription plan IDs and complete cart payload were not inspected line by line.], [Needs app and theme inspection],
)

= US membership products

The inspected US membership products are ordinary Shopify Products with `productType: Subscription`. Their Products and variants provide the offer data that the PDP displays. Their subscription configuration provides the recurring purchase behavior.

#table(
  columns: (1.9fr, 1.7fr, 1.1fr, 1.2fr),
  inset: 5pt,
  stroke: 0.4pt + luma(205),
  fill: (col, row) => if row == 0 { luma(230) } else { none },
  [*Offer*], [*Product ID*], [*Variant ID*], [*Observed price*],
  [#text("Standard monthly Premier")], [`7696193355975`], [`43246953267399`], [$39.99],
  [#text("Standard yearly Premier")], [`4129967505490`], [`30135749771346`], [$399.99],
  [#text("Standard two-year Premier")], [`4815463809106`], [`32930539503698`], [$699.99],
  [#text("Promotional monthly with 30 days free")], [`8081808261319`], [`44236514427079`], [$0.00],
)

The standard equipment PDPs sampled during the investigation reference the standard monthly Product `7696193355975`, not the promotional `$0.00` Product `8081808261319`. The promotional Product has different tags and should not replace the standard monthly Product unless the relevant campaign is intentionally configured to do so.

The standard Products use tags such as `PremierSub`, `Monthly`, `Yearly`, `TwoYear`, `Subscription`, and `year`. These tags are used by Liquid to recognize cart state and membership type. They are not the source of the recurring billing schedule. The billing schedule comes from the subscription configuration and selling plan attached to the membership offer.

= PDP membership metafield

The confirmed Product metafield definition is:

#table(
  columns: (1.7fr, 3.2fr),
  inset: 6pt,
  stroke: 0.4pt + luma(205),
  fill: (col, row) => if row == 0 { luma(230) } else { none },
  [*Setting*], [*Value*],
  [Display name], [PDP individual product],
  [Namespace and key], [`custom.pdp_individual_product`],
  [Type], [`list.product_reference`],
  [Definition ID], [`gid://shopify/MetafieldDefinition/56523587783`],
  [Description], [Choose a fit pass for your product],
)

For the confirmed Stride 6S PDP, the stored list is:

```json
[
  "gid://shopify/Product/7696193355975",
  "gid://shopify/Product/4129967505490",
  "gid://shopify/Product/4815463809106"
]
```

The list order is meaningful. Position 0 is the normal default monthly plan, position 1 is yearly, and position 2 is two-year. The same ordered list was confirmed on sampled Stride, EX-5s, and EX-8s equipment PDPs. Other active product records returned a null value, which proves the relationship is assigned per PDP rather than automatically inherited by every equipment product. [4] [5]

= Liquid rendering flow

The main product section renders `product-template-individual`, passing the current Product, section blocks, gallery settings, thumbnail settings, video settings, and the context name `main-individual-product`.

```liquid
{%- render 'product-template-individual',
  product: product,
  section_id: section.id,
  blocks: section.blocks,
  image_container_width: section.settings.image_size,
  product_zoom_enable: section.settings.product_zoom_enable,
  thumbnail_position: section.settings.thumbnail_position,
  thumbnail_height: section.settings.thumbnail_height,
  thumbnail_arrows: section.settings.thumbnail_arrows,
  video_looping: section.settings.enable_video_looping,
  video_style: section.settings.product_video_style,
  context: 'main-individual-product',
-%}
```

The `individual_product` block calls `individual-product-selection`:

```liquid
{%- when 'individual_product' -%}
  {% render 'individual-product-selection',
    subInCart: subInCart,
    yearlyInCart: yearlyInCart,
    enable_addon_1: section.settings.enable_addon_1,
    enable_addon_2: section.settings.enable_addon_2
  %}
```

The membership selector first checks whether `product.metafields.custom.pdp_individual_product` is populated. If it is, it assigns the resolved Product objects to `product_list`:

```liquid
{% if product.metafields.custom.pdp_individual_product != blank %}
  {% assign membership = true %}
{% endif %}

{% assign product_list = product.metafields.custom.pdp_individual_product.value %}
```

For each `related_product`, the selector reads `custom.pdp_badges_individual_product_json`. The JSON properties include `discount`, `discount_2`, `best_price`, `bonus`, `include_text`, and `show_price`. These values are passed to `product-radio-option` together with the referenced Product.

#table(
  columns: (1.8fr, 3.2fr),
  inset: 6pt,
  stroke: 0.4pt + luma(205),
  fill: (col, row) => if row == 0 { luma(230) } else { none },
  [*Data source*], [*PDP result*],
  [`related_product.featured_image`], [Membership card image],
  [`custom.alternate_title`], [Short card title when present, otherwise Product title],
  [`related_product.price`], [Displayed price when `show_price` is true],
  [`discount` and `discount_2`], [Savings badges],
  [`best_price`], [Best-value badge],
  [`bonus`], [Bonus amount or `Already in cart` state],
  [`include_text`], [Supporting text under the card],
)

= Radio-card behavior

The `product-radio-option.liquid` snippet renders the visible card and radio input. It does not submit the cart request. The surrounding theme JavaScript consumes its data attributes.

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
  {% if index == 0 or outlet %}checked{% endif %}
>
```

The first membership in the PDP reference list is normally checked by default. If the cart already contains a yearly or two-year membership, the option matching the existing yearly variant is checked instead. The wrapper can receive a `selected` class for a single-option list, a free-bonus state, or a matching existing yearly membership.

The card title uses `related_product.metafields.custom.alternate_title` when present. Otherwise it uses `related_product.title`. The image is read from the membership Product's featured image. The price is read from the Product and shown only when `show_price` is true. If the relevant membership is already present in the cart, the right-side bonus area changes to `Already in cart`.

The outlet branch changes the title to `Equipment Only`, hides the membership image, and shifts the option index because an equipment-only option appears before the membership options.

= Subscription billing behavior

Subscription billing is handled by a separate layer from PDP membership presentation. The PDP field identifies which membership Products should be displayed. The membership Product and its subscription configuration identify the commercial offer. The selling plan identifies the recurring billing behavior.

The expected runtime sequence is:

```text
PDP metafield
  -> referenced membership Product
  -> selected membership Product variant
  -> selected subscription selling plan
  -> cart line item with selling-plan information
  -> checkout
  -> subscription contract and recurring renewal
```

The exact live US subscription integration was not fully traced because the provided Liquid snippets do not include the cart JavaScript handler or the subscription app's selling-plan records. The verified conclusions are:

1. The membership Products are Shopify Products with `productType: Subscription`.
2. The PDP metafield does not define the recurring interval.
3. Product tags such as `Monthly`, `Yearly`, and `TwoYear` help Liquid recognize cart state and prevent duplicate membership selection.
4. The radio snippet exposes the selected Product Variant ID and display values, but it does not itself submit a subscription cart line.
5. The theme JavaScript and subscription integration must connect the selected membership to its selling plan before checkout.
6. The exact selling-plan IDs and final cart payload must be inspected before reproducing the full US billing behavior in UK.

#block(fill: luma(245), inset: 10pt)[
  *Do not infer billing from tags.* A `Yearly` tag helps the theme recognize an existing yearly membership, but the tag is not the recurring billing mechanism. The subscription integration and selling plan remain the billing source of truth.
]

= Cart-state and duplicate-membership behavior

The US selector inspects `cart.items` and sets flags based on Product tags. A `Monthly` item sets `subInCart`. A `Yearly` or `TwoYear` item sets `yearly_in_cart` and stores the existing yearly variant. A `choice` item sets `choice_in_cart`. An `october_promo_bundle` item sets `equipment_in_cart`.

These flags alter the default selection, the card status, and the add-to-cart button. When a monthly or yearly membership is already in the cart, the button can switch from `individual-add-to-cart` to `add-product-only`, allowing equipment to be added without buying a second membership.

This is cart eligibility and presentation logic. It is separate from the subscription app's renewal, payment, and entitlement logic.

= US to UK replication guidance

The UK implementation should preserve the observed US presentation while using a safer data model. The target should be a neutral `product.dynamic` template with a `custom.template_profile` Product reference and a list of `membership_offer` records.

A UK membership offer should store the exact Product Variant reference, not rely on the first available variant:

```text
product
  -> custom.template_profile
  -> profile.membership_offers
  -> membership_offer.variant
  -> membership card
  -> dynamic cart helper
```

Each offer should contain a plan key, program, exact Product Variant reference, localized GBP display price, image, title, savings, detail text, benefits, free-delivery flag, extra variants, and default-selection flag. The template should enforce the business rule that only annual and two-year plans may show free delivery.

The cart helper should add the current equipment variant, selected membership variant, optional warranty variant, and configured extras through the intended UK cart API. The current equipment variant should come from `product.selected_or_first_available_variant.id`. The selected membership should come from `offer.variant`. Numeric US Product IDs and variant IDs must not be copied into UK Liquid, JavaScript, or section settings.

The UK schema should also cover product-specific specifications, experience sections, comparison rows, media, shipping status, financing, warranty, promotions, related collections, community, and safety. Missing data should hide a section or use a neutral fallback. It must never leak another SKU's content.

= UK implementation checklist

#table(
  columns: (2.3fr, 2.9fr),
  inset: 6pt,
  stroke: 0.4pt + luma(205),
  fill: (col, row) => if row == 0 { luma(230) } else { none },
  [*Implementation step*], [*Required result*],
  [Confirm UK membership Products], [Monthly, annual, and two-year UK Products and exact variants are identified with GBP pricing and subscription configuration.],
  [Create profile schema], [`product_template_profile` and `custom.template_profile` exist in UK.],
  [Create membership offers], [Each offer contains an exact Product Variant reference and UK-localized presentation data.],
  [Build neutral template], [`product.dynamic` owns neutral sections and does not contain SKU-specific branches.],
  [Implement membership renderer], [Renderer uses profile offers, preserves intended order, and emits cart data attributes.],
  [Implement cart helper], [Equipment and selected membership variants are added with the correct selling-plan information.],
  [Test two products], [Two different Products share the same template and produce correct content and cart line items.],
  [Validate checkout], [Correct UK variant, selling plan, price, currency, renewal behavior, and entitlement are confirmed.],
)

= Acceptance tests

The implementation is ready only after the following tests pass in an unpublished or preview UK theme.

#table(
  columns: (2.2fr, 2.8fr),
  inset: 6pt,
  stroke: 0.4pt + luma(205),
  fill: (col, row) => if row == 0 { luma(230) } else { none },
  [*Test*], [*Expected result*],
  [Standard equipment PDP], [Monthly, Yearly, and 2-Year plans render in intended order.],
  [Blank membership field], [No membership selector appears and normal product flow remains usable.],
  [Existing monthly membership], [Duplicate monthly purchase is suppressed or product-only behavior is used.],
  [Existing yearly or two-year membership], [Duplicate long-term membership behavior is explicit and correct.],
  [Selling plan selection], [Selected membership line contains the correct UK selling-plan information.],
  [Free delivery rule], [Only annual and two-year offers display free delivery.],
  [Two products, one template], [Each product shows its own profile data with no cross-SKU leakage.],
  [Checkout and renewal], [Correct UK price, currency, subscription creation, and renewal schedule are verified.],
  [Mobile and desktop], [Cards, radios, gallery, CTA, and checkout behavior work at both breakpoints.],
)

= Risks and operational notes

Changing a source membership Product, variant price, tags, badge JSON, selling plan, or subscription configuration can affect every PDP that references that Product. Before editing a source membership Product, identify all PDPs that reference it and record the current list order.

The standard monthly Product `7696193355975` and the promotional `$0.00` Product `8081808261319` are not interchangeable. Their tags and promotional semantics differ. Use the standard Product for normal PDPs and the promotional Product only where a campaign explicitly requires it.

The subscription integration is separate from the PDP display layer. A visually correct selector does not prove that a customer subscription contract, renewal, account entitlement, or subscription app synchronization is correct.

For a quote-style Product template, do not display a price unless the UK business rules explicitly authorize it. Use the quote workflow and profile settings instead of falling back to a normal product price.

= Source references

[1] #link("https://admin.shopify.com/store/echelon-store/products/7696193355975")[US Admin: Echelon Premier Monthly]

[2] #link("https://admin.shopify.com/store/echelon-store/products/4129967505490")[US Admin: Echelon Premier Yearly Plan]

[3] #link("https://admin.shopify.com/store/echelon-store/products/4815463809106")[US Admin: Echelon Premier 2-Year Plan]

[4] #link("https://admin.shopify.com/store/echelon-store/settings/custom_data/product/metafields/56523587783")[US Admin: PDP individual product metafield definition]

[5] #link("https://echelonfit.com/products/stride-6s")[Echelon Fit US: Stride 6S public PDP]

[6] #link("https://echelonfit.com/pages/membership")[Echelon Fit US: Membership page]

[7] #link("https://echelonfit.uk/pages/echelon-membership")[Echelon Fit UK: Membership page]

[8] #link("https://admin.shopify.com/store/echelon-store/themes/139674484935/editor?previewPath=%2Fproducts%2Fstride-8s%26section=template--17570151301319__main-individual-product")[Shopify Theme Editor: Stride 8S main-individual-product section]

[9] #link("file:///home/ubuntu/upload/Correct_Solution_One_100%_Dynamic_Product_Template.pdf")[User-provided UK PDF: Correct Solution One 100% Dynamic Product Template]

[10] #link("file:///home/ubuntu/upload/pasted_content.txt")[User-provided US product section source]

[11] #link("file:///home/ubuntu/upload/pasted_content_2.txt")[User-provided product-template-individual source]

[12] #link("file:///home/ubuntu/upload/pasted_content_3.txt")[User-provided individual-product-selection source]

[13] #link("file:///home/ubuntu/upload/pasted_content_4.txt")[User-provided product-radio-option source]

= Final handoff

The US storefront uses Product references and shared Liquid snippets to render membership choices. Product tags help the theme understand cart state, but recurring billing is controlled by the subscription Product's selling-plan configuration and the app or cart integration that attaches that plan before checkout.

For UK, preserve the verified US behavior as a presentation reference and implement the final system with a neutral `product.dynamic` template, `custom.template_profile`, explicit `membership_offer.variant` references, UK selling-plan configuration, and a tested dynamic cart helper. Do not publish until the exact selling-plan payload and subscription renewal behavior have been validated on at least two products.

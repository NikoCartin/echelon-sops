# Standard Operating Procedure: UK Dynamic Bike Product Template

**Document owner:** UK Ecommerce Development
**Author:** Manus AI
**Version:** 1.1
**Status:** Final and validated for the UK live theme
**Template:** `product.dynamic-bike`
**Theme:** Dev Mega Menu, theme ID `192726008183`
**Store:** `echelonfit-uk.myshopify.com`
**Last updated:** 19 August 2026

## 1. Purpose and operating principle

This SOP explains how the UK bike dynamic product template is built, how it obtains data, how its fixed bike presentation is maintained, how new bikes are added, and how future developers should edit and deploy it safely.

The template is **additive**. It does not replace `templates/product.liquid`, does not modify any existing SKU-specific product template and does not require deleting products or sections. A bike is assigned the template explicitly through Shopify Admin. Existing products remain on their current templates until their assignments are intentionally migrated.

The template deliberately combines two layers:

| Layer | Responsibility | Examples |
|---|---|---|
| Fixed bike layer | Preserves the approved shared presentation and bike-wide defaults | Section order, EX-7s-style layout, CSS classes, shared UK membership copy, shared Experience slides, fixed video, Community image wall, safety imagery and the `cart-accessories` collection |
| Dynamic PDP layer | Reads data belonging to the product assigned to the template | Product title, URL, native price, compare-at price, gallery, selected variant, description, Key Features specifications and product-linked reviews |

This is a **collection-level dynamic template**, not a SKU-specific template. The current implementation is for bikes. Future collections may receive their own additive templates, such as `product.dynamic-treadmill`, while following the same separation between fixed collection presentation and dynamic PDP data.

> **Core rule:** Keep universal bike presentation in the bike template. Keep product-specific facts in Shopify product data or approved UK product metafields. Never copy an individual SKU’s title, price, gallery or specifications into the shared bike template.

## 2. Scope and exclusions

This SOP covers the UK bike template only. It includes the product description and membership selector, fixed bike sections, review integration, product specifications, collection rendering, cart behavior, validation and deployment.

The following items are intentionally outside the current implementation:

| Excluded item | Treatment |
|---|---|
| Recurring billing | Not implemented in the template. Existing membership products are selected for presentation and cart variant selection only. |
| Shopify selling plans | Deferred. Do not add selling-plan logic while following this SOP. |
| US products and promotions | Excluded. Use UK products, UK prices, UK assets and UK promotion rules only. |
| Duplicate membership products | Prohibited. Use the existing UK Premier products. |
| Existing SKU templates | Do not delete or modify them. |
| `product.dynamic.json` or `product.dynamic-bike.json` | Do not create either JSON template. The current theme uses legacy Liquid templates. |
| Automatic publication | Not part of deployment. The CLI push updates theme code but does not publish the theme. |

Shopify’s theme architecture separates templates, sections and snippets, and Shopify’s metafield system is the approved way to add structured product data beyond the native product fields [1] [2] [3].

## 3. High-level rendering flow

The public entry point is `templates/product.dynamic-bike.liquid`. It renders fixed sections in the approved bike order, places a product-linked review anchor after the core product description, then renders shared popups and the cart helper.

```text
Shopify product assigned to product.dynamic-bike
                  |
                  v
     templates/product.dynamic-bike.liquid
                  |
     +------------+----------------+
     |                             |
     v                             v
Dynamic PDP section          Fixed bike sections
product description          EX-7s shared presentation
membership cards             UK bike defaults and assets
Key Features specifications
     |                             |
     +-------------+---------------+
                   |
                   v
       Product-linked Klaviyo reviews
                   |
                   v
        Dynamic cart helper and popups
```

The current public wrapper is intentionally ordered as follows:

| Order | Template output | Primary role |
|---:|---|---|
| 1 | `dynamic-product-description` | Native product PDP, gallery, price, membership cards and CTA |
| 2 | `dynamic-membership-upgrade` | Shared membership upgrade presentation |
| 3 | `dynamic-product-specifications` | Product description Key Features rendered in the fixed specifications layout |
| 4 | Klaviyo review anchor | Real reviews keyed to the current `product.id` |
| 5 | `dynamic-experience` | Fixed EX-7s bike Experience slides |
| 6 | `dynamic-product-experience` | Fixed Product Experience CTA and bike feature copy |
| 7 | `dynamic-feature-slider` | Fixed EX-7s bike feature slider |
| 8 | `dynamic-full-width-video` | Fixed bike banner and video popup |
| 9 | `dynamic-memberships` | Shared UK membership benefits section |
| 10 | `dynamic-derisk-section` | Shared reassurance and warranty presentation |
| 11 | `dynamic-financing-cta` | Shared bike financing presentation |
| 12 | `dynamic-more-than-membership` | Shared membership-value section and EX-7s image |
| 13 | `dynamic-featured-collection` | Real `cart-accessories` collection grid |
| 14 | `dynamic-community` | Fixed seven-image community wall and UK social copy |
| 15 | `dynamic-safety` | Shared safety presentation and fixed UK image |
| 16 | `dynamic-upgrade-stripped` | Membership upgrade popup |
| 17 | `dynamic-membership-plans` | Membership comparison popup |
| 18 | `dynamic-cart-helper` | Cart add/remove logic for equipment, membership, warranty and extras |

The global navigation, Mega Menu, cart drawer, footer and other global theme components are not part of the product template upload.

## 4. Complete component inventory

### 4.1 Template entry point

| File | Function | Edit policy |
|---|---|---|
| `templates/product.dynamic-bike.liquid` | Public bike template entry point and section order | Edit only when changing the bike template architecture or section sequence. Do not add SKU-specific values. |

The older `product.dynamic` file remains a compatibility path from earlier work. New UK bikes should use `product.dynamic-bike`. Do not create a JSON template beside either Liquid template.

### 4.2 Dynamic and fixed sections

| File | What it renders | Data boundary |
|---|---|---|
| `sections/dynamic-product-description.liquid` | Product gallery, native price, product description, Premier membership cards, payment row and primary CTA | Dynamic product data and existing UK membership product references |
| `sections/dynamic-membership-upgrade.liquid` | Shared membership upgrade module | Shared bike presentation, optional product context |
| `sections/dynamic-product-specifications.liquid` | Two-column Product Specifications section | Dynamic from the product Description `Key Features:` list, with UK metafield fallback |
| `sections/dynamic-experience.liquid` | Experience module wrapper | Fixed bike content supplied by `dynamic-bike-experience` |
| `sections/dynamic-product-experience.liquid` | Product Experience CTA | Fixed bike presentation and shared bike feature defaults |
| `sections/dynamic-feature-slider.liquid` | Feature slider wrapper | Fixed bike content supplied by `dynamic-bike-feature-slider` |
| `sections/dynamic-full-width-video.liquid` | Full-width image banner and video popup | Fixed bike image, heading and video reference |
| `sections/dynamic-memberships.liquid` | Membership benefits and navigation | Shared UK bike membership presentation |
| `sections/dynamic-derisk-section.liquid` | Reassurance, warranty and risk-reduction content | Shared bike defaults |
| `sections/dynamic-financing-cta.liquid` | Financing call-to-action | Shared bike financing defaults and fixed bike image |
| `sections/dynamic-more-than-membership.liquid` | Membership value section | Shared bike copy and exact EX-7s reference image |
| `sections/dynamic-featured-collection.liquid` | Featured collection section wrapper | Fixed bike collection behavior |
| `sections/dynamic-community.liquid` | Community section wrapper | Fixed seven-image UK bike wall |
| `sections/dynamic-safety.liquid` | Safety section | Shared bike safety presentation and fixed UK image |

### 4.3 Dynamic and fixed snippets

| File | Function | Edit policy |
|---|---|---|
| `snippets/dynamic-product-description-v3.liquid` | Preserved reference-style markup for gallery, membership cards, payment row and CTA | Edit only for shared card markup or UI behavior. Do not hardcode a SKU. |
| `snippets/dynamic-cart-helper.liquid` | Removes an existing membership line and adds the selected equipment, membership, warranty and extras | Edit only when changing cart behavior. Test every membership plan after edits. |
| `snippets/dynamic-membership-plans.liquid` | Membership comparison popup | Keep shared UK membership presentation aligned with the main cards. |
| `snippets/dynamic-upgrade-stripped.liquid` | Membership upgrade popup | Keep shared bike popup structure. |
| `snippets/dynamic-bike-experience.liquid` | Four fixed EX-7s Experience slides and UK assets | Edit only for an intentional bike-collection-wide content or asset update. |
| `snippets/dynamic-bike-feature-slider.liquid` | Three fixed EX-7s feature slides and UK assets | Edit only for an intentional bike-collection-wide content or asset update. |
| `snippets/dynamic-bike-featured-collection.liquid` | Render-safe real-product grid for `cart-accessories` | Do not restore the legacy `include` chain. The direct grid prevents Liquid include errors and placeholder onboarding. |
| `snippets/dynamic-bike-community.liquid` | Seven fixed community images and shared UK social content | Edit only for a bike-wide asset or social-content update. |
| `snippets/cargo-cta-section.liquid` | Shared existing CTA renderer with fixed-bike image support | Preserve compatibility with other templates. |
| `snippets/cargo-financing-output.liquid` | Shared existing financing renderer with fixed-bike image support | Preserve compatibility with other templates. |
| `snippets/cargo-full-width-banner-output.liquid` | Shared full-width renderer with fixed-bike image support | Preserve compatibility with other templates. |
| `snippets/cargo-safety-output.liquid` | Shared safety renderer with fixed-bike image support | Preserve compatibility with other templates. |

The package may contain older analysis files and compatibility files that are not referenced by `product.dynamic-bike`. Do not upload unrelated analysis scripts or deprecated template files unless the deployment plan explicitly requires them.

## 5. Dynamic product data model

### 5.1 Native Shopify product data

The template reads the following from the product assigned to it:

| Native field | Used by |
|---|---|
| `product.title` | Product title and related product output |
| `product.url` | CTA and product links |
| `product.images` and `product.featured_image` | Main gallery and fallback media |
| `product.selected_or_first_available_variant` | Native price, selected variant and cart equipment variant |
| `product.price` and `product.compare_at_price` | Price display and sale logic |
| `product.description` | Main description and Key Features specification parser |
| `product.id` | Real product-linked review anchor |
| `product.available` | Availability and Sold Out behavior |

A new bike should be completed in Shopify Admin first. The title, price, media and description should be accurate in the native product record before any template troubleshooting begins.

### 5.2 UK product metafields

Use metafields only when the value is product-specific and cannot be represented safely by native Shopify product data. The current implementation supports the following keys and fallback patterns:

| Namespace and key | Purpose | Typical value |
|---|---|---|
| `custom.product_description_override` | Optional replacement description | Rich text or HTML string |
| `custom.header_price` | Optional product header price override | UK price string |
| `custom.banner_heading` | Optional product banner heading | Text |
| `custom.banner_price` | Optional product banner price | UK price string |
| `custom.monthly_price` | Optional payment-row monthly value | UK price string |
| `custom.klarna_price` | Optional payment-row value | UK price string |
| `custom.shipping_status` | Product shipping state override | `shipsNow` or `delayed` |
| `custom.shipping_date` | Delayed shipping date | Date or text |
| `custom.membership_program` | Membership mode | `premier` |
| `custom.default_membership` | Default selected membership | `monthly`, `annual` or `twoyear` |
| `custom.membership_products` | Ordered product-reference list | Monthly, 1-Year, 2-Year |
| `custom.membership_monthly_variant_id` | Optional monthly variant override | Variant ID |
| `custom.membership_annual_variant_id` | Optional 1-Year variant override | Variant ID |
| `custom.membership_two_year_variant_id` | Optional 2-Year variant override | Variant ID |
| `custom.membership_monthly_badge` | Optional monthly badge override | `Save £29.99` |
| `custom.membership_annual_badge` | Optional 1-Year badge override | `Save £60` |
| `custom.membership_two_year_badge` | Optional 2-Year badge override | `Save £240` |
| `custom.membership_monthly_savings` | Optional monthly savings suffix | `(1 mo. free)` |
| `custom.membership_annual_savings` | Optional 1-Year savings suffix | `(2 mo. free)` |
| `custom.membership_two_year_savings` | Optional 2-Year savings suffix | `(4 mo. free)` |
| `custom.membership_monthly_detail` | Optional monthly subcopy | `£29.99/mo after 30 Days. Cancel anytime` |
| `custom.membership_annual_detail` | Optional 1-Year benefit subcopy | `FREE Heart Rate Monitor (worth £119.99)` |
| `custom.membership_two_year_detail` | Optional 2-Year benefit subcopy | `FREE Heart Rate Monitor + Free £50 Gift Voucher` |
| `custom.warranty_variant_id` | Optional warranty variant | Variant ID |
| `custom.monthly_extra_variant_ids` | Monthly extras | Comma-separated variant IDs |
| `custom.annual_extra_variant_ids` | 1-Year extras | Comma-separated variant IDs |
| `custom.two_year_extra_variant_ids` | 2-Year extras | Comma-separated variant IDs |
| `custom.free_postage_variant_id` | Optional postage variant | Variant ID |
| `custom.heart_rate_monitor_variant_id` | Optional monitor variant | Variant ID |
| `custom.gift_voucher_variant_id` | Optional voucher variant | Variant ID |
| `custom.template_profile` | Fallback profile object | Profile JSON or structured metafield |
| `custom.product_specifications` | Fallback specification list | Structured list |
| `custom.pdp_product_specs` | Fallback specification list | Structured list |

Use **variant IDs**, not product IDs, for cart and extra-item fields. Do not put US IDs, US prices or US promotion logic in any UK product metafield.

### 5.3 Membership product source and delivery rules

The existing UK Premier products are the source of membership images, prices and variant IDs when they are referenced by `custom.membership_products` or selected through the section settings. They must not be duplicated.

| Plan | Existing handle | Current UK price | Free delivery |
|---|---|---:|---|
| Monthly | `uk-premier-monthly` | £29.99 per month after the first 30 days | Hidden |
| 1-Year | `uk-premier-yearly` | £299.90 | Visible |
| 2-Year | `uk-premier-2-year` | £479.76 | Visible |

The main Premier card presentation is:

| Plan | Card price area | Card detail |
|---|---|---|
| Monthly Access | `Free` introductory display | `£29.99/mo after 30 Days. Cancel anytime` |
| 1-Year Access | `+ £299.90` | `FREE Heart Rate Monitor (worth £119.99)` |
| 2-Year Access | `+ £479.76` | `FREE Heart Rate Monitor + Free £50 Gift Voucher` |

The monthly plan is not free after the introductory period. The word `Free` is only the initial offer display. The annual and two-year plans show their full UK charges and the free-delivery badge. The JavaScript delivery logic must continue to qualify only `annual`, `twoyear` and the appropriate annual Choice value.

## 6. Product Specifications workflow

### 6.1 Required product-description format

The preferred source for bike specifications is the native Shopify product Description field. Use a heading such as `Key Features:` followed by a standard unordered list. Each list item should contain a bold label, a separator and supporting text.

```html
<p><strong>Key Features:</strong></p>
<ul>
  <li><strong>24&quot; HD Touchscreen with 180° Flip Rotation</strong> - Stream live and on-demand classes solo, or flip the screen to lead group training sessions</li>
  <li><strong>Magnetic Coil Resistance System</strong> - Smooth, quiet, low-maintenance resistance built for constant use</li>
  <li><strong>Quick-Adjust Seat &amp; Handlebars</strong> - Fast, tool-free adjustments make it easy to switch between riders</li>
  <li><strong>Power Ports</strong> - Keep devices charged and ready to go</li>
</ul>
```

### 6.2 Parser behavior

The specifications section locates the `Key Features:` heading, finds the following unordered list and reconstructs each list item’s inner HTML before stripping tags. This prevents HTML attributes such as `class="font-claude-response-body"` from appearing as visible specification labels. The bold label is preserved as the left-hand label and the supporting text is rendered as the right-hand value in the existing two-column EX-7s layout.

If the description does not contain a usable Key Features list, the section falls back to the approved UK specification profile or specification metafield list. A new bike should still use the native description format whenever possible because it keeps the PDP description and the specification section aligned.

### 6.3 Specification editing procedure

To change a bike’s specifications, edit the native product Description in Shopify Admin. Do not edit the shared Liquid section for a single SKU. Preserve the `Key Features:` heading, use a real `<ul>` list and keep each feature in one `<li>`. Put the feature name in `<strong>` and separate it from the explanation with a hyphen or en dash.

After saving the product, preview the product with `product.dynamic-bike` and confirm that every feature appears exactly once in the specification section. If the page shows HTML attributes, confirm that the current live `dynamic-product-specifications.liquid` matches the validated source and that the product description contains a valid list structure.

## 7. Editing procedure by change type

### 7.1 Change one bike’s PDP information

Use Shopify Admin product editing. Update the product title, native price, compare-at price, media, description and variants. Add or update only the necessary UK product metafields. Do not edit the Liquid template for a one-product change.

### 7.2 Change membership references for one product

Set `custom.membership_products` as an ordered list of three product references: Monthly first, 1-Year second and 2-Year third. Verify that the referenced products are the existing UK Premier products. If the list is empty, the section settings and UK handle fallbacks are used.

### 7.3 Change a shared bike section for every bike

Edit the relevant fixed section or fixed bike snippet. For example, edit `dynamic-bike-community.liquid` to replace a shared community image or edit `dynamic-bike-feature-slider.liquid` to change the shared bike slides. Do not put a product title, product price or SKU-specific image into a shared file.

### 7.4 Change shared membership presentation

Edit the membership section or `dynamic-product-description-v3.liquid` only when the card geometry, shared labels, badge treatment or delivery behavior must change for all bikes. Keep product prices and variant IDs product-driven. Preserve the rule that monthly does not show free delivery.

### 7.5 Change the fixed accessories collection

The current bike collection is `cart-accessories`. The render-safe bike snippet directly loops through real products in that collection. Do not restore `{% include 'product-loop' %}` or any nested legacy include chain inside this dynamic snippet. If the collection changes for all bikes, update the `settingCollection` value and test that the collection exists and contains real products.

### 7.6 Create another collection-specific template

Copy the additive architecture into a new file such as `templates/product.dynamic-treadmill.liquid`. Keep the product data layer and cart rules consistent, then replace only the fixed collection-specific sections, assets, copy and defaults. Use a separate prefix for collection-specific snippets, such as `dynamic-treadmill-experience.liquid`. Do not modify `product.liquid` or existing SKU templates.

## 8. Manual installation procedure

Manual installation is appropriate when the CLI is unavailable. In Shopify Admin, open **Online Store > Themes > Edit code** for the intended theme. Add each file to the exact folder shown in the package manifest. Add sections and snippets first, then add `templates/product.dynamic-bike.liquid` last. Do not create a JSON template and do not overwrite `templates/product.liquid`.

The complete additive file set for the current bike implementation is:

| Folder | Files |
|---|---|
| `templates` | `product.dynamic-bike.liquid` |
| `sections` | `dynamic-product-description.liquid`, `dynamic-membership-upgrade.liquid`, `dynamic-product-specifications.liquid`, `dynamic-experience.liquid`, `dynamic-product-experience.liquid`, `dynamic-feature-slider.liquid`, `dynamic-full-width-video.liquid`, `dynamic-memberships.liquid`, `dynamic-derisk-section.liquid`, `dynamic-financing-cta.liquid`, `dynamic-more-than-membership.liquid`, `dynamic-featured-collection.liquid`, `dynamic-community.liquid`, `dynamic-safety.liquid` |
| `snippets` | `dynamic-product-description-v3.liquid`, `dynamic-cart-helper.liquid`, `dynamic-membership-plans.liquid`, `dynamic-upgrade-stripped.liquid`, `dynamic-bike-experience.liquid`, `dynamic-bike-feature-slider.liquid`, `dynamic-bike-featured-collection.liquid`, `dynamic-bike-community.liquid`, `cargo-cta-section.liquid`, `cargo-financing-output.liquid`, `cargo-full-width-banner-output.liquid`, `cargo-safety-output.liquid` |

After saving the files, assign `product.dynamic-bike` to a test bike product through the product’s **Online store > Theme template** field. Preview the product in the Theme Editor and test it before migrating additional products.

## 9. Shopify CLI deployment procedure

The verified CLI target is the live UK theme `Dev Mega Menu`, ID `192726008183`. Use the authenticated account that has access to **Online Store > Themes > Edit code**. Always confirm the target store and theme before pushing.

### 9.1 Read-only access check

```bash
shopify theme list \
  --store echelonfit-uk.myshopify.com
```

Confirm that `Dev Mega Menu` appears as the live theme with ID `192726008183`.

### 9.2 Pull a backup or verification copy

```bash
rm -rf /home/ubuntu/live-bike-backup
mkdir -p /home/ubuntu/live-bike-backup
shopify theme pull \
  --store echelonfit-uk.myshopify.com \
  --theme 192726008183 \
  --path /home/ubuntu/live-bike-backup \
  --nodelete
```

Do not overwrite the local source tree with the pull unless intentionally refreshing the source. Keep a dated backup when making a production change.

### 9.3 Validate before push

From `/home/ubuntu/uk-theme-work`, run:

```bash
python3 validate_neutral_template.py
```

A valid result must include:

```text
dynamic_sections:17
dynamic_snippets:10
schemas:ok
section_and_snippet_references:ok
liquid_balance:ok
sku_neutrality:ok
```

The validator checks structural references, schemas, Liquid block balance and SKU neutrality. It does not replace visual browser testing.

### 9.4 Push only intended files

For a membership-card or Featured Collection fix, push only the affected files:

```bash
shopify theme push \
  --store echelonfit-uk.myshopify.com \
  --theme 192726008183 \
  --path /home/ubuntu/uk-theme-work \
  --allow-live \
  --nodelete \
  --only sections/dynamic-product-description.liquid \
  --only snippets/dynamic-product-description-v3.liquid \
  --only snippets/dynamic-bike-featured-collection.liquid
```

For a fixed community or experience change, replace the `--only` paths with the exact affected section and snippet files. Keep `--nodelete` enabled. Do not use a full push when a limited push is sufficient.

### 9.5 Verify the deployed source

```bash
rm -rf /home/ubuntu/live-bike-verify
mkdir -p /home/ubuntu/live-bike-verify
shopify theme pull \
  --store echelonfit-uk.myshopify.com \
  --theme 192726008183 \
  --path /home/ubuntu/live-bike-verify \
  --nodelete \
  --only sections/dynamic-product-description.liquid \
  --only snippets/dynamic-product-description-v3.liquid \
  --only snippets/dynamic-bike-featured-collection.liquid

cmp -s sections/dynamic-product-description.liquid \
  /home/ubuntu/live-bike-verify/sections/dynamic-product-description.liquid
cmp -s snippets/dynamic-product-description-v3.liquid \
  /home/ubuntu/live-bike-verify/snippets/dynamic-product-description-v3.liquid
cmp -s snippets/dynamic-bike-featured-collection.liquid \
  /home/ubuntu/live-bike-verify/snippets/dynamic-bike-featured-collection.liquid
```

A successful `cmp` produces no output and exits with code zero. Record the checksum when a change is important:

```bash
sha256sum \
  /home/ubuntu/live-bike-verify/sections/dynamic-product-description.liquid \
  /home/ubuntu/live-bike-verify/snippets/dynamic-product-description-v3.liquid \
  /home/ubuntu/live-bike-verify/snippets/dynamic-bike-featured-collection.liquid
```

## 10. Testing and acceptance checklist

A change is complete only after both structural validation and product-page testing succeed.

| Test area | Acceptance condition |
|---|---|
| Template assignment | A test bike uses `product.dynamic-bike`; existing SKU templates are unchanged. |
| Product title | The title changes when a second bike is assigned to the same template. |
| Native price | The current bike’s native price appears without an incorrect SKU default. |
| Gallery | The current product gallery appears and does not show an EX-7-only gallery. |
| Description | The native product description appears unless an intentional override is configured. |
| Specifications | `Key Features:` list items appear as clean two-column rows with no leaked HTML attributes. |
| Monthly membership | Shows introductory `Free` display, then `£29.99/mo after 30 Days. Cancel anytime`. |
| Annual membership | Shows `+ £299.90`, the correct benefits and `FREE DELIVERY`. |
| Two-year membership | Shows `+ £479.76`, the correct benefits and `FREE DELIVERY`. |
| Delivery logic | Monthly has no free-delivery badge or banner. Annual and two-year do. |
| Membership images | Existing UK Premier product images or approved UK asset fallbacks appear. |
| Membership variants | Radio controls carry valid variant IDs and the cart helper adds the selected plan. |
| Reviews | The Klaviyo review integration is keyed to the current `product.id` and shows real product-linked reviews. |
| Experience | Four fixed EX-7s bike slides appear with their UK assets. |
| Product Experience | The fixed bike CTA image, heading and feature list appear. |
| Feature Slider | Three fixed EX-7s bike slides appear with their UK assets. |
| Full-width video | The fixed bike banner and video popup display correctly. |
| Featured Collection | Real products from `cart-accessories` render without a Liquid include error or onboarding placeholders. |
| Community | Seven fixed UK bike community images appear. |
| More Than a Membership | The exact shared EX-7s image appears. |
| Safety | The fixed UK bike safety asset appears. |
| Mobile layout | Cards, gallery, popups, membership selector and fixed sections work on mobile. |
| Cart behavior | Equipment, membership, warranty and configured extras are added correctly. |
| Sold Out behavior | Unavailable products display their unavailable state and do not offer an invalid purchase action. |

Test at least two different UK bikes. The title, price, gallery, description and specifications must change with the bike. Shared bike sections should remain the same unless the change was intentionally made at the collection level.

## 11. Troubleshooting guide

| Symptom | Likely cause | Corrective action |
|---|---|---|
| Monthly card says only `Free` | Monthly detail or price binding was not deployed, or the old snippet is still active | Confirm the live section and snippet match the validated files. Monthly must show `£29.99/mo after 30 Days. Cancel anytime`. |
| Monthly card has a free-delivery badge | Delivery JavaScript or markup was changed incorrectly | Confirm that only annual, two-year and the correct annual Choice value qualify. |
| Annual or two-year price is blank | Membership product reference or fallback is missing | Confirm `custom.membership_products` order and the existing UK Premier product handles. |
| Membership cards are absent | Product is delayed or membership program is not Premier | Check `custom.shipping_status`, `custom.membership_program` and the section settings. |
| Specifications show CSS attributes | The list item was split before its inner HTML was reconstructed | Redeploy the validated `dynamic-product-specifications.liquid` and confirm the product description uses a valid `<ul>` list. |
| Specifications are empty | The description lacks `Key Features:` and no fallback specification metafield exists | Add the native Key Features list or populate the approved UK specification fallback. |
| Featured Collection shows a Liquid `include` error | A legacy `product-loop` include chain is still present | Redeploy `dynamic-bike-featured-collection.liquid`. Do not restore the legacy include. |
| Featured Collection shows placeholders | The collection handle is blank, wrong or the old onboarding renderer is active | Confirm `cart-accessories` exists and the direct real-product grid is deployed. |
| Community or Experience images are missing | Fixed bike snippet or asset reference is missing | Compare the relevant `dynamic-bike-*` snippet with the validated source. |
| Video is missing | Fixed banner section or video reference is missing | Compare `dynamic-full-width-video.liquid` and `cargo-full-width-banner-output.liquid`. |
| Reviews are missing or show the wrong product | Review provider anchor is missing or not keyed to `product.id` | Confirm `<div id="klaviyo-reviews-all" data-id="{{ product.id }}"></div>` remains in the wrapper. |
| A new bike still shows the old page | The product was not assigned `product.dynamic-bike` or the preview is using another template | Check the product’s Theme template field and preview URL. |
| Shopify CLI asks for login | The CLI session expired | Run `shopify auth login`, approve the device code, then verify with `shopify theme list`. |
| Shopify CLI lists themes but push fails | Account can read themes but lacks theme-code write access | Use an account with Online Store theme Edit code permission. Do not assume product or metafield permissions grant theme write access. |
| Push changes unrelated files | A full push or missing `--only` restriction was used | Restore the backup and use a limited push with `--nodelete` and explicit `--only` paths. |
| Shopify reports a schema error | A section setting violates Shopify schema rules, such as a name-length limit | Fix the schema locally, run the validator and retry the limited push. |

## 12. Rollback procedure

If a deployment introduces a Liquid, schema or visual regression, stop assigning the template to additional products. First identify the affected file from the browser error or the deployment manifest. Restore the previous version of only that file from the dated CLI pull, local Git/source backup or Shopify theme version history. Run the validator again, push only the reverted file with `--nodelete`, and re-test the affected product.

Do not delete existing SKU templates as part of rollback. Do not replace `templates/product.liquid`. Keep the additive bike template available for later testing unless the entire template is intentionally withdrawn.

A safe rollback pattern is:

```bash
cp /home/ubuntu/live-bike-backup/sections/<affected-file>.liquid \
  /home/ubuntu/uk-theme-work/sections/<affected-file>.liquid

python3 /home/ubuntu/uk-theme-work/validate_neutral_template.py

shopify theme push \
  --store echelonfit-uk.myshopify.com \
  --theme 192726008183 \
  --path /home/ubuntu/uk-theme-work \
  --allow-live \
  --nodelete \
  --only sections/<affected-file>.liquid
```

## 13. Change-control rules

Every shared bike change should be reviewed as a collection-level change because it affects every product assigned to `product.dynamic-bike`. Every product-specific change should be made in the Shopify product record or its approved UK metafields. The developer should record the changed files, validator output, target theme ID and post-push verification result.

Before deployment, confirm that the change does not introduce a Stride, Summit, EX-7s-only product title, product ID, variant ID or US promotion. Shared EX-7s assets are allowed where they are the intentional fixed bike presentation reference. SKU-specific PDP information is not allowed in shared template code.

## 14. Current validated state

The current implementation has been validated with the following checks:

```text
dynamic_sections:17
dynamic_snippets:10
schemas:ok
section_and_snippet_references:ok
liquid_balance:ok
sku_neutrality:ok
```

The live theme currently contains the additive bike template and the corrected membership and Featured Collection files. The latest fixes were pushed only to the three affected files:

```text
sections/dynamic-product-description.liquid
snippets/dynamic-product-description-v3.liquid
snippets/dynamic-bike-featured-collection.liquid
```

The live source was pulled back and compared byte-for-byte with the local validated source after deployment. The public EX-PRO page was also checked with a cache-busting query. The Accessories section rendered real products from `cart-accessories` with images, prices and Add to Cart buttons, and no Liquid error.

## References

[1]: https://help.shopify.com/en/manual/online-store/themes/theme-structure/templates "Shopify Help Center: Templates"

[2]: https://help.shopify.com/en/manual/online-store/themes/theme-structure/sections "Shopify Help Center: Sections"

[3]: https://help.shopify.com/en/manual/custom-data/metafields "Shopify Help Center: Metafields"

[4]: https://help.shopify.com/en/manual/online-store/themes/customizing-themes/edit-code/edit-theme-code "Shopify Help Center: Editing theme code"

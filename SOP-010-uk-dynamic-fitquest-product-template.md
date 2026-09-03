# SOP-010: UK Dynamic FitQuest Product Template

**Document owner:** UK Ecommerce Development  
**Author:** Nicolas Cartin Reyes<br>
**Audience:** Internal Echelon developers, Shopify administrators and technical operators<br>
**Version:** 1.0  
**Status:** Final and validated against the UK live storefront  
**Template:** `product.dynamic-fitquest`  
**Store:** `echelonfit-uk.myshopify.com`  
**Storefront:** [echelonfit.uk](https://echelonfit.uk/)  
**Last verified:** 3 September 2026  
**Last verified live theme:** `Copy of Dev Mega Menu`, theme ID `193430749559`

## 1. Purpose

This SOP explains how to maintain the UK FitQuest dynamic product template, how to add a new FitQuest product, how product data is rendered, how the membership selector is restricted to elliptical products, how the single purchase action works, and how to deploy a narrowly scoped change safely.

The template is a native Shopify Liquid implementation. It uses a legacy Liquid product template, reusable Liquid sections, native Shopify product data, lightweight CSS and vanilla JavaScript. It does not use React, an external frontend bundle or an app frontend.

Shopify describes a template as the component that controls what is displayed on a page and sections as reusable, customizable modules. Shopify also documents that theme features can be implemented with Liquid, CSS and JavaScript [1]. This SOP follows that architecture and keeps the FitQuest behavior inside the FitQuest template files only.

> **Core operating rule:** Product-specific PDP facts come from the current Shopify product and variant. FitQuest-wide presentation remains in the FitQuest sections. Do not hardcode a product title, SKU, price, product URL, product ID or variant ID into reusable FitQuest Liquid.

## 2. Scope and exclusions

This SOP covers the UK `product.dynamic-fitquest` template and the FitQuest sections that it renders. It includes product setup, membership presentation, the single purchase action, validation, live deployment and rollback.

| Included | Excluded |
|---|---|
| `product.dynamic-fitquest` template assignment | `product.dynamic-bike` and all bike remediation work |
| FitQuest product gallery, title, price, variants and description | Shared layouts, global CSS, global JavaScript and theme settings |
| FitQuest discount card and modal | Product creation, deletion, status changes or channel publication through this SOP |
| Membership cards for elliptical products | Hardcoded SKU-specific Liquid or fixed variant IDs |
| Native form submission and combined cart request | React bundles, app frontends and external checkout implementations |
| Product-specific specifications and related products | Creating another theme copy or publishing a theme |

The discount card and its modal are separate from the membership eligibility rule. Do not remove or gate the discount card when changing the membership condition unless that change is separately approved.

## 3. Current implementation summary

The public entry point is `templates/product.dynamic-fitquest.liquid`. It renders the FitQuest product section, FitQuest offers section, specifications section, brand story and related products. A product receives this layout only when Shopify Admin assigns the `product.dynamic-fitquest` template to it.

| File | Responsibility | Edit policy |
|---|---|---|
| `templates/product.dynamic-fitquest.liquid` | FitQuest section order and product-linked review anchor | Edit only when changing the FitQuest section architecture or order |
| `sections/fitquest-dynamic-product.liquid` | Native product form, gallery, title, price, variant selector, description and one submit button | Keep product data dynamic and preserve the native form |
| `sections/fitquest-dynamic-offers.liquid` | Discount card and modal, membership cards and modal, elliptical-only eligibility and combined cart behavior | Change only for FitQuest offer or membership behavior |
| `sections/fitquest-dynamic-specifications.liquid` | Product description and Key Features rendering | Keep specifications sourced from the current product description |
| `sections/fitquest-dynamic-brand-story.liquid` | Shared FitQuest brand story | Do not add product-specific facts here |
| `sections/fitquest-dynamic-related-products.liquid` | Related FitQuest product presentation | Keep product links and values dynamic |

The live correction documented in this SOP changed only `sections/fitquest-dynamic-offers.liquid`. No layout, asset, settings, product assignment or unrelated template was changed.

## 4. Rendering flow

The rendering flow is intentionally additive:

```text
Shopify product assigned to product.dynamic-fitquest
                         |
                         v
       templates/product.dynamic-fitquest.liquid
                         |
          +--------------+---------------+
          |                              |
          v                              v
fitquest-dynamic-product        fitquest-dynamic-offers
native product form             discount card and modal
one native submit button        membership block when eligible
          |                              |
          +--------------+---------------+
                         v
              specifications, brand story
                 and related products
```

The product section renders the native form with the current selected or first available variant. The offers section is then moved into the product form's offers slot by the wrapper script. On eligible elliptical products, the offers section contains the membership cards and radios. The native submit handler reads the current product variant and the checked membership radio at submit time.

## 5. Product data boundary

### 5.1 Native product data

The template should use native Shopify product data wherever possible.

| Native field | Usage |
|---|---|
| `product.title` | Product title and the current elliptical eligibility rule |
| `product.url` | Product links and related product navigation |
| `product.media` and `product.featured_media` | Product gallery and media fallback |
| `product.selected_or_first_available_variant` | Current price, availability and equipment variant |
| `product.variants` | Variant selector and dynamic variant options |
| `product.description` | Main description and specifications source |
| `product.id` | Product-linked review anchor |
| `product.available` | Availability and sold-out behavior |

The product record must be accurate in Shopify Admin before template troubleshooting begins. Update a product's title, price, media, description or variants in Shopify Admin rather than hardcoding a one-product exception into the template.

### 5.2 Membership product references

Membership cards obtain product and variant data from the section's existing product references. The implementation reads the selected or first available variant for each configured membership product. Do not duplicate membership products and do not paste fixed membership variant IDs into the reusable section.

The current UK Premier plan presentation is:

| Plan | Display rule | Delivery presentation |
|---|---|---|
| Monthly Access | Introductory `Free` display with recurring price detail | No free-delivery badge |
| 1-Year Access | Displays the referenced annual price | Free-delivery badge |
| 2-Year Access | Displays the referenced two-year price | Free-delivery badge |

The monthly plan is not permanently free. The introductory display must continue to explain the charge after the first 30 days and that the plan can be cancelled according to the configured UK copy.

## 6. Membership eligibility rule

Membership options are intentionally limited to products whose current `product.title`, lowercased by Liquid, contains `elliptical`. The current active FitQuest products verified through Shopify Admin are:

| Product | Status | Membership result |
|---|---|---|
| FitQuest 2-In-1 Elliptical Stepper - Black | Active | Membership cards and combined purchase flow enabled |
| FitQuest 2-In-1 Elliptical Stepper - Purple | Active | Membership cards and combined purchase flow enabled |
| Stair Climber Elite | Active | Membership cards hidden; native product purchase remains |

The rule is implemented without product handles, SKUs or fixed IDs:

```liquid
{% assign product_title_downcase = product.title | downcase %}
{% assign is_elliptical_product = false %}
{% if product_title_downcase contains 'elliptical' %}
  {% assign is_elliptical_product = true %}
{% endif %}

{% assign membership_enabled = false %}
{% if is_elliptical_product %}
  {% assign membership_enabled = section.settings.show_membership_options %}
  {% comment %}
    Existing membership metafield and tag overrides remain inside this guard.
  {% endcomment %}
{% endif %}
```

The live section also supports the existing `custom.membership_eligible` metafield and `membership-eligible` or `no-membership` tags. Those overrides are evaluated only after the product has passed the elliptical guard. This means a non-elliptical product cannot display membership options by accidentally inheriting a section-level default or an unrelated eligibility value.

When creating a future elliptical product, use a product title that clearly contains `elliptical`. If the business later requires membership options for a non-elliptical product, do not bypass this rule by adding a hardcoded handle. Propose an explicit product-level eligibility model and update this SOP and the validated Liquid source together.

## 7. Purchase action and cart behavior

### 7.1 One physical purchase action

Every product using the FitQuest template has one native product submit button in `sections/fitquest-dynamic-product.liquid`:

```liquid
{% form 'product', product, id: 'FitQuestProductForm', class: 'fitquest-pdp__form' %}
  ...
  <button type="submit" class="fitquest-pdp__add" data-fitquest-add>
    <span>{{ section.settings.add_to_cart_label }}</span>
  </button>
{% endform %}
```

The offers section must not render a second purchase CTA. The membership block contains selection controls and a comparison modal, not another purchase button. This avoids duplicate actions and prevents two independent cart handlers from being triggered for the same customer interaction.

### 7.2 Elliptical membership submit flow

When the product is an eligible elliptical and a membership radio is selected, the offers script listens to the native `FitQuestProductForm` submit event. It performs the following sequence:

1. Reads the current equipment variant from `[data-fitquest-variant-select]` at submit time.
2. Reads the currently checked membership input from `[data-fitquest-membership-input]:checked`.
3. Prevents the native form navigation only when a membership is selected and both dynamic IDs are present.
4. Sends both line items to `routes.cart_add_url` using Shopify's locale-aware Liquid route.
5. Redirects to `routes.cart_url` after a successful response.
6. Restores the button state if the request fails.

Shopify's Ajax Cart API documents `POST /{locale}/cart/add.js` for adding one or multiple variants. Each line item uses a variant `id` and `quantity`, and multiple objects can be sent in the `items` array [2]. The FitQuest implementation follows this pattern.

The core behavior is equivalent to:

```javascript
productForm.addEventListener('submit', function(event) {
  var selected = root.querySelector('[data-fitquest-membership-input]:checked');
  if (!selected) return;

  event.preventDefault();
  addSelectedMembership(purchaseButton, selected);
});
```

The `addSelectedMembership` function posts the equipment and membership variant IDs as two items. The IDs are read from the current rendered product and membership inputs. They must never be replaced with literal numeric IDs in reusable source.

### 7.3 Non-elliptical behavior

For a non-elliptical FitQuest product, the membership block is not rendered. The native FitQuest form therefore follows normal Shopify form behavior and adds only the current equipment variant. The discount card and modal remain independent and may still render according to their section setting.

## 8. How to add a new FitQuest product

### 8.1 Product setup in Shopify Admin

Create or update the product in Shopify Admin using the correct native title, price, media, description, variants, inventory and FitQuest organization tag. Confirm the product is active and available on the intended storefront sales channel according to the normal ecommerce release process.

If the product is an elliptical that should receive membership options, make sure the product title contains `elliptical`. Do not add a hardcoded URL or ID to the Liquid source.

### 8.2 Assign the template

In Shopify Admin, open the product and select `product.dynamic-fitquest` in the theme template field. Save the product assignment. Do not edit `templates/product.liquid`, `product.dynamic-bike`, global layout files or unrelated product templates.

### 8.3 Configure section references

Open the assigned theme in the Theme Editor and verify the FitQuest section settings. The membership section should reference the existing UK Premier monthly, annual and two-year membership products. Confirm the configured image, label, savings and delivery copy is appropriate for the UK storefront.

If a product is not an elliptical, leave membership options hidden through the Liquid eligibility rule. Do not enable membership by adding a fixed ID or by changing the global default for all FitQuest products.

### 8.4 Product description and specifications

Enter the product description in Shopify Admin. When specifications are required, use a stable `Key Features:` heading followed by a real unordered list. Keep each feature in its own list item and place the feature name in a bold element when the fixed specifications section expects a label and value.

```html
<p><strong>Key Features:</strong></p>
<ul>
  <li><strong>Adjustable resistance</strong> - Supporting product-specific explanation</li>
  <li><strong>Compact footprint</strong> - Supporting product-specific explanation</li>
</ul>
```

Do not edit the shared specification parser for a single product. The product description remains the source of truth for product-specific specifications.

## 9. Theme editing and deployment procedure

### 9.1 Pre-change checklist

Before editing, confirm the store domain, current public theme ID, product template, affected files, rollback source and validation plan. The live theme ID must be verified from Shopify Admin or from the public storefront's `data-theme-instance-id`; do not rely on an old draft-theme ID.

Confirm the target theme in Shopify Admin before pulling. Never reuse a theme ID from a previous draft or retired theme.

Shopify's theme structure separates templates, sections, snippets and configuration files [1]. The deployment should use that separation and upload only the exact changed FitQuest file.

### 9.2 Read-only pull

Use a clean local working directory and pull only the wrapper and its relevant FitQuest sections:

```bash
shopify theme pull \
  --store echelonfit-uk.myshopify.com \
  --theme <confirmed-live-theme-id> \
  --path /path/to/live-fitquest-audit \
  --nodelete \
  --only templates/product.dynamic-fitquest.liquid \
  --only sections/fitquest-dynamic-product.liquid \
  --only sections/fitquest-dynamic-offers.liquid
```

Read the wrapper first. Pull additional sections only when the wrapper references them and the requested change requires them. Never upload the entire theme for a FitQuest-only correction.

### 9.3 Local validation

Validate the exact pulled files before any push. Minimum checks are:

| Check | Acceptance criterion |
|---|---|
| Template references | The wrapper references the expected FitQuest sections |
| Liquid balance | `if`/`endif`, `unless`/`endunless`, `for`/`endfor` and `form`/`endform` counts balance |
| Schema JSON | Each section has one valid schema block |
| Native action | Exactly one `button[type="submit"]` exists in the FitQuest product section |
| Duplicate CTA | No `.fitquest-membership__cta` or `data-fitquest-membership-cta` remains |
| Eligibility | Membership is guarded by the lowercased product title containing `elliptical` |
| Dynamic data | No fixed product, SKU, handle or numeric variant ID is embedded in reusable source |
| Cart behavior | The submit handler reads the current equipment variant and checked membership input |
| Discount behavior | The discount card and modal remain unchanged unless separately approved |

### 9.4 Minimal live push

Push only the changed FitQuest file. The `--allow-live` flag is required for a non-interactive CLI push to a live theme. Do not use `--publish`.

```bash
shopify theme push \
  --store echelonfit-uk.myshopify.com \
  --theme <confirmed-live-theme-id> \
  --path /path/to/live-fitquest-audit \
  --nodelete \
  --allow-live \
  --only sections/fitquest-dynamic-offers.liquid
```

The command must not include settings, layout, assets, global scripts, unrelated templates or the dynamic-bike files. A successful push updates the selected file in the named theme; it does not publish or switch a theme when `--publish` is omitted.

## 10. Verification procedure

### 10.1 Public HTML checks

Use a hard refresh and a cache-busting query on the public pages. Verify both the intended positive cases and a non-eligible control.

| Page type | Expected result |
|---|---|
| Active FitQuest elliptical | One native submit, three membership options, zero duplicate membership CTA buttons |
| Active FitQuest non-elliptical | One native submit, zero membership options, zero duplicate membership CTA buttons |
| Non-FitQuest product | No FitQuest membership or product-section markup introduced |

The current verified public examples are:

- [FitQuest elliptical Black](https://echelonfit.uk/products/qvc-purple-stepper-despatched)
- [FitQuest elliptical Purple](https://echelonfit.uk/products/qvc-black-stepper-despatched)
- [Stair Climber Elite](https://echelonfit.uk/products/stair-climber-elite)
- [Non-FitQuest control PDP](https://echelonfit.uk/products/echelon-ex-pro-smart-connect-bike)

The product handles are documented here for verification only. They must not be hardcoded into the reusable template.

### 10.2 Interaction checks

On an eligible elliptical, select each membership radio and verify that the selected card state follows the radio. Change the equipment variant where the product has multiple variants and confirm that the current variant is used at submit time.

Click the single native purchase action and verify that the cart contains exactly the current equipment variant and the selected membership variant. Confirm there is no second cart request and that the customer is routed to the cart after success.

On a non-elliptical FitQuest product, verify that the membership cards are absent and the normal native Add to Cart behavior remains available. Confirm that the discount card, if enabled, still opens its modal.

### 10.3 Accessibility and responsive checks

Confirm that membership options remain keyboard reachable as labels and radio inputs, that the comparison control exposes its expanded state, that modal close controls remain reachable and that focus is restored after closing the modal. Verify the single purchase action is visible and usable on mobile and desktop widths.

## 11. Troubleshooting

| Symptom | Likely cause | Resolution |
|---|---|---|
| Membership cards appear on every FitQuest product | The elliptical guard was removed or `membership_enabled` defaults to true outside the guard | Restore the title-based guard and validate a non-elliptical PDP |
| Membership cards are missing on an elliptical | The product title does not contain `elliptical`, the section setting is off or membership product references are blank | Correct the product data or Theme Editor references; do not hardcode a handle |
| Two purchase buttons appear | A standalone membership CTA was reintroduced or an unrelated section was added to the product form | Remove the second purchase control and keep the native submit as the only purchase action |
| Cart contains only equipment | The submit handler did not intercept the native form or no membership radio was checked | Confirm the checked input selector, current variant input and `routes.cart_add_url` request |
| Cart contains the wrong equipment variant | The script cached a variant ID instead of reading the selector at submit time | Read `[data-fitquest-variant-select].value` inside the submit flow |
| Product page is 404 during testing | The public handle is not the current Admin handle or the product is not available on the storefront channel | Confirm the handle and product status in Shopify Admin; do not change the template to compensate |
| Unrelated pages changed | More than the explicit FitQuest file was pushed or a theme was published | Stop, compare the push command, restore only the intended FitQuest file and verify a non-FitQuest control PDP |
| CLI pull has no FitQuest files | The theme ID is not the theme serving the public storefront | Verify the live theme ID from Admin and the public `data-theme-instance-id` before pulling again |

## 12. Rollback procedure

Rollback must restore the previous validated version of the exact FitQuest file. Do not switch themes or publish a draft as a rollback method.

1. Record the public symptom and the current live theme ID.
2. Pull or retrieve the last validated `sections/fitquest-dynamic-offers.liquid` source from version control or the approved backup.
3. Restore only that file in the local working directory.
4. Re-run the Liquid, schema, single-action and eligibility checks.
5. Push only `sections/fitquest-dynamic-offers.liquid` to the same confirmed live theme with `--nodelete --allow-live --only`.
6. Hard-refresh an eligible elliptical, a non-elliptical FitQuest product and the non-FitQuest control PDP.
7. Record the rollback commit, affected theme ID and verification results.

If the issue is caused by product data rather than theme code, correct the product record in Shopify Admin and do not roll back the shared template.

## 13. Change-control rules

The following rules keep this template durable and scalable:

| Rule | Requirement |
|---|---|
| Native architecture | Use Liquid, HTML, CSS and lightweight vanilla JavaScript only |
| Data source | Use native product data, configured product references and approved product metafields |
| SKU neutrality | Never hardcode product titles, handles, URLs, prices, SKU values, product IDs or variant IDs |
| Scope | Edit only the FitQuest files required for the approved change |
| Theme safety | Do not create theme copies for routine FitQuest corrections, do not publish a theme and do not touch shared layout files |
| Membership eligibility | Keep membership restricted to the approved product-data rule and document any rule change |
| Purchase actions | Keep exactly one physical purchase action in the FitQuest PDP |
| Cart behavior | Read current variant and membership values at submit time and avoid duplicate cart calls |
| Verification | Test positive, negative and unrelated control pages after every live change |
| Security | Never store Theme Access credentials in the repository or SOP; rotate exposed credentials |

## 14. References

1. [Shopify theme architecture](https://shopify.dev/docs/storefronts/themes/architecture) - Templates, sections, snippets and native Liquid theme features.
2. [Shopify Ajax Cart API reference](https://shopify.dev/docs/api/ajax/reference/cart) - Adding one or multiple variants with `POST /{locale}/cart/add.js` and clearing a test cart.
3. [Shopify theme structure](https://help.shopify.com/en/manual/online-store/themes/theme-structure) - Theme file organization and reusable sections.
4. [Echelon Shopify SOP repository](https://github.com/NikoCartin/echelon-sops) - Related Echelon storefront SOPs and implementation references.

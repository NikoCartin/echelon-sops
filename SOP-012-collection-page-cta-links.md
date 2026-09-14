# Standard Operating Procedure (SOP)
## Collection Page CTA Links: Configuration, Validation, and Release Control

**Document owner:** Nicolas Cartin Reyes, Lead Developer  
**Audience:** Shopify Development, Performance Marketing, Ecommerce Operations, and QA  
**Store:** Echelon Fit US  
**Applies to:** Shopify collection pages using the `stronger-hero` section and the shared `collection-product-grid` section  
**Status:** Approved team reference for draft-theme work  
**Last updated:** September 14, 2026

---

## 1. Purpose

This SOP establishes the required process for creating and validating collection-page call-to-action buttons. It is designed to prevent buttons that appear correct but do nothing, redirect to the same page with a trailing `#`, or fail to scroll to the product grid.

The key principle is that a working CTA requires **both** a valid link and a valid destination element. A value such as `#cpg-collection_product_grid` is only functional when the rendered HTML contains an element with exactly `id="cpg-collection_product_grid"`.

> A correct `href` by itself is not sufficient. The destination ID must exist in the final storefront DOM, and the click must be tested in the actual draft-theme preview.

Shopify’s theme architecture separates configurable section settings from the Liquid section markup that renders those settings. The Theme Editor is intended for configuring section content and settings, while Liquid controls the resulting HTML structure and reusable behavior.[1] [2]

## 2. Scope and ownership

Performance Marketing owns the campaign intent, button wording, destination choice, tracking requirements, and business acceptance criteria. Development owns the reusable Liquid implementation, stable destination anchors, theme safety, and technical validation. QA or the requesting marketer owns the final functional review in the draft preview before publication.

No team member should publish a live-theme CTA change without confirming the draft preview, the final rendered `href`, the destination element, desktop behavior, and mobile behavior.

| Responsibility | Owner | Required output |
|---|---|---|
| Define CTA label and business destination | Performance Marketing | Approved label, target collection or section, campaign context |
| Configure the collection section | Performance Marketing or trained Shopify Admin user | Draft-theme configuration saved in the correct collection template |
| Maintain Liquid section and stable anchors | Development | Reusable code with no hardcoded campaign-specific assumptions |
| Validate rendered HTML and interaction | QA / requesting team member | Functional test evidence in draft preview |
| Approve publication | Ecommerce owner / authorized approver | Explicit approval after QA |
| Publish or roll back | Authorized Shopify Admin user | Published version or rollback to backup |

## 3. Standard destination rules

For a hero button whose purpose is to take the shopper to the products on the same collection page, use the stable grid anchor:

```text
#cpg-collection_product_grid
```

Do not invent a destination based on the visible section name, the Shopify template ID, or a temporary browser-generated identifier. Do not use the dynamic ID generated from `section.id` in a manually entered Theme Editor field. Shopify section IDs can contain template-specific values such as `template--22947822586567__collection_product_grid`; those values are not suitable for a reusable marketing workflow.

Use a full collection URL when the CTA should take the shopper to a different page:

```text
/collections/connect-bikes
/collections/stair-climber
/collections/all-accessories
```

Use a product URL when the CTA is intended to open one product:

```text
/products/example-product-handle
```

Use a page URL for editorial or campaign content:

```text
/pages/partners
/pages/financing
```

Do not use the following values for a production CTA unless the button is intentionally non-functional and visually hidden:

```text
#


javascript:void(0)
```

A blank link is not a valid “temporary” configuration. It creates a broken customer journey and must be treated as a release-blocking defect.

## 4. Required Liquid implementation

The shared product-grid section must expose a stable anchor while preserving the dynamic ID used internally by the section’s CSS and JavaScript.

In **`sections/collection-product-grid.liquid`**, the grid must follow this structure:

```liquid
{%- paginate collection.products by per_page -%}
<span id="cpg-collection_product_grid" class="cpg-scroll-anchor" aria-hidden="true"></span>
<section class="cpg" id="cpg-{{ section.id }}" data-per-row="{{ per_row }}">
  <!-- existing product-grid markup remains unchanged -->
</section>
{%- endpaginate -%}
```

The stable anchor must be placed immediately before the product-grid section. Do not replace `id="cpg-{{ section.id }}"` with the stable ID. The dynamic ID is used by existing selectors and scripts and must remain unchanged.

Add the following CSS in the same section or the theme stylesheet:

```css
.cpg-scroll-anchor {
  display: block;
  height: 0;
  scroll-margin-top: 110px;
}
```

The `scroll-margin-top` value must be adjusted if the store’s sticky header height changes. Its purpose is to keep the collection heading visible below the sticky header after the anchor is resolved.

The shared hero section should keep its normal configured-link behavior:

```liquid
{%- if primary_label != blank -%}
  <a
    href="{{ primary_link | default: '#' }}"
    class="stronger-hero__btn stronger-hero__btn--primary">
    {{ primary_label }}
  </a>
{%- endif -%}
```

The fallback to `#` should not be considered a valid final state. It exists only as defensive rendering behavior. The Theme Editor configuration must always provide a real destination for a visible primary button.

## 5. Performance Marketing procedure: configure a CTA

Before editing the theme, identify the intended customer journey in one sentence. For example: “This button takes a visitor from the Stair Climbers hero to the products listed on the same page.” If that is the intended journey, use `#cpg-collection_product_grid`.

Open Shopify Admin, navigate to **Online Store → Themes**, select the approved draft theme, and open **Customize**. Navigate to the relevant collection page and select the hero section. Enter the approved button label in the primary-button label field and enter the approved destination in the primary-button link field.

For a same-page product-grid CTA, the value must be:

```text
#cpg-collection_product_grid
```

For a different collection, use the collection’s canonical relative path. Do not paste a live-theme URL with a preview parameter into the Theme Editor. Do not use a URL copied from a temporary preview session as the canonical destination.

Save the draft theme. Do not publish yet. Record the page URL, CTA label, destination, campaign name, and date in the campaign ticket or release record.

## 6. Developer procedure: create or modify a collection CTA

Development must first determine whether the requested page uses the shared `stronger-hero` and `collection-product-grid` sections. If it does, no page-specific JavaScript should be created. The stable anchor in the shared product-grid section is the preferred implementation because it supports all collection pages using the same grid.

When the CTA is configured through a JSON template, the relevant setting should look like this:

```json
{
  "primary_label": "SHOP STAIR CLIMBERS",
  "primary_link": "#cpg-collection_product_grid"
}
```

The exact JSON nesting depends on the template. Do not perform a blind global replacement. Confirm that the section’s `primary_label` belongs to the intended collection hero and that the section includes the corresponding product grid below it.

When the requested CTA targets a different collection, use a canonical collection path instead of the same-page anchor:

```json
{
  "primary_label": "SHOP BIKES",
  "primary_link": "/collections/connect-bikes"
}
```

Before uploading a theme file, review the diff and confirm that no product data, unrelated section, PDP snippet, navigation menu, or live-theme asset is included in the change.

## 7. Mandatory QA procedure

QA must test the final draft preview, not only the Theme Editor canvas. The test must be performed in a fresh browser tab or private session where possible.

| Test | Expected result | Pass condition |
|---|---|---|
| Open the collection root URL | Page loads successfully | HTTP response is successful and products render |
| Inspect the hero CTA | Button has the approved label | Label matches the campaign brief |
| Inspect the CTA `href` | `href` is not blank and is not `#` | Exact expected value is present |
| Inspect the destination | `document.getElementById('cpg-collection_product_grid')` returns an element for same-page grid CTAs | Target exists in the DOM |
| Click the CTA | Browser remains on the intended page and updates the hash when using the same-page anchor | URL contains the expected hash |
| Observe the viewport | Collection heading and product grid are visible | Sticky header does not cover the heading |
| Reload the hash URL | Page returns to the grid | Direct deep-link works after reload |
| Test desktop | Layout remains usable | CTA and grid are visible at desktop width |
| Test mobile | Layout remains usable | CTA is tappable and grid heading is visible |
| Test without JavaScript where practical | Same-page anchor still resolves natively | No dependency on a fragile click listener |

For Stair Climbers, the required test URL is:

```text
https://echelonfit.com/collections/stair-climber#cpg-collection_product_grid
```

For the current primary collection set, repeat the same validation on:

```text
/collections/stride
/collections/connect-bikes
/collections/stair-climber
/collections/echelon-ellipticals
/collections/echelon-strength
/collections/recovery
/collections/all-accessories
```

A screenshot is useful for visual review, but it does not replace DOM validation. The reviewer should confirm the final `href`, the presence of the target ID, and the resulting scroll position.

## 8. Browser-console validation

For same-page grid CTAs, the following read-only check can be used in browser developer tools:

```javascript
(() => {
  const target = document.getElementById('cpg-collection_product_grid');
  const cta = [...document.querySelectorAll('a.stronger-hero__btn')]
    .find((link) => /STAIR CLIMBERS/i.test(link.textContent));

  return {
    href: cta?.getAttribute('href'),
    hash: window.location.hash,
    targetExists: Boolean(target),
    targetId: target?.id,
    scrollY: window.scrollY,
    targetTop: target?.getBoundingClientRect().top,
  };
})();
```

For a successful same-page result, `targetExists` must be `true`, `targetId` must equal `cpg-collection_product_grid`, the CTA `href` must match the approved destination, and `targetTop` should be close to the visible content boundary below the sticky header after the click or direct hash load.

## 9. Troubleshooting guide

### The URL ends in `#` or the button appears to do nothing

The button is receiving a blank link and Liquid is applying its defensive `#` fallback. Check the section’s `primary_link` setting in the draft template or Theme Editor. Do not fix this by adding arbitrary JavaScript first. Provide the correct destination value and retest.

### The URL contains `#cpg-collection_product_grid`, but the page does not scroll

Inspect the DOM. If `document.getElementById('cpg-collection_product_grid')` returns `null`, the stable anchor is missing from the product-grid section. Verify that `sections/collection-product-grid.liquid` contains the stable anchor immediately before the dynamic grid section.

### The grid exists, but the heading is hidden behind the header

Increase or correct `scroll-margin-top` on `.cpg-scroll-anchor`. Use the measured sticky-header height plus a small spacing allowance. Do not add arbitrary top padding to the entire product grid because that changes the visual layout for every visitor.

### The link works in the Theme Editor but not in the preview URL

The Theme Editor canvas can preserve editor state that is not present in the storefront preview. Validate the rendered storefront HTML and test the preview URL directly. If the preview shows a different template, confirm that the correct collection template is assigned.

### A hardcoded dynamic ID works on one page but not another

Do not hardcode IDs containing `template--...` or a specific `section.id`. Those values can differ between templates and preview sessions. Use the stable anchor defined by the shared section.

### The button scrolls to the wrong location

Confirm that there is only one `id="cpg-collection_product_grid"` on the page and that the anchor appears immediately before the intended grid. Remove duplicate anchors introduced by page-specific custom sections.

### A campaign needs a different destination

Do not reuse the same-page grid anchor. Use the canonical collection, product, or page path approved in the campaign brief, then validate the destination independently.

## 10. Release and rollback controls

All CTA changes must be made in an unpublished draft theme first. A live-theme change requires an approved backup or duplicate of the current live theme, a completed QA record, and explicit approval from the designated ecommerce owner.

The release record must contain the collection URL, CTA label, configured destination, affected template or section, preview URL, desktop test result, mobile test result, and approver. The release must be limited to the approved files. If the change introduces a broken CTA or unrelated visual regression, stop publication and restore the prior draft checkpoint or backup theme rather than patching live under pressure.

After publication, perform a production smoke test on the affected collection pages. If a production CTA fails, record the exact URL and rendered `href`, stop additional rollout, and roll back to the last known-good theme version while Development investigates.

## 11. Team checklist

Before marking a collection page ready, the responsible team member must confirm all of the following:

- The CTA label is approved and descriptive.
- The destination is either a valid canonical path or `#cpg-collection_product_grid` for the same-page product grid.
- No visible CTA has a blank `href` or a fallback `#`.
- The stable destination element exists in the rendered DOM.
- The CTA works from the draft preview, not only inside the Theme Editor.
- The direct hash URL works after reload.
- The collection heading remains visible below the sticky header.
- Desktop and mobile behavior have both been tested.
- The change is limited to the approved draft theme and files.
- Publication approval and rollback ownership are recorded.

## 12. Reference implementation summary

The reusable implementation has three separate responsibilities:

| Layer | Responsibility | Do not do |
|---|---|---|
| Theme Editor / JSON setting | Store the CTA label and approved destination | Do not assume a link works without a target element |
| `stronger-hero.liquid` | Render the visible button | Do not hide a blank production link behind a `#` fallback |
| `collection-product-grid.liquid` | Render the stable destination and dynamic grid | Do not replace the dynamic grid ID used by internal CSS and JavaScript |

The approved same-page pattern is therefore:

```text
CTA href: #cpg-collection_product_grid
Stable target: <span id="cpg-collection_product_grid" ...></span>
Dynamic grid ID: cpg-{{ section.id }}
```

## 13. Document control

**Author:** Nicolas Cartin Reyes, Lead Developer  
**Review cadence:** Review after any redesign of the collection hero, product-grid section, sticky header, or theme architecture.  
**Change rule:** Update this SOP whenever the stable anchor, shared section names, or release process changes.

## References

[1]: https://shopify.dev/docs/storefronts/themes/architecture/sections "Shopify theme sections and blocks"
[2]: https://shopify.dev/docs/storefronts/themes/tools/online-editor "Shopify theme editor"
[3]: https://shopify.dev/docs/api/liquid "Shopify Liquid reference"
[4]: https://shopify.dev/docs/api/liquid/filters/link_to "Shopify Liquid link_to filter"

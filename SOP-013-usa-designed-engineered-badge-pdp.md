# Standard Operating Procedure (SOP)
## “Designed and Engineered in the USA” Badge Across Product Detail Pages

**Document owner:** Nicolas Cartin Reyes, Lead Developer  
**Audience:** Shopify Development, Ecommerce Operations, QA, Merchandising, and Performance Marketing  
**Store:** Echelon Fit US  
**Applies to:** All Product Detail Pages (PDPs) that use the shared purchase render paths documented below  
**Status:** Team reference for draft-theme development and controlled release  
**Last updated:** September 14, 2026

---

## 1. Purpose

This SOP documents the complete process for implementing, validating, maintaining, and safely releasing the **“Designed and Engineered in the USA”** badge across Echelon PDPs.

The badge is a reusable Liquid component containing a U.S. flag icon, the required customer-facing text, and an informational indicator. It is positioned in the purchase area of the PDP, **below the price and financing row and above Add to Cart**. This placement keeps the message close to the purchase decision without interfering with product titles, pricing, variant selection, or the Add to Cart control.

The implementation is intentionally shared across PDP render paths. Product data, product titles, prices, variants, financing values, and Add to Cart behavior must remain unchanged when the badge is added or updated.

> The badge is a presentation component. It does not determine eligibility, pricing, financing, shipping, membership status, product availability, or checkout behavior.

## 2. Roles and responsibilities

Development owns the reusable Liquid snippet, shared render points, CSS, accessibility, regression testing, and release safety. Ecommerce Operations owns the business requirement and confirms that the badge should appear on the applicable PDPs. QA validates visual placement and behavior on representative product templates. Performance Marketing may request copy or placement changes, but must not edit shared Liquid render paths without Development review.

| Responsibility | Owner | Required output |
|---|---|---|
| Confirm badge wording and business intent | Ecommerce / Merchandising | Approved copy: “Designed and Engineered in the USA” |
| Request campaign or visual changes | Performance Marketing | Written request identifying scope and reason |
| Maintain snippet and shared render paths | Development | Reviewed Liquid/CSS change and regression validation |
| Validate desktop and mobile rendering | QA | Preview evidence and pass/fail record |
| Approve publication | Authorized Ecommerce owner | Explicit approval after preview review |
| Publish or roll back | Authorized Shopify Admin user | Published checkpoint or restored backup |

## 3. Approved customer-facing specification

The required visible text is exactly:

```text
Designed and Engineered in the USA
```

The badge includes a small inline U.S. flag icon and an informational “i” indicator. The flag is decorative and must remain hidden from assistive technologies with `aria-hidden="true"`. The visible text is the accessible meaning of the badge. The informational indicator provides a title and accessible label.

| Property | Approved requirement |
|---|---|
| Visible text | `Designed and Engineered in the USA` |
| Placement | Below price/financing and above Add to Cart |
| Desktop layout | Inline flex row with flag, text, and info indicator |
| Mobile layout | Reduced spacing and font size without clipping or overflow |
| Product data | Must not be changed |
| Price or financing logic | Must not be changed |
| Add to Cart logic | Must not be changed |
| Reviews or ratings | Must not be fabricated, changed, or added |
| Localization | Do not alter copy without Ecommerce and Development approval |

## 4. Architecture overview

The implementation has two layers. The reusable visual component is stored in `snippets/usa-designed-badge.liquid`. Shared purchase render paths invoke the snippet at the correct location in the purchase flow.

The badge must not be copied into every product JSON template. Copying markup into individual templates creates drift, duplicate renders, and incomplete coverage when new PDP templates are introduced.

The approved architecture is:

```text
PDP template
   └── shared purchase render path
          └── render 'usa-designed-badge'
                 ├── inline U.S. flag SVG
                 ├── accessible text
                 ├── info indicator
                 └── scoped responsive CSS
```

## 5. Reusable Liquid snippet

The source of truth is:

```text
snippets/usa-designed-badge.liquid
```

The snippet must contain one root badge element, one decorative inline flag, one visible text span, and one information indicator. A representative implementation is:

```liquid
<div class="echelon-usa-designed-badge" role="note" aria-label="Designed and Engineered in the USA">
  <svg
    class="echelon-usa-designed-badge__flag"
    viewBox="0 0 24 16"
    aria-hidden="true"
    focusable="false">
    <!-- approved inline U.S. flag artwork -->
  </svg>

  <span class="echelon-usa-designed-badge__text">
    Designed and Engineered in the USA
  </span>

  <span
    class="echelon-usa-designed-badge__info"
    title="Designed and engineered in the USA"
    aria-label="Designed and engineered in the USA">
    i
  </span>
</div>
```

The production snippet may contain the complete approved SVG path data. Do not replace it with a remote image, third-party script, or external asset unless that change is separately reviewed for performance, accessibility, and deployment safety.

The CSS must remain scoped to the badge classes. The approved layout uses a compact inline flex row and a mobile media query. Changes to colors, spacing, font size, or icon dimensions must be reviewed on both desktop and mobile PDPs.

## 6. Approved shared purchase render paths

The badge was extended across the shared purchase snippets used by the active PDP templates. The current coverage list is:

| Render path | Purpose | Required badge location |
|---|---|---|
| `snippets/product-form.liquid` | Standard product form | After price/financing and before Add to Cart |
| `snippets/no-sub-button.liquid` | Active purchase path for PDPs using the financing widget and `data-add-to-cart` markup | Immediately after the financing row and before the active Add to Cart container |
| `snippets/product-form-preorder.liquid` | Preorder product form | Before the preorder/Add to Cart control |
| `snippets/buy-button-with-quanity-selector.liquid` | Purchase form with quantity selector | Before the purchase button control |
| `snippets/sub-select-popup.liquid` | Subscription or plan selection purchase path | Before the relevant Add to Cart control |
| `snippets/individual-product-selection.liquid` | Individual/special PDP selection path | Immediately before the individual Add to Cart button |

The active storefront preview previously used `no-sub-button.liquid`, not only the initially inspected standard `product-form.liquid`. This is why validation must inspect the rendered storefront DOM and not rely solely on the name of the product template.

The previous title-level renders in `snippets/product-template.liquid` and `snippets/product-template-individual.liquid` were removed. The badge must not be rendered both at the title level and in the purchase area.

## 7. How to add the badge to a new PDP render path

When a new PDP template or purchase component is introduced, Development must first identify the actual snippet that renders the Add to Cart control. Search the theme for the relevant purchase markup, including `data-add-to-cart`, `type="submit"`, `Add to Cart`, `product-form`, and financing-widget references.

Insert the badge immediately before the Add to Cart container or button, after the price and financing content. Use the existing snippet rather than copying its markup:

```liquid
{% render 'usa-designed-badge' %}
```

The exact insertion point must satisfy all three conditions:

| Condition | Required result |
|---|---|
| Price visibility | Price and financing appear before the badge |
| Purchase hierarchy | Badge appears before Add to Cart |
| Form behavior | Badge is not nested inside a clickable button or invalid form control |

Do not place the badge inside an anchor, inside the Add to Cart button, inside a quantity input wrapper, or inside a financing widget that controls its own layout.

After adding a new render point, confirm that the same PDP does not receive the badge from another shared snippet. Exactly one badge should render in the purchase area per PDP.

## 8. Placement rules

The approved visual order is:

```text
Product title
Price
Financing row or financing widget
Designed and Engineered in the USA badge
Variant or purchase controls, if applicable
Add to Cart
```

If a specific PDP has a different purchase hierarchy, preserve the same semantic relationship: the badge remains after the price/financing information and before the final purchase action.

Do not move the badge above the product title, into the product media gallery, into the reviews area, or below Add to Cart without approval. Do not add large vertical spacing that pushes the purchase control below the fold unnecessarily.

## 9. Theme development workflow

All badge changes must begin in an unpublished draft theme. The current approved work theme is `colorful-inspiration` (`161010352327`), but teams must confirm the active draft theme before editing.

Before making a change, create or confirm a backup/checkpoint. Edit only the approved badge snippet and shared purchase render paths. Do not modify product records, product metafields, pricing, financing settings, shipping functions, discount functions, collection templates, or unrelated navigation while implementing the badge.

After editing, upload only the approved files to the draft theme. Review the theme diff and confirm that the live theme remains unchanged. Generate a direct storefront preview URL for representative PDPs; an Admin Theme Editor screenshot alone is not sufficient.

## 10. Required QA matrix

QA must test at least one standard PDP and one individual/special PDP. The Connect EX-7s PDP was used as a representative validation product during the original implementation.

| Test area | Expected result |
|---|---|
| Standard PDP | Badge appears once in the purchase area |
| Individual/special PDP | Badge appears once before the individual Add to Cart control |
| Price/financing order | Badge is below price and financing |
| Add to Cart order | Badge is above Add to Cart |
| Desktop | Flag, text, and info indicator align correctly |
| Mobile | Text remains readable and does not clip or overflow |
| Accessibility | Decorative SVG is hidden; visible meaning is text-based; info indicator has an accessible label |
| Product selection | Variant selection remains functional |
| Quantity | Quantity selector remains functional where present |
| Add to Cart | Add to Cart behavior remains unchanged |
| Financing | Financing widget and content remain unchanged |
| Product title | No duplicate badge appears near the title |
| Product data | No product, price, or availability data changes |
| Fresh preview | Badge appears in the storefront preview without editor-only state |

## 11. Browser and DOM validation

Use the browser inspector on a fresh draft-preview session. The following read-only check confirms that the badge renders once and is positioned before the purchase action:

```javascript
(() => {
  const badges = [...document.querySelectorAll('.echelon-usa-designed-badge')];
  const addToCart = [...document.querySelectorAll('[data-add-to-cart], button[type="submit"]')]
    .find((element) => /add to cart|buy now|pre-?order/i.test(element.textContent || ''));
  const badge = badges[0];

  return {
    badgeCount: badges.length,
    text: badge?.querySelector('.echelon-usa-designed-badge__text')?.textContent?.trim(),
    badgeTop: badge?.getBoundingClientRect().top,
    addToCartTop: addToCart?.getBoundingClientRect().top,
    badgeBeforeAddToCart: Boolean(
      badge && addToCart && badge.getBoundingClientRect().top < addToCart.getBoundingClientRect().top
    ),
  };
})();
```

A passing result requires `badgeCount: 1`, the exact approved text, and `badgeBeforeAddToCart: true`. If a page contains more than one active Add to Cart control because of responsive or sticky purchase UI, inspect the rendered layout manually and confirm that the badge is not duplicated in multiple purchase forms.

## 12. Responsive and accessibility requirements

The badge must remain readable at the store’s supported mobile breakpoint. The approved mobile CSS reduces the gap, margin, font size, and letter spacing without hiding the text. Do not use a fixed width that can cause overflow on narrow screens.

The flag SVG is decorative and must use `aria-hidden="true"` and `focusable="false"`. The customer-facing text must remain in real HTML text, not only inside an image or CSS pseudo-element. The information indicator must retain its title and accessible label. The badge should not receive keyboard focus because it is informational, not an interactive control.

Any future text change must be reviewed for capitalization, meaning, translation, and legal or marketing approval. The phrase must not be changed to imply that every component, material, or manufacturing step occurs in the United States unless that claim has been approved by the appropriate business owner.

## 13. Troubleshooting

### The badge does not appear on a PDP

Inspect the rendered HTML first. If the snippet is present in the repository but absent from the storefront, the inspected PDP may use a different purchase render path. Locate the active Add to Cart markup and add the shared snippet to that path rather than adding another product-template-level render.

### The badge appears near the title instead of above Add to Cart

A previous title-level render is still active. Search for all occurrences of `usa-designed-badge` and remove the obsolete title-level invocation from the active path. The badge should render only in the purchase area.

### The badge appears twice

Two shared snippets are rendering the badge for the same PDP, or a title-level and purchase-level invocation both remain. Search all active render paths, inspect the final DOM, and keep exactly one purchase-area render.

### The badge appears below Add to Cart

The render invocation is in the wrong location. Move it after the price/financing markup and immediately before the Add to Cart container. Do not solve the problem with large negative margins or absolute positioning.

### The badge is present in desktop but missing on mobile

Check whether the mobile layout uses a separate sticky purchase snippet or a different product-form branch. Validate both the normal and sticky/mobile purchase paths. Do not hide the badge through a mobile-only selector unless the business requirement explicitly changes.

### The badge text or icon is clipped

Inspect the width, flex behavior, line height, letter spacing, and media query. Use wrapping and responsive sizing rather than fixed widths. Confirm that the badge remains visible at the narrowest supported viewport.

### The Add to Cart button stops working

The badge may have been inserted inside the button or into a form element with invalid nesting. Move the badge outside the button and preserve the existing form markup. Do not modify Add to Cart JavaScript as part of a badge-only change.

## 14. Release and rollback procedure

Before publication, Development must confirm the draft preview on representative standard and individual PDPs, complete the QA matrix, review the file diff, and save a checkpoint. Ecommerce must approve the final preview.

The release must include only the approved badge snippet, the approved shared purchase render paths, and any narrowly scoped CSS required for the badge. The live theme must be backed up before publication. If any PDP loses Add to Cart functionality, shows duplicate badge markup, or displays incorrect placement, stop the rollout and restore the prior theme checkpoint or backup.

After publication, perform a production smoke test on at least one standard PDP and one individual/special PDP. Record the tested URLs, viewport sizes, badge count, placement, and Add to Cart result.

## 15. Maintenance rules

The snippet is the single source of truth for badge copy, SVG artwork, classes, and component styling. Do not duplicate the markup into product templates or campaign-specific JSON. When a new PDP purchase path is added, Development must update the render-path inventory and add the snippet once at the approved purchase location.

Any change to the phrase, U.S. flag artwork, accessibility labels, placement, or responsive styling requires review by Development and Ecommerce. Any request to remove the badge from a product or collection must identify whether the requirement is global or template-specific; do not introduce product-level conditions without an approved business rule.

## 16. Team checklist

Before closing a badge task, confirm that the exact approved text is visible, the badge renders once, the badge sits below price/financing and above Add to Cart, standard and individual PDP paths are covered, mobile and desktop views pass, no product or purchase logic changed, no title-level duplicate remains, the draft preview was tested directly, the live theme was not changed without approval, and a rollback checkpoint exists.

## 17. Implementation record

The badge implementation was validated in the unpublished `colorful-inspiration` theme (`161010352327`). The active purchase paths included `product-form.liquid`, `no-sub-button.liquid`, `product-form-preorder.liquid`, `buy-button-with-quanity-selector.liquid`, `sub-select-popup.liquid`, and `individual-product-selection.liquid`. The badge was confirmed below price/financing and above the Add to Cart control, and the live theme remained unchanged during the draft validation.

**Author:** Nicolas Cartin Reyes, Lead Developer  
**Review cadence:** Review after any PDP architecture change, product-form refactor, financing-widget change, or new purchase render path.  
**Change control:** Update this SOP whenever the snippet name, shared render paths, placement rules, or release process changes.

## References

[1]: https://shopify.dev/docs/storefronts/themes/architecture/sections "Shopify theme sections"
[2]: https://shopify.dev/docs/storefronts/themes/tools/online-editor "Shopify theme editor"
[3]: https://shopify.dev/docs/api/liquid "Shopify Liquid reference"

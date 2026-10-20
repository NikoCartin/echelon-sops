# SOP-023: Dual-Brand Logo Same-Tab Links

**Author:** Nícolas Cartín Reyes, Lead Developer

## Purpose

Maintain a combined Echelon and PRIMAL logo whose two visible brand areas remain independently clickable, with the PRIMAL destination opening in the current browser tab.

## Scope

This SOP applies to the shared `sections/mega-menu.liquid` header section and its desktop, mobile top-bar and mobile drawer render branches. It does not redraw the logo, split the image into separate assets or add a JavaScript navigation handler.

## Implementation

1. Pull the current live header section and create an unpublished theme copy.
2. Preserve the existing combined image, positioned wrapper, hit-area widths and accessible labels.
3. Add `target="_self"` to the PRIMAL anchor in every responsive logo branch that renders the external destination.
4. Keep the Echelon anchor on the Shopify root route.
5. Do not add `target="_blank"`, `window.open`, nested anchors or a second logo image.
6. Push only `sections/mega-menu.liquid` to the unpublished theme.

## Validation

On desktop, mobile top bar and mobile drawer:

- The Echelon area points to the Echelon storefront.
- The PRIMAL area points to the US Primal Strength storefront.
- The PRIMAL link contains `target="_self"` and replaces the current tab.
- Both links retain their accessible labels and keyboard focus outline.
- The combined image, header navigation, search, account and cart controls remain unchanged.
- The rendered markup contains no nested anchors.

Before a live release, perform a fresh live pull, review the one-file diff, publish only the approved section and check the public DOM after deployment.

## Rollback

Restore the previous `sections/mega-menu.liquid` from the live pullback and push only that file. Do not revert unrelated product, navigation or checkout files.

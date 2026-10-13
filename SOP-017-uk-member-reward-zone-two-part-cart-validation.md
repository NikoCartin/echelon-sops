# Standard Operating Procedure: UK Member Reward Zone Two-Part Cart Validation

**Document owner:** UK Ecommerce Development  
**Author:** Nicolas Cartin Reyes, Lead Developer  
**Audience:** Echelon developers, Shopify administrators and technical operators  
**Version:** 1.0  
**Status:** Investigation and validation guidance  
**Scope:** UK Member Reward Zone and two-part equipment cart behavior  
**Store:** `echelonfit-uk.myshopify.com`  
**Last updated:** 13 October 2026

## 1. Purpose

This SOP explains how to verify whether an existing Premier Member purchase path adds both required lines for a two-part equipment product. It was created after a Row-7s order contained the equipment SKU and the member-token line but did not contain the packaged-separately screen SKU.

The normal Row-7s product-page flow and the Member Reward Zone flow must be treated as separate purchase paths. A successful test of the standard product-page button does not prove that the authenticated member path uses the same JavaScript handler.

> **Core rule:** Every approved two-part equipment purchase path must add the equipment SKU and its corresponding screen SKU as separate cart lines before checkout.

## 2. Scope and exclusions

This procedure covers:

| Equipment SKU | Screen SKU | Normal product template |
|---|---|---|
| `ECH01-ROW7` | `ECH01-SCR7` | `product.cargo-row7s` |

The procedure may be reused for other approved two-part products only after their product mapping and cart ownership are documented.

This SOP does not authorize:

- Editing an existing order.
- Placing a real order or entering payment details.
- Changing the live theme before the failing purchase path is identified.
- Replacing the shared cart helper without an isolated test and rollback plan.
- Assuming that a customer login automatically uses the standard product-page handler.

## 3. Verified standard Row-7s path

The live dedicated Row-7s template contains the following control flow:

1. Resolve the current `screen-row-7s` available variant through Shopify Liquid.
2. Read `/cart.js` before adding the screen.
3. Check whether the matching screen variant is already in the cart.
4. Add the screen through `/cart/add.js` when it is not already present.
5. Delegate the equipment, membership, delivery and warranty behavior to the existing `addtocartwithwarranty` helper.

The equipment variant is resolved dynamically from the current product object. The shared product snippet and global cart assets are not responsible for the product-specific screen mapping.

A successful normal PDP test should show these separate lines in `/cart.js`:

- `ECH01-ROW7`, Echelon Row-7s Smart Rowing Machine
- `ECH01-SCR7`, Screen Row-7s, packaged separately
- The selected membership line, when selected
- The applicable delivery or promotional line, when required

## 4. Why the Member Reward Zone requires a separate check

The live product page presents existing members with a separate link:

> Already an Echelon Premier Member? Order via the Member Reward Zone

The link sends the customer to the account login route. The presence of a logged-in customer is not sufficient evidence that the subsequent Member Reward Zone purchase uses the same `product.cargo-row7s` handler.

The Member Reward Zone may use a separate page, app, product link, form or JavaScript request. If that route adds the equipment and member token directly, it may bypass the dedicated two-part screen logic unless it has its own screen mapping.

## 5. JavaScript and handler verification

### 5.1 Verify the normal product template

In a pulled copy of the live theme, inspect `templates/product.cargo-row7s.liquid` and confirm:

- The `screen-row-7s` product reference resolves an available variant.
- The equipment variant is resolved from `product.selected_or_first_available_variant.id` or the active variant state.
- The handler reads `/cart.js` before adding the screen.
- The duplicate guard compares the actual screen variant ID.
- The handler calls the existing `addtocartwithwarranty` function after the screen step.
- The normal purchase button has the expected `.buynow` class or the current documented selector.

Do not conclude that the member path is covered merely because these checks pass.

### 5.2 Verify the shared helper without changing it

Locate the definition of `addtocartwithwarranty` in the shared UK theme JavaScript. Confirm that it owns the existing membership, delivery, warranty and approved promotional behavior. Confirm that the helper is not silently removing the screen line after the dedicated template adds it.

The helper should not be copied into the dedicated product template. If the helper must change, stop and open a separate scoped change with its own QA and rollback plan.

### 5.3 Identify the Member Reward Zone owner

Starting from the existing-member link, identify the first page after authentication where the purchase action is rendered. Check whether the action is controlled by:

- A Liquid form or product link.
- A theme snippet or section.
- An app embed or app proxy.
- A custom JavaScript asset.
- A direct `/cart/add.js`, `/cart/update.js` or `/cart/change.js` request.

Use the browser Network panel in an isolated authorized test session. Filter requests by:

- `/cart.js`
- `/cart/add.js`
- `/cart/update.js`
- `/cart/change.js`
- `screen-row-7s`
- `ECH01-SCR7`
- `MEMBERTOKEN`

Record the initiating page and the request payload. Do not copy customer credentials, session tokens or personal data into documentation.

### 5.4 Compare both cart paths

Run the normal PDP test and the Member Reward Zone test separately. For each test:

1. Start with an empty isolated test cart.
2. Record the page URL and selected membership option.
3. Capture the relevant cart request sequence.
4. Read `/cart.js` after the add action.
5. Confirm the equipment and screen SKU quantities.
6. Remove only the test lines after validation.

The Member Reward Zone path passes only when it contains the same required equipment and screen relationship as the normal PDP path.

## 6. Validation matrix

| Test | Expected result |
|---|---|
| Normal Row-7s PDP purchase | `ECH01-ROW7` and `ECH01-SCR7` appear as separate lines. |
| Normal PDP retry | A second screen line is not created. |
| Existing member login only | Login alone does not remove or alter the screen requirement. |
| Member Reward Zone purchase | The member path adds `ECH01-ROW7` and `ECH01-SCR7` as separate lines. |
| Member token present | The token or member discount does not replace the screen line. |
| Screen unavailable | The flow fails safely or surfaces a clear error. It must not add an unrelated product. |
| Checkout not submitted | All testing stops before checkout payment and order submission. |

## 7. Troubleshooting

| Symptom | Likely cause | Action |
|---|---|---|
| Normal PDP adds the screen but Member Reward Zone does not | The member path bypasses the dedicated template handler | Identify the member page and its add-to-cart owner. |
| Equipment and `MEMBERTOKEN` appear without the screen | A member-specific request adds only the equipment and token | Add the approved screen mapping to that path after QA approval. |
| The screen appears twice | The member path and the normal handler both add it | Implement one shared duplicate guard at the owning purchase boundary. |
| `422 Cannot find variant` | Screen product is unavailable to Online Store or the variant ID is invalid | Confirm the product publication and resolve the current available variant. |
| Cart loses the screen after the add request | A helper or cart cleanup script removes it | Trace `/cart/update.js` and `/cart/change.js` calls after the add request. |
| Results differ between test sessions | Existing cart state, cookies, app session or customer context differs | Repeat in a clean isolated session and record the exact entry path. |

## 8. Change-control and rollback

Do not deploy a live change until the failing Member Reward Zone path is identified and its owner is known. If a fix is approved, keep the change limited to the responsible member-flow file, app configuration or dedicated template. Do not modify global JavaScript or the shared helper unless the approved design requires it.

Before deployment:

1. Pull a current theme backup.
2. Validate the smallest possible file set.
3. Test the normal PDP and Member Reward Zone paths in QA.
4. Confirm separate `ECH01-ROW7` and `ECH01-SCR7` lines.
5. Confirm duplicate protection and member-token behavior.
6. Deploy only the approved files with an explicit allowlist.
7. Pull the live files back and compare hashes.
8. Run a no-payment live smoke test.

For rollback, restore only the affected member-flow file or configuration. Do not delete the screen product, modify existing orders or remove the screen from the Online Store channel if the normal two-part flow still depends on it.

## 9. Related documentation

- [SOP-011: UK Two-Part Equipment and Screen Cart Flow](SOP-011-uk-two-part-screen-line-cart-flow.md)
- [SOP-014: UK Product2024 Secondary Product Cart Mapping](SOP-014-uk-product2024-secondary-product-cart.md)

## 10. Ownership

This document was authored by **Nicolas Cartin Reyes, Lead Developer**. Any production change requires review by the Echelon storefront engineering owner.

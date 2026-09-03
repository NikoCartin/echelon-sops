# Standard Operating Procedure: UK Two-Part Equipment and Screen Cart Flow

**Document owner:** UK Ecommerce Development  
**Author:** Manus AI  
**Version:** 1.0  
**Status:** Final and validated for the UK live theme  
**Scope:** Strength+ and Row-7s two-part SKU products  
**Theme:** Copy of Dev Mega Menu, theme ID `193430749559`  
**Store:** `echelonfit-uk.myshopify.com`  
**Last updated:** 3 September 2026

## 1. Purpose and operating principle

This SOP documents the corrective implementation that ensures two-part equipment products add both physical components to the Shopify cart. The affected products are the Echelon Strength+ Smart Gym System and the Echelon Row-7s Smart Rowing Machine. Each equipment product has a separate screen product that must be present as a second cart line so the fulfilment team receives the correct order contents.

The implementation is deliberately limited to the two dedicated product templates. It does not replace the shared product-description snippet, the shared membership cart helper, the global cart drawer, the global JavaScript asset or any unrelated product template. Shopify’s Ajax Cart API supports adding cart line items through the customer’s session, and the native Liquid product object provides the selected or first available variant used by the equipment line [1] [2].

> **Core rule:** A two-part product must add the current equipment variant and its corresponding screen variant as separate Shopify cart lines. The screen must be an active product variant available to the Online Store channel before the cart request is made.

## 2. Scope and exclusions

This SOP covers the dedicated cart behavior for the following product pairs:

| Equipment product | Equipment SKU | Screen product | Screen SKU | Dedicated template |
|---|---|---|---|---|
| Echelon Strength+ Smart Gym System | `ECH-ES-5` | Strength Home Screen, packaged separately | `ECH-ES-5-SCREEN` | `product.strength-home` |
| Echelon Row-7s Smart Rowing Machine | `ECH01-ROW7` | Screen Row-7s, packaged separately | `ECH01-SCR7` | `product.cargo-row7s` |

The implementation includes dynamic resolution of the current equipment variant, dynamic resolution of the corresponding screen product variant, duplicate-screen protection, preservation of the existing UK membership flow and post-add cart behavior. The screen product is added as a separate line rather than being merged into the equipment line.

The following items are outside scope:

| Excluded item | Treatment |
|---|---|
| Shared `cargo-product-description-v3.liquid` | Do not modify for this fix. The dedicated templates call the existing shared helper. |
| Shared `app.new.min.js` and `addtocartwithwarranty` | Preserve the existing helper and its membership, delivery, warranty and promotional logic. |
| Other equipment products | Do not add screen logic unless a dedicated two-part mapping is approved and documented. |
| Orders or existing customer carts | Do not edit orders. Test in an isolated or explicitly approved browser session only. |
| Product price, inventory, title or description | Do not change as part of the cart fix. |
| Theme layouts, assets, settings and global navigation | Do not include in a two-part cart deployment. |
| Shopify selling plans or recurring billing | Not implemented by this template correction. |

## 3. Verified root cause

The two dedicated templates previously called the shared membership cart flow without adding the corresponding screen line. Row-7s appeared to work in some checks because its screen product was already available to the Online Store channel, but the template still required an explicit two-line add flow. Strength+ also had a product-availability blocker: the screen product was active but was not published to the Online Store channel, so Shopify returned `422 Cannot find variant` when the screen variant was posted to `/cart/add.js`.

The approved remediation had two parts. First, the Strength Home Screen product was published to the Online Store channel without changing its title, price or inventory. Second, only the dedicated Strength+ and Row-7s product templates were updated to resolve and add their corresponding screen variants before invoking the existing membership cart helper.

## 4. Architecture and data boundary

The public product pages remain standard Shopify Liquid product templates. The template-specific code owns only the two-part mapping and the handoff into the existing shared purchase logic. The shared helper remains responsible for membership replacement, delivery, warranty, promotional extras and the final `/cart/add.js` request.

| Layer | Responsibility | Allowed source |
|---|---|---|
| Dedicated product template | Identify the approved screen product, resolve its current variant, prevent duplicate screen lines and pass the screen variant into the existing cart flow | `templates/product.strength-home.liquid`; `templates/product.cargo-row7s.liquid` |
| Native product data | Supply the current equipment product, selected variant, title, price, availability and product URL | Shopify product and variant data |
| Screen product data | Supply the corresponding screen product and its current available variant | Shopify product reference, handle and variant data |
| Shared cart helper | Add membership, equipment, approved extras and delivery/warranty lines | Existing `addtocartwithwarranty` implementation |
| Cart session | Store the equipment, screen and membership as separate cart lines | Shopify Ajax Cart API |

The equipment variant must be read from the current product state at purchase time. A fixed equipment variant ID must not be used because a future product variant or replacement product may change the selected variant. The screen mapping is product-specific and belongs in the dedicated template, not in a global helper used by unrelated products.

The screen lookup should prefer the Shopify product reference or handle and then use that product’s `selected_or_first_available_variant.id`. A fallback may be retained for the approved screen product if the theme environment does not expose the product reference during rendering, but the screen must still be a valid Online Store product variant. Fallback values must be documented as operational data and must not be copied into a global cart helper.

## 5. Current verified product data

The following values were observed during the live verification on 3 September 2026. Variant IDs are included as a verification snapshot only. The template must resolve the current equipment and screen variants dynamically rather than assuming that these IDs will remain unchanged.

| Product role | Handle | SKU | Verified variant ID | Online Store availability |
|---|---|---|---:|---|
| Strength+ equipment | `strength-home` | `ECH-ES-5` | `54802711904631` | Available |
| Strength+ screen | `strength-home-screen` | `ECH-ES-5-SCREEN` | `54811206746487` | Published after approved correction |
| Row-7s equipment | `row-7s` | `ECH01-ROW7` | `40024239931505` | Available |
| Row-7s screen | `screen-row-7s` | `ECH01-SCR7` | `40024239964273` | Available |
| UK Premier monthly membership | `uk-premier-monthly` | `PREMIERMONTHLYUK` | `40193761738865` | Available |

The live validation also observed the expected free-delivery line for monthly-plan handling. Delivery, warranty and promotional line behavior remains controlled by the existing shared helper and is not reimplemented in the dedicated templates.

## 6. Implementation procedure

### 6.1 Confirm the Shopify product records

Before editing Liquid, open the four relevant product records in Shopify Admin and confirm that the equipment and screen products are active. Confirm the exact SKUs rather than relying only on titles. Confirm that both screen products are published to the **Online Store** sales channel. A screen product that is active but unavailable to Online Store cannot be added through the storefront cart request.

The screen product should not be added to navigation or collections merely because it is published to Online Store. Availability to the sales channel is required for the cart line, while discoverability is a separate merchandising decision. If the screen must remain hidden from normal merchandising, keep it out of collections and navigation, but do not unpublish it from the channel required by the cart flow.

### 6.2 Confirm the dedicated template assignment

Verify that Strength+ is assigned to `product.strength-home` and Row-7s is assigned to `product.cargo-row7s`. Do not change the assignment of other products as part of this SOP. A product that is using a different template will not execute the dedicated screen logic.

### 6.3 Resolve the current equipment variant

The purchase handler must read the current selected or first available equipment variant from the native product form or from the current product object. The selected variant must be read at click time, not only at initial page render, so that future variant selectors continue to work.

The code must not replace the current equipment variant with the screen variant, a product ID, a hardcoded SKU or a historic equipment variant. The two lines have different product records and must remain separate.

### 6.4 Resolve the corresponding screen variant

The Strength+ template maps to `strength-home-screen`. The Row-7s template maps to `screen-row-7s`. The dedicated template resolves the screen product’s current variant and passes that variant ID to the two-part cart helper. The mapping is intentionally kept in each dedicated template because the screen relationship is product-family-specific.

If the screen lookup returns no valid product or no available variant, the handler must not silently add an unrelated screen. It should stop the two-part add flow and preserve the normal product behavior or surface a clear error that the screen product is unavailable. Do not guess a product by title, price or image.

### 6.5 Prevent duplicate screen lines

Before adding the screen, inspect the current cart session for the corresponding screen variant. If the screen line is already present, do not add it a second time. This guard is required because customers may retry after a delayed response, return to the product page or already have the screen in their cart.

The duplicate guard must be specific to the mapped screen variant. It must not remove unrelated products, membership lines or screens belonging to another equipment family.

### 6.6 Preserve the existing membership cart behavior

After the screen line is resolved and duplicate protection is applied, the dedicated template should continue through the existing membership-aware cart flow. The shared helper remains responsible for removing an incompatible membership, adding the selected UK Premier membership, adding the equipment line and adding approved delivery, warranty or promotional extras.

Do not copy the full shared helper into either dedicated template. Duplication would allow membership pricing, delivery rules and promotional logic to drift between templates. The dedicated code should add only the two-part screen behavior and then delegate to the existing helper.

## 7. Exact files in the live correction

Only the following dedicated product templates were changed for the two-part SKU correction:

| File | Change |
|---|---|
| `templates/product.strength-home.liquid` | Added dynamic Strength screen resolution, duplicate-screen guard and two-part cart handoff. |
| `templates/product.cargo-row7s.liquid` | Added dynamic Row-7s screen resolution, duplicate-screen guard and two-part cart handoff. |

The Strength screen product publication was a separate approved Shopify product-channel operation. No product title, price, inventory, description or navigation entry was changed. No shared snippet or global asset was changed.

## 8. Validation procedure

A two-part cart correction is complete only after structural validation, direct variant availability checks and real storefront cart verification all succeed.

### 8.1 Structural checks

Run the dedicated template validator or an equivalent review before deployment. The validation must confirm the following conditions:

| Check | Acceptance condition |
|---|---|
| Liquid balance | Both dedicated templates have balanced Liquid blocks and valid syntax. |
| Template scope | Only `product.strength-home.liquid` and `product.cargo-row7s.liquid` are included in the cart patch. |
| Dynamic equipment variant | The current product variant is resolved at purchase time. |
| Screen mapping | Strength+ maps only to `strength-home-screen`; Row-7s maps only to `screen-row-7s`. |
| Screen variant | The screen variant is resolved from Shopify product data or the documented dedicated fallback. |
| Duplicate guard | An existing matching screen line is not added a second time. |
| Shared helper | Membership, delivery, warranty and promotion logic remains delegated to the shared helper. |
| No unrelated changes | No shared layout, asset, settings, global JavaScript or other template is in the deployment set. |

### 8.2 Direct screen-variant availability check

For an authorized test session, confirm that each screen variant can be added through the native Shopify cart route before testing the complete product button. The direct request is a diagnostic only; it should be removed from the test cart afterward.

The expected outcome is a separate cart line with the correct screen SKU. A `422 Cannot find variant` response indicates that the screen is not available to the Online Store channel, the variant is invalid, or the implementation is using the wrong ID. Do not solve that response by changing the equipment ID or by adding a different product.

### 8.3 Strength+ acceptance test

Open the live Strength+ PDP and select a membership plan. Activate the single purchase action once. Read `/cart.js` or the cart page and confirm that the cart contains at least these separate SKU lines:

| Expected line | Required result |
|---|---|
| `ECH-ES-5` | One equipment line |
| `ECH-ES-5-SCREEN` | One screen line |
| `PREMIERMONTHLYUK` or the selected UK Premier plan | The selected membership line |
| Delivery or other approved extras | Present only when the existing helper rules require them |

The verified live test produced `ECH-ES-5`, `ECH-ES-5-SCREEN`, `PREMIERMONTHLYUK` and the expected free-delivery line. The screen was represented as a separate zero-price line with the expected promotional gift property.

### 8.4 Row-7s acceptance test

Open the live Row-7s PDP and select a membership plan. Activate the single purchase action once. Read `/cart.js` or the cart page and confirm that the cart contains:

| Expected line | Required result |
|---|---|
| `ECH01-ROW7` | One equipment line |
| `ECH01-SCR7` | One screen line |
| `PREMIERMONTHLYUK` or the selected UK Premier plan | The selected membership line |
| Delivery or other approved extras | Present only when the existing helper rules require them |

The verified live test produced `ECH01-ROW7`, `ECH01-SCR7`, `PREMIERMONTHLYUK` and the expected free-delivery line. The screen was represented as a separate line and discounted according to the existing promotional behavior.

### 8.5 Duplicate-click and retry test

Run the purchase action twice only in an explicitly approved test session. The second attempt must not create a second matching screen line. If the existing helper intentionally adds or replaces membership lines, verify that behavior separately from the screen duplicate guard.

### 8.6 Cleanup requirement

After testing, remove only the temporary equipment, screen, delivery and promotional lines created by the test. Preserve any pre-existing customer test lines unless the session owner authorizes their removal. Do not initiate checkout or place an order as part of this SOP.

## 9. Deployment procedure

The live correction used a limited Shopify CLI push against theme `193430749559`. Future deployments must use the same principle: pull a backup, validate locally and push only the dedicated templates with `--nodelete` and explicit `--only` paths.

A representative deployment pattern is:

```bash
shopify theme pull \
  --store echelonfit-uk.myshopify.com \
  --theme 193430749559 \
  --path /home/ubuntu/two-part-sku-live-backup \
  --nodelete \
  --only templates/product.strength-home.liquid \
  --only templates/product.cargo-row7s.liquid

python3 validate_two_part_sku_templates.py

shopify theme push \
  --store echelonfit-uk.myshopify.com \
  --theme 193430749559 \
  --path /home/ubuntu/two-part-sku-live-patch \
  --allow-live \
  --nodelete \
  --only templates/product.strength-home.liquid \
  --only templates/product.cargo-row7s.liquid
```

The command must not include a full theme directory, layout files, settings, assets, global JavaScript, shared snippets or unrelated product templates. If a shared helper appears to require a change, stop and review the scope before deployment rather than expanding the push implicitly.

After the push, pull the same two files back from Shopify and compare them with the validated local source. A successful byte-for-byte comparison confirms that the intended dedicated files were deployed, but it does not replace public cart testing.

## 10. Troubleshooting guide

| Symptom | Likely cause | Corrective action |
|---|---|---|
| Equipment is added but screen is missing | Dedicated template does not pass the screen variant into the cart flow | Confirm the current template assignment and the screen mapping in the dedicated template. |
| `422 Cannot find variant` for the screen | Screen product is not published to Online Store, the variant is invalid or the wrong variant ID is used | Confirm the product’s Online Store availability and resolve the current screen variant from Shopify product data. |
| Row-7s works but Strength+ fails | Strength screen was unavailable to Online Store or its handle/variant mapping is wrong | Confirm `strength-home-screen`, SKU `ECH-ES-5-SCREEN` and Online Store publication. |
| A screen appears twice | Duplicate guard is missing or checks the wrong variant ID | Compare the cart’s screen variant ID with the dedicated mapping and stop repeated adds. |
| Membership is duplicated | The dedicated template copied or bypassed the shared helper | Restore delegation to the existing membership cart helper. |
| Membership or delivery behavior changed | Shared helper or global JavaScript was modified | Roll back unrelated files and redeploy only the dedicated template correction. |
| The page uses the old flow | The product is assigned to another template or cached HTML is being viewed | Confirm the product’s `templateSuffix`, clear the cache and inspect the live source. |
| Screen is visible in navigation unexpectedly | Publishing to Online Store was incorrectly treated as merchandising placement | Remove the screen from navigation or collections without unpublishing it from the required channel. |
| Browser cart test is blocked by Cloudflare | Public request rate limiting | Use a low-rate authorized browser session or a permitted Shopify test route. Do not mark the test as passed from a blocked request. |

## 11. Rollback procedure

If the two-part flow introduces a regression, stop testing additional products and restore only the affected dedicated template. Do not roll back the shared cart helper unless a separate approved change was made to that helper.

The rollback sequence is:

1. Identify whether the failure is limited to Strength+ or Row-7s.
2. Restore the affected template from the dated pre-change pull or the previous validated source.
3. Run the dedicated validator again.
4. Push only the reverted template with `--allow-live`, `--nodelete` and an explicit `--only` path.
5. Re-test the affected PDP and confirm that the other two-part product remains unchanged.
6. If the Strength screen product was published to Online Store only for this correction and must be withdrawn, unpublish that product from the channel as a separate approved product operation. Do not combine product publication rollback with an unscoped theme push.

A rollback must never delete the screen product, delete a screen order line from an existing order, modify customer orders or replace the shared product template.

## 12. Change-control rules

The screen relationship is a product-family rule, so every new two-part mapping requires a documented SKU pair, product handle, Online Store availability check, dedicated template owner and cart acceptance test. Do not add a new mapping to a global helper merely because two products share a visual layout.

Every future change must record the exact target theme, changed template paths, validator output, screen-product publication status, cart JSON result and cleanup result. Use the smallest possible `--only` deployment. If a product-specific change can be made in Shopify Admin rather than Liquid, prefer the product record or its approved product metafield.

The following conditions are prohibited:

| Prohibited practice | Reason |
|---|---|
| Hardcoding the equipment variant in a reusable helper | It can add the wrong equipment when variants change. |
| Guessing a screen by title, image or price | It can send the wrong physical item to fulfilment. |
| Adding a screen product that is unavailable to Online Store | Shopify will reject the cart line. |
| Copying the shared membership helper into a dedicated template | Membership and promotional rules will drift. |
| Pushing the entire theme for a two-part cart change | It increases regression risk and violates the deployment boundary. |
| Testing by submitting checkout | The cart test must not create an order. |

## 13. Verified implementation state

The live correction was verified on 3 September 2026. The Strength+ browser test produced separate equipment and screen lines after the Strength screen was published to Online Store. The Row-7s browser test produced separate equipment and screen lines using the existing published screen product. Both tests retained the selected UK Premier membership and the expected helper-managed delivery behavior.

The connected browser cart was cleaned after testing and left with only its pre-existing monthly membership line. No checkout or order was submitted. The live correction did not change FitQuest, dynamic-bike, shared layouts, global assets, settings, unrelated templates, product prices or inventory.

## References

[1]: https://shopify.dev/docs/storefronts/themes/architecture "Shopify Developer Documentation: Theme architecture"

[2]: https://shopify.dev/docs/api/liquid/objects/product "Shopify Developer Documentation: Liquid product object"

[3]: https://shopify.dev/docs/api/ajax/reference/cart "Shopify Developer Documentation: Cart API reference"

[4]: https://help.shopify.com/en/manual/online-sales-channels "Shopify Help Center: Sales channels"

[5]: https://github.com/NikoCartin/echelon-sops "Echelon Fit Shopify Development SOP repository"

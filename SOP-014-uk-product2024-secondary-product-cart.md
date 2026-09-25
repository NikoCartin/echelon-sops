# Standard Operating Procedure: UK Product2024 Secondary Product Cart Mapping

**Document owner:** UK Ecommerce Development  
**Author:** Nicolas Cartin Reyes  
**Audience:** Echelon developers, Shopify administrators and technical operators  
**Version:** 1.0  
**Status:** Final and validated for the UK live theme  
**Store:** `echelonfit-uk.myshopify.com`  
**Template:** `product.product2024-uk`  
**Last updated:** 25 September 2026

## 1. Purpose

This SOP explains how Product2024 adds an optional secondary product, such as a packaged-separately screen, to the same cart action as the primary equipment and selected UK Premier membership.

The relationship is stored in Shopify as a product-reference metafield. The template does not identify the secondary item by title, SKU text or hardcoded variant ID. If the metafield is empty, Product2024 keeps its normal primary-product and membership behavior.

Dedicated Strength+ and Row-7s mappings remain documented separately in [SOP-011](SOP-011-uk-two-part-screen-line-cart-flow.md). Use this SOP for products assigned to Product2024.

> **Core rule:** A secondary product must be a valid Shopify product reference, have an available variant and be published to the Online Store channel before Product2024 sends the cart request.

## 2. Data contract

Create this product metafield on the primary product:

| Namespace | Key | Type | Value |
|---|---|---|---|
| `custom` | `pdp_secondary_product` | Product reference | The packaged-separately product, such as the matching screen |

For the verified Stride 9s implementation, the metafield points to **Stride 9s Pro Screen, packaged separately**. Its SKU is `ECH-STRIDE-9s-22-SCREEN`.

The SKU remains an operational and fulfilment identifier. It is not the relationship key. Product references are preferred because they remain stable when a variant changes.

The secondary product must meet all of these conditions:

1. It is active.
2. It has an available variant.
3. It is published to **Online Store**.
4. It is not required to be in navigation or a merchandising collection.
5. Its title, price, inventory and SKU are not changed by this SOP.

Publishing to Online Store makes the product available to the storefront cart endpoint. It does not require adding the product to navigation or collections.

## 3. Shopify configuration procedure

### 3.1 Prepare the secondary product

Open the secondary product in Shopify Admin. Confirm the exact SKU and variant. Publish the product to the **Online Store** sales channel while leaving its merchandising placement unchanged.

Verify that its storefront URL is available. A product that is active but not published to Online Store may return `422 Cannot find variant` when the cart endpoint receives its variant ID.

### 3.2 Configure the primary product

1. Open the primary product in Shopify Admin.
2. Create or open `custom.pdp_secondary_product`.
3. Set the field type to **Product reference**.
4. Select the matching secondary product.
5. Save the product.
6. Confirm that the product uses `product2024-uk`.
7. Confirm that memberships remain configured through `custom.pdp_individual_product`.

Do not paste a SKU or variant ID into the product-reference field.

## 4. Liquid implementation

The Product2024 shell resolves the relationship from Shopify product data and exposes only the current product and variant IDs to the scoped JavaScript controller:

```liquid
assign secondary_product = product.metafields.custom.pdp_secondary_product.value
assign secondary_variant = blank
if secondary_product != blank
  assign secondary_variant = secondary_product.selected_or_first_available_variant
endif
```

The root element exposes the resolved values through data attributes. Empty metafields produce empty attributes and no secondary cart line.

The current implementation is in:

```text
snippets/uk-product2024-template-individual.liquid
```

## 5. Cart implementation

`assets/uk-product2024.js` reads the secondary product and adds its available variant alongside the primary equipment variant. When a membership is selected, the equipment, secondary product and membership receive the same `_pdp24_bundle_id`.

The relationship properties are:

```text
_pdp24_secondary_product_id
_pdp24_secondary_variant_id
```

The existing membership properties remain unchanged:

```text
_pdp24_equipment_product_id
_pdp24_equipment_variant_id
_pdp24_membership_product_id
_pdp24_membership_variant_id
_pdp24_membership_plan
_pdp24_membership_family
```

The secondary line is separate from the equipment line. This allows fulfilment to receive the required physical SKU as its own cart line.

Before adding the bundle, the controller checks the current cart for the matching secondary variant. If it is already present, it does not add a second copy. Membership replacement continues to use the existing Product2024 logic.

## 6. Membership behavior

The secondary-product relationship is independent of membership selection.

- If the product has no membership options, Product2024 adds the equipment and secondary product.
- If the product has membership options, Product2024 adds the equipment, secondary product and selected membership.
- If the metafield is empty, Product2024 keeps the normal equipment-only or equipment-plus-membership flow.
- Discount Ninja and the existing UK cart behavior remain responsible for applicable discounts and delivery rules.

Do not copy membership products or membership variant IDs into this mapping.

## 7. Acceptance testing

Complete these checks in an unpublished development theme before live deployment:

1. Run the Product2024 validator.
2. Run `node --check` against `uk-product2024.js` and `uk-product2024-lower.js`.
3. Open the primary product in the development-theme preview.
4. Confirm that the root data attributes contain the secondary product and an available secondary variant.
5. Select the intended membership plan.
6. Clear an isolated test cart.
7. Activate the primary purchase action once.
8. Read `/cart.js` or the cart page.
9. Confirm one line for the equipment, one line for the secondary product and one line for the selected membership.
10. Confirm the shared `_pdp24_bundle_id` and secondary-product properties.
11. Repeat the purchase action only in an approved test session and confirm that the matching secondary line is not duplicated.
12. Do not submit checkout or place an order.

For the verified Stride 9s implementation, the live test returned:

| SKU | Result |
|---|---|
| `ECH-STRIDE-9s-22` | One equipment line |
| `ECH-STRIDE-9s-22-SCREEN` | One separate screen line |
| `PREMIERMONTHLYUK` | One selected monthly membership line |

The cart contained three lines and no checkout or order was submitted.

## 8. Deployment boundary

The Stride 9s implementation was deployed by pushing only these Product2024 files:

```text
assets/uk-product2024.js
snippets/uk-product2024-template-individual.liquid
```

The deployment did not include layout files, global stylesheets, settings, navigation, checkout files or unrelated templates.

Use an unpublished development theme first. Pull a backup of the same files from the target theme, validate the local patch, push with `--nodelete` and explicit `--only` paths, pull the files back and compare hashes. Public cart testing is still required after a byte-for-byte match.

Representative commands:

```bash
shopify theme pull \
  --store echelonfit-uk.myshopify.com \
  --theme <theme-id> \
  --path ./backup \
  --nodelete \
  --only assets/uk-product2024.js \
  --only snippets/uk-product2024-template-individual.liquid

python3 validate_product2024_uk_faithful.py
node --check assets/uk-product2024.js
node --check assets/uk-product2024-lower.js

shopify theme push \
  --store echelonfit-uk.myshopify.com \
  --theme <theme-id> \
  --path ./product2024-patch \
  --nodelete \
  --only assets/uk-product2024.js \
  --only snippets/uk-product2024-template-individual.liquid
```

Use `--allow-live` only after the live deployment has been explicitly approved.

## 9. Troubleshooting

| Symptom | Likely cause | Corrective action |
|---|---|---|
| The equipment is added but the secondary product is missing | The product reference is empty or the theme files are not deployed | Check `custom.pdp_secondary_product`, the product template assignment and the two Product2024 files. |
| `422 Cannot find variant` | The secondary product is not published to Online Store, or the resolved variant is invalid | Publish the secondary product to Online Store and verify its available variant in Shopify. |
| The secondary product is added twice | The duplicate guard is missing or compares the wrong variant ID | Compare the cart variant ID with the resolved secondary variant and confirm the current `filterExistingSecondary` flow. |
| Membership behavior changes | The Product2024 membership flow was bypassed or copied | Restore the existing membership logic and preserve all `_pdp24_membership_*` properties. |
| A product without the metafield receives a secondary line | A product-specific fallback was hardcoded | Remove the fallback. Product2024 must add a secondary product only when the product reference resolves. |
| The product is visible in navigation after publication | Channel publication was confused with merchandising placement | Remove it from navigation or collections without unpublishing it from Online Store. |

## 10. Rollback

If the cart test fails after deployment:

1. Stop additional testing.
2. Confirm whether the issue is product publication, metafield configuration or theme code.
3. Restore the backed-up `assets/uk-product2024.js` and `snippets/uk-product2024-template-individual.liquid` only.
4. Push only those reverted files with explicit `--only` paths.
5. Re-run the validator and live cart smoke test.
6. If the product-channel publication must also be reversed, handle that as a separate approved Shopify product operation.

Do not delete the secondary product, edit existing orders or submit checkout as part of rollback.

## 11. References

[1]: https://shopify.dev/docs/api/liquid/objects/product "Shopify Liquid product object"

[2]: https://shopify.dev/docs/api/liquid/objects/metafield "Shopify Liquid metafield object"

[3]: https://shopify.dev/docs/api/ajax/reference/cart "Shopify Ajax Cart API reference"

[4]: https://help.shopify.com/en/manual/custom-data/metafields "Shopify Help Center: Metafields"

[5]: https://help.shopify.com/en/manual/online-sales-channels "Shopify Help Center: Sales channels"

[6]: https://github.com/NikoCartin/echelon-sops/blob/main/SOP-011-uk-two-part-screen-line-cart-flow.md "Echelon SOP-011: UK two-part equipment and screen cart flow"

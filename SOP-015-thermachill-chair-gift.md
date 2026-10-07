# ThermaChill Recliner Chair Gift Implementation

**Owner:** Echelon Fitness
**Lead Developer:** Nicolas Cartin Reyes
**Status:** Production implementation

## Overview

This implementation adds one Recliner Chair to the cart when a customer purchases the ThermaChill Main Unit. Shopify applies a 100% product discount to the chair line. The main unit and any selected garments remain paid.

The solution uses two coordinated layers:

1. The product page adds the chair as a separate cart line and marks it as a promotion gift.
2. A Shopify Discount Function verifies the trigger and applies the discount at checkout.

This pattern keeps the chair visible to fulfillment as a normal SKU while preventing a chair purchased without ThermaChill from being discounted.

## Architecture

### Product-page cart composition

The ThermaChill product template reads a product-reference metafield for the configured gift product. The Liquid cart handler resolves the available gift variant and includes it in the existing `/cart/add.js` request.

The request contains separate lines for:

- The ThermaChill Main Unit.
- Any selected garments.
- One marked Recliner Chair gift line.

The gift line uses explicit private properties:

```text
_thermachill_gift=true
_thermachill_gift_source=ThermaChill Main Unit
_thermachill_gift_trigger=<main-unit-variant-id>
```

The handler checks the current cart before adding the chair, so repeated submissions do not create a duplicate marked gift line.

### Shopify Discount Function

The Rust/WASM Function runs on the cart-line product discount target:

```text
cart.lines.discounts.generate.run
```

It reads a JSON configuration from the automatic discount and evaluates each cart line. The discount is returned only when:

- The cart contains the configured ThermaChill product or variant.
- The chair line matches the configured Recliner Chair variant.
- The chair line has the explicit gift marker.
- The automatic discount includes the product discount class.

The Function targets one chair unit with a 100% percentage discount. It fails closed when configuration is missing or invalid.

### Administrative controls

The Shopify Admin App Home provides controlled configuration for the trigger and gift references. It validates Shopify Product and ProductVariant IDs, detects duplicate exact-title discounts, verifies the Function-to-discount link, and stores the configuration on the automatic discount.

The existing Premier free-shipping Function remains a separate checkout concern and is not modified by the chair promotion.

## Safeguards

- The promotion is scoped to the ThermaChill product template.
- A separately purchased chair remains paid.
- Selected garments remain paid.
- Only one chair unit is discounted per cart under the current contract.
- Duplicate automatic discounts are blocked by the control plane.
- The Function fails closed when the trigger, gift variant, marker, or product discount class is absent.
- The implementation does not require a customer database or a developer-hosted runtime server.

## Verification

The production flow was tested with a controlled cart and no payment was submitted.

| Scenario | Result |
|---|---|
| ThermaChill alone | ThermaChill remained paid and one chair was added at `$0.00` |
| ThermaChill plus a garment | The garment retained its normal price and only the chair was discounted |
| Gift eligibility | The discount required both the ThermaChill trigger and the marked chair line |
| Deployment | The corrected theme file was pulled back and matched the deployed source |

The promotion uses the public Recliner Chair SKU `CHR-TC01` so fulfillment can process the gift as an ordinary order line.

## Maintenance guidance

When the gift product or variant changes:

1. Verify the product and inventory in Shopify Admin.
2. Update the product-reference metafield on the ThermaChill product.
3. Update the automatic discount configuration through the App Home.
4. Confirm the Function remains linked to the exact-title automatic discount.
5. Repeat the controlled cart acceptance tests.

Do not replace this flow with a broad site-wide discount. Any change to gift quantity, campaign eligibility, or trigger products must update both the cart-line contract and the Function tests.

## References

[1]: https://shopify.dev/docs/apps/build/discounts/build-discount-function "Build a Shopify Discount Function"
[2]: https://shopify.dev/docs/api/functions/latest/discount "Shopify Discount Function API"
[3]: https://shopify.dev/docs/api/admin-graphql/latest/mutations/discountAutomaticAppCreate "discountAutomaticAppCreate mutation"
[4]: https://echelonfit.com/products/thermachill "ThermaChill product page"

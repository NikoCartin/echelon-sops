# SOP-028: Shop Pay Installments Fallback for the PDP Financing Slot

**Author:** Nícolas Cartín Reyes, Lead Developer
**Date:** October 28, 2026
**Scope:** Echelon US product template `snippets/product-template-individual.liquid` and cart
**Status:** Live stopgap while the ChargeAfter promotional widget is empty

## Purpose

The ChargeAfter "as low as $X/mo" widget next to the PDP price stopped rendering (the vendor API returns an empty widget). This SOP documents the Shop Pay Installments message placed in the same slot, how it hides itself when ChargeAfter returns, and the related mobile layout fix.

## Implementation

- The PDP price block renders `{{ form | payment_terms }}` inside a product form, extracts the `shopify-payment-terms` element and places it in `.pdp-shop-pay-installments`, next to the existing `.ca-promotional-widget`.
- A `MutationObserver` watches the ChargeAfter widget. As soon as it gets child elements, the wrapper `.custom-content-financing-widget` receives the class `ca-loaded` and CSS hides the Shop Pay message, so the two never show together.
- Shopify generates the text ("From $X/mo with Shop"), the legal terms and the (?) details modal. Do not hard-code amounts.
- ThermaChill uses its own mobile header, so it has a separate `thermachill-main-unit__mobile-installments` container under the price.
- The cart already showed the Shop Pay monthly price and was not changed.

## Related bug fix

A ThermaChill-only CSS rule in `pdp-2025.css` hid the title, price and financing slot on screens up to 1024 px for every product using the template. The rule is now scoped to the ThermaChill template. When adding template-specific CSS, always scope it to that template's wrapper class.

## Verification

1. Open Stride-6, Summit 22" and ThermaChill at 390 x 844 and 1440 x 900.
2. Confirm the title, price and "From $X/mo with Shop" line are visible.
3. Open the (?) modal and confirm the terms load.
4. Confirm there are no Liquid errors in the page source.

## When ChargeAfter is fixed

1. Confirm the ChargeAfter widget renders content on a PDP.
2. Confirm the Shop Pay message hides itself.
3. Decide with the business owner whether to keep Shop Pay as a fallback. Consumer financing should route to ChargeAfter and commercial financing to Ascentium.

## Rollback

Restore the backed-up `snippets/product-template-individual.liquid` with a partial push (`--only`, `--nodelete`) and verify the three PDPs again.

# SOP-027: Premier Monthly 30-Days Free Trial Operations

**Author:** Nícolas Cartín Reyes, Lead Developer
**Date:** October 28, 2026
**Scope:** Echelon US storefront, custom app discount function and theme messaging
**Status:** Live; permanent business rule

## Purpose

This SOP explains how the 30-Days Free Trial works, how to check it, how to change it safely and who must be told before changes. The full engineering reference is the developer guide in the custom app repository (`docs/premier-first-month-free-developer-guide.md`).

## How it works

- **Offer:** Premier Monthly is $0 for the first month when bought with eligible equipment. The equipment price does not change.
- **Eligibility:** dynamic. Equipment qualifies when its product metafield `custom.pdp_individual_product` lists the Premier Monthly product, which is the same list the PDP uses to offer memberships. There is no SKU allowlist.
- **Discount:** an automatic app discount named `30-Days Free Trial`, created from the custom app's admin page, that runs the `premier-first-month-free` cart discount function. It takes 100 percent off one Premier Monthly line. It has no end date and no usage limit.
- **Theme:** the 30-Days membership card shows a "Free Trial" badge and "Then $39.99/mo. Cancel anytime." The cart shows "Free for 30 days, then $39.99/mo." and a discount row only when a discount with "Free Trial" in its title is applied.
- **Billing:** no SKU, product or price is changed. The Shopify order reaches Stripe through a webhook, the customer receives an activation email and adds the card on file there, and Stripe bills the membership price 30 days later.

## Routine check (no real order)

1. Open an eligible PDP, for example Stride-6, and choose the 30-Days membership.
2. Add to cart. The cart must show the membership as Free, the "30-Days Free Trial" discount row and an unchanged equipment price.
3. Negative check: add Premier Monthly without equipment. No discount should apply.
4. Stop before payment. Do not place a real order to test.

## Making a new product eligible

Add the Premier Monthly product to the equipment product's `custom.pdp_individual_product` metafield. No code change is needed. Run the routine check on that product.

## Changes that need approval first

- Title, end date, usage limit or combination settings of the discount.
- Membership price or eligibility rules.
- Any SKU change on the membership products. Tell the CTO (owner of the Stripe and billing integration) the new SKU before it goes live.
- Customer-facing trial wording. Confirm with the performance and marketing team.

## Deployment

1. Develop on a feature branch of the custom app repository.
2. Deploy with `shopify app deploy` only after approval, because it changes live checkout.
3. Open a pull request and merge it to `main` after the deploy so the repository matches production.
4. For theme changes, follow the controlled release in SOP-026, section 5.

## Rollback

- **Stop the offer:** deactivate the `30-Days Free Trial` automatic discount in Shopify admin (Discounts). The theme messaging hides itself when the discount is not applied.
- **Function rollback:** release the previous app version from the Partner dashboard, then repeat the routine check.

## Troubleshooting

| Symptom | Check |
|---|---|
| Badge shows but the cart still charges $39.99 | Is the automatic discount active, and is its title still `30-Days Free Trial`? |
| A product that should qualify does not | Does its `custom.pdp_individual_product` metafield include Premier Monthly? |
| Function not found when creating the discount | The app version with the function is not released or the app is not installed. |

# SOP-029: In-App Browser and Mobile Checkout Testing Without Real Orders

**Author:** Nícolas Cartín Reyes, Lead Developer
**Date:** October 28, 2026
**Scope:** Echelon storefront checkout on phones, including social app browsers
**Status:** Approved test procedure

## Purpose

Social traffic converts worst at checkout, and most of it opens inside the Instagram, Facebook or Snapchat in-app browser. This SOP describes how to test the full mobile checkout in those browsers without placing a real order or spending money.

## Rules

- Never place a real order to test. Stop at the last step before payment is captured.
- Use a test shipping address, not a customer's.
- Do not cancel or edit real orders to work around a test.

## Getting into the in-app browser

1. Send yourself the product URL in Instagram, Facebook Messenger or Snapchat, or tap a live ad.
2. Open the link inside the app. Do not choose "Open in browser".
3. Confirm you are in the in-app browser: the app's own toolbar shows at the top.

## Test matrix

Run each row on a real phone, in each in-app browser and in Safari or Chrome as a control:

| Step | Pass condition |
|---|---|
| PDP | Title, price and monthly price visible; Add to cart works |
| Cart | Chat bubble does not cover buttons; no game popup once the cart has items; Check out visible |
| Checkout information | Address autocomplete works; shipping rates load |
| Shop Pay | Opens and can be closed |
| PayPal | Opens, and the shopper can return to checkout |
| Apple Pay / Google Pay | Payment sheet opens; cancel before authorizing |
| Financing (ChargeAfter) | Window opens without warnings; lenders are selectable; load time noted |

## Recording results

- Take screenshots of each failure with the time and app version.
- Note whether the issue comes from the theme (fixable by us) or a vendor window (send to the vendor through the account owner).
- Cross-check analytics: compare checkout-to-cart rates by channel in Shopify, since pixel-based tools can under-report checkouts.

## Known vendor finding

As of October 28, 2026 the ChargeAfter window shows an "Update Your Browser" banner inside in-app browsers. This is vendor side and has been escalated.

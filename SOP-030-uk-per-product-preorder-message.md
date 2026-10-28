# SOP-030: UK Per-Product Pre-Order Message

**Author:** Nícolas Cartín Reyes, Lead Developer
**Date:** October 28, 2026
**Scope:** Echelon UK `Dynamic2026-UK` product template
**Status:** Live on Stride-6s-10

## Purpose

Some UK products are sold before stock arrives. This SOP explains how to show a pre-order message and a "Pre-order now" button label on one product without affecting any other product.

## How it works

- Optional product metafield `custom.preorder_message` (single line text, admin name "Pre-order message").
- When the metafield has a value, the template renders the message under the add-to-cart button and changes the available button label to "Pre-order now".
- Products without the metafield are unchanged.
- The product must be assigned to the `Dynamic2026-UK` template.

## Turning it on for a product

1. Confirm the product uses the `Dynamic2026-UK` template.
2. Confirm the product can be bought: inventory policy allows selling, or stock has been added, and it is available on the Online Store.
3. Enter the approved message in `custom.preorder_message`, for example the expected dispatch date and the quantity arriving.
4. Check the PDP on mobile and desktop.

## Turning it off

Clear the metafield when stock arrives. The message and label revert on the next page load. No theme change is needed.

## Rules

- Message wording comes from the UK team and must be approved.
- Do not change inventory or "continue selling when out of stock" settings without the stock owner's approval.

## Source

Code and changelog are in the `Dynamic2026-UK` repository (pull request #1 for the feature, #2 for the October 28 accessibility sync).

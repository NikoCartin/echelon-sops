# SOP-001: Editing the Membership Upgrade Modal

**Store:** echelonfit.com (Echelon Fit Shopify Store)  
**Template:** `main-cart-pdp-2025`  
**Section file:** `sections/membership-popup.liquid`  
**Last updated:** July 2026

## 1. Overview

The Membership Upgrade Modal is a custom Shopify section that appears when a customer clicks "Add to Cart" on eligible product pages. It prompts the customer to choose between a 1-Year or 2-Year membership plan and controls which free gift products are added to the cart alongside the subscription.

There are two separate systems that must be kept in sync when editing this modal:

| System | Controls |
|--------|----------|
| Theme Customizer (Blocks) | What freebies are **displayed** in the modal UI |
| Section Code (`membership-popup.liquid`) | What freebies are **actually added to the cart** |

Editing only one without the other will cause a mismatch between what the customer sees and what ends up in their cart.

---

## 2. Part 1 — Editing Displayed Freebies via the Theme Customizer

Use this method to add, remove, or reorder the gift items shown visually inside the modal.

**Step 1:** Navigate to **Shopify Admin → Online Store → Themes → (live theme) → Customize**

**Step 2:** In the page selector at the top, switch to a Product page that uses this modal (e.g., the Echelon Meridian Pilates Reformer).

**Step 3:** In the left sidebar, scroll down and click on the section named **"Membership Popup"**.

**Step 4:** Manage freebie blocks. Each block represents one gift item displayed in the modal.
- To **remove** a freebie: click the block → click the trash/delete icon.
- To **add** a freebie: click "Add block" → select "Freebie" → configure the product, title, image, and price fields.
- To **reorder** freebies: drag and drop the blocks.

> **Important:** The last block in the list appears only in the 2-Year column. All other blocks appear in both columns. This is controlled by the `limit:num_freebies` logic in the Liquid template.

**Step 5:** Click **Save**.

---

## 3. Part 2 — Editing Cart Logic via the Code Editor

Use this method when changing which product variant IDs are actually added to the cart. This must always be updated to match the blocks configured in Part 1.

**Step 1:** Duplicate the live theme as a backup before making any code changes.

**Step 2:** Navigate to **Shopify Admin → Online Store → Themes → (live theme) → Edit code**

**Step 3:** In the left sidebar under **Sections**, locate `membership-popup.liquid`.

**Step 4:** Use `Ctrl+F` and search for `getItems(type)` to locate the Subscription config block.

**Step 5:** Edit the `items` arrays. The relevant block looks like this:

```javascript
oneYear: {
  variantId: CONFIG.ONE_YEAR_VARIANT,
  items: [CONFIG.ONE_YEAR_VARIANT],
  specialProps: null
},
twoYear: {
  variantId: CONFIG.TWO_YEAR_VARIANT,
  items: [CONFIG.BUNDLE_PRODUCT_2, CONFIG.TWO_YEAR_VARIANT],
  specialProps: { '_annual': generateUniqueKey(CONFIG.VARIANT_ID) }
},
```

- To **remove** a freebie from cart: delete its `CONFIG.*` entry from the array.
- To **add** a freebie to cart: add a new `CONFIG` constant at the top of the script and include it in the array.

**Step 6:** Search for `bundleCartItems` and apply the same changes to keep both cart paths consistent.

**Step 7:** Click **Save** and test on the live product page.

---

## 4. CONFIG Key Reference

| CONFIG Key | Variant ID | Product |
|------------|-----------|---------|
| `ONE_YEAR_VARIANT` | `30135749771346` | 1-Year Membership |
| `TWO_YEAR_VARIANT` | `32930539503698` | 2-Year Membership |
| `BUNDLE_PRODUCT_2` | `44944771612871` | Merch Voucher ($100 Apparel Credit) |
| `VARIANT_PRODUCT` | `44940605554887` | Heart Rate Monitor *(removed July 2026)* |
| `BUNDLE_PRODUCT_1` | `37737276637383` | 4-Year Extended Warranty *(removed July 2026)* |

---

## 5. What Each Plan Adds to Cart

| Plan | Items Added to Cart |
|------|-------------------|
| Monthly (trial) | Product + Monthly Subscription |
| 1-Year Upgrade | Product + 1-Year Membership |
| 2-Year Upgrade | Product + Merch Voucher + 2-Year Membership |
| Cancel / Continue Monthly | Product + Monthly Subscription (no upgrade) |

---

## 6. Changes Made — July 2026

| What was changed | Where | Result |
|-----------------|-------|--------|
| Removed "4-Year Extended Warranty" block | Theme Customizer → Membership Popup blocks | No longer displayed in modal UI |
| Removed "Heart Rate Monitor" block | Theme Customizer → Membership Popup blocks | No longer displayed in modal UI |
| Removed `CONFIG.VARIANT_PRODUCT` and `CONFIG.BUNDLE_PRODUCT_1` from `oneYear` items | `membership-popup.liquid` JS — `Subscription.getItems()` | No longer added to cart on 1-year upgrade |
| Removed same items from `twoYear` items | `membership-popup.liquid` JS — `Subscription.getItems()` | No longer added to cart on 2-year upgrade |
| Removed same items from `bundleCartItems` block | `membership-popup.liquid` JS — `handleAddToCartButtonClick()` | No longer added via direct add-to-cart path |
| Kept `CONFIG.BUNDLE_PRODUCT_2` (Merch Voucher) in `twoYear` items | `membership-popup.liquid` JS | Merch Voucher still added to cart on 2-year upgrade |

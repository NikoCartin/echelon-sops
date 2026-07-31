# SOP-005: Upsell & Cross-Sell App (Selleasy)

**Store:** Echelon Fit Shopify Stores  
**Category:** E-commerce Operations & App Configuration  
**Last updated:** July 2026

## 1. Purpose

Selleasy is used in Shopify to create upsell and cross-sell offers that help increase average order value (AOV). It displays related or complementary products based on the product the customer is viewing or adding to the cart.

## 2. How Selleasy Works

The setup follows a 4-step flow:

### 1. Select the Campaign Type
Selleasy supports 18 different campaign types (e.g., product page upsells, add-on offers, cart-related cross-sells, pre-purchase offers). The type determines where and how the offer appears.

### 2. Create the Campaign
A campaign consists of 3 main elements:
- **Trigger Products:** The main products the customer interacts with (selected by individual product, collection, or tag). E.g., Treadmill Collection.
- **Offer Products:** The complementary items being promoted. E.g., Socks.
- **Optional Discount:** Incentivizes buying both items (e.g., percentage off, bundle pricing).

### 3. Test in Store
After creation, verify the campaign in the storefront:
- Enable the Selleasy app embed in Theme Settings.
- Add necessary app blocks in the Theme Editor.
- Verify the widget appears on the correct page, triggers on the right product, displays the correct offer, applies discount logic, and functions without breaking the theme layout.

### 4. Customize and Troubleshoot
Adjust widget positioning, styling, layout, or custom CSS within the Selleasy app to resolve conflicts with theme CSS or mobile responsiveness.

## 3. Internal Understanding & Documentation

Selleasy depends on both **App-side configuration** (campaigns, triggers, discounts) and **Theme-side integration** (app embeds, app blocks, CSS).

Whenever installing, debugging, or modifying Selleasy, document the following:
1. **App Status:** Active/inactive, app embed enabled.
2. **Campaign Details:** Type, triggers, offers, discounts, affected pages.
3. **Theme Integration:** App block locations, templates affected, custom CSS added.
4. **Testing Performed:** PDP, cart, mobile, add-to-cart logic.
5. **Issues & Fixes:** Note any styling breaks, overlapping elements, or JS conflicts, and how they were resolved.

## 4. Troubleshooting Checklist

If Selleasy is not working, check:
1. Is Selleasy installed and active?
2. Is the correct campaign type selected?
3. Are trigger and offer products configured correctly?
4. Is the Selleasy app embed enabled in the theme?
5. Are app blocks added in the theme editor where required?
6. Is the theme hiding or breaking the widget with CSS?
7. Are there conflicts with another app or script?

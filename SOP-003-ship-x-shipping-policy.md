# SOP-003: Ship-X Shipping Policy & Setup

**Store:** Echelon Fit Shopify Stores  
**Category:** E-commerce Operations & Shipping  
**Last updated:** July 2026

## 1. Purpose

This document defines the standard process for configuring and troubleshooting shipping in Shopify when shipping behavior is controlled by the **Ship-X** app. It ensures teams launch new products correctly, understand scenario logic, use correct product tags, and avoid conflicts with Shopify manual shipping rates.

## 2. Policy Summary

**Core Rule:** If a product is intended to use Ship-X-controlled shipping, **do not create overlapping manual Shopify shipping rates** unless there is a specific documented exception.

Overlapping rates cause duplicate shipping methods, incorrect prices, or conflicting standard/premium delivery options at checkout.

## 3. How Ship-X Works

Ship-X controls shipping through **scenarios**. Each scenario includes conditions, shipping rates, and a status (Active/Inactive).

Scenarios evaluate:
- Product tags
- Product SKU
- Product/Cart weight
- Cart quantity/total

Scenarios can apply to:
- **Any product in cart:** At least one matching product triggers the scenario.
- **All products in cart:** Every product in the cart must meet the condition.

## 4. Standard Operating Procedure

### Step 1: Confirm the Shipping Strategy
Determine if the product should use Ship-X scenario-based shipping, manual Shopify shipping, promotional shipping, or heavy-equipment shipping.

### Step 2: Verify Product Setup in Shopify
Confirm the product is marked as physical, weight and package dimensions are accurate, and fulfillment location is correct. *Weight errors can cause the wrong Ship-X scenario to trigger.*

### Step 3: Verify Required Tags
Apply the correct shipping, promotional, membership, or bundle tag. Remove outdated or conflicting tags.

### Step 4: Check Existing Ship-X Scenarios
Review whether an active scenario already exists for the product tag, SKU, or cart weight.

### Step 5: Check for Manual Shopify Rate Conflicts
Ensure no overlapping manual rates exist in Shopify under *Settings > Shipping and delivery*.

### Step 6: Test Checkout
Test the product alone and with expected cart conditions to confirm options appear correctly without duplicates.

## 5. Tag and Scenario Reference

| Tag | Scenario | Use Case |
|-----|----------|----------|
| `freeshipping2026` | Free Shipping with 1 and 2 Year Plan | Free shipping tied to 1- and 2-year plan campaigns |
| `multifunction-dumbbells` | Multifunction Dumbbells free shipping | Free shipping for specific dumbbell products |
| `maw2025` | MAW 2025 | Promotional shipping (Cart total >= $50) |
| `lower_shipping` | Lower Shipping Price | Lower pricing for specific heavy items (Cart weight <= 100 lb) |
| `year_50%` | Half Price of Shipping with Annual Premier | Half-price shipping for annual subscription promotion |
| `Subscription` | Premier | Subscription products only (Product weight = 0 lb) |
| `Merchandise` | Merchandise | Standard merchandise (Product weight <= 50 lb, All products in cart) |
| `outlet, commercial, Disney` | Above 150lbs | Higher-weight shipping (Cart weight >= 150 lb) |

## 6. Troubleshooting Guide

### No Shipping Option Appears
Check for missing tags, inactive scenarios, incorrect product weight, or a conflicting Shopify manual rate.

### Wrong Shipping Price Appears
Check for wrong/extra tags on the product, wrong weight thresholds, or overlapping scenarios.

### Duplicate Shipping Options Appear
A manual Shopify rate exists alongside the active Ship-X scenario.

### Large Equipment Shipping Is Incorrect
Verify product weight accuracy and cart weight thresholds (commonly 100 lb, 149.99 lb, 150 lb). Confirm if the scenario uses *product weight* or *cart weight*.

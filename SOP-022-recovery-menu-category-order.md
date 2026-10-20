# SOP-022: Recovery Menu Category Order

**Author:** Nícolas Cartín Reyes, Lead Developer

## Purpose

Reorder the category items inside an existing Shopify mega menu while preserving their destinations, product cards and responsive behavior.

## Scope

This SOP applies to menu content managed through Shopify Navigation. It does not require Liquid, CSS or JavaScript changes when the existing mega-menu renderer already consumes the menu item order.

## Procedure

1. Confirm the target store and open the menu used by the Recovery navigation item.
2. Record the current child-item order and destination for each category.
3. Move the child items into the approved order using Shopify Navigation.
4. Save the menu and reopen it to confirm the order persisted.
5. Check the desktop mega menu and the mobile submenu. Confirm that the active state, category links, product cards and Shop All link remain intact.
6. Open each category link and verify it resolves to the intended collection.

## Example acceptance order

For a recovery menu containing these categories, the approved order can be:

1. Plunges
2. Compression
3. Chillers
4. Sauna

Use the current business-approved order for the store rather than copying this example blindly.

## Rollback

Restore the previous child-item order in Shopify Navigation. Do not edit theme code unless inspection proves the menu renderer, not the menu data, is responsible for the ordering issue.

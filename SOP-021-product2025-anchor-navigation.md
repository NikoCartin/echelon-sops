# SOP-021: Product2025 Anchor Navigation

**Author:** Nícolas Cartín Reyes, Lead Developer

## Purpose

Keep the top navigation on a custom Product2025 product page connected to the sections it labels. The navigation should move the customer to real content without changing product purchase logic.

## Scope

This SOP covers a Product2025 top-banner section, its product-page template settings and an optional anchor on the membership selector. It is intended for pages with sections such as Features, Specs, Premier Membership and Accessories.

## Implementation

1. Pull the current theme and identify the template suffix used by the product.
2. List the actual section IDs in the template before editing any link.
3. Configure each label with a real fragment identifier. Do not invent an ID from the label text.
4. If the product title is used as the first navigation item, point it to the page's main content anchor instead of `#`.
5. Add a stable membership anchor only to the intended Product2025 path. Do not change the membership cart logic.
6. Keep the navigation JSON, target section IDs and Liquid wrapper in the same QA release.

## Validation

In an unpublished theme:

- Click every navigation item and confirm that the URL fragment changes.
- Confirm that the viewport lands on the requested section, not only on the top of the page.
- Check desktop and mobile layouts.
- Confirm the membership selector, add-to-cart control and product gallery still work.
- Check for missing IDs, empty `href` values, console errors and horizontal overflow.

After deployment, pull back the changed files and repeat the public smoke test. If a section ID changes later, update the link and target in the same reviewed release.

## Rollback

Restore the pre-release navigation section, snippet or template JSON from the live pullback. Push only the affected files. Never replace the full theme to repair one anchor.

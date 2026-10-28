# SOP-026: WCAG 2.2 AA Theme Audit and Remediation

**Author:** Nícolas Cartín Reyes, Lead Developer
**Date:** October 28, 2026
**Scope:** Echelon US, CA and UK Shopify themes; Primal Strength through a handoff kit
**Status:** Approved technical reference

## Purpose

This SOP defines the repeatable process used to audit a Shopify theme against WCAG 2.2 Level AA, fix the issues in an unpublished copy, publish only the changed files, and document what remains outside the theme. It was used for the US release on October 27, 2026 and the CA and UK releases on October 28, 2026.

Passing this SOP means the automated scan is clean on the tested pages and the listed manual checks pass. It is not a legal opinion or a full conformance certificate.

## Scope and non-goals

In scope: theme Liquid, CSS and JavaScript; the accessibility options launcher; the accessibility statement page; alt text in product descriptions.

Out of scope: Shopify checkout, page-builder pages such as Replo (owned by marketing), and third-party widgets (chat, financing, reviews, upsell, game popups, cookie banner). Record these as known limitations and send them to their owners.

## Prerequisites

- Theme access for the target store through Shopify CLI.
- A free theme slot. If the store is at the 100-theme limit, get approval to delete an older unused copy first.
- Node.js with Playwright and a local copy of `axe-core`.
- A list of representative pages: home, one collection, two or three PDPs, cart, search, membership page, accessibility statement, one blog or content page.

## Procedure

### 1. Baseline

1. Confirm the store and the live theme ID with `shopify theme list`.
2. Duplicate the live theme in admin and name it `Dev ADA <store> <date>`.
3. Pull the live theme into a local folder and commit it as `live baseline <date>`. Every later diff is measured against this commit.
4. Run the automated scan on the live theme at 390 x 844 (mobile) and 1440 x 900 (desktop) with the `wcag2a`, `wcag2aa`, `wcag21aa` and `wcag22aa` tags. Save the JSON results.
5. Mock or block geolocation redirects and dismiss cookie banners in the scan script so they do not hide the page.

### 2. Fix in the dev theme

Work through findings in this order, because the early ones affect the most users:

1. **Keyboard and focus:** popups and drawers trap focus while open and return focus when closed; closed menus and drawers are removed from the tab order (`inert` or `hidden`); elements with `role="button"` respond to Enter and Space; focus outlines are always visible and meet 3:1 contrast.
2. **Names and alternatives:** meaningful images get alt text, decorative images get `alt=""`; icon buttons, links and iframes get accessible names or titles.
3. **Contrast:** text must reach 4.5:1 (3:1 for large text). Check text over photos and gradients by hand, because the scanner cannot measure it.
4. **Structure:** one `h1` per page, ordered headings, lists marked up as lists, landmarks present.
5. **Carousels and media:** dots and arrows have names and a 24 x 24 px minimum target; autoplay has a pause control; scrollable regions are focusable.
6. **Forms:** every input has a label; errors are announced.

Keep store-wide CSS and small shared scripts in one snippet, `snippets/a11y-fixes.liquid`, rendered before `</body>`. Edit the original section or snippet when the fix is markup, so the source stays clean.

### 3. Accessibility launcher and statement

1. Install the launcher (`snippets/accessibility-launcher.liquid` and `assets/accessibility-launcher.js`) following SOP-024.
2. Update the accessibility statement page. It must name WCAG 2.2 AA, list known third-party limitations, give a phone number and a support link, and carry a "last updated" date. Back up the old page body before replacing it, and get approval for the new text.

### 4. Review and approval

1. Rescan the dev theme with `?preview_theme_id=<dev theme ID>`.
2. Test by hand with the keyboard only: open the menu, search, add to cart, open the cart drawer, and reach checkout.
3. Send preview links and the list of changed files for approval.

### 5. Controlled live release

1. Pull the live versions of the changed files and confirm they still match the baseline commit. If any file changed on live, merge the live change first.
2. Save a backup of those live files in a dated folder.
3. Push only the changed files: `shopify theme push --theme <live ID> --only <file> ... --nodelete --allow-live`.
4. Pull the files back and confirm they match the approved versions byte for byte.
5. Rescan the live pages at both viewports and save the results.

### 6. Handoff when there is no direct access

For a store without theme access (Primal Strength), package the snippets, the scan script and written step-by-step instructions as a kit for the developer who has access, with the same approval and release rules.

## Acceptance criteria

- Zero automated WCAG 2.2 AA violations on every tested page at both viewports.
- Full keyboard path from home to checkout with visible focus throughout.
- The statement page is live, dated and approved.
- Live files match the approved files; backups exist.

## Rollback

Push the backed-up files to the live theme with `--only` and `--nodelete`, pull them back and rescan. Never roll back with a full-theme push.

## Known limitations to report

List each remaining item with its owner: page-builder pages (marketing), checkout (Shopify), third-party widgets (each vendor), and manual screen-reader testing (VoiceOver and NVDA on key pages and checkout).

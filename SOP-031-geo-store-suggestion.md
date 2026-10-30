# SOP-031: Geo Store Suggestion for Regional Shopify Stores

**Author:** Nícolas Cartín Reyes, Lead Developer
**Date:** October 29, 2026
**Scope:** Echelon US theme first; CA, UK, DE and FR stores after the US release
**Status:** Approved technical reference; live on US, Canada, UK, Germany and France (October 29–30, 2026)

## Purpose

This SOP replaces IP-based auto-redirects with a store suggestion. Visitors from another country see a short dialog offering their regional store. They choose; the site never moves them on its own.

## Why not auto-redirect

- Third-party IP lookups add a request on every page, rate-limit, and send the visitor's IP to another company.
- Redirects also move search engine crawlers, which can stop regional pages from being indexed.
- Same-path redirects land on 404s when product handles differ between stores.
- Google and Shopify both recommend suggesting a store instead of forcing one.

## How it works

- Country comes from Shopify's own `/browsing_context_suggestions.json`. No third-party API.
- A country-to-store map in `snippets/geo-store-suggest.liquid` decides which store to suggest. Unmapped countries see nothing.
- The dialog is centered, shows the country flag (inline SVG), and has two actions: "Go to [store]" and "Stay on [current store]".
- "Go" opens the same product, collection or page on the target store when it exists there (checked against Shopify's public `.js` / `.json` endpoints); otherwise it opens the home page.
- The dialog waits until the cookie banner is closed and pauses other promo popups while it is open.
- The choice is stored for 14 days only if preferences or functional consent is given (OneTrust group `C0003` or the Shopify Customer Privacy API). Without consent it lasts for the session only.
- Germany (Consentmo) and France (Axeptio): the dialog waits until the cookie banner is answered, and the choice is kept for 14 days only after the visitor accepts. Shopify's privacy API reports "allowed" before these banners are answered, so the snippet reads the banner state directly.
- It never runs for crawlers, in the theme editor, or on checkout and admin URLs.
- `snippets/footer-region-links.liquid` adds region links in the footer so any visitor can switch stores manually.

## Accessibility

- `role="dialog"`, `aria-modal`, labelled heading, focus moves into the dialog and is trapped, Escape closes it, focus returns afterwards.
- Buttons meet WCAG 2.2 AA contrast and target size. Run axe-core on the open dialog before release.

## Installing on a store

1. Duplicate the live theme as an unpublished dev copy.
2. Add both snippets. In `layout/theme.liquid`, remove the old IP redirect script and add `{%- render 'geo-store-suggest' -%}` before `</body>`.
3. Render `footer-region-links` in the footer section.
4. Update the country map and store URLs for this store, and remove the current store from the suggestions.
5. Test with `?geo_test=CA&geo_reset=1` (replace the country code), on desktop and mobile, with cookies accepted and declined.
6. Follow the controlled release steps: pull live, confirm unchanged, back up, push only the changed files, pull back and verify.

## QA checklist

- Each mapped country shows the right flag and store; the current store's country and unmapped countries show nothing.
- Deep link opens the same product, collection or page, or the home page if it doesn't exist.
- Choice remembered for 14 days with consent; session only without.
- Dialog appears after the cookie banner, not on top of it.
- axe-core shows 0 violations with the dialog open.

## Reference

Open-source starter: [shopify-geo-store-suggestion](https://github.com/NikoCartin/shopify-geo-store-suggestion).

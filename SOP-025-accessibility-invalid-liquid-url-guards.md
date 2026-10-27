# SOP-025: Guarding Optional Liquid Image URLs

**Author:** Nícolas Cartín Reyes, Lead Developer
**Date:** October 26, 2026
**Scope:** Shopify Liquid sections that render optional product images or CSS background images
**Status:** Published as a reusable QA implementation reference

## Purpose

Prevent optional Shopify image settings from producing invalid `Liquid error` output in rendered HTML or CSS. An empty image picker must not be passed into `image_url`, and a background rule should not emit `url()` when its source is absent.

This SOP is a focused accessibility and rendering safeguard. It does not certify ADA or WCAG conformance and does not replace semantic, keyboard, screen-reader, contrast or assistive-technology testing.

## Symptoms

Inspect the rendered HTML and CSS for patterns such as:

- An image source containing `Liquid error`.
- A CSS declaration containing `background-image: url(Liquid error...)`.
- A broken or empty image request from a hidden membership, gift or promotional block.
- An optional image setting that is blank in Theme Editor but is still passed to `image_url`.

## Prerequisites

- A current pull of the target theme or an approved duplicate theme.
- A product or page where the affected section is rendered.
- Confirmation of the intended fallback when the optional image is missing.
- A mobile viewport and a desktop viewport for validation.
- A rollback copy of every file in scope.

## Safe implementation pattern

Guard the source before applying `image_url`:

```liquid
{% if block.settings.product != blank and block.settings.product.images[0] != blank %}
  <img src="{{ block.settings.product.images[0] | image_url }}" loading="lazy">
{% elsif block.settings.alt_image != blank and block.settings.alt_image.image != blank %}
  <img src="{{ block.settings.alt_image.image | image_url }}" loading="lazy">
{% endif %}
```

For CSS, emit the rule only when the setting exists:

```liquid
{% if section.settings.background_image != blank %}
  .section-{{ section.id }} {
    background-image: url({{ section.settings.background_image | image_url }});
  }
{% endif %}
```

Use the setting ID defined in the section schema. Do not reference a similarly named or undefined setting as a fallback.

## Controlled QA procedure

1. Pull the current files from the approved QA theme.
2. Identify every `image_url` and CSS `background-image` expression in the affected section.
3. Add the smallest possible guard around optional sources.
4. Preserve existing product, cart, checkout and section behavior.
5. Validate the Liquid file and inspect the rendered source.
6. Push only the approved files with deletion disabled.
7. Pull the same files back and compare hashes.
8. Test the target page at a narrow mobile width and a desktop width.
9. Check HTTP status, `Liquid error` strings, image sources, CSS `url()` values and horizontal overflow.
10. Record unrelated third-party console or network signals separately instead of attributing them to the guard.

## Acceptance criteria

- The target page returns HTTP 200.
- No rendered image source contains `Liquid error`, `undefined` or `null`.
- No rendered CSS `url()` value contains `Liquid error`, `undefined` or `null`.
- Missing optional images fail closed without creating broken image requests.
- Existing valid images still render.
- The page has no new horizontal overflow at mobile or desktop widths.
- Product browsing, membership selection, cart behavior and checkout handoff remain outside the change scope and are not regressed.
- The QA pullback hashes match the approved files.

## Troubleshooting

If an error remains, inspect every rendered instance of the section. A section can contain separate desktop, mobile, popup and fallback branches. Check both the image setting ID and the schema definition. Also inspect CSS rules that are emitted unconditionally even when the related class is not applied.

If a third-party console error remains after the guard, record its request URL and owner separately. Do not remove, defer or replace analytics, payment, consent, support or performance scripts as part of an image fallback fix.

## Rollback

Restore the pre-change files in the approved QA or live workflow, push only those files with deletion disabled, pull them back, compare hashes and rerun the same mobile and desktop smoke test.

## Verification boundary

Passing this SOP confirms that the targeted optional image expressions fail safely in the tested viewports. It does not establish full ADA or WCAG conformance, complete storefront accessibility or absence of unrelated third-party errors.

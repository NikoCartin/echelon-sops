# SOP-024: Accessibility Launcher and Flash Speed Load Order

**Author:** Nícolas Cartín Reyes, Lead Developer
**Date:** October 26, 2026
**Scope:** Shopify theme accessibility launcher prototype and controlled theme release
**Status:** Published as a reusable implementation reference

## Purpose

This SOP explains how to release a small accessibility options launcher when a storefront performance optimizer rewrites later scripts into lazyload placeholders. It documents the load-order fix, the narrow file scope and the validation required before publication.

The launcher is a convenience panel. It is not a WCAG or ADA conformance guarantee, a legal opinion or a replacement for accessible markup throughout the storefront.

## Symptoms

The launcher markup can appear while its controls do nothing. Inspect the rendered page and confirm whether the launcher asset has been rewritten from a normal deferred script into a lazyload placeholder such as `type="text/lazyload"` or a `data-src` attribute. If the runtime does not execute, the launcher will not initialize, focus will not move into the panel and the preference controls will not respond.

## Prerequisites

- An approved unpublished duplicate theme for testing.
- A current pull of the published theme before any release.
- A documented accessibility statement URL.
- Confirmation of the active performance optimizer and its script-rewrite behavior.
- A rollback copy of every file in the approved scope.
- Mobile and desktop test viewports.

## Approved implementation pattern

Use three focused theme files:

- `layout/theme.liquid`
- `snippets/accessibility-launcher.liquid`
- `assets/accessibility-launcher.js`

Render the snippet in the body near, but independent from, the existing support-chat markup. Load the deferred launcher asset before the optimizer's observer or render block. Do not disable the optimizer globally and do not modify chat, checkout, payment or analytics behavior to solve a launcher load-order issue.

The launcher markup should include:

- A real `button` with an accessible name.
- `aria-expanded` and `aria-controls` on the launcher button.
- A labeled panel with a stable heading and a hidden initial state.
- Real buttons for each preference, with `aria-pressed` state where applicable.
- Visible keyboard focus styling.
- Escape handling and focus return when the panel closes.
- A link to the storefront accessibility statement.

Preference features should be reversible. If preferences are persisted, use a namespaced storage key and provide a reset control. Avoid claiming that a preference changes every component unless it has been tested across the entire storefront.

## Controlled release procedure

1. Pull the published theme and confirm the active theme identity.
2. Pull the approved QA source or reproduce the approved change in an isolated release directory.
3. Compare the current published files against the release source to detect drift.
4. Add the launcher asset tag before the optimizer observer.
5. Render the launcher snippet in the approved body location.
6. Validate Liquid placement, JavaScript selectors, file endings and the exact file manifest.
7. Push only the approved files with deletion disabled.
8. Pull the same files back from the published theme and compare hashes.
9. Run the public smoke test in a mobile viewport and a desktop viewport.
10. Record the preview or public URL, changed files, measured behavior and rollback path.

## Acceptance criteria

The release is acceptable only when all of the following pass:

- The launcher asset remains a normal executable deferred script after the optimizer runs.
- The launcher initializes on a clean page load.
- The control is visible without horizontal overflow.
- The panel opens with the correct expanded state and focus enters the panel.
- Escape closes the panel and focus returns to the launcher.
- Text, contrast, link and motion preferences change their tested states and can be reset.
- Product browsing, cart behavior, support chat and checkout handoff remain outside the change scope and are not regressed.
- The post-release console contains no new launcher errors.
- The live pullback hashes match the approved release files.

## Troubleshooting

If the markup exists but the controls do not work, inspect the final script tag and the browser resource entry. If the tag has been rewritten to a lazyload type, move only the launcher asset tag before the optimizer observer and test again. Do not remove or broadly defer third-party scripts without a dependency inventory and owner approval.

If the panel opens but focus or Escape fails, inspect the panel selectors, `aria-controls`, the close handler and the focus return reference. If a preference has no visible effect, verify the CSS selector against the actual storefront DOM and test both mobile and desktop layouts.

## Rollback

Restore the previous layout file, remove the launcher render and asset tag, and remove only the newly introduced launcher snippet and asset. Pull back the affected files and rerun the smoke test. Never use a full-theme replacement as a rollback shortcut.

## Verification boundary

Passing this SOP confirms a controlled script-loading and interaction release. It does not establish full ADA or WCAG conformance. A separate accessibility program must cover semantic structure, names and descriptions, keyboard access, focus order, contrast, forms, media alternatives, screen readers, mobile assistive technology and the complete purchase journey.

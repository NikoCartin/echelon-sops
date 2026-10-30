# SOP-033: Consumer Financing Landing Section and Template-Swap Release

**Author:** Nícolas Cartín Reyes, Lead Developer
**Date:** October 30, 2026
**Scope:** Echelon US theme, `/pages/echelon-financing`; pattern applies to any page rebuilt as a new template
**Status:** Live on the US financing page

## Purpose

Rebuild a page as one schema-driven section in a new template, then release it by switching the page's template instead of editing the old one. The old template stays in the theme, so rollback is one setting.

## Affected files

| File | Role |
|---|---|
| `sections/financing-landing.liquid` | Hero, three steps, product cards, ways-to-pay cards, FAQ, closing CTA, disclosure |
| `templates/page.financing-v2.json` | Uses only the new section; all copy lives in section and block settings |
| `templates/page.financing.json` | Previous template, left unchanged for rollback |

## Section structure

- **Settings:** hero copy and image, shop link, apply label and note, step titles and text, headings, disclosure (rich text), ChargeAfter public key, `show_estimate` checkbox, `months` range and card note.
- **Blocks:** `product` (product picker + optional short name), `way` (title, text, badge), `faq` (question, rich-text answer).
- **Monthly estimate:** off by default. When `show_estimate` is on, the card shows `price / months` rounded up. Turn it on only after finance approves the APR wording, because a plain division implies 0% APR.
- **FAQ:** native `<details>`/`<summary>` so it works without JavaScript and with keyboards.
- **Disclosure:** normal body size (14px or more), never small italics. Use the lender's approved text word for word.

## Click-loaded ChargeAfter, safe under speed apps

The theme's speed app rewrites inline `<script>` tags to `type="text/lazyload"` and runs them only after the first interaction. A listener added by an inline script is therefore missing on the first click.

Put the handler on the button itself (attributes are not rewritten):

1. The button carries `data-ca-key` (public key from section settings) and `data-fallback` (shop link).
2. `onclick` checks `window.ChargeAfter.payments`. If missing, it injects `https://cdn.chargeafter.com/web/v2/chargeafter.min.js` once with `ChargeAfter.cfg = { apiKey }`.
3. It polls every 200 ms for up to 15 s, then calls `ChargeAfter.payments.present('apply', {})`.
4. On timeout it sends the visitor to the fallback link. `aria-busy` prevents double clicks.

## Procedure

1. Pull the live theme into a working repo and commit it as the base.
2. Add the new section and template. Do not edit the existing page template.
3. Push only the two new files to an unpublished theme.
4. Preview with `?preview_theme_id=<dev theme>&view=financing-v2` at 1440px and 390px.
5. Get approval on the previews.
6. Pull live again, confirm it matches the base, and back it up.
7. Push only the two new files to live with `--only … --nodelete --allow-live`.
8. Change the page's template suffix from `financing` to `financing-v2` (Admin > Pages > Theme template, or `pageUpdate` with `templateSuffix`).
9. Pull back the two files and compare them with the repo.

## Validation

- Page returns 200 three times in a row and renders the new section.
- Desktop and phone screenshots show no clipped text, overflow or overlap with sticky navigation.
- "Check your rate" opens the ChargeAfter application on the first click (test with a real desktop user agent and with promotional popups hidden).
- FAQ items open and close with mouse and keyboard.
- Browser console shows no new errors compared with the previous page.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| First click does nothing | Handler added by an inline script that the speed app delayed | Use the `onclick` attribute pattern above |
| `image_tag` class missing, image stretched | A filter such as `default` inside the `image_tag` arguments breaks parsing | Assign alt text to a variable first, then pass it |
| Image height wrong | Theme CSS sets `height` from the width/height attributes | Set `height:100% !important` inside the fixed-ratio wrapper |
| Click lands on a popup | Promotional or cookie dialogs cover the button in tests | Hide them in the test harness only |

## Rollback

Set the page's template suffix back to `financing`. The new files can stay in the theme unused.

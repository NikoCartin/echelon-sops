# Standard Operating Procedure: SEO Audit and Controlled Shopify Theme Release

**Document owner:** Echelon Ecommerce Development
**Author:** Nícolas Cartín Reyes, Lead Developer
**Audience:** Shopify developers, QA, ecommerce operations, catalog, marketing, and performance teams
**Version:** 1.0
**Status:** Approved technical reference
**Storefront:** Echelon Fit US consumer site
**Last updated:** October 12, 2026

## 1. Purpose

This SOP defines the repeatable process for auditing technical SEO, implementing a narrow theme change, validating the result, and documenting the release without overwriting unrelated storefront work.

The procedure is designed for changes such as:

- Metadata fallbacks and social sharing markup.
- Product and collection structured data.
- Semantic heading improvements.
- Product-card image alt text, dimensions, and loading behavior.
- Related SEO validation, crawl comparison, and post-release reporting.

The central release rule is:

> Pull the current production baseline, test in a duplicate theme, deploy only the approved files, pull the result back, verify the content, and smoke-test representative public URLs.

## 2. Scope and Non-Goals

This SOP covers technical SEO changes to the Shopify theme and their validation. It does not authorize:

- A full-theme overwrite.
- An unreviewed change to robots.txt.
- Mass creation of title or meta-description copy.
- Automatic noindex or publication changes.
- Removal of third-party applications, trackers, fonts, financing scripts, or personalization tools.
- Catalog edits without an owner-approved data decision.
- Changes to checkout, discounts, shipping, inventory, or payment behavior unless separately approved.

SEO work must preserve the storefront visual system, responsive dimensions, catalog behavior, cart flow, checkout, and commercial integrations.

## 3. Roles and Responsibilities

| Responsibility | Owner | Required output |
|---|---|---|
| Approve SEO objective and business scope | Ecommerce or Marketing owner | Written scope and acceptance criteria |
| Confirm product and collection priorities | Marketing and Catalog | Reviewed priority list and keyword intent |
| Implement theme changes | Lead Developer or assigned Shopify developer | Narrow code package and validation notes |
| Validate QA theme behavior | QA and requesting owner | Pass/fail evidence on representative URLs |
| Review performance and app impact | Performance and app owners | Functional sign-off for affected dependencies |
| Approve production publication | Authorized ecommerce owner | Explicit release approval |
| Deploy and verify | Authorized Shopify developer | Pullback, comparison, smoke-test record |

## 4. Required Inputs

Before editing, collect and record:

- Storefront and market being changed.
- Business objective and approved scope.
- Current production theme backup or pull.
- Duplicate QA theme identifier in the authorized Shopify environment.
- List of exact files allowed to change.
- Representative product, collection, CMS, and home-page URLs.
- Current crawl or page-level baseline.
- Current Lighthouse or field-performance baseline when performance is involved.
- Rollback location and release owner.

Do not place API tokens, private admin URLs, customer information, or credentials in this repository or in the release notes.

## 5. Approved SEO Change Contract

For the Echelon Fit US technical SEO update documented in the related case study, the approved file scope was:

- `layout/theme.liquid`
- `snippets/social-meta-tags.liquid`
- `snippets/product-template-variables.liquid`
- `sections/main-collection.liquid`
- `snippets/product-grid-item-new.liquid`

A future request may use a different file list. The developer must record the new list before editing and must not expand the scope because an unrelated issue is discovered during implementation.

## 6. Baseline Procedure

### 6.1 Pull the current production theme

1. Authenticate through the approved Shopify CLI or connector.
2. Pull the current production theme into a new timestamped working directory.
3. Record the theme name, theme status, pull time, Git commit or archive identifier, and file hashes.
4. Confirm that the working copy is not carrying uncommitted edits from another request.
5. Save a read-only baseline before making changes.

If authentication, theme selection, or file retrieval fails, stop and resolve the access issue. Do not improvise by editing a different theme.

### 6.2 Create or use the duplicate QA theme

1. Confirm the duplicate theme is the intended QA target.
2. Pull the QA theme fresh before testing.
3. Apply only the approved files and related test assets.
4. Keep the QA theme unpublished unless the business owner explicitly requests otherwise.
5. Record the preview URL and the test date.

The QA theme is the first implementation target for any follow-up optimization. Do not test experimental performance changes directly on production.

### 6.3 Capture the page baseline

For each representative URL, record:

- HTTP status and content type.
- Title.
- Meta description.
- Canonical URL.
- H1 count and visible heading text.
- JSON-LD types and required fields.
- Open Graph or social image URL.
- Primary image dimensions and loading attributes where relevant.
- Screenshot or browser evidence when layout behavior is part of the change.

Use both raw HTML and a rendered browser check when JavaScript or app-injected markup may affect the result. A third-party audit warning must be reconciled against the raw response and rendered DOM before it is treated as a production defect.

## 7. Implementation Procedure

### 7.1 Metadata fallback

Use a safe fallback only to prevent an empty technical tag. The fallback must not override approved page-specific SEO copy.

A typical pattern is:

```liquid
assign seo_meta_description = page_description | default: shop.description | default: shop.name
```

Confirm that the final output contains one meta-description tag. Check the character distribution after deployment and create an editorial queue for pages that inherit a generic store description.

### 7.2 Social metadata

1. Emit an absolute HTTPS image URL.
2. Preserve page-specific social image values when available.
3. Confirm that the output is not duplicated by another theme snippet or app.
4. Test the home page, a product page, and a collection page.

### 7.3 Product JSON-LD

1. Emit recognized HTTPS Schema.org references.
2. Emit one coherent Product object for the page.
3. Include variant-aware Offer data that reflects the visible Shopify product and variant state.
4. Do not invent price, SKU, description, inventory, or availability values.
5. Check whether an app already injects Product schema before adding theme markup.
6. Classify internal bundle products before deciding whether they should receive Product schema or remain outside the public SEO strategy.
7. Validate the result with a structured-data test and a rendered page check.

Incomplete source catalog data is a Catalog or Operations decision first. Theme code should not conceal a missing business field with fabricated values.

### 7.4 Collection H1

1. Add a semantic H1 to standard collection pages.
2. Use the collection context for the visible heading.
3. Preserve the existing visual system and layout.
4. Confirm that the template does not output a second H1 through a section or content block.
5. Test at least one standard collection, one custom collection, and one mobile viewport.

### 7.5 Product-card images

1. Provide descriptive fallback alt text based on the product context when a dedicated alt value is empty.
2. Add explicit dimensions where the component has reliable image dimensions.
3. Keep non-critical product-card images lazy-loaded.
4. Do not apply card-image lazy loading to the true LCP image without a separate benchmark.
5. Confirm that fallback images do not create broken URLs, duplicate alt text, or layout shifts.
6. Test desktop and mobile cards, including a product with multiple variants and a product with incomplete media.

## 8. QA Acceptance Criteria

The QA theme passes only when all applicable criteria are met:

- The changed files are limited to the approved scope.
- The home page, a product page, and a collection page render without Liquid errors.
- Each representative page has exactly one intended title, meta description, and canonical tag.
- Product pages expose valid Product JSON-LD without fabricated fields.
- Collection pages have the expected H1 and do not gain unintended duplicate H1 elements.
- Social image URLs are absolute HTTPS URLs.
- Product cards render valid image URLs, descriptive alt text, and stable dimensions.
- Variant selection, Add to Cart, cart state, financing, personalization, and existing app behavior remain unchanged unless explicitly in scope.
- Mobile and desktop layouts do not show new clipping, overflow, or significant layout shift.
- A QA crawl or page-level comparison is saved with the release record.

A passing QA result does not authorize publication by itself. Production approval remains a separate business decision.

## 9. Controlled Production Deployment

1. Pull production again immediately before deployment and compare it with the earlier baseline.
2. Reconcile any production drift before creating the release package.
3. Build a package containing only the approved files.
4. Upload the package as a partial theme update.
5. Use the platform's no-delete behavior where available. The deployment must not delete unrelated files.
6. Do not use a full-theme push for this type of SEO update.
7. Record the deployment result, timestamp, target theme, and changed files.
8. Pull the affected production files back into a separate pullback directory.
9. Compare file hashes and content against the intended package.
10. Stop and investigate if the pullback differs from the intended files.

No production release is complete until the pullback comparison and smoke test pass.

## 10. Post-Deployment Validation

### 10.1 Live smoke test

Check at least:

- Home page.
- One priority product page.
- One priority collection page.
- One page with a known fallback or edge case.

For each page, verify the HTTP response, title, meta description, canonical, H1, JSON-LD, social image, visible layout, and primary navigation. For product pages, also verify variant selection and Add to Cart behavior.

### 10.2 Crawl comparison

Run the same crawl method used for the baseline where possible. Record:

- URLs discovered.
- Valid HTML responses.
- Transient failures and retry results.
- Missing title, meta description, and canonical counts.
- H1 counts.
- JSON-LD coverage and incomplete field counts.
- Title and meta-description length distributions.
- New errors or changed canonical patterns.

Do not treat a single incomplete-read crawl result as a confirmed 404. Retry the URL individually.

### 10.3 Performance check

Run mobile Lighthouse on the same representative pages used for the baseline. Record performance score, FCP, LCP, CLS, render-blocking resources, image sizing, and layout-shift contributors.

Lighthouse is a lab test. When available, compare it with Search Console Core Web Vitals and analytics data before making a business claim about user experience or rankings.

Do not remove a script or integration solely because Lighthouse lists it as render-blocking. Confirm ownership, business purpose, and functional impact first.

## 11. Rollback Procedure

Rollback is required when the deployment introduces a functional regression, unexpected markup duplication, broken images, cart behavior changes, or a pullback mismatch.

1. Stop further production edits.
2. Identify the exact affected files from the release record.
3. Restore only those files from the verified pre-deployment baseline.
4. Upload a narrow rollback package with no deletion of unrelated files.
5. Pull back the restored files and compare hashes.
6. Repeat the live smoke test on the representative URLs.
7. Record the reason, affected files, validation result, and next owner.

Do not roll back by replacing the entire theme when a five-file restoration is sufficient.

## 12. Reporting Standard

The release report must be in English and include:

- Business objective.
- Date and storefront.
- Author and responsible owner.
- Approved file list.
- Before-and-after findings.
- QA evidence and representative URLs.
- Production deployment and pullback result.
- Known limitations and unresolved findings.
- Recommended next phase.
- Rollback location or procedure.

The report must not claim that SEO is fully fixed unless field data and business outcomes support that statement. Technical coverage, lab performance, organic visibility, and conversion performance are separate measurements.

## 13. Troubleshooting

| Symptom | Likely cause | Response |
|---|---|---|
| Meta description is missing in one tool but present in raw HTML | Audit timing or rendering difference | Compare raw HTML, rendered DOM, and a second crawl before changing code |
| Product JSON-LD is missing price or SKU | Source Shopify catalog field is incomplete or unavailable at render time | Review the product and variant data before changing the template |
| Collection has multiple H1 elements | A section, content block, or article-like component adds another H1 | Inspect the rendered DOM and correct the responsible component in QA |
| Product-card image shifts the layout | Missing dimensions or late image replacement | Add reliable dimensions and test the component at mobile and desktop widths |
| Lighthouse identifies a third-party script as a major cost | Script is render-blocking or loads too early | Identify owner and business purpose, then test defer or conditional loading in QA |
| Pullback does not match the release package | Theme drift, wrong target, or incomplete upload | Stop deployment, reconcile the target theme, and do not declare success |
| Cart, financing, or personalization changes after SEO work | Scope expanded into shared behavior or an app conflict appeared | Stop, roll back the affected files, and involve the integration owner |

## 14. Maintenance

Review this SOP when the theme architecture, SEO app stack, Shopify deployment workflow, or measurement process changes. Keep the case study and release reports aligned with verified production behavior.

Never commit credentials, customer data, private admin links, raw connector output, or temporary sandbox paths.

## References

1. [Echelon Fit US storefront](https://echelonfit.com/)
2. [Google Search Central: Core Web Vitals](https://developers.google.com/search/docs/appearance/core-web-vitals)
3. [Google Search Central: Product structured data](https://developers.google.com/search/docs/appearance/structured-data/product)
4. [Shopify Help Center: SEO overview](https://help.shopify.com/en/manual/promoting-marketing/seo/seo-overview)
5. [Shopify Help Center: Editing robots.txt.liquid](https://help.shopify.com/en/manual/promoting-marketing/seo/editing-robots-txt)
6. [Shopify Help Center: Adding alt text to media](https://help.shopify.com/en/manual/products/product-media/add-alt-text)

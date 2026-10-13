# Echelon Fit US SEO Improvements: Technical Case Study

**Author:** Nícolas Cartín Reyes, Lead Developer
**Storefront:** [echelonfit.com](https://echelonfit.com/)
**Date:** October 12, 2026
**Audience:** Shopify development, ecommerce operations, catalog, marketing, performance, and QA teams
**Status:** Completed technical update with post-deployment validation

## Executive Summary

Echelon Fit US had a set of technical SEO issues across metadata, structured data, collection headings, social sharing markup, and product-card image output. The work was intentionally limited to a narrow group of approved theme files and was released through a controlled QA and production workflow.

The deployment improved technical coverage without changing storefront design, product pricing, inventory, checkout behavior, or unrelated integrations. A full post-deployment audit confirmed that title, canonical, and meta-description tags were present across the valid crawl results. The number of pages without a detectable H1 also decreased materially.

The work did not make a claim that SEO is fully resolved. The next priorities are mobile performance, editorial metadata, catalog classification, and validation of incomplete product structured data.

## Business and Technical Problem

The storefront needed a safer technical SEO baseline before broader content and performance work could be prioritized. The main issues were:

- Pages could lack a rendered meta description when page-level metadata was empty.
- Social sharing image URLs were not consistently emitted in the expected form.
- Product structured data needed a recognized Product representation with HTTPS Schema.org references and variant offer data.
- Standard collection pages did not consistently expose a semantic H1.
- Product cards needed stronger fallback behavior for image alt text, dimensions, and loading attributes.
- A broad live-theme change would have created unnecessary risk across financing, analytics, personalization, cart, checkout, and merchandising integrations.

## Approved Scope

The implementation was limited to five theme files:

- `layout/theme.liquid`
- `snippets/social-meta-tags.liquid`
- `snippets/product-template-variables.liquid`
- `sections/main-collection.liquid`
- `snippets/product-grid-item-new.liquid`

No full-theme overwrite was used. No unrelated theme files, applications, dependencies, trackers, or checkout functions were changed as part of this update.

## Technical Changes

### Metadata fallback

A global fallback now prevents eligible public pages from rendering without a meta description when a page-specific description is unavailable. The fallback is a technical safety net, not a replacement for editorial copy.

The implementation follows this principle:

```liquid
assign seo_meta_description = page_description | default: shop.description | default: shop.name
```

Pages with a store-level fallback should still be prioritized for unique title and meta-description copy when they represent commercial search intent.

### Social metadata

Social sharing markup was corrected so the image URL is emitted in a consistent absolute HTTPS form. The change was validated against representative public URLs.

### Product JSON-LD

Product markup was updated to use recognized HTTPS Schema.org references and a single Product object with variant-aware Offer data. The output is intended to remain aligned with the visible product page and Shopify catalog data.

The implementation does not create catalog values that do not exist in Shopify. Missing price, SKU, description, inventory, or publication data must be corrected or classified at the source before structured data is expanded.

### Collection heading structure

Standard collection pages now expose a semantic H1 based on the collection context. This improves document hierarchy without changing the visible visual system or collection merchandising layout.

### Product-card image output

Product-card fallback behavior was improved for:

- Descriptive alt text when a dedicated image alt value is missing.
- Explicit image dimensions where the product-card context can provide them.
- Lazy-loading behavior for non-critical card images.
- Fallback handling when a product image is missing or incomplete.

The LCP image on a page must not be changed to lazy loading without a separate performance test. Product-card rules should not be applied blindly to hero images or other above-the-fold content.

## Release Controls

The release followed a controlled sequence:

1. A current production baseline was pulled before editing.
2. The approved changes were applied to a duplicate QA theme.
3. Representative product and collection URLs were reviewed in the QA theme.
4. Only the approved files were packaged for production.
5. The live theme received a narrow partial update rather than a full-theme push.
6. The deployed files were pulled back after the update.
7. File hashes and content were compared against the intended package.
8. Representative live URLs were checked for title, meta description, canonical, H1, and Product JSON-LD output.
9. A broader crawl and mobile Lighthouse baseline were recorded after deployment.

This process preserved an explicit rollback path and prevented unrelated theme drift from being overwritten.

## Post-Deployment Results

The post-deployment crawl covered 906 public sitemap URLs. Of those, 903 returned valid HTML 200 responses. Three incomplete-read failures were treated as transient crawl results rather than automatic 404 findings.

The reliable crawl findings were:

- No missing title tags across valid HTML responses.
- No missing canonical tags across valid HTML responses.
- No missing meta-description tags across valid HTML responses.
- Pages without a detectable H1 decreased from 68 to 32.
- Representative product pages exposed title, meta description, canonical, H1, and Product JSON-LD.
- The Accessories collection exposed CollectionPage JSON-LD and an H1.

These results describe technical coverage. They do not prove improved organic rankings, conversions, or field Core Web Vitals without Search Console and analytics data.

## Remaining Findings

The audit identified several follow-up areas:

### Mobile performance

Mobile Lighthouse scores were 41 for the home page, 37 for DuoTread, and 63 for Accessories. Simulated LCP was 7.3 seconds on the home page, 15.7 seconds on DuoTread, and 9.6 seconds on Accessories. Layout shift was also elevated on the home page and DuoTread in the lab tests.

The next safe step is an isolated QA experiment for one change at a time:

- LCP image preload or eager loading only where measurement proves it is appropriate.
- Explicit dimensions for the mobile logo and other layout-shift contributors.
- Responsive image sizes closer to their rendered viewport dimensions.
- Audited loading of duplicate or non-critical resources.

Finance, analytics, personalization, Flash Speed, Bootstrap, Splide, fonts, and other third-party dependencies must not be removed globally without owner review and functional QA.

### Editorial metadata

The fallback solved missing technical tags, but it also means many pages inherit a store-level description. The crawl found 316 titles longer than 60 characters, 750 meta descriptions longer than 160 characters, and 87 meta descriptions shorter than 120 characters.

Marketing and Catalog should prioritize a reviewed matrix for revenue products and collections instead of generating mass copy automatically.

### Structured-data completeness

A small group of products still had incomplete Product JSON-LD fields such as price, SKU, or description. These cases require catalog review before deciding whether the correct fix belongs in Shopify product data, a product template, or a page-classification decision.

### H1 and accessibility coverage

The H1 result improved, but 32 pages still had no detectable H1 and 42 pages had multiple H1 elements. Accessibility findings also included ARIA, contrast, focus, and heading-order opportunities. These should be handled by component and template, not by a blind site-wide replacement.

## Recommended Next Phase

1. **Content and classification:** Marketing and Catalog prepare a reviewed title and meta-description matrix for priority products and collections.
2. **QA performance experiment:** Development benchmarks the home page, DuoTread, and Accessories in the duplicate theme, changing one loading or sizing behavior at a time.
3. **Catalog and schema review:** Operations confirms the commercial status and source fields for products with missing or incomplete Product JSON-LD.
4. **Accessibility pass:** Development corrects shared component issues for ARIA, contrast, image sizing, and heading hierarchy.
5. **Field measurement:** Performance reviews Search Console Core Web Vitals, index coverage, rich-result status, organic queries, and conversions alongside the lab baseline.

## Engineering Principles

- Prefer narrow, reversible theme changes over broad production pushes.
- Validate the rendered storefront, not only Liquid source code.
- Keep catalog truth in Shopify product data instead of fabricating structured-data values.
- Treat metadata fallbacks as technical coverage, not editorial optimization.
- Test performance changes in QA before changing production dependencies.
- Preserve app and checkout behavior unless the change is explicitly scoped to it.
- Record baseline, changed files, validation evidence, and rollback steps for every production release.

## Related Documentation

- [SEO Audit and Controlled Theme Release SOP](SOP-016-seo-audit-controlled-theme-release.md)
- [Echelon Fit Shopify Development SOPs](README.md)

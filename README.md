# Echelon Fit — Shopify Development SOPs

This repository contains Standard Operating Procedures (SOPs) and reference code for custom Shopify theme development on the Echelon Fit storefronts (US, UK, CA).

These documents serve as technical references for engineers and developers maintaining enterprise-level Shopify storefronts for Echelon Fitness Multimedia, LLC.

**Storefronts covered:**
- [Echelon US](https://echelonfit.com/)
- [Echelon UK](https://echelonfit.uk/)
- [Echelon CA](https://echelonfit.ca/)

---

## Available SOPs

| ID | Title | Description |
|----|-------|-------------|
| **[SOP-001](SOP-001-membership-upgrade-modal.md)** | Editing the Membership Upgrade Modal | How to add, remove, or update freebies in the membership upgrade modal — covering both the Theme Customizer blocks and the cart logic in `membership-popup.liquid`. |
| **[SOP-002](SOP-002-bazaarvoice-coding-setup.md)** | Bazaarvoice Coding Setup | Replacing Klaviyo widgets with Bazaarvoice inline ratings, and troubleshooting custom Liquid star-rating behaviors. |
| **[SOP-003](SOP-003-ship-x-shipping-policy.md)** | Ship-X Shipping Policy & Setup | Configuring Ship-X scenarios, required product tags, and resolving checkout conflicts with Shopify manual rates. |
| **[SOP-004](SOP-004-ssl-setup-putty.md)** | SSL Setup and Validation via PuTTY | DevOps procedure for connecting to internal servers via jump hosts to validate and fix Nginx SSL configurations. |
| **[SOP-005](SOP-005-upsell-selleasy-app.md)** | Upsell & Cross-Sell App (Selleasy) | Architecture, configuration, and troubleshooting guide for implementing Selleasy campaigns and theme app blocks. |
| **[SOP-009](SOP-009-uk-dynamic-bike-product-template.md)** | UK Dynamic Bike Product Template | Architecture, data model, fixed-versus-dynamic boundary, product setup, validation, deployment, testing, troubleshooting and rollback for the additive `product.dynamic-bike` template. |

## UK Dynamic Bike Template Reference Files
| File | Description |
|------|-------------|
| [`MANUAL-UK-DYNAMIC-BIKE-TEMPLATE.md`](MANUAL-UK-DYNAMIC-BIKE-TEMPLATE.md) | Step-by-step manual installation and product-assignment guide for the UK `product.dynamic-bike` template. |
| [`REFERENCE-UK-DYNAMIC-BIKE-TEMPLATE.md`](REFERENCE-UK-DYNAMIC-BIKE-TEMPLATE.md) | Quick-reference implementation summary, UK metafields, membership products and validation requirements. |

## Reference Code

| File | Description |
|------|-------------|
| [`membership-popup.liquid`](membership-popup.liquid) | Full source of the Membership Upgrade Modal section, including Liquid template, HTML structure, and JavaScript cart logic. |

---

## Tech Stack

`Shopify` · `Liquid` · `JavaScript` · `HTML` · `CSS` · `Theme Customization` · `E-commerce Operations`

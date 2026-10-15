# Standard Operating Procedure: Scheduled Sales-Channel Publication Flow

**Document owner:** Ecommerce Operations

**Author:** Nicolás Cartin Reyes, Lead Developer

**Audience:** Shopify developers, Shopify administrators and technical operators

**Version:** 1.0

**Status:** Active implementation pattern

**Scope:** Scheduled, tag-driven product publication control for one sales channel
**Last updated:** 15 October 2026

## 1. Purpose

This SOP documents a controlled Shopify Flow pattern for products whose inventory state is supplied by an upstream stock-synchronization process. The workflow reads the resulting product state and removes matching products from one selected sales channel at product level.

The pattern is deliberately narrow. It changes publication on the selected channel only. It does not change the Online Store channel, product status, inventory quantities or product tags.

> **Core rule:** A product-level publication action must not be treated as proof that an external marketplace offer, listing or offer state has been deactivated. Validate the downstream channel connector separately.

## 2. Scope and exclusions

This procedure covers:

- A scheduled Shopify Flow trigger that runs after the upstream inventory-state process.
- A product-data query with an explicit filter and a deterministic sort order.
- A `For each` loop over the products returned by the query.
- An exact tag condition representing the configured inventory state.
- An `Unpublish product` action targeting one approved marketplace or sales channel.
- Run-history review, controlled validation and a reversible disable procedure.

This procedure does not authorize:

- Unpublishing from the Online Store channel.
- Changing product status, inventory, tags, variants or product data.
- Variant-level publication control.
- Automatic republishing when the inventory-state tag is removed.
- Bulk republishing without an approved product list and a controlled review.
- Claiming that a marketplace offer is inactive without checking the channel connector and the marketplace state separately.
- Placing orders, entering payment details or testing through a customer purchase.

Republish and variant-level handling require separate workflows with their own acceptance criteria, failure behavior and rollback plan.

## 3. Prerequisites

Before creating or changing the workflow, confirm:

1. The upstream inventory process is already responsible for writing the product inventory-state tag or equivalent state signal.
2. The target sales channel is installed, authorized and visible as a product publication destination.
3. The operator can view Shopify Flow run history and product publication state.
4. A controlled test product is published to both the target channel and Online Store, unless the approved test intentionally uses another baseline.
5. The product has no customer or order dependency that would make a publication test unsafe.
6. The owner has approved the schedule, target channel, state condition and one-way action.
7. A current list of test products and a rollback method are available before activation.

Do not copy store-specific channel identifiers, workflow IDs, internal product counts or proprietary tag values into public documentation. Use the production values only inside the authorized Shopify environment.

## 4. Reference workflow design

The intended topology is:

```text
Scheduled trigger
  -> Get product data using an advanced query
  -> For each product returned
      -> Exact inventory-state tag condition
          -> Unpublish product from the selected sales channel
```

### 4.1 Schedule after the upstream state update

Set the Flow schedule after the upstream stock-synchronization process has completed. The schedule should have a documented timezone, cadence, start condition and end condition. Avoid overlapping runs when the upstream process is still writing tags.

The schedule is part of the business control. Changing it can create a race condition, leave stale publications active, or process the same state before the source system has finished updating the catalog.

### 4.2 Query the smallest safe product set

Use the `Get product data` action with an advanced query that targets the approved product population and sorts the result consistently, such as by most recently updated products first. Keep the production tag value in Shopify Flow configuration and refer to it in documentation as `INVENTORY_STATE_TAG`.

A query should be narrow enough to avoid processing unrelated products. A conceptual pattern is:

```text
status:active AND tag:INVENTORY_STATE_TAG
```

The exact query must match the store's approved product scope. Do not assume that a sort order provides pagination or that one Flow query scans an unlimited catalog.

### 4.3 Respect query result limits

A Flow loop processes the products returned by the preceding action. Before activation, confirm the action's current result limit and compare the result count with the expected population.

If the catalog can exceed the action limit:

- Split the population with deterministic filters, such as product type, collection or a documented date range.
- Create separate workflows only when ownership, schedules and rollback remain clear.
- Use an approved API or bulk-processing design when complete catalog coverage is required.
- Reconcile the source count, query count and action count after each run.

Do not describe a single advanced query as a complete catalog scan without verifying its coverage.

### 4.4 Use an exact tag condition

Inside the loop, compare the product's tags to the configured inventory-state tag using an exact equality condition. Do not use a loose text match if another tag could contain the same text.

The condition should be the final gate before the publication action. It should not add, remove or rewrite the tag. The upstream inventory process remains the source of truth for that state.

### 4.5 Target one sales channel

Use the product-level `Unpublish product` action and select only the approved target sales channel. Review the action configuration before activation to ensure the Online Store channel is not selected.

The action should not be expanded to other channels as a convenience. Each additional channel has different merchandising, inventory, connector and rollback implications.

## 5. Controlled validation

Validate the workflow in an authorized test context before relying on scheduled execution.

### 5.1 Baseline capture

For each test product, record only the technical state needed for validation:

- Product identifier or internal test reference.
- Current tag state.
- Publication state for the target channel.
- Publication state for Online Store.
- Product status and inventory state.
- Relevant connector state, if available.

Do not place customer data, credentials, session material or private URLs in the public SOP.

### 5.2 Positive test

Use a product carrying the approved inventory-state tag and published to the target channel. Trigger the workflow through the approved test or scheduled path. Confirm:

- The product appears in the query result.
- The loop evaluates the product.
- The exact tag condition evaluates true.
- The selected channel publication is removed.
- Online Store publication is unchanged.
- Product status, inventory and tags are unchanged.
- No unrelated product is changed.

### 5.3 Negative tests

Run at least these checks:

| Test | Expected result |
|---|---|
| Product without the inventory-state tag | No publication change. |
| Product with a similar but non-matching tag | No publication change. |
| Product published to Online Store and the target channel | Only the target channel is changed. |
| Product already unpublished from the target channel | The run completes without creating a new publication. |
| Product outside the query scope | The workflow does not process it. |
| Query result near the configured action limit | Coverage is reviewed and documented before activation. |
| External marketplace connector state | Verified separately; never inferred from the Shopify action alone. |

Stop testing before checkout, payment or order submission. Remove or restore test publication state through the approved rollback procedure after validation.

## 6. Monitoring and operational review

After activation, review recent Flow runs at the cadence defined by the workflow owner. For each run, check:

- Trigger completion time and timezone.
- Number of products returned by the query.
- Number of products evaluated by the loop.
- Number of products that met the exact condition.
- Number of successful and failed publication actions.
- Any connector or permission errors.
- Whether the source inventory-state count matches the processed count.

Investigate a sudden zero-result run, an unexpected increase in processed products, repeated action failures or a count mismatch before changing the workflow. A successful Flow run confirms that Shopify executed the configured steps. It does not confirm the final state of an external marketplace listing.

Keep the workflow name, owner, target channel, schedule, query scope and rollback reference in the team's private operational record. Do not place private run evidence in this public SOP.

## 7. Troubleshooting

| Symptom | Likely cause | Action |
|---|---|---|
| The workflow returns zero products | Query syntax, tag mismatch, product scope or upstream process failure | Compare the query with the current product state and confirm the upstream process completed. |
| Tagged products remain published | Product was not returned, the condition did not match, or the action failed | Inspect the run's query result, condition branch and action error before changing the schedule. |
| More products were changed than expected | Query scope is too broad or a tag was applied incorrectly | Turn off the workflow, preserve the run record and reconcile the source tag population. |
| Online Store publication changed unexpectedly | The wrong channel was selected or another workflow changed it | Disable this workflow, inspect all related publication automations and restore only approved products. |
| The external marketplace listing remains active | The connector or marketplace requires a separate listing action or has not synchronized | Verify the connector state and marketplace state independently. Do not broaden this workflow without approval. |
| Results stop at a repeatable count | The product-data action reached its configured result limit | Split the query or move to an approved bulk-processing design. |
| A run fails with a permission error | Flow or the selected channel lacks the required authorization | Ask the channel owner to correct the permission, then rerun a controlled test. |
| A product is republished after the tag is removed | A separate workflow or connector is handling republish behavior | Identify the owner of that behavior. Republish is not part of this SOP. |

## 8. Disable and rollback

The safest immediate rollback is to turn off the workflow. Disabling it prevents future actions but does not automatically republish products already unpublished by a prior run.

If a publication restoration is approved:

1. Turn off the workflow before restoring any product.
2. Build the restoration list from the affected run and confirm each product with the owner.
3. Restore publication only to the intended sales channel.
4. Confirm that Online Store publication, product status, inventory and tags remain unchanged.
5. Check the channel connector and external marketplace state separately.
6. Record the restoration and leave the workflow disabled until the root cause is resolved.

Do not restore an entire catalog from memory or from a broad query. Use an explicit, reviewed product list.

## 9. Change control

Before modifying the workflow:

1. Record the current configuration and recent run outcome.
2. Confirm the upstream state signal and timing dependency.
3. Review the query scope, result-limit assumption, exact tag condition and selected channel.
4. Test the smallest safe change with positive and negative cases.
5. Confirm the one-way publication boundary and rollback list.
6. Activate only after the owner approves the changed schedule or action.
7. Review the first scheduled run and compare its counts with the upstream source.
8. Update the private operational record without adding credentials, customer data or private administration URLs to this public repository.

A descriptive workflow name is recommended for maintainability. Renaming a live workflow is a separate configuration change and should be handled through the same review process.

## 10. Related documentation

- [Shopify Flow overview](https://help.shopify.com/en/manual/shopify-flow)
- [Echelon Fit Shopify development SOP index](README.md)
- [SOP-016: SEO Audit and Controlled Shopify Theme Release](SOP-016-seo-audit-controlled-theme-release.md)

## 11. Ownership

This document was authored by **Nicolás Cartin Reyes, Lead Developer**. Any production change requires review by the storefront engineering or ecommerce operations owner responsible for the affected sales channel.

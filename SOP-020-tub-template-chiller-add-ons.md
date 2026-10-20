# SOP-020: Plunge Template for Products Without Built-in Chillers

**Author:** Nícolas Cartín Reyes, Lead Developer

## Policy

Every plunge product without a built-in chiller must use the same product template:

`pdp2025-tubs-simple`

This includes inflatable plunges, hard plunges, soft plunges and plunge products that use optional external chillers. A no-built-in-chiller plunge must not remain on `product2024`, `product2024-simple` or another product template after it is identified for the plunge catalog.

Products with a built-in chiller are outside the scope of this policy. They must remain on the approved built-in-chiller template unless a separate design and migration decision is documented.

The only permitted exception for an in-scope product is a temporary migration or incident state recorded in the private release log with an owner, reason, preview status and target date. A different template is not an acceptable permanent design choice for a plunge without a built-in chiller.

## Purpose

Maintain one reusable product-page architecture for plunge products without a built-in chiller. The template provides the shared gallery, product purchase surface, product description, optional external chiller add-ons, responsive layout, image zoom, product media and related product sections.

This SOP covers template assignment, add-on configuration, product media fallbacks, preview approval, live pullback and the boundary between shared template behavior and product-specific logic.

## Scope

This SOP applies to:

- All products classified as plunges or cold-immersion tubs without a built-in chiller
- The `pdp2025-tubs-simple` product template
- The `main-individual-product` section and its add-on settings
- Optional external chiller variant references and display cards
- The product-specific conditions that control add-on headings or modules

Products with a built-in chiller are explicitly out of scope for this template assignment.

It does not create products, change inventory, change shipping rates or publish a product without separate approval.

## Required files and architecture

The primary template is:

```text
templates/product.pdp2025-tubs-simple.json
```

The template uses the shared individual-product section:

```json
{
  "type": "main-individual-product",
  "settings": {
    "enable_addon_1": true,
    "addon_1_variant_id": "<approved chiller variant ID>",
    "addon_1_title": "<approved chiller title>",
    "addon_1_image": "",
    "addon_1_image_url": "<current Shopify CDN image URL>",
    "enable_addon_2": true,
    "addon_2_variant_id": "<approved chiller variant ID>",
    "addon_2_title": "<approved chiller title>",
    "addon_2_image": "",
    "addon_2_image_url": "<current Shopify CDN image URL>"
  }
}
```

The current shared template supports two optional chiller slots. The image picker is preferred when populated. The URL is the fallback when the picker is empty. Both values must be checked during QA so a deleted Shopify file does not render a broken-image icon.

The shared Liquid renderer follows this pattern:

```liquid
{% if product.available and show_addons %}
  <div class="add-promotions-section">
    {% if enable_addon_1 == true and addon_1_variant_id != blank %}
      <input
        type="checkbox"
        name="addon-product-1"
        class="dumbbells-checkbox"
        data-variant-id="{{ addon_1_variant_id }}"
        data-title="{{ addon_1_title | escape }}"
      >
      <img
        src="{% if addon_1_image %}{{ addon_1_image | image_url: width: 360 }}{% else %}{{ addon_1_image_url }}{% endif %}"
        alt="{{ addon_1_title }}"
        class="individual-image"
      >
    {% endif %}
  </div>
{% endif %}
```

The actual production snippet also renders the second add-on slot using the same data-attribute and fallback-image pattern. Keep the shared renderer generic. Do not create a separate copy of the chiller card for each plunge product.

## Assigning the mandatory template

Use Shopify Admin or a controlled Admin GraphQL mutation. The mutation must set only the product ID and the approved template suffix for the migration batch:

```graphql
mutation AssignPlungeTemplate($input: ProductInput!) {
  productUpdate(input: $input) {
    product {
      id
      handle
      templateSuffix
    }
    userErrors {
      field
      message
    }
  }
}
```

Example variables:

```json
{
  "input": {
    "id": "gid://shopify/Product/<plunge-product-id>",
    "templateSuffix": "pdp2025-tubs-simple"
  }
}
```

Before executing a batch, query every candidate product and record its built-in-chiller status, current `templateSuffix`, handle, status and SKU. Assign the template only to products without a built-in chiller. The migration must be reversible and must not alter price, inventory, tags, media, description or product status.

## Migration procedure

1. Build an inventory of every plunge product in the store, including active, draft and scheduled catalog records.
2. Confirm the product classification with the approved Plunges collection or catalog taxonomy.
3. Classify each product as either no built-in chiller or built-in chiller using approved product data. Do not infer this from the product title alone.
4. Record the current template suffix for each no-built-in-chiller product and identify any non-compliant product.
5. Pull the current live theme and create a backup of `product.pdp2025-tubs-simple.json`, the shared individual-product snippet and any related JavaScript conditions.
6. Confirm the shared template contains the current approved external chiller variant references and valid image sources.
7. Update the shared template or its product-specific condition only if the change is required for the migration. Keep that code change separate from the product assignment mutation.
8. Assign `pdp2025-tubs-simple` only to the no-built-in-chiller migration batch through Shopify Admin or the controlled mutation above.
9. Generate an unpublished-theme preview before final approval. The preview is mandatory and must be shown to the reviewer before the template migration is considered complete.
10. Preview at least one hard plunge, one soft or inflatable plunge, one product with both external chiller add-ons and one product without optional add-ons. Keep a built-in-chiller product out of the migration batch as a control.
11. Validate the product gallery, image zoom, price, inventory message, description, add-on cards, membership or purchase controls and mobile layout.
12. Select and clear each external chiller add-on in the preview. Confirm that the cart payload contains the selected chiller variant and the correct base plunge variant.
13. Deploy only the approved theme files, then pull the live files back and compare them with the release source.
14. Run a public smoke test on representative no-built-in-chiller plunge products and record the migration result for every product.

## Product-specific conditions

A shared template must not silently fail because a new plunge product is missing from a hardcoded product-ID condition. If a heading, module or add-on behavior depends on product identity, prefer a stable product classification, tag or template-level condition. If a product-ID condition is unavoidable, update it in a separate reviewed code change before assigning the template.

The Party Plunge does not have a built-in chiller, so it is in scope for this template policy. Its current state is a migration exception until its product-specific external-chiller heading and behavior condition are updated, previewed and approved. The product must then be assigned to `pdp2025-tubs-simple`; leaving it on `product2024` is not the final state.

## Validation checklist

Use the unpublished preview and confirm:

- The product is rendered by `pdp2025-tubs-simple`.
- The product is confirmed to have no built-in chiller.
- The product title, price, compare-at price, inventory state and media are unchanged unless separately approved.
- The main product gallery and zoom behavior work on desktop and mobile.
- Both configured chiller cards render valid images with no broken-image icon.
- The displayed title, variant and price match the selected chiller records.
- Selecting and clearing an add-on updates the cart payload without changing the base plunge variant.
- A product without add-ons does not display empty or misleading chiller cards.
- The product-specific heading and optional modules are correct.
- No Liquid errors appear in the storefront response or browser console.
- The product remains in its approved status, and no order or payment is submitted during testing.
- The preview is shown to the reviewer before final approval.

After deployment, pull the live template back and repeat the public smoke test on representative plunge products. Record the product handles, template suffix, preview result and live result in the private release log.

## Troubleshooting

| Symptom | Likely cause | Action |
|---|---|---|
| A no-built-in-chiller plunge still shows the old layout | The product has a non-compliant template suffix | Assign `pdp2025-tubs-simple` after preview approval |
| A built-in-chiller product is being considered for migration | The product was not classified before the batch | Remove it from this migration and keep its approved built-in-chiller template |
| Broken add-on image | Deleted or stale Shopify file URL | Replace it with current product media and verify the HTTP response |
| Correct image in QA but not live | Wrong theme or incomplete push | Confirm the target theme, push only the approved file and pull back the result |
| Add-on heading does not match the plunge | Product-specific condition excludes the product | Add a reviewed classification-based condition or update the approved product condition |
| Add-on does not reach cart | Invalid variant ID or disabled slot | Re-read the variant record and inspect the rendered data attributes |
| Empty chiller cards appear | Add-on is enabled without a valid variant reference | Disable the unused slot or provide an approved variant and image |
| Mobile layout is broken | Template CSS or media sizing regression | Reproduce in the unpublished preview and patch the shared template only |

## Rollback

If the shared template release causes a storefront regression, restore the previous version of the affected template or shared snippet from the live pullback and push only the affected file. If the issue is limited to one no-built-in-chiller product assignment, restore that product's prior template suffix while the shared template is investigated. Treat the prior suffix as a temporary incident state, not as the permanent catalog standard. Do not use this rollback procedure to move a built-in-chiller product onto this template.

Do not replace the full theme, delete product media or change product status as a rollback shortcut.

## Change record

Record:

- Product handle, SKU and previous template suffix
- Built-in-chiller classification and evidence
- Assigned template suffix: `pdp2025-tubs-simple`
- Chiller variant IDs and image sources
- Files changed and theme environment
- Preview URL and reviewer approval
- Pullback comparison result
- Public smoke-test outcome
- Any temporary exception and its owner or target date

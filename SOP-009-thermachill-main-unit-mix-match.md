# ThermaChill Main Unit PDP and Mix-and-Match Garments

**Implementation record:** ThermaChill Main Unit PDP, garment catalog setup, pricing, inventory, variants, and live deployment  
**Store:** Echelon Fit US (`echelon-store.myshopify.com`)  
**Status:** Deployed to the live theme  
**Author:** Nicolas Cartin Reyes<br>
**Audience:** Internal Echelon developers, Shopify administrators and technical operators<br>
**Last updated:** August 21, 2026

## Executive summary

The ThermaChill Main Unit PDP was extended with a dedicated `thermachill-main` product template based on the existing individual-product PDP structure. The new experience allows customers to select any available combination of ThermaChill garments, choose the garment variant or size, choose a quantity, and add the complete configuration to the Shopify cart.

The implementation preserves the existing Main Unit price presentation and adds a compact configuration block for Double Boots, Shoulder Arm, and Vest. Inventory availability determines which garment cards and variant options are rendered. The Main Unit and each selected garment are sent as separate cart lines so Shopify can preserve product identity, variant identity, quantity, pricing, inventory, and line-item properties.

The approved version was first tested in the unpublished **ThermaChill Size Selector QA** theme and was then published to the live theme after a fresh live-theme backup. The Main Unit product was assigned the `thermachill-main` template suffix after the theme file was published.

## Scope of work

| Area | Completed implementation |
|---|---|
| Product records | ThermaChill Main Unit, Double Boots, Shoulder Arm, and Vest maintained as individual Shopify products |
| Main Unit template | New `templates/product.thermachill-main.json` based on the current PDP template |
| Garment configuration | Mix-and-match cards for Double Boots, Shoulder Arm, and Vest |
| Variant selection | Size or option selector populated from available Shopify variants |
| Quantity | Per-garment quantity input with inventory-based maximum |
| Cart behavior | Main Unit plus selected garments added as separate cart lines |
| Availability | Sold-out garments remain visible as disabled cards; unavailable variants are hidden |
| Layout | Fixed three-column grid on desktop and mobile; cards do not expand when others are sold out |
| Responsive price order | Main Unit title and price are shown above the garment selector on tablet and mobile; the desktop header remains unchanged |
| Pricing | Garment Compare-at/MSRP above current selling price; Main Unit pricing unchanged |
| Dynamic subtotal | Main Unit plus selected garment prices multiplied by selected quantities, updated before cart |
| Visual behavior | Garment images use a consistent frame (150px desktop, 96px mobile) and scale to 1.5x on pointer devices |
| Selection state | Add Garment uses a large 28px circular control that fills with ThermaChill navy and shows a white check when selected |
| Selector label | ADD GARMENT is reduced and letter spacing tightened so the complete label fits beside the circular control |
| Membership | Membership purchase flow removed from the ThermaChill configuration flow |
| Deployment | Published to live theme `139674484935` |

## Shopify product and pricing configuration

The catalog uses List/MAP as the current selling price and MSRP as Shopify Compare-at price.

| Product | Current selling price | Compare-at / MSRP | Variant structure |
|---|---:|---:|---|
| ThermaChill Main Unit | $1,499.99 | $1,999.99 | Default/base system variant |
| ThermaChill Double Boots | $499.99 | $599.99 | Short; Standard; Tall |
| ThermaChill Shoulder Arm | $249.99 | $299.99 | S; L |
| ThermaChill Vest | $249.99 | $299.99 | S; M; L |

The garment cards show the Compare-at/MSRP value on the first line and the current selling price immediately below it. The Main Unit continues to show its own standard PDP pricing block. Garment images are rendered inside consistent visual frames so cards align even when source assets have different proportions. The Add Garment control is intentionally larger and circular for clear selection feedback, while its label uses a compact two-line-safe treatment on narrow cards.

## Dynamic configuration subtotal

The Main Unit PDP now displays a `Configuration subtotal` before the customer proceeds to cart. The initial value is the current Main Unit selling price. When a customer selects a garment, the subtotal adds the selected variant price multiplied by the selected quantity. Changing a garment size reads the newly selected variant price, and changing quantity recalculates the line amount while respecting the inventory maximum. Deselecting a garment removes its line from the subtotal without changing the underlying product or inventory data.

The calculation is performed in the browser from Shopify-rendered product and variant prices expressed in cents, then formatted in the store currency. The cart request continues to build separate Main Unit and garment lines; the subtotal is a customer-facing estimate of that same configuration and does not replace Shopify’s authoritative cart totals.

QA validation confirmed `$1,499.99` for the Main Unit alone and `$2,749.96` for the Main Unit plus two Double Boots and one Shoulder Arm. No cart order was submitted during the test.

## Inventory and availability behavior

Inventory is evaluated at the Shopify variant level. The configuration block identifies available variants for each garment. If a garment has no available variants (e.g., the Vest with zero inventory), it remains visible in its fixed grid position but is rendered as a disabled card with a **Sold Out** label. This ensures the layout remains consistent and provides transparency to the customer. If a garment has at least one available variant, only those available variants appear in its size selector.

Each quantity input is initialized to `1` and receives a maximum based on the selected variant inventory. When a customer changes the selected size or option, the maximum quantity is updated. During cart construction, the quantity is normalized to at least `1` and capped to the selected variant inventory before the request is sent to `/cart/add.js`.

The inventory was rebalanced using the confirmed direction to split current Shopify stock evenly across variants before deployment:

| Product | Live inventory allocation after rebalance |
|---|---|
| Double Boots | Short: 7; Standard: 6; Tall: 6 |
| Shoulder Arm | S: 50; L: 49; M removed |
| Vest | S: 0; M: 0; L: 0 |
| ThermaChill Main Unit | Default Title: 38 |

The external inventory reports contained exact source rows for some SKUs but did not provide a verified SKU mapping for every Shopify variant. The rebalance therefore preserved each product’s current aggregate Shopify total and distributed that total evenly by variant.

## Metafield configuration

The Main Unit uses the following product metafield to control which garments are offered in the mix-and-match block:

| Namespace | Key | Type | Purpose |
|---|---|---|---|
| `custom` | `thermachill_mix_match_garments` | `list.product_reference` | Administrable list of garment products displayed on the Main Unit PDP |

The current referenced garments are:

- ThermaChill Double Boots
- ThermaChill Shoulder Arm
- ThermaChill Vest

This design allows the merchandising team to add or remove garments from the Main Unit configuration through Shopify product data without hard-coding additional product IDs into the template.

The prior `custom.pdp_individual_product` membership references were removed from the ThermaChill products per the approved merchandising direction. The new Main Unit configuration does not depend on the membership selector or membership popup.

## Theme files

The implementation is concentrated in the following theme files:

| File | Responsibility |
|---|---|
| `templates/product.thermachill-main.json` | Exclusive Main Unit template based on the existing product PDP structure |
| `snippets/thermachill-mix-match.liquid` | Renders garment cards, available options, prices, selectors, and quantities |
| `snippets/product-template-individual.liquid` | Renders the mix-and-match block only when the product template suffix is `thermachill-main` |
| `snippets/individual-product-selection.liquid` | Main Unit purchase button and inline cart handling for selected garments and quantities |
| `assets/pdp-2025.css` | Card layout, stacked prices, hover enlargement, filled selection state, quantity controls, fixed grid, and responsive Main Unit price order |

The main cart request uses the following conceptual structure:

```json
{
  "items": [
    {
      "id": "main_unit_variant_id",
      "quantity": 1,
      "properties": {
        "_thermachill_main_unit": "true",
        "_thermachill_garment_group": "thermachill-main-unit"
      }
    },
    {
      "id": "selected_garment_variant_id",
      "quantity": "customer_selected_quantity",
      "properties": {
        "_thermachill_garment": "true",
        "_thermachill_garment_product": "garment_product_id",
        "_thermachill_garment_title": "garment_title",
        "_thermachill_garment_group": "thermachill-main-unit"
      }
    }
  ]
}
```

## QA and deployment record

The feature was validated in the unpublished theme **ThermaChill Size Selector QA**, theme ID `160118079687`. QA validation confirmed the following behavior:

| Test | Result |
|---|---|
| Main Unit template renders | Passed |
| Three garment cards render | Passed |
| Garment size selectors render | Passed |
| Unavailable variants are filtered | Passed |
| Quantity fields render | Passed |
| Quantity maximums reflect selected variant inventory | Passed |
| Cart handler contains selected quantity logic | Passed by DOM and handler inspection; no real order submitted |
| Compare-at/MSRP stacks above sale price | Passed |
| Configuration subtotal displays before cart | Passed; starts at $1,499.99 |
| Subtotal updates for selected garments and quantities | Passed; Main Unit + 2 Double Boots + 1 Shoulder Arm = $2,749.96 |
| Garment image frame is consistent across cards | Passed with 150px desktop and 96px mobile image frames |
| Hover image scale is 1.5x on pointer devices | Implemented in live CSS |
| Selected Add Garment circle is large and fully filled | Implemented in live CSS with white check mark |
| ADD GARMENT label fits beside the circle | Passed after reduced font size and tightened letter spacing |
| Main Unit price appears before garments on tablet/mobile | Published to live CSS and template; endpoint renders the updated PDP |
| Membership purchase UI removed from configuration flow | Passed |

Before live publication, the previous live theme was pulled to a local backup directory:

`./backups/echelon-live-theme-pre-publish-thermachill`

The approved files were then published to live theme `139674484935`, named `echelon-US/live-published-theme`. The final CSS refinement for consistent image framing, the larger circular selector, and the compact ADD GARMENT label was published to the same live theme on August 20, 2026. The dynamic configuration subtotal snippet and styles were published to the same live theme on August 21, 2026. The fixed three-column layout and Sold Out card state were published to the same live theme on August 21, 2026. The responsive Main Unit title and price header for tablet and mobile was published to the same live theme on August 21, 2026 after a fresh live-theme backup. The Main Unit product was assigned:

```text
templateSuffix: thermachill-main
```

The live PDP was verified after deployment:

[Live ThermaChill PDP](https://echelonfit.com/products/thermachill)

## Maintenance instructions

Future garment changes should be made by updating the `custom.thermachill_mix_match_garments` product metafield on the Main Unit. The referenced product must have active variants, accurate prices, Compare-at prices, and inventory before it is added to the list.

Future theme changes should be developed in the QA theme first. The recommended workflow is to pull or preserve a live backup, update the local theme files, push only the affected files to QA, inspect the QA preview on desktop and mobile widths, and then publish to live only after approval. The responsive Main Unit price order is controlled by `thermachill-main-unit__mobile-header`, `thermachill-main-unit__desktop-title`, and `thermachill-main-unit__desktop-price` in the individual product snippet and `pdp-2025.css`.

Before changing inventory, confirm the authoritative stock source and exact SKU mapping for each Shopify variant. The storefront logic correctly reads Shopify variant availability, but it cannot infer that an external inventory-report row belongs to a specific Shopify variant when the SKU mapping is ambiguous.

No real cart order was submitted during QA or live verification. A post-deployment functional test should add a controlled Main Unit and garment combination to cart in a non-production test session before any customer-facing campaign or promotion relies on the new configuration.

## References

[1]: https://echelonfit.com/products/thermachill "Live ThermaChill Main Unit PDP"

[2]: https://echelon-store.myshopify.com/products/thermachill?view=thermachill-main&preview_theme_id=160118079687 "ThermaChill QA Preview"

[3]: https://admin.shopify.com/store/echelon-store/themes/139674484935/editor "Live Shopify Theme Editor"

[4]: https://admin.shopify.com/store/echelon-store/products/8645094342855 "ThermaChill Main Unit Shopify Product"

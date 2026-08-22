# US to UK membership architecture comparison

## Confirmed US implementation

The US store uses `custom.pdp_individual_product` as a Product metafield of type `list.product_reference`. Multiple active equipment PDPs point to the same three standard Premier Product records in order: Monthly, Yearly, 2-Year. The Liquid snippet `individual-product-selection` checks whether the list is populated, assigns `.value` to `product_list`, loops over referenced Product objects, reads each related product's `custom.pdp_badges_individual_product_json`, and passes the resulting presentation fields into `product-radio-option`.

This is an effective dynamic membership selector, but it is narrow. It handles membership references and related product badge data, while the surrounding PDP still has additional logic, sections, and historical SKU-specific dependencies.

## UK PDF target architecture

The UK PDF calls for one neutral `product.dynamic` wrapper and one product profile reference such as `custom.template_profile`. The profile stores product-specific content, shipping, pricing labels, financing, specifications, media, comparison rows, safety content, membership offers, warranty reference, promotions, and related collections. Membership plans are represented by `membership_offer` metaobjects whose `variant` field is a Product variant reference, not a numeric ID in Liquid or JavaScript.

## Recommended bridge

Do not delete the US `custom.pdp_individual_product` pattern before the UK migration is validated. Treat it as the proven source behavior for the membership portion. In UK, implement the broader profile model and store the membership list inside `profile.membership_offers`, or use a compatibility layer that maps the existing list-product-reference field into a normalized membership-offer collection.

The preferred UK end state is:
`product -> custom.template_profile -> profile.membership_offers -> membership_offer.variant`

The existing US compatibility path is:
`product -> custom.pdp_individual_product -> referenced Product -> product.metafields.custom.pdp_badges_individual_product_json`

## Main differences

| Concern | US current pattern | UK target pattern |
|---|---|---|
| PDP membership source | Product list reference | Product profile list of membership-offer records |
| Plan item reference | Referenced Product, with its first available variant used downstream | Direct Product variant reference in membership offer |
| Badge and copy data | Product JSON metafield on referenced membership Product | Fields on membership-offer record |
| Product-specific content | Distributed across product metafields, sections, snippets, and legacy SKU branches | Centralized in product_template_profile |
| Template strategy | Existing product template and `individual-product-selection` snippet | Neutral `product.dynamic` wrapper and reusable sections |
| Cart IDs | Existing code contains some fixed IDs in historical branches | No numeric IDs in Liquid, JS, or section settings |
| Free delivery rule | Existing shipping and membership rules are partly distributed | Enforce `free_delivery` and annual/two-year-only rule in data and template |
| Missing data | Risk of legacy content leaking from copied SKU templates | Render nothing or a neutral fallback, never another SKU's content |

## Migration implication

The UK implementation should first establish the metaobject definitions and neutral wrappers, then migrate the approved visual markup section by section. The membership selector should be tested on at least two products sharing the same template, and the cart line items should be compared before any live publish.

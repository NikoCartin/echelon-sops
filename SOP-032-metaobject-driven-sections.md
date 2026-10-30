# SOP-032: Building Theme Sections from Metaobjects (Rower Coaches Example)

**Author:** Nícolas Cartín Reyes, Lead Developer
**Date:** October 29, 2026
**Scope:** Echelon US theme, `/collections/rower` coaches section; pattern applies to any repeated content
**Status:** Live on the rower page

## Purpose

Hardcoded lists in JavaScript or section settings go out of date. This SOP explains how to load repeated content, such as coaches, from Shopify metaobjects so the page updates when the content team edits Shopify, with no code change.

## Rower coaches example

- Source: the `instructor` metaobject definition, the same entries `/pages/instructors` uses.
- Filter: instructors whose `teaching_categories` include `Row`, with a name and a photo (headshot as fallback).
- Output: Liquid writes the list as JSON to `window.EchelonRowerCoaches`, and the rower page script renders cards from it. Cards link to `/pages/instructors`.

```liquid
window.EchelonRowerCoaches = [
  {%- assign sep = '' -%}
  {%- for instructor in shop.metaobjects.instructor.values -%}
    {%- assign teaches_row = false -%}
    {%- for category in instructor.teaching_categories.value -%}
      {%- if category.category.value == 'Row' -%}{%- assign teaches_row = true -%}{%- endif -%}
    {%- endfor -%}
    {%- assign img = instructor.photo.value | default: instructor.headshot.value -%}
    {%- if teaches_row and instructor.name.value != blank and img != blank -%}
      {{ sep }}{"name": {{ instructor.name.value | json }}, "image": {{ img | image_url: width: 800 | prepend: 'https:' | json }}}
      {%- assign sep = ',' -%}
    {%- endif -%}
  {%- endfor -%}
];
```

## Updating the coaches (no developer needed)

1. In Shopify admin, open Content > Metaobjects > Instructor.
2. To add a coach to the rower page, add the `Row` teaching category and make sure the entry has a photo.
3. To remove one, remove the `Row` category or delete the entry.
4. Reload `/collections/rower`; the grid adjusts to the number of coaches.

## Applying the pattern elsewhere

1. Check whether a metaobject already holds the content before creating a new definition.
2. Always output values through the `json` filter, and skip entries missing required fields so a blank entry can't break the layout.
3. Use `image_url` with a width instead of raw file URLs, so deleted or renamed files don't leave hardcoded 404s.
4. Avoid hardcoded counts in copy (for example "40+ instructors"); they drift from the data.
5. Release through an unpublished theme and the controlled push steps.

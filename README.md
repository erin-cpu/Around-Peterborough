# Peterborough Holiday Happenings

An interactive guide to the 2026 holiday season in Peterborough, New Hampshire:
every event in list and calendar form, a to-scale downtown map, and a directory
of shop hours and offers.

One HTML file, no build dependencies, no framework, no tracking.

## What's in it

**All events** — nineteen events from Nov 21 to Dec 15, searchable, filterable
by seven categories. Events can carry two categories, so the ConVal Craft Fair
and the MAxT Night Market appear under both *Markets & fairs* and *Shop local*.

**Calendar** — November and December side by side. Coloured dots per category,
a tint across the Giving Trees window, and a day panel underneath. Events can
be a single date, a continuous range, or a set of separate days (Holiday Trees
runs Friday, Saturday and Monday, skipping the Sunday).

**Downtown map** — drawn from OpenStreetMap geometry and projected
equirectangular about 42.877° N:

```
x = (lon + 71.9540) * 88014
y = (42.8800 - lat) * 120000
```

One unit is about 0.93 m, so the drawing is to scale and carries a scale bar
that steps up as you zoom out. Eight venue pins, two highlighted event routes,
and 28 points of interest across seven toggleable layers — two of which
(Holiday Stroll stops, Giving Trees) solo themselves and hide the rest.

It pans by dragging and zooms with the `+` / `−` buttons or ctrl-wheel. The
house button returns to downtown; **ALL** frames the whole town — ConVal and
Brady's north up the Hancock Road, Divine Mercy east on Wilton Road, and MAxT
south-west at Noone Falls. Downtown detail — minor streets, street labels,
parking, and the downtown markers — drops away past 2.2× so the wide view stays
readable. The out-of-town road network is a separate, harder-thinned set
(`HIGHWAYS`) drawn at every zoom.

**Shops & offers** — holiday hours and promotions. See *Where the shop data
lives* below.

## Layout

```
build.ps1              regenerates docs/index.html from src/page.html
src/page.html          the source of truth — edit this
docs/                  what GitHub Pages serves
  index.html           generated; do not hand-edit
  messiah-flyer.jpg
  data/businesses.json shop snapshot used by the static build
```

`src/page.html` has no `<!doctype>`, `<html>`, `<head>` or `<body>`. That is
deliberate: it is also published as a Claude artifact, and that viewer supplies
the document skeleton. `build.ps1` wraps the same source in a real document for
static hosting.

## Building

```
powershell -ExecutionPolicy Bypass -File .\build.ps1
```

Then open `docs/index.html`, or serve the `docs` folder over HTTP. Serving it
matters for the shop list, which is fetched rather than inlined — `file://`
blocks that fetch and the page falls back to a "shop list unavailable" card.
Everything else works from disk.

## Publishing with GitHub Pages

Settings → Pages → Source: *Deploy from a branch*, branch `main`, folder
`/docs`. No Actions workflow needed.

## Editing the content

Everything lives in plain arrays near the top of the `<script>` in
`src/page.html`. Run `build.ps1` after any change.

**Add an event** — push an object onto `EVENTS`:

```js
{
  id:"unique-slug",
  title:"Event name",
  cat:"family",                  // shop | market | make | wellness | lights | music | family | giving
  also:["shop"],                 // optional second category
  start:"2026-12-04",            // and either:
  end:"2026-12-06",              //   a continuous range
  days:["2026-12-04","2026-12-07"], //   or separate days
  time:"6 – 9 PM",
  sort:1080,                     // minutes past midnight; -1 for all-day
  place:"Where it is",
  venue:"library",               // a key in VENUES, or anything for off-map
  desc:"One or two sentences.",
  list:["Bullet","Bullet"],      // optional
  note:"A line above the links.",// optional
  email:"someone@example.com",   // optional, shown with a copy button
  links:[{label:"Tickets", href:"https://..."}],
  flag:"Something to verify.",   // optional warning box
  flyer:{src:"poster.jpg", alt:"Describe the poster"} // optional
}
```

**Add a map pin** — add to `VENUES` with `x`/`y` in map units and `lx`/`ly`
for the label. Convert a real coordinate with the projection above.

**Add a point of interest** — add to `POIS` with a group of `food`, `shop`,
`culture` or `civic`. Parking markers come from `LOTS`.

## Where the shop data lives

The page has two sources, and picks whichever is available:

- **As a Claude artifact** it uses the artifact database, so anyone with
  Contributor access can add and edit businesses directly on the page and
  everyone sees the change.
- **As a static site** that API is absent, so it fetches
  `docs/data/businesses.json` and renders it read-only.

To refresh the static snapshot, export the artifact's `businesses` collection
into that file. The fields are `id`, `name`, `category`, `promo`, `hours`,
`address` and `link`.

## Accuracy notes

Street geometry, the Contoocook and the Nubanusit, the parks and the parking
lots come from OpenStreetMap. Business listings were taken from the same source
and then corrected by hand where the data was stale — OSM is community
maintained and runs a few years behind on storefronts. Address geocoding placed
two businesses on the wrong side of their street; those were fixed manually.
Expect to keep correcting it.

Dates come from the printed *Holiday Happenings* flyer. Four of them
contradicted themselves and were resolved with the organisers.

## Credits

Map data © [OpenStreetMap](https://www.openstreetmap.org/copyright)
contributors, [ODbL](https://opendatacommons.org/licenses/odbl/). Fonts are
Newsreader and Public Sans from Google Fonts. The Messiah flyer belongs to its
creators and is included with permission of whoever supplied it.

Event information belongs to the organisations running each event. Confirm
times with the host before you go.

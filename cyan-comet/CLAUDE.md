# simonprojects.eu — Astro fejlesztési útmutató

## Projekt kontextus

- **Framework:** Astro 6.x (statikus site generator)
- **Dev szerver:** `nohup npm run dev -- --host > ~/dev.log 2>&1 &`
- **Élő preview:** <http://192.168.1.196:4321/>
- **Deploy:** cPanel git pull a `deploy` branch-ből (részletek: `../CLAUDE.md`)

## Kódolási konvenciók

- Magyar nyelvű tartalom, angol nyelvű kód (változónevek, fájlnevek)
- Fájlnév: `kebab-case` (pl. `hero-section.astro`), komponens: PascalCase (pl. `HeroSection.astro`)
- CSS: scoped `<style>` Astro komponensekben; globális CSS → `src/styles/global.css`
- Képek: WebP formátum, `public/images/` mappában
- Nincs felesleges JS — statikus HTML/CSS, JS csak indokolt esetben
- Reszponzív: mobile-first, 375px–1440px

## Projekt struktúra

```text
cyan-comet/
├── src/
│   ├── pages/          # .astro oldalak (route = fájlnév)
│   │   └── en/         # Angol i18n oldalak
│   ├── components/     # Nav, Footer, Card, HeroSection, DarkModeToggle
│   ├── layouts/        # BaseLayout.astro
│   └── styles/         # global.css (design tokenek, dark mode, reset)
├── public/             # Statikus assets (képek, favicon, robots.txt)
├── astro.config.mjs    # site URL, i18n, sitemap integráció
└── package.json
```

## Oldalak státusza

| Oldal | Fájl | HU | EN |
| --- | --- | --- | --- |
| Főoldal | `index.astro` | kész | kész |
| Rólam | `about.astro` | kész | kész |
| Portfólióm | `projects.astro` | kész | kész |
| Elérhetőség | `contact.astro` | kész | kész |
| 404 | `404.astro` | kész | — |
| Impresszum | `impresszum.astro` | kész | kész (`en/impresszum.astro`) |

## Dizájn rendszer

- **Betűtípus:** Inter (body) + Instrument Serif (display)
- **Színpaletta:** meleg bézs háttér (`#f5f0eb`), teal akcentus (`#01696f`)
- **Dark mode:** `.dark` class + `prefers-color-scheme` hibrid, localStorage
- **Spacing:** CSS custom properties (`--space-xs` → `--space-5xl`)
- **SEO:** JSON-LD, hreflang (hu/en), OG/Twitter meta, sitemap

## i18n

- Default locale: `hu` (prefix nélkül: `/about/`)
- Angol: `/en/` prefix (`/en/about/`)
- Nav-ban HU/EN toggle gomb
- `astro.config.mjs`-ben `i18n` konfig

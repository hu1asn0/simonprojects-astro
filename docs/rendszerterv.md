# simonprojects-astro (simonprojects.eu) — rendszerterv

**Frissítve:** 2026-08-10 · Ez a projekt kurált jelen-állapot oldala. A session-napló a repo CLAUDE.md-jében él, a task-szintű teendők a backlogban. Ahol számot állítunk, jelöljük: **[mért]** vagy **[terv]**.

---

## 1. Miért létezik?

A simonprojects.eu **nem önálló brand**: a 2026-04-25-i brand-merger óta a **Prio Consulting Kft. sister-site-ja** — technical proof / credibility engine az „Applied AI IT PM @ Prio Consulting" pozicionálás mögött. A munkamegosztás: a prioconsulting.hu ad el, a simonprojects.eu **bizonyít** — élő AI-labor, ahol a projektek (trading-signals, scanner, RAG) publikus case-ként láthatók. Ebből következik a legfontosabb szabály: **minden CTA a `prioconsulting.hu/applied-ai/`-ra mutat**, a hero HU/EN szövege „Élő AI-labor a Prio Consulting mögött" / „A live AI lab behind Prio Consulting". A brand-merger a site-on 2026-07-30-án zárult le (merge `9b6b0d0` + `6c6dfc1`): footer minden oldalon `© 2026 Prio Consulting Kft.`, impresszum HU+EN teljes Kft.-adatokkal, a `dist`-ben 0 e.v. maradvány **[mért]**.

Történetileg a site a WordPress-es simonprojects.eu kiváltása Astro statikus site-tal.

## 2. Mit tud?

- **53 oldal HU+EN** [mért: 52 `index.html` a dist-ben + 404] — alap-oldalak (főoldal, rólam, portfólió, kapcsolat, impresszum, blog) magyar defaulttal (`/about/`) és `/en/` prefixű angol tükörrel, kétirányú hreflang + JSON-LD + sitemap
- **Beehiiv-vezérelt blog**: a hírlevél-tartalom RSS-ből épül be build-időben (`cyan-comet/src/lib/beehiiv.js` → `blog/[slug].astro` HU+EN), a blog-aloldalak adják az oldalszám zömét
- **Emerald/amber design** [a gyökér CLAUDE.md szerint; az emerald tokenek — `#34d399`, `#6ee7b7` — a `global.css`-ben mérve], dark mode (`.dark` class + `prefers-color-scheme` hibrid), Inter + Instrument Serif, mobile-first, minimál JS
- **Email-obfuszkáció**: `info[ at]simonprojects.eu`, 0 `mailto` a kimenetben [mért, deploy `9a28c3f`]
- Case-tartalom: a projekt-portfólió oldal él; a trading-signals case writeup és a `/work` 6 case card **nyitott feladat** (7. szekció)

## 3. Architektúra és jelenlegi állapot

Kétgépes, egyirányú lánc: az otthoni szerver (M920q) buildel és pushol, a tárhely (cPanel) ütemezetten pullol — bejövő kapcsolat egyik irányban sincs.

```text
Beehiiv RSS ──(build-időben fetch: src/lib/beehiiv.js)──▶
  cyan-comet/ (Astro 6.x forrás, main branch)
    │ sync-beehiiv.sh: npm run build → dist/ → /tmp mentés
    ▼
  deploy branch (CSAK a kész dist/ tartalma)
    │ git push origin deploy
    ▼
  GitHub (hu1asn0/simonprojects-astro)
    │ cPanel-OLDALI cron: uapi VersionControl update (ADR-002)
    ▼
  s40.tarhely.com — /home/simonpr2/public_html → simonprojects.eu
```

**Állapot:** éles és stabil. A deploy-lánc 2026-04-06 és 2026-07-28 között fagyott volt (a cPanel sosem pullolt — ADR-002), azóta helyreállítva; a legutóbbi cron-futás 2026-08-07-én hibátlanul zárult („No changes — skipping commit") [mért: `beehiiv-sync.log`]. A repo két aktív branchet használ: `main` (forrás) és `deploy` (csak build-kimenet) — **a deploy branchre kézzel soha nem váltunk**, azt a `sync-beehiiv.sh` kezeli.

## 4. Döntések

| Döntés | Dátum | Lényeg |
| --- | --- | --- |
| **Brand-merger** | 2026-04-25 | E.v. szüneteltetve, Prio Consulting Kft. az egyetlen jogi entitás; a simonprojects.eu sister-site (technical proof), nem önálló brand — minden CTA a prioconsulting.hu/applied-ai/-ra. A site-on 2026-07-30-án teljeskörűen átvezetve |
| **ADR-002: cPanel deploy-transzport** (`~/.claude/decisions/ADR-002-cpanel-deploy-transport.md`) | 2026-07-28 | A cPanel nem pullol push-ra, a szerverről hívott UAPI-t az Imunify360 blokkolja → a pull a **tárhely oldaláról** fut cPanel-cronnal; a szerveroldali API-hívás best-effort kiegészítés `CPANEL_TOKEN` guard mögött. Élesedés ütemezett (max. ~12 óra csúszás), éles verifikáció (`curl` + tartalmi grep) minden deploy után kötelező |
| **Szolgáltató ≠ hostname** | — | A tárhelyszolgáltató a Websupport Magyarország Kft. (mhosting.hu), a kiszolgáló hostneve `s40.tarhely.com` — két külön réteg, nem ellentmondás; az impresszumba a szolgáltató cégadatai kellenek. A prioconsulting.hu **külön szerveren** él (s50), külön cPanel fiókkal |

## 5. Interfészek

- **Beehiiv RSS** (befelé): a blog egyetlen tartalomforrása; build-időben fetch, hiba esetén a build bukik és a régi éles állapot marad
- **GitHub `deploy` branch** (kifelé): a határ a két gép között — csak a kész `dist/` tartalma, forrás és `node_modules` soha
- **cPanel @ s40.tarhely.com** (pull-oldal): saját fiók (`simonpr2`), cPanel-oldali cron pullolja a deploy branchet a `public_html`-be (ADR-002). Ismert csapda: untracked fájl a `public_html`-ben megállítja a pullt
- **prioconsulting.hu** (tartalmi interfész): minden CTA a `/applied-ai/` pillar oldalra mutat; az impresszum cross-linkel az elsődleges (prioconsulting.hu-s) impresszumra

## 6. Üzemeltetés

- **Belépési pont:** `sync-beehiiv.sh` — a cron-ütemezés **egyetlen forrása a gyökér `~/CLAUDE.md` Cron-táblája** (itt szándékosan nem ismételjük)
- **Védőrétegek a scriptben** (a 2026-07-20-i „astro: not found" cron-bukás tanulságaiból): **branch guard** (ha a working tree a deploy branchen ragadt, self-heal vagy hangos hiba) · **EXIT restore trap** (build/push/OOM-bukásnál is visszavált main-re) · a deploy-branch takarítás **kíméli** a `cyan-comet/`-et, `.env`-et és logokat (a korábbi `rm -rf` a `node_modules`-t is törölte) · `node_modules` auto-restore (`npm install`, ha hiányzik) · commit-döntés staged diff alapján (az üres commit korábban `set -e`-vel ölte a scriptet) · Netdata gauge-ok (`cron_exit`/`cron_time.beehiiv_sync`)
- **Napló:** `beehiiv-sync.log` a repo gyökerében
- **Kézi deploy / hibakezelés:** a repo `CLAUDE.md`-jében; deployhoz a `/deploy` skill használandó
- **Secrets:** `.env` git-ignored (cPanel API-hitelesítők) — soha nem commitolható, tartalma ide sem kerül

## 7. Roadmap

1. **Trading-signals case writeup** — a legerősebb élő proof-asset még nincs megírva a site-ra [terv]
2. **`/work` oldal 6 case carddal** — a `src/pages/` alatt ma nincs work oldal [mért]; a portfólió-bemutatás következő lépcsője [terv]
3. Az umbrella go-to-market ciklus (portal `/applied-ai-plan`) lejárt (2026-07-13); az új 12 hetes ciklus **user-döntésre vár** — a site ebből kapja majd a tartalmi feladatait

---

*Kapcsolódó dokumentumok: repo `CLAUDE.md` (deploy-részletek, skillek) · `cyan-comet/CLAUDE.md` (Astro-konvenciók — az oldalszám- és színlistája a merger előtti állapotot tükrözi, elavult) · `~/.claude/decisions/ADR-002-cpanel-deploy-transport.md` · gyökér `~/CLAUDE.md` → Cron-tábla + Státusz*

# Changelog

A verziózási szabályokat lásd [`../docs/RELEASING.md`](../docs/RELEASING.md).

## [1.0.0] — 2026-09-15

Első verziójelölés — a jelenlegi éles állapot megnevezése, nem egy adott
naptári változás.

### Jelenlegi állapot

- Astro 6 statikus site a `simonprojects.eu` WordPress oldal kiváltására,
  éles, HU + EN, emerald/amber design, 53 oldal.
- Astro projekt a `cyan-comet/` almappában; a `deploy` branch tartalmazza a
  kész `dist/` kimenetet, amit a cPanel (**s40.tarhely.com**, saját cPanel
  fiók, tárhelyszolgáltató Websupport Magyarország Kft. / mhosting.hu)
  naponta pull-ol.
- 2026-07-28: a deploy-lánc helyreállítva — 2026-04-06 óta fagyott volt
  élesben. A `sync-beehiiv.sh` javítva: az addigi `rm -rf cyan-comet` a
  `node_modules`-t is törölte, ezért bukott a cron build 2026-07-20 óta
  (`astro: not found`); most branch guard + restore trap + `.env`/log
  védelem alatt fut.
- Email-obfuszkáció: `info[ at]simonprojects.eu`, 0 `mailto` link.
- 2026-04-25 brand-merger: az egyéni vállalkozás szüneteltetve, a
  `simonprojects.eu` a **Prio Consulting Kft. sister-site-ja** (technical
  proof / credibility engine), nem önálló brand.
- 2026-07-30: a brand-merger lezárva a site-on — hero HU/EN „Élő AI-labor a
  Prio Consulting mögött" / „A live AI lab behind Prio Consulting", CTA-k a
  `prioconsulting.hu/applied-ai/`-ra; meta title+description átírva; footer
  mind az 52 oldalon `© 2026 Prio Consulting Kft.`; impresszum HU+EN teljes
  Kft.-adatokkal (cégjegyzékszám, adószám) + tárhelyszolgáltató adatai +
  cross-link az elsődleges impresszumra. A `dist`-ben 0 e.v.-maradvány.
- Deploy cron: `simonprojects-astro/sync-beehiiv.sh`, H/Sz/P 10:00 — lásd a
  gyökér `CLAUDE.md` `## Cron` táblája.

### Előzmények

A fenti állapot 2026-04-16 (initial Astro 6 portfolio build) és 2026-07-30
(brand-merger lezárása) közötti commitok eredménye — lásd `git log`. A fájl
visszamenőleg nem sorol fel korábbi verziószámokat, mert 2026-09-15 előtt a
repónak nem volt saját verziózása.

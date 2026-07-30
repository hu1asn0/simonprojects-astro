# simonprojects-astro — simonprojects.eu statikus oldal

## Projekt áttekintés

A `simonprojects.eu` WordPress oldal kiváltása Astro 6.x statikus site-tal.

- **Framework:** Astro 6.x
- **Astro projekt:** `cyan-comet/` almappa (fejlesztési részletek ott: `cyan-comet/CLAUDE.md`)
- **GitHub repo:** `hu1asn0/simonprojects-astro`

## Deploy — cPanel (mhosting.hu)

A `deploy` branch tartalmazza a kész `dist/` kimenetet. A cPanel naponta pull-olja.

**Szolgáltató vs. szerver — ne keverd össze:** a tárhelyszolgáltató a **Websupport
Magyarország Kft. (mhosting.hu)**, a kiszolgáló gép hostneve viszont `s40.tarhely.com`
(a `simonprojects.eu` A rekordja `185.111.89.234`, reverse DNS-ben ez látszik). A kettő nem
mond ellent egymásnak, csak más réteg — az impresszumba a **szolgáltató** cégadatai
kellenek, nem a szerver hostneve.

**Manuális deploy lépések:**

```bash
cd ~/simonprojects-astro/cyan-comet && npm run build
cd ~/simonprojects-astro && git checkout deploy && git rm -rf . && cp -r cyan-comet/dist/* . && git add -A && git commit -m "deploy: update" && git push origin deploy && git checkout main
```

**cPanel beállítás:**
- Repo path: `/home/simonpr2/public_html`
- Branch: `deploy`
- Cron: naponta `git fetch origin deploy && git reset --hard origin/deploy`

## Slash commandok (skills)

| Trigger | Skill | Leírás |
| --- | --- | --- |
| `/site-build` | `.claude/skills/site-build/SKILL.md` | Build + hibaellenőrzés |
| `/git-sync` | `.claude/skills/git-sync/SKILL.md` | Stage → commit → push |
| `/seo-audit` | `.claude/skills/seo-audit/SKILL.md` | Meta, sitemap, OG ellenőrzés |
| `/add-page [név]` | `.claude/skills/add-page/SKILL.md` | Új Astro oldal |

## Commit konvenció

```text
feat: [mit adtál hozzá]
fix: [mit javítottál]
content: [tartalom változás]
style: [csak CSS/design]
chore: [config, dependency]
```

## Hibakezelés

| Hiba | Megoldás |
| --- | --- |
| `npm run build` sikertelen | Hiányzó import vagy rossz frontmatter |
| Git push rejected | `git pull --rebase origin main` |
| 404 a live oldalon | `dist/` üres vagy deploy branch nincs frissítve |

## Secrets

`.env` fájl git-ignored — soha ne commitold.

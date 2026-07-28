#!/bin/bash
# Beehiiv RSS sync — rebuild Astro site and push to deploy branch
# Cron: 0 10 * * 1,3,5 (hétfő + szerda + péntek 10:00)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASTRO_DIR="$SCRIPT_DIR/cyan-comet"
LOG="$SCRIPT_DIR/beehiiv-sync.log"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"; }

# cPanel API credentials (CPANEL_HOST/USER/TOKEN/REPO_ROOT/BRANCH) — optional
if [ -f "$SCRIPT_DIR/.env" ]; then
    set -a; . "$SCRIPT_DIR/.env"; set +a
fi

# Branch guard: this script only exists on main — if a previous run died
# mid-deploy, the working tree is stuck on the deploy branch and cron fails
# silently (exit 127). Try to self-heal, otherwise fail loudly.
_GUARD_BRANCH=$(git -C "$SCRIPT_DIR" branch --show-current)
if [ "$_GUARD_BRANCH" != "main" ]; then
    log "WARN: working tree on '$_GUARD_BRANCH', expected main — attempting recovery"
    if git -C "$SCRIPT_DIR" checkout main >> "$LOG" 2>&1; then
        log "Recovery OK: switched back to main"
    else
        log "ERROR: cannot switch back to main (uncommitted changes?) — manual fix required"
        exit 1
    fi
fi

# Restore trap: guarantee the working tree is back on main even if the
# script dies mid-deploy (build fail, push fail, signal, OOM).
restore_branch() {
    local _now
    _now=$(git -C "$SCRIPT_DIR" branch --show-current)
    if [ "$_now" != "main" ]; then
        git -C "$SCRIPT_DIR" checkout main >> "$LOG" 2>&1 || true
        log "Restore trap: switched back to main (was on '$_now')"
    fi
}

# Netdata monitoring + branch restore
_CRON_START=$(date +%s)
trap '_RC=$?; restore_branch; echo "cron_exit.beehiiv_sync:$_RC|g" | nc -u -w0 127.0.0.1 8125 2>/dev/null; echo "cron_time.beehiiv_sync:$(( $(date +%s) - _CRON_START ))|g" | nc -u -w0 127.0.0.1 8125 2>/dev/null' EXIT

log "=== Beehiiv sync started ==="

# Step 0: Restore node_modules if a previous run wiped it
if [ ! -f "$ASTRO_DIR/node_modules/.package-lock.json" ]; then
    log "node_modules missing — running npm install..."
    (cd "$ASTRO_DIR" && npm install >> "$LOG" 2>&1)
fi

# Step 1: Build
cd "$ASTRO_DIR"
log "Building Astro site..."
if npm run build >> "$LOG" 2>&1; then
    PAGE_COUNT=$(find dist -name '*.html' | wc -l)
    log "Build OK — $PAGE_COUNT pages"
else
    log "ERROR: Build failed"
    exit 1
fi

# Step 2: Save dist to /tmp (before branch switch / cleanup kills it!)
rm -rf /tmp/simonprojects-deploy-dist
cp -r "$ASTRO_DIR/dist" /tmp/simonprojects-deploy-dist
log "dist saved to /tmp"

# Step 3: Push to deploy branch
cd "$SCRIPT_DIR"

log "Switching to deploy branch..."
git checkout deploy >> "$LOG" 2>&1

# Clean old dist files (keep .git and cyan-comet — the latter holds
# node_modules/dist which are gitignored and must survive the deploy)
find . -maxdepth 1 \
    -not -name '.git' -not -name '.' -not -name '..' \
    -not -name 'cyan-comet' -not -name '.env' -not -name '*.log' \
    -exec rm -rf {} + 2>/dev/null || true

# Copy new build output
cp -r /tmp/simonprojects-deploy-dist/* .

# Commit and push if there are staged changes.
# NOTE: decide AFTER add+reset — untracked-but-ignored files (logs, .astro)
# used to trigger a "nothing added to commit" failure that killed the script
# mid-deploy via set -e, stranding the working tree on the deploy branch.
git add -A
git reset HEAD -- cyan-comet/ .env ./*.log 2>/dev/null || true
if git diff --cached --quiet; then
    log "No changes — skipping commit"
else
    git commit -m "deploy: beehiiv sync $(date '+%Y-%m-%d %H:%M')" >> "$LOG" 2>&1
    git push origin deploy >> "$LOG" 2>&1
    log "Deployed to origin/deploy"

    # Best-effort cPanel pull trigger — optional, only if .env provides a
    # token. Requires the server IP to be whitelisted in Imunify360 on the
    # host — until then this logs the denial but must not fail the sync.
    if [ -n "${CPANEL_TOKEN:-}" ]; then
        _cpanel_resp=$(curl -sG --max-time 30 -A "Mozilla/5.0" \
            -H "Accept: application/json" \
            -H "Authorization: cpanel ${CPANEL_USER}:${CPANEL_TOKEN}" \
            --data-urlencode "repository_root=${CPANEL_REPO_ROOT}" \
            --data-urlencode "branch=${CPANEL_BRANCH}" \
            "https://${CPANEL_HOST}:2083/execute/VersionControl/update" || true)
        log "cPanel pull response: $(echo "$_cpanel_resp" | tr -d '\n' | head -c 300)"
    fi
fi

# Step 4: Switch back to main (restore trap covers failure paths)
git checkout main >> "$LOG" 2>&1
log "=== Beehiiv sync complete ==="

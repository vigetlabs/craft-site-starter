#!/usr/bin/env bash
#
# Pre-populate Composer's dist cache for every GitHub-hosted package in
# composer.lock, without calling the GitHub API.
# .claude/cloud/environment-setup.sh and .claude/hooks/session-start.sh run it
# into DDEV's Composer cache before `ddev start`; see docs/claude-cloud.md.
#
# Why: in Claude Code cloud sessions the GitHub proxy returns 403 for archive
# downloads (api.github.com/.../zipball, codeload.github.com) from any
# repository not attached to the session, while anonymous `git fetch` over
# github.com still works. Composer reports the 403 as "Could not authenticate
# against github.com" and falls back to full-history source clones, which are
# slow and ignore export-ignore.
# See https://github.com/anthropics/claude-code/issues/78330
#
# How: for each locked package whose dist is a GitHub zipball, shallow-fetch
# the single locked commit and `git archive` it. That honours export-ignore
# and export-subst from the archived tree, as GitHub's own archives do. The zip
# is written to <cache-files-dir>/<package>/<sha1 of dist url>.zip, the path
# Composer checks before downloading a dist. composer.json and composer.lock
# are never modified.
#
# Usage:
#   .claude/cloud/warm-composer-cache.sh [project-dir]    # default: cwd
#
# Environment:
#   JOBS=8     parallel fetches
#   FORCE=1    rebuild zips that are already cached
#
# Afterwards, install from the cache. COMPOSER_DISABLE_NETWORK=1 asks Composer
# (best effort) to fail on a missing cache entry rather than download it, and
# COMPOSER_ALLOW_SUPERUSER=1 is needed when running as root so Composer
# plugins (craftcms/plugin-installer, yiisoft/yii2-composer) are enabled:
#   COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_DISABLE_NETWORK=1 composer install

set -euo pipefail

export GIT_TERMINAL_PROMPT=0

# Worker mode, invoked once per package by xargs below.
if [[ ${1:-} == __build ]]; then
    name=$2 repo=$3 ref=$4 key=$5
    target="$CACHE_DIR/$name/$key.zip"

    if [[ -s $target && ${FORCE:-0} != 1 ]]; then
        echo "cached  $name"
        exit 0
    fi

    mkdir -p "${target%/*}"
    work=$(mktemp -d)
    tmp="$target.tmp.$$"
    trap 'rm -rf "$work" "$tmp"' EXIT

    # GitHub names the archive's top-level directory <owner>-<repo>-<sha7>.
    # Composer strips it on extraction, so it only matters for fidelity.
    if git -c init.defaultBranch=main -C "$work" init -q \
        && git -C "$work" fetch -q --depth 1 --no-tags "https://github.com/$repo.git" "$ref" \
        && git -C "$work" archive --format=zip --prefix="${repo/\//-}-${ref:0:7}/" -o "$tmp" FETCH_HEAD \
        && mv -f "$tmp" "$target"; then
        echo "built   $name (${ref:0:7})"
    else
        echo "FAILED  $name ($repo@${ref:0:7})"
        exit 1
    fi
    exit 0
fi

for cmd in git php composer; do
    command -v "$cmd" >/dev/null || { echo "Required command not found: $cmd" >&2; exit 1; }
done

project=${1:-.}
lock="$project/composer.lock"
if [[ ! -f $lock ]]; then
    echo "No composer.lock in $project." >&2
    echo "Resolve one without downloading any packages: composer update --no-install" >&2
    exit 1
fi

CACHE_DIR=$(composer config --no-interaction --working-dir="$project" cache-files-dir 2>/dev/null)
if [[ -z $CACHE_DIR ]]; then
    echo "Could not determine Composer's cache-files-dir." >&2
    exit 1
fi
export CACHE_DIR

# One line per locked package:
#   GH <name> <owner/repo> <sha> <sha1 of dist url>
#   SKIP <name> <reason>
read -r -d '' PLAN_PHP <<'PHP' || true
$lock = json_decode(file_get_contents($argv[1]), true);
if (!is_array($lock)) {
    fwrite(STDERR, "Could not parse " . $argv[1] . "\n");
    exit(1);
}
foreach (array_merge($lock["packages"] ?? [], $lock["packages-dev"] ?? []) as $p) {
    $dist = $p["dist"] ?? [];
    $url = $dist["url"] ?? "";
    if (($dist["type"] ?? "") !== "zip"
        || !preg_match("#^https://api\.github\.com/repos/([^/]+)/([^/]+)/zipball/([0-9a-f]{40})$#", $url, $m)) {
        echo "SKIP ", $p["name"], " not-a-github-zipball\n";
        continue;
    }
    // Composer keys the cache on the dist URL rewritten to the dist
    // reference; only an unchanged URL is safe to key on directly.
    if (($dist["reference"] ?? $m[3]) !== $m[3]) {
        echo "SKIP ", $p["name"], " dist-reference-differs-from-url\n";
        continue;
    }
    echo "GH ", $p["name"], " ", $m[1], "/", $m[2], " ", $m[3], " ", sha1($url), "\n";
}
PHP

plan=$(mktemp)
log=$(mktemp)
trap 'rm -f "$plan" "$log"' EXIT

php -r "$PLAN_PHP" "$lock" >"$plan"

total=$(grep -c '^GH ' "$plan" || true)
skipped=$(grep -c '^SKIP ' "$plan" || true)
echo "Warming $CACHE_DIR with $total GitHub zips from $lock (jobs: ${JOBS:-8})"

if [[ $total -gt 0 ]]; then
    set +e
    awk '$1 == "GH" { print $2, $3, $4, $5 }' "$plan" \
        | xargs -P "${JOBS:-8}" -n 4 bash "${BASH_SOURCE[0]}" __build \
        | tee "$log"
    set -e
fi

built=$(grep -c '^built ' "$log" || true)
cached=$(grep -c '^cached ' "$log" || true)
failed=$(grep -c '^FAILED ' "$log" || true)

echo
echo "built: $built  already cached: $cached  failed: $failed  skipped: $skipped"
if [[ $skipped -gt 0 ]]; then
    echo "Skipped (not rebuilt; Composer will download these itself):"
    awk '$1 == "SKIP" { print "  " $2 " (" $3 ")" }' "$plan"
fi
if [[ $failed -gt 0 ]]; then
    echo "Failed (Composer would try to download these, then fall back to a git clone):"
    sed -n 's/^FAILED  /  /p' "$log"
    exit 1
fi

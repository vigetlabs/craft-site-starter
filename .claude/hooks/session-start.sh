#!/bin/bash
#
# Starts DDEV and installs Craft in a Claude Code cloud session, so the ddev
# commands in README.md work as they do locally. Local sessions skip it.
#
# The cloud environment's setup script (.claude/cloud/environment-setup.sh)
# installs DDEV. docs/claude-cloud.md explains the setup.
#
# What this prints goes into Claude's context at the start of the session.

set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
    exit 0
fi

cd "$CLAUDE_PROJECT_DIR"

log() { echo "session-start: $*" >&2; }

# An environment without the setup script installs DDEV here, in every session.
if ! command -v ddev >/dev/null; then
    log "DDEV isn't installed, running .claude/cloud/environment-setup.sh"
    .claude/cloud/environment-setup.sh >&2
fi

if ! docker info >/dev/null 2>&1; then
    log "starting Docker"
    nohup setsid dockerd >/var/log/dockerd.log 2>&1 &
    for _ in $(seq 1 30); do docker info >/dev/null 2>&1 && break; sleep 1; done
fi

# DDEV runs as the `ubuntu` user (it refuses to run as root), and so do its
# containers. Let them write to this checkout, including files created later.
# `ddev start` also changes the permissions of .ddev/ when it writes Craft's
# settings, which only the directory's owner can do.
setfacl -R -m u:ubuntu:rwX -m d:u:ubuntu:rwX .
chown ubuntu: .ddev

# `composer create-project` gives a project its .env (post-root-package-install
# in composer.json), and a clone doesn't have one. Installing Craft fills in
# CRAFT_SECURITY_KEY and CRAFT_APP_ID.
if [ ! -f .env ]; then
    cp .env.example.dev .env
fi

project=$(sed -n 's/^name:[[:space:]]*//p' .ddev/config.yaml | tr -d "\"'")
site_url="https://$project.ddev.site"

if [ -z "$(docker ps -q --filter "name=^ddev-$project-web$" --filter status=running)" ]; then
    # The post-start `composer install` downloads every locked package as a
    # GitHub zip. Build those zips from git into DDEV's Composer cache first, so
    # the install doesn't depend on GitHub's archive downloads. Composer
    # downloads anything this misses. It runs as root, since git needs the
    # session's proxy CA, so hand the cache to ubuntu before `ddev start`:
    # Composer in the web container fails on a cache directory it can't write.
    # The setup script has usually done this already, and then it's quick.
    log "warming DDEV's Composer cache"
    docker volume create ddev-global-cache >/dev/null
    composer_cache="$(docker volume inspect ddev-global-cache --format '{{.Mountpoint}}')/composer"
    COMPOSER_CACHE_DIR=$composer_cache .claude/cloud/warm-composer-cache.sh . >/tmp/warm-composer-cache.log 2>&1 ||
        log "warming Composer's cache failed (log: /tmp/warm-composer-cache.log)"
    if [ -d "$composer_cache" ]; then
        chown -R ubuntu: "$composer_cache"
    fi

    log "starting DDEV"
    started=false
    # DDEV picks host ports for web's HTTP(S) and db before it starts the
    # containers, and leaves the rest to Docker. A freshly started Docker hands
    # those out from 32768, so one can take a port DDEV picked. A second
    # `ddev start` sees that port is taken and picks another.
    if ddev start >/tmp/ddev-start.log 2>&1; then
        started=true
    elif grep -q 'port is already allocated' /tmp/ddev-start.log; then
        log "a container took a port DDEV picked, running ddev start again"
        ddev start >>/tmp/ddev-start.log 2>&1 && started=true
    fi
    if [ "$started" = false ]; then
        cat /tmp/ddev-start.log >&2
        cat <<CONTEXT
\`ddev start\` failed in this cloud session, so ddev commands won't work until
it's fixed. The end of its output (full log: /tmp/ddev-start.log):

$(tail -n 15 /tmp/ddev-start.log)

See "Troubleshooting" in docs/claude-cloud.md. A 403 from an apt repository
means the cloud environment's network access is missing a host.
CONTEXT
        exit 0
    fi
fi

# The vite daemon (web_extra_daemons in .ddev/config.yaml) runs npm install and
# npm run build before it serves. Wait for it, so the pre-commit hook finds
# node_modules. It usually takes under a minute. Stop after 5, so the hook
# finishes within its timeout and can say what went wrong.
log "waiting for the vite daemon"
vite_up=false
for _ in $(seq 1 60); do
    # The port is the vite entry's container_port in web_extra_exposed_ports.
    if ddev exec curl -s -o /dev/null http://localhost:3000/ 2>/dev/null; then
        vite_up=true
        break
    fi
    sleep 5
done

# *.ddev.site resolves to this VM. Keep requests to it away from the egress proxy.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
    echo "export NO_PROXY=\"${NO_PROXY:-}${NO_PROXY:+,}.ddev.site\" no_proxy=\"${no_proxy:-}${no_proxy:+,}.ddev.site\"" >>"$CLAUDE_ENV_FILE"
fi

cat <<'CONTEXT'
DDEV is running in this cloud session (see docs/claude-cloud.md), so use ddev
commands as you would locally, e.g. `ddev composer phpstan`, `ddev composer
ecs-check`, `ddev craft …` and `ddev npm run build`. The husky pre-commit hook
runs lint-staged in DDEV.
CONTEXT

if [ "$vite_up" = false ]; then
    cat <<'CONTEXT'

The vite daemon didn't answer within 5 minutes, so node_modules/ or the built
assets may be missing, and the pre-commit hook and `ddev npm` may fail. Its
output is in `ddev logs -s web`.
CONTEXT
fi

if ddev craft install/check >/dev/null 2>&1; then
    cat <<CONTEXT

Craft is installed in DDEV's database, with no content: $site_url
Its admin account is admin@example.com. If you don't have its password, set
one with \`ddev craft users/set-password admin@example.com\`.
CONTEXT
else
    log "installing Craft"
    if login=$(.claude/cloud/install-craft.sh 2>&1); then
        cat <<CONTEXT

$login
CONTEXT
    else
        cat <<CONTEXT

Installing Craft failed, so \`ddev craft\` commands fail and $site_url
returns 503. .claude/cloud/install-craft.sh said:

$login
CONTEXT
    fi
fi

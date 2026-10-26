#!/bin/bash
#
# Setup script for a Claude Code cloud environment that runs DDEV projects.
# Paste it into the environment's "Setup script" field (the cloud environment
# menu in a session's title bar, then Edit), and paste it again after changing
# it. Projects that use it keep identical copies of it, so one environment can
# serve them all: change them together. docs/claude-cloud.md explains each
# step.
#
# It provisions the VM with what the base image lacks:
#   - DDEV and the Docker images in PROJECT_IMAGES, so sessions can run DDEV
#     projects and their test suites the way local development does
#   - PHP's bcmath extension, which craftcms/cms requires, for anything that
#     runs Composer on the VM instead of through DDEV
#
# It also caches the slow part of starting the DDEV projects the session has
# checked out: it builds each project's DDEV images, and fills DDEV's Composer
# cache from its composer.lock.
#
# The script runs as root before Claude Code starts, the first time a session
# starts in the environment, after the session's repositories are cloned. When
# it finishes within about five minutes, Anthropic snapshots the filesystem,
# and later sessions start from the snapshot without running it. It runs again
# when it or the environment's network settings change, and when the snapshot
# expires after about seven days. The snapshot keeps files, not running
# processes, so a session starts Docker and DDEV itself.
#
# Setup every session needs, like installing Composer dependencies, belongs in
# a project's .claude/hooks/session-start.sh, which runs in every session. The
# hook also runs this script when the environment doesn't have it.

set -euo pipefail

DDEV_VERSION=v1.25.4

# Images DDEV projects in this environment need beyond the ones
# `ddev utility download-images` pulls without a project: each project's
# database (`database` in .ddev/config.yaml) and its add-on services. Add a
# project's images here. The script gets the images of the projects the session
# has checked out by itself, but the snapshot also serves sessions on other
# projects. A missing image isn't an error: `ddev start` pulls it.
PROJECT_IMAGES=(
    "ddev/ddev-dbserver-mysql-8.0:$DDEV_VERSION" # projects on MySQL 8.0
    "ddev/ddev-dbserver-mysql-8.4:$DDEV_VERSION" # projects on MySQL 8.4
    redis:6 # projects with a Redis service
)

# Stop building projects' images this many seconds into the script, so it
# finishes within the five minutes it has to be cached in. A build cut short
# still caches the steps it finished.
BUILD_DEADLINE=240

# DDEV refuses to run as root, and cloud sessions run everything as root, so
# DDEV runs as the VM image's regular user.
DDEV_USER=ubuntu
DDEV_HOME=$(getent passwd "$DDEV_USER" | cut -d: -f6)

# DDEV's apt repository, as in its install docs (Linux tab):
# https://docs.ddev.com/en/stable/users/install/ddev-installation/
# The package includes ddev-hostname and mkcert.
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://packages.ddev.com/public/gpg.key -o /etc/apt/keyrings/ddev.asc
chmod a+r /etc/apt/keyrings/ddev.asc
printf 'Types: deb\nURIs: https://packages.ddev.com/public/deb/ubuntu\nSuites: stable\nComponents: main\nSigned-By: /etc/apt/keyrings/ddev.asc\n' \
    >/etc/apt/sources.list.d/ddev.sources

# acl provides setfacl, which sessions use to share the root-owned checkout
# with $DDEV_USER before `ddev start`. apt can still be running from VM
# startup, so wait for its locks instead of failing.
export DEBIAN_FRONTEND=noninteractive
apt_get() { apt-get -o DPkg::Lock::Timeout=120 "$@"; }
apt_get update -q
apt_get install -y -q acl "ddev=${DDEV_VERSION#v}"
usermod -aG docker "$DDEV_USER"

# bcmath matches the base image's PHP, so a change to that image could rename
# or drop the package. Nothing in the DDEV setup needs it, so don't fail on it.
php_version=$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;' 2>/dev/null || true)
if [ -n "$php_version" ]; then
    apt_get install -y -q "php$php_version-bcmath" ||
        echo "Warning: couldn't install php$php_version-bcmath" >&2
fi

# `ddev`, run as root, runs DDEV as $DDEV_USER in the same directory.
# /usr/local/bin comes before /usr/bin on PATH, so this wins over the package's.
cat >/usr/local/bin/ddev <<EOF
#!/bin/sh
if [ "\$(id -u)" = 0 ]; then
    exec runuser -u $DDEV_USER -- /usr/bin/ddev "\$@"
fi
exec /usr/bin/ddev "\$@"
EOF
chmod +x /usr/local/bin/ddev

# DDEV adds hostnames it can't resolve to /etc/hosts with `sudo ddev-hostname`.
# Cloud sessions' DNS only answers for allowed domains, so *.ddev.site needs it.
echo "$DDEV_USER ALL=(root) NOPASSWD: /usr/bin/ddev-hostname" >/etc/sudoers.d/ddev-hostname
chmod 0440 /etc/sudoers.d/ddev-hostname

# Outbound HTTPS from DDEV's containers is re-signed by Anthropic's egress
# gateway, so the web container has to trust the CAs the VM trusts
# (/usr/local/share/ca-certificates). A global pre.Dockerfile is DDEV's
# documented fix for TLS-intercepting proxies:
# https://docs.ddev.com/en/stable/users/usage/networking/#corporate-packet-inspection-vpns-including-zscaler-and-global-protect
web_build="$DDEV_HOME/.ddev/web-build"
mkdir -p "$web_build"
rm -f "$web_build"/claude-ca-*.crt
for ca in /usr/local/share/ca-certificates/*.crt; do
    case "$(basename "$ca")" in mkcert*) continue ;; esac
    cp "$ca" "$web_build/claude-ca-$(basename "$ca")"
done
cat >"$web_build/pre.Dockerfile.claude-ca" <<'EOF'
COPY claude-ca-*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates
EOF

# Anonymous GitHub API requests from cloud sessions share the egress IPs, which
# use up GitHub's limit of 60 an hour. Composer then falls back to cloning a
# `github` or `vcs` repository in composer.json over SSH, which cloud sessions
# can't reach, so `ddev composer update` and `require` fail. Without the API,
# Composer clones it over HTTPS, and composer.lock comes out the same. DDEV
# copies the global homeadditions into the web container's home directory.
homeadditions="$DDEV_HOME/.ddev/homeadditions"
mkdir -p "$homeadditions/.composer"
echo '{ "config": { "use-github-api": false } }' >"$homeadditions/.composer/config.json"
chown -R "$DDEV_USER": "$DDEV_HOME/.ddev"

# Git in the web container sees the checkout as owned by root.
runuser -u "$DDEV_USER" -- git config --global --replace-all safe.directory '*'

# mkcert's CA goes where DDEV looks for it, and into the VM's trust stores
# (curl, Playwright's Chromium). Installing it needs root.
caroot="$DDEV_HOME/.local/share/mkcert"
mkdir -p "$caroot"
CAROOT="$caroot" mkcert -install
chown -R "$DDEV_USER": "$DDEV_HOME/.local"

# Anonymous Docker Hub pulls from cloud sessions hit its rate limit (429 Too
# Many Requests), so go through Google's Docker Hub mirror, which the Trusted
# network level allows (*.gcr.io).
mkdir -p /etc/docker
echo '{ "registry-mirrors": ["https://mirror.gcr.io"] }' >/etc/docker/daemon.json
started_dockerd=
if ! docker info >/dev/null 2>&1; then
    nohup setsid dockerd >/var/log/dockerd.log 2>&1 &
    started_dockerd=1
    for _ in $(seq 1 30); do docker info >/dev/null 2>&1 && break; sleep 1; done
fi

cd /
# Node doesn't read the system CA store. By the time Node runs, the store holds
# the egress CAs (pre.Dockerfile above) and mkcert's CA (added at container start).
ddev config global --instrumentation-opt-in=false \
    --web-environment="NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt" >/dev/null

# The DDEV projects the session has checked out. Sessions clone their
# repositories into /home/user before this script runs. DDEV, running as
# $DDEV_USER, needs to write to each checkout, as the SessionStart hooks allow.
projects=()
for config in /home/user/*/.ddev/config.yaml; do
    if [ -f "$config" ]; then
        project=${config%/.ddev/config.yaml}
        projects+=("$project")
        setfacl -R -m "u:$DDEV_USER:rwX" -m "d:u:$DDEV_USER:rwX" "$project"
    fi
done

# Everything from here on only saves sessions time, so a failure warns instead
# of failing the script, which would stop every session from starting.
# `ddev start` pulls and builds whatever is missing, and Composer downloads what
# its cache lacks.

# Pull images now so the snapshot keeps them.
pending=()
{ ddev utility download-images >/dev/null 2>&1 || echo "Warning: ddev utility download-images failed" >&2; } &
pending+=($!)
for image in "${PROJECT_IMAGES[@]}"; do
    { docker pull -q "$image" >/dev/null || echo "Warning: docker pull $image failed" >&2; } &
    pending+=($!)
done

# Meanwhile, fill DDEV's Composer cache (in the ddev-global-cache volume) from
# each project's composer.lock, with the project's warm-composer-cache.sh. It
# builds the packages from git (the script explains why), so it runs as root,
# for git's proxy CA. Composer in the web container needs to own the cache.
composer_cache=
if docker volume create ddev-global-cache >/dev/null; then
    composer_cache="$(docker volume inspect ddev-global-cache --format '{{.Mountpoint}}')/composer"
    for project in "${projects[@]}"; do
        warm="$project/.claude/cloud/warm-composer-cache.sh"
        if [ -x "$warm" ] && [ -f "$project/composer.lock" ]; then
            { COMPOSER_CACHE_DIR=$composer_cache "$warm" "$project" >/dev/null 2>&1 ||
                echo "Warning: warming Composer's cache for $project failed" >&2; } &
            pending+=($!)
        fi
    done
fi
# Only these jobs: a bare `wait` would also wait for dockerd.
wait "${pending[@]}"
if [ -d "$composer_cache" ]; then
    chown -R "$DDEV_USER": "$composer_cache"
fi

# Build each project's DDEV images (web and db), and pull its add-on services'
# images, so the snapshot keeps them and Docker's build cache. `ddev start` then
# builds the images in seconds, instead of a minute or more. DDEV writes each
# project's Docker Compose file first, one project at a time, since it also
# updates its global project list. The builds run in parallel.
until_deadline() {
    local budget=$((BUILD_DEADLINE - SECONDS))
    [ "$budget" -gt 0 ] && timeout "$budget" "$@"
}
builds=()
for project in "${projects[@]}"; do
    if ! (cd "$project" && ddev utility compose-config >/dev/null); then
        echo "Warning: ddev utility compose-config failed in $project" >&2
        continue
    fi
    budget=$((BUILD_DEADLINE - SECONDS))
    if [ "$budget" -lt 30 ]; then
        echo "Warning: no time left to build $project's DDEV images" >&2
        continue
    fi
    {
        compose=(docker compose -f "$project/.ddev/.ddev-docker-compose-full.yaml")
        until_deadline "${compose[@]}" pull -q --ignore-buildable --policy missing >/dev/null 2>&1 ||
            echo "Warning: pulling $project's DDEV images failed or ran out of time" >&2
        until_deadline "${compose[@]}" build >/dev/null 2>&1 ||
            echo "Warning: building $project's DDEV images failed or ran out of time" >&2
    } &
    builds+=($!)
done
if [ ${#builds[@]} -gt 0 ]; then
    wait "${builds[@]}"
fi

# Stop dockerd so the snapshot holds a consistent image store and no stale pid
# file. Sessions start it again.
if [ -n "$started_dockerd" ]; then
    pkill -x dockerd || true
    for _ in $(seq 1 30); do pgrep -x dockerd >/dev/null || break; sleep 1; done
fi

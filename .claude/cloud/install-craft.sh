#!/bin/bash
#
# Installs Craft into DDEV's empty database, with no content, so `ddev craft`
# commands, the control panel and the front end work in a Claude Code cloud
# session. .claude/hooks/session-start.sh runs it. docs/claude-cloud.md
# explains when to run it yourself.
#
# It does nothing when Craft is already installed. The install rewrites project
# config, so the script restores config/project/ from git afterwards, even when
# the install fails, then applies it with `craft up`. Craft's output goes to
# /tmp/install-craft.log, and the script prints the login.

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

if ddev craft install/check >/dev/null 2>&1; then
    echo "Craft is already installed."
    exit 0
fi

if [ -n "$(git status --porcelain -- config/project)" ]; then
    echo "Commit or stash your changes to config/project/ first: this script restores it from git." >&2
    exit 1
fi
restore() { git checkout -- config/project && git clean -fdq -- config/project; }
trap restore EXIT

project=$(sed -n 's/^name:[[:space:]]*//p' .ddev/config.yaml | tr -d "\"'")
log=/tmp/install-craft.log
password=$(openssl rand -hex 12)

# config/general.php sets useEmailAsUsername, so the email address is the login.
# Project config replaces the site name and URL.
if ! ddev craft install/craft --interactive=0 \
    --email=admin@example.com --password="$password" \
    --site-name="$project" --site-url='$PRIMARY_SITE_URL' --language=en-US >"$log" 2>&1; then
    tail -n 15 "$log"
    exit 1
fi
restore
trap - EXIT
if ! ddev craft up --interactive=0 >>"$log" 2>&1; then
    tail -n 15 "$log"
    exit 1
fi

cat <<EOF
Craft is installed in DDEV's database, with no content: https://$project.ddev.site
Control panel: https://$project.ddev.site/admin
Email: admin@example.com
Password: $password
EOF

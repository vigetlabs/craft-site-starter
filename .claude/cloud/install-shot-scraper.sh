#!/bin/bash
#
# Installs shot-scraper (https://shot-scraper.datasette.io), which takes
# screenshots and records videos of pages from the command line, so Claude can
# check UI changes in a cloud session. The SessionStart hook runs it in every
# cloud session. It does nothing when the right version is already installed.
#
# shot-scraper drives Chromium with Python's Playwright, and each Playwright
# version looks for the browser build it was released with. Cloud sessions
# can't download browsers (Playwright's CDN isn't an allowed host), but the VM
# image ships the builds for the Node Playwright it preinstalls, in
# $PLAYWRIGHT_BROWSERS_PATH. Python's and Node's Playwright are released
# together, so pinning Python's to the same minor version finds those builds.

set -euo pipefail

if ! command -v uv >/dev/null; then
    echo "uv isn't installed, so shot-scraper can't be" >&2
    exit 1
fi

# Resolve from / so a project's own node_modules/playwright, which can be a
# different version, doesn't answer instead of the VM image's.
node_version=$(cd / && node -p "require('playwright/package.json').version")
minor=${node_version%.*}

tool_python="$(uv tool dir 2>/dev/null)/shot-scraper/bin/python"
if [ -x "$tool_python" ]; then
    installed=$("$tool_python" -c 'import importlib.metadata as m; print(m.version("playwright"))' 2>/dev/null || true)
    if [ "${installed%.*}" = "$minor" ]; then
        exit 0
    fi
fi

# `shot-scraper video` arrived in 1.10. A download from PyPI can stall, so
# don't let one hold up the session.
timeout 180 uv tool install --force "shot-scraper>=1.10" --with "playwright==$minor.*"

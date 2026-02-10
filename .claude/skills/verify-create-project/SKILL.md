---
name: verify-create-project
description: Runs the full "Getting Started" flow from the README to verify that `composer create-project` works correctly with the current branch.
disable-model-invocation: true
---

## Inputs

Ask the user for **both** of the following before starting:

1. **Branch name** — which branch/version to test with `composer create-project`. The AI agent will convert branch name to Composer's `dev-<branch>` format, e.g. branch `jp/create-project-flags` becomes `dev-jp/create-project-flags`, branch `5.x` becomes `5.x-dev`). Note: for branches that look like version numbers (e.g. `5.x`), Composer uses `5.x-dev`; for all other branches, Composer uses `dev-<branch-name>`.
2. **Directory path** — where the test project should be created. The directory must not already exist — the script will create it. Suggest `../craft-starter-test-<YYYY-MM-DD>` as a default.

## Test Credentials

- **Email:** admin@example.com
- **Username:** admin
- **Password:** password123

Remember these — you'll need them to log in and verify the install.

## Failure policy

**Stop immediately on any unexpected result.** Every step below has explicit success criteria. If any step produces a non-zero exit code, unexpected output, missing files, incorrect values, or any other deviation from what is described — **stop execution, report exactly what went wrong (including full command output), and ask the user how to proceed.** Do not attempt to fix, retry, or work around failures automatically.

This includes but is not limited to:
- Commands exiting with non-zero status
- Docker daemon not running
- DDEV not installed or not responding
- Vite or front-end builds not working.
- Files missing or containing unexpected values after a step
- Network errors, timeouts, or TLS failures
- Browser pages returning errors (500, 502, connection refused, etc.)

## Prerequisites

Before starting, verify these prerequisites. **Stop and report if any fail:**

1. **Docker is running:** Run `docker info` and confirm it exits successfully. If it fails, stop — the Docker daemon is not running.
2. **DDEV is installed:** Run `ddev version` and confirm it exits successfully. If it fails, stop — DDEV is not installed.

## Steps

### 1. Create the test directory

```bash
mkdir -p <user-provided-directory>
```

Verify the directory was created and is empty (`ls -A` should produce no output). If it already contains files, **stop and ask the user what to do.**

### 2. Run composer create-project via Docker

From inside the test directory, run:

```bash
docker run --rm -it -v "$PWD":/app -v ${COMPOSER_HOME:-$HOME/.composer}:/tmp -e PROJECT_NAME="Test Project" -e PROJECT_SLUG="test-project" composer create-project viget/craft-site-starter=<composer-version> ./ --ignore-platform-reqs
```

Replace `<composer-version>` with the Composer version string derived from the user's chosen branch (see Inputs above).

**Important:** The `-e PROJECT_NAME` and `-e PROJECT_SLUG` environment variables enable non-interactive mode in the post-create-project script, so no user input is required.

Wait for this to complete. It may take a few minutes. **Verify it exits with code 0.** If it exits with any other code, **stop and report the full output.**

### 3. Verify post-create-project changes

After the create-project command finishes, verify **all** of the following. If **any** check fails, **stop and report all discrepancies** before proceeding:

#### 3a. DDEV config

- `.ddev/config.yaml` should have `name: test-project` (not `viget-craft-starter`)

#### 3b. DDEV environment

- `.ddev/.env.web` should have `PRIMARY_SITE_URL="https://test-project.ddev.site"` (not `viget-craft-starter.ddev.site`)

#### 3c. package.json and package-lock.json

- `package.json` should have `"name": "test-project"` (not `viget-craft-starter`)
- `package-lock.json` should have `"name": "test-project"` (not `viget-craft-starter`)

#### 3d. Project config — name replacements

The string `Viget Craft Starter` should have been replaced with `Test Project` in **every** file under `config/project/`. Verify by grepping the entire `config/project/` directory for `Viget Craft Starter` — **there should be zero matches.** Specifically check:

- `config/project/project.yaml` `email.fromName` should be `'Test Project'` (not `'Viget Craft Starter'`)
- `config/project/project.yaml` `system.name` should be `'Test Project'` (not `'Viget Craft Starter'`)
- `config/project/project.yaml` `meta.__names__` entries that previously said `Viget Craft Starter` should now say `Test Project`
- The site group file in `config/project/siteGroups/` should have `name: 'Test Project'`
- The site file in `config/project/sites/` should have `name: 'Test Project'`

#### 3e. Project config — license keys removed

- `config/project/project.yaml` should have **no** `licenseKey: REPLACE` entries. The `licenseKey` lines with value `REPLACE` should have been removed entirely (not replaced with a different value — the whole line should be gone).

#### 3f. composer.json cleanup

- The `composer.json` should no longer have a `post-create-project-cmd` script
- The `composer.json` should no longer have a `name` field
- The `composer.json` should no longer have a `license` field
- The `composer.json` should no longer have a `type` field

#### 3g. composer-scripts directory deleted

- The `composer-scripts/` directory should **not exist** at all

#### 3h. .env file created

- A `.env` file should exist in the project root (copied from `.env.example.dev` during the create-project process)

#### 3i. .gitignore — starter-only block removed

- `.gitignore` should **not** contain `# BEGIN-STARTER-ONLY` or `# END-STARTER-ONLY`
- `.gitignore` should **not** contain `config/license.key` (that line was inside the starter-only block)

#### 3j. phpstan.neon — scanFiles removed

- `phpstan.neon` should **not** contain a `scanFiles` section or any reference to `composer-scripts/ScriptHelpers.php`

### 4. Start DDEV

```bash
ddev start
```

Wait for DDEV to fully start. This includes the post-start hooks (composer install, npm install, vite build). **Verify the command exits with code 0.** If it fails, **stop and report the full output.**

### 5. Install Craft

```bash
ddev craft install --interactive=0 --email=admin@example.com --username=admin --password=password123
```

**Verify the command exits with code 0.** If it fails, **stop and report the full output.**

### 6. Verify the site in the browser

Use the browser tools to verify the installation. **If any check fails, stop and report the failure before continuing to the next check:**

1. Navigate to `https://test-project.ddev.site` and verify the homepage loads (should not be a 500 error, connection refused, or blank page)
2. Navigate to `https://test-project.ddev.site/admin` and log in with:
   - **Username:** admin
   - **Password:** password123
3. Verify the Craft admin dashboard loads successfully
4. Check that the site name shows "Test Project" (not "Viget Craft Starter")

### 7. Report results

Summarize the verification results:

- Whether prerequisites passed (Docker, DDEV)
- Whether create-project completed successfully
- Whether file replacements were correct
- Whether DDEV started without errors
- Whether Craft installed successfully
- Whether the frontend loaded
- Whether the admin panel was accessible
- Any warnings or issues encountered

**Do NOT clean up the test directory** — leave it for manual inspection.

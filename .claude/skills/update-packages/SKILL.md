---
name: update-packages
description: Updates Composer, Craft CMS plugins, and Node packages. Commits each step separately, audits for vulnerabilities, and generates a PR description.
allowed-tools: Bash, Write, Read, Edit
---

# Update Packages

Updates Composer, Craft Plugins and node packages. Each step is committed separately.

## Git Commit Convention

Each step that changes files must be committed separately using this template:

```
[UPDATES] <cli-command-from-step>
```

For example: `[UPDATES] ddev composer update`

## Steps

Follow these steps in order:

### 1. Update Craft dependencies

```bash
ddev craft update all --interactive=0
```

This updates Composer packages related to Craft CMS. Commit any changes.

### 2. Update Composer dependencies

```bash
ddev composer update
```

This updates all Composer packages to their latest compatible versions. Commit any changes.

### 3. Update Node dependencies

```bash
ddev npm update
```

Commit any changes.

### 4. Check for vulnerabilities

Run both audits:

```bash
ddev composer audit
```

```bash
ddev npm audit
```

If vulnerabilities are found in either, write a vulnerability report to a markdown file in the root of the repository. If no issues are found, do nothing.

### 5. Create a Pull Request description

Write a markdown file to the root of the repo describing the updates and listing changed dependencies.

- Put changes into markdown tables, with a separate table for each dependency type (Craft, Composer, NPM)
- The user will handle creating the actual PR
- DO NOT commit this document to the repo

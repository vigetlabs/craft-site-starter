# Update Packages

## Overview

Updates Composer, Craft Plugins and node packages.

## Git Commits

- Each step should be committed separately.
- Commits shoudl follow the following template

```
[UPDATES] <cli-command-from-step>
```

## Steps

1. Update Craft dependencies

```bash
ddev craft update all --interactive=0
```

This should update our Composer packages related to Craft CMS.

2. Update composer dependencies

```bash
ddev composer update
```

This updates all Composer packages to their latest compatible versions.

3. Update Node Dependences

```bash
ddev npm update
```

4. Check for vulnerabilities.

```bash
ddev composer audit
```

This checks Composer packages for known security vulnerabilities.

```bash
ddev npm audit
```

This checks npm packages for known security vulnerabilities.

5. If vulnerabilities are found, write a report to a markdown file in the root of this repository.

- If no issues are found, do nothing.

6. Create a Pull request desription describing the updates you made and listing changed dependencies

- Write this markdown file to the root of the repo. The user will handle creating the actual PR.
- Put the changes into markdown tables. With a new table for each type of dependency (Craft, vs. composer update vs NPM)
- DO NOT commit this document to the repo

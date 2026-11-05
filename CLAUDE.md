# CLAUDE.md

This repository is Viget's Craft Site Starter, the template that new Craft CMS projects are created from with `composer create-project`. It's also a working Craft site: `ddev start` and `ddev craft install` run it like any project. This file covers working on the starter itself. `CLAUDE.project.md`, imported at the end, covers working in the site, and becomes each new project's `CLAUDE.md`.

## This is a public repository

This starter is open source and public on GitHub. Everything written here is public: code, comments, templates, content, docs, commit messages, branch names, PR descriptions, and issue comments.

**NEVER mention client or internal details.** No client or client-project names, no internal URLs, hostnames, or Slack channels, no links to private repositories or tickets, and no credentials. Use generic placeholders (`Acme`, `example.com`), and describe a real-world need in general terms ("a multi-site project with an RTL site") rather than naming who has it.

Projects created from this starter are often private client projects, but this repository is not.

## How a project is created

`composer create-project` copies the starter once. Projects don't receive later changes to it.

After copying, it runs `post-create-project-cmd` from `composer.json`. That runs `composer-scripts/post-create-project.php`, removes the starter's `name`, `license`, `type` and the script itself from `composer.json`, and deletes `composer-scripts/`. The PHP script:

- Asks for the project's name and slug, or reads them from `PROJECT_NAME` and `PROJECT_SLUG`.
- Replaces the slug placeholder `viget-craft-starter` in `.ddev/config.yaml`, `.ddev/.env.web` (`PRIMARY_SITE_URL`), `package.json` and `package-lock.json`.
- Replaces the name placeholder `Viget Craft Starter` in `config/project/`.
- Removes the `licenseKey: REPLACE` lines from `config/project/project.yaml`.
- Removes the `# BEGIN-STARTER-ONLY` … `# END-STARTER-ONLY` block from `.gitignore`.
- Deletes this file, renames `CLAUDE.project.md` to `CLAUDE.md`, and puts the project's name in its heading.
- Removes the `composer-scripts/` entry from `phpstan.neon`.

So:

- Don't rename the placeholders without updating the script.
- Anything that only belongs in the starter needs the script to remove or rewrite it.
- Put guidance for working on the starter here, and guidance for any site built from it in `CLAUDE.project.md`. Keep `CLAUDE.project.md` free of anything only true of the starter. Each project's team adds its own details to the copy they get.
- When the script changes, update the checks in `.claude/skills/verify-create-project/SKILL.md` to match.

## Testing a release

README.md's "Release Testing" section lists the checks. The `/verify-create-project` skill runs `composer create-project` from a branch and checks the result. Only the user can start it, so ask them to.

## Commits

Prefix commit messages with the issue number, `[#123] …`, or `[n/a] …` when there's no issue.

@CLAUDE.project.md

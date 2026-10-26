# Claude Code Cloud Sessions

Claude Code can work on this project in a cloud VM instead of on your laptop: from [claude.ai/code](https://claude.ai/code), the Claude app, or `claude --cloud`. This page sets up a cloud environment so those sessions run the project in **DDEV**, the same way local development does. `ddev composer`, `ddev craft`, `ddev npm` and the husky pre-commit hook all work as they do locally, and Craft is installed, so the site and control panel load.

Projects created from this starter keep these files, so their cloud sessions work the same way.

Four files do the work:

| File                                                                              | Runs                                                                                                                                  | Does                                                                                                                                                          |
| --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`.claude/cloud/environment-setup.sh`](../.claude/cloud/environment-setup.sh)     | Once per environment, as its setup script. The VM snapshot keeps the result for ~7 days                                               | Installs DDEV and mkcert, makes DDEV's containers trust the cloud's egress proxy, pulls Docker images, and builds the DDEV images of the projects checked out |
| [`.claude/hooks/session-start.sh`](../.claude/hooks/session-start.sh)             | At the start of every cloud session ([SessionStart hook](https://code.claude.com/docs/en/hooks#sessionstart)). Local sessions skip it | Starts Docker and `ddev start`, waits for the vite daemon, installs Craft, tells Claude how to work in the session                                            |
| [`.claude/cloud/install-craft.sh`](../.claude/cloud/install-craft.sh)             | From the hook, when Craft isn't installed                                                                                             | Installs Craft, with no content, into DDEV's empty database ([Craft](#craft))                                                                                 |
| [`.claude/cloud/warm-composer-cache.sh`](../.claude/cloud/warm-composer-cache.sh) | From the setup script and the hook, before `ddev start`                                                                               | Builds every package in `composer.lock` from git into DDEV's Composer cache ([below](#how-the-cloud-vm-differs-from-a-laptop))                                |

Nothing else in the project changes for the cloud.

## One-time setup

Whoever owns the cloud environment does this once. Open the environment's settings from the cloud environment menu in a session's title bar, then **Edit**. ([Anthropic's docs](https://code.claude.com/docs/en/cloud-environments))

### 1. Network access

Set **Network access** to **Custom**, tick **Also include default list of common package managers**, and add these hosts under **Allowed domains**:

```text
packages.ddev.com
getcomposer.org
composer.craftcms.com
```

| Host                    | Why                                                           | Without it                                                  |
| ----------------------- | ------------------------------------------------------------- | ----------------------------------------------------------- |
| `packages.ddev.com`     | DDEV's apt repository. The setup script installs DDEV from it | The setup script fails                                      |
| `getcomposer.org`       | DDEV updates Composer while it builds the web image           | A warning on `ddev start`. The image's Composer still works |
| `composer.craftcms.com` | A repository in `composer.json`                               | `ddev composer require` and `ddev composer update` fail     |

The default list already covers GitHub, Docker Hub's mirror (`mirror.gcr.io`), Packagist, npm, Node.js and Ubuntu's package archive.

A project that adds Debian packages to its web image (`webimage_extra_packages` in `.ddev/config.yaml`, or a `.ddev/web-build/Dockerfile`) also needs the hosts they come from, such as `deb.debian.org`.

### 2. Setup script

Paste the contents of [`.claude/cloud/environment-setup.sh`](../.claude/cloud/environment-setup.sh) into **Setup script**.

The environment keeps its own copy of the script. When the file changes (for example, to upgrade DDEV), paste it in again.

One environment can serve several DDEV projects, so every project that uses the script keeps an identical copy. Change them together, and paste the newest. The script finds the DDEV projects the session has checked out by itself. For other projects, it pulls the Docker images listed in its `PROJECT_IMAGES`: add a project's database image and add-on services' images there. A project whose images aren't cached still works: `ddev start` pulls and builds them, which takes longer.

The script took 1.5 minutes in a VM that already had DDEV and the base images, building this project's images and a larger project's alongside. A new VM adds about 1.5 minutes to install DDEV and pull images. That's under the ~5 minutes a setup script has to finish in for the environment to be [cached](https://code.claude.com/docs/en/cloud-environments#environment-caching), and the script stops building images 4 minutes in to stay under it. Without the setup script, the SessionStart hook runs it in every session, which works but makes each session start a few minutes slower.

### 3. Check it

The hook is in the repository, so it runs in any session started on a branch that has it. Start a session and ask Claude to run:

```sh
ddev describe
ddev craft install/check
ddev composer phpstan
ddev composer ecs-check
curl -I https://viget-craft-starter.ddev.site   # your project's name from .ddev/config.yaml
```

## What a session looks like

Once the environment is cached, a new session runs the SessionStart hook before Claude starts:

1. Starts the Docker daemon. The snapshot keeps files, not running processes.
2. Gives DDEV's user write access to the checkout (see [below](#how-the-cloud-vm-differs-from-a-laptop)).
3. Creates `.env` from `.env.example.dev`, as `composer create-project` does.
4. Warms DDEV's Composer cache with `.claude/cloud/warm-composer-cache.sh`. The setup script has usually done this already, and then it takes seconds.
5. Runs `ddev start`. This builds the project's images (from the build cache the setup script left), starts the containers, and runs the post-start `composer install`. If it fails because another container took a host port DDEV picked (see [Troubleshooting](#troubleshooting)), the hook runs it once more.
6. Waits up to 5 minutes for the vite daemon to finish `npm install` and `npm run build`, so `node_modules` exists for the pre-commit hook. If it doesn't answer, the hook tells Claude.
7. Installs Craft with `.claude/cloud/install-craft.sh`, and tells Claude the control panel login ([Craft](#craft)).

Measured in a cloud session:

| Step                                                          | Time                                    |
| ------------------------------------------------------------- | --------------------------------------- |
| Setup script, with DDEV and the base images already on the VM | 1.5 minutes                             |
| SessionStart hook, after the setup script built the images    | 42 seconds (images built in 4 seconds)  |
| `ddev start` without the setup script's images                | 80 seconds (images built in 49 seconds) |
| Warming DDEV's Composer cache (step 4), 171 packages          | 22 seconds, or none when they're cached |
| `.claude/cloud/install-craft.sh`                              | ~10 seconds                             |
| `ddev composer phpstan`                                       | 4 seconds                               |

## How the cloud VM differs from a laptop

Each difference below is something the setup script or hook handles. They're listed here so the scripts make sense, and for troubleshooting.

**Everything runs as root, and DDEV refuses to.** DDEV exits with "DDEV is not designed to be run with root privileges", and has no override. So DDEV runs as the VM image's regular `ubuntu` user. `/usr/local/bin/ddev` is a wrapper that runs the real binary (`/usr/bin/ddev`, from DDEV's apt package) as `ubuntu`. It comes first on `PATH`, so `ddev …` works from Claude's root shell and from the pre-commit hook. The checkout stays owned by root, and the hook gives `ubuntu` read and write access with ACLs, including on files created later (`setfacl -d`). ACLs don't let `ubuntu` change permissions, and `ddev start` changes `.ddev/`'s when it writes Craft's settings, so the hook also makes `ubuntu` the owner of `.ddev/`. Git in the web container sees a root-owned checkout, so `ubuntu`'s git config trusts it (`safe.directory`). DDEV copies that config into the container.

**HTTPS is intercepted.** All outbound traffic goes through Anthropic's egress proxy, which re-signs HTTPS with its own CAs. The VM trusts them (they're in `/usr/local/share/ca-certificates`), but containers don't, so `apt`, `curl`, Composer and npm in DDEV's containers would fail with certificate errors. The setup script follows [DDEV's documented fix for TLS-intercepting proxies](https://docs.ddev.com/en/stable/users/usage/networking/#corporate-packet-inspection-vpns-including-zscaler-and-global-protect): it copies the CAs into a global `~/.ddev/web-build/pre.Dockerfile`, which applies to every project without changing `.ddev/`. Node doesn't read the system CA store, so a global `web_environment` sets `NODE_EXTRA_CA_CERTS`.

**Docker Hub rate-limits anonymous pulls.** Pulls from cloud sessions get `429 Too Many Requests`, because many sessions share the egress IPs. The Docker daemon pulls through `mirror.gcr.io`, Google's Docker Hub mirror, instead.

**`*.ddev.site` doesn't resolve, and the VM's tools send it to the proxy.** A cloud VM's DNS may only answer for hosts its network access allows, so `<project>.ddev.site` doesn't resolve. DDEV then adds the project's hostnames to `/etc/hosts` with `sudo ddev-hostname`, and the setup script lets the `ubuntu` user run that without a password. Separately, `HTTPS_PROXY` is set for every command, and the proxy refuses local addresses. The hook adds `.ddev.site` to `NO_PROXY` for the session, so `curl` and Playwright reach the site directly. The setup script trusts mkcert's CA in the VM's trust stores, including Chromium's.

**GitHub archives work inside DDEV, but the hook doesn't rely on them.** Composer downloads every locked package as a GitHub archive (`api.github.com/repos/…/zipball/…`). From the VM itself, the GitHub proxy refuses these for any repository not attached to the session. From DDEV's containers they go through the egress proxy like other traffic, and `ddev composer install` works. These requests are anonymous, and the egress IPs share GitHub's 60 requests/hour API limit.

So that the post-start `composer install` doesn't depend on them, the setup script and the hook first run `.claude/cloud/warm-composer-cache.sh`. For each package in `composer.lock`, it shallow-fetches the locked commit with git and builds the zip with `git archive`, which honours `export-ignore` like GitHub's archives. It writes the zip into DDEV's Composer cache (the `ddev-global-cache` volume), under the name Composer looks for before it downloads. They run it as root, because git on the VM needs the session's proxy CA, then hand the cache to `ubuntu`: Composer in the web container fails on a cache directory it can't write.

After changing `composer.json`, the same steps work by hand, in the web container, where no `chown` is needed:

```sh
ddev composer update --no-install <package>
ddev exec .claude/cloud/warm-composer-cache.sh
ddev composer install
```

If archive downloads start failing with rate-limit errors, give Composer in the web container a read-only GitHub token with `ddev composer config --global github-oauth.github.com <token>`. It lasts until `ddev restart`. An environment variable such as `COMPOSER_AUTH` in the environment's settings doesn't help, because DDEV doesn't pass the VM's environment into its containers.

**Composer can't use GitHub's API for metadata.** That shared 60 requests/hour limit is usually used up, so the API answers `403`. When `composer.json` has a `github` or `vcs` repository, `composer update` and `composer require` read it through the API, and after a `403` fall back to cloning it over SSH, which cloud sessions can't reach. So the setup script turns off Composer's GitHub API in DDEV's web container (`use-github-api: false`, through DDEV's global `~/.ddev/homeadditions`), and Composer clones such repositories over HTTPS instead.

**The snapshot is a cache, not a copy of a session.** The setup script runs after the session's repositories are cloned, and before the snapshot is taken. So it builds the DDEV images of the projects checked out then, and fills DDEV's Composer cache from their lock files. Both are keyed by content, not by checkout: a later session reuses whatever still matches its branch, and rebuilds the rest.

**There's no database dump.** Local development on a real project usually imports a database. A cloud session starts with DDEV's empty database, and the hook installs Craft into it with no content. See [Craft](#craft).

## Craft

The hook runs `.claude/cloud/install-craft.sh` whenever Craft isn't installed, and puts the login it prints into Claude's context. To run it yourself:

```sh
.claude/cloud/install-craft.sh
```

It takes about 10 seconds. It installs Craft from project config, with no content, and an admin account: `admin@example.com` and a random password. Installing rewrites project config with the site name and URL it's given, so the script then restores `config/project/` from git, even when the install fails, and runs `craft up` so the database matches it. Craft's output goes to `/tmp/install-craft.log`. It does nothing when Craft is already installed, and won't run over uncommitted changes to `config/project/`.

Afterwards, `ddev craft` commands work, the site is at `https://<project>.ddev.site`, and the control panel is at `/admin`. If the password is lost (a resumed session's context doesn't have it), set a new one with `ddev craft users/set-password admin@example.com`.

## Limitations

- **The site has no content.** The hook installs Craft with no entries or users besides its admin. Don't import a real project's database into a cloud VM: that means handing a session production credentials and personal data. If Claude needs to see pages with content, a scrubbed dump or a seed script would be the way.
- **No secrets.** `.env` comes from `.env.example.dev`, so S3, Imager X and email aren't configured. Environment variables in the environment's settings are visible to everything in the session, so don't put production secrets there.
- **Resources.** Cloud VMs have about 4 vCPUs, 16 GB of RAM and 30 GB of disk. Docker's images, build cache and volumes take a large share of the disk.
- **Idle sessions.** The VM pauses when idle and can be reclaimed. A reopened session starts a new VM, and the hook starts DDEV again.
- **One repository per session.** In a session with more than one repository, Claude Code doesn't run any repository's SessionStart hook ([Anthropic's docs](https://code.claude.com/docs/en/cloud-environments#limitations-in-cloud-sessions)), so Docker and DDEV don't start. Run the hook by hand from this checkout: `CLAUDE_CODE_REMOTE=true CLAUDE_PROJECT_DIR="$PWD" .claude/hooks/session-start.sh`.
- **A session from the cache can start on an old commit.** The snapshot keeps the checkout, and a session that starts from it can stay on the commit its branch had then, even when the branch has moved since. `git status` still says it's up to date, because the remote-tracking branch was moved back too. Run `git fetch` before trusting it, and `git pull` to catch up.
- **Version drift.** The environment runs the pasted copy of the setup script. Re-paste it when `.claude/cloud/environment-setup.sh` changes. The environment's cache also expires after ~7 days and the script runs again then.

## Troubleshooting

| Symptom                                                                                            | Cause and fix                                                                                                                                                                                                                                                                  |
| -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `ddev start` fails building the web image with `403 Forbidden`                                     | A host from [Network access](#1-network-access) is missing                                                                                                                                                                                                                     |
| `ddev start` fails with `could not change permissions on file …/.ddev`                             | `.ddev/` isn't owned by `ubuntu`. Run `chown ubuntu: .ddev` from the checkout                                                                                                                                                                                                  |
| `SSL certificate problem` or `SELF_SIGNED_CERT_IN_CHAIN` inside a container                        | The proxy's CAs aren't in the web image. Re-run `.claude/cloud/environment-setup.sh`, then `ddev restart`. Check with `ddev exec curl -I https://repo.packagist.org`                                                                                                           |
| `429 Too Many Requests` pulling an image                                                           | Docker isn't using the mirror. Check `/etc/docker/daemon.json` and restart `dockerd`                                                                                                                                                                                           |
| `ddev composer update` fails with `ssh: connect to host github.com port 22: Connection timed out`  | Composer is using GitHub's API. `ddev exec composer config -g use-github-api` should print `false`. If it doesn't, re-run `.claude/cloud/environment-setup.sh`, then `ddev restart`                                                                                            |
| `composer install` fails with `…/composer/files/<package> does not exist and could not be created` | A directory in DDEV's Composer cache belongs to root, so Composer in the web container can't write to it. Run `chown -R ubuntu: "$(docker volume inspect ddev-global-cache --format '{{.Mountpoint}}')/composer"`. Run the warm script with `ddev exec`, not as root on the VM |
| The hook logs `warming Composer's cache failed`                                                    | A git fetch failed. `/tmp/warm-composer-cache.log` lists the packages, and the post-start `composer install` downloads them instead. To retry, run `ddev exec .claude/cloud/warm-composer-cache.sh`                                                                            |
| `ddev start` fails with `Bind for 127.0.0.1:32768 failed: port is already allocated`               | Another container got that host port first, which can happen just after Docker starts. DDEV picks the web and db containers' ports, Docker picks the rest. The hook runs `ddev start` once more. If that fails too, run `ddev start` again                                     |
| `DDEV is not designed to be run with root privileges`                                              | Something ran `/usr/bin/ddev` directly. Use `ddev`                                                                                                                                                                                                                             |
| `permission denied` writing in the checkout from DDEV                                              | The checkout lost its ACLs. Re-run `setfacl -R -m u:ubuntu:rwX -m d:u:ubuntu:rwX .` from the checkout                                                                                                                                                                          |
| `curl https://<project>.ddev.site` gets `CONNECT tunnel failed, response 403`                      | `NO_PROXY` doesn't include `.ddev.site`. Use `curl --noproxy .ddev.site …`                                                                                                                                                                                                     |
| The hook says installing Craft failed                                                              | `/tmp/install-craft.log` has Craft's output. Fix the cause, then run `.claude/cloud/install-craft.sh`. If it says to commit or stash your changes first, `config/project/` has uncommitted changes                                                                             |

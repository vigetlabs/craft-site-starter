# Deploy Cache Clearing

> This file is a template from [Craft Site Starter](https://github.com/vigetlabs/craft-site-starter).
> Customize the "What `bin/deploy` actually runs" section for the specific project
> (FPM version, paths from `config/deploy.conf`).

---

## What `bin/deploy` actually runs

On every deploy:

```sh
./craft clear-caches/compiled-templates
./craft clear-caches/blitz          # omit if Blitz is not installed
```

PHP-FPM is reloaded unconditionally (see `config/deploy.conf` for the exact service name),
which clears OPcache for all web requests.

After a Craft or plugin update only (run manually via `bin/deploy <env> run`):

```sh
cd current && ./craft clear-caches/compiled-classes && ./craft clear-caches/cp-resources
```

---

## Full cache inventory

| Cache               | Command                            | Clear on deploy?                   |
| ------------------- | ---------------------------------- | ---------------------------------- |
| Blitz HTML cache    | `clear-caches/blitz`               | ✅ Always (if Blitz is installed)  |
| Compiled templates  | `clear-caches/compiled-templates`  | ✅ Always                          |
| Compiled classes    | `clear-caches/compiled-classes`    | ✅ Craft/plugin updates only       |
| CP resources        | `clear-caches/cp-resources`        | ✅ Craft/plugin updates only       |
| PHP OPcache         | FPM reload                         | ✅ Always (`bin/deploy` does this) |
| Data/object cache   | `clear-caches/data`                | ❌ Never on routine deploy         |
| Asset indexing data | `clear-caches/asset-indexing-data` | ❌ Never                           |

### Why the data cache must never be cleared on routine deploys

The data cache contains:

- **Imager X transform metadata** — S3/CloudFront object existence records. If cleared,
  Imager X must issue an S3 HEAD request per transform on the next request to determine
  whether the transform already exists. At scale this is catastrophic.
- **Embedded Assets JSON** — TTL 0, expensive to rebuild.
- `{% cache %}` fragment output.
- Element query results.

**Never run `clear-caches/all` on deploy.** It clears the data cache.

---

## Imager X + AWS Serverless Transformer

This project uses `spacecatninja/imager-x-aws-serverless-transformer`. Transforms are
generated on-demand via AWS Lambda and cached on CloudFront. The data cache holds the
transform metadata that tells Imager X which S3 keys already exist.

| Situation                                                                  | Action                                                                                                                                                                              |
| -------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Routine deploy                                                             | `clear-caches/compiled-templates` only — never `clear-caches/data`                                                                                                                  |
| `config/imager-x.php` or `config/imager-x-transforms.php` changes          | CloudFront auto-invalidates (configured via `cloudfrontInvalidateEnabled: true`). Then clear data cache and regenerate: `./craft clear-caches/data && ./craft blitz/cache/generate` |
| `signatureKey` in `config/imager-x-aws-serverless-transformer.php` changes | All signed URLs are immediately invalid — existing CloudFront entries will 403. Perform a full CloudFront invalidation (`/*`) before the deploy goes live.                          |

---

## Local development

In DDEV, `post-import-db` runs `./craft clear-caches/all`. This is safe because local
development has no persistent Imager X metadata or Embedded Assets data worth preserving.

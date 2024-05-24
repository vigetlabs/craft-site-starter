# Getting Started

This repo is a Composer "project" intended for use with the `composer create-project` command.

Our starter uses DDEV for local development. Install it before doing any of the following steps.

## Create Project

1. [Install DDEV](https://ddev.readthedocs.io/en/stable/users/install/ddev-installation/)
2. Choose a folder for your project and move into it:
   ```shell
   cd /path/to/web/projects
   mkdir my-project
   cd my-project
   ```
3. Create The Project
   If you already have PHP and Composer running on your host machine (your computer, not Docker container or DDEV
   instance), you can run the following command

   ```shell
   composer create-project viget/craft-site-starter=^5.0.0 ./ --ignore-platform-reqs
   ```

   If you'd rather not set up PHP, you can create the project with a desposable Docker
   image ([Thanks nystudio107](https://nystudio107.com/blog/dock-life-using-docker-for-all-the-things)).

   ```shell
   docker run --rm -it -v "$PWD":/app -v ${COMPOSER_HOME:-$HOME/.composer}:/tmp composer create-project viget/craft-site-starter=^5.0.0 ./ --ignore-platform-reqs
   ```

4. Start DDEV & Install Craft
   ```shell
   ddev start
   ddev craft install
   ```
5. Run `ddev launch` to open the project in your browser

# Plugins

This starter includes common plugins that we use on most of our sites. This provides consistency and familiarly between
client projects. You may not need every plugin, but avoid
replacing standard plugins with similar alternatives (unless absolutely necessary).

| Name                                                              | Composer                          | Usage                                                                                                                                                                               | Year 1 Price | Renewal Price |
| ----------------------------------------------------------------- | --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ | ------------- |
| [Amazon S3](https://plugins.craftcms.com/aws-s3)                  | `craftcms/aws-s3`                 | This plugin integrates Craft CMS and Amazon S3 cloud storage service.                                                                                                               | Free         | Free          |
| [Autocomplete](https://github.com/nystudio107/craft-autocomplete) | `nystudio107/craft-autocomplete`  | Provides Twig template IDE autocomplete of Craft CMS & plugin variables. Requires the [PHPStorm Symphony Support Plugin](https://plugins.jetbrains.com/plugin/7219-symfony-support) | Free         | Free          |
| [CKEditor](https://plugins.craftcms.com/ckeditor)                 | `craftcms/ckeditor`               | Craft CMS’s official rich text plugin                                                                                                                                               | Free         | Free          |
| [Classnames](https://plugins.craftcms.com/classnames)             | `viget/craft-classnames`          | Conditionally join css class names together in Twig                                                                                                                                 | Free         | Free          |
| [CP Field Inspect](https://plugins.craftcms.com/cp-field-inspect) | `mmikkel/cp-field-inspect`        | CP Field Inspect is a tiny utility plugin, that makes content modelling a little bit easier in Craft.                                                                               | Free         | Free          |
| [Empty Coalesce](https://plugins.craftcms.com/empty-coalesce)     | `nystudio107/craft-emptycoalesce` | Adds the `???` operator to Twig that will return the first thing that is defined, not null, and not empty.                                                                          | Free         | Free          |
| [Imager X](https://plugins.craftcms.com/imager-x)                 | `spacecatninja/imager-x`          | Image optimization and Imgix connector. Provides useful Twig shortcuts for generating transforms and placeholders.                                                                  | $99.00       | $59.00        |
| [Navigation](https://plugins.craftcms.com/navigation)             | `verbb/navigation`                | Simplifies management of complex navigation groups (main menus, footer menus, etc.)                                                                                                 | $19.00       | $5.00         |
| [Retour](https://plugins.craftcms.com/retour)                     | `nystudio107/craft-retour`        | Provides an Craft admin UI to set up redirects. Will automatically create redirects when URLs of entries change.                                                                    | $59.00       | $29.00        |
| [SEOMatic](https://plugins.craftcms.com/seomatic)                 | `nystudio107/craft-seomatic`      | A turnkey SEO plugin that follows [modern SEO best practices](https://nystudio107.com/blog/modern-seo-snake-oil-vs-substance).                                                      | $99.00       | $49.00        |
| [Vite](https://plugins.craftcms.com/vite)                         | `nystudio107/craft-vite`          | Loads front-end files that are compiled by Vite.                                                                                                                                    | Free         | Free          |

# Contribute to this starter

## Local Dev

Ideally, you should be able to clone this repo and make modifications to plugin & build tool configs with minimal fuss.

Run `ddev start` and make edits in a feature branch.

See [ARCHITECTURE.md](ARCHITECTURE.md) for details on technical goals & decisions.

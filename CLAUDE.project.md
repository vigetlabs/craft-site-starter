# Viget Craft Starter

A Craft CMS 5 site built on [Viget's Craft Site Starter](https://github.com/vigetlabs/craft-site-starter): PHP 8.4 and MySQL 8.4 in DDEV, Twig templates, and a Vite build with Tailwind CSS 4 and Alpine.js.

## Commands

Run PHP, Composer, Craft and npm through DDEV, not on the host:

- `ddev start` starts the site at `https://<name>.ddev.site`, where `<name>` is the `name` in `.ddev/config.yaml`. The control panel is at `/admin`.
- `ddev craft …` runs Craft's console. `ddev craft up` applies pending migrations and project config.
- `ddev composer phpstan` and `ddev composer ecs-check` check the PHP in `modules/` and `config/`. `ddev composer ecs-fix` fixes coding style.
- `ddev npm run lint` runs ESLint on `src/` and fixes what it can. `ddev npm run format` runs Prettier on everything.
- `ddev npm run build` builds the front end into `web/dist/`.

`ddev start` also starts the Vite dev server, as a DDEV daemon that runs `npm install`, `npm run build` and `npm run dev`. Don't start another one.

The husky pre-commit hook runs lint-staged in DDEV, so DDEV has to be running to commit. On staged files, it runs ECS (with fixes) and PHPStan on PHP, ESLint and Prettier on JS, and Prettier on everything else.

## Content model

Sections, entry types, fields and plugin settings are stored in project config, `config/project/*.yaml`. The control panel only allows changing them in the `dev` environment (`CRAFT_ENVIRONMENT` in `.env`). Make schema changes in the control panel and commit the YAML Craft writes. If you edit the YAML by hand, give anything new its own UUID, then run `ddev craft up` and check it applies.

## Templates

- `_layouts/base.twig` is the page shell. Page templates extend it and fill its `content` block.
- `_elements/` holds the entry templates that sections point to.
- `_components/` holds the components, based on [Blueprint](https://github.com/vigetlabs/blueprint). Each is a macro that takes a single `props` hash and declares every prop at the top, with a `{# @var type name #}` comment and a default (`props.size ?? 'md'`). Most take a `class` prop, joined to their own classes with `cx()` from the Classnames plugin. Import them with `{% from '_components/button' import Button %}`. New components should follow the same pattern.
- `_blocks/` renders the `pageBlocks` Matrix field, the block editor. `_blocks/index.twig` includes `_blocks/_<entryTypeHandle>.twig` for each block, and sets the spacing between blocks in `marginBottomConfig`. A block template passes the block's fields to a component. To add a block, add an entry type to `pageBlocks` and a matching `_blocks/_<handle>.twig`.
- `_partials/` holds the `<head>`, header, navigation and footer.
- `parts-kit/<component>/<example>.twig` are the examples in the [Parts Kit](https://github.com/vigetlabs/craft-parts-kit), at `/parts-kit` for logged-in users. Add or update one along with a component.

Render images with the `Image` component, which builds responsive transforms with Imager X. Pass `sizes` and, for a fixed shape, `ratio`.

Wrap static UI text in the `|t` filter, and add its translation to each `translations/<language>/site.php`.

## Front end

- `src/js/app.js` is the only Vite entry. It imports `src/css/app.css` and registers Alpine plugins and components. Alpine components go in `src/js/alpine/`, registered with `Alpine.data()`.
- Tailwind is configured in `src/css/app.css` (`@theme`), with no `tailwind.config.js`. Its spacing scale is replaced with steps named in pixels (`p-16` is 16px), and only the listed steps exist. PostCSS converts px to rem.
- The styles for buttons, dialogs, forms and rich text are Tailwind plugins in `config/tailwind/`.
- For an icon, add an SVG to `src/icons/` and render it by file name with the `Icon` macro in `_components/icon.twig`. Vite bundles the icons into one SVG spritemap.

## PHP

Custom PHP goes in a Craft module in `modules/` (namespace `modules\`). `ddev craft make module` scaffolds one. Config files in `config/` read environment variables with `App::env()`. Add new ones to the `.env.example.*` files.

The plugins that come with the starter are listed in `README.md`. Use them before adding alternatives.

## Cloud sessions

In Claude Code cloud sessions, DDEV runs and Craft is installed with no content. See `docs/claude-cloud.md`.

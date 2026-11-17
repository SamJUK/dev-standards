# Install

dev-standards installs through Composer for PHP projects, and as a GitHub dependency for Node projects.
Either way, `samjuk-dev-standards init` sets the project up, and the files it writes are committed.

## Magento store

```sh
composer require --dev samjuk/dev-standards phpstan/phpstan bitexpert/phpstan-magento phpstan/extension-installer
composer require --dev magento/magento-coding-standard   # or mage-os/magento-coding-standard on Mage-OS
vendor/bin/samjuk-dev-standards init
```

`init` writes `lefthook.yml`, `phpcs.xml.dist` and, when `app/code` has first-party PHP, `phpstan.neon.dist`, then installs the git hooks.
The `.dist` files include the shared config from `vendor/samjuk/dev-standards/php/magento/`, which runs the Magento2 standard at severity 6 on PHP and templates, and PHPStan at level 6.

## Magento module

A repository with `registration.php` at its root, or `"type": "magento2-module"` in `composer.json`, is a module.

```sh
composer config repositories.mage-os composer https://mirror.mage-os.org/   # Magento packages without repo.magento.com keys
composer require --dev samjuk/dev-standards magento/magento-coding-standard
composer require --dev bitexpert/phpstan-magento phpstan/extension-installer   # Magento factories and proxies for PHPStan
vendor/bin/samjuk-dev-standards init
```

The module's `composer.json` has to `require` what its code uses: `magento/framework` at least, as `registration.php` calls it, and every Magento module it depends on.
PHPCS and PHPStan load Composer's autoloader, which runs `registration.php`, so the checks fail until it does.
[Yireo's ExtensionChecker](https://github.com/yireo/Yireo_ExtensionChecker) finds undeclared dependencies and suggests the `require` section.

Composer asks to allow plugins.
Allow `dealerdirect/phpcodesniffer-composer-installer`, which registers the Magento coding standard with PHPCS.
Magento's own plugins are not needed in a module, so deny those.
Ignore `/vendor/`, `/var/` (PHPStan's cache) and `composer.lock` in the module's `.gitignore`.

`init` writes `phpcs.xml.dist` and `phpstan.neon.dist`, listing every top-level folder with PHP or templates, bar `vendor/`.
The Magento coding standard brings PHPStan with it, so a module gets both.
With tests under analysis, add `phpunit/phpunit` too, or take the tests folder out of `paths`.

## Laravel app

```sh
composer require --dev samjuk/dev-standards
vendor/bin/samjuk-dev-standards init
```

`init` writes `lefthook.yml` and installs the git hooks.
On commit, Pint checks the staged files with the app's own `pint.json`, then PHPStan runs when there is a `phpstan.neon` or `phpstan.neon.dist`.

## Node project or static site

```sh
pnpm add -D lefthook github:SamJUK/dev-standards#v1.0.0   # or npm install -D
node_modules/.bin/samjuk-dev-standards init
```

A project with `package.json` and no PHP stack.
On commit, it runs the package.json scripts named `lint`, `check` and `typecheck`, where they exist.
`test` is left out, as end-to-end suites are too slow for a commit.
Choose other scripts with `NODE_SCRIPTS` on the `node-checks` job, for example `NODE_SCRIPTS: astro:check`.

Add `"prepare": "lefthook install"` to the scripts, and everyone else gets the hooks on their next install.

## Apps in a sub-folder

A Laravel app in `web/` or a site in `site/` works too.
Install dev-standards in that folder and run `init` from it.
`lefthook.yml` goes at the repository root, and the stack's checks only see files inside the folder.

## Choose what gets checked

On Magento, the `<file>` entries in `phpcs.xml.dist` are what the hooks check, in stores and modules alike.
`init` fills them in, and editing the list changes it, for example `<file>src</file>` for a module kept under `src/`.
PHPStan reads `paths` in `phpstan.neon.dist`.

## Where PHP runs

PHP tools run with the host's PHP, or inside Warden or DDEV when the host has none.
With neither, the check fails rather than let the commit through unchecked.
Start the environment, or skip the check once with `LEFTHOOK_EXCLUDE=php-standards git commit ...`.

## How the stack is detected

In order:

1. `artisan`: Laravel.
2. A root `registration.php`, or the `magento2-module` composer type: Magento module.
3. `app/etc/config.php` or `bin/magento`: Magento store.
4. `package.json`: Node.
5. Anything else gets the base rules only.

## Commands

| Command | What it does |
|---|---|
| `samjuk-dev-standards check [files]` | The stack's checks. Magento runs PHPCS and PHPStan on the given files. Laravel runs Pint on them, then PHPStan over its configured paths. Node runs its package.json scripts when any given file is in the project. With no files, the whole project |
| `samjuk-dev-standards fix [files]` | PHPCBF or Pint. Nothing for Node |
| `samjuk-dev-standards init` | Write the config files and install the hooks. Existing files are kept |
| `samjuk-dev-standards doctor [--strict]` | Report setup drift: config that is missing, ignored by Git or not including the shared config, a local `phpcs.xml` or `phpstan.neon` overriding the shared one, hooks not installed |

## Checking the setup in CI

`samjuk-dev-standards doctor --strict` fails on any drift, so a CI step can catch a project that has lost its config.
Hooks can be skipped with `--no-verify`, so CI should still run PHPCS, PHPStan or the package.json scripts itself.

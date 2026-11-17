# dev-standards

Shared git hooks, commit rules and QA checks for Magento, Laravel and Node projects, so every project checks the same things locally and in CI.
Hooks run through [Lefthook](https://github.com/evilmartians/lefthook), and each project turns rules off or configures them in its own `lefthook.yml`.

On every commit and push it checks:

- **Commit messages**: Conventional Commits, line width, and a task reference if the project wants one.
- **Staged changes**: conflict markers, debug calls, private keys, credential files and large files.
- **The stack's own tools**: PHPCS and PHPStan on Magento, Pint and PHPStan on Laravel, the package.json scripts on Node.
- **Pushes**: nothing straight to `main` or `master`.

Rules only cover what the stack's tools miss, and every check runs on staged changes, so a commit stays quick.

## Quick start

Magento store:

```sh
composer require --dev samjuk/dev-standards magento/magento-coding-standard phpstan/phpstan bitexpert/phpstan-magento phpstan/extension-installer
vendor/bin/samjuk-dev-standards init
```

Magento module:

```sh
composer require --dev samjuk/dev-standards magento/magento-coding-standard
vendor/bin/samjuk-dev-standards init
```

Laravel app:

```sh
composer require --dev samjuk/dev-standards
vendor/bin/samjuk-dev-standards init
```

Node project or static site:

```sh
pnpm add -D lefthook github:SamJUK/dev-standards#v1.0.0
node_modules/.bin/samjuk-dev-standards init
```

It needs a POSIX shell: macOS, Linux, or WSL on Windows.

`init` works out the stack, writes `lefthook.yml` and the QA config it needs, and installs the hooks.
Commit what it writes.
Everyone else runs `lefthook install` once per clone.

[docs/install.md](docs/install.md) covers each stack in more depth: Mage-OS, PHPStan on modules, apps in a sub-folder, Warden and DDEV, and checking the setup in CI.

## Rules

| Hook | Rule | What it stops |
|---|---|---|
| commit-msg | `conventional-commit` | Subjects that are not `type(scope)!: summary` |
| commit-msg | `message-width` | Subject or body lines over 72 characters |
| commit-msg | `task-id` | Messages without a task reference, once a pattern is set |
| pre-commit | `conflict-markers` | `<<<<<<<` and `>>>>>>>` left in |
| pre-commit | `debug-statements` | `dd(`, `dump(`, `ray(`, `console.log(`, `debugger;` |
| pre-commit | `private-keys` | Private key blocks |
| pre-commit | `credential-files` | `auth.json`, `.env`, `env.php`, `.npmrc`, SSH keys, certificates |
| pre-commit | `large-files` | Files over 500KB not tracked by Git LFS |
| pre-commit | `php-standards` | PHPCS and PHPStan (Magento), Pint and PHPStan (Laravel) |
| pre-commit | `magento-object-manager` | `ObjectManager::getInstance()` |
| pre-commit | `node-checks` | Failing `lint`, `check` or `typecheck` scripts |
| pre-push | `protected-branches` | Pushing straight to `main` or `master` |

Turn one off, or configure it, by name in the project's `lefthook.yml`:

```yaml
commit-msg:
  jobs:
    - name: task-id
      env:
        TASK_ID_PATTERN: 'PROJ-[0-9]+'

pre-push:
  jobs:
    - name: protected-branches
      skip: true
```

[docs/rules.md](docs/rules.md) has every option, the opt-in gitleaks rule, and how to skip a rule for one line, one file or one commit.

## Contributing

[CONTRIBUTING.md](CONTRIBUTING.md) covers the layout, running the tests, adding a rule and cutting a release.

## Licence

MIT

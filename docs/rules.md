# Rules

Rules cover what the stack's own tools miss.
Anything PHPCS, PHPStan or Pint already flags is left to them.
Rules on staged changes only look at added lines, so existing code never blocks a commit.

## Every project

| Hook | Rule | What it checks | Configure with |
|---|---|---|---|
| commit-msg | `conventional-commit` | The subject is `type(scope)!: summary` | `COMMIT_TYPES` (default `build\|chore\|ci\|docs\|feat\|fix\|perf\|refactor\|revert\|style\|test`) |
| commit-msg | `message-width` | Subject and body line length. Body lines with a URL are exempt | `SUBJECT_MAX_WIDTH`, `BODY_MAX_WIDTH` (72) |
| commit-msg | `task-id` | The message references a task. Off until a pattern is set | `TASK_ID_PATTERN`, for example `PROJ-[0-9]+` or `(PROJ\|OPS)-[0-9]+` |
| pre-commit | `conflict-markers` | Merge conflict markers | |
| pre-commit | `debug-statements` | `dd(`, `dump(`, `ray(` in PHP, plus `var_dump(` and `print_r(` on Laravel, as Magento's PHPCS already flags those. `console.log(`, `console.debug(` and `debugger;` in scripts and templates | `DEBUG_PATTERN` replaces the default, for every file |
| pre-commit | `private-keys` | Private key blocks | |
| pre-commit | `credential-files` | `auth.json`, `.env`, `env.php`, `.npmrc`, SSH keys, `*.pem`, `*.key`. `.example`, `.dist`, `.sample` and `.template` copies are fine | `CREDENTIAL_FILES` replaces the pattern |
| pre-commit | `large-files` | Files over the limit not tracked by Git LFS | `LARGE_FILE_KB` (500) |
| pre-push | `protected-branches` | Pushing straight to a protected branch | `PROTECTED_BRANCHES` (`main master`) |

Merge, revert, fixup and squash commits skip the commit message rules.
A renamed file is compared with its old path, so moving a file does not re-check its contents.

## Per stack

| Stack | Rule | What it checks | Configure with |
|---|---|---|---|
| Magento | `magento-object-manager` | `ObjectManager::getInstance()` | |
| Magento | `php-standards` | PHPCS and PHPStan on staged files | `phpcs.xml.dist`, `phpstan.neon.dist` |
| Laravel | `php-standards` | Pint on staged files, then PHPStan | `pint.json`, `phpstan.neon` |
| Node | `node-checks` | The project's package.json scripts | `NODE_SCRIPTS` (`lint check typecheck`) |

## Opt in

`gitleaks` scans staged changes for secrets with [gitleaks](https://github.com/gitleaks/gitleaks), which has to be installed.
Add it to `extends`:

```yaml
extends:
  - vendor/samjuk/dev-standards/lefthook/base.yml
  - vendor/samjuk/dev-standards/lefthook/magento.yml
  - vendor/samjuk/dev-standards/lefthook/optional/gitleaks.yml
```

## Configure a project

Each rule is a Lefthook job, and the project's `lefthook.yml` turns it off or sets its options by name:

```yaml
templates:
  dev-standards: vendor/samjuk/dev-standards

extends:
  - vendor/samjuk/dev-standards/lefthook/base.yml
  - vendor/samjuk/dev-standards/lefthook/magento.yml

commit-msg:
  jobs:
    - name: task-id
      env:
        TASK_ID_PATTERN: 'PROJ-[0-9]+'

pre-commit:
  jobs:
    - name: private-keys
      exclude:
        - "tests/fixtures/*"

pre-push:
  jobs:
    - name: protected-branches
      skip: true
```

## Skipping a rule

| Scope | How |
|---|---|
| One line, from PHPCS or PHPStan | The tool's own marker: `// phpcs:ignore Sniff.Name`, `// @phpstan-ignore identifier` |
| Some files, for good | `exclude` on the job in `lefthook.yml` |
| A large file | Track it with Git LFS, or `exclude` it from `large-files` |
| A whole rule | `skip: true` on the job |
| One commit | `LEFTHOOK_EXCLUDE=credential-files git commit ...`, comma-separated for several |
| Everything, once | `git commit --no-verify`. CI should still run the stack's tools |

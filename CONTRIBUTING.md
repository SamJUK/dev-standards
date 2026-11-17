# Contributing

Issues and pull requests are welcome.
For anything bigger than a fix, open an issue first, so we can agree the shape before you write it.

## Layout

```
bin/        samjuk-dev-standards: init, check, fix and doctor (POSIX shell)
lefthook/   shared hook configs: base.yml for every project, one per stack, optional/ to opt in
rules/      the rule scripts (POSIX shell): commit-msg/, pre-commit/, pre-push/, one folder per stack, lib/ for shared helpers
php/        PHPCS and PHPStan config, included by the .dist files init writes
stubs/      the files init writes into a project
tests/      bats tests: real commits and pushes through Lefthook
docs/       install and rules reference
```

Composer and pnpm install GitHub's archive of a tag, so `.gitattributes` decides what both get.

## Running the tests

The tests make real commits and pushes in throwaway repositories, through a real Lefthook.
They need [bats-core](https://github.com/bats-core/bats-core), [Lefthook](https://github.com/evilmartians/lefthook), PHP and Node on the `PATH`.

```sh
shellcheck bin/samjuk-dev-standards rules/*/*.sh && shellcheck -s bash tests/helpers.bash
bats tests   # or: npx bats tests
bats --filter 'phpcs.xml.dist' tests   # some of them
```

`blocked <job> <command>` asserts that a command fails, and that the named job is what failed it.
Use it for every case that should be stopped, so a test cannot pass because something else broke.

## Adding a rule

- Write it in POSIX shell under `rules/<hook>/`, and keep it to what the stack's own tools miss.
- Put every default in the script, read from an environment variable the project can set.
  Lefthook lets `extends` override the project's own file, so the shared configs in `lefthook/` never set `skip` or `env`, or a project could not change them.
- For rules on staged changes, `rules/lib/added-lines.sh` checks added lines only.
- Add tests for what it stops and what it lets through, and document it in `docs/rules.md` and the README's table.

## Commits

Commits follow [Conventional Commits](https://www.conventionalcommits.org/).
Run `lefthook install` once, and this repository's own hooks check them, with the rules from the working tree.
Release notes are built from them, so the subject should make sense to someone reading the release.
Mark a breaking change with `!` and a `BREAKING CHANGE:` footer.

## Releasing

Versions follow [Semantic Versioning](https://semver.org/).
The public surface is the command and its options, the job names, the environment variables and the paths under `vendor/samjuk/dev-standards` and `node_modules/@samjuk/dev-standards`.

1. Pick the version from the commits since the last tag: a breaking change is a major, a `feat` a minor, anything else a patch. `git cliff --bumped-version` suggests one.
2. Tag `master` and push the tag: `git tag -s v1.2.0 -m v1.2.0 && git push origin v1.2.0`.
   Or run the Release workflow from the Actions tab with the version, which tags `master` for you (unsigned).
3. The release workflow creates the GitHub release, with notes built from the commits by [git-cliff](https://git-cliff.org/).
   Packagist picks up the tag on its own.

The GitHub releases are the changelog.

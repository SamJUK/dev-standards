# A static site in site/, the package laid out the way pnpm installs it: real files under .pnpm, a symlink to them.
setup() {
    load helpers
    project
    pkg=site/node_modules/.pnpm/@samjuk+dev-standards/node_modules/@samjuk/dev-standards
    mkdir -p site/node_modules/@samjuk site/node_modules/.bin
    copy_package "$pkg"
    ln -s ../.pnpm/@samjuk+dev-standards/node_modules/@samjuk/dev-standards site/node_modules/@samjuk/dev-standards
    ln -s "$(command -v lefthook)" site/node_modules/.bin/lefthook
    printf '{"lint": "not a script", "scripts": {"check" : "! grep -rq BAD src", "test": "exit 1"}}\n' > site/package.json
    printf '/site/node_modules/\n' > .gitignore
    mkdir -p site/src && printf 'fine\n' > site/src/index.astro
    git add -A && git commit -q --no-verify -m 'chore: site'
    rm lefthook.yml
    site/node_modules/@samjuk/dev-standards/bin/samjuk-dev-standards init >/dev/null
    git add lefthook.yml && git commit -q --no-verify -m 'chore: hooks'
}

@test "init writes lefthook.yml for the site" { grep -q 'site/node_modules/@samjuk/dev-standards/lefthook/node.yml' lefthook.yml; }
@test "failing check script blocks" { blocked node-checks add site/src/bad.astro 'BAD\n'; }
@test "clean file, and test is not run" { add site/src/good.astro 'fine\n'; }
@test "files outside site/ skip it" { add other.md 'BAD\n'; }
@test "NODE_SCRIPTS picks the scripts" { NODE_SCRIPTS=lint add site/src/x.astro 'BAD\n'; }

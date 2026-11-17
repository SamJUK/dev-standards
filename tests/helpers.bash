# Shared by every test: a throwaway repository with a bare remote, hooks installed through a real Lefthook.
# shellcheck disable=SC2016,SC2034,SC2154 # literal PHP; long is for the tests; bats sets status and output
root=$(cd "$BATS_TEST_DIRNAME/.." && pwd)
long=$(printf '%080d' 0)

# project [config] [extends]: lefthook.yml extends base.yml, then any extra extends lines, then the project's config.
project() {
    cd "$BATS_TEST_TMPDIR" || return 1
    rm -rf repo remote.git
    git init -q --bare remote.git
    git init -q -b feature repo
    cd repo || return 1
    git config user.email test@example.com
    git config user.name Test
    git config commit.gpgsign false
    git remote add origin ../remote.git
    cat > lefthook.yml <<YAML
templates:
  dev-standards: $root
extends:
  - $root/lefthook/base.yml
${2:-}
${1:-}
YAML
    git add lefthook.yml
    git commit -q --no-verify -m "chore: init"
    lefthook install >/dev/null 2>&1
}

commit() {
    git commit -q --allow-empty -m "$1"
}

# add <file> <content>: write, stage and commit a file, with PREFIX as the subject's start.
add() {
    mkdir -p "$(dirname "$1")"
    printf '%b' "$2" > "$1"
    git add -- "$1"
    git commit -q -m "${PREFIX:-feat:} add $1"
}

# blocked <job> <command...>: the command fails, and the named Lefthook job is what failed it.
blocked() {
    job=$1
    shift
    run "$@"
    if [ "$status" -eq 0 ] || ! grep -qE "🥊[[:space:]]+$job \(" <<< "$output"; then
        printf 'expected %s to block it (status %s)\n%s\n' "$job" "$status" "$output" >&2
        return 1
    fi
}

# copy_package <dir>: the working tree, without .git, into <dir>.
copy_package() {
    mkdir -p "$1"
    (cd "$root" && tar -cf - --exclude ./.git .) | (cd "$1" && tar -xf -)
}

# install_package <dir>: the package at <dir>/samjuk/dev-standards, as Composer installs it into vendor/.
install_package() {
    mkdir -p "$1/bin"
    copy_package "$1/samjuk/dev-standards"
    ln -s ../samjuk/dev-standards/bin/samjuk-dev-standards "$1/bin/samjuk-dev-standards"
    ln -s "$(command -v lefthook)" "$1/bin/lefthook"
}

# fake_tool <path>: a stand-in for PHPCS or Pint that fails on any file containing BAD.
fake_tool() {
    mkdir -p "$(dirname "$1")"
    printf '%s\n' '<?php foreach (array_slice($argv, 1) as $f) { if (is_file($f) && str_contains(file_get_contents($f), "BAD")) { exit(1); } }' > "$1"
    chmod +x "$1"
}

# use_hooks <package path> <stack>: a lefthook.yml for an installed package, committed, hooks installed.
use_hooks() {
    cat > lefthook.yml <<YAML
templates:
  dev-standards: $1
extends:
  - $1/lefthook/base.yml
  - $1/lefthook/$2.yml
YAML
    git add -A
    git commit -q --no-verify -m "chore: hooks"
    lefthook install >/dev/null 2>&1
}

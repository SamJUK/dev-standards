setup() {
    load helpers
}

@test "no stack: init extends base.yml only" {
    project
    install_package vendor
    printf '/vendor/\n' > .gitignore
    rm lefthook.yml
    vendor/bin/samjuk-dev-standards init
    grep -q 'lefthook/base.yml' lefthook.yml
    run grep -q 'none.yml' lefthook.yml
    [ "$status" -ne 0 ]
}

@test "path with a space: init writes lefthook.yml in the repo" {
    git init -q -b feature "$BATS_TEST_TMPDIR/a b"
    cd "$BATS_TEST_TMPDIR/a b"
    install_package vendor
    vendor/bin/samjuk-dev-standards init
    [ -f lefthook.yml ]
    [ ! -e "$BATS_TEST_TMPDIR/a" ]
}

@test "doctor: ok once init has run" {
    project
    install_package vendor
    printf '/vendor/\n' > .gitignore
    rm lefthook.yml
    vendor/bin/samjuk-dev-standards init
    run vendor/bin/samjuk-dev-standards doctor --strict
    [ "$status" -eq 0 ] && [ "$output" = ok ]
}

@test "doctor --strict: fails on a missing lefthook.yml" {
    project
    install_package vendor
    rm lefthook.yml
    run vendor/bin/samjuk-dev-standards doctor --strict
    [ "$status" -ne 0 ] && [[ $output == *"lefthook.yml is missing"* ]]
}

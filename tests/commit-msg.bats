setup() {
    load helpers
    project
}

@test "conventional subject" { commit 'feat(cart): handle an empty quote'; }
@test "non-conventional subject" { blocked conventional-commit commit 'updated some stuff'; }
@test "unknown type" { blocked conventional-commit commit 'feature: thing'; }
@test "breaking change marker" { commit 'feat!: drop PHP 8.1'; }
@test "merge commit" { commit "Merge branch 'x' into feature"; }
@test "long merge subject" { commit "Merge branch '$long' into feature"; }
@test "long revert subject" { commit "Revert \"feat: $long\""; }
@test "subject over 72" { blocked message-width commit "feat: $long"; }
@test "body line over 72" { blocked message-width commit "$(printf 'feat: x\n\n%s' "$long")"; }
@test "long body line with a URL" { commit "$(printf 'feat: x\n\nhttps://example.com/%s' "$long")"; }
@test "task id off by default" { commit 'feat: no task'; }

setup() {
    load helpers
    project
}

@test "push to a feature branch" { git push -q origin feature; }
@test "push to main" { blocked protected-branches git push -q origin feature:main; }
@test "push to master" { blocked protected-branches git push -q origin feature:master; }

@test "push an already-pushed branch to main" {
    git push -q -u origin feature
    blocked protected-branches git push -q origin feature:main
}

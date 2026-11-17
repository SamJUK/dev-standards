# A project's lefthook.yml turns rules off, configures them with env, and excludes paths.
setup() {
    load helpers
    project "$(cat <<'YAML'
commit-msg:
  jobs:
    - name: conventional-commit
      skip: true
    - name: task-id
      env:
        TASK_ID_PATTERN: '(PROJ|OPS):[0-9]+'
pre-commit:
  jobs:
    - name: large-files
      env:
        LARGE_FILE_KB: 1000
    - name: debug-statements
      env:
        DEBUG_PATTERN: 'forbidden_call\('
    - name: private-keys
      exclude:
        - "fixtures/*"
    - name: credential-files
      exclude:
        - auth.json
pre-push:
  jobs:
    - name: protected-branches
      skip: true
YAML
)"
    PREFIX=PROJ:1
}

@test "skipped rule: non-conventional subject allowed" { commit 'PROJ:123 updated some stuff'; }
@test "task id required by project" { blocked task-id commit 'feat: no task'; }
@test "task id present" { commit "$(printf 'feat: x\n\nOPS:42')"; }

@test "raised size limit" {
    head -c 600000 /dev/zero > big.bin
    git add big.bin
    git commit -q -m 'PROJ:1 big'
}

@test "custom debug pattern replaces default" { add f.php '<?php\ndd($x);\n'; }
@test "custom debug pattern applies" { blocked debug-statements add g.php '<?php\nforbidden_call();\n'; }
@test "skipped rule: push to main allowed" { git push -q origin feature:main; }
@test "project exclude: auth.json" { add auth.json '{}\n'; }
@test "project exclude: key fixture" { add fixtures/test-key.txt '-----BEGIN RSA PRIVATE KEY-----\n'; }
@test "exclude is per path: key elsewhere still caught" { blocked private-keys add other.txt '-----BEGIN RSA PRIVATE KEY-----\n'; }

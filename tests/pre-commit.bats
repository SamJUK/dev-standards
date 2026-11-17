setup() {
    load helpers
    project
}

@test "conflict marker" { blocked conflict-markers add a.txt '<<<<<<< HEAD\nx\n'; }
@test "setext heading is not a conflict marker" { add b.md 'Title\n=======\n'; }
@test "dd()" { blocked debug-statements add c.php '<?php\ndd($x);\n'; }
@test "var_dump is left to PHPCS outside Laravel" { add c.php '<?php\nvar_dump($x);\n'; }
@test "add() and ->dump() are not debug calls" { add e.php '<?php\n$this->add($x);\n$y->dump($z);\n'; }
@test "console.log" { blocked debug-statements add d.js 'console.log(x);\n'; }
@test "console.log in docs is fine" { add d.md 'Call console.log(x) to see it.\n'; }
@test "json.dump in Python is fine" { add d.py 'json.dump(a, f)\n'; }

@test "renamed file is not scanned again" {
    printf 'console.log(1);\n' > d.js && git add d.js && git commit -q --no-verify -m 'chore: old log'
    git mv d.js d2.js
    git commit -q -m 'refactor: rename'
}

@test "renamed file with a new debug call" {
    printf 'console.log(1);\n' > d.js && git add d.js && git commit -q --no-verify -m 'chore: old log'
    git mv d.js d3.js
    printf 'console.log(1);\nconsole.log(2);\n' > d3.js
    git add d3.js
    blocked debug-statements git commit -q -m 'refactor: rename'
    [[ $output == *"d3.js:2:"* && $output != *"d3.js:1:"* ]]
}

@test "one-off LEFTHOOK_EXCLUDE" { LEFTHOOK_EXCLUDE=debug-statements add j.php '<?php\ndd(1);\n'; }
@test "auth.json" { blocked credential-files add auth.json '{}\n'; }
@test "env.php" { blocked credential-files add app/etc/env.php 'x'; }
@test ".env.example" { add .env.example 'APP_KEY=\n'; }
@test ".env.production.local" { blocked credential-files add .env.production.local 'APP_KEY=x\n'; }
@test "private key" { blocked private-keys add id_rsa '-----BEGIN OPENSSH PRIVATE KEY-----\nabc\n'; }
@test "public key" { add id_rsa.pub 'ssh-ed25519 AAAA test\n'; }

@test "file over 500KB" {
    head -c 600000 /dev/zero > big.bin
    git add big.bin
    blocked large-files git commit -q -m 'feat: big'
}

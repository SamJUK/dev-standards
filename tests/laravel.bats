# A Laravel app in web/, the package in its vendor/ as Composer installs it, Pint faked to reject BAD.
setup() {
    load helpers
    project
    install_package web/vendor
    fake_tool web/vendor/bin/pint
    touch web/artisan
    printf '/web/vendor/\n' > .gitignore
    use_hooks web/vendor/samjuk/dev-standards laravel
}

@test "pint failure blocks" { blocked php-standards add web/Bad.php '<?php // BAD\n'; }
@test "clean file" { add web/Good.php '<?php\n'; }
@test "files outside web/ skip pint" { add Other.php '<?php // BAD\n'; }
@test "var_dump is caught" { blocked debug-statements add web/Dump.php '<?php\nvar_dump(1);\n'; }

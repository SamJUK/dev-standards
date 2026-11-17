# Magento projects and modules. PHPCS is faked to reject files containing BAD.
setup() {
    load helpers
    project
}

# A module repository with the package in vendor/ as Composer installs it.
module() {
    install_package vendor
    fake_tool vendor/bin/phpcs
    printf '/vendor/\n' > .gitignore
    add registration.php '<?php\n' && add Model/Item.php '<?php\n'
    use_hooks vendor/samjuk/dev-standards magento
}

# A module kept under src/, known only by its composer type, scoped by phpcs.xml.dist.
src_module() {
    install_package vendor
    fake_tool vendor/bin/phpcs
    printf '/vendor/\n' > .gitignore
    printf '{"type": "magento2-module"}\n' > composer.json
    for dir in src dev lib legacy extra; do mkdir -p $dir && printf '<?php\n' > $dir/a.php; done
    use_hooks vendor/samjuk/dev-standards magento
}

@test "project: ObjectManager::getInstance" {
    project "$(printf 'pre-commit:\n  jobs:\n    - name: php-standards\n      skip: true\n')" "  - $root/lefthook/magento.yml"
    blocked magento-object-manager add h.php '<?php\n\\\\Magento\\\\Framework\\\\App\\\\ObjectManager::getInstance();\n'
}

@test "project: injected dependency" {
    project "$(printf 'pre-commit:\n  jobs:\n    - name: php-standards\n      skip: true\n')" "  - $root/lefthook/magento.yml"
    add i.php '<?php\n$this->repository->get(1);\n'
}

@test "module: phpcs failure blocks" { module; blocked php-standards add Model/Bad.php '<?php // BAD\n'; }
@test "module: clean file" { module; add Model/Good.php '<?php\n'; }
@test "module: file name with a space" { module; blocked php-standards add 'Model/My Bad.php' '<?php // BAD\n'; }
@test "module: root registration.php is checked" { module; blocked php-standards add registration.php '<?php // BAD\n'; }

@test "staged content is checked, not the working tree" {
    module
    printf '<?php // BAD\n' > Model/S.php && git add Model/S.php && printf '<?php\n' > Model/S.php
    blocked php-standards git commit -q -m 'feat: s'
    [ "$(cat Model/S.php)" = '<?php' ]
}

@test "unstaged changes are not checked" {
    module
    printf '<?php\n' > Model/T.php && git add Model/T.php && printf '<?php // BAD\n' > Model/T.php
    git commit -q -m 'feat: t'
}

@test "module: init lists the module's folders, no PHPStan" {
    module
    vendor/bin/samjuk-dev-standards init
    grep -q '<file>Model</file>' phpcs.xml.dist
    grep -q '<file>registration.php</file>' phpcs.xml.dist
    [ ! -f phpstan.neon.dist ]
}

@test "module: no PHPStan config with Magento but no PHPStan" {
    module
    mkdir -p vendor/magento/framework
    vendor/bin/samjuk-dev-standards init
    [ ! -f phpstan.neon.dist ]
}

@test "module: init adds PHPStan once it and Magento are installed" {
    module
    mkdir -p vendor/magento/framework
    printf '#!/bin/sh\n' > vendor/bin/phpstan && chmod +x vendor/bin/phpstan
    vendor/bin/samjuk-dev-standards init
    grep -q '        - Model' phpstan.neon.dist
}

@test "module in src/: init finds it by composer type" {
    src_module
    printf '<?php\n' > src/registration.php
    vendor/bin/samjuk-dev-standards init
    grep -q '<file>src</file>' phpcs.xml.dist
}

scoped() {
    src_module
    printf '<?xml version="1.0"?>\n<ruleset name="m">\n    <!-- <file>dev</file> --><file>./src/</file><file type="x">lib</file>\n    <!--\n    <file>legacy</file>\n    -->\n    <file>\n        extra\n    </file>\n</ruleset>\n' > phpcs.xml.dist
    git add phpcs.xml.dist && git commit -q --no-verify -m 'chore: scope'
}

@test "phpcs.xml.dist: listed folder is checked" { scoped; blocked php-standards add src/Bad.php '<?php // BAD\n'; }
@test "phpcs.xml.dist: second entry on the line, with attributes" { scoped; blocked php-standards add lib/Bad.php '<?php // BAD\n'; }
@test "phpcs.xml.dist: entry in a one-line comment is not" { scoped; add dev/Bad.php '<?php // BAD\n'; }
@test "phpcs.xml.dist: entry in a multi-line comment is not" { scoped; add legacy/Bad.php '<?php // BAD\n'; }
@test "phpcs.xml.dist: entry over several lines is" { scoped; blocked php-standards add extra/Bad.php '<?php // BAD\n'; }

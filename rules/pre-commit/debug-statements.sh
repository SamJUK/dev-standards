#!/bin/sh
# Only what the stack's own tools miss. Magento's PHPCS already flags var_dump and print_r; nothing on Laravel does.
# PHP calls are looked for in PHP files and console calls in script files; DEBUG_PATTERN applies to every file.
added="$(dirname "$0")/../lib/added-lines.sh"
[ -n "${DEBUG_PATTERN:-}" ] && exec "$added" debug-statements "$DEBUG_PATTERN" 'Debug statements:' "$@"

calls='dd|dump|ray'
[ -n "$(git ls-files -- artisan '*/artisan')" ] && calls="$calls|var_dump|print_r"
php=$(for f; do case $f in (*.php | *.phtml) printf '%s\n' "$f" ;; esac; done)
js=$(for f; do case $f in (*.js | *.mjs | *.cjs | *.ts | *.mts | *.cts | *.jsx | *.tsx | *.vue | *.svelte | *.astro | *.html | *.phtml) printf '%s\n' "$f" ;; esac; done)

IFS='
'
set -f
status=0
# shellcheck disable=SC2086 # one path per line, split on newlines
[ -z "$php" ] || "$added" debug-statements "(^|[^[:alnum:]_\$>:.])($calls)\(" 'Debug statements:' $php || status=1
# shellcheck disable=SC2086
[ -z "$js" ] || "$added" debug-statements 'console\.(log|debug)\(|^[[:space:]]*debugger;' 'Debug statements:' $js || status=1
exit $status

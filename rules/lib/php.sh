#!/bin/sh
# Run a PHP command with host PHP, or inside Warden or DDEV when the host has none.
if command -v php >/dev/null 2>&1; then
    exec php "$@"
elif [ -f .env ] && grep -q '^WARDEN_ENV_TYPE=' .env && command -v warden >/dev/null 2>&1; then
    exec warden env exec -T php-fpm php "$@"
elif [ -d .ddev ] && command -v ddev >/dev/null 2>&1; then
    exec ddev exec php "$@"
fi
echo "No PHP on the host and no running Warden or DDEV environment. Start one, or skip the check once: LEFTHOOK_EXCLUDE=php-standards git commit ..." >&2
exit 1

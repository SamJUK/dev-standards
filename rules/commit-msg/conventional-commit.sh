#!/bin/sh
# Subject follows Conventional Commits: type(scope)!: summary
types=${COMMIT_TYPES:-build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test}
"$(dirname "$0")/../lib/generated.sh" "$1" && exit 0
subject=$("$(dirname "$0")/../lib/message.sh" "$1" | sed -n '/./{p;q;}')

printf '%s\n' "$subject" | grep -Eq "^($types)(\([^)]+\))?!?: [^ ]" && exit 0

echo "Subject must follow Conventional Commits, for example: fix(cart): handle an empty quote"
echo "  types: $types"
echo "  got:   $subject"
exit 1

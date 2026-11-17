#!/bin/sh
# Message references a task, matching TASK_ID_PATTERN (an extended regex). Off until a pattern is set.
[ -n "$TASK_ID_PATTERN" ] || exit 0
"$(dirname "$0")/../lib/generated.sh" "$1" && exit 0
message=$("$(dirname "$0")/../lib/message.sh" "$1")

printf '%s\n' "$message" | grep -Eq "$TASK_ID_PATTERN" && exit 0
echo "Commit message must reference a task matching: $TASK_ID_PATTERN"
exit 1

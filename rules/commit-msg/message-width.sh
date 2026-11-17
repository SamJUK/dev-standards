#!/bin/sh
# Subject and body line length. Lines with a URL are exempt from the body limit.
subject_max=${SUBJECT_MAX_WIDTH:-72}
body_max=${BODY_MAX_WIDTH:-72}
"$(dirname "$0")/../lib/generated.sh" "$1" && exit 0

"$(dirname "$0")/../lib/message.sh" "$1" | awk -v s="$subject_max" -v b="$body_max" '
    !seen && /./ { seen = 1; if (length($0) > s) { printf "Subject is %d characters; the limit is %d\n", length($0), s; bad = 1 }; next }
    seen && !/:\/\// && length($0) > b { printf "Body line %d is %d characters; the limit is %d\n", NR, length($0), b; bad = 1 }
    END { exit bad }
'

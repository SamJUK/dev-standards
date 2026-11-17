#!/bin/sh
# Usage: added-lines.sh <rule> <extended regex> <message> <files...>
# Fails if a line added to a staged file matches the regex. A renamed file is compared with its old path.
rule=$1 pattern=$2 message=$3
shift 3
lines=$(mktemp)
hits=$(mktemp)
trap 'rm -f "$lines" "$hits"' EXIT
renames=$(git -c core.quotePath=false diff --cached -M --name-status --diff-filter=R)

for file; do
    old=$(printf '%s\n' "$renames" | awk -F '\t' -v f="$file" '$3 == f { print $2 }')
    git diff --cached -M -U0 --no-color -- ${old:+"$old"} "$file" | awk '/^@@/ {
        split($3, a, ","); start = substr(a[1], 2); count = (2 in a) ? a[2] : 1
        for (i = 0; i < count; i++) print start + i
    }' > "$lines"
    [ -s "$lines" ] || continue

    git show ":$file" | PATTERN=$pattern awk -v file="$file" '
        NR == FNR { added[$1] = 1; next }
        (FNR in added) && $0 ~ ENVIRON["PATTERN"] { printf "%s:%d: %s\n", file, FNR, $0 }
    ' "$lines" - >> "$hits"
done

[ -s "$hits" ] || exit 0
echo "$message"
cat "$hits"
echo "To commit it anyway, skip the rule once: LEFTHOOK_EXCLUDE=$rule git commit ..."
exit 1

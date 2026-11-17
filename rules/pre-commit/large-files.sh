#!/bin/sh
# Staged files over LARGE_FILE_KB that are not tracked by Git LFS.
max=$(( ${LARGE_FILE_KB:-500} * 1024 ))
status=0
for file; do
    [ "$(git check-attr filter -- "$file" | sed 's/.*: //')" = lfs ] && continue
    size=$(git cat-file -s ":$file" 2>/dev/null) || continue
    if [ "$size" -gt "$max" ]; then
        echo "$file is $(( size / 1024 ))KB; the limit is ${LARGE_FILE_KB:-500}KB (track it with Git LFS, or add it to this job's exclude in lefthook.yml)"
        status=1
    fi
done
exit $status

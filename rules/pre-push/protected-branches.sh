#!/bin/sh
# Block pushing straight to a protected branch. Reads git's pre-push lines from stdin.
protected=${PROTECTED_BRANCHES:-main master}
status=0
while read -r _ local_sha remote_ref _; do
    [ "$local_sha" = 0000000000000000000000000000000000000000 ] && continue
    for branch in $protected; do
        if [ "$remote_ref" = "refs/heads/$branch" ]; then
            echo "Pushing straight to $branch is blocked; open a pull request instead."
            status=1
        fi
    done
done
exit $status

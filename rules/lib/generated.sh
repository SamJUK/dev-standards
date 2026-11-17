#!/bin/sh
# Succeeds for a message git wrote itself: merges, reverts, fixups and squashes, which the message rules leave alone.
case $("$(dirname "$0")/message.sh" "$1" | sed -n '/./{p;q;}') in
    Merge\ * | Revert\ * | fixup!\ * | squash!\ * | amend!\ *) exit 0 ;;
esac
exit 1

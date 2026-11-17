#!/bin/sh
exec "$(dirname "$0")/../lib/added-lines.sh" conflict-markers '^(<<<<<<<|>>>>>>>)( |$)' 'Merge conflict markers:' "$@"

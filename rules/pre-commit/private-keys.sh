#!/bin/sh
exec "$(dirname "$0")/../lib/added-lines.sh" private-keys '-----BEGIN ([A-Z]+ )*PRIVATE KEY-----' 'Private keys:' "$@"
